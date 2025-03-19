#include <QString>
#include <QMap>
#include <QSize>

// Any extension should be self-contained and only interact with the rest of the
// application through PQCNotify (to perform actions) and PQCConstants (to get
// information). Any method in any of the PQCScripts* singletons can also be used.
// In addition, the properties below need to be specified.

// In addition to everything in this folder, the following might need to be added:
// - add loader to PQMainWindow.qml
// - add id for loader to PQLoader.qml
// - add settings file to settings section

namespace PQCExtensionConfig {

    namespace QuickActions {

        QString id = "quickactions";

        // if this is true, then a second file for the popout needs to be added with the same filename
        // but with 'Popout' added to the *end* of the basename
        bool allowPopout = true;
        bool isModal = false;

        // window size handling
        QSize defaultPopoutWindowSize = QSize(0,0);
        // this is the min required window size to have it embedded
        QSize minimumRequiredWindowSize = QSize(0,0);

        // This needs to have exactly two entries. If a popout does not exist, that entry can be the empty string.
        QString qmlBaseName = "PQQuickActions";

        // The name of the setting that stores its popout status
        QString popoutSettingName = "PopoutQuickActions";

        // what the loader might be able call
        // there is always assumed to be an action for "show" : {id}, and that doesn't need to be specified
// TODO: IMPLEMENT THIS
        QList<QStringList> actions = {};

        // what shortcuts there are to be defined:
        // shortcut, default shortcut, action, additional arguments...
        //
// TODO: IMPLEMENT THIS
        QStringList shortcuts = {"__quickActions"};
        QMap<QString, QStringList> shortcutsActions = {{"__quickActions", {"show", "quickactions"}}};

        // what settings this extension needs:
        // settings name, settings table (usually 'extensions'), datatype, defaultValue
        QList<QStringList> settings = {{"QuickActionsItems",  "extensions", "list", "rename:://::delete:://::|:://::rotateleft:://::rotateright:://::mirrorhor:://::mirrorver:://::|:://::crop:://::scale:://::|:://::close"},
                                       {"QuickActionsHeight", "extensions", "int",  "40"},
                                       {"QuickActions",       "extensions", "bool", "0"},
                                       {"PopoutQuickActions", "extensions", "bool", "0"}};

        // any setting that needs migrating
        // The key is the version number at which any given migration needs to happen
        // The values are the old and new settings name and table
        //
        // {"x.x", {{"oldname1", "oldtable1", "newname1", "newtable1"},
        //          {"oldname2", "oldtable2", "newname2", "newtable2"}}}
        //
        QMap<QString, QList<QStringList> > migrateSettings;

        // any shortcut that needs migrating
        // The key is the version number at which any given migration needs to happen
        // The values are the old and new shortcut and possible default shortcuts (in order of priority, the first match is used)
        //
        // {"x.x", {{"oldname1", "newname1", "newshortcut1", "newshortcut1_variant", ...},
        //          {"oldname2", "newname2", "newshortcut2", "newshortcut2_variant", ...}}}
        //
// TODO: IMPLEMENT THIS
        QMap<QString, QList<QStringList> > migrateShortcuts;

        // any further special migrations needs to be added directly to the PQCSettings::migrate() or PQCShortcuts::migrate() functions

    }

}
