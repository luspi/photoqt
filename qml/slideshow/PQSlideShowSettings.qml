import QtQuick 2.9
import Qt.labs.platform 1.0
import QtGraphicalEffects 1.0

import "../elements"

Item {

    id: slideshowsettings_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: PQSettings.slideShowSettingsPopoutElement ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.slideShowSettingsPopoutElement ? 0 : PQSettings.animationDuration*100 } }
    visible: opacity!=0

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.slideShowSettingsPopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#cc000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Text {
            id: heading
            x: 0
            y: 25
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: em.pty+qsTranslate("slideshow", "Slideshow settings")
            font.pointSize: 25
            font.bold: true
            color: "white"
        }

        Rectangle {
            id: sep_top
            color: "white"
            x: 0
            y: heading.y+heading.height+25
            width: parent.width
            height: 1
        }

        Flickable {
            id: flickable
            anchors {
                top: sep_top.bottom
                bottom: sep_bot.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            clip: true
            contentHeight: col.height

            Column {

                id: col

                spacing: 25

                property int leftcolwidth: 8*width/17

                width: parent.width

                Item {
                    width: 1
                    height: PQSettings.slideShowSettingsPopoutElement ? 0 : 20
                }

                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: interval_txt
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "interval:"
                    }

                    PQSlider {
                        id: interval_slider
                        y: (interval_txt.height-height)/2
                        from: 1
                        to: 300
                        toolTipSuffix: "s"
                    }

                    Text {
                        y: (interval_txt.height-height)/2
                        color: "white"
                        text: interval_slider.value+"s"
                    }

                }

                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: animtype_txt
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "animation:"
                    }

                    PQComboBox {
                        id: animtype_combo
                        model: ["opacity", "along x-axis", "along y-axis"]
                    }

                }


                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: trans_txt
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "animation speed:"
                    }

                    Column {

                        spacing: 10

                        PQSlider {
                            id: transition_slider
                            height: trans_txt.height
                            from: 0
                            to: 15
                            tooltip: (value == 15 ?
                                         "immediately, without animation" :
                                         (value > 9 ?
                                              "pretty fast animation" :
                                              (value > 4 ?
                                                   "not too fast and not too slow" :
                                                   "very slow animation")))
                        }

                        Text {
                            id: transspeed_txt
                            color: "white"
                            text: "current speed: <b>" + transition_slider.tooltip + "</b>"
                        }

                    }

                }

                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: loop_txt
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "looping"
                    }

                    PQCheckbox {
                        id: loop_check
                        y: (loop_txt.height-height)/2
                        text: "loop over all files"
                    }

                }

                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: shuffle_txt
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "shuffle:"
                    }

                    PQCheckbox {
                        id: shuffle_check
                        y: (shuffle_txt.height-height)/2
                        text: "shuffle all files"
                    }

                }

                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: quick_txt
                        y: (loop_txt-height)/2
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "quickinfo:"
                    }

                    PQCheckbox {
                        id: quick_check
                        y: (quick_txt.height-height)/2
                        text: "hide quickinfo"
                    }

                }

                Row {

                    spacing: 15

                    width: parent.width
                    height: childrenRect.height

                    Text {
                        id: music_txt
                        width: col.leftcolwidth
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "music:"
                    }

                    Column {

                        spacing: 10

                        PQCheckbox {
                            id: music_check
                            height: music_txt.height
                            text: "enable music"
                        }

                        PQButton {
                            id: music_button
                            enabled: music_check.checked
                            property string musicfile: ""
                            text: musicfile=="" ? "[no file selected]" : handlingGeneral.getFileNameFromFullPath(musicfile)
                            tooltip: (musicfile=="" ? "Click to select music file" : ("<b>"+musicfile+"</b><br><br>Click to change music file"))
                            onClicked: {
                                fileDialog.visible = true
                            }
                        }

                        FileDialog {
                            id: fileDialog
                            currentFile: music_button.musicfile=="" ? "" : music_button.musicfile
                            folder: (music_button.musicfile == "" ? "file://"+handlingFileDialog.getHomeDir() : "file://"+handlingGeneral.getFilePathFromFullPath(music_button.musicfile))
                            modality: Qt.ApplicationModal
                            nameFilters: ["Common music formats (aac *.flac *.mp3 *.ogg *.oga *.wav *.wma)", "All Files (*.*)"]
                            onAccepted: {
                                if(fileDialog.file != "")
                                    music_button.musicfile = handlingFileDialog.cleanPath(fileDialog.file)
                            }
                        }

                    }

                }

            }

        }

        Rectangle {
            id: sep_bot
            color: "white"
            x: 0
            y: button_row.y-10
            width: parent.width
            height: 1
        }


        Row {

            id: button_row

            spacing: 5

            x: (parent.width-width)/2
            y: (parent.height-height)

            height: button_start.height+20

            PQButton {
                id: button_start
                y: 5
                //: Written on a clickable button
                text: em.pty+qsTranslate("slideshow", "Start slideshow")
                onClicked: {

                    PQSettings.slideShowTime = interval_slider.value
                    PQSettings.slideShowTypeAnimation = (animtype_combo.currentIndex==0 ? "opacity" : (animtype_combo.currentIndex==1 ? "x" : "y"))
                    PQSettings.slideShowImageTransition = transition_slider.value
                    PQSettings.slideShowLoop = loop_check.checked
                    PQSettings.slideShowShuffle = shuffle_check.checked
                    PQSettings.slideShowHideQuickInfo = quick_check.checked
                    PQSettings.slideShowMusicFile = (music_check.checked&&music_button.musicfile!="" ? music_button.musicfile : "")

                    if(PQSettings.slideShowSettingsPopoutElement) {
                        slideshow_window.visible = false
                    } else {
                        slideshowsettings_top.opacity = 0
                        variables.visibleItem = ""
                    }
                    loader.ensureItIsReady("slideshowcontrols")
                    loader.passOn("slideshowcontrols", "start", undefined)
                }
            }
            PQButton {
                id: button_cancel
                y: 5
                text: genericStringCancel
                onClicked: {
                    if(PQSettings.slideShowSettingsPopoutElement) {
                        slideshow_window.visible = false
                    } else {
                        slideshowsettings_top.opacity = 0
                        variables.visibleItem = ""
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

                    interval_slider.value = PQSettings.slideShowTime
                    animtype_combo.currentIndex = (PQSettings.slideShowTypeAnimation=="opacity" ? 0 : (PQSettings.slideShowTypeAnimation=="x" ? 1 : 2))
                    transition_slider.value = PQSettings.slideShowImageTransition
                    loop_check.checked = PQSettings.slideShowLoop
                    shuffle_check.checked = PQSettings.slideShowShuffle
                    quick_check.checked = PQSettings.slideShowHideQuickInfo
                    music_check.checked = (PQSettings.slideShowMusicFile!="")
                    music_button.musicfile = PQSettings.slideShowMusicFile

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

}
