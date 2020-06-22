import QtQuick 2.9

PQFileTypeTile {

    title: "GraphicsMagick"

    available: PQImageFormats.getAvailableEndingsWithDescriptionGm()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsGm()
    currentlyEnabled: PQImageFormats.enabledFileformatsGm
    projectWebpage: ["graphicsmagick.org", "http://www.graphicsmagick.org"]

    iconsource: "/settingsmanager/filetypes/gm.jpg"

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
            PQImageFormats.enabledFileformatsGm = c
        }

    }
}
