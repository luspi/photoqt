#include "../pqc_configtemplate.h"

class PQCExtensionScaleImage : public PQCExtensionConfig {

public:
    PQCExtensionScaleImage() {

        id = "scaleimage";
        allowPopout = true;
        isModal = true;

        defaultPopoutWindowSize = QSize(800,600);
        minimumRequiredWindowSize = QSize(600,400);

        qmlBaseName = "PQScaleImage";

        popoutSettingName = "ScaleImagePopout";

        shortcutsActions = {
            {"__scale",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Scale Image"),
             "", // no default shortcut set
             "show", "scaleimage"}
        };

        settings = {
            {"ScaleImagePopout",   "extensions", "bool",   "0"}
        };

        // {"x.x", {{"oldname1", "oldtable1", "newname1", "newtable1"},
        //          {"oldname2", "oldtable2", "newname2", "newtable2"}}}
        migrateSettings = {
            {"4.9", {{"PopoutScale", "interface", "ScaleImagePopout", "extensions"}}}
        };

    }

};
