import QtQuick 2.9
import PQFileFolderModel 1.0
import "shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    property var shortcuts: []
    property string visibleItem: ""
    property var allImageFilesInOrder: []
    property int indexOfCurrentImage: -1
    property real currentZoomLevel: 1
    property real currentPaintedZoomLevel: 1
    property string openCurrentDirectory: PQSettings.openKeepLastLocation ? handlingFileDialog.getLastLocation() : handlingFileDialog.getHomeDir()
    property point mousePos: Qt.point(-1, -1)
    property int metaDataWidthWhenKeptOpen: 0

    property bool slideShowActive: false
    property bool faceTaggingActive: false

    property bool filterSet: false
    property var filterStrings: []
    property var filterSuffixes: []
    property string filterStringConcat: ""
    property var allImageFilesInOrderFilterBackup: []

    onIndexOfCurrentImageChanged:
        cppmetadata.updateMetadata(indexOfCurrentImage != -1 ? allImageFilesInOrder[indexOfCurrentImage] : "")

    onOpenCurrentDirectoryChanged:
        handlingFileDialog.setLastLocation(openCurrentDirectory)


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

                variables.allImageFilesInOrder = filefoldermodel.loadFilesInFolder(folderNew, PQSettings.openShowHiddenFilesFolders, PQImageFormats.getAllEnabledFileformats(), sortField, !PQSettings.sortbyAscending)
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

        onCmdShowChanged: {
            if(PQCppVariables.cmdShow) {
                console.log("show")
                PQCppVariables.cmdShow = false
            }
        }

        onCmdHideChanged: {
            if(PQCppVariables.cmdHide) {
                console.log("hide")
                PQCppVariables.cmdHide = false
            }
        }

        onCmdToggleChanged: {
            if(PQCppVariables.cmdToggle) {
                console.log("toggle")
                PQCppVariables.cmdToggle = false
            }
        }

        onCmdThumbsChanged: {
            if(PQCppVariables.cmdThumbs) {
                console.log("thumbs")
                PQCppVariables.cmdThumbs = false
            }
        }

        onCmdShortcutSequenceChanged: {
            if(PQCppVariables.cmdShortcutSequence != "") {
                HandleShortcuts.checkComboForShortcut(PQCppVariables.cmdShortcutSequence)
                PQCppVariables.cmdShortcutSequence = ""
            }
        }

        onCmdNoThumbsChanged: {
            if(PQCppVariables.cmdNoThumbs) {
                console.log("nothumbs")
                PQCppVariables.cmdNoThumbs = false
            }
        }

        onCmdTrayChanged: {
            if(PQCppVariables.cmdTray) {
                console.log("tray")
                PQCppVariables.cmdTray = false
            }
        }

//        onCmdDebugChanged: {
            // this we actually do not handle here
            // if this changes to true, we keep it at true and use it to detect debug modus everywhere
//        }

    }

    Connections {

        target: PQSettings

        onMainMenuPopoutElementChanged:
            loader.ensureItIsReady("mainmenu")

        onMetadataPopoutElementChanged:
            loader.ensureItIsReady("metadata")

        onHistogramPopoutElementChanged:
            loader.ensureItIsReady("histogram")

        onSlideShowSettingsPopoutElementChanged: {
            if(variables.visibleItem == "slideshowsettings") {
                loader.ensureItIsReady("slideshowsettings")
                loader.show("slideshowsettings")
            }
        }

    }

}
