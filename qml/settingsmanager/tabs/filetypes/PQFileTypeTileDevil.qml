import QtQuick 2.9

PQFileTypeTile {

    title: "DevIL"

    available: PQImageFormats.getAvailableEndingsWithDescriptionDevIL()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsDevIL()
    currentlyEnabled: PQImageFormats.enabledFileformatsDevIL
    projectWebpage: ["openil.sourceforge.net", "http://openil.sourceforge.net"]

    iconsource: "/settingsmanager/filetypes/devil.jpg"

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsDevIL = c
        }

    }
}
