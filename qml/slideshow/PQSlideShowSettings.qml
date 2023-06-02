/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
import Qt.labs.platform 1.0
import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: slideshowsettings_top

    popout: PQSettings.interfacePopoutSlideShowSettings
    shortcut: "__slideshow"
    title: em.pty+qsTranslate("slideshow", "Slideshow settings")

    //: Written on a clickable button
    button1.text: em.pty+qsTranslate("slideshow", "Start slideshow")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutSlideShowSettings = popout

    button1.onClicked:
        startSlideshow()

    button2.onClicked:
        closeElement()

    property int leftcolwidth: 100

    content: [

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: interval_txt
                font.weight: baselook.boldweight
                //: The interval between images in a slideshow
                text: em.pty+qsTranslate("slideshow", "interval") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQSlider {
                id: interval_slider
                y: (interval_txt.height-height)/2
                from: 1
                to: 300
                toolTipSuffix: "s"
            }

            PQText {
                y: (interval_txt.height-height)/2
                text: interval_slider.value+"s"
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: animtype_txt
                font.weight: baselook.boldweight
                //: This is referring to the in/out animation of images during a slideshow
                text: em.pty+qsTranslate("slideshow", "animation") + ":"
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
                model: [em.pty+qsTranslate("slideshow", "opacity"),
                        //: This is referring to the in/out animation of images during slideshows
                        em.pty+qsTranslate("slideshow", "along x-axis"),
                        //: This is referring to the in/out animation of images during slideshows
                        em.pty+qsTranslate("slideshow", "along y-axis"),
                        //: This is referring to the in/out animation of images
                        em.pty+qsTranslate("slideshow", "rotation"),
                        //: This is referring to the in/out animation of images
                        em.pty+qsTranslate("slideshow", "explosion"),
                        //: This is referring to the in/out animation of images
                        em.pty+qsTranslate("slideshow", "implosion"),
                        //: This is referring to the in/out animation of images
                        em.pty+qsTranslate("slideshow", "choose one at random")]
                lineBelowItem: 5
            }

        },


        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: trans_txt
                verticalAlignment: Text.AlignTop
                font.weight: baselook.boldweight
                //: The speed of transitioning from one image to another during slideshows
                text: em.pty+qsTranslate("slideshow", "animation speed") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
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

                PQText {
                    id: transspeed_txt
                    //: This refers to the currently set speed of transitioning from one image to another during slideshows
                    text: em.pty+qsTranslate("slideshow", "current speed") + ": <b>" + transition_slider.tooltip + "</b>"
                }

            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: loop_txt
                font.weight: baselook.boldweight
                text: em.pty+qsTranslate("slideshow", "looping") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckbox {
                id: loop_check
                y: (loop_txt.height-height)/2
                //: Loop over all images during slideshows
                text: em.pty+qsTranslate("slideshow", "loop over all files")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: shuffle_txt
                font.weight: baselook.boldweight
                //: during slideshows shuffle the order of all images
                text: em.pty+qsTranslate("slideshow", "shuffle") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckbox {
                id: shuffle_check
                y: (shuffle_txt.height-height)/2
                //: during slideshows shuffle the order of all images
                text: em.pty+qsTranslate("slideshow", "shuffle all files")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: subfolders_txt
                font.weight: baselook.boldweight
                //: also include images in subfolders during slideshows
                text: em.pty+qsTranslate("slideshow", "subfolders") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckbox {
                id: subfolders_check
                y: (shuffle_txt.height-height)/2
                //: also include images in subfolders during slideshows
                text: em.pty+qsTranslate("slideshow", "include images in subfolders")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: quick_txt
                verticalAlignment: Text.AlignTop
                font.weight: baselook.boldweight
                //: What to do with the file details during slideshows
                text: em.pty+qsTranslate("slideshow", "file info") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckbox {
                id: quick_check
                y: (quick_txt.height-height)/2
                //: What to do with the file details during slideshows
                text: em.pty+qsTranslate("slideshow", "hide label with details about current file")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: winbut_txt
                verticalAlignment: Text.AlignTop
                font.weight: baselook.boldweight
                //: What to do with the window buttons during slideshows
                text: em.pty+qsTranslate("slideshow", "window buttons") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
                }
            }

            PQCheckbox {
                id: winbut_check
                y: (winbut_txt.height-height)/2
                //: What to do with the window buttons during slideshows
                text: em.pty+qsTranslate("slideshow", "hide window buttons during slideshow")
            }

        },

        Row {

            spacing: 15

            x: parent.width/2 - 1.5*leftcolwidth
            height: childrenRect.height

            PQTextL {
                id: music_txt
                verticalAlignment: Text.AlignTop
                font.weight: baselook.boldweight
                //: The music that is to be played during slideshows
                text: em.pty+qsTranslate("slideshow", "music") + ":"
                horizontalAlignment: Text.AlignRight
                Component.onCompleted: {
                    if(width > leftcolwidth)
                        leftcolwidth = width
                    width = Qt.binding(function() { return leftcolwidth; })
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
                    text: musicfile=="" ? "[" + em.pty+qsTranslate("slideshow", "no file selected") + "]" : handlingFileDir.getFileNameFromFullPath(musicfile)
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
                    folder: (music_button.musicfile == "" ? "file:///"+handlingFileDir.getHomeDir() : "file:///"+handlingFileDir.getFilePathFromFullPath(music_button.musicfile))
                    modality: Qt.ApplicationModal
                    nameFilters: [em.pty+qsTranslate("slideshow", "Common music file formats") + " (aac *.flac *.mp3 *.ogg *.oga *.wav *.wma)",
                                  em.pty+qsTranslate("slideshow", "All Files") + " (*.*)"]
                    onAccepted: {
                        if(fileDialog.file != "")
                            music_button.musicfile = handlingFileDir.cleanPath(fileDialog.file)
                    }
                }

            }

        }

    ]

    Connections {
        target: loader
        onSlideshowPassOn: {
            if(what == "show") {
                if(filefoldermodel.current == -1)
                    return
                opacity = 1
                variables.visibleItem = "slideshowsettings"

                var animArray = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
                PQSettings.slideshowTypeAnimation = animArray[animtype_combo.currentIndex]
                animtype_combo.currentIndex = animArray.indexOf(PQSettings.slideshowTypeAnimation)
                if(animtype_combo.currentIndex == -1) animtype_combo.currentIndex = 0

                interval_slider.value = PQSettings.slideshowTime
                transition_slider.value = PQSettings.slideshowImageTransition
                loop_check.checked = PQSettings.slideshowLoop
                shuffle_check.checked = PQSettings.slideshowShuffle
                winbut_check.checked = PQSettings.slideshowHideWindowButtons
                quick_check.checked = PQSettings.slideshowHideLabels
                music_check.checked = (PQSettings.slideshowMusicFile!="")
                music_button.musicfile = PQSettings.slideshowMusicFile
                subfolders_check.checked = PQSettings.slideshowIncludeSubFolders

            } else if(what == "hide") {
                closeElement()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    closeElement()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    startSlideshow()
            }
        }
    }

    function startSlideshow() {

        var animArray = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQSettings.slideshowTypeAnimation = animArray[animtype_combo.currentIndex]

        PQSettings.slideshowTime = interval_slider.value
        PQSettings.slideshowImageTransition = transition_slider.value
        PQSettings.slideshowLoop = loop_check.checked
        PQSettings.slideshowShuffle = shuffle_check.checked
        PQSettings.slideshowHideWindowButtons = winbut_check.checked
        PQSettings.slideshowHideLabels = quick_check.checked
        PQSettings.slideshowMusicFile = (music_check.checked&&music_button.musicfile!="" ? music_button.musicfile : "")
        PQSettings.slideshowIncludeSubFolders = subfolders_check.checked

        closeElement()
        loader.ensureItIsReady("slideshowcontrols")
        loader.passOn("slideshowcontrols", "start", undefined)

    }

    function closeElement() {
        slideshowsettings_top.opacity = 0
        variables.visibleItem = ""
    }

}
