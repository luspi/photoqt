pragma ComponentBehavior: Bound
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
                        setting_top.checkDefault()
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
                                    //: A special slideshow effect: https://en.wikipedia.org/wiki/Ken_Burns_effect
                            model: [qsTranslate("slideshow", "Ken Burns effect"),
                                    //: This is referring to the in/out animation of images during slideshows
                                    qsTranslate("slideshow", "opacity"),
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
                            lineBelowItem: [0,6]
                            onCurrentIndexChanged: setting_top.checkDefault()
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
                        setting_top.checkDefault()
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
                        setting_top.checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Shuffle")

            helptext: qsTranslate("settingsmanager", "The images can either be shown in their normal or a randomly shuffled order.")

            content: [
                PQCheckBox {
                    id: shuffle
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "shuffle")
                    onCheckedChanged:
                        setting_top.checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Status info and window buttons")

            helptext: qsTranslate("settingsmanager", "The status info and the window buttons can either remain visible or be hidden during slideshows.")

            content: [
                PQCheckBox {
                    id: hidestatusinfo
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "hide status info")
                    onCheckedChanged:
                        setting_top.checkDefault()
                },
                PQCheckBox {
                    id: hidewindowbuttons
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "hide window buttons")
                    onCheckedChanged:
                        setting_top.checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Include subfolders")

            helptext: qsTranslate("settingsmanager", "When starting a slideshow PhotoQt can also include images in subfolders.")

            content: [
                PQCheckBox {
                    id: includesub
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "include subfolders")
                    onCheckedChanged:
                        setting_top.checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_music

            //: Settings title
            title: qsTranslate("settingsmanager", "Music files")

            helptext: qsTranslate("settingsmanager", "PhotoQt can play some background music while a slideshow is running. You can select an individual file or multiple files. PhotoQt will restart from the beginning once the end is reached. During videos the volume of the music can optionally be reduced.")

            property list<string> musicfiles: []
            onMusicfilesChanged:
                setting_top.checkDefault()

            content: [

                PQCheckBox {
                    id: music_check
                    enforceMaxWidth: set_ani.rightcol
                    //: Enable music to be played during slideshows
                    text: qsTranslate("settingsmanager", "enable music")
                    onCheckedChanged:
                        setting_top.checkDefault()
                },

                Column {

                    id: musicont

                    spacing: 10

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
                            width: set_ani.rightcol-35
                            spacing: 5

                            PQText {
                                height: music_volumevideos.height
                                verticalAlignment: Text.AlignVCenter
                                //: some options as to what will happen with the slideshow music volume while videos are playing
                                text: qsTranslate("settingsmanager", "music volume during videos with audio:")
                            }

                            PQComboBox {
                                id: music_volumevideos
                                        //: one option as to what will happen with the slideshow music volume while videos are playing
                                model: [qsTranslate("settingsmanager", "mute"),
                                        //: one option as to what will happen with the slideshow music volume while videos are playing
                                        qsTranslate("settingsmanager", "lower"),
                                        //: one option as to what will happen with the slideshow music volume while videos are playing
                                        qsTranslate("settingsmanager", "leave unchanged")]
                                onCurrentIndexChanged:
                                    setting_top.checkDefault()
                            }
                        }
                    }

                    Rectangle {

                        id: filescont

                        color: "transparent"
                        border.width: 1
                        border.color: PQCLook.baseColorHighlight

                        width: Math.min(500, set_ani.rightcol)
                        height: 300

                        PQTextL {
                            x: 10
                            y: (parent.height-height)/2
                            width: parent.width-20
                            opacity: set_music.musicfiles.length===0 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            font.weight: PQCLook.fontWeightBold
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            enabled: false
                            text: qsTranslate("settingsmanager", "No music files selected")
                        }

                        ListView {

                            id: music_view

                            model: set_music.musicfiles.length

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

                                    required property int modelData

                                    property string fname: PQCScriptsFilesPaths.getBasename(set_music.musicfiles[modelData])
                                    property string fpath: PQCScriptsFilesPaths.getDir(set_music.musicfiles[modelData])

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
                                        width: set_ani.rightcol > 300 ? 120 : 0
                                        Behavior on width { NumberAnimation { duration: 200 } }
                                        height: 40
                                        PQButtonIcon {
                                            width: 40
                                            height: 40
                                            iconScale: 0.5
                                            radius: 0
                                            enabled: musicdeleg.modelData>0
                                            source: "image://svg/:/white/upwards.svg"
                                            //: This relates to the list of music files for slideshows
                                            tooltip: qsTranslate("settingsmanager", "Move file up one position")
                                            onClicked: {
                                                set_music.musicfiles.splice(musicdeleg.modelData-1, 0, set_music.musicfiles.splice(musicdeleg.modelData, 1)[0])
                                                set_music.musicfilesChanged()
                                            }
                                        }
                                        PQButtonIcon {
                                            width: 40
                                            height: 40
                                            rotation: 180
                                            iconScale: 0.5
                                            radius: 0
                                            enabled: musicdeleg.modelData < music_view.model-1
                                            source: "image://svg/:/white/upwards.svg"
                                            //: This relates to the list of music files for slideshows
                                            tooltip: qsTranslate("settingsmanager", "Move file down one position")
                                            onClicked: {
                                                set_music.musicfiles.splice(musicdeleg.modelData+1, 0, set_music.musicfiles.splice(musicdeleg.modelData, 1)[0])
                                                set_music.musicfilesChanged()
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
                                                set_music.musicfiles.splice(musicdeleg.modelData, 1)
                                                set_music.musicfilesChanged()
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
                                                                                  (set_music.musicfiles.length===0 ?
                                                                                       PQCScriptsFilesPaths.getHomeDir() :
                                                                                       PQCScriptsFilesPaths.getDir(set_music.musicfiles[set_music.musicfiles.length-1])),
                                                                                  ["aac", "flac", "mp3", "ogg", "oga", "wav", "wma"]);
                            if(fnames.length > 0) {
                                set_music.musicfiles = set_music.musicfiles.concat(fnames)
                                set_music.musicfilesChanged()
                            }
                        }
                    }

                    PQCheckBox {
                        id: music_shuffle
                        text: qsTranslate("settingsmanager", "shuffle order")
                        onCheckedChanged:
                            setting_top.checkDefault()
                    }

                }

            ]

        }

    }

    Component.onCompleted:
        load()

    function areTwoListsEqual(l1: var, l2: var) : bool {

        if(l1.length !== l2.length)
            return false

        for(var i = 0; i < l1.length; ++i) {

            if(l1[i].length !== l2[i].length)
                return false

            for(var j = 0; j < l1[i].length; ++j) {
                if(l1[i][j] !== l2[i][j])
                    return false
            }
        }

        return true
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (anicombo.hasChanged() || anispeed.hasChanged() || interval.hasChanged() || loop.hasChanged() ||
                          shuffle.hasChanged() || hidewindowbuttons.hasChanged() || hidestatusinfo.hasChanged() || music_check.hasChanged() ||
                          includesub.hasChanged() || music_volumevideos.hasChanged() || music_shuffle.hasChanged() ||
                          !areTwoListsEqual(set_music.musicfiles, PQCSettings.slideshowMusicFiles))

    }

    function load() {

        anim_check.loadAndSetDefault(PQCSettings.slideshowImageTransition<15)

        var animArray = ["kenburns", "opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        anicombo.loadAndSetDefault(animArray.indexOf(PQCSettings.slideshowTypeAnimation))
        if(anicombo.currentIndex === -1) anicombo.loadAndSetDefault(0)

        anispeed.loadAndSetDefault(PQCSettings.slideshowImageTransition)
        interval.loadAndSetDefault(PQCSettings.slideshowTime)

        loop.loadAndSetDefault(PQCSettings.slideshowLoop)
        shuffle.loadAndSetDefault(PQCSettings.slideshowShuffle)
        hidewindowbuttons.loadAndSetDefault(PQCSettings.slideshowHideWindowButtons)
        hidestatusinfo.loadAndSetDefault(PQCSettings.slideshowHideLabels)
        includesub.loadAndSetDefault(PQCSettings.slideshowIncludeSubFolders)
        music_check.loadAndSetDefault(PQCSettings.slideshowMusic)
        music_volumevideos.loadAndSetDefault(PQCSettings.slideshowMusicVolumeVideos)
        music_shuffle.loadAndSetDefault(PQCSettings.slideshowMusicShuffle)

        var tmp = []
        for(var i in PQCSettings.slideshowMusicFiles) {
            if(PQCScriptsFilesPaths.doesItExist(PQCSettings.slideshowMusicFiles[i]))
                tmp.push(PQCSettings.slideshowMusicFiles[i])
        }
        set_music.musicfiles = tmp

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var animArray = ["kenburns", "opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQCSettings.slideshowTypeAnimation = animArray[anicombo.currentIndex]

        PQCSettings.slideshowTime = interval.value
        PQCSettings.slideshowImageTransition = anispeed.value
        PQCSettings.slideshowLoop = loop.checked
        PQCSettings.slideshowShuffle = shuffle.checked
        PQCSettings.slideshowHideWindowButtons = hidewindowbuttons.checked
        PQCSettings.slideshowHideLabels = hidestatusinfo.checked
        PQCSettings.slideshowIncludeSubFolders = includesub.checked
        PQCSettings.slideshowMusic = music_check.checked
        PQCSettings.slideshowMusicVolumeVideos = music_volumevideos.currentIndex
        PQCSettings.slideshowMusicShuffle = music_shuffle.checked
        PQCSettings.slideshowMusicFiles = set_music.musicfiles

        anicombo.saveDefault()
        anispeed.saveDefault()
        interval.saveDefault()
        loop.saveDefault()
        shuffle.saveDefault()
        hidewindowbuttons.saveDefault()
        hidestatusinfo.saveDefault()
        music_check.saveDefault()
        includesub.saveDefault()
        music_check.saveDefault()
        music_volumevideos.saveDefault()
        music_shuffle.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
