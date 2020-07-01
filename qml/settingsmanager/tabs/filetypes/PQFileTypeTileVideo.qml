import QtQuick 2.9
import "../../../elements"

PQFileTypeTile {

    title: "Video"

    visible: handlingGeneral.isVideoSupportEnabled()

    available: PQImageFormats.getAvailableEndingsWithDescriptionVideo()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsVideo()
    currentlyEnabled: PQImageFormats.enabledFileformatsVideo

    description: "Here are some of the common video formats listed. Which ones are supported depend entirely on what codecs you have available on your system. Thus the list of enabled video formats might have to be adjusted to the proper set of supported formats."

    additionalSetting: [
        Row {
            spacing: 15
            x: (parent.width-width)/2
            PQCheckbox {
                id: autoplay
                y: (combo.height-height)/2+10
                text: "Autoplay"
            }
            PQCheckbox {
                id: loop
                y: (combo.height-height)/2+10
                text: "Loop"
            }
            PQComboBox {
                id: combo
                y: 10
                model: ["ffmpegthumbnailer"]
            }
        }

    ]

    additionalSettingShow: true

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
            autoplay.checked = PQSettings.videoAutoplay
            loop.checked = PQSettings.videoLoop
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsVideo = c
            PQSettings.videoAutoplay = autoplay.checked
            PQSettings.videoLoop = loop.checked
            PQSettings.videoThumbnailer = combo.currentText
        }

    }
}
