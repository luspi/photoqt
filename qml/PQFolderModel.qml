import QtQuick 2.9
import PQFileFolderModel 1.0

Item {

    id: folder_top

    // access model propertoes
    property alias count: model.count
    property alias folder: model.folder
    property alias nameFilters: model.overWriteNameFilters
    property alias filenameFilters: model.filenameFilters

    // the current index and filename
    // a change in the current filename triggers a (re-)load of the image even if the index remained unchanged
    property int current: -1
    property string currentFilePath: ""

    // this allows to set a specific filename as current
    // once the model has finished reloading
    property string setFileNameOnceReloaded: ""

    // a change in the index updates the current file path
    onCurrentChanged:
        currentFilePath = model.getFilePath(current)

    // a change in the current file path triggers an update to the metadata
    onCurrentFilePathChanged:
        cppmetadata.updateMetadata(foldermodel.currentFilePath)

    // if the folder content in general has changed, not necessarily the current image
    signal folderContentChanged()

    PQFileFolderModel {

        id: model

        count: 0
        ignoreDirs: true

        onNewDataLoaded: {

            var curset = false

            // if a specific filename is to be loaded
            if(setFileNameOnceReloaded != "") {
                if(setAsCurrent(setFileNameOnceReloaded))
                    curset = true
                setFileNameOnceReloaded = ""
            } else if(currentFilePath != "") {
                if(setAsCurrent(currentFilePath))
                    curset = true
            }

            if(!curset) {

                // make sure the index is valid
                if(folder_top.current >= model.count)
                    folder_top.current = model.count-1

                // update the current file path
                folder_top.currentFilePath = model.getFilePath(current)

            }

            // this signal typically means that the folder has changed
            // or a new folder is loaded
            folder_top.folderContentChanged()

        }

        property var overWriteNameFilters: []
        nameFilters: overWriteNameFilters.length == 0 ? PQImageFormats.getEnabledFormats() : overWriteNameFilters

        // some settings
        showHidden: PQSettings.openShowHiddenFilesFolders
        sortField: PQSettings.sortby=="name" ?
                       PQFileFolderModel.Name :
                       (PQSettings.sortby == "naturalname" ?
                            PQFileFolderModel.NaturalName :
                            (PQSettings.sortby == "time" ?
                                 PQFileFolderModel.Time :
                                 (PQSettings.sortby == "size" ?
                                     PQFileFolderModel.Size :
                                     PQFileFolderModel.Type)))
        sortReversed: !PQSettings.sortbyAscending

    }

    // sets a new folder path, and a copy of the images (instead of having to reload them from scratch)
    function setFolderAndImages(folder, images) {
        current = model.setFolderAndImages(folder, images)
    }

    // get the file path at at the given index
    function getFilePath(index) {
        return model.getFilePath(index)
    }

    // set a specific file as current file
    function setAsCurrent(filepath) {
        var ind = model.getIndexOfFile(filepath)
        if(ind != -1) {
            current = ind
            return true
        }
        return false
    }

}
