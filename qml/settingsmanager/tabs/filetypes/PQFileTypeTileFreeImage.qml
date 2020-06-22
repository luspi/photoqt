import QtQuick 2.9

PQFileTypeTile {

    title: "FreeImage"

    available: PQImageFormats.getAvailableEndingsWithDescriptionFreeImage()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsFreeImage()
    currentlyEnabled: PQImageFormats.enabledFileformatsFreeImage
    projectWebpage: ["freeimage.sourceforge.io", "https://freeimage.sourceforge.io"]
    description: "FreeImage is an open source image library supporting a number of image formats, many of which have been successfully tested in PhotoQt."

    iconsource: "/settingsmanager/filetypes/freeimage.jpg"

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
            PQImageFormats.enabledFileformatsFreeImage = c
        }

    }
}
