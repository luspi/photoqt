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

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

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

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Looping")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When loading an image PhotoQt loads all images in the folder as thumbnails for easy navigation. When PhotoQt reaches the end of the list of files, it can either stop right there or loop back to the other end of the list and keep going.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: loop
            x: (parent.width-width)/2
            //: When reaching the end of the images in the folder whether to loop back around to the beginning or not
            text: qsTranslate("settingsmanager", "Loop around")
            checked: PQCSettings.imageviewLoopThroughFolder
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Sort images")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Images in a folder can be sorted in different ways depending on your preferences. These criteria here are the ones that can be used in a very quick way. Once a folder is loaded it is possible to further sort a folder in several advanced ways using the menu option for sorting.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQText {
                y: (sortcriteria.height-height)/2
                text: qsTranslate("settingsmanager", "Sort by:")
            }
            PQComboBox {
                id: sortcriteria
                        //: A criteria for sorting images
                model: [qsTranslate("settingsmanager", "natural name"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager", "name"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager", "time"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager", "size"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager", "type")]
                onCurrentIndexChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQRadioButton {
                id: sortasc
                //: Sort images in ascending order
                text: qsTranslate("settingsmanager", "ascending order")
                checked: PQCSettings.imageviewSortImagesAscending
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: sortdesc
                //: Sort images in descending order
                text: qsTranslate("settingsmanager", "descending order")
                onCheckedChanged: checkDefault()
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Animation")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When switching between images PhotoQt can add an animation to smoothes such a transition. There are a whole bunch of transitions to choose from, and also an option for PhotoQt to choose one at random each time. Additionally, the speed of the chosen animation can be chosen from very slow to very fast.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: anispeed_check
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "animate switching between images")
            checked: (PQCSettings.imageviewAnimationDuration>0)
            onCheckedChanged: checkDefault()
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            enabled: anispeed_check.checked
            PQText {
                y: (anicombo.height-height)/2
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

        Row {
            x: (parent.width-width)/2
            enabled: anispeed_check.checked
            PQText {
                //: used here for the animation speed
                text: qsTranslate("settingsmanager", "very slow")
            }
            PQSlider {
                id: anispeed
                from: 1
                to: 10
                value: PQCSettings.imageviewAnimationDuration
                onValueChanged: checkDefault()
            }
            PQText {
                //: used here for the animation speed
                text: qsTranslate("settingsmanager", "very fast")
            }
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

        settingChanged = false

    }

    function load() {

        loop.loadAndSetDefault(PQCSettings.imageviewLoopThroughFolder)

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

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewLoopThroughFolder = loop.checked

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

        loop.saveDefault()
        sortasc.saveDefault()
        sortdesc.saveDefault()
        anispeed_check.saveDefault()
        anispeed.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
