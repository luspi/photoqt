#include <pqc_extensionshandler.h>

#include <quickactions/config.h>
#include <floatingnavigation/config.h>
#include <histogram/config.h>

#include <QVariant>
#include <QQmlEngine>
#include <QQmlContext>

PQCExtensionsHandler::PQCExtensionsHandler() {

    /***********************************************/
    // ALL EXTENSIONS NEED TO BE REGISTERED HERE!!!
    /***********************************************/
    //
    // in addition, the loaderneeds to be added to PQMainWindow.qml
    // and the loader name added to the list in PQLoader.qml
    //

    m_allextensions.append(new PQCExtensionQuickActions());
    m_allextensions.append(new PQCExtensionFloatingNavigation());
    m_allextensions.append(new PQCExtensionHistogram());

    /********************************************/
    /********************************************/

    // do some minor processing and caching for easier and quicker access later-on
    for(auto &ext : m_allextensions) {
        m_extensions.append(ext->id);
        QList<QStringList> actions = ext->shortcutsActions;
        QStringList allsh;
        for(int i = 0; i < actions.length(); ++i) {
            allsh.append(actions[i][0]);
            m_mapShortcutToExtension.insert(actions[i][0], ext->id);
        }
        m_shortcuts.insert(ext->id, allsh);
        m_simpleListAllShortcuts.append(allsh);
    }

}

PQCExtensionsHandler::~PQCExtensionsHandler() {}

QStringList PQCExtensionsHandler::getExtensions() {
    return m_extensions;
}

bool PQCExtensionsHandler::getAllowPopout(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->allowPopout;
    }
    qWarning() << "Unknown extension id:" << id;
    return false;
}

bool PQCExtensionsHandler::getIsModal(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->isModal;
    }
    qWarning() << "Unknown extension id:" << id;
    return false;
}

QString PQCExtensionsHandler::getQmlBaseName(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->qmlBaseName;
    }
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QSize PQCExtensionsHandler::getDefaultPopoutSize(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->defaultPopoutWindowSize;
    }
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

QSize PQCExtensionsHandler::getMinimumRequiredWindowSize(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->minimumRequiredWindowSize;
    }
    qWarning() << "Unknown extension id:" << id;
    return QSize(0,0);
}

QStringList PQCExtensionsHandler::getShortcuts(QString id) {
    if(m_extensions.contains(id)) {
        return m_shortcuts[id];
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QList<QStringList> PQCExtensionsHandler::getShortcutsActions(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->shortcutsActions;
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QList<QStringList> PQCExtensionsHandler::getSettings(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->settings;
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QString PQCExtensionsHandler::getPopoutSettingName(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->popoutSettingName;
    }
    qWarning() << "Unknown extension id:" << id;
    return "";
}

QStringList PQCExtensionsHandler::getAllShortcuts() {
    return m_simpleListAllShortcuts;
}

QString PQCExtensionsHandler::getDescriptionForShortcut(QString sh) {
    QString ret = "";
    for(auto ext : std::as_const(m_allextensions)) {
        const QList<QStringList> allsh = ext->shortcutsActions;
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

QString PQCExtensionsHandler::getExtensionForShortcut(QString sh) {
    return m_mapShortcutToExtension.value(sh, "");
}

QList<QStringList> PQCExtensionsHandler::getDoAtStartup(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->doAtStartup;
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QMap<QString, QList<QStringList> > PQCExtensionsHandler::getMigrateSettings(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->migrateSettings;
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

QMap<QString, QList<QStringList> > PQCExtensionsHandler::getMigrateShortcuts(QString id) {
    int ind = m_extensions.indexOf(id);
    if(ind != -1) {
        return m_allextensions[ind]->migrateShortcuts;
    }
    qWarning() << "Unknown extension id:" << id;
    return {};
}

