#include <pqc_configtemplate.h>

class PQCExtensionWallpaper : public PQCExtensionConfig {

public:
    PQCExtensionWallpaper() {

        id = "wallpaper";
        allowPopout = true;
        isModal = true;

        defaultPopoutWindowSize = QSize(800,600);
        minimumRequiredWindowSize = QSize(600,400);

        qmlBaseName = "PQWallpaper";

        popoutSettingName = "WallpaperPopout";

        shortcutsActions = {
            {"__wallpaper",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Set as Wallpaper"),
             "W",
             "show", "wallpaper"}
        };

        settings = {
            {"WallpaperPopout", "extensions", "bool", "0"}
        };

        // {"x.x", {{"oldname1", "oldtable1", "newname1", "newtable1"},
        //          {"oldname2", "oldtable2", "newname2", "newtable2"}}}
        migrateSettings = {
            {"4.9", {{"PopoutWallpaper", "interface", "WallpaperPopout", "extensions"}}}
        };

    }

};
