import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "quick info")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "The quick info refers to the labels along the top edge of the main view.")
    content: [

        PQCheckbox {
            id: quick_show
            //: checkbox in settings manager
            text: em.pty+qsTranslate("settingsmanager_interface", "show quick info")
            opacity: variables.settingsManagerExpertMode ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity > 0
            property bool skipCheckedCheck: false
            onCheckedChanged: {
                if(!skipCheckedCheck) {
                    if(checked) {
                        quick_counter.checked = true
                        quick_filepath.checked = false
                        quick_filename.checked = true
                        quick_zoom.checked = true
                        quick_exit.checked = true
                    } else {
                        quick_counter.checked = false
                        quick_filepath.checked = false
                        quick_filename.checked = false
                        quick_zoom.checked = false
                        quick_exit.checked = false
                    }
                }
            }
        },

        Column {

            spacing: 15
            height: variables.settingsManagerExpertMode ? undefined : 0

            Flow {
                id: quick_flow
                width: set.contwidth
                spacing: 10
                opacity: variables.settingsManagerExpertMode ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity > 0

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: quick_counter
                    //: refers to the image counter (i.e., image #/# in current folder)
                    text: em.pty+qsTranslate("settingsmanager_interface", "counter")
                    onCheckedChanged: {
                        quick_show.skipCheckedCheck = true
                        quick_show.checked = (howManyChecked() > 0)
                        quick_show.skipCheckedCheck = false
                    }

                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: quick_filepath
                    //: show filepath in the quickinfo. This is specifically the filePATH and not the filename.
                    text: em.pty+qsTranslate("settingsmanager_interface", "filepath")
                    onCheckedChanged: {
                        quick_show.skipCheckedCheck = true
                        quick_show.checked = (howManyChecked() > 0)
                        quick_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: quick_filename
                    //: show filename in the quickinfo. This is specifically the fileNAME and not the filepath.
                    text: em.pty+qsTranslate("settingsmanager_interface", "filename")
                    onCheckedChanged: {
                        quick_show.skipCheckedCheck = true
                        quick_show.checked = (howManyChecked() > 0)
                        quick_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: quick_zoom
                    text: em.pty+qsTranslate("settingsmanager_interface", "current zoom level")
                    onCheckedChanged: {
                        quick_show.skipCheckedCheck = true
                        quick_show.checked = (howManyChecked() > 0)
                        quick_show.skipCheckedCheck = false
                    }
                }

                PQCheckbox {
                    y: (parent.height-height)/2
                    id: quick_exit
                    //: the exit button is the x shown in the top right corner of the window
                    text: em.pty+qsTranslate("settingsmanager_interface", "exit button")
                    onCheckedChanged: {
                        quick_show.skipCheckedCheck = true
                        quick_show.checked = (howManyChecked() > 0)
                        quick_show.skipCheckedCheck = false
                    }
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
                    //: the size of the exit button (the x shown in the top right corner of the window)
                    text: em.pty+qsTranslate("settingsmanager_interface", "size of exit button") + ":"
                }
                PQSlider {
                    id: quick_exitsize
                    y: (parent.height-height)/2
                    from: 5
                    to: 25
                }
            }

        }

    ]

    function howManyChecked() {
        var howmany = 0
        if(quick_counter.checked) howmany += 1
        if(quick_filepath.checked) howmany += 1
        if(quick_filename.checked) howmany += 1
        if(quick_zoom.checked) howmany += 1
        if(quick_exit.checked) howmany += 1
        return howmany
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            quick_counter.checked = !PQSettings.quickInfoHideCounter
            quick_filepath.checked = !PQSettings.quickInfoHideFilepath
            quick_filename.checked = !PQSettings.quickInfoHideFilename
            quick_zoom.checked = !PQSettings.quickInfoHideZoomLevel
            quick_exit.checked = !PQSettings.quickInfoHideX

            quick_exitsize.value = PQSettings.quickInfoCloseXSize

            if(howManyChecked() == 0)
                quick_show.checked = false
            else
                quick_show.checked = true
        }

        onSaveAllSettings: {

            PQSettings.quickInfoHideCounter = !quick_counter.checked
            PQSettings.quickInfoHideFilepath = !quick_filepath.checked
            PQSettings.quickInfoHideFilename = !quick_filename.checked
            PQSettings.quickInfoHideZoomLevel = !quick_zoom.checked
            PQSettings.quickInfoHideX = !quick_exit.checked

            PQSettings.quickInfoCloseXSize = quick_exitsize.value

        }

    }

}
