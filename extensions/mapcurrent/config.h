#include <pqc_configtemplate.h>
#include <scripts/pqc_scriptsconfig.h>

class PQCExtensionMapCurrent : public PQCExtensionConfig {

public:
    PQCExtensionMapCurrent() {

        id = "mapcurrent";

        supportedByThisBuild = PQCScriptsConfig::get().isLocationSupportEnabled();

        allowPopout = true;
        isModal = false;

        defaultPopoutWindowSize = QSize(300,200);
        minimumRequiredWindowSize = QSize(500,350);

        qmlBaseName = "PQMapCurrent";

        popoutSettingName = "MapCurrentPopout";

        shortcutsActions = {
            {"__showMapCurrent",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Show Image on Map"),
             "", // no default shortcut set
             "show", "mapcurrent"}
        };

        settings = {
            {"MapCurrent",         "extensions", "bool",  "0"},
            {"MapCurrentPosition", "extensions", "point", "100,100"},
            {"MapCurrentSize",     "extensions", "size",  "300,200"},
            {"MapCurrentPopout",   "extensions", "bool",  "0"}
        };

        migrateSettings = {
            {"4.9", {{"CurrentVisible",   "mapview",   "MapCurrent",         "extensions"},
                     {"CurrentPosition",  "mapview",   "MapCurrentPosition", "extensions"},
                     {"CurrentSize",      "mapview",   "MapCurrentSize",     "extensions"},
                     {"PopoutMapCurrent", "interface", "MapCurrentPopout",   "extensions"}}}
        };

        doAtStartup = {
            {"MapCurrent", "show", "mapcurrent"}
        };

    }

};
