/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title
    title: "Video"
    helptext: em.pty+qsTranslate("settingsmanager_filetypes", "These are some additional settings for playing videos.")
    expertmodeonly: true
    available: handlingGeneral.isVideoSupportEnabled()
    content: [

        Row {

            spacing: 10

            PQCheckbox {
                id: autoplay
                y: (combo.height-height)/2
                //: Used as setting for video files (i.e., autoplay videos)
                text: em.pty+qsTranslate("settingsmanager_filetypes", "Autoplay")
            }
            PQCheckbox {
                id: loop
                y: (combo.height-height)/2
                //: Used as setting for video files (i.e., loop videos)
                text: em.pty+qsTranslate("settingsmanager_filetypes", "Loop")
            }
            PQComboBox {
                id: combo
                //: Tooltip shown for combobox for selectiong video thumbnailer
                tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Select tool for creating video thumbnails")
                model: ["------",
                        "ffmpegthumbnailer"]
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.filetypesVideoAutoplay = autoplay.checked
            PQSettings.filetypesVideoLoop = loop.checked
            PQSettings.filetypesVideoThumbnailer = (combo.currentIndex == 0 ? "" : combo.currentText)
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {

        autoplay.checked = PQSettings.filetypesVideoAutoplay
        loop.checked = PQSettings.filetypesVideoLoop
        combo.currentIndex = (PQSettings.filetypesVideoThumbnailer == "" ? 0 : 1)

    }


}
