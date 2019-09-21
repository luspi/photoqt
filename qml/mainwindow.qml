import QtQuick 2.9
import QtQuick.Window 2.9

import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQFileWatcher 1.0
import PQWindowGeometry 1.0
import PQFileFolderModel 1.0
import PQCppMetaData 1.0

import "./mainwindow"
import "./shortcuts"
import "./menumeta"
import "./histogram"
import "./slideshow"

Window {

    id: toplevel

    visible: true

    visibility: PQSettings.windowMode ? (PQSettings.saveWindowGeometry ? Window.Windowed : Window.Maximized) : Window.FullScreen
    flags: PQSettings.windowDecoration ?
               (PQSettings.keepOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQSettings.keepOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint) : Qt.FramelessWindowHint)

    minimumWidth: 600
    minimumHeight: 400

    width: 1024
    height: 768

    color: "#00000000"

    Image {

        anchors.fill: parent

        source: PQSettings.backgroundImageScreenshot ?
                    ("file://" + handlingGeneral.getTempDir() + "/photoqt_screenshot_0.jpg") :
                    (PQSettings.backgroundImageUse ? ("file://"+PQSettings.backgroundImagePath) : "")

        fillMode: PQSettings.backgroundImageScale ?
                      Image.PreserveAspectFit :
                      PQSettings.backgroundImageScaleCrop ?
                          Image.PreserveAspectCrop :
                          PQSettings.backgroundImageStretch ?
                              Image.Stretch :
                              PQSettings.backgroundImageCenter ?
                                  Image.Pad :
                                  Image.Tile

        Rectangle {

            anchors.fill: parent

            color: Qt.rgba(PQSettings.backgroundColorRed/256.0,
                           PQSettings.backgroundColorGreen/256.0,
                           PQSettings.backgroundColorBlue/256.0,
                           PQSettings.backgroundColorAlpha/256.0)

        }

    }

    title: em.pty+qsTranslate("other", "PhotoQt Image Viewer")

    onClosing: {

        if(variables.slideShowActive)
            loader.passOn("slideshowcontrols", "quit", undefined)

        if(PQSettings.saveWindowGeometry) {
            windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
            windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
        }
        if(variables.indexOfCurrentImage > -1)
            handlingGeneral.setLastLoadedImage(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
        handlingGeneral.cleanUpScreenshotsTakenAtStartup()
        close.accepted = true
    }

    Component.onCompleted:  {

        if(PQSettings.saveWindowGeometry) {

            if(windowgeometry.mainWindowMaximized)

                toplevel.visibility = Window.Maximized

            else {

                toplevel.setX(windowgeometry.mainWindowGeometry.x)
                toplevel.setY(windowgeometry.mainWindowGeometry.y)
                toplevel.setWidth(windowgeometry.mainWindowGeometry.width)
                toplevel.setHeight(windowgeometry.mainWindowGeometry.height)

            }

        }

        var filenameToLoad = handlingGeneral.getLastLoadedImage()

        if(PQCppVariables.cmdFilePath != "" || (PQSettings.startupLoadLastLoadedImage && filenameToLoad != "")) {

            if(PQCppVariables.cmdFilePath != "")
                filenameToLoad = PQCppVariables.cmdFilePath

            var folderToLoad = handlingGeneral.getFilePathFromFullPath(filenameToLoad)

            var sortField = PQSettings.sortby=="name" ?
                                PQFileFolderModel.Name :
                                (PQSettings.sortby == "naturalname" ?
                                    PQFileFolderModel.NaturalName :
                                    (PQSettings.sortby == "time" ?
                                        PQFileFolderModel.Time :
                                        (PQSettings.sortby == "size" ?
                                            PQFileFolderModel.Size :
                                            PQFileFolderModel.Type)))

            variables.allImageFilesInOrder = filefoldermodel.loadFilesInFolder(folderToLoad, PQSettings.openShowHiddenFilesFolders, PQImageFormats.getAllEnabledFileformats(), sortField, !PQSettings.sortbyAscending)

            variables.openCurrentDirectory = folderToLoad

            if(handlingGeneral.isDir(filenameToLoad)) {
                if(variables.allImageFilesInOrder.length == 0) {
                    loader.show("filedialog")
                    variables.openCurrentDirectory = filenameToLoad
                }else {
                    filenameToLoad = variables.allImageFilesInOrder[0]
                    variables.indexOfCurrentImage = variables.allImageFilesInOrder.indexOf(filenameToLoad)
                }
            } else
                variables.indexOfCurrentImage = variables.allImageFilesInOrder.indexOf(filenameToLoad)

        } else
            loader.show("filedialog")

        loader.ensureItIsReady("mainmenu")
        loader.ensureItIsReady("metadata")

        if(PQSettings.histogram)
            loader.ensureItIsReady("histogram")

    }

    // needed to load folders without PQFileDialog
    PQFileFolderModel { id: filefoldermodel }

    PQVariables { id: variables }
    PQLoader { id: loader }

    PQMouseShortcuts { id: mouseshortcuts }

    PQImage { id: imageitem }
    PQQuickInfo { id: quickinfo }
    PQCloseButton { id: closebutton }

    PQThumbnailBar { id: thumbnails }

    Loader { id: histogram }

    Loader { id: mainmenu }
    Loader { id: metadata }

    Loader { id: slideshowsettings }
    Loader { id: slideshowcontrols }
    Loader { id: filedialog }

    PQImageProperties { id: imageproperties }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }
    PQHandlingShortcuts { id: handlingShortcuts }

    PQWindowGeometry { id: windowgeometry }
    PQCppMetaData { id: cppmetadata }

    PQKeyShortcuts { id: shortcuts }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation { id : em }

    function quitPhotoQt() {
        close()
    }

    function closePhotoQt() {

        // TODO: check tray icon setting and potentially only hide window

        close()
    }

}
