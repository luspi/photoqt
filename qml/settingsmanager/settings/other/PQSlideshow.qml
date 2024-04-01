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
import PQCNotify
import PQCScriptsFilesPaths

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false
    property bool settingsLoaded: false

    Column {

        id: contcol

        width: parent.width
        spacing: 10

        PQText {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager", "These settings can also be adjusted when setting up a slideshow.")
        }

        Item {
            width: 1
            height: 1
        }

        PQSetting {

            id: set_ani

            //: Settings title
            title: qsTranslate("settingsmanager", "Animation")

            helptext: qsTranslate("settingsmanager", "The animation for switching images can be customized for slideshows.")

            content: [

                PQCheckBox {
                    id: anim_check
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "Enable animations")
                    onCheckedChanged:
                        checkDefault()
                },

                Column {

                    spacing: 15

                    enabled: anim_check.checked
                    clip: true

                    height: enabled ? (anirow1.height+anirow2.height+transspeed_txt.height+2*spacing) : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Flow {
                        id: anirow1
                        width: set_ani.rightcol
                        spacing: 5
                        PQText {
                            height: anicombo.height
                            verticalAlignment: Text.AlignVCenter
                            text: qsTranslate("settingsmanager", "Animation:")
                        }
                        PQComboBox {
                            id: anicombo
                                    //: This is referring to an in/out animation of images
                            model: [qsTranslate("settingsmanager", "opacity"),
                                    //: This is referring to an in/out animation of images
                                    qsTranslate("settingsmanager", "along x-axis"),
                                    //: This is referring to an in/out animation of images
                                    qsTranslate("settingsmanager", "along y-axis"),
                                    //: This is referring to an in/out animation of images
                                    qsTranslate("settingsmanager", "rotation"),
                                    //: This is referring to an in/out animation of images
                                    qsTranslate("settingsmanager", "explosion"),
                                    //: This is referring to an in/out animation of images
                                    qsTranslate("settingsmanager", "implosion"),
                                    //: This is referring to an in/out animation of images
                                    qsTranslate("settingsmanager", "choose one at random")]
                            lineBelowItem: [5]
                            onCurrentIndexChanged: checkDefault()
                        }
                    }

                    Flow {

                        id: anirow2

                        width: set_ani.rightcol
                        spacing: 10

                        PQText {
                            //: Used as in: slow animation
                            text: qsTranslate("slideshow", "slow")
                        }

                        PQSlider {
                            id: anispeed
                            from: 0
                            to: 15

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
                        width: set_ani.rightcol
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        property string speed: ""
                        //: This refers to the currently set speed of transitioning from one image to another during slideshows
                        text: qsTranslate("slideshow", "current speed") + ": <b>" + speed + "</b>"
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Interval")

            helptext: qsTranslate("settingsmanager", "This determines how long PhotoQt waits before switching to the next image in the list.")

            content: [
                PQSliderSpinBox {
                    id: interval
                    width: set_ani.rightcol
                    minval: 1
                    maxval: 300
                    title: qsTranslate("settingsmanager", "interval:")
                    suffix: " s"
                    onValueChanged:
                        checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Loop")

            helptext: qsTranslate("settingsmanager", "When the end of the image list has been reached PhotoQt can go to the first image and keep going.")

            content: [
                PQCheckBox {
                    id: loop
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "loop")
                    onCheckedChanged:
                        checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Shuffle")

            helptext: qsTranslate("settingsmanager", "The images can either be shown in their normal order or they can be traversed in a randomly shuffled order.")

            content: [
                PQCheckBox {
                    id: shuffle
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "shuffle")
                    onCheckedChanged:
                        checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Status info an window buttons")

            helptext: qsTranslate("settingsmanager", "The status info and the window buttons can either remain visible or be hidden during slideshows.")

            content: [
                PQCheckBox {
                    id: hidestatusinfo
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "hide status info")
                    onCheckedChanged:
                        checkDefault()
                },
                PQCheckBox {
                    id: hidewindowbuttons
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "hide window buttons")
                    onCheckedChanged:
                        checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Include subfolders")

            helptext: qsTranslate("settingsmanager", "When starting a slideshow PhotoQt can also include images in subfolders in the list of images to iterate over.")

            content: [
                PQCheckBox {
                    id: includesub
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "include subfolders")
                    onCheckedChanged:
                        checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Music file")

            helptext: qsTranslate("settingsmanager", "PhotoQt can play some background music while a slideshow is running.")

            content: [

                PQCheckBox {
                    id: music_check
                    enforceMaxWidth: set_ani.rightcol
                    //: Enable music to be played during slideshows
                    text: qsTranslate("settingsmanager", "enable music")
                },

                PQButton {
                    id: music_button
                    enabled: music_check.checked
                    smallerVersion:true
                    height: music_check.checked ? 35 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: music_check.checked ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    width: Math.min(300, set_ani.rightcol)
                    clip: true
                    property string musicfile: ""
                    text: musicfile=="" ? "[" + qsTranslate("settingsmanager", "no file selected") + "]" : PQCScriptsFilesPaths.getFilename(musicfile)
                    tooltip: (musicfile==""
                                ? qsTranslate("settingsmanager", "Click to select music file")
                                : ("<b>"+musicfile+"</b><br><br>" + qsTranslate("settingsmanager", "Click to change music file")))
                    onClicked: {
                        var fname = PQCScriptsFilesPaths.openFileFromDialog("Select",
                                                                            (music_button.musicfile == "" ? PQCScriptsFilesPaths.getHomeDir() : music_button.musicfile),
                                                                            ["aac", "flac", "mp3", "ogg", "oga", "wav", "wma"]);
                        if(fname !== "")
                            music_button.musicfile = PQCScriptsFilesPaths.cleanPath(fname)
                    }
                }

            ]

        }


    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (anicombo.hasChanged() || anispeed.hasChanged() || interval.hasChanged() || loop.hasChanged() ||
                          shuffle.hasChanged() || hidewindowbuttons.hasChanged() || hidestatusinfo.hasChanged() || music_check.hasChanged() ||
                          includesub.hasChanged())

    }

    function load() {

        anim_check.loadAndSetDefault(PQCSettings.slideshowImageTransition<15)

        var animArray = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        anicombo.loadAndSetDefault(animArray.indexOf(PQCSettings.slideshowTypeAnimation))
        if(anicombo.currentIndex === -1) anicombo.loadAndSetDefault(0)

        anispeed.loadAndSetDefault(PQCSettings.slideshowImageTransition)
        interval.loadAndSetDefault(PQCSettings.slideshowTime)

        loop.loadAndSetDefault(PQCSettings.slideshowLoop)
        shuffle.loadAndSetDefault(PQCSettings.slideshowShuffle)
        hidewindowbuttons.loadAndSetDefault(PQCSettings.slideshowHideWindowButtons)
        hidestatusinfo.loadAndSetDefault(PQCSettings.slideshowHideLabels)
        music_check.loadAndSetDefault(PQCSettings.slideshowMusicFile!=="")
        music_button.musicfile = PQCSettings.slideshowMusicFile
        includesub.loadAndSetDefault(PQCSettings.slideshowIncludeSubFolders)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var animArray = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQCSettings.slideshowTypeAnimation = animArray[anicombo.currentIndex]

        PQCSettings.slideshowTime = interval.value
        PQCSettings.slideshowImageTransition = anispeed.value
        PQCSettings.slideshowLoop = loop.checked
        PQCSettings.slideshowShuffle = shuffle.checked
        PQCSettings.slideshowHideWindowButtons = hidewindowbuttons.checked
        PQCSettings.slideshowHideLabels = hidestatusinfo.checked
        PQCSettings.slideshowMusicFile = (music_check.checked&&music_button.musicfile!="" ? music_button.musicfile : "")
        PQCSettings.slideshowIncludeSubFolders = includesub.checked

        anicombo.saveDefault()
        anispeed.saveDefault()
        interval.saveDefault()
        loop.saveDefault()
        shuffle.saveDefault()
        hidewindowbuttons.saveDefault()
        hidestatusinfo.saveDefault()
        music_check.saveDefault()
        includesub.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
