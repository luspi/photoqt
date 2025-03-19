#include <scripts/pqc_scriptsextensions.h>
#include <quickactions/config.h>
#include <QVariant>
#include <QQmlEngine>
#include <QQmlContext>

PQCScriptsExtensions::PQCScriptsExtensions() {

    /***********************************************/
    // ALL EXTENSIONS NEED TO BE REGISTERED HERE!!!
    /***********************************************/
    //
    // in addition, the loaderneeds to be added to PQMainWindow.qml
    // and the loader name added to the list in PQLoader.qml
    //

    // QUICK ACTIONS
    m_extensions.append(PQCExtensionConfig::QuickActions::id);
    m_allowPopout.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::allowPopout);
    m_isModal.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::isModal);
    m_qmlBaseName.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::qmlBaseName);
    m_defaultPopoutSize.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::defaultPopoutWindowSize);
    m_minimumRequiredWindowSize.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::minimumRequiredWindowSize);
    m_actions.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::actions);
    m_shortcuts.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::shortcuts);
    m_shortcutsActions.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::shortcutsActions);
    m_settings.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::settings);
    m_popoutSettingName.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::popoutSettingName);
    m_migrateSettings.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::migrateSettings);
    m_migrateShortcuts.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::migrateShortcuts);

}

PQCScriptsExtensions::~PQCScriptsExtensions() {}

QStringList PQCScriptsExtensions::getExtensions() {
    return m_extensions;
}

bool PQCScriptsExtensions::getAllowPopout(QString id) {
    if(m_extensions.contains(id)) {
        return m_allowPopout[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCScriptsExtensions::getIsModal(QString id) {
    if(m_extensions.contains(id)) {
        return m_isModal[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return false;
}

QString PQCScriptsExtensions::getQmlBaseName(QString id) {
    if(m_extensions.contains(id)) {
        return m_qmlBaseName[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QSize PQCScriptsExtensions::getDefaultPopoutSize(QString id) {
    if(m_extensions.contains(id)) {
        return m_defaultPopoutSize[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

QSize PQCScriptsExtensions::getMinimumRequiredWindowSize(QString id) {
    if(m_extensions.contains(id)) {
        return m_minimumRequiredWindowSize[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

QList<QStringList> PQCScriptsExtensions::getActions(QString id) {
    if(m_extensions.contains(id)) {
        return m_actions[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QStringList PQCScriptsExtensions::getShortcuts(QString id) {
    if(m_extensions.contains(id)) {
        return m_shortcuts[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QMap<QString, QStringList> PQCScriptsExtensions::getShortcutsActions(QString id) {
    if(m_extensions.contains(id)) {
        return m_shortcutsActions[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QList<QStringList> PQCScriptsExtensions::getSettings(QString id) {
    if(m_extensions.contains(id)) {
        return m_settings[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QString PQCScriptsExtensions::getPopoutSettingName(QString id) {
    if(m_extensions.contains(id)) {
        return m_popoutSettingName[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QMap<QString, QList<QStringList> > PQCScriptsExtensions::getMigrateSettings(QString id) {
    if(m_extensions.contains(id)) {
        return m_migrateSettings[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QMap<QString, QList<QStringList> > PQCScriptsExtensions::getMigrateShortcuts(QString id) {
    if(m_extensions.contains(id)) {
        return m_migrateShortcuts[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

