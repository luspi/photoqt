/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../other/PQCommonFunctions.js" as PQF
import PhotoQt

PQSetting {

    id: set_slsh

    content: [

        PQText {
            x: -set_slsh.indentWidth
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager", "These settings can also be adjusted when setting up a slideshow.")
        },

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Animation")

            helptext: qsTranslate("settingsmanager", "The animation for switching images can be customized for slideshows.")

            showLineAbove: false

        },

        PQCheckBox {
            id: anim_check
            enforceMaxWidth: set_slsh.contentWidth
            text: qsTranslate("settingsmanager", "Enable animations")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },

        Flow {
            id: anirow1
            enabled: anim_check.checked
            width: set_slsh.contentWidth
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
                onCurrentIndexChanged: set_slsh.checkForChanges()
            }
        },

        Flow {

            id: anirow2

            enabled: anim_check.checked

            width: set_slsh.contentWidth
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

        },

        PQText {
            enabled: anim_check.checked
            id: transspeed_txt
            width: set_slsh.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            property string speed: ""
            //: This refers to the currently set speed of transitioning from one image to another during slideshows
            text: qsTranslate("slideshow", "current speed") + ": <b>" + speed + "</b>"

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                anim_check.checked = (PQCSettings.getDefaultForSlideshowImageTransition() < 15)

                var animArray = ["kenburns", "opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
                anicombo.currentIndex = animArray.indexOf(PQCSettings.getDefaultForSlideshowTypeAnimation())
                if(anicombo.currentIndex === -1) anicombo.currentIndex = 0

                anispeed.value = PQCSettings.getDefaultForSlideshowImageTransition()

            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Interval")

            helptext: qsTranslate("settingsmanager", "This determines how long PhotoQt waits before switching to the next image in the list.")

        },

        PQSliderSpinBox {
            id: interval
            width: set_slsh.contentWidth
            minval: 1
            maxval: 300
            title: qsTranslate("settingsmanager", "interval:")
            suffix: " s"
            onValueChanged:
                set_slsh.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                interval.setValue(PQCSettings.getDefaultForSlideshowTime())
            }
        },

        /************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Loop")

            helptext: qsTranslate("settingsmanager", "When the end of the image list has been reached PhotoQt can go to the first image and keep going.")

        },

        PQCheckBox {
            id: loop
            enforceMaxWidth: set_slsh.contentWidth
            text: qsTranslate("settingsmanager", "loop")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                loop.checked = PQCSettings.getDefaultForSlideshowLoop()
            }
        },

        /******************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Shuffle")

            helptext: qsTranslate("settingsmanager", "The images can either be shown in their normal or a randomly shuffled order.")

        },

        PQCheckBox {
            id: shuffle
            enforceMaxWidth: set_slsh.contentWidth
            text: qsTranslate("settingsmanager", "shuffle")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                shuffle.checked = PQCSettings.getDefaultForSlideshowShuffle()
            }
        },

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Status info and window buttons")

            helptext: qsTranslate("settingsmanager", "The status info and the window buttons can either remain visible or be hidden during slideshows.")

        },

        PQCheckBox {
            id: hidestatusinfo
            enforceMaxWidth: set_slsh.contentWidth
            text: qsTranslate("settingsmanager", "hide status info")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },
        PQCheckBox {
            id: hidewindowbuttons
            enforceMaxWidth: set_slsh.contentWidth
            text: qsTranslate("settingsmanager", "hide window buttons")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                hidewindowbuttons.checked = PQCSettings.getDefaultForSlideshowHideWindowButtons()
                hidestatusinfo.checked = PQCSettings.getDefaultForSlideshowHideLabels()
            }
        },

        /***********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Include subfolders")

            helptext: qsTranslate("settingsmanager", "When starting a slideshow PhotoQt can also include images in subfolders.")

        },

        PQCheckBox {
            id: includesub
            enforceMaxWidth: set_slsh.contentWidth
            text: qsTranslate("settingsmanager", "include subfolders")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                includesub.checked = PQCSettings.getDefaultForSlideshowIncludeSubFolders()
            }
        },

        /************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Music files")

            helptext: qsTranslate("settingsmanager", "PhotoQt can play some background music while a slideshow is running. You can select an individual file or multiple files. PhotoQt will restart from the beginning once the end is reached. During videos the volume of the music can optionally be reduced.")

        },

        PQCheckBox {
            id: music_check
            enforceMaxWidth: set_slsh.contentWidth
            //: Enable music to be played during slideshows
            text: qsTranslate("settingsmanager", "enable music")
            onCheckedChanged:
                set_slsh.checkForChanges()
        },

        Column {

            id: musicont

            enabled: music_check.checked

            property list<string> musicfiles: []
            onMusicfilesChanged:
                set_slsh.checkForChanges()

            spacing: 10

            clip: true

            Row {

                spacing: 5

                Item {
                    width: 30
                    height: 30
                }

                Flow {
                    width: set_slsh.contentWidth-35
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
                        property list<string> modeldata: [qsTranslate("settingsmanager", "mute"),
                                                          //: one option as to what will happen with the slideshow music volume while videos are playing
                                                          qsTranslate("settingsmanager", "lower"),
                                                          //: one option as to what will happen with the slideshow music volume while videos are playing
                                                          qsTranslate("settingsmanager", "leave unchanged")]
                        model: modeldata
                        onCurrentIndexChanged:
                            set_slsh.checkForChanges()
                    }
                }
            }

            Rectangle {

                id: filescont

                color: "transparent"
                border.width: 1
                border.color: PQCLook.baseBorder

                width: Math.min(500, set_slsh.contentWidth)
                height: 300

                PQTextL {
                    x: 10
                    y: (parent.height-height)/2
                    width: parent.width-20
                    opacity: musicont.musicfiles.length===0 ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    font.weight: PQCLook.fontWeightBold
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    enabled: false
                    text: qsTranslate("settingsmanager", "No music files selected")
                }

                ListView {

                    id: music_view

                    model: musicont.musicfiles.length

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

                            property string fname: PQCScriptsFilesPaths.getBasename(musicont.musicfiles[modelData])
                            property string fpath: PQCScriptsFilesPaths.getDir(musicont.musicfiles[modelData])

                            width: music_view.width-(music_scroll.visible ? music_scroll.width : 0)
                            height: 40
                            color: PQCLook.baseBorder

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
                                width: set_slsh.contentWidth > 300 ? 120 : 0
                                Behavior on width { NumberAnimation { duration: 200 } }
                                height: 40
                                PQButtonIcon {
                                    width: 40
                                    height: 40
                                    iconScale: 0.5
                                    enabled: musicdeleg.modelData>0
                                    source: "image://svg/:/" + PQCLook.iconShade + "/upwards.svg"
                                    //: This relates to the list of music files for slideshows
                                    tooltip: qsTranslate("settingsmanager", "Move file up one position")
                                    onClicked: {
                                        musicont.musicfiles.splice(musicdeleg.modelData-1, 0, musicont.musicfiles.splice(musicdeleg.modelData, 1)[0])
                                        musicont.musicfilesChanged()
                                    }
                                }
                                PQButtonIcon {
                                    width: 40
                                    height: 40
                                    rotation: 180
                                    iconScale: 0.5
                                    enabled: musicdeleg.modelData < music_view.model-1
                                    source: "image://svg/:/" + PQCLook.iconShade + "/upwards.svg"
                                    //: This relates to the list of music files for slideshows
                                    tooltip: qsTranslate("settingsmanager", "Move file down one position")
                                    onClicked: {
                                        musicont.musicfiles.splice(musicdeleg.modelData+1, 0, musicont.musicfiles.splice(musicdeleg.modelData, 1)[0])
                                        musicont.musicfilesChanged()
                                    }
                                }
                                PQButtonIcon {
                                    width: 40
                                    height: 40
                                    iconScale: 0.35
                                    source: "image://svg/:/" + PQCLook.iconShade + "/x.svg"
                                    //: This relates to the list of music files for slideshows
                                    tooltip: qsTranslate("settingsmanager", "Delete this file from the list")
                                    onClicked: {
                                        musicont.musicfiles.splice(musicdeleg.modelData, 1)
                                        musicont.musicfilesChanged()
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
                                                                          (musicont.musicfiles.length===0 ?
                                                                               PQCScriptsFilesPaths.getHomeDir() :
                                                                               PQCScriptsFilesPaths.getDir(musicont.musicfiles[musicont.musicfiles.length-1])),
                                                                          ["aac", "flac", "mp3", "ogg", "oga", "wav", "wma"]);
                    if(fnames.length > 0) {
                        musicont.musicfiles = musicont.musicfiles.concat(fnames)
                        musicont.musicfilesChanged()
                    }
                }
            }

            PQCheckBox {
                id: music_shuffle
                text: qsTranslate("settingsmanager", "shuffle order")
                onCheckedChanged:
                    set_slsh.checkForChanges()
            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {
                music_check.checked = PQCSettings.getDefaultForSlideshowMusic()
                music_volumevideos.currentIndex = PQCSettings.getDefaultForSlideshowMusicVolumeVideos()
                music_shuffle.checked = PQCSettings.getDefaultForSlideshowMusicShuffle()
                musicont.musicfiles = []
            }
        }

    ]

    Component.onCompleted:
        load()

    function handleEscape() {
        anicombo.popup.close()
        interval.acceptValue()
        music_volumevideos.popup.close()
    }

    // TODO!!!!
    // do not make this function typed, it will break
    function areTwoListsEqual(l1, l2) {
    }

    function checkForChanges() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (anim_check.hasChanged() || anicombo.hasChanged() || anispeed.hasChanged() || interval.hasChanged() ||
                                                      loop.hasChanged() || shuffle.hasChanged() || hidewindowbuttons.hasChanged() ||
                                                      hidestatusinfo.hasChanged() || includesub.hasChanged() ||
                                                      music_check.hasChanged() || music_volumevideos.hasChanged() || music_shuffle.hasChanged() ||
                                                      !PQF.areTwoListsEqual(musicont.musicfiles, PQCSettings.slideshowMusicFiles))

    }

    function load() {

        settingsLoaded = false

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
        musicont.musicfiles = tmp

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var animArray = ["kenburns", "opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        PQCSettings.slideshowTypeAnimation = animArray[anicombo.currentIndex]
        PQCSettings.slideshowImageTransition = anispeed.value

        anim_check.saveDefault()
        anicombo.saveDefault()
        anispeed.saveDefault()

        PQCSettings.slideshowTime = interval.value
        interval.saveDefault()

        PQCSettings.slideshowLoop = loop.checked
        loop.saveDefault()

        PQCSettings.slideshowShuffle = shuffle.checked
        shuffle.saveDefault()

        PQCSettings.slideshowHideWindowButtons = hidewindowbuttons.checked
        PQCSettings.slideshowHideLabels = hidestatusinfo.checked
        hidewindowbuttons.saveDefault()
        hidestatusinfo.saveDefault()

        PQCSettings.slideshowIncludeSubFolders = includesub.checked
        includesub.saveDefault()

        PQCSettings.slideshowMusic = music_check.checked
        PQCSettings.slideshowMusicVolumeVideos = music_volumevideos.currentIndex
        PQCSettings.slideshowMusicShuffle = music_shuffle.checked
        PQCSettings.slideshowMusicFiles = musicont.musicfiles

        music_check.saveDefault()
        music_check.saveDefault()
        music_volumevideos.saveDefault()
        music_shuffle.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
