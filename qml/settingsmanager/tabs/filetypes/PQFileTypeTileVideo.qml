/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

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
