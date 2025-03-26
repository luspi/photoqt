#include "../pqc_configtemplate.h"

class PQCExtensionImgurCom : public PQCExtensionConfig {

public:
    PQCExtensionImgurCom() {

        id = "imgurcom";
        allowPopout = true;
        isModal = true;

        defaultPopoutWindowSize = QSize(800,600);
        minimumRequiredWindowSize = QSize(600,400);

        qmlBaseName = "PQImgurCom";

        popoutSettingName = "ImgurComPopout";

        shortcutsActions = {
            {"__imgurAnonym",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Upload to imgur.com (anonymously)"),
             "", // no default shortcut set
             "show", "imgurcom"},
            {"__imgur",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Upload to imgur.com user account"),
             "", // no default shortcut set
             "show", "imgurcom"}
        };

        settings = {
            {"ImgurComPopout", "extensions", "bool",   "0"}
        };

        migrateSettings = {
            {"4.9", {{"PopoutImgur", "interface", "ImgurComPopout", "extensions"}}}
        };

    }

};
