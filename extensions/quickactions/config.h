#include <pqc_configtemplate.h>

class PQCExtensionQuickActions : public PQCExtensionConfig {

public:
    PQCExtensionQuickActions() {

        id = "quickactions";

        allowPopout = true;
        isModal = false;

        qmlBaseName = "PQQuickActions";

        popoutSettingName = "QuickActionsPopout";

        shortcutsActions = {
            {"__quickActions",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Show/Hide quick actions"),
             "Ctrl+Shift+A", // no default shortcut set
             "show", "quickactions"}
        };

        settings = {
            {"QuickActionsItems",  "extensions", "list", "rename:://::delete:://::|:://::rotateleft:://::rotateright:://::mirrorhor:://::mirrorver:://::|:://::crop:://::scale:://::|:://::close"},
            {"QuickActionsHeight", "extensions", "int",  "40"},
            {"QuickActions",       "extensions", "bool", "0"},
            {"QuickActionsPopout", "extensions", "bool", "0"}
        };

        doAtStartup = {
            {"QuickActions", "show", "quickactions"}
        };

    }

};
