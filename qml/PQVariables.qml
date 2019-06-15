import QtQuick 2.9
import PQFileFolderModel 1.0

Item {

    property var shortcuts: []
    property string visibleItem: ""
    property var allImageFilesInOrder: []
    property int indexOfCurrentImage: -1
    property real currentZoomLevel: 1

    property string openCurrentDirectory: handlingFileDialog.getHomeDir()

    property point mousePos: Qt.point(-1, -1)


    Connections {
        target: PQCppVariables

        onCmdFilePathChanged: {

            if(PQCppVariables.cmdFilePath != "") {

                var folderOld = (variables.allImageFilesInOrder.length == 0 ? "" : handlingGeneral.getFilePathFromFullPath(variables.allImageFilesInOrder[0]))
                var folderNew = handlingGeneral.getFilePathFromFullPath(PQCppVariables.cmdFilePath)

                if(folderNew == folderOld) {
                    var newindex = variables.allImageFilesInOrder.indexOf(handlingFileDialog.cleanPath(PQCppVariables.cmdFilePath))
                    if(newindex > -1) {
                        variables.indexOfCurrentImage = newindex
                        return
                    }
                }

                var sortField = PQSettings.sortby=="name" ?
                                    PQFileFolderModel.Name :
                                    (PQSettings.sortby == "naturalname" ?
                                        PQFileFolderModel.NaturalName :
                                        (PQSettings.sortby == "time" ?
                                            PQFileFolderModel.Time :
                                            (PQSettings.sortby == "size" ?
                                                PQFileFolderModel.Size :
                                                PQFileFolderModel.Type)))

                variables.allImageFilesInOrder = filefoldermodel.loadFilesInFolder(folderNew, PQSettings.openShowHiddenFilesFolders, imageformats.getAllEnabledFileformats(), sortField, !PQSettings.sortbyAscending)
                variables.indexOfCurrentImage = Math.max(0, variables.allImageFilesInOrder.indexOf(PQCppVariables.cmdFilePath))

                // reset variable
                PQCppVariables.cmdFilePath = ""
            }

        }

        onCmdOpenChanged: {
            if(PQCppVariables.cmdOpen) {

                if(variables.visibleItem != "filedialog")
                    loader.show("filedialog")

                PQCppVariables.cmdOpen = false
            }
        }

        onCmdThumbsChanged: {
            if(PQCppVariables.cmdThumbs) {
                console.log("thumbs")
                PQCppVariables.cmdThumbs = false
            }
        }

        onCmdNoThumbsChanged: {
            if(PQCppVariables.cmdNoThumbs) {
                console.log("nothumbs")
                PQCppVariables.cmdNoThumbs = false
            }
        }

//        onCmdDebugChanged: {
            // this we actually do not handle here
            // if this changes to true, we keep it at true and use it to detect debug modus everywhere
//        }

    }

}
