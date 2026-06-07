/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#include <pqc_imagehandler.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_extensionsettings.h>
#include <scripts/pqc_scriptslocalization.h>
#include <pqc_metadata_cpp.h>
#include <pqc_extensioninfo.h>
#include <QCryptographicHash>

#ifdef PQMEXTENSIONS
#include <yaml-cpp/yaml.h>
#endif

#ifdef PQMEXTENSIONS_NONSYS_OPENSSL
#include <openssl/evp.h>
#include <openssl/pem.h>
#endif

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

/****************************************************************/
/****************************************************************/
// This is the current/latest version supported by this build!
#define CURRENTAPIVERSION 3
/****************************************************************/
/****************************************************************/

PQCExtensionsHandler::PQCExtensionsHandler() {
    m_isSetup = false;
    m_numExtensionsEnabled = 0;
    m_numExtensionsAll = 0;
    m_numExtensionsFailed = 0;
    resetNumExtensionsAll = new QTimer;
    resetNumExtensionsAll->setInterval(250);
    resetNumExtensionsAll->setSingleShot(false);
#if __cplusplus >= 202002L
    connect(resetNumExtensionsAll, &QTimer::timeout, this, [=, this]() {
#else
    connect(resetNumExtensionsAll, &QTimer::timeout, this, [=]() {
#endif
        m_numExtensionsEnabled = m_extensions.length();
        m_numExtensionsAll = m_extensions.length()+m_extensionsDisabled.length();
        m_numExtensionsFailed = m_extensionsFailed.length();
        Q_EMIT numExtensionsEnabledChanged();
        Q_EMIT numExtensionsAllChanged();
        Q_EMIT numExtensionsFailedChanged();

        for(const QString &hashId : std::as_const(m_extensions)) {
            const std::shared_ptr<PQCExtensionInfo> info = m_allextensions.value(hashId);
            setExtensionMainMenu(hashId, info->mainmenu);
            setExtensionContextMenu(hashId, info->contextMenuSection, true);
        }
        for(const QString &hashId : std::as_const(m_extensionsDisabled)) {
            const std::shared_ptr<PQCExtensionInfo> info = m_allextensions.value(hashId);
            setExtensionMainMenu(hashId, false);
            setExtensionContextMenu(hashId, info->contextMenuSection, false);
        }
        Q_EMIT mainmenuChanged();
        Q_EMIT contextMenuUseChanged();
        Q_EMIT contextMenuManipulateChanged();
        Q_EMIT contextMenuAboutChanged();
        Q_EMIT contextMenuOtherChanged();

    });

    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceLanguageChanged, this, &PQCExtensionsHandler::updateTranslationLanguage);

}

void PQCExtensionsHandler::setup() {

    if(m_isSetup) return;
    m_isSetup = true;

#if __cplusplus >= 202002L
    QFuture<void> future = QtConcurrent::run([=, this] {
#else
    QFuture<void> future = QtConcurrent::run([=] {
#endif

#ifdef PQMEXTENSIONS

    m_systemExtensionDir = "";

#ifdef Q_OS_UNIX
    #ifdef NDEBUG
      #ifdef PQMAPPIMAGEBUILD
        m_systemExtensionDir = QCoreApplication::applicationDirPath() % "/../" % QString(PQMSHAREDLIBDIR) % "/PhotoQt/extensions";
        const QStringList checkDirs = {PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       m_systemExtensionDir};
      #else
        m_systemExtensionDir = QString(PQMINSTALLPREFIX) % "/" % QString(PQMSHAREDLIBDIR) % "/PhotoQt/extensions";
        const QStringList checkDirs = {PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       m_systemExtensionDir};
      #endif
    #else
        m_systemExtensionDir = QString(PQMBUILDDIR) %  ("/extensions");
        const QStringList checkDirs = {m_systemExtensionDir,
                                       PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       QCoreApplication::applicationDirPath() % "/" % QString(PQMSHAREDLIBDIR) % "/PhotoQt/extensions"};
    #endif
#else
        m_systemExtensionDir = QCoreApplication::applicationDirPath() % "/extensions";
        const QStringList checkDirs = {PQCConfigFiles::get().EXTENSION_DATA_DIR(),
                                       m_systemExtensionDir};
#endif

        // This needs to be instantiated to make sure that the CPP class has been populated.
        // Even though this object is not to be used anywhere.

        qDebug() << "Checking the following directories for plugins:" << checkDirs.join(", ");

        for(const QString &baseDir : checkDirs) {

            QDir pluginsDir(baseDir);

            const QStringList dirlist = pluginsDir.entryList(QDir::Dirs|QDir::NoDotAndDotDot);
            for(const QString &nameId : dirlist) {

                const QString extensionDir = QDir(baseDir).absoluteFilePath(nameId);
                const bool isSystemExtension = (m_systemExtensionDir == baseDir);
                const QString hashId = (isSystemExtension ?
                                            QCryptographicHash::hash(nameId.toUtf8(), QCryptographicHash::Md5).toHex() :
                                            QCryptographicHash::hash(extensionDir.toUtf8(), QCryptographicHash::Md5).toHex());
                const QString identifyName = nameId % " (" % extensionDir % ")";

                // if there is a YAML file, then we load that one
                const QString yamlfile = extensionDir % "/manifest.yml";
                if(!QFile::exists(yamlfile)) {

                    qWarning() << "Required YAML file not found for extension" << identifyName;
                    qWarning() << "File expected at" << yamlfile;
                    continue;

                }

                bool verificationPassed = (isSystemExtension ? true : verifyExtension(extensionDir, nameId));
                bool allowUntrusted = false;
                if(!verificationPassed) {

                    qWarning() << "Extension" << identifyName << "did not pass verification check!";

#ifdef NDEBUG
                    if(!PQCSettingsCPP::get().getGeneralExtensionsAllowUntrusted().contains(hashId))
                        qWarning() << "Extension" << identifyName << "will not be loaded";
                    else
#endif
                        allowUntrusted = true;

                }

                bool extEnabled = verificationPassed||allowUntrusted;

                if(m_allextensions.contains(hashId)) {
                    qDebug() << "Extension" << identifyName << "exists already.";
                    qDebug() << "Extension will not be loaded";
                    continue;
                }

                if(!PQCSettingsCPP::get().getGeneralExtensionsEnabled().contains(hashId) && !(isSystemExtension && PQCSettingsCPP::get().getGeneralExtensionsEnabled().contains(nameId))) {
                    qDebug() << "Extension" << identifyName << "is disabled.";
                    extEnabled = false;
                }
                QFile fy(yamlfile);
                if(!fy.open(QIODevice::ReadOnly)) {
                    qWarning() << identifyName << "- unable to open manifest.yml for reading";
                    continue;
                }
                QTextStream in(&fy);
                QString definition = in.readAll();

                std::shared_ptr<PQCExtensionInfo> extinfo(new PQCExtensionInfo);

                extinfo->location = extensionDir;
                extinfo->internalId = hashId;
                extinfo->nameId = nameId;

                if(!loadExtension(extinfo, nameId, hashId, extensionDir, definition, extEnabled)) {
                    qWarning() << identifyName << "- failed to load";
                    continue;
                }

                // all good so far, we have what we need
                qDebug() << "Successfully loaded extension" << identifyName;

                // create translator for this extension
                std::shared_ptr<QTranslator> trans(new QTranslator);
                extTrans.insert(hashId, trans);

                if(extEnabled) {
                    m_extensions.append(hashId);
                    const QString qmfile = extinfo->location % "/lang/" % nameId % "_" % PQCScriptsLocalization::get().getActiveTranslationCode() % ".qm";
                    if(trans->load(qmfile)) {
                        qDebug() << identifyName << "- installing translation file:" << qmfile;
                        qApp->installTranslator(trans.get());
                    } else
                        qDebug() << identifyName << "- unable to install translator:" << PQCScriptsLocalization::get().getActiveTranslationCode();
                } else {
                    if(allowUntrusted || verificationPassed)
                        m_extensionsDisabled.append(hashId);
                    else
                        m_extensionsFailed.append(hashId);
                }
                m_allextensions.insert(hashId, extinfo);

                if(isSystemExtension) m_extensionsSystem.append(hashId);

            }

        }

        m_numExtensionsEnabled = m_extensions.length();
        m_numExtensionsAll = m_extensions.length()+m_extensionsDisabled.length();
        m_numExtensionsFailed = m_extensionsFailed.length();
        Q_EMIT numExtensionsEnabledChanged();
        Q_EMIT numExtensionsAllChanged();
        Q_EMIT numExtensionsFailedChanged();

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

bool PQCExtensionsHandler::loadExtension(std::shared_ptr<PQCExtensionInfo> &extinfo, QString nameId, QString hashId, QString extensionDir, QString manifestTxt, bool isEnabled) {

#ifdef PQMEXTENSIONS

    bool oldExtension_v1 = false;

    YAML::Node config;

    const QString identifyName = nameId % " (" % extensionDir % ")";

    // LOAD yaml file
    try {
        config = YAML::Load(manifestTxt.toStdString());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to load YAML file:" << e.what();
        return false;
    }

    /***********************************/
    // PROPERTIES: about (all except longName are REQUIRED, localizations are OPTIONAL)

    // version
    try {
        extinfo->version = config["about"]["version"].as<int>();
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'version':" << e.what();
        return false;
    }

    // name
    try {
        extinfo->name = QString::fromStdString(config["about"]["name"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'name':" << e.what();
        return false;
    }

    // long name
    bool haveProperLongName = true;
    try {
        extinfo->longName = QString::fromStdString(config["about"]["longName"].as<std::string>());
    } catch(YAML::Exception &e) {
        haveProperLongName = false;
    }
    if(extinfo->longName.isEmpty()) {
        haveProperLongName = false;
        extinfo->longName = extinfo->name;
    }

    // description
    try {
        extinfo->description = QString::fromStdString(config["about"]["description"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'description':" << e.what();
        return false;
    }

    // author
    try {
        extinfo->author = QString::fromStdString(config["about"]["author"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'author':" << e.what();
        return false;
    }

    // contact
    try {
        extinfo->contact = QString::fromStdString(config["about"]["contact"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'contact':" << e.what();
        return false;
    }

    // website
    try {
        extinfo->website = QString::fromStdString(config["about"]["website"].as<std::string>());
    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'website':" << e.what();
        return false;
    }

    // target API
    try {
        extinfo->targetAPI = config["about"]["targetAPI"].as<int>();

        if(extinfo->targetAPI > CURRENTAPIVERSION) {
            qWarning() << "Required API version -" << extinfo->targetAPI << "- newer than what's supported:" << CURRENTAPIVERSION;
            qWarning() << "Extension" << identifyName << "not enabled.";
            return false;
        }

        if(extinfo->targetAPI < CURRENTAPIVERSION) {
            qDebug() << identifyName << "- outdated target API, consider updating extension!";
            if(extinfo->targetAPI == 1)
                oldExtension_v1 = true;
        }

    } catch(YAML::Exception &e) {
        qWarning() << "Extension:" << identifyName << "- Failed to read required value for 'targetAPI':" << e.what();
        return false;
    }

    // OPTIONAL localizations
    const QStringList langLst = PQCScriptsLocalization::get().getAvailableTranslations();
    // check localizations for name
    for(const QString &lang : langLst) {
        try {
            const std::string langStr = QString("name[" % lang % "]").toStdString();
            if(config["about"][langStr].IsDefined()) {
                const QString val = QString::fromStdString(config["about"][langStr].as<std::string>());
                extinfo->nameLocalized[lang] = val;
            } else {
                const int langIdx = lang.indexOf("_");
                if(langIdx > -1) {
                    const std::string lang_Str = QString("name[" % lang.mid(0,langIdx) % "]").toStdString();
                    if(config["about"][lang_Str].IsDefined()) {
                        const QString val = QString::fromStdString(config["about"][lang_Str].as<std::string>());
                        extinfo->nameLocalized[lang] = val;
                    }
                }
            }
        } catch(YAML::Exception &e) {}
    }
    // check localizations for longName
    for(const QString &lang : langLst) {
        if(haveProperLongName) {
            try {
                const std::string langStr = QString("longName[" % lang % "]").toStdString();
                if(config["about"][langStr].IsDefined()) {
                    const QString val = QString::fromStdString(config["about"][langStr].as<std::string>());
                    extinfo->longNameLocalized[lang] = val;
                } else {
                    const int langIdx = lang.indexOf("_");
                    if(langIdx > -1) {
                        const std::string lang_Str = QString("longName[" % lang.mid(0,langIdx) % "]").toStdString();
                        if(config["about"][lang_Str].IsDefined()){
                            const QString val = QString::fromStdString(config["about"][lang_Str].as<std::string>());
                            extinfo->longNameLocalized[lang] = val;
                        }
                    }
                }
            } catch(YAML::Exception &e) {}
        } else
            extinfo->longNameLocalized = extinfo->nameLocalized;
    }
    // check localizations for description
    for(const QString &lang : langLst) {
        try {
            const std::string langStr = QString("description[" % lang % "]").toStdString();
            if(config["about"][langStr].IsDefined()) {
                const QString val = QString::fromStdString(config["about"][langStr].as<std::string>());
                extinfo->descriptionLocalized[lang] = val;
            } else {
                const int langIdx = lang.indexOf("_");
                if(langIdx > -1) {
                    const std::string lang_Str = QString("description[" % lang.mid(0,langIdx) % "]").toStdString();
                    if(config["about"][lang_Str].IsDefined()){
                        const QString val = QString::fromStdString(config["about"][lang_Str].as<std::string>());
                        extinfo->descriptionLocalized[lang] = val;
                    }
                }
            }
        } catch(YAML::Exception &e) {}
    }

    /***********************************/
    // OPTIONAL values

    //////////////////////
    // setup/integrated

    // allow integrated
    try {
        extinfo->integratedAllow = config["setup"]["integrated"]["allow"].as<bool>();
    } catch(YAML::Exception &e) {}

    // minimum required window size
    try {
        std::list<int> vals = config["setup"]["integrated"]["minimumRequiredWindowSize"].as<std::list<int> >();
        if(vals.size() != 2)
            qWarning() << "Extension:" << identifyName << "- Expected two values (width, height) for property 'minimumRequiredWindowSize', but found" << vals.size();
        else
            extinfo->integratedMinimumRequiredWindowSize = QSize(vals.front(), vals.back());
    } catch(YAML::Exception &e) {}

    // default position
    try {
        extinfo->integratedDefaultPosition = extinfo->getIntegerForPosition(config["setup"]["integrated"]["defaultPosition"].as<std::string>());
    } catch(YAML::Exception &e) {}

    // default distance from window edge
    try {
        extinfo->integratedDefaultDistanceFromEdge = config["setup"]["integrated"]["defaultDistanceFromEdge"].as<int>();
    } catch(YAML::Exception &e) {}

    // default integrated size
    try {
        std::list<int> vals = config["setup"]["integrated"]["defaultSize"].as<std::list<int> >();
        if(vals.size() != 2)
            qWarning() << "Extension:" << identifyName << "- Expected two values (width, height) for property 'integrated/defaultSize', but found" << vals.size();
        else
            extinfo->integratedDefaultSize = QSize(vals.front(), vals.back());
    } catch(YAML::Exception &e) {}

    // fix size to content
    try {
        extinfo->integratedFixSizeToContent = config["setup"]["integrated"]["fixSizeToContent"].as<bool>();
    } catch(YAML::Exception &e) {}


    //////////////////////
    // setup/popout

    // allow popout
    try {
        extinfo->popoutAllow = config["setup"]["popout"]["allow"].as<bool>();
        if(!extinfo->popoutAllow && !extinfo->integratedAllow) {
            qWarning() << "Extension:" << identifyName << "- At least one of integrated or popout needs to be enabled. Force-enabling integrated.";
            extinfo->integratedAllow = true;
        }
    } catch(YAML::Exception &e) {}

    // default popout size
    try {
        std::list<int> vals = config["setup"]["popout"]["defaultSize"].as<std::list<int> >();
        if(vals.size() != 2)
            qWarning() << "Extension:" << identifyName << "- Expected two values (width, height) for property 'popout/defaultSize', but found" << vals.size();
        else
            extinfo->popoutDefaultSize = QSize(vals.front(), vals.back());
    } catch(YAML::Exception &e) {}

    // fix size to content
    try {
        extinfo->popoutFixSizeToContent = config["setup"]["popout"]["fixSizeToContent"].as<bool>();
    } catch(YAML::Exception &e) {}


    //////////////////////
    // setup

    // this is a floating element
    try {
        extinfo->floating = config["setup"]["floating"].as<bool>();
    } catch(YAML::Exception &e) {}

    // make element modal
    try {
        extinfo->modal = config["setup"]["modal"].as<bool>();
    } catch(YAML::Exception &e) {}

    // default shortcut to toggle element
    try {
        extinfo->defaultShortcut = QString::fromStdString(config["setup"]["defaultShortcut"].as<std::string>());
    } catch(YAML::Exception &e) {}

    // remember geometry
    try {
        extinfo->rememberGeometry = config["setup"]["rememberGeometry"].as<bool>();
    } catch(YAML::Exception &e) {}

    // context menu section
    try {
        extinfo->contextMenuSection = QString::fromStdString(config["setup"]["contextmenu"].as<std::string>());
        setExtensionContextMenu(hashId, extinfo->contextMenuSection, isEnabled);
        Q_EMIT contextMenuOtherChanged();
    } catch(YAML::Exception &e) {}

    // add entry to main menu
    try {
        extinfo->mainmenu = config["setup"]["mainmenu"].as<bool>();
        setExtensionMainMenu(hashId, (isEnabled && extinfo->mainmenu));
        Q_EMIT mainmenuChanged();
    } catch(YAML::Exception &e) {}

    // add entry to main menu
    try {
        extinfo->customMouseHandling = config["setup"]["customMouseHandling"].as<bool>();
    } catch(YAML::Exception &e) {}

    // settings
    try {

        for(const auto &sets : config["setup"]["settings"]) {

            QStringList vals;
            for(auto const& l : sets)
                vals.append(QString::fromStdString(l.as<std::string>()));

            if(vals.length() == 3)
                extinfo->settings.append(vals);

        }

    } catch(YAML::Exception &e) {}

    // whether CPP actions have been supplied
    try {
        extinfo->haveCPPActions = config["setup"]["haveCPPActions"].as<bool>();

        if(extinfo->haveCPPActions) {

            // make sure we can find and load the actions
            QDir extDir(extensionDir);
#ifdef Q_OS_UNIX
            extDir.setNameFilters({"*.so"});
#else
            extDir.setNameFilters({"*.dll"});
#endif
            QStringList filList = extDir.entryList();

            if(filList.length() == 0) {

                qWarning() << "No shared library found at" << extensionDir;
                qWarning() << "CPP actions of extension" << identifyName << "have not been enabled!";
                extinfo->haveCPPActions = false;

            } else {

                const QString libName = extensionDir % "/" % filList.at(0);

                // linker file does not exist
                if(!QFile::exists(libName)) {
                    qWarning() << "Expected file" << filList.at(0) << "not found.";
                    qWarning() << "Extension" << identifyName << "not enabled.";
                    return false;
                }

                QPluginLoader loader(libName);
                QObject *plugin = loader.instance();
                if(plugin) {

                    PQCExtensionActions *actions = qobject_cast<PQCExtensionActions*>(plugin);

                    if(actions) {
#if __cplusplus >= 202002L
                        connect(actions, &PQCExtensionActions::sendMessage, this, [=, this](QVariant val) { Q_EMIT receivedMessage(hashId, val); });
#else
                        connect(actions, &PQCExtensionActions::sendMessage, this, [=](QVariant val) { Q_EMIT receivedMessage(hashId, val); });
#endif
                        m_actions.insert(hashId, actions);
                    }
                }

            }

        }

    } catch(YAML::Exception &e) {}

    // adapt old APIs
    if(oldExtension_v1) {

        // floating is a new element, before not modal meant floating
        extinfo->floating = !extinfo->modal;

    }

    return true;

#endif

    return false;

}

void PQCExtensionsHandler::setExtensionMainMenu(QString hashId, bool add) {
    if(add && !m_mainmenu.contains(hashId)) {
        m_mainmenu.append(hashId);
    } else if(!add && m_mainmenu.contains(hashId)) {
        m_mainmenu.removeAt(m_mainmenu.indexOf(hashId));
    }
}

void PQCExtensionsHandler::setExtensionContextMenu(QString hashId, QString section, bool add) {
    if(add) {
        if(section == "use" && !m_contextMenuUse.contains(hashId)) {
            m_contextMenuUse.append(hashId);
        } else if(section == "manipulate" && !m_contextMenuManipulate.contains(hashId)) {
            m_contextMenuManipulate.append(hashId);
        } else if(section == "about" && !m_contextMenuAbout.contains(hashId)) {
            m_contextMenuAbout.append(hashId);
        } else if(section == "other" && !m_contextMenuOther.contains(hashId)) {
            m_contextMenuOther.append(hashId);
        }
    } else {
        if(section == "use" && m_contextMenuUse.contains(hashId)) {
            m_contextMenuUse.removeAt(m_contextMenuUse.indexOf(hashId));
        } else if(section == "manipulate" && m_contextMenuManipulate.contains(hashId)) {
            m_contextMenuManipulate.removeAt(m_contextMenuManipulate.indexOf(hashId));
        } else if(section == "about" && m_contextMenuAbout.contains(hashId)) {
            m_contextMenuAbout.removeAt(m_contextMenuAbout.indexOf(hashId));
        } else if(section == "other" && m_contextMenuOther.contains(hashId)) {
            m_contextMenuOther.removeAt(m_contextMenuOther.indexOf(hashId));
        }
    }
}

QStringList PQCExtensionsHandler::getExtensions() {
    return m_extensions;
}

QStringList PQCExtensionsHandler::getDisabledExtensions() {
    return m_extensionsDisabled;
}

QStringList PQCExtensionsHandler::getFailedExtensions() {
    return m_extensionsFailed;
}

QStringList PQCExtensionsHandler::getExtensionsEnabledAndDisabld() {
    return QStringList() << m_extensions << m_extensionsDisabled;
}

bool PQCExtensionsHandler::isSystemExtension(const QString id) {
    return m_extensionsSystem.contains(id);
}

/****************************************/

QString PQCExtensionsHandler::getExtensionLocation(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->location;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionConfigLocation(QString id) {
    const QString path = PQCConfigFiles::get().EXTENSION_CONFIG_DIR() % "/" % id;
    QDir dir(path);
    if(!dir.exists(path))
        dir.mkpath(path);
    return path;
}

QString PQCExtensionsHandler::getExtensionDataLocation(QString id) {
    const QString path = PQCConfigFiles::get().EXTENSION_DATA_DIR() % "/" % id;
    QDir dir(path);
    if(!dir.exists(path))
        dir.mkpath(path);
    return path;
}

QString PQCExtensionsHandler::getExtensionCacheLocation(QString id) {
    const QString path = PQCConfigFiles::get().EXTENSION_CACHE_DIR() % "/" % id;
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

QString PQCExtensionsHandler::getExtensionNameId(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->nameId;
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionName(QString id) {
    if(m_allextensions.contains(id)) {
        const QString l1 = PQCSettingsCPP::get().getInterfaceLanguage();
        if(l1 != "en") {
            if(m_allextensions[id]->nameLocalized.contains(l1))
                return m_allextensions[id]->nameLocalized[l1];
            else {
                const int idx = l1.indexOf("_");
                if(idx > -1) {
                    const QString l2 = l1.mid(0,idx);
                    if(m_allextensions[id]->nameLocalized.contains(l2))
                        return m_allextensions[id]->nameLocalized[l2];
                }
            }
        }
        return m_allextensions[id]->name;
    }
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
    if(m_allextensions.contains(id)) {
        const QString l1 = PQCSettingsCPP::get().getInterfaceLanguage();
        if(l1 != "en") {
            if(m_allextensions[id]->descriptionLocalized.contains(l1))
                return m_allextensions[id]->descriptionLocalized[l1];
            else {
                const int idx = l1.indexOf("_");
                if(idx > -1) {
                    const QString l2 = l1.mid(0, idx);
                    if(m_allextensions[id]->descriptionLocalized.contains(l2))
                        return m_allextensions[id]->descriptionLocalized[l2];
                }
            }
        }
        return m_allextensions[id]->description;
    }
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QString PQCExtensionsHandler::getExtensionLongName(QString id) {
    if(m_allextensions.contains(id)) {
        const QString l1 = PQCSettingsCPP::get().getInterfaceLanguage();
        if(l1 != "en") {
            if(m_allextensions[id]->longNameLocalized.contains(l1))
                return m_allextensions[id]->longNameLocalized[l1];
            else {
                const int idx = l1.indexOf("_");
                if(idx > -1) {
                    const QString l2 = l1.mid(0,idx);
                    if(m_allextensions[id]->longNameLocalized.contains(l2))
                        return m_allextensions[id]->longNameLocalized[l2];
                }
            }
        }
        return m_allextensions[id]->longName;
    }
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

bool PQCExtensionsHandler::getExtensionFloating(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->floating;
    qWarning() << "Unknown extension id:" << id;
    return false;
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

bool PQCExtensionsHandler::getExtensionCustomMouseHandling(QString id) {
    if(m_allextensions.contains(id))
        return m_allextensions[id]->customMouseHandling;
    qWarning() << "Unknown extension id:" << id;
    return false;
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
        return QFile::exists(m_allextensions[id]->location % "/qml/" % m_allextensions[id]->nameId % "Settings.qml");
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
        QSize sze;
        QString err = "";
        QImage img = PQCImageHandler::get().getImage(PQCFileFolderModelCPP::get().getCurrentFile(), QSize(-1,-1), sze, err);
        return m_actions[id]->actionWithImage(PQCFileFolderModelCPP::get().getCurrentFile(), img, additional);
    }

    qWarning() << "No action with image provided for extension" << id;
    return QVariant();

}

void PQCExtensionsHandler::callActionNonBlocking(const QString &id, QVariant additional) {

    qDebug() << "args: id =" << id;

#if __cplusplus >= 202002L
    QThreadPool::globalInstance()->start([=, this]() {
#else
    QThreadPool::globalInstance()->start([=]() {
#endif
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

#if __cplusplus >= 202002L
    QThreadPool::globalInstance()->start([=, this]() {
#else
    QThreadPool::globalInstance()->start([=]() {
#endif
        QSize sze;
        QString err = "";
        QImage img = PQCImageHandler::get().getImage(PQCFileFolderModelCPP::get().getCurrentFile(), QSize(-1,-1), sze, err);
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
        const QString qmfile = m_allextensions.value(id)->location % "/lang/" % id % "_" % PQCScriptsLocalization::get().getActiveTranslationCode() % ".qm";
        if(!QFile::exists(qmfile))
            qDebug() << id << "- no translation file found:" << qmfile;
        else {
            if(extTrans.value(id)->load(qmfile))
                qApp->installTranslator(extTrans.value(id).get());
            else
                qWarning() << id << "- unable to install translator:" << PQCScriptsLocalization::get().getActiveTranslationCode();
        }
    }
    resetNumExtensionsAll->start();
}

void PQCExtensionsHandler::setDisabledExtensions(const QStringList &ids) {
    m_extensionsDisabled = ids;
    for(const QString &id : ids)
        qApp->removeTranslator(extTrans.value(id).get());
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

        QMessageBox msg;
        msg.setIcon(QMessageBox::Critical);
        msg.setWindowFlag(Qt::WindowStaysOnTopHint);
        msg.setWindowTitle("Invalid extension");
        msg.setText("The extension does not appear to be valid and cannot be installed.\n\nError message:\n" % meta["error"].toString());
        msg.setStandardButtons(QMessageBox::Ok);
        msg.exec();

        return 0;

    }

    QMessageBox msg;
    msg.setIcon(QMessageBox::Question);
    msg.setWindowTitle("Install extension?");
    msg.setWindowFlag(Qt::WindowStaysOnTopHint);
    msg.setText("Do you want to install this extension?<br><br><b>Name:</b> " % meta["name"].toString() %
                " (version: " % QString::number(meta["version"].toInt()) %
                ")<br><b>Description:</b> " % meta["description"].toString() %
                "<br><b>Author:</b> " % meta["author"].toString() %
                "<br><b>Contact:</b> " % meta["contact"].toString() %
                "<br><b>Website:</b> " % meta["website"].toString() % "");
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
    QByteArray tmpPath = QFile::encodeName(filepath);
    int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif
    if(r != ARCHIVE_OK) {
        qWarning() << "ERROR: archive_read_open_filename() returned code of" << r;
        return 0;
    }

    int numFilesSuccess = 0;
    int numFilesFailure = 0;

    QString nameId = "";

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
        // and PhotoQt might crash if not handled properly -> check before converting to QString
        const wchar_t *wpath = archive_entry_pathname_w(entry);
        if(!wpath) continue;
        QString filenameinside = QString::fromWCharArray(wpath);

        QString fullpath = PQCConfigFiles::get().DATA_DIR() % "/extensions/" % filenameinside;

        if(fullpath.endsWith("/")) {
            if(nameId.isEmpty())
                nameId = filenameinside.replace("/", "").trimmed();
            QDir dir;
            if(!dir.mkpath(fullpath))
                qWarning() << "Unable to make path:" << fullpath;
        } else {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            if(size <= 0) {
                qWarning() << "Invalid image size of file in archive:" << size;
                numFilesFailure += 1;
                continue;
            }

            // Create a buffer of that size to hold the image data
            QByteArray data;
            data.resize(size);

            // And finally read the file into the buffer in chunks
            char* ptr = data.data();
            qint64 total = 0;
            while (total < size) {
                la_ssize_t chunk = archive_read_data(a, ptr + total, size - total);
                if(chunk < 0) {
                    qWarning() << "Invalid chunk read:" << archive_error_string(a);
                    break;
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                numFilesFailure += 1;
                continue;
            }

            // file handles
            QFile file(fullpath);
            QFileInfo info(file);
            if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                qWarning() << QString("ERROR: Unable to write file '%1'... Skipping file!").arg(filenameinside);
                numFilesFailure += 1;
                continue;
            }

            // remove it if it exists, there is no way to know if it's the same file or not
            if(file.exists()) file.remove();

            // make sure the path exists
            QDir dir(info.absolutePath());
            if(!dir.exists())
                dir.mkpath(info.absolutePath());

            // write buffer to file
            if(!file.open(QIODevice::WriteOnly)) {
                qWarning() << "Unable to extract file to temporary location.";
                continue;
            }
            QDataStream out(&file);   // we will serialize the data into the file
            out.writeRawData(data, data.size());
            file.close();

            numFilesSuccess += 1;

        }

    }

    if(numFilesSuccess > 0) {

        const QString extensionDir = QFileInfo(PQCConfigFiles::get().EXTENSION_DATA_DIR() % "/" % nameId % "/tmp.txt").absolutePath();
        const QString hashId = QCryptographicHash::hash(extensionDir.toUtf8(), QCryptographicHash::Md5).toHex();
        const QString identifyName = nameId % " (" % extensionDir % ")";

        if(m_allextensions.contains(hashId))
            return 2;

        std::shared_ptr<PQCExtensionInfo> extinfo(new PQCExtensionInfo);
        extinfo->location = extensionDir;
        extinfo->internalId = hashId;
        extinfo->nameId = nameId;

        QFile fy(extinfo->location % "/manifest.yml");
        if(!fy.open(QIODevice::ReadOnly)) {
            qWarning() << "Unable to read manifest.yml for reading";
            return -1;
        }
        QTextStream in(&fy);
        QString manifestTxt = in.readAll();

        if(!loadExtension(extinfo, nameId, hashId, extensionDir, manifestTxt, false)) {
            return -1;
        }

        // create translator for this extension
        std::shared_ptr<QTranslator> trans(new QTranslator);
        extTrans.insert(hashId, trans);

        // all good so far, we have what we need
        qDebug() << "Successfully loaded extension" << identifyName;

        m_extensionsDisabled.append(hashId);
        m_allextensions.insert(hashId, extinfo);

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
    QByteArray tmpPath = QFile::encodeName(filepath);
    int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif
    if(r != ARCHIVE_OK) {
        QString msg = "ERROR: archive_read_open_filename() returned code of " % QString::number(r);
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
        // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
        // and PhotoQt might crash if not handled properly -> check before converting to QString
        const wchar_t *wpath = archive_entry_pathname_w(entry);
        if(!wpath) continue;
        QString filenameinside = QString::fromWCharArray(wpath);

        if(filenameinside.endsWith("manifest.yml") && filenameinside.count("/") == 1) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            if(size <= 0) {
                QString msg = "Invalid image size of file in archive: " % QString::number(size);
                qWarning() << msg;
                ret["error"] = msg;
                continue;
            }

            // Create a buffer of that size to hold the image data
            definitionyml.resize(size);

            // And finally read the file into the buffer in chunks
            char* ptr = definitionyml.data();
            qint64 total = 0;
            while (total < size) {
                la_ssize_t chunk = archive_read_data(a, ptr + total, size - total);
                if(chunk < 0) {
                    QString msg = "Invalid chunk read: " % QString::fromStdString(archive_error_string(a));
                    qWarning() << msg;
                    ret["error"] = msg;
                    break;
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                QString msg = QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                qWarning() << msg;
                ret["error"] = msg;
                continue;
            }

        }

    }

    bool err = false;

    if(!definitionyml.isEmpty()) {

        YAML::Node config;

        // LOAD yaml file
        try {
            config = YAML::Load(definitionyml.toStdString());
        } catch(YAML::Exception &e) {
            QString msg = "Failed to load YAML file: " % QString(e.what());
            qWarning() << msg;
            ret["error"] = msg;
            err = true;
        }

        if(!err) {
            // version
            try {
                ret["about"] = config["about"]["version"].as<int>();
            } catch(YAML::Exception &e) {
                QString msg = "Failed to read value for 'version': " % QString(e.what());
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
                QString msg = "Failed to read value for 'name': " % QString(e.what());
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
                QString msg = "Failed to read value for 'description': " % QString(e.what());
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
                QString msg = "Failed to read value for 'author': " % QString(e.what());
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
                QString msg = "Failed to read value for 'contact': " % QString(e.what());
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
                QString msg = "Failed to read value for 'website': " % QString(e.what());
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
                    QString msg = "Required API version - " % QString::number(ret["targetAPI"].toInt()) %
                                  " - newer than what's supported: " % QString::number(CURRENTAPIVERSION);
                    qWarning() << msg;
                    ret["error"] = msg;
                    err = true;
                }

            } catch(YAML::Exception &e) {
                QString msg = "Failed to read value for 'targetAPI': " % QString(e.what());
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

    return ret;

#endif
#endif

    ret.insert("error", "Extension support is not available.");
    return ret;

}

bool PQCExtensionsHandler::verifyExtension(QString extensionDir, QString nameId) {

    qDebug() << "args: extensionDir =" << extensionDir;
    qDebug() << "args: nameId =" << nameId;

#if defined(PQMEXTENSIONS) && defined(PQMEXTENSIONS_NONSYS_OPENSSL)

    const QString identifyName = nameId % " (" % extensionDir % ")";

    /*************************************/
    // first verify signature of manifest

    QFile fmanifest(extensionDir % "/verification.txt");
    if(!fmanifest.open(QIODevice::ReadOnly)) {
        qWarning() << identifyName << "- unable to read verification.txt:" << QString("%1/verification.txt").arg(extensionDir);
        return false;
    }
    QByteArray manifest = fmanifest.readAll();

    QFile fmanifestsig(extensionDir % "/verification.txt.sig");
    if(!fmanifestsig.open(QIODevice::ReadOnly)) {
        qWarning() << identifyName << "- unable to read verification.txt.sig";
        return false;
    }
    QByteArray manifestsig = fmanifestsig.readAll();

#ifdef PQMHAVECUSTOMKEY
    const QStringList possibleKeys = {":/extensions.key", ":/custom_extensions.key"};
#else
    const QStringList possibleKeys = {":/extensions.key"};
#endif

    bool signaturePassed = false;

    for(const QString &keyfn : possibleKeys) {

        qDebug() << "Testing key file" << keyfn;

        QFile keyfile(keyfn);
        if(!keyfile.open(QIODevice::ReadOnly)) {
            qWarning() << "Unable to open public key for checking extension signature";
            continue;
        }

        QByteArray keyData = keyfile.readAll();

        // allocate openssl memory
        BIO* bio = BIO_new_mem_buf(keyData.constData(), static_cast<int>(keyData.size()));
        if(!bio) continue;

        EVP_PKEY* pubKey = PEM_read_bio_PUBKEY(bio, nullptr, nullptr, nullptr);

        BIO_free(bio);

        if(!pubKey) {
            qWarning() << "Failed to read public key";
            continue;
        }

        // create digest context
        EVP_MD_CTX* ctx = EVP_MD_CTX_new();
        if(!ctx) {
            EVP_PKEY_free(pubKey);
            continue;
        }

        if(EVP_DigestVerifyInit(ctx, nullptr, EVP_sha256(), nullptr, pubKey) == 1) {
            if(EVP_DigestVerifyUpdate(ctx, manifest.constData(), manifest.size()) == 1) {
                int result = EVP_DigestVerifyFinal(ctx, reinterpret_cast<const unsigned char*>(manifestsig.constData()), manifestsig.size());
                if(result == 1) {
                    qDebug() << identifyName << "- passed signature verification";
                    signaturePassed = true;
                } else
                    qDebug() << identifyName << "- Signature of verification.txt is wrong";
            }
        }

        EVP_MD_CTX_free(ctx);
        EVP_PKEY_free(pubKey);

        if(signaturePassed) break;

    }

    if(!signaturePassed) {
        qWarning() << identifyName << "- signature verification failed!";
        return false;
    }

    /**************************************/
    // next read manifest and compile map of all files and their hashes

    QHash<QString,QString> hashMap;
    const QList<QByteArray> maniLines = manifest.split('\n');
    for(const QString &l : maniLines) {

        if(l.trimmed().isEmpty())
            continue;

        const QStringList parts = l.split(":");
        if(parts.length() != 2) {
            qWarning() << identifyName << "- Invalid line in manifest found:" << l;
            return false;
        }

        hashMap.insert(parts.value(0), parts.at(1).trimmed());

    }

    /*************************************/
    // finally look through all the files and make sure they all have a match

    int counter = 0;

    QStringList ignoreFiles = {"verification.txt", "verification.txt.sig"};
    QStringList considerFileEndings = {"qml", "txt", "yml",
#ifdef PQMEXTENSIONS_NONSYS_LIBRARYVERIFICATION
                                       "so", "dll"
#endif
    };

    const QStringList lst = listFilesIn(extensionDir);
    for(QString _f : lst) {

        const QString f = _f.remove(0, extensionDir.length()+1);

        if(ignoreFiles.contains(f))
            continue;

        if(!considerFileEndings.contains(QFileInfo(f).suffix().toLower()))
            continue;

        counter += 1;

        if(!hashMap.contains(f)) {
            qWarning() << identifyName << "- File not listed in manifest:" << f;
            return false;
        }

        QFile file(extensionDir % "/" % f);
        if(!file.open(QIODevice::ReadOnly)) {
            qWarning() << identifyName << "- unable to read found file:" << f;
            return false;
        }
        const QString hash = QCryptographicHash::hash(file.readAll(),QCryptographicHash::Sha256).toHex();

        if(hash != hashMap.value(f)) {
            qWarning() << identifyName << "- Invalid hash for file:" << f;
            return false;
        }

    }

    if(counter != hashMap.count()) {
        qWarning() << identifyName << "- some expected files were not found, found" << counter << "of" << hashMap.count() << "files";
        return false;
    }

    /******************************************/

    qDebug() << identifyName << "- verification passed.";
    return true;

#endif

    return false;

}

QStringList PQCExtensionsHandler::listFilesIn(QString dir) {

    QStringList ret;

    QDir d(dir);
    const QStringList lstD = d.entryList(QDir::Dirs|QDir::NoDotAndDotDot);

    for(const QString &e : lstD)
        ret << listFilesIn(dir % "/" % e);

    const QStringList lstF = d.entryList(QDir::Files);
    for(const QString &e : lstF)
        ret << (dir % "/" % e);

    return ret;
}

void PQCExtensionsHandler::updateTranslationLanguage() {

    for(const QString &id : std::as_const(m_extensions))
        qApp->removeTranslator(extTrans.value(id).get());

    for(const QString &id : std::as_const(m_extensions)) {
        const QString qmfile = m_allextensions.value(id)->location % "/lang/" % id % "_" % PQCScriptsLocalization::get().getActiveTranslationCode() % ".qm";
        if(!QFile::exists(qmfile))
            qDebug() << id << "- no translation file found:" << qmfile;
        else {
            if(extTrans.value(id)->load(qmfile))
                qApp->installTranslator(extTrans.value(id).get());
            else
                qWarning() << id << "- unable to install translator:" << PQCScriptsLocalization::get().getActiveTranslationCode();
        }
    }

}
