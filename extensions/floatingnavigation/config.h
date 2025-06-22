#include <pqc_configtemplate.h>

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
             "Ctrl+N",
             "show", "floatingnavigation"}
        };

        settings = {
            {"FloatingNavigation",  "extensions", "bool", "0"}
        };

        migrateSettings = {
            {"4.9", {{"NavigationFloating", "interface", "FloatingNavigation", "extensions"}}}
        };

        doAtStartup = {
            {"", "setup", "floatingnavigation"},
            {"FloatingNavigation", "show", "floatingnavigation"}
        };

    }

};
