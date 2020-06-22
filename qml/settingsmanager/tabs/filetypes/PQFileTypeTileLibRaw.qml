import QtQuick 2.9

PQFileTypeTile {

    title: "libraw"

    available: PQImageFormats.getAvailableEndingsWithDescriptionRAW()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsRAW()
    currentlyEnabled: PQImageFormats.enabledFileformatsRAW
    projectWebpage: ["libraw.org", "https://www.libraw.org"]

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
            PQImageFormats.enabledFileformatsRAW = c
        }

    }
}
