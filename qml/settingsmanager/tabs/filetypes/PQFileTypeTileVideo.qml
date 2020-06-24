import QtQuick 2.9

PQFileTypeTile {

    title: "Video"

    visible: handlingGeneral.isVideoSupportEnabled()

    available: PQImageFormats.getAvailableEndingsWithDescriptionVideo()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsVideo()
    currentlyEnabled: PQImageFormats.enabledFileformatsVideo

    description: "Here are some of the common video formats listed. Which ones are supported depend entirely on what codecs you have available on your system. Thus the list of enabled video formats might have to be adjusted to the proper set of supported formats."

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
            PQImageFormats.enabledFileformatsVideo = c
        }

    }
}
