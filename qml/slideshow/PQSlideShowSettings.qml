import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import "../elements"

Rectangle {

    id: slideshowsettings_top

    color: PQSettings.slideShowSettingsPopoutElement ? "#aa000000" : "#88000000"

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: PQSettings.slideShowSettingsPopoutElement ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.slideShowSettingsPopoutElement ? 0 : PQSettings.animationDuration*100 } }
    visible: opacity!=0

    PQMouseArea {
        anchors.fill: parent
    }

    Rectangle {

        id: insidecont

        x: PQSettings.slideShowSettingsPopoutElement ? 10 : ((parent.width-width)/2)
        y: PQSettings.slideShowSettingsPopoutElement ? 10 : ((parent.height-height)/2)
        width: PQSettings.slideShowSettingsPopoutElement ? parentWidth-20 : 600
        height: PQSettings.slideShowSettingsPopoutElement ? parentHeight-20 : 400

        Text {
            id: heading
            x: (parent.width-width)/2
            y: 10
            color: "white"
            font.pointSize: 20
            font.bold: true
            text: "Slideshow"
        }

        clip: true

        color: PQSettings.slideShowSettingsPopoutElement ? "transparent" : "#88000000"
        border.color: PQSettings.slideShowSettingsPopoutElement ? "transparent" : "#44ffffff"
        radius: PQSettings.slideShowSettingsPopoutElement ? 0 : 10

        Flickable {

            width: parent.width
            height: insidecont.height-heading.height-butcont.height-40
            y: heading.y+heading.height+10

            contentHeight: insidecolumn.height
            clip: true

            ScrollBar.vertical: PQScrollBar { id: scroll }

            Column {

                id: insidecolumn

                width: parent.width

                spacing: 5

                Item {
                    width: parent.width
                    height: 1
                }

                Item {

                    id: timeitem

                    x: 10
                    width: parent.width-2*x
                    height: childrenRect.height

                    Row {

                        spacing: 10

                        Text {
                            y: (timetext.height-height)/2
                            color: "white"
                            text: "Time before switching to next image:"
                        }

                        PQSpinBox {

                            id: timetext

                            height: 30

                            from: 1
                            to: 300

                            value: PQSettings.slideShowTime
                            onValueChanged: PQSettings.slideShowTime = value

                            suffix: "s"

                        }

                    }
                }

                Item {

                    id: transitionitem

                    x: 10
                    width: parent.width-2*x
                    height: childrenRect.height

                    Row {

                        spacing: 10

                        Text {
                            y: (transition.height-height)/2
                            color: "white"
                            text: "Transition speed:"
                        }

                        Column {

                            PQSlider {

                                id: transition

                                width: 200

                                from: 0
                                to: 15

                                handleToolTipEnabled: false

                                value: 15-PQSettings.slideShowImageTransition
                                onValueChanged: PQSettings.slideShowImageTransition = 15-value

                            }

                            Text {
                                color: "white"
                                text: "Current speed: <b>" +
                                          (transition.value == 15 ?
                                              "immediately, without animation" :
                                              (transition.value > 9 ?
                                                   "pretty fast animation" :
                                                   (transition.value > 4 ?
                                                        "not too fast and not too slow" :
                                                        "very slow animation"))) + "</b>"
                            }

                        }

                    }

                }

                PQCheckbox {
                    id: loopcheck
                    text: "Loop over images"
                    checked: PQSettings.slideShowLoop
                    onCheckedChanged: PQSettings.slideShowLoop = checked
                }

                PQCheckbox {
                    id: shufflecheck
                    text: "Shuffle images"
                    checked: PQSettings.slideShowShuffle
                    onCheckedChanged: PQSettings.slideShowShuffle = checked
                }

                PQCheckbox {
                    id: quickcheck
                    text: "Hide Quickinfo"
                    checked: PQSettings.slideShowHideQuickInfo
                    onCheckedChanged: PQSettings.slideShowHideQuickInfo = checked
                }

                Row {

                    PQCheckbox {
                        id: music_check
                        y: (music_button.height-height)/2
                        text: "Enable Music"
                        checked: PQSettings.slideShowMusicFile!=""
                    }

                    Column {

                        spacing: 10

                        PQButton {
                            id: music_button
                            height: 25
                            text: "Select music file"
                            enabled: music_check.checked
                            onClicked: {
                                selectmusicfile.visible = true
                            }
                        }

                        Text {
                            color: music_check.checked ? "#ffffff" : "#888888"
                            width: insidecont.width-music_check.width
                            wrapMode: Text.WordWrap
                            text: "Currently selected file: <b>" + (selectmusicfile.prevSelectedFile=="" ? "---" : selectmusicfile.prevSelectedFile) + "</b>"
                        }

                    }

                    FileDialog {
                        id: selectmusicfile
                        nameFilters: ["Music files (*.mp3 *.flac *.wav *.acc *.ogg *.wma)", "All Files (*)"]
                        selectExisting: true
                        selectMultiple: false
                        visible: false
                        title: "Select music file"
                        folder: shortcuts.music
                        property string prevSelectedFile: PQSettings.slideShowMusicFile
                        onPrevSelectedFileChanged: PQSettings.slideShowMusicFile = prevSelectedFile
                        onAccepted: {
                            var fn = handlingFileDialog.cleanPath(fileUrl)
                            if(fn != "")
                                prevSelectedFile = fn
                        }
                    }

                }


            }

        }

        Item {

            id: butcont

            x: 0
            y: insidecont.height-10-childrenRect.height
            width: insidecont.width
            height: childrenRect.height

            Row {

                spacing: 5

                x: (parent.width-width)/2

                PQButton {
                    id: button_start
                    text: "Start slideshow"
                    onClicked: {
                        if(!music_check.checked) {
                            PQSettings.slideShowMusicFile = ""
                            selectmusicfile.prevSelectedFile = ""
                        }
                        if(PQSettings.slideShowSettingsPopoutElement) {
                            slideshow_window.visible = false
                        } else {
                            slideshowsettings_top.opacity = 0
                            variables.visibleItem = ""
                        }
                        // start slideshow
                    }
                }
                PQButton {
                    id: button_cancel
                    text: "Cancel"
                    onClicked: {
                        if(!music_check.checked) {
                            PQSettings.slideShowMusicFile = ""
                            selectmusicfile.prevSelectedFile = ""
                        }
                        if(PQSettings.slideShowSettingsPopoutElement) {
                            slideshow_window.visible = false
                        } else {
                            slideshowsettings_top.opacity = 0
                            variables.visibleItem = ""
                        }
                    }
                }

            }

        }


    }

    Connections {
        target: loader
        onSlideshowPassOn: {
            if(what == "show") {
                if(PQSettings.slideShowSettingsPopoutElement) {
                    slideshow_window.visible = true
                } else {
                    if(variables.indexOfCurrentImage == -1)
                        return
                    opacity = 1
                    variables.visibleItem = "slideshowsettings"
                }
            } else if(what == "hide") {
                button_cancel.clicked()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    button_cancel.clicked()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    button_start.clicked()
            }
        }
    }

    Shortcut {
        sequence: "Esc"
        enabled: PQSettings.slideShowSettingsPopoutElement
        onActivated: button_cancel.clicked()
    }

    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: PQSettings.slideShowSettingsPopoutElement
        onActivated: button_start.clicked()
    }

}
