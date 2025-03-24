#include "../pqc_configtemplate.h"

class PQCExtensionQuickActions : public PQCExtensionConfig {

public:
    PQCExtensionQuickActions() {

        id = "quickactions";

        allowPopout = true;
        isModal = false;

        qmlBaseName = "PQQuickActions";

        popoutSettingName = "PopoutQuickActions";

        shortcutsActions = {
            {"__quickActions",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Show quick actions"),
             "", // no default shortcut set
             "show", "quickactions"}
        };

        settings = {
            {"QuickActionsItems",  "extensions", "list", "rename:://::delete:://::|:://::rotateleft:://::rotateright:://::mirrorhor:://::mirrorver:://::|:://::crop:://::scale:://::|:://::close"},
            {"QuickActionsHeight", "extensions", "int",  "40"},
            {"QuickActions",       "extensions", "bool", "0"},
            {"PopoutQuickActions", "extensions", "bool", "0"}
        };

    }

};
