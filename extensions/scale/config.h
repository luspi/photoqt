#include "../pqc_configtemplate.h"

class PQCExtensionScale : public PQCExtensionConfig {

public:
    PQCExtensionScale() {

        id = "scale";
        allowPopout = true;
        isModal = true;

        defaultPopoutWindowSize = QSize(800,600);
        minimumRequiredWindowSize = QSize(600,400);

        qmlBaseName = "PQScale";

        popoutSettingName = "ScalePopout";

        shortcutsActions = {
            {"__scale",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Scale Image"),
             "", // no default shortcut set
             "show", "scale"}
        };

        settings = {
            {"ScalePopout",   "extensions", "bool",   "0"}
        };

        // {"x.x", {{"oldname1", "oldtable1", "newname1", "newtable1"},
        //          {"oldname2", "oldtable2", "newname2", "newtable2"}}}
        migrateSettings = {
            {"4.9", {{"PopoutScale", "interface", "ScalePopout", "extensions"}}}
        };

    }

};
