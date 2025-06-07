#include <pqc_configtemplate.h>

class PQCExtensionExportImage : public PQCExtensionConfig {

public:
    PQCExtensionExportImage() {

        id = "exportimage";
        allowPopout = true;
        isModal = true;

        defaultPopoutWindowSize = QSize(800,600);
        minimumRequiredWindowSize = QSize(600,400);

        qmlBaseName = "PQExportImage";

        popoutSettingName = "ExportImagePopout";

        shortcutsActions = {
            {"__export",
             //: Description of shortcut action
             QApplication::translate("settingsmanager", "Export Image"),
             "Ctrl+S:://::Ctrl+Shift+S",
             "show", "exportimage"}
        };

        settings = {
            {"ExportImagePopout",    "extensions", "bool",   "0"},
            {"ExportImageFavorites", "extensions", "list",   "11485:://::46215:://::28282:://::44462"},
            {"ExportImageLastUsed",  "extensions", "string", ""}
        };

        migrateSettings = {
            {"4.9", {{"PopoutExport", "interface", "ExportImagePopout",      "extensions"},
                     {"Favorites",    "export",    "ExportImageFavorites", "extensions"},
                     {"LastUsed",     "export",    "ExportImageLastUsed",  "extensions"},
                     {"",             "export",    "",                     ""}}}
        };

        migrateShortcuts = {
            {"4.9", {{"__saveAs", "__export"}}}
        };

    }

};
