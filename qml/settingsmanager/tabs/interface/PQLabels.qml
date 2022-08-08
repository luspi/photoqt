/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "labels")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "The labels are shown along the top edge of the main view.")
    content: [

        PQCheckbox {
            id: labels_show
            //: checkbox in settings manager
            text: em.pty+qsTranslate("settingsmanager_interface", "show labels")
            opacity: variables.settingsManagerExpertMode ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity > 0
            property bool skipCheckedCheck: false
            onCheckedChanged: {
                if(!skipCheckedCheck) {
                    if(checked) {
                        labels_counter.checked = true
                        labels_filepath.checked = false
                        labels_filename.checked = true
                        labels_resolution.checked = false   // only show when explicitely enabled
                        labels_zoom.checked = true
                        labels_rotation.checked = true
                        labels_windowbuttons.checked = true
                    } else {
                        labels_counter.checked = false
                        labels_filepath.checked = false
                        labels_filename.checked = false
                        labels_resolution.checked = false
                        labels_zoom.checked = false
                        labels_rotation.checked = false
                        labels_windowbuttons.checked = false
                        labels_windowclosebuttonalwaysvisible.checked = false
                    }
                }
            }
        },

        Column {

            spacing: 15
            height: variables.settingsManagerExpertMode ? undefined : 0

            Flow {
                id: labels_flow
                width: set.contwidth
                spacing: 10
                opacity: variables.settingsManagerExpertMode ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity > 0

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_counter
                    //: refers to the image counter (i.e., image #/# in current folder)
                    text: em.pty+qsTranslate("settingsmanager_interface", "counter")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }

                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_filepath
                    //: show filepath in the labels. This is specifically the filePATH and not the filename.
                    text: em.pty+qsTranslate("settingsmanager_interface", "filepath")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_filename
                    //: show filename in the labels. This is specifically the fileNAME and not the filepath.
                    text: em.pty+qsTranslate("settingsmanager_interface", "filename")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_resolution
                    text: em.pty+qsTranslate("settingsmanager_interface", "image resolution")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_zoom
                    text: em.pty+qsTranslate("settingsmanager_interface", "current zoom level")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_rotation
                    text: em.pty+qsTranslate("settingsmanager_interface", "current rotation angle")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_windowbuttons
                    //: the window buttons are some window management buttons like: close window, maximize, fullscreen
                    text: em.pty+qsTranslate("settingsmanager_interface", "window buttons")
                    onCheckedChanged: {
                        labels_show.skipCheckedCheck = true
                        labels_show.checked = (howManyChecked() > 0)
                        labels_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: labels_windowclosebuttonalwaysvisible
                    //: The 'x' is a small button (part of the window buttons) that closes the window
                    text: em.pty+qsTranslate("settingsmanager_interface", "always show 'x'")
                    enabled: labels_windowbuttons.checked
                }

            }

            Row {
                spacing: 5
                width: parent.width
                opacity: variables.settingsManagerExpertMode ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity > 0
                Text {
                    y: (parent.height-height)/2
                    color: "white"
                    //: the size of the window buttons (the buttons shown in the top right corner of the window)
                    text: em.pty+qsTranslate("settingsmanager_interface", "size of window buttons") + ":"
                }
                PQSlider {
                    id: labels_windowbuttonssize
                    y: (parent.height-height)/2
                    from: 5
                    to: 25
                }
            }

        }

    ]

    function howManyChecked() {
        var howmany = 0
        if(labels_counter.checked) howmany += 1
        if(labels_filepath.checked) howmany += 1
        if(labels_filename.checked) howmany += 1
        if(labels_resolution.checked) howmany += 1
        if(labels_zoom.checked) howmany += 1
        if(labels_rotation.checked) howmany += 1
        if(labels_windowbuttons.checked) howmany += 1
        return howmany
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            labels_counter.checked = !PQSettings.interfaceLabelsHideCounter
            labels_filepath.checked = !PQSettings.interfaceLabelsHideFilepath
            labels_filename.checked = !PQSettings.interfaceLabelsHideFilename
            labels_resolution.checked = !PQSettings.interfaceLabelsHideResolution
            labels_zoom.checked = !PQSettings.interfaceLabelsHideZoomLevel
            labels_rotation.checked = !PQSettings.interfaceLabelsHideRotationAngle
            labels_windowbuttons.checked = !PQSettings.interfaceLabelsHideWindowButtons
            labels_windowclosebuttonalwaysvisible.checked = PQSettings.interfaceLabelsAlwaysShowX

            labels_windowbuttonssize.value = PQSettings.interfaceLabelsWindowButtonsSize

            if(howManyChecked() == 0)
                labels_show.checked = false
            else
                labels_show.checked = true
        }

        onSaveAllSettings: {

            PQSettings.interfaceLabelsHideCounter = !labels_counter.checked
            PQSettings.interfaceLabelsHideFilepath = !labels_filepath.checked
            PQSettings.interfaceLabelsHideFilename = !labels_filename.checked
            PQSettings.interfaceLabelsHideResolution = !labels_resolution.checked
            PQSettings.interfaceLabelsHideZoomLevel = !labels_zoom.checked
            PQSettings.interfaceLabelsHideRotationAngle = !labels_rotation.checked
            PQSettings.interfaceLabelsHideWindowButtons = !labels_windowbuttons.checked
            PQSettings.interfaceLabelsAlwaysShowX = labels_windowclosebuttonalwaysvisible.checked

            PQSettings.interfaceLabelsWindowButtonsSize = labels_windowbuttonssize.value

        }

    }

}
