/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <pqc_extensionshandler.h>
#include <pqc_configfiles.h>
#include <pqc_notify_cpp.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <QDir>
#include <QPluginLoader>
#include <QtConcurrent/QtConcurrentRun>
#include <QImage>
#include <QTranslator>
#include <QTimer>
#include <pqc_filefoldermodelCPP.h>
#include <pqc_settingscpp.h>
#include <pqc_loadimage.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_imageformats.h>
#include <pqc_extensionsettings.h>
#include <scripts/pqc_scriptslocalization.h>
#include <pqc_metadata_cpp.h>
#include <pqc_extensioninfo.h>
#include <QCryptographicHash>

#ifdef PQMEXTENSIONS
#include <yaml-cpp/yaml.h>
#include <QtCrypto>
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
    m_numExtensionsEnabled = 0;
    m_numExtensionsAll = 0;
    resetNumExtensionsAll = new QTimer;
    resetNumExtensionsAll->setInterval(250);
    resetNumExtensionsAll->setSingleShot(false);
    connect(resetNumExtensionsAll, &QTimer::timeout, this, [=]() {
        m_numExtensionsEnabled = m_extensions.length();
        m_numExtensionsAll = m_extensions.length()+m_extensionsDisabled.length();
        Q_EMIT numExtensionsEnabledChanged();
        Q_EMIT numExtensionsAllChanged();
    });

    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceLanguageChanged, this, &PQCExtensionsHandler::updateTranslationLanguage);

}

void PQCExtensionsHandler::setup() {

    QFuture<void> future = QtConcurrent::run([=] {

#ifdef PQMEXTENSIONS

#ifdef Q_OS_UNIX
#ifdef NDEBUG
        const QStringList checkDirs = {PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       QString("%1/lib/PhotoQt/extensions").arg(PQMINSTALLPREFIX)};
#else
        const QStringList checkDirs = {QString("%1/extensions").arg(PQMBUILDDIR),
                                       PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       QString("%1/lib/PhotoQt/extensions").arg(PQMINSTALLPREFIX)};
#endif
#else
        const QStringList checkDirs = {PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       qgetenv("PHOTOQT_EXE_BASEDIR") + "/extensions"};
#endif

        // This needs to be instantiated to make sure that the CPP class has been populated.
        // Even though this object is not to be used anywhere.

        qDebug() << "Checking the following directories for plugins:" << checkDirs.join(", ");

        for(const QString &baseDir : checkDirs) {

            QDir pluginsDir(baseDir);

            const QStringList dirlist = pluginsDir.entryList(QDir::Dirs|QDir::NoDotAndDotDot);
            for(const QString &id : dirlist) {

                // if there is a YAML file, then we load that one
                const QString yamlfile = QString("%1/%2/manifest.yml").arg(baseDir, id);
                if(!QFile::exists(yamlfile)) {

                    qWarning() << "Required YAML file not found for extension" << id;
                    qWarning() << "File expected at" << yamlfile;
                    continue;

                }

#ifdef NDEBUG
                if(PQCSettingsCPP::get().getGeneralExtensionsEnforeVerification() && !verifyExtension(baseDir, id)) {

                    qWarning() << "Extension with id" << id << "did not pass verification but verification is enforced.";
                    qWarning() << "*********************************************************";
                    continue;

                }

#else
                qDebug() << "Debug build => extension verification is disabled";
#endif

                bool extEnabled = true;

                if(m_allextensions.contains(id)) {
                    qDebug() << "Extension with id" << id << "exists already.";
                    qDebug() << "Extension located at" << QString("%1/%2").arg(baseDir,id) << "will not be loaded";
                    continue;
                }

                if(!PQCSettingsCPP::get().getGeneralExtensionsEnabled().contains(id)) {
                    qDebug() << "Extension" << id << "disabled.";
                    extEnabled = false;
                }
                QFile fy(yamlfile);
                if(!fy.open(QIODevice::ReadOnly)) {
                    qWarning() << "Unable to read manifest.yml for reading";
                    continue;
                }
                QTextStream in(&fy);
                QString definition = in.readAll();

                PQCExtensionInfo *extinfo = new PQCExtensionInfo;

                extinfo->location = QString("%1/%2").arg(baseDir, id);

                if(!loadExtension(extinfo, id, baseDir, definition)) {
                    delete extinfo;
                    continue;
                }

                // all good so far, we have what we need
                qDebug() << "Successfully loaded extension" << id << "from location:" << baseDir;

                // create translator for this extension
                QTranslator *trans = new QTranslator;
                extTrans.insert(id, trans);

                if(extEnabled) {
                    m_extensions.append(id);
                    const QString qmfile = QString("%1/lang/%2_%3.qm").arg(extinfo->location,id,PQCScriptsLocalization::get().getActiveTranslationCode());
                    if(!QFile::exists(qmfile))
                        qDebug() << id << "- no translation file found:" << qmfile;
                    else {
                        if(trans->load(qmfile))
                            qApp->installTranslator(trans);
                        else
                            qWarning() << id << "- unable to install translator:" << PQCScriptsLocalization::get().getActiveTranslationCode();
                    }
                } else
                    m_extensionsDisabled.append(id);
                m_allextensions.insert(id, extinfo);

            }

        }

        m_numExtensionsEnabled = m_extensions.length();
        m_numExtensionsAll = m_extensions.length()+m_extensionsDisabled.length();
        Q_EMIT numExtensionsEnabledChanged();
        Q_EMIT numExtensionsAllChanged();

        if(m_extensions.length())
            qDebug() << "The following extensions have been enabled:" << m_extensions.join(", ");
        else
            qDebug() << "No extensions found.";

#else
        qDebug() << "Extension support has been disabled at compile time.";
#endif

        loadSettingsInBGToLookForShortcuts();

    });

}

PQCExtensionsHandler::~PQCExtensionsHandler() {}

bool PQCExtensionsHandler::loadExtension(PQCExtensionInfo *extinfo, QString id, QString baseDir, QString definition) {

#ifdef PQMEXTENSIONS

    YAML::Node config;

    // LOAD yaml file
    try {
        config = YAML::Load(definition.toStdString());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to load YAML file:" << e.what();
        return false;
    }

    /***********************************/
    // PROPERTIES: about (all except longName are REQUIRED)

    // version
    try {
        extinfo->version = config["about"]["version"].as<int>();
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'version':" << e.what();
        return false;
    }

    // name
    try {
        extinfo->name = QString::fromStdString(config["about"]["name"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'name':" << e.what();
        return false;
    }

    // long name
    try {
        extinfo->longName = QString::fromStdString(config["about"]["longName"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Optional value for 'longName' not found, adopting value of 'name':" << e.what();
    }
    if(extinfo->longName == "") extinfo->longName = extinfo->name;

    // description
    try {
        extinfo->description = QString::fromStdString(config["about"]["description"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'description':" << e.what();
        return false;
    }

    // author
    try {
        extinfo->author = QString::fromStdString(config["about"]["author"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'author':" << e.what();
        return false;
    }

    // contact
    try {
        extinfo->contact = QString::fromStdString(config["about"]["contact"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'contact':" << e.what();
        return false;
    }

    // website
    try {
        extinfo->website = QString::fromStdString(config["about"]["website"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'website':" << e.what();
        return false;
    }

    // target API
    try {
        extinfo->targetAPI = config["about"]["targetAPI"].as<int>();

        if(extinfo->targetAPI > CURRENTAPIVERSION) {
            qWarning() << "Required API version -" << extinfo->targetAPI << "- newer than what's supported:" << CURRENTAPIVERSION;
            qWarning() << "Extension" << id << "located at" << baseDir << "not enabled.";
            return false;
        }

    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << id << "- Failed to read required value for 'targetAPI':" << e.what();
        return false;
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

    // context menu section
    try {
        extinfo->contextMenuSection = QString::fromStdString(config["setup"]["contextmenu"].as<std::string>());
        if(extinfo->contextMenuSection == "use") {
            m_contextMenuUse.append(id);
            Q_EMIT contextMenuUseChanged();
        } else if(extinfo->contextMenuSection == "manipulate") {
            m_contextMenuManipulate.append(id);
            Q_EMIT contextMenuManipulateChanged();
        } else if(extinfo->contextMenuSection == "about") {
            m_contextMenuAbout.append(id);
            Q_EMIT contextMenuAboutChanged();
        } else if(extinfo->contextMenuSection == "other") {
            m_contextMenuOther.append(id);
            Q_EMIT contextMenuOtherChanged();
        }
    } catch(YAML::Exception &e) {
        qDebug() << "Extension:" << id << "- Optional value for 'contextmenu' invalid or not found, skipping:" << e.what();
    }

    // add entry to main menu
    try {
        extinfo->mainmenu = config["setup"]["mainmenu"].as<bool>();
        if(extinfo->mainmenu) {
            m_mainmenu.append(id);
            Q_EMIT mainmenuChanged();
        }
    } catch(YAML::Exception &e) {
        qDebug() << "Extension:" << id << "- Optional value for 'mainmenu' invalid or not found, skipping:" << e.what();
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
                    return false;
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

    return true;

#endif

    return false;

}

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

QString PQCExtensionsHandler::getExtensionLongName(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->longName;
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

bool PQCExtensionsHandler::getExtensionMainMenu(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->mainmenu;
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

QString PQCExtensionsHandler::getExtensionContextMenuSection(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->contextMenuSection;
    qWarning() << "Unknown extension id:" << id;
    return "";
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
        return QFile::exists(QString("%1/qml/%2Settings.qml").arg(m_allextensions[id]->location, id));
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

        ExtensionSettings set(id);
        set.saveShortcut(sh);

    }
}

void PQCExtensionsHandler::removeShortcut(QString id) {
    if(m_extensionToActiveShortcut.contains(id)) {
        m_activeShortcutToExtension.remove(m_extensionToActiveShortcut.value(id));
        m_extensionToActiveShortcut.remove(id);
    }
}

QVariant PQCExtensionsHandler::callAction(const QString &id, QVariant additional) {

    qDebug() << "args: id =" << id;

    if(m_actions.contains(id))
        return m_actions[id]->action(PQCFileFolderModelCPP::get().getCurrentFile(), additional);

    qWarning() << "No action provided for extension" << id;
    return QVariant();

}

QVariant PQCExtensionsHandler::callActionWithImage(const QString &id, QVariant additional) {

    qDebug() << "args: id =" << id;

    if(m_actions.contains(id)) {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModelCPP::get().getCurrentFile(), QSize(-1,-1), sze, img);
        return m_actions[id]->actionWithImage(PQCFileFolderModelCPP::get().getCurrentFile(), img, additional);
    }

    qWarning() << "No action with image provided for extension" << id;
    return QVariant();

}

void PQCExtensionsHandler::callActionNonBlocking(const QString &id, QVariant additional) {

    qDebug() << "args: id =" << id;

    QFuture<void> future = QtConcurrent::run([=] {
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->action(PQCFileFolderModelCPP::get().getCurrentFile(), additional);
            Q_EMIT replyForAction(id, ret);
        } else {
            qWarning() << "No action provided for extension" << id;
            Q_EMIT replyForAction(id, QVariant(""));
        }
    });

}

void PQCExtensionsHandler::callActionWithImageNonBlocking(const QString &id, QVariant additional) {

    qDebug() << "args: id =" << id;

    QFuture<void> future = QtConcurrent::run([=] {
        QImage img;
        QSize sze;
        PQCLoadImage::get().load(PQCFileFolderModelCPP::get().getCurrentFile(), QSize(-1,-1), sze, img);
        if(m_actions.contains(id)) {
            QVariant ret = m_actions[id]->actionWithImage(PQCFileFolderModelCPP::get().getCurrentFile(), img, additional);
            Q_EMIT replyForActionWithImage(id, ret);
        } else {
            qWarning() << "No action with image provided for extension" << id;
            Q_EMIT replyForActionWithImage(id, QVariant(""));
        }
    });

}

void PQCExtensionsHandler::loadSettingsInBGToLookForShortcuts() {

    for(const QString &ext : std::as_const(m_extensions)) {

        // we don't need to do more than this, setting up this with the extensionId
        // like this loads the settings and enters the shortcuts
        ExtensionSettings set(ext);

    }

}

void PQCExtensionsHandler::setEnabledExtensions(const QStringList &ids) {
    m_extensions = ids;
    m_numExtensionsEnabled = m_extensions.length();
    for(const QString &id : ids) {
        const QString qmfile = QString("%1/lang/%2_%3.qm").arg(m_allextensions.value(id)->location,id,PQCScriptsLocalization::get().getActiveTranslationCode());
        if(!QFile::exists(qmfile))
            qDebug() << id << "- no translation file found:" << qmfile;
        else {
            if(extTrans.value(id)->load(qmfile))
                qApp->installTranslator(extTrans.value(id));
            else
                qWarning() << id << "- unable to install translator:" << PQCScriptsLocalization::get().getActiveTranslationCode();
        }
    }
    resetNumExtensionsAll->start();
}

void PQCExtensionsHandler::setDisabledExtensions(const QStringList &ids) {
    m_extensionsDisabled = ids;
    for(const QString &id : ids)
        qApp->removeTranslator(extTrans.value(id));
    resetNumExtensionsAll->start();
}

void PQCExtensionsHandler::enableExtension(const QString &id) {
    qDebug() << "args: id =" << id;
    if(!m_extensions.contains(id)) {
        m_extensions.append(id);
        if(m_extensionsDisabled.contains(id))
            m_extensionsDisabled.removeAt(m_extensionsDisabled.indexOf(id));
    }
    resetNumExtensionsAll->start();
}

void PQCExtensionsHandler::disableExtension(const QString &id) {
    qDebug() << "args: id =" << id;
    if(!m_extensionsDisabled.contains(id)) {
        m_extensionsDisabled.append(id);
        if(m_extensions.contains(id))
            m_extensions.removeAt(m_extensions.indexOf(id));
    }
    resetNumExtensionsAll->start();
}

// return code:
// 2: success, but id already exists (-> not loaded)
// 1: success
// 0: failure
// -1: cancelled by user
// -2: unsupported
// -3: installed but not all files could be extracted successfully
int PQCExtensionsHandler::installExtension(QString filepath) {

    qDebug() << "args: filepath =" << filepath;

#if !defined(PQMEXTENSIONS) || !defined(PQMLIBARCHIVE)
    return -2;
#endif

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

#ifdef PQMLIBARCHIVE

    // Create new archive handler
    struct archive *a = archive_read_new();

    // Read file
    archive_read_support_format_all(a);
    archive_read_support_filter_all(a);

// Read file - if something went wrong, output error message and stop here
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(filepath.utf16()), 10240);
#else
    int r = archive_read_open_filename(a, filepath.toLocal8Bit().data(), 10240);
#endif
    if(r != ARCHIVE_OK) {
        QString msg = QString("ERROR: archive_read_open_filename() returned code of %1").arg(r);
        qWarning() << msg;
        return 0;
    }

    QByteArray definitionyml = "";

    int numFilesSuccess = 0;
    int numFilesFailure = 0;

    QString extensionId = "";

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        QString fullpath = PQCConfigFiles::get().DATA_DIR() + "/extensions/" + filenameinside;

        if(fullpath.endsWith("/")) {
            if(extensionId == "")
                extensionId = filenameinside.replace("/", "").trimmed();
            QDir dir;
            if(!dir.mkpath(fullpath))
                qWarning() << "Unable to make path:" << fullpath;
        } else {

            // store read data in here
            const void *buff;
            size_t size;
            la_int64_t offset;

            // The output file...
            QFile file(fullpath);

            // Overwrite old content
            if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                qWarning() << QString("ERROR: Unable to write file '%1'... Skipping file!").arg(filenameinside);
                numFilesFailure += 1;
                continue;
            }
            QDataStream out(&file);   // we will serialize the data into the file

            // read data
            while((r = archive_read_data_block(a, &buff, &size, &offset)) == ARCHIVE_OK) {
                if(r != ARCHIVE_OK || size == 0) {
                    numFilesFailure += 1;
                    qWarning() << QString("ERROR: Unable to extract file '%1':").arg(filenameinside) << archive_error_string(a) << " " << QString("(%1)").arg(r) << " - Skipping file!";
                    break;
                }
                out.writeRawData((const char*) buff, size);
            }

            numFilesSuccess += 1;

            file.close();

        }

    }

    if(numFilesSuccess > 0) {

        if(m_allextensions.contains(extensionId))
            return 2;

        PQCExtensionInfo *extinfo = new PQCExtensionInfo;
        extinfo->location = QString("%1/extensions/%2").arg(PQCConfigFiles::get().DATA_DIR(), extensionId);

        QFile fy(QString("%1/manifest.yml").arg(extinfo->location));
        if(!fy.open(QIODevice::ReadOnly)) {
            qWarning() << "Unable to read manifest.yml for reading";
            return -1;
        }
        QTextStream in(&fy);
        QString definition = in.readAll();

        if(!loadExtension(extinfo, extensionId, QString("%1/extensions/").arg(PQCConfigFiles::get().DATA_DIR()), definition)) {
            delete extinfo;
            return -1;
        }

        // create translator for this extension
        QTranslator *trans = new QTranslator;
        extTrans.insert(extensionId, trans);

        // all good so far, we have what we need
        qDebug() << "Successfully loaded extension" << extensionId << "from location:" << PQCConfigFiles::get().DATA_DIR();

        m_extensionsDisabled.append(extensionId);
        m_allextensions.insert(extensionId, extinfo);

    }

    return (numFilesSuccess==0 ? 0 : (numFilesFailure > 0 ? -3 : 1));

#endif

    return -2;
}

QHash<QString,QVariant> PQCExtensionsHandler::getExtensionZipMetadata(QString filepath) {

    qDebug() << "args: filepath =" << filepath;

    QHash<QString,QVariant> ret;

#ifdef PQMEXTENSIONS
#ifdef PQMLIBARCHIVE

    // Create new archive handler
    struct archive *a = archive_read_new();

    // Read file
    archive_read_support_format_all(a);
    archive_read_support_filter_all(a);

// Read file - if something went wrong, output error message and stop here
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(filepath.utf16()), 10240);
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

        if(filenameinside.endsWith("manifest.yml") && filenameinside.count("/") == 1) {

            // store read data in here
            const void *buff;
            size_t size;
            la_int64_t offset;

            // read data
            while((r = archive_read_data_block(a, &buff, &size, &offset)) == ARCHIVE_OK) {
                if(r != ARCHIVE_OK || size == 0) {
                    QString msg = QString("ERROR: Unable to read file 'manifest.yml': %1 (%2)").arg(archive_error_string(a)).arg(r);
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
#endif

    ret.insert("error", "Extension support is not available.");
    return ret;

}

bool PQCExtensionsHandler::verifyExtension(QString baseDir, QString id) {

    qDebug() << "args: baseDir =" << baseDir;
    qDebug() << "args: id =" << id;

#ifdef PQMEXTENSIONS

    /*************************************/
    // first verify signature of manifest

    if(!QCA::isSupported("pkey") || !QCA::PKey::supportedIOTypes().contains(QCA::PKey::RSA)) {
        qWarning() << "RSA used for extension signing not supported on this machine!";
        return false;
    }

    QFile pemfile(":/extensions/public_rsa.pem");
    if(!pemfile.open(QIODevice::ReadOnly)) {
        qWarning() << "Unable to open public key for checking extension signature";
        return false;
    }

    QCA::ConvertResult res;
    QCA::PublicKey pubkey = QCA::PublicKey::fromPEM(pemfile.readAll(), &res);

    if(res != QCA::ConvertGood) {
        qWarning() << "Importing public key for signature verification failed.";
        return false;
    }

    if(!pubkey.canVerify()) {
        qWarning() << "Public key cannot verify signatures";
        return false;
    }

    QFile fmanifest(QString("%1/%2/verification.txt").arg(baseDir, id));
    if(!fmanifest.open(QIODevice::ReadOnly)) {
        qWarning() << id << "- unable to read verification.txt:" << QString("%1/%2/verification.txt").arg(baseDir, id);
        return false;
    }
    QByteArray manifest = fmanifest.readAll();

    QFile fmanifestsig(QString("%1/%2/verification.txt.sig").arg(baseDir, id));
    if(!fmanifestsig.open(QIODevice::ReadOnly)) {
        qWarning() << id << "- unable to read verification.txt.sig";
        return false;
    }
    QByteArray manifestsig = fmanifestsig.readAll();

    if(!pubkey.verifyMessage(manifest, manifestsig, QCA::EMSA3_SHA256)) {
        qWarning() << id << "- Signature of manifest is wrong";
        return false;
    }

    /**************************************/
    // next read manifest and compile map of all files and their hashes

    QHash<QString,QString> hashMap;
    for(const QString &l : manifest.split('\n')) {

        if(l.trimmed() == "")
            continue;

        const QStringList parts = l.split(":");
        if(parts.length() != 2) {
            qWarning() << id << "- Invalid line in manifest found:" << l;
            return false;
        }

        hashMap.insert(parts.value(0), parts.at(1));

    }

    /*************************************/
    // finally look through all the files and make sure they all have a match

    int counter = 0;

    QStringList ignoreFiles = {QString("lib%2.so").arg(id), "verification.txt", "verification.txt.sig"};
    QStringList considerFileEndings = {"qml", "txt", "yml"};

    const QStringList lst = listFilesIn(QString("%1/%2").arg(baseDir,id));
    for(QString _f : lst) {

        const QString f = _f.remove(0, baseDir.length()+id.length()+2);

        if(ignoreFiles.contains(f))
            continue;

        if(!considerFileEndings.contains(QFileInfo(f).suffix().toLower()))
            continue;

        counter += 1;

        if(!hashMap.contains(f)) {
            qWarning() << id << "- File not listed in manifest:" << f;
            return false;
        }

        QFile file(QString("%1/%2/%3").arg(baseDir,id,f));
        if(!file.open(QIODevice::ReadOnly)) {
            qWarning() << id << "- unable to read found file:" << f;
            return false;
        }
        const QString hash = QCryptographicHash::hash(file.readAll(),QCryptographicHash::Sha256).toHex();

        if(hash != hashMap.value(f)) {
            qWarning() << id << "- Invalid hash for file:" << f;
            return false;
        }

    }

    if(counter != hashMap.count()) {
        qWarning() << id << "- some expected files were not found";
        return false;
    }


    /******************************************/
    //
    // THE CHECK BELOW IS CURRENTLY NOT USED
    // it is left here in case that ever changes
    //
    // The reason is that we want to avoid running random code that was not intended
    // by the user to be run. The checks above (the signed manifest) already takes
    // care of that. Other than the signature, the check below is very easy to
    // circumvent and thus of only limited usefulness.
    //
    // To my knowledge there is no way to verify the integrity of a compiled library
    // that is compiled on the end user's system (reproducible builds could help here,
    // but we are not there yet afaik).
    //
    /******************************************/

    /******************************************/
    // lastly, we check the hash of the compiled library (if any)
    // the first time this check is done, the hash does not yet exist and is created
    // this is not as secure as we might want but should be sufficient with the other
    // verifications above
    // after all, we want it to be secure but if something messed up the extension to
    // this extent then the system has bigger issues

    /*const QString soname = QString("%1/%2/lib%3.so").arg(baseDir, id, id);

    if(QFile::exists(soname)) {

        QFile fC(soname);
        if(!fC.open(QIODevice::ReadOnly)) {
            qWarning() << id << "- .so file cannot be read";
            return false;
        }

        // find out version number of current extension
        QFile fVer(QString("%1/%2/manifest.yml").arg(baseDir, id));
        if(!fVer.open(QIODevice::ReadOnly)) {
            qWarning() << id << "- unable to open manifest.yml to find version number";
            return false;
        }
        int versionNumber = -1;
        YAML::Node config;
        try {
            config = YAML::Load(fVer.readAll().toStdString());
            versionNumber = config["about"]["version"].as<int>();
        } catch(YAML::Exception &e) {
            qWarning() << id << "- unable to find version number in yml file:" << e.what();
            return false;
        }

        // get hash parts
        const QString idHash  = QCryptographicHash::hash(id.toUtf8(),QCryptographicHash::Sha256).toHex();
        const QString cppHash = QCryptographicHash::hash(fC.readAll(),QCryptographicHash::Sha256).toHex();

        // access hash fle
        QFile fCHash(PQCConfigFiles::get().DATA_DIR() + "/extensions/cpphashes");
        if(!fCHash.open(QIODevice::ReadOnly)) {
            qWarning() << id << "- unable to open cpp hash file -" << QString("%1/extensions/cpphashes").arg(PQCConfigFiles::get().DATA_DIR()) << "- for reading and writing";
            return false;
        }

        QTextStream in(&fCHash);
        QString existingHashes = in.readAll();

        if(existingHashes.contains(QString("%1:%2:").arg(idHash).arg(versionNumber))) {

            if(!existingHashes.contains(QString("%1:%2:%3").arg(idHash).arg(versionNumber).arg(cppHash))) {
                qWarning() << id << "- the hash of the compiled library does not match.";
                return false;
            }

        } else {

            existingHashes = QString("%1%2:%3:%4\n").arg(existingHashes, idHash).arg(versionNumber).arg(cppHash);
            fCHash.close();
            if(!fCHash.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
                qWarning() << id << "- unable to store lib hash";
                return false;
            }
            QTextStream out(&fCHash);
            out << existingHashes;
            out.flush();
        }

    }*/

    /******************************************/

    qDebug() << id << "- signature verified.";
    return true;

#endif

    qDebug() << id << "- extensions are not supported";
    return false;

}

QStringList PQCExtensionsHandler::listFilesIn(QString dir) {

    QStringList ret;

    QDir d(dir);
    const QStringList lstD = d.entryList(QDir::Dirs|QDir::NoDotAndDotDot);

    for(const QString &e : lstD)
        ret << listFilesIn(QString("%1/%2").arg(dir, e));

    const QStringList lstF = d.entryList(QDir::Files);
    for(const QString &e : lstF)
        ret << QString("%1/%2").arg(dir, e);

    return ret;
}

void PQCExtensionsHandler::updateTranslationLanguage() {

    for(const QString &id : std::as_const(m_extensions))
        qApp->removeTranslator(extTrans.value(id));

    for(const QString &id : std::as_const(m_extensions)) {
        const QString qmfile = QString("%1/lang/%2_%3.qm").arg(m_allextensions.value(id)->location,id,PQCScriptsLocalization::get().getActiveTranslationCode());
        if(!QFile::exists(qmfile))
            qDebug() << id << "- no translation file found:" << qmfile;
        else {
            if(extTrans.value(id)->load(qmfile))
                qApp->installTranslator(extTrans.value(id));
            else
                qWarning() << id << "- unable to install translator:" << PQCScriptsLocalization::get().getActiveTranslationCode();
        }
    }

}
