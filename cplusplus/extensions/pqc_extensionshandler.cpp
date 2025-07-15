#include <pqc_extensionshandler.h>
#include <pqc_configfiles.h>
#include <QDir>
#include <QPluginLoader>
#include <pqc_notify.h>
#include <pqc_filefoldermodel.h>
#include <pqc_settingscpp.h>
#include <pqc_loadimage.h>
#include <QtConcurrent>

/****************************************************************/
/****************************************************************/
// This is the current/latest version supported by this build!
#define CURRENTAPIVERSION 1
/****************************************************************/
/****************************************************************/

PQCExtensionsHandler::PQCExtensionsHandler() {
    previousCurrentFile = "";
    m_numExtensions = 0;

    connect(&PQCFileFolderModel::get(), &PQCFileFolderModel::currentFileChanged, this, [=]() {
        m_currentFile = PQCFileFolderModel::get().getCurrentFile();
        Q_EMIT currentFileChanged();
    });
    connect(&PQCFileFolderModel::get(), &PQCFileFolderModel::currentIndexChanged, this, [=]() {
        m_currentIndex = PQCFileFolderModel::get().getCurrentIndex();
        Q_EMIT currentIndexChanged();
    });
    connect(&PQCFileFolderModel::get(), &PQCFileFolderModel::countMainViewChanged, this, [=]() {
        m_numFiles = PQCFileFolderModel::get().getCountMainView();
        Q_EMIT numFilesChanged();
    });

    connect(&PQCNotify::get(), &PQCNotify::currentImageLoadedAndDisplayed, this, &PQCExtensionsHandler::currentImageDisplayed);

    m_numFiles = PQCFileFolderModel::get().getCountMainView();
    m_currentIndex = PQCFileFolderModel::get().getCurrentIndex();
    m_currentFile = PQCFileFolderModel::get().getCurrentFile();

}

void PQCExtensionsHandler::setup() {

#ifdef Q_OS_UNIX
    const QStringList checkDirs = {"/usr/lib/PhotoQt/extensions",
                                   PQCConfigFiles::get().DATA_DIR() + "/extensions",
                                   // this one is for development in particular:
                                   QDir::homePath()+"/.INSTALL/lib/PhotoQt/extensions/"};
#else
    const QStringList checkDirs = {qgetenv("PHOTOQT_EXE_BASEDIR"),
                                   PQCConfigFiles::get().DATA_DIR() + "/extensions"};
#endif

    // This needs to be instantiated to make sure that the CPP class has been populated.
    // Even though this object is not to be used anywhere.

    qDebug() << "Checking the following directories for plugins:" << checkDirs.join(", ");

    for(const QString &baseDir : checkDirs) {

        QDir pluginsDir(baseDir);

        const QStringList dirlist = pluginsDir.entryList(QDir::Dirs|QDir::NoDotAndDotDot);
        for(const QString &id : dirlist) {

            if(!PQCSettingsCPP::get().getGeneralEnabledExtensions().contains(id)) {
                qDebug() << "Extension" << id << "disabled.";
                m_extensionsDisabled.append(id);
                continue;
            }

            QDir extDir(baseDir + "/" + id);
#ifdef Q_OS_UNIX
            extDir.setNameFilters({"*.so"});
#else
            extDir.setNameFilters({"*.dll"});
#endif
            QStringList filList = extDir.entryList();
            if(filList.length() == 0) {
                qWarning() << "No shared library found at" << baseDir;
                qWarning() << "Plugin" << id << "not enabled.";
                continue;
            }
            const QString libName = filList.at(0);

            // linker file does not exist
            if(!QFile::exists(baseDir + "/" + id + "/" + libName)) {
                qWarning() << "Expected file" << libName << "not found.";
                qWarning() << "Plugin" << id << "located at" << baseDir << "not enabled.";
                continue;
            }

            // minimum required qml files
            if(!QFile::exists(QString(baseDir + "/" + id + "/qml/PQ%1.qml").arg(id))) {
                qWarning() << "Expected QML file not found:" << QString(id + "/modern/PQ%1.qml").arg(id);
                qWarning() << "Plugin" << id << "not enabled.";
                continue;
            }

            QPluginLoader loader(baseDir + "/" + id + "/" + libName);
            QObject *plugin = loader.instance();
            if(plugin) {

                PQExtensionsAPI *interface = qobject_cast<PQExtensionsAPI*>(plugin);

                if(interface) {

                    if(interface->targetAPIVersion() > CURRENTAPIVERSION) {

                        qWarning() << "Required API version -" << interface->targetAPIVersion() << "- newer than what's supported:" << CURRENTAPIVERSION;
                        qWarning() << "Plugin" << id << "located at" << baseDir << "not enabled.";

                    } else {

                        // SUCCESS
                        // NOW LETS LOAD IT!

                        m_extensions.append(id);
                        m_allextensions.insert(id, interface);
                        m_extensionLocation.insert(id, baseDir + "/" + id);

                        const QList<QStringList> actions = interface->shortcuts();
                        QStringList allsh;
                        for(const QStringList &l : actions) {
                            allsh.append(l[0]);
                            m_mapShortcutToExtension.insert(l[0], id);
                        }
                        m_shortcuts.insert(id, allsh);
                        m_simpleListAllShortcuts.append(allsh);

                    }

                } else {

                    qWarning() << "Could not cast plugin to PQExtensionsAPI";
                    qWarning() << "Plugin" << id << "located at" << baseDir << "not enabled.";

                }

            } else {

                qWarning() << "Plugin failed to load:" << loader.errorString();
                qWarning() << "Plugin" << id << "located at" << baseDir << "not enabled.";

            }

        }

    }

    m_numExtensions = m_extensions.length();
    Q_EMIT numExtensionsChanged();

    if(m_extensions.length())
        qDebug() << "Successfully loaded the following extensions:" << m_extensions.join(", ");
    else
        qDebug() << "No extensions found.";

}

PQCExtensionsHandler::~PQCExtensionsHandler() {}

QStringList PQCExtensionsHandler::getExtensions() {
    return m_extensions;
}

QStringList PQCExtensionsHandler::getDisabledExtensions() {
    return m_extensionsDisabled;
}

/****************************************/

int PQCExtensionsHandler::getExtensionVersion(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->version();
    qWarning() << "Unknown extension id:" << id;
    return 0;
}

QString PQCExtensionsHandler::getExtensionName(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->name();
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionAuthor(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->author();
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionContact(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->contact();
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionDescription(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->description();
    qWarning() << "Unknown extension id:" << id;
    return "";
}

int PQCExtensionsHandler::getExtensionTargetAPIVersion(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->targetAPIVersion();
    qWarning() << "Unknown extension id:" << id;
    return 1;
}

/****************************************/

QSize PQCExtensionsHandler::getExtensionMinimumRequiredWindowSize(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->minimumRequiredWindowSize();
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

bool PQCExtensionsHandler::getExtensionIsModal(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->isModal();
    qWarning() << "Unknown extension id:" << id;
    return false;
}

PQExtensionsAPI::DefaultPosition PQCExtensionsHandler::getExtensionPositionAt(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->positionAt();
    qWarning() << "Unknown extension id:" << id;
    return PQExtensionsAPI::TopLeft;
}

bool PQCExtensionsHandler::getExtensionRememberPosition(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->rememberPosition();
    qWarning() << "Unknown extension id:" << id;
    return true;
}

bool PQCExtensionsHandler::getExtensionPassThroughMouseClicks(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->passThroughMouseClicks();
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionPassThroughMouseWheel(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->passThroughMouseWheel();
    qWarning() << "Unknown extension id:" << id;
    return false;
}

/****************************************/


QString PQCExtensionsHandler::getExtensionLocation(QString id) {
    if(m_extensionLocation.contains(id))
        return m_extensionLocation[id];
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QStringList PQCExtensionsHandler::getExtensionShortcuts(QString id) {
    if(m_shortcuts.contains(id)) {
        return m_shortcuts[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QList<QStringList> PQCExtensionsHandler::getExtensionShortcutsActions(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->shortcuts();
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QList<QStringList> PQCExtensionsHandler::getExtensionSettings(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->settings();
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QStringList PQCExtensionsHandler::getAllShortcuts() {
    return m_simpleListAllShortcuts;
}

QString PQCExtensionsHandler::getDescriptionForShortcut(QString sh) {
    QString ret = "";
    for(auto ext : std::as_const(m_allextensions)) {
        const QList<QStringList> allsh = ext->shortcuts();
        for(int i = 0; i < allsh.length(); ++i) {
            if(allsh[i][0] == sh) {
                ret = allsh[i][1];
                break;
            }
        }
        if(ret != "") break;
    }
    return ret;
}

QString PQCExtensionsHandler::getWhichExtensionForShortcut(QString sh) {
    return m_mapShortcutToExtension.value(sh, "");
}

QMap<QString, QList<QStringList> > PQCExtensionsHandler::getExtensionMigrateSettings(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->migrateSettings();
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QMap<QString, QList<QStringList> > PQCExtensionsHandler::getExtensionMigrateShortcuts(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->migrateShortcuts();
    qWarning() << "Unknown extension id:" << id;
    return {};
}

bool PQCExtensionsHandler::getHasSettings(const QString &id) {
    if(m_allextensions.contains(id))
        return QFile::exists(QString("%1/modern/PQ%2Settings.qml").arg(m_extensionLocation[id], id));
    qWarning() << "Unknown extension id:" << id;
    return false;
}

void PQCExtensionsHandler::requestCallActionWithImage1(const QString &id) {
    QFuture<void> future = QtConcurrent::run([=] {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModel::get().getCurrentFile(), QSize(-1,-1), sze, img);
        QVariant ret = m_allextensions[id]->actionWithImage1(PQCFileFolderModel::get().getCurrentFile(), img);
        Q_EMIT replyForActionWithImage1(id, ret);
    });
}

void PQCExtensionsHandler::requestCallActionWithImage2(const QString &id) {
    QFuture<void> future = QtConcurrent::run([=] {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModel::get().getCurrentFile(), QSize(-1,-1), sze, img);
        QVariant ret = m_allextensions[id]->actionWithImage2(PQCFileFolderModel::get().getCurrentFile(), img);
        Q_EMIT replyForActionWithImage2(id, ret);
    });
}

void PQCExtensionsHandler::requestCallAction1(const QString &id) {
    QFuture<void> future = QtConcurrent::run([=] {
        QVariant ret = m_allextensions[id]->action1(PQCFileFolderModel::get().getCurrentFile());
        Q_EMIT replyForAction1(id, ret);
    });
}

void PQCExtensionsHandler::requestCallAction2(const QString &id) {
    QFuture<void> future = QtConcurrent::run([=] {
        QVariant ret = m_allextensions[id]->action2(PQCFileFolderModel::get().getCurrentFile());
        Q_EMIT replyForAction2(id, ret);
    });
}

void PQCExtensionsHandler::requestExecutionOfInternalShortcut(const QString &cmd) {
    Q_EMIT PQCNotify::get().executeInternalCommand(cmd);
}

void PQCExtensionsHandler::requestShowingOf(const QString &id) {
    Q_EMIT PQCNotify::get().loaderShowExtension(id);
}

bool PQCExtensionsHandler::getIsEnabled(const QString &id) {
    if(m_allextensions.contains(id))
        return PQCSettingsCPP::get().getExtensionValue(id).toBool();
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getIsEnabledByDefault(const QString &id) {
    if(m_allextensions.contains(id))
        return PQCSettingsCPP::get().getExtensionDefaultValue(id).toBool();
    qWarning() << "Unknown extension id:" << id;
    return false;
}
