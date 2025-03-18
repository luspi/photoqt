#include <QString>
#include <QMap>

// Any extension should be self-contained and only interact with the rest of the
// application through PQCNotify (to perform actions) and PQCConstants (to get
// information). Any method in any of the PQCScripts* singletons can also be used.
// In addition, the properties below need to be specified.

// In addition to everything in this folder, the following might need to be added:
// - settings in settings database
// - possible shortcuts to shortcuts database
// - add loader to PQMainWindow.qml named 'loader_{id}'
// - add loader to settings section

namespace PQCExtensionConfig {

    namespace QuickActions {

        QString id = "quickactions";

        // basic behavior
        bool allowPopout = true;
        bool isModal = false;

        // what the loader might be able call
        // there is always assumed to be an action for "show" : {id}, and that doesn't need to be specified
        QList<QStringList> actions = {};

        // what shortcuts there are to be defined:
        // shortcut, default shortcut, action, additional arguments...
        QStringList shortcuts = {"__quickActions"};
        QMap<QString, QStringList> shortcutsActions = {{"__quickActions", {"show", "quickactions"}}};

        // what settings this extension needs
        QMap<QString,QStringList> settings = {{"QuickActionsItems",  {"list", "rename:://::delete:://::|:://::rotateleft:://::rotateright:://::mirrorhor:://::mirrorver:://::|:://::crop:://::scale:://::|:://::close"}},
                                              {"QuickActionsHeight", {"int",  "40"}},
                                              {"QuickActions",       {"bool", "false"}},
                                              {"PopoutQuickActions", {"bool", "0"}}};

        // any setting that needs migrating
        // The key is the version number at which any given migration needs to happen
        // The values are the old and new settings name and table
        QMap<QString, QList<QStringList> > migrateSettings = {
            {"4.9", {{"QuickActionsItems",  "interface", "QuickActionsItems",  "extensions"},
                     {"QuickActionsHeight", "interface", "QuickActionsHeight", "extensions"},
                     {"QuickActions",       "interface", "QuickActions",       "extensions"},
                     {"PopoutQuickActions", "interface", "PopoutQuickActions", "extensions"}}}
        };

        // any shortcut that needs migrating
        // The key is the version number at which any given migration needs to happen
        // The values are the old and new shortcut and possible default shortcuts (in order of priority, the first match is used)
        QMap<QString, QList<QStringList> > migrateShortcuts;

        // any further special migrations needs to be added directly to the PQCSettings::migrate() or PQCShortcuts::migrate() functions

    }

}
