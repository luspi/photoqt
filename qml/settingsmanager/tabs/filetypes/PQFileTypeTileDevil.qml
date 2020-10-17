import QtQuick 2.9

PQFileTypeTile {

    title: "DevIL"

    available: PQImageFormats.getAvailableEndingsWithDescriptionDevIL()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsDevIL()
    currentlyEnabled: PQImageFormats.enabledFileformatsDevIL
    projectWebpage: ["openil.sourceforge.net", "http://openil.sourceforge.net"]
    description: em.pty+qsTranslate("settingsmanager", "The Developer's Image Library (DevIL) supports a large number of image formats, many of which have been successfully tested with PhotoQt.")

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

    Component.onCompleted: {
        resetChecked()
    }
}
