import QtQuick 2.9

PQFileTypeTile {

    title: "GraphicsMagick"

    available: PQImageFormats.getAvailableEndingsWithDescriptionGm()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsGm()
    currentlyEnabled: PQImageFormats.enabledFileformatsGm
    projectWebpage: ["graphicsmagick.org", "http://www.graphicsmagick.org"]
    description: "GraphicsMagick calls itself the 'swiss army knife of image processing'. It supports a wide variety of image formats, and PhotoQt can display the vast majority of them."

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

    Component.onCompleted: {
        resetChecked()
    }
}
