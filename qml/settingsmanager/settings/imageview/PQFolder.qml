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

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - imageviewLoopThroughFolder
// - imageviewSortImagesBy
// - imageviewSortImagesAscending
// - imageviewAnimationDuration
// - imageviewAnimationType

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: anispeed.editMode || preload.editMode || sortcriteria.popup.visible || anicombo.popup.visible

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_loop

            //: Settings title
            title: qsTranslate("settingsmanager", "Looping")

            helptext: qsTranslate("settingsmanager", "When loading an image PhotoQt loads all images in the folder as thumbnails for easy navigation. When PhotoQt reaches the end of the list of files, it can either stop right there or loop back to the other end of the list and keep going.")

            content: [
                PQCheckBox {
                    id: loop
                    enforceMaxWidth: set_loop.rightcol
                    //: When reaching the end of the images in the folder whether to loop back around to the beginning or not
                    text: qsTranslate("settingsmanager", "Loop around")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sort

            //: Settings title
            title: qsTranslate("settingsmanager", "Sort images")

            helptext: qsTranslate("settingsmanager", "Images in a folder can be sorted in different ways. Once a folder is loaded it is possible to further sort a folder in several advanced ways using the menu option for sorting.")

            content: [
                Flow {
                    width: set_sort.rightcol
                    spacing: 5
                    PQText {
                        height: sortcriteria.height
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        text: qsTranslate("settingsmanager", "Sort by:")
                    }
                    PQComboBox {
                        id: sortcriteria
                                                          //: A criteria for sorting images
                        property list<string> modeldata: [qsTranslate("settingsmanager", "natural name"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "name"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "time"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "size"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "type")]
                        model: modeldata
                        onCurrentIndexChanged: setting_top.checkDefault()
                    }
                },

                Flow {
                    width: set_sort.rightcol
                    spacing: 5
                    PQRadioButton {
                        id: sortasc
                        //: Sort images in ascending order
                        text: qsTranslate("settingsmanager", "ascending order")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: sortdesc
                        //: Sort images in descending order
                        text: qsTranslate("settingsmanager", "descending order")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_ani

            //: Settings title
            title: qsTranslate("settingsmanager", "Animation")

            helptext: qsTranslate("settingsmanager", "When switching between images PhotoQt can add an animation to smoothes such a transition. There are a whole bunch of transitions to choose from, and also an option for PhotoQt to choose one at random each time. Additionally, the speed of the chosen animation can be chosen from very slow to very fast.")

            content: [

                PQCheckBox {
                    id: anispeed_check
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "animate switching between images")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Column {

                    spacing: 15

                    enabled: anispeed_check.checked
                    clip: true

                    height: enabled ? (anirow1.height+anirow2.height+spacing) : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Flow {
                        id: anirow1
                        spacing: 5
                        width: set_ani.rightcol
                        PQText {
                            height: anicombo.height
                            verticalAlignment: Text.AlignVCenter
                            text: qsTranslate("settingsmanager", "Animation:")
                        }
                        PQComboBox {
                            id: anicombo
                                                              //: This is referring to an in/out animation of images
                            property list<string> modeldata: [qsTranslate("settingsmanager", "opacity"),
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
                            model: modeldata
                            property list<int> linedata: [5]
                            lineBelowItem: linedata
                            onCurrentIndexChanged: setting_top.checkDefault()
                        }
                    }

                    Column {

                        id: anirow2

                        spacing: 5

                        PQSliderSpinBox {
                            id: anispeed
                            width: set_ani.rightcol
                            minval: 1
                            maxval: 10
                            title: qsTranslate("settingsmanager", "speed:")
                            suffix: ""
                            onValueChanged:
                                setting_top.checkDefault()
                        }

                        PQText {
                            width: set_ani.rightcol
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            //: The value is a numerical value expressing the speed of animating between images
                            text: qsTranslate("settingsmanager", "(higher value = slower)")
                        }

                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_preload

            //: Settings title
            title: qsTranslate("settingsmanager", "Preloading")

            helptext: qsTranslate("settingsmanager", "The number of images in both directions (previous and next) that should be preloaded in the background. Images are not preloaded until the main image has been displayed. This improves navigating through all images in the folder, but the tradeoff is an increased memory consumption. It is recommended to keep this at a low number.")

            content: [

                Column {

                    id: preloadcol

                    spacing: 5

                    PQSliderSpinBox {
                        id: preload
                        width: set_preload.rightcol
                        minval: 0
                        maxval: 5
                        title: ""
                        suffix: ""
                        onValueChanged:
                            setting_top.checkDefault()
                    }

                    PQText {
                        width: set_preload.rightcol
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: preload.value == 0 ?
                                  qsTranslate("settingsmanager", "only current image will be loaded") :
                                  (preload.value == 1 ?
                                       qsTranslate("settingsmanager", "preload 1 image in both directions") :
                                       qsTranslate("settingsmanager", "preload %1 images in both directions").arg(preload.value))

                    }

                }
            ]

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        anispeed.acceptValue()
        preload.acceptValue()
        sortcriteria.popup.close()
        anicombo.popup.close()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        if(loop.hasChanged() || sortasc.hasChanged() || sortdesc.hasChanged() ||
                anispeed_check.hasChanged() || anispeed.hasChanged()) {
            settingChanged = true
            return
        }

        var l = ["naturalname", "name", "time", "size", "type"]
        if(PQCSettings.imageviewSortImagesBy !== l[sortcriteria.currentIndex]) {
            settingChanged = true
            return
        }

        var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        if(PQCSettings.imageviewAnimationType !== aniValues[anicombo.currentIndex]) {
            settingChanged = true
            return
        }

        if(preload.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        loop.loadAndSetDefault(PQCSettings.imageviewLoopThroughFolder) // qmllint disable unqualified

        var l = ["naturalname", "name", "time", "size", "type"]
        if(l.indexOf(PQCSettings.imageviewSortImagesBy) > -1)
            sortcriteria.currentIndex = l.indexOf(PQCSettings.imageviewSortImagesBy)
        else
            sortcriteria.currentIndex = 0

        sortasc.loadAndSetDefault(PQCSettings.imageviewSortImagesAscending)
        sortdesc.loadAndSetDefault(!PQCSettings.imageviewSortImagesAscending)

        anispeed_check.loadAndSetDefault(PQCSettings.imageviewAnimationDuration>0)
        var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        if(aniValues.indexOf(PQCSettings.imageviewAnimationType) > -1)
            anicombo.currentIndex = aniValues.indexOf(PQCSettings.imageviewAnimationType)
        else
            anicombo.currentIndex = 0
        anispeed.loadAndSetDefault(PQCSettings.imageviewAnimationDuration)

        preload.loadAndSetDefault(PQCSettings.imageviewPreloadInBackground)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewLoopThroughFolder = loop.checked // qmllint disable unqualified

        var l = ["naturalname", "name", "time", "size", "type"]
        PQCSettings.imageviewSortImagesBy = l[sortcriteria.currentIndex]

        PQCSettings.imageviewSortImagesAscending = sortasc.checked

        if(!anispeed_check.checked)
            PQCSettings.imageviewAnimationDuration = 0
        else {
            var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
            PQCSettings.imageviewAnimationType = aniValues[anicombo.currentIndex]
            PQCSettings.imageviewAnimationDuration = anispeed.value
        }

        PQCSettings.imageviewPreloadInBackground = preload.value

        loop.saveDefault()
        sortasc.saveDefault()
        sortdesc.saveDefault()
        anispeed_check.saveDefault()
        anispeed.saveDefault()
        preload.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
