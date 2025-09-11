/**************************************************************************
 * *                                                                      **
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

import QtQuick
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_fili

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Sort images")

            helptext: qsTranslate("settingsmanager", "Images in a folder can be sorted in different ways. Once a folder is loaded it is possible to further sort a folder in several advanced ways using the menu option for sorting.")

            showLineAbove: false

        },

        Flow {
            width: set_fili.contentWidth
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
                                                        //: A criteria for sorting images
                property list<string> modeldata_woicu: [qsTranslate("settingsmanager", "name"),
                                                        //: A criteria for sorting images
                                                        qsTranslate("settingsmanager", "time"),
                                                        //: A criteria for sorting images
                                                        qsTranslate("settingsmanager", "size"),
                                                        //: A criteria for sorting images
                                                        qsTranslate("settingsmanager", "type")]
                model: PQCScriptsConfig.isICUSupportEnabled() ? modeldata : modeldata_woicu
                onCurrentIndexChanged: set_fili.checkForChanges()
            }
        },

        Flow {
            width: set_fili.contentWidth
            spacing: 5
            PQRadioButton {
                id: sortasc
                //: Sort images in ascending order
                text: qsTranslate("settingsmanager", "ascending order")
                onCheckedChanged: set_fili.checkForChanges()
            }
            PQRadioButton {
                id: sortdesc
                //: Sort images in descending order
                text: qsTranslate("settingsmanager", "descending order")
                onCheckedChanged: set_fili.checkForChanges()
            }
        },

        /********************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Looping")
            helptext: qsTranslate("settingsmanager", "When loading an image PhotoQt loads all images in the folder as thumbnails for easy navigation. When PhotoQt reaches the end of the list of files, it can either stop right there or loop back to the other end of the list and keep going.")
        },

        PQCheckBox {
            id: loop
            enforceMaxWidth: set_fili.contentWidth
            //: When reaching the end of the images in the folder whether to loop back around to the beginning or not
            text: qsTranslate("settingsmanager", "Loop around")
            onCheckedChanged: set_fili.checkForChanges()
        }

    ]

    onResetToDefaults: {

        sortcriteria.currentIndex = 0
        sortasc.checked = PQCSettings.getDefaultForImageviewSortImagesAscending()
        sortdesc.checked = !sortasc.checked

        loop.checked = PQCSettings.getDefaultForImageviewLoopThroughFolder()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (sortcriteria.hasChanged() || sortasc.hasChanged() || sortdesc.hasChanged() || loop.hasChanged())

    }

    function load() {

        settingsLoaded = false

        if(!PQCScriptsConfig.isICUSupportEnabled() && PQCSettings.imageviewSortImagesBy === "naturalname")
            PQCSettings.imageviewSortImagesBy = "name"

        var l = ["naturalname", "name", "time", "size", "type"]
        if(l.indexOf(PQCSettings.imageviewSortImagesBy) > -1)
            sortcriteria.loadAndSetDefault(l.indexOf(PQCSettings.imageviewSortImagesBy))
        else
            sortcriteria.loadAndSetDefault(0)

        sortasc.loadAndSetDefault(PQCSettings.imageviewSortImagesAscending)
        sortdesc.loadAndSetDefault(!PQCSettings.imageviewSortImagesAscending)

        loop.loadAndSetDefault(PQCSettings.imageviewLoopThroughFolder)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var l = ["naturalname", "name", "time", "size", "type"]
        PQCSettings.imageviewSortImagesBy = l[sortcriteria.currentIndex]
        PQCSettings.imageviewSortImagesAscending = sortasc.checked

        sortcriteria.saveDefault()
        sortasc.saveDefault()
        sortdesc.saveDefault()

        PQCSettings.imageviewLoopThroughFolder = loop.checked
        loop.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
