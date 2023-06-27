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

import QtQuick
import PQCFileFolderModel

PQCFileFolderModel {

    id: model

    // MainView:
    // the current index and filename
    // a change in the current filename triggers a (re-)load of the image even if the index remained unchanged
    property int currentIndex: -1
    property string currentFile: ""

    // shortcut to detect whether filter is currently set
    property bool filterCurrentlyActive: nameFilters.length!==0
                                         ||filenameFilters.length!==0
                                         ||imageResolutionFilter.width!=0
                                         ||imageResolutionFilter.height!=0
                                         ||fileSizeFilter!==0

    // this allows to set a specific filename as current
    // once the model has finished reloading
    property string setFileNameOnceReloaded: ""

    // is this a document or archive? if so, save some extra details
    property bool isPQT: currentFile.indexOf("::PDF::")>-1
    property bool isARC: currentFile.indexOf("::ARC::")>-1
    property string pqtName: isPQT ? currentFile.split("::PDF::")[1] : ""
    property int pqtNum: isPQT ? currentFile.split("::PDF::")[0]*1 : ""
    property string arcName: isARC ? currentFile.split("::ARC::")[1] : ""
    property string arcFile: isARC ? currentFile.split("::ARC::")[0] : ""

    sortField: PQCSettings.imageviewSortImagesBy==="name" ?
                   PQFileFolderModel.Name :
                   PQCSettings.imageviewSortImagesBy==="time" ?
                       PQFileFolderModel.Time :
                       PQCSettings.imageviewSortImagesBy==="size" ?
                           PQFileFolderModel.Size :
                           PQCSettings.imageviewSortImagesBy==="type" ?
                               PQFileFolderModel.Type :
                               PQFileFolderModel.NaturalName

    sortReversed: !PQCSettings.imageviewSortImagesAscending

    defaultNameFilters: PQCImageFormats.getEnabledFormats()
    mimeTypeFilters: PQCImageFormats.getEnabledMimeTypes()

    showHidden: PQCSettings.openfileShowHiddenFilesFolders

    onCurrentIndexChanged: {
        if(currentIndex == -1)
            currentFile = ""
        else
            currentFile = model.entriesMainView[currentIndex]
    }

    onFolderFileDialogChanged: {
//        if(folderFileDialog != "")
//            handlingFileDialog.setLastLocation(folderFileDialog)
    }

    onNewDataLoadedMainView: {

        var curset = false

        // if a specific filename is to be loaded
        if(setFileNameOnceReloaded == "---") {
            if(model.countMainView > 0) {
                currentIndex = 0
                currentFile = model.entriesMainView[0]
            }
        } else if(setFileNameOnceReloaded != "") {
            if(setAsCurrent(setFileNameOnceReloaded)) {
                curset = true
                currentFile = setFileNameOnceReloaded
            }
            setFileNameOnceReloaded = ""
        } else if(currentFile != "") {
            if(setAsCurrent(currentFile))
                curset = true
        }

        if(!curset) {

            // make sure the index is valid
            if(model.currentIndex >= model.countMainView)
                model.currentIndex = model.countMainView-1
            else if(model.currentIndex == -1 && model.countMainView > 0)
                model.currentIndex = 0
            else if(model.countMainView == 0)
                model.currentIndex = -1

            // update the current file path
            model.currentFile = (model.currentIndex!=-1 ? model.entriesMainView[model.currentIndex] : "")

        }

    }

    // set a specific file as current file
    function setAsCurrent(filepath) {
        var ind = model.getIndexOfMainView(filepath)
        if(ind != -1) {
            currentIndex = ind
            return true
        }
        return false
    }

    function resetQMLModel() {
        currentIndex = -1
        setFileNameOnceReloaded = ""
        currentFile = ""
    }

}
