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
    enabled: visible

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
            y: insidecont.y-height
            width: parent.width
            text: em.pty+qsTranslate("slideshow", "Slideshow settings")
            font.pointSize: 25
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: childrenRect.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                id: col

                property int leftcolwidth: 100

                spacing: 15

                Item {
                    width: 1
                    height: 20
                }

                Row {

                    spacing: 15

                    height: childrenRect.height

                    Text {
                        id: interval_txt
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        //: The interval between images in a slideshow
                        text: em.pty+qsTranslate("slideshow", "interval") + ":"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
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

                    height: childrenRect.height

                    Text {
                        id: animtype_txt
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: "animation:"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    PQComboBox {
                        id: animtype_combo
                        //: This is referring to the in/out animation of images during slideshows
                        model: [em.pty+qsTranslate("slideshow", "opacity"),
                                //: This is referring to the in/out animation of images during slideshows
                                em.pty+qsTranslate("slideshow", "along x-axis"),
                                //: This is referring to the in/out animation of images during slideshows
                                em.pty+qsTranslate("slideshow", "along y-axis")]
                    }

                }


                Row {

                    spacing: 15

                    height: childrenRect.height

                    Text {
                        id: trans_txt
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        //: The speed of transitioning from one image to another during slideshows
                        text: em.pty+qsTranslate("slideshow", "animation speed") + ":"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    Column {

                        spacing: 10

                        PQSlider {
                            id: transition_slider
                            height: trans_txt.height
                            from: 0
                            to: 15
                            tooltip: (value == 15 ?
                                         //: This refers to a speed of transitioning from one image to another during slideshows
                                         em.pty+qsTranslate("slideshow", "immediately, without animation") :
                                         (value > 9 ?
                                              //: This refers to a speed of transitioning from one image to another during slideshows
                                              em.pty+qsTranslate("slideshow", "pretty fast animation") :
                                              (value > 4 ?
                                                   //: This refers to a speed of transitioning from one image to another during slideshows
                                                   em.pty+qsTranslate("slideshow", "not too fast and not too slow") :
                                                   //: This refers to a speed of transitioning from one image to another during slideshows
                                                   em.pty+qsTranslate("slideshow", "very slow animation"))))
                        }

                        Text {
                            id: transspeed_txt
                            color: "white"
                            //: This refers to the currently set speed of transitioning from one image to another during slideshows
                            text: em.pty+qsTranslate("slideshow", "current speed") + ": <b>" + transition_slider.tooltip + "</b>"
                        }

                    }

                }





                Row {

                    spacing: 15

                    height: childrenRect.height

                    Text {
                        id: loop_txt
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        text: em.pty+qsTranslate("slideshow", "looping") + ":"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    PQCheckbox {
                        id: loop_check
                        y: (loop_txt.height-height)/2
                        //: Loop over all images during slideshows
                        text: em.pty+qsTranslate("slideshow", "loop over all files")
                    }

                }

                Row {

                    spacing: 15

                    height: childrenRect.height

                    Text {
                        id: shuffle_txt
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        //: during slideshows shuffle the order of all images
                        text: em.pty+qsTranslate("slideshow", "shuffle") + ":"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    PQCheckbox {
                        id: shuffle_check
                        y: (shuffle_txt.height-height)/2
                        //: during slideshows shuffle the order of all images
                        text: em.pty+qsTranslate("slideshow", "shuffle all files")
                    }

                }

                Row {

                    spacing: 15

                    height: childrenRect.height

                    Text {
                        id: quick_txt
                        y: (loop_txt-height)/2
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        //: What to do with the quick info during slideshows
                        text: em.pty+qsTranslate("slideshow", "quickinfo") + ":"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    PQCheckbox {
                        id: quick_check
                        y: (quick_txt.height-height)/2
                        //: What to do with the quick info during slideshows
                        text: em.pty+qsTranslate("slideshow", "hide quickinfo")
                    }

                }

                Row {

                    spacing: 15

                    height: childrenRect.height

                    Text {
                        id: music_txt
                        verticalAlignment: Text.AlignTop
                        color: "white"
                        font.pointSize: 15
                        font.bold: true
                        //: The music that is to be played during slideshows
                        text: em.pty+qsTranslate("slideshow", "music") + ":"
                        horizontalAlignment: Text.AlignRight
                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    Column {

                        spacing: 10

                        PQCheckbox {
                            id: music_check
                            height: music_txt.height
                            //: Enable music to be played during slideshows
                            text: em.pty+qsTranslate("slideshow", "enable music")
                        }

                        PQButton {
                            id: music_button
                            enabled: music_check.checked
                            property string musicfile: ""
                            text: musicfile=="" ? "[" + em.pty+qsTranslate("slideshow", "no file selected") + "]" : handlingGeneral.getFileNameFromFullPath(musicfile)
                            tooltip: (musicfile==""
                                        ? em.pty+qsTranslate("slideshow", "Click to select music file")
                                        : ("<b>"+musicfile+"</b><br><br>" + em.pty+qsTranslate("slideshow", "Click to change music file")))
                            onClicked: {
                                fileDialog.visible = true
                            }
                        }

                        FileDialog {
                            id: fileDialog
                            currentFile: music_button.musicfile=="" ? "" : music_button.musicfile
                            folder: (music_button.musicfile == "" ? "file://"+handlingFileDialog.getHomeDir() : "file://"+handlingGeneral.getFilePathFromFullPath(music_button.musicfile))
                            modality: Qt.ApplicationModal
                            nameFilters: [em.pty+qsTranslate("slideshow", "Common music file formats") + " (aac *.flac *.mp3 *.ogg *.oga *.wav *.wma)",
                                          em.pty+qsTranslate("slideshow", "All Files") + " (*.*)"]
                            onAccepted: {
                                if(fileDialog.file != "")
                                    music_button.musicfile = handlingFileDialog.cleanPath(fileDialog.file)
                            }
                        }

                    }

                }

                Item {
                    width: 1
                    height: 5
                }

            }

        }

        Row {

            id: button_row

            spacing: 5

            y: insidecont.y+insidecont.height
            x: (parent.width-width)/2

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
