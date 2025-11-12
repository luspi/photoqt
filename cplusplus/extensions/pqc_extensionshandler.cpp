#include <pqc_extensionshandler.h>
#include <pqc_configfiles.h>
#include <pqc_notify_cpp.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <QDir>
#include <QPluginLoader>
#include <QtConcurrent/QtConcurrentRun>
#include <QImage>
#include <pqc_notify_cpp.h>
#include <pqc_filefoldermodelCPP.h>
#include <pqc_settingscpp.h>
#include <pqc_loadimage.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_imageformats.h>
#include <pqc_extensionsettings.h>

#ifdef PQMEXTENSIONS
#include <yaml-cpp/yaml.h>
#endif

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
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
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, [=](int key, int modifiers) {
        QString combo = PQCScriptsShortcuts::get().analyzeModifier(static_cast<Qt::KeyboardModifiers>(modifiers)).join("+");
        if(combo != "") combo += "+";
        combo += PQCScriptsShortcuts::get().analyzeKeyPress(static_cast<Qt::Key>(key));
        Q_EMIT receivedShortcut(combo);
    });
}

void PQCExtensionsHandler::setup() {

#ifdef PQMEXTENSIONS

#ifdef Q_OS_UNIX
#ifdef NDEBUG
    const QStringList checkDirs = {PQCConfigFiles::get().DATA_DIR() + "/extensions",
                                   QString("%1/extensions").arg(PQMBUILDDIR)};
#else
    const QStringList checkDirs = {QString("%1/lib/PhotoQt/extensions").arg(PQMINSTALLPREFIX),
                                   PQCConfigFiles::get().DATA_DIR() + "/extensions",
                                   QString("%1/extensions").arg(PQMBUILDDIR)};
#endif
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

            bool extEnabled = true;

            if(!PQCSettingsCPP::get().getGeneralEnabledExtensions().contains(id)) {
                qDebug() << "Extension" << id << "disabled.";
                extEnabled = false;
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
                qWarning() << "Extension:" << id << "- Failed to load YAML file:" << e.what();
                delete extinfo;
                continue;
            }

            /***********************************/
            // REQUIRED PROPERTIES: about

            // version
            try {
                extinfo->version = config["about"]["version"].as<int>();
            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'version':" << e.what();
                delete extinfo;
                continue;
            }

            // name
            try {
                extinfo->name = QString::fromStdString(config["about"]["name"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'name':" << e.what();
                delete extinfo;
                continue;
            }

            // description
            try {
                extinfo->description = QString::fromStdString(config["about"]["description"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'description':" << e.what();
                delete extinfo;
                continue;
            }

            // author
            try {
                extinfo->author = QString::fromStdString(config["about"]["author"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'author':" << e.what();
                delete extinfo;
                continue;
            }

            // contact
            try {
                extinfo->contact = QString::fromStdString(config["about"]["contact"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'contact':" << e.what();
                delete extinfo;
                continue;
            }

            // website
            try {
                extinfo->website = QString::fromStdString(config["about"]["website"].as<std::string>());
            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'website':" << e.what();
                delete extinfo;
                continue;
            }

            // target API
            try {
                extinfo->targetAPI = config["about"]["targetAPI"].as<int>();

                if(extinfo->targetAPI > CURRENTAPIVERSION) {
                    qWarning() << "Required API version -" << extinfo->targetAPI << "- newer than what's supported:" << CURRENTAPIVERSION;
                    qWarning() << "Extension" << id << "located at" << baseDir << "not enabled.";
                    delete extinfo;
                    continue;
                }

            } catch(YAML::Exception &e) {
                qWarning() << "Extension:" << id << "- Failed to read required value for 'targetAPI':" << e.what();
                delete extinfo;
                continue;
            }

            /***********************************/
            // OPTIONAL values

            //////////////////////
            // setup/integrated

            // allow integrated
            try {
                extinfo->integratedAllow = config["setup"]["integrated"]["allow"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'integrated/allow' invalid or not found, skipping:" << e.what();
            }

            // minimum required window size
            try {
                std::list<int> vals = config["setup"]["integrated"]["minimumRequiredWindowSize"].as<std::list<int> >();
                if(vals.size() != 2)
                    qWarning() << "Extension:" << id << "- Expected two values (width, height) for property 'minimumRequiredWindowSize', but found" << vals.size();
                else
                    extinfo->integratedMinimumRequiredWindowSize = QSize(vals.front(), vals.back());
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'minimumRequiredWindowSize' invalid or not found, skipping:" << e.what();
            }

            // default position
            try {
                extinfo->integratedDefaultPosition = extinfo->getIntegerForPosition(config["setup"]["integrated"]["defaultPosition"].as<std::string>());
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'defaultPosition' invalid or not found, skipping:" << e.what();
            }

            // default distance from window edge
            try {
                extinfo->integratedDefaultDistanceFromEdge = config["setup"]["integrated"]["defaultDistanceFromEdge"].as<int>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'defaultDistanceFromEdge' invalid or not found, skipping:" << e.what();
            }

            // default integrated size
            try {
                std::list<int> vals = config["setup"]["integrated"]["defaultSize"].as<std::list<int> >();
                if(vals.size() != 2)
                    qWarning() << "Extension:" << id << "- Expected two values (width, height) for property 'integrated/defaultSize', but found" << vals.size();
                else
                    extinfo->integratedDefaultSize = QSize(vals.front(), vals.back());
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'integrated/defaultSize' invalid or not found, skipping:" << e.what();
            }

            // fix size to content
            try {
                extinfo->integratedFixSizeToContent = config["setup"]["integrated"]["fixSizeToContent"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'integrated/fixSizeToContent' invalid or not found, skipping:" << e.what();
            }


            //////////////////////
            // setup/popout

            // allow popout
            try {
                extinfo->popoutAllow = config["setup"]["popout"]["allow"].as<bool>();
                if(!extinfo->popoutAllow && !extinfo->integratedAllow) {
                    qWarning() << "Extension:" << id << "- At least one of integrated or popout needs to be enabled. Force-enabling integrated.";
                    extinfo->integratedAllow = true;
                }
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'popout/allow' invalid or not found, skipping:" << e.what();
            }

            // default popout size
            try {
                std::list<int> vals = config["setup"]["popout"]["defaultSize"].as<std::list<int> >();
                if(vals.size() != 2)
                    qWarning() << "Extension:" << id << "- Expected two values (width, height) for property 'popout/defaultSize', but found" << vals.size();
                else
                    extinfo->popoutDefaultSize = QSize(vals.front(), vals.back());
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'popout/defaultSize' invalid or not found, skipping:" << e.what();
            }

            // fix size to content
            try {
                extinfo->popoutFixSizeToContent = config["setup"]["popout"]["fixSizeToContent"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'popout/fixSizeToContent' invalid or not found, skipping:" << e.what();
            }


            //////////////////////
            // setup

            // make element modal
            try {
                extinfo->modal = config["setup"]["modal"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'modal' invalid or not found, skipping:" << e.what();
            }

            // default shortcut to toggle element
            try {
                extinfo->defaultShortcut = QString::fromStdString(config["setup"]["defaultShortcut"].as<std::string>());
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'defaultShortcut' invalid or not found, skipping:" << e.what();
            }

            // remember geometry
            try {
                extinfo->rememberGeometry = config["setup"]["rememberGeometry"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'rememberGeometry' invalid or not found, skipping:" << e.what();
            }

            // let me handle mouse events
            try {
                extinfo->letMeHandleMouseEvents = config["setup"]["letMeHandleMouseEvents"].as<bool>();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'letMeHandleMouseEvents' invalid or not found, skipping:" << e.what();
            }

            // settings
            try {

                for(const auto &sets : config["setup"]["settings"]) {

                    QStringList vals;
                    for(auto const& l : sets)
                        vals.append(QString::fromStdString(l.as<std::string>()));

                    if(vals.length() == 3)
                        extinfo->settings.append(vals);

                }

                // std::list<std::list<std::string> > vals = config["setup"]["shortcuts"].as<std::list<std::list<std::string> >();
            } catch(YAML::Exception &e) {
                qDebug() << "Extension:" << id << "- Optional value for 'settings' invalid or not found, skipping:" << e.what();
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
                                connect(actions, &PQCExtensionActions::sendMessage, this, [=](QVariant val) { Q_EMIT receivedMessage(id, val); });
                                m_actions.insert(id, actions);
                            }
                        }

                    }

                }

            } catch(YAML::Exception &e) {
                qDebug() << "Optional value for 'haveCPPActions' invalid or not found, skipping:" << e.what();
            }

            // all good so far, we have what we need
            qDebug() << "Successfully loaded extension" << id << "from location:" << baseDir;

            if(extEnabled)
                m_extensions.append(id);
            else
                m_extensionsDisabled.append(id);
            m_allextensions.insert(id, extinfo);

        }

    }

    m_numExtensions = m_extensions.length();
    Q_EMIT numExtensionsChanged();

    if(m_extensions.length())
        qDebug() << "The following extensions have been enabled:" << m_extensions.join(", ");
    else
        qDebug() << "No extensions found.";

#else
    qDebug() << "Extension support has been disabled at compile time.";
#endif

    QFuture<void> future = QtConcurrent::run([=] {
        loadSettingsInBGToLookForShortcuts();
    });

}

PQCExtensionsHandler::~PQCExtensionsHandler() {}

QStringList PQCExtensionsHandler::getExtensions() {
    return m_extensions;
}

QStringList PQCExtensionsHandler::getDisabledExtensions() {
    return m_extensionsDisabled;
}

QStringList PQCExtensionsHandler::getExtensionsEnabledAndDisabld() {
    return QStringList() << m_extensions << m_extensionsDisabled;
}

/****************************************/

QString PQCExtensionsHandler::getExtensionLocation(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->location;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionConfigLocation(QString id) {
    const QString path = QString("%1/%2").arg(PQCConfigFiles::get().EXTENSION_CONFIG_DIR(), id);
    QDir dir(path);
    if(!dir.exists(path))
        dir.mkpath(path);
    return path;
}

QString PQCExtensionsHandler::getExtensionDataLocation(QString id) {
    const QString path = QString("%1/%2").arg(PQCConfigFiles::get().EXTENSION_DATA_DIR(), id);
    QDir dir(path);
    if(!dir.exists(path))
        dir.mkpath(path);
    return path;
}

QString PQCExtensionsHandler::getExtensionCacheLocation(QString id) {
    const QString path = QString("%1/%2").arg(PQCConfigFiles::get().EXTENSION_CACHE_DIR(), id);
    QDir dir(path);
    if(!dir.exists(path))
        dir.mkpath(path);
    return path;
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

QString PQCExtensionsHandler::getExtensionWebsite(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->website;
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

QSize PQCExtensionsHandler::getExtensionIntegratedDefaultSize(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->integratedDefaultSize;
    qWarning() << "Unknown extension id:" << id;
    return QSize(-1,-1);
}

QSize PQCExtensionsHandler::getExtensionPopoutDefaultSize(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->popoutDefaultSize;
    qWarning() << "Unknown extension id:" << id;
    return QSize(-1,-1);
}

QSize PQCExtensionsHandler::getExtensionIntegratedMinimumRequiredWindowSize(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->integratedMinimumRequiredWindowSize;
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

bool PQCExtensionsHandler::getExtensionModal(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->modal;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionIntegratedAllow(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->integratedAllow;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionPopoutAllow(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->popoutAllow;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

int PQCExtensionsHandler::getExtensionIntegratedDefaultPosition(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->integratedDefaultPosition;
    qWarning() << "Unknown extension id:" << id;
    return 0;
}

int PQCExtensionsHandler::getExtensionIntegratedDefaultDistanceFromEdge(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->integratedDefaultDistanceFromEdge;
    qWarning() << "Unknown extension id:" << id;
    return 50;
}

bool PQCExtensionsHandler::getExtensionRememberGeometry(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->rememberGeometry;
    qWarning() << "Unknown extension id:" << id;
    return true;
}

bool PQCExtensionsHandler::getExtensionIntegratedFixSizeToContent(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->integratedFixSizeToContent;
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getExtensionPopoutFixSizeToContent(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->popoutFixSizeToContent;
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

void PQCExtensionsHandler::requestCallActionWithImage(const QString &id, QVariant additional, bool async) {
    qDebug() << "args: id =" << id;
    qDebug() << "args: async =" << async;
    if(async) {
        QFuture<void> future = QtConcurrent::run([=] {
            QImage img;
            QSize sze;
            PQCLoadImage::get().load(PQCFileFolderModelCPP::get().getCurrentFile(), QSize(-1,-1), sze, img);
            if(m_actions.contains(id)) {
                QVariant ret = m_actions[id]->actionWithImage(PQCFileFolderModelCPP::get().getCurrentFile(), img, additional);
                Q_EMIT replyForActionWithImage(id, ret);
            } else {
                qWarning() << "No action provided for extension" << id;
                Q_EMIT replyForActionWithImage(id, QVariant(""));
            }
        });
    } else {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModelCPP::get().getCurrentFile(), QSize(-1,-1), sze, img);
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->actionWithImage(PQCFileFolderModelCPP::get().getCurrentFile(), img, additional);
            Q_EMIT replyForActionWithImage(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForActionWithImage(id, QVariant(""));
        }
    }
}

void PQCExtensionsHandler::requestCallAction(const QString &id, QVariant additional, bool async) {
    qDebug() << "args: id =" << id;
    qDebug() << "args: async =" << async;
    if(async) {
        QFuture<void> future = QtConcurrent::run([=] {
            if(m_actions.contains(id)) {
                QVariant ret = m_actions[id]->action(PQCFileFolderModelCPP::get().getCurrentFile(), additional);
                Q_EMIT replyForAction(id, ret);
            } else {
                qWarning() << "No action provided for extension" << id;
                Q_EMIT replyForAction(id, QVariant(""));
            }
        });
    } else {
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->action(PQCFileFolderModelCPP::get().getCurrentFile(), additional);
            Q_EMIT replyForAction(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForAction(id, QVariant(""));
        }
    }
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

void PQCExtensionsHandler::loadSettingsInBGToLookForShortcuts() {

    for(const QString &ext : std::as_const(m_extensions)) {

        // we don't need to do more than this, setting up this with the extensionId
        // like this loads the settings and enters the shortcuts
        ExtensionSettings set(ext);

    }

}

void PQCExtensionsHandler::setEnabledExtensions(QStringList ids) {
    m_extensions = ids;
    m_numExtensions = m_extensions.length();
    Q_EMIT numExtensionsChanged();
}

void PQCExtensionsHandler::setDisabledExtensions(QStringList ids) {
    m_extensionsDisabled = ids;
}

int PQCExtensionsHandler::installExtension(QString filepath) {

    qDebug() << "args: filepath =" << filepath;

    QHash<QString,QVariant> meta = getExtensionZipMetadata(filepath);

    if(meta.contains("error")) {
        QMessageBox::critical(0, "Invalid extension", QString("The extension does not appear to be valid and cannot be installed.\n\nError message:\n%1").arg(meta["error"].toString()));
        return 0;
    }

    QMessageBox msg;
    msg.setWindowTitle("Install extension?");
    msg.setText(QString("Do you want to install this extension?<br><br><b>Name:</b> %1 (version: %2)<br><b>Description:</b> %3<br><b>Author:</b> %4<br><b>Contact:</b> %5<br><b>Website:</b> %6").arg(meta["name"].toString()).arg(meta["version"].toInt()).arg(meta["description"].toString(), meta["author"].toString(), meta["contact"].toString(), meta["website"].toString()));
    msg.setTextFormat(Qt::RichText);
    msg.setStandardButtons(QMessageBox::Yes|QMessageBox::No);
    msg.setDefaultButton(QMessageBox::No);

    if(msg.exec() == QMessageBox::No)
        return -1;

    // TODO: install extension

    return 1;
}

QHash<QString,QVariant> PQCExtensionsHandler::getExtensionZipMetadata(QString filepath) {

    qDebug() << "args: filepath =" << filepath;

    QHash<QString,QVariant> ret;

#ifdef PQMEXTENSIONS

    // Create new archive handler
    struct archive *a = archive_read_new();

    // Read file
    archive_read_support_format_all(a);
    archive_read_support_filter_all(a);

// Read file - if something went wrong, output error message and stop here
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archiveFile.utf16()), 10240);
#else
    int r = archive_read_open_filename(a, filepath.toLocal8Bit().data(), 10240);
#endif
    if(r != ARCHIVE_OK) {
        QString msg = QString("ERROR: archive_read_open_filename() returned code of %1").arg(r);
        qWarning() << msg;
        ret["error"] = msg;
        return ret;
    }

    QByteArray definitionyml = "";

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        QFileInfo info(filenameinside);

        if(filenameinside.endsWith("definition.yml") && filenameinside.count("/") == 1) {

            // store read data in here
            const void *buff;
            size_t size;
            la_int64_t offset;

            // read data
            while((r = archive_read_data_block(a, &buff, &size, &offset)) == ARCHIVE_OK) {
                if(r != ARCHIVE_OK || size == 0) {
                    QString msg = QString("ERROR: Unable to read file 'definition.yml': %1 (%2)").arg(archive_error_string(a)).arg(r);
                    qWarning() << msg;
                    ret["error"] = msg;
                    break;
                }
                definitionyml = QByteArray::fromRawData((const char*) buff, size);
            }

        }

    }

    bool err = false;

    if(definitionyml != "") {

        YAML::Node config;

        // LOAD yaml file
        try {
            config = YAML::Load(definitionyml.toStdString());
        } catch(YAML::Exception &e) {
            QString msg = QString("Failed to load YAML file: %1").arg(e.what());
            qWarning() << msg;
            ret["error"] = msg;
            err = true;
        }

        if(!err) {
            // version
            try {
                ret["about"] = config["about"]["version"].as<int>();
            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'version': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

        if(!err) {
            // name
            try {
                ret["name"] = QString::fromStdString(config["about"]["name"].as<std::string>());
            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'name': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

        if(!err) {
            // description
            try {
                ret["description"] = QString::fromStdString(config["about"]["description"].as<std::string>());
            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'description': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

        if(!err) {
            // author
            try {
                ret["author"] = QString::fromStdString(config["about"]["author"].as<std::string>());
            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'author': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

        if(!err) {
            // contact
            try {
                ret["contact"] = QString::fromStdString(config["about"]["contact"].as<std::string>());
            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'contact': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

        if(!err) {
            // website
            try {
                ret["website"] = QString::fromStdString(config["about"]["website"].as<std::string>());
            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'website': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

        if(!err) {
            // target API
            try {
                ret["targetAPI"] = config["about"]["targetAPI"].as<int>();

                if(ret["targetAPI"].toInt() > CURRENTAPIVERSION) {
                    QString msg = QString("Required API version - %1 - newer than what's supported: %2").arg(ret["targetAPI"].toInt()).arg(CURRENTAPIVERSION);
                    qWarning() << msg;
                    ret["error"] = msg;
                    err = true;
                }

            } catch(YAML::Exception &e) {
                QString msg = QString("Failed to read value for 'targetAPI': %1").arg(e.what());
                qWarning() << msg;
                ret["error"] = msg;
                err = true;
            }
        }

    }

    // Close archive
    r = archive_read_close(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_close() returned code of" << r;
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_free() returned code of" << r;

    if(err)
        return ret;
    return ret;

#endif

    ret.insert("error", "Extension support is not available.");
    return ret;

}
