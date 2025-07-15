#include <pqc_extensionshandler.h>
#include <pqc_configfiles.h>
#include <QDir>
#include <QPluginLoader>
#include <pqc_notify.h>
#include <pqc_filefoldermodel.h>
#include <pqc_settingscpp.h>
#include <pqc_loadimage.h>
#include <QtConcurrent>

#ifdef PQMEXTENSIONS
#include <yaml-cpp/yaml.h>
#endif

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

#ifdef PQMEXTENSIONS

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

            // if there is a YAML file, then we load that one
            QString yamlfile = QString("%1/%2/definition.yml").arg(baseDir, id);
            if(!QFile::exists(yamlfile)) {

                qWarning() << "Required YAML file not found for extension" << id;
                qWarning() << "File expected at" << yamlfile;
                continue;

            }

            PQCExtensionInfo *extinfo = new PQCExtensionInfo;

            extinfo->location = QString("%1/%2").arg(baseDir, id);

            YAML::Node config;

            // LOAD yaml file
            try {
                config = YAML::LoadFile(yamlfile.toStdString());
            } catch(YAML::Exception &e) {
                qWarning() << "Failed to load YAML file:" << e.what();
                delete extinfo;
                continue;
            }

            /***********************************/
            // REQUIRED PROPERTIES:

            // version
            try {
                extinfo->version = config["metainfo"]["version"].as<int>();
            } catch(YAML::Exception &e) {
                qWarning() << "Failed to read required value for 'version':" << e.what();
                delete extinfo;
                continue;
            }

            // name
            try {
                extinfo->name = QString::fromStdString(config["metainfo"]["name"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Failed to read required value for 'name':" << e.what();
                delete extinfo;
                continue;
            }

            // description
            try {
                extinfo->description = QString::fromStdString(config["metainfo"]["description"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Failed to read required value for 'description':" << e.what();
                delete extinfo;
                continue;
            }

            // author
            try {
                extinfo->author = QString::fromStdString(config["metainfo"]["author"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Failed to read required value for 'author':" << e.what();
                delete extinfo;
                continue;
            }

            // contact
            try {
                extinfo->contact = QString::fromStdString(config["metainfo"]["contact"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Failed to read required value for 'contact':" << e.what();
                delete extinfo;
                continue;
            }

            // target API
            try {
                extinfo->targetAPI = config["metainfo"]["targetAPI"].as<int>();

                if(extinfo->targetAPI > CURRENTAPIVERSION) {
                    qWarning() << "Required API version -" << extinfo->targetAPI << "- newer than what's supported:" << CURRENTAPIVERSION;
                    qWarning() << "Extension" << id << "located at" << baseDir << "not enabled.";
                    delete extinfo;
                    continue;
                }

            } catch(YAML::Exception &e) {
                qWarning() << "Failed to read required value for 'targetAPI':" << e.what();
                delete extinfo;
                continue;
            }

            /***********************************/
            // OPTIONAL values

            // default shortcut to toggle element
            try {
                extinfo->defaultShortcut = QString::fromStdString(config["setup"]["defaultShortcut"].as<std::string>());
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'defaultShortcut' invalid or not found, skipping:" << e.what();
            }

            // minimum required window size
            try {
                std::list<int> vals = config["setup"]["minimumRequiredWindowSize"].as<std::list<int> >();
                if(vals.size() != 2)
                    qWarning() << "Expected two values (width, height) for property 'minimumRequiredWindowSize', but found" << vals.size();
                else
                    extinfo->minimumRequiredWindowSize = QSize(vals.front(), vals.back());
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'minimumRequiredWindowSize' invalid or not found, skipping:" << e.what();
            }

            // is modal
            try {
                extinfo->isModal = config["setup"]["isModal"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'isModal' invalid or not found, skipping:" << e.what();
            }

            // allow integrated
            try {
                extinfo->allowIntegrated = config["setup"]["allowIntegrated"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'allowIntegrated' invalid or not found, skipping:" << e.what();
            }

            // allow popout
            try {
                extinfo->allowPopout = config["setup"]["allowPopout"].as<bool>();
                if(!extinfo->allowPopout && !extinfo->allowIntegrated) {
                    qWarning() << "At least one of integrated or popout needs to be enabled. Force-enabling integrated.";
                    extinfo->allowIntegrated = true;
                }
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'allowPopout' invalid or not found, skipping:" << e.what();
            }

            // position at
            try {
                extinfo->positionAt = extinfo->getEnumForPosition(config["setup"]["positionAt"].as<std::string>());
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'isModal' invalid or not found, skipping:" << e.what();
            }

            // remember geometry
            try {
                extinfo->rememberGeometry = config["setup"]["rememberGeometry"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'rememberGeometry' invalid or not found, skipping:" << e.what();
            }

            // fix size to content
            try {
                extinfo->fixSizeToContent = config["setup"]["fixSizeToContent"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'fixSizeToContent' invalid or not found, skipping:" << e.what();
            }

            // pass through mouse events
            try {
                extinfo->letMeHandleMouseEvents = config["setup"]["letMeHandleMouseEvents"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'letMeHandleMouseEvents' invalid or not found, skipping:" << e.what();
            }

            // settings
            try {

                for(const auto &sets : config["setup"]["settings"]) {

                    QStringList vals;
                    for(auto const& l : sets)
                        vals.append(QString::fromStdString(l.as<std::string>()));

                    if(vals.length()) {
                        qWarning() << ">>> APPENDING:" << vals;
                        extinfo->settings.append(vals);
                    }

                }

                // std::list<std::list<std::string> > vals = config["setup"]["shortcuts"].as<std::list<std::list<std::string> >();
            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'settings' invalid or not found, skipping:" << e.what();
            }

            // whether CPP actions have been supplied
            try {
                extinfo->haveCPPActions = config["setup"]["haveCPPActions"].as<bool>();

                if(extinfo->haveCPPActions) {

                    // make sure we can find and load the actions
                    QDir extDir(baseDir + "/" + id);
#ifdef Q_OS_UNIX
                    extDir.setNameFilters({"*.so"});
#else
                    extDir.setNameFilters({"*.dll"});
#endif
                    QStringList filList = extDir.entryList();

                    if(filList.length() == 0) {

                        qWarning() << "No shared library found at" << baseDir;
                        qWarning() << "CPP actions of extension" << id << "have not been enabled!";
                        extinfo->haveCPPActions = false;

                    } else {

                        const QString libName = QString("%1/%2/%3").arg(baseDir, id, filList.at(0));

                        // linker file does not exist
                        if(!QFile::exists(libName)) {
                            qWarning() << "Expected file" << filList.at(0) << "not found.";
                            qWarning() << "Extension" << id << "located at" << baseDir << "not enabled.";
                            delete extinfo;
                            continue;
                        }

                        QPluginLoader loader(libName);
                        QObject *plugin = loader.instance();
                        if(plugin) {

                            PQCExtensionActions *actions = qobject_cast<PQCExtensionActions*>(plugin);

                            if(actions) {
                                m_actions.insert(id, actions);
                            }
                        }

                    }

                }

            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'haveCPPActions' invalid or not found, skipping:" << e.what();
            }

            // all good so far, we have what we need

            m_extensions.append(id);
            m_allextensions.insert(id, extinfo);

        }

    }

    m_numExtensions = m_extensions.length();
    Q_EMIT numExtensionsChanged();

    if(m_extensions.length())
        qDebug() << "Successfully loaded the following extensions:" << m_extensions.join(", ");
    else
        qDebug() << "No extensions found.";

#else
    qDebug() << "Extension support has been disabled at compile time.";
#endif

}

PQCExtensionsHandler::~PQCExtensionsHandler() {}

QStringList PQCExtensionsHandler::getExtensions() {
    return m_extensions;
}

QStringList PQCExtensionsHandler::getDisabledExtensions() {
    return m_extensionsDisabled;
}

/****************************************/

QString PQCExtensionsHandler::getExtensionLocation(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->location;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

int PQCExtensionsHandler::getExtensionVersion(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->version;
    qWarning() << "Unknown extension id:" << id;
    return 0;
}

QString PQCExtensionsHandler::getExtensionName(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->name;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionAuthor(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->author;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionContact(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->contact;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionDescription(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->description;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

int PQCExtensionsHandler::getExtensionTargetAPIVersion(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->targetAPI;
    qWarning() << "Unknown extension id:" << id;
    return 1;
}

/****************************************/

QString PQCExtensionsHandler::getExtensionDefaultShortcut(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->defaultShortcut;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QSize PQCExtensionsHandler::getExtensionMinimumRequiredWindowSize(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->minimumRequiredWindowSize;
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

bool PQCExtensionsHandler::getExtensionIsModal(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->isModal;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionAllowIntegrated(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->allowIntegrated;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionAllowPopout(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->allowPopout;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

PQCExtensionInfo::DefaultPosition PQCExtensionsHandler::getExtensionPositionAt(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->positionAt;
    qWarning() << "Unknown extension id:" << id;
    return PQCExtensionInfo::TopLeft;
}

bool PQCExtensionsHandler::getExtensionRememberGeometry(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->rememberGeometry;
    qWarning() << "Unknown extension id:" << id;
    return true;
}

bool PQCExtensionsHandler::getExtensionFixSizeToContent(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->fixSizeToContent;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionLetMeHandleMouseEvents(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->letMeHandleMouseEvents;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

/****************************************/

QList<QStringList> PQCExtensionsHandler::getExtensionSettings(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->settings;
    qWarning() << "Unknown extension id:" << id;
    return {};
}

bool PQCExtensionsHandler::getExtensionHasCPPActions(QString id) {
    if(m_allextensions.contains(id))
        return true;
    qWarning() << "Unknown extension id:" << id;
    return {};
}

bool PQCExtensionsHandler::getHasSettings(const QString &id) {
    if(m_allextensions.contains(id))
        return QFile::exists(QString("%1/qml/PQ%2Settings.qml").arg(m_allextensions[id]->location, id));
    qWarning() << "Unknown extension id:" << id;
    return false;
}

QString PQCExtensionsHandler::getExtensionForShortcut(QString sh) {
    return m_activeShortcutToExtension.value(sh, "");
}

QString PQCExtensionsHandler::getShortcutForExtension(QString id) {
    return m_extensionToActiveShortcut.value(id, "");
}

void PQCExtensionsHandler::addShortcut(QString id, QString sh) {
    if(!m_activeShortcutToExtension.contains(sh)) {
        m_extensionToActiveShortcut.insert(id, sh);
        m_activeShortcutToExtension.insert(sh, id);
    }
}

void PQCExtensionsHandler::removeShortcut(QString id) {
    if(m_extensionToActiveShortcut.contains(id)) {
        m_activeShortcutToExtension.remove(m_extensionToActiveShortcut.value(id));
        m_extensionToActiveShortcut.remove(id);
    }
}

bool PQCExtensionsHandler::getHasActions(const QString &id) {
    return m_actions.contains(id);
}

void PQCExtensionsHandler::requestCallActionWithImage1(const QString &id, QVariant additional) {
    qDebug() << "args: id =" << id;
    QFuture<void> future = QtConcurrent::run([=] {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModel::get().getCurrentFile(), QSize(-1,-1), sze, img);
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->actionWithImage1(PQCFileFolderModel::get().getCurrentFile(), img, additional);
            Q_EMIT replyForActionWithImage1(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForActionWithImage1(id, QVariant(""));
        }
    });
}

void PQCExtensionsHandler::requestCallActionWithImage2(const QString &id, QVariant additional) {
    qDebug() << "args: id =" << id;
    QFuture<void> future = QtConcurrent::run([=] {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModel::get().getCurrentFile(), QSize(-1,-1), sze, img);
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->actionWithImage2(PQCFileFolderModel::get().getCurrentFile(), img, additional);
            Q_EMIT replyForActionWithImage2(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForActionWithImage1(id, QVariant(""));
        }
    });
}

void PQCExtensionsHandler::requestCallAction1(const QString &id, QVariant additional) {
    qDebug() << "args: id =" << id;
    QFuture<void> future = QtConcurrent::run([=] {
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->action1(PQCFileFolderModel::get().getCurrentFile(), additional);
            Q_EMIT replyForAction1(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForActionWithImage1(id, QVariant(""));
        }
    });
}

void PQCExtensionsHandler::requestCallAction2(const QString &id, QVariant additional) {
    qDebug() << "args: id =" << id;
    QFuture<void> future = QtConcurrent::run([=] {
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->action2(PQCFileFolderModel::get().getCurrentFile(), additional);
            Q_EMIT replyForAction2(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForActionWithImage1(id, QVariant(""));
        }
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
