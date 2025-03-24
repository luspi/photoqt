#include "../pqc_configtemplate.h"

class PQCExtensionFloatingNavigation : public PQCExtensionConfig {

public:
    PQCExtensionFloatingNavigation() {

        id = "floatingnavigation";
        allowPopout = false;
        isModal = false;

        qmlBaseName = "PQFloatingNavigation";

        shortcutsActions = {
            {"__navigationFloating",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Show floating navigation buttons"),
             "",
             "show", "floatingnavigation"}
        };

        settings = {
            {"NavigationFloating",  "extensions", "int", "0"}
        };

        migrateSettings = {
            {"4.9", {{"NavigationFloating", "interface", "NavigationFloating", "extensions"}}}
        };

        doAtStartup = {
            {"", "setup", "floatingnavigation"},
            {"NavigationFloating", "show", "floatingnavigation"}
        };

    }

};
