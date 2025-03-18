#include <scripts/pqc_scriptsextensions.h>
#include <quickactions/config.h>
#include <QVariant>

PQCScriptsExtensions::PQCScriptsExtensions() {
    m_extensions = {PQCExtensionConfig::QuickActions::id};

    m_allowPopout.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::allowPopout);
    m_isModal.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::isModal);
    m_actions.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::actions);
    m_shortcuts.insert(PQCExtensionConfig::QuickActions::id, PQCExtensionConfig::QuickActions::shortcuts);

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

QMap<QString, QStringList> PQCScriptsExtensions::getSettings(QString id) {
    if(m_extensions.contains(id)) {
        return m_settings[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
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

