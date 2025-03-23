#include <QString>
#include <QMap>
#include <QSize>
#include <QApplication>

// Any extension should be self-contained and only interact with the rest of the
// application through PQCNotify (to perform actions) and PQCConstants (to get
// information). Any method in any of the PQCScripts* singletons can also be used.
// In addition, the properties below need to be specified.

// In addition to everything in this folder, the following might need to be added:
// - add loader to PQMainWindow.qml
// - add id for loader to PQLoader.qml
// - add settings file to settings section
// - add qmlBasename without PQ prefix to ListExtensions.cmake

namespace PQCExtensionConfig {

    namespace Histogram {

        QString id = "histogram";

        // if this is true, then a second file for the popout needs to be added with the same filename
        // but with 'Popout' added to the *end* of the basename
        bool allowPopout = true;
        bool isModal = false;

        // window size handling
        QSize defaultPopoutWindowSize = QSize(300,200);
        // this is the min required window size to have it embedded
        QSize minimumRequiredWindowSize = QSize(500,350);

        // This needs to have exactly two entries. If a popout does not exist, that entry can be the empty string.
        QString qmlBaseName = "PQHistogram";

        // The name of the setting that stores its popout status
        QString popoutSettingName = "HistogramPopout";

        // what shortcuts there are to be defined:
        // shortcut, description (for settings manager), default shortcut, action, additional argument
        // One of them should always be 'show','{id}'!
        // NOTE: New (default) shortcuts need to be entered as migrations
        QList<QStringList> shortcutsActions = {
            {"__histogram",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Show Histogram"),
             "", // no default shortcut set
             "show", "histogram"}
        };

        // what settings this extension needs:
        // settings name, settings table (usually 'extensions'), datatype, defaultValue
        QList<QStringList> settings = {
            {"HistogramVisible",  "extensions", "bool",   "0"},
            {"HistogramPosition", "extensions", "point",  "100,100"},
            {"HistogramSize",     "extensions", "size",   "300,200"},
            {"HistogramVersion",  "extensions", "string", "color"},
            {"HistogramPopout",   "extensions", "bool",   "0"}
        };

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
        // The values are the old and new shortcut and possible default shortcuts, both old and new (in order of priority, the first match is used)
        // The old default shortcut is needed to make sure we only change a default shortcut if it hasn't been changed yet
        //
        // {"x.x", {{"oldname1", "newname1", "oldshortcut1", "newshortcut1", "newshortcut1_variant", ...},
        //          {"oldname2", "newname2", "oldshortcut2", "newshortcut2", "newshortcut2_variant", ...}}}
        //
        // NOTE: New (default) shortcuts need to be entered as migrations
        QMap<QString, QList<QStringList> > migrateShortcuts;

        // any further special migrations needs to be added directly to the PQCSettings::migrate() or PQCShortcuts::migrate() functions

        // startup checks
        // the key is the setting that if true calls what's after. An empty setting always runs the command after
        // the values is the command, possible commands are 'show' and 'setup'
        QList<QStringList> doAtStartup = {
            {"HistogramVisible", "show", "hisotram"}
        };

    }

}
