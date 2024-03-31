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
    title: qsTranslate("slideshow", "Slideshow setup")

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

    content: [

        Row {

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
                //: This is referring to the in/out animation of images during slideshows
                model: [qsTranslate("slideshow", "opacity"),
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
                lineBelowItem: [5]
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
                        text: "slow"
                    }

                    PQSlider {
                        id: transition_slider
                        height: trans_txt.height
                        from: 0
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
                        text: "fast"
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

                Item {

                    clip: true
                    enabled: music_check.checked
                    width: music_button.width
                    height: enabled ? music_button.height : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQButton {
                        id: music_button
                        enabled: music_check.checked
                        font.pointSize: PQCLook.fontSize
                        font.weight: PQCLook.fontWeightNormal
                        width: 300
                        property string musicfile: ""
                        text: musicfile=="" ? "[" + qsTranslate("slideshow", "no file selected") + "]" : PQCScriptsFilesPaths.getFilename(musicfile)
                        tooltip: (musicfile==""
                                    ? qsTranslate("slideshow", "Click to select music file")
                                    : ("<b>"+musicfile+"</b><br><br>" + qsTranslate("slideshow", "Click to change music file")))
                        onClicked: {
                            var fname = PQCScriptsFilesPaths.openFileFromDialog("Select",
                                                                                (music_button.musicfile == "" ? PQCScriptsFilesPaths.getHomeDir() : music_button.musicfile),
                                                                                ["aac", "flac", "mp3", "ogg", "oga", "wav", "wma"]);
                            if(fname !== "")
                                music_button.musicfile = PQCScriptsFilesPaths.cleanPath(fname)
                        }
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
        if(popout)
            slideshowsetup_popout.show()

        var animArray = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQCSettings.slideshowTypeAnimation = animArray[animtype_combo.currentIndex]
        animtype_combo.currentIndex = animArray.indexOf(PQCSettings.slideshowTypeAnimation)
        if(animtype_combo.currentIndex === -1) animtype_combo.currentIndex = 0

        interval_slider.value = PQCSettings.slideshowTime
        transition_slider.value = PQCSettings.slideshowImageTransition
        loop_check.checked = PQCSettings.slideshowLoop
        shuffle_check.checked = PQCSettings.slideshowShuffle
        winbut_check.checked = PQCSettings.slideshowHideWindowButtons
        quick_check.checked = PQCSettings.slideshowHideLabels
        music_check.checked = (PQCSettings.slideshowMusicFile!=="")
        music_button.musicfile = PQCSettings.slideshowMusicFile
        subfolders_check.checked = PQCSettings.slideshowIncludeSubFolders

    }

    function hide() {
        opacity = 0
        loader.elementClosed(thisis)
    }

    function startSlideshow() {

        var animArray = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQCSettings.slideshowTypeAnimation = animArray[animtype_combo.currentIndex]

        PQCSettings.slideshowTime = interval_slider.value
        PQCSettings.slideshowImageTransition = transition_slider.value
        PQCSettings.slideshowLoop = loop_check.checked
        PQCSettings.slideshowShuffle = shuffle_check.checked
        PQCSettings.slideshowHideWindowButtons = winbut_check.checked
        PQCSettings.slideshowHideLabels = quick_check.checked
        PQCSettings.slideshowMusicFile = (music_check.checked&&music_button.musicfile!="" ? music_button.musicfile : "")
        PQCSettings.slideshowIncludeSubFolders = subfolders_check.checked

        hide()
        loader.show("slideshowhandler")
        loader.show("slideshowcontrols")

    }

}
