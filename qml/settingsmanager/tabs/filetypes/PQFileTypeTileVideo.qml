import QtQuick 2.9
import "../../../elements"

PQFileTypeTile {

    title: "Video"

    visible: handlingGeneral.isVideoSupportEnabled()

    available: PQImageFormats.getAvailableEndingsWithDescriptionVideo()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsVideo()
    currentlyEnabled: PQImageFormats.enabledFileformatsVideo

    description: em.pty+qsTranslate("settingsmanager_filetypes", "Here are some of the common video formats listed. Which ones are supported depend entirely on what codecs you have available on your system. Thus the list of enabled video formats might have to be adjusted to the proper set of supported formats.")

    additionalSetting: [
        Row {
            spacing: 15
            x: (parent.width-width)/2
            PQCheckbox {
                id: autoplay
                y: (combo.height-height)/2+10
                //: Used as setting for video files (i.e., autoplay videos)
                text: em.pty+qsTranslate("settingsmanager_filetypes", "Autoplay")
            }
            PQCheckbox {
                id: loop
                y: (combo.height-height)/2+10
                //: Used as setting for video files (i.e., loop videos)
                text: em.pty+qsTranslate("settingsmanager_filetypes", "Loop")
            }
            PQComboBox {
                id: combo
                y: 10
                model: ["------",
                        "ffmpegthumbnailer"]
            }
        }

    ]

    additionalSettingShow: true

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
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
            PQSettings.videoThumbnailer = (combo.currentIndex == 0 ? "" : combo.currentText)
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        resetChecked()
        autoplay.checked = PQSettings.videoAutoplay
        loop.checked = PQSettings.videoLoop
        combo.currentIndex = (PQSettings.videoThumbnailer == "" ? 0 : 1)
    }

}
