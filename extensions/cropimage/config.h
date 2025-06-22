#include <pqc_configtemplate.h>

class PQCExtensionCropImage : public PQCExtensionConfig {

public:
    PQCExtensionCropImage() {

        id = "cropimage";
        allowPopout = true;
        isModal = true;

        defaultPopoutWindowSize = QSize(800,600);
        minimumRequiredWindowSize = QSize(600,400);

        qmlBaseName = "PQCropImage";

        popoutSettingName = "CropImagePopout";

        shortcutsActions = {
            {"__crop",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Crop Image"),
             "", // no default shortcut set
             "show", "cropimage"}
        };

        settings = {
            {"CropImagePopout", "extensions", "bool", "0"}
        };

        // {"x.x", {{"oldname1", "oldtable1", "newname1", "newtable1"},
        //          {"oldname2", "oldtable2", "newname2", "newtable2"}}}
        migrateSettings = {
            {"4.9", {{"PopoutCrop", "interface", "CropImagePopout", "extensions"}}}
        };

    }

};
