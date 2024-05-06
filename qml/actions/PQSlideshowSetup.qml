/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls

import PQCScriptsFilesPaths
import PQCFileFolderModel
import PQCWindowGeometry

import "../elements"

PQTemplateFullscreen {

    id: slideshowsettings_top

    thisis: "slideshowsetup"
    popout: PQCSettings.interfacePopoutSlideshowSetup
    forcePopout: PQCWindowGeometry.slideshowsetupForcePopout
    shortcut: "__slideshow"
    title: qsTranslate("slideshow", "Slideshow setup") + " | PhotoQt"

    //: Written on a clickable button
    button1.text: qsTranslate("slideshow", "Start slideshow")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQCSettings.interfacePopoutSlideshowSetup = popout

    button1.onClicked:
        startSlideshow()

    button2.onClicked:
        hide()

    property int leftcolwidth: 100

    property var musicfiles: []

    content: [

        Row {

            id: contentrow

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: interval_txt
                font.weight: PQCLook.fontWeightBold
                //: The interval between images in a slideshow
                text: qsTranslate("slideshow", "interval") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQSliderSpinBox {
                id: interval_slider
                y: (interval_txt.height-height)/2
                minval: 1
                maxval: 300
                suffix: " s"
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: animtype_txt
                y: (animtype_combo.height-height)/2
                font.weight: PQCLook.fontWeightBold
                //: This is referring to the in/out animation of images during a slideshow
                text: qsTranslate("slideshow", "animation") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQComboBox {
                id: animtype_combo
                        //: A special slideshow effect: https://en.wikipedia.org/wiki/Ken_Burns_effect
                model: [qsTranslate("slideshow", "Ken Burns effect"),
                        //: This is referring to the in/out animation of images during slideshows
                        qsTranslate("slideshow", "opacity"),
                        //: This is referring to the in/out animation of images during slideshows
                        qsTranslate("slideshow", "along x-axis"),
                        //: This is referring to the in/out animation of images during slideshows
                        qsTranslate("slideshow", "along y-axis"),
                        //: This is referring to the in/out animation of images
                        qsTranslate("slideshow", "rotation"),
                        //: This is referring to the in/out animation of images
                        qsTranslate("slideshow", "explosion"),
                        //: This is referring to the in/out animation of images
                        qsTranslate("slideshow", "implosion"),
                        //: This is referring to the in/out animation of images
                        qsTranslate("slideshow", "choose one at random")]
                lineBelowItem: [0,6]
            }

        },


        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: trans_txt
                verticalAlignment: Text.AlignTop
                font.weight: PQCLook.fontWeightBold
                //: The speed of transitioning from one image to another during slideshows
                text: qsTranslate("slideshow", "animation speed") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            Column {

                spacing: 10

                Row {

                    PQText {
                        //: Used as in: slow animation
                        text: qsTranslate("slideshow", "slow")
                    }

                    PQSlider {
                        id: transition_slider
                        height: trans_txt.height
                        from: 1
                        to: 15
                        tooltip: ""
                        extraSmall: true

                        onValueChanged: {
                            if(value > 14)
                                //: This refers to a speed of transitioning from one image to another during slideshows
                                transspeed_txt.speed = qsTranslate("slideshow", "immediately, without animation")
                            else if(value > 9)
                                //: This refers to a speed of transitioning from one image to another during slideshows
                                transspeed_txt.speed = qsTranslate("slideshow", "pretty fast animation")
                            else if(value > 4)
                                //: This refers to a speed of transitioning from one image to another during slideshows
                                transspeed_txt.speed = qsTranslate("slideshow", "not too fast and not too slow")
                            else
                                //: This refers to a speed of transitioning from one image to another during slideshows
                                transspeed_txt.speed = qsTranslate("slideshow", "very slow animation")

                        }
                    }

                    PQText {
                        //: Used as in: fast animation
                        text: qsTranslate("slideshow", "fast")
                    }

                }

                PQText {
                    id: transspeed_txt
                    property string speed: ""
                    //: This refers to the currently set speed of transitioning from one image to another during slideshows
                    text: qsTranslate("slideshow", "current speed") + ": <b>" + speed + "</b>"
                }

            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: loop_txt
                font.weight: PQCLook.fontWeightBold
                text: qsTranslate("slideshow", "looping") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckBox {
                id: loop_check
                y: (loop_txt.height-height)/2
                //: Loop over all images during slideshows
                text: qsTranslate("slideshow", "loop over all files")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: shuffle_txt
                font.weight: PQCLook.fontWeightBold
                //: during slideshows shuffle the order of all images
                text: qsTranslate("slideshow", "shuffle") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckBox {
                id: shuffle_check
                y: (shuffle_txt.height-height)/2
                //: during slideshows shuffle the order of all images
                text: qsTranslate("slideshow", "shuffle all files")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: subfolders_txt
                font.weight: PQCLook.fontWeightBold
                //: also include images in subfolders during slideshows
                text: qsTranslate("slideshow", "subfolders") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckBox {
                id: subfolders_check
                y: (shuffle_txt.height-height)/2
                //: also include images in subfolders during slideshows
                text: qsTranslate("slideshow", "include images in subfolders")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: quick_txt
                verticalAlignment: Text.AlignTop
                font.weight: PQCLook.fontWeightBold
                //: What to do with the file details during slideshows
                text: qsTranslate("slideshow", "status info") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckBox {
                id: quick_check
                y: (quick_txt.height-height)/2
                //: What to do with the file details during slideshows
                text: qsTranslate("slideshow", "hide status info during slideshow")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: winbut_txt
                verticalAlignment: Text.AlignTop
                font.weight: PQCLook.fontWeightBold
                //: What to do with the window buttons during slideshows
                text: qsTranslate("slideshow", "window buttons") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckBox {
                id: winbut_check
                y: (winbut_txt.height-height)/2
                //: What to do with the window buttons during slideshows
                text: qsTranslate("slideshow", "hide window buttons during slideshow")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: music_txt
                verticalAlignment: Text.AlignTop
                font.weight: PQCLook.fontWeightBold
                //: The music that is to be played during slideshows
                text: qsTranslate("slideshow", "music") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            Column {

                spacing: 10

                PQCheckBox {
                    id: music_check
                    height: music_txt.height
                    //: Enable music to be played during slideshows
                    text: qsTranslate("slideshow", "enable music")
                }

                Column {

                    id: musicont

                    spacing: 5

                    height: music_check.checked ? music_volumevideos.height+filescont.height+filesbut.height+music_shuffle.height+3*10 : 0
                    opacity: music_check.checked ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    clip: true

                    Row {

                        spacing: 5

                        Item {
                            width: 30
                            height: 30
                        }

                        Flow {

                            width: slideshowsettings_top.width-leftcolwidth - contentrow.x - contentrow.spacing-10
                            spacing: 5

                            PQText {
                                height: music_volumevideos.height
                                verticalAlignment: Text.AlignVCenter
                                //: some options as to what will happen with the music volume while videos are playing
                                text: qsTranslate("settingsmanager", "music volume during videos with audio:")
                            }

                            PQComboBox {
                                id: music_volumevideos
                                model: [qsTranslate("settingsmanager", "mute"),
                                        qsTranslate("settingsmanager", "lower"),
                                        qsTranslate("settingsmanager", "leave unchanged")]
                            }
                        }
                    }

                    Rectangle {

                        id: filescont

                        color: "transparent"
                        border.width: 2
                        border.color: PQCLook.baseColorHighlight

                        width: Math.min(500, slideshowsettings_top.width-leftcolwidth - contentrow.x - contentrow.spacing-10)
                        height: 200

                        PQTextL {
                            x: 10
                            y: (parent.height-height)/2
                            width: parent.width-20
                            opacity: slideshowsettings_top.musicfiles.length===0 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            font.weight: PQCLook.fontWeightBold
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            enabled: false
                            text: qsTranslate("settingsmanager", "No music files selected")
                        }

                        ListView {

                            id: music_view

                            model: slideshowsettings_top.musicfiles.length

                            x: 5
                            y: 5
                            width: parent.width-10
                            height: parent.height-10
                            orientation: Qt.Vertical
                            spacing: 5
                            clip: true

                            ScrollBar.vertical: PQVerticalScrollBar { id: music_scroll }

                            delegate:
                                Rectangle {

                                    id: musicdeleg

                                    property string fname: PQCScriptsFilesPaths.getBasename(slideshowsettings_top.musicfiles[index])
                                    property string fpath: PQCScriptsFilesPaths.getDir(slideshowsettings_top.musicfiles[index])

                                    width: music_view.width-(music_scroll.visible ? music_scroll.width : 0)
                                    height: 40
                                    color: PQCLook.baseColorHighlight

                                    Column {
                                        x: 5
                                        y: (parent.height-height)/2
                                        width: parent.width-10
                                        PQText {
                                            width: parent.width-musicbutrow.width
                                            elide: Text.ElideMiddle
                                            text: musicdeleg.fname
                                        }
                                        PQTextS {
                                            width: parent.width-musicbutrow.width
                                            elide: Text.ElideMiddle
                                            text: musicdeleg.fpath
                                        }
                                    }

                                    Row {
                                        id: musicbutrow
                                        x: parent.width-width
                                        visible: width>0
                                        width: slideshowsettings_top.width-1.5*leftcolwidth > 300 ? 120 : 0
                                        Behavior on width { NumberAnimation { duration: 200 } }
                                        height: 40
                                        PQButtonIcon {
                                            width: 40
                                            height: 40
                                            iconScale: 0.5
                                            radius: 0
                                            enabled: index>0
                                            source: "image://svg/:/white/upwards.svg"
                                            //: This relates to the list of music files for slideshows
                                            tooltip: qsTranslate("settingsmanager", "Move file up one position")
                                            onClicked: {
                                                slideshowsettings_top.musicfiles.splice(index-1, 0, slideshowsettings_top.musicfiles.splice(index, 1)[0])
                                                slideshowsettings_top.musicfilesChanged()
                                            }
                                        }
                                        PQButtonIcon {
                                            width: 40
                                            height: 40
                                            rotation: 180
                                            iconScale: 0.5
                                            radius: 0
                                            enabled: index < music_view.model-1
                                            source: "image://svg/:/white/upwards.svg"
                                            //: This relates to the list of music files for slideshows
                                            tooltip: qsTranslate("settingsmanager", "Move file down one position")
                                            onClicked: {
                                                slideshowsettings_top.musicfiles.splice(index+1, 0, slideshowsettings_top.musicfiles.splice(index, 1)[0])
                                                slideshowsettings_top.musicfilesChanged()
                                            }
                                        }
                                        PQButtonIcon {
                                            width: 40
                                            height: 40
                                            iconScale: 0.35
                                            radius: 0
                                            source: "image://svg/:/white/x.svg"
                                            //: This relates to the list of music files for slideshows
                                            tooltip: qsTranslate("settingsmanager", "Delete this file from the list")
                                            onClicked: {
                                                slideshowsettings_top.musicfiles.splice(index, 1)
                                                slideshowsettings_top.musicfilesChanged()
                                            }
                                        }
                                    }

                                }

                        }

                    }

                    PQButton {
                        id: filesbut
                        text: qsTranslate("settingsmanager", "Add music files")
                        onClicked: {
                            var fnames = PQCScriptsFilesPaths.openFilesFromDialog("Select",
                                                                                  (slideshowsettings_top.musicfiles.length===0 ?
                                                                                       PQCScriptsFilesPaths.getHomeDir() :
                                                                                       PQCScriptsFilesPaths.getDir(slideshowsettings_top.musicfiles[slideshowsettings_top.musicfiles.length-1])),
                                                                                  ["aac", "flac", "mp3", "ogg", "oga", "wav", "wma"]);
                            if(fnames.length > 0) {
                                slideshowsettings_top.musicfiles = slideshowsettings_top.musicfiles.concat(fnames)
                                slideshowsettings_top.musicfilesChanged()
                            }
                        }
                    }

                    PQCheckBox {
                        id: music_shuffle
                        text: qsTranslate("settingsmanager", "shuffle order")
                    }

                }

            }

        }

    ]

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(slideshowsettings_top.visible) {

                if(what === "keyEvent") {
                    if(param[0] === Qt.Key_Escape)
                        hide()
                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        startSlideshow()
                }

            }
        }
    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }

        opacity = 1
        if(popoutWindowUsed)
            slideshowsetup_popout.visible = true

        var animArray = ["kenburns", "opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        animtype_combo.currentIndex = animArray.indexOf(PQCSettings.slideshowTypeAnimation)
        if(animtype_combo.currentIndex === -1) animtype_combo.currentIndex = 0

        interval_slider.loadAndSetDefault(PQCSettings.slideshowTime)
        transition_slider.loadAndSetDefault(PQCSettings.slideshowImageTransition)
        loop_check.loadAndSetDefault(PQCSettings.slideshowLoop)
        shuffle_check.loadAndSetDefault(PQCSettings.slideshowShuffle)
        winbut_check.loadAndSetDefault(PQCSettings.slideshowHideWindowButtons)
        quick_check.loadAndSetDefault(PQCSettings.slideshowHideLabels)
        music_check.loadAndSetDefault((PQCSettings.slideshowMusicFile!==""))
        subfolders_check.loadAndSetDefault(PQCSettings.slideshowIncludeSubFolders)

        music_check.loadAndSetDefault(PQCSettings.slideshowMusic)
        music_volumevideos.loadAndSetDefault(PQCSettings.slideshowMusicVolumeVideos)
        music_shuffle.loadAndSetDefault(PQCSettings.slideshowMusicShuffle)

        var tmp = []
        for(var i in PQCSettings.slideshowMusicFiles) {
            if(PQCScriptsFilesPaths.doesItExist(PQCSettings.slideshowMusicFiles[i]))
                tmp.push(PQCSettings.slideshowMusicFiles[i])
        }
        slideshowsettings_top.musicfiles = tmp

    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            slideshowsetup_popout.visible = false
        loader.elementClosed(thisis)
    }

    function startSlideshow() {

        var animArray = ["kenburns", "opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQCSettings.slideshowTypeAnimation = animArray[animtype_combo.currentIndex]

        PQCSettings.slideshowTime = interval_slider.value
        PQCSettings.slideshowImageTransition = transition_slider.value
        PQCSettings.slideshowLoop = loop_check.checked
        PQCSettings.slideshowShuffle = shuffle_check.checked
        PQCSettings.slideshowHideWindowButtons = winbut_check.checked
        PQCSettings.slideshowHideLabels = quick_check.checked
        PQCSettings.slideshowIncludeSubFolders = subfolders_check.checked

        PQCSettings.slideshowMusic = music_check.checked
        PQCSettings.slideshowMusicVolumeVideos = music_volumevideos.currentIndex
        PQCSettings.slideshowMusicShuffle = music_shuffle.checked
        PQCSettings.slideshowMusicFiles = slideshowsettings_top.musicfiles

        hide()
        loader.show("slideshowhandler")
        loader.show("slideshowcontrols")

    }

}
