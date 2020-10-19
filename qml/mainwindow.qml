import QtQuick 2.9
import QtQuick.Window 2.2

import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQHandlingFileManagement 1.0
import PQHandlingManipulation 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQFileWatcher 1.0
import PQWindowGeometry 1.0
import PQFileFolderModel 1.0
import PQCppMetaData 1.0
import PQHandlingShareImgur 1.0
import PQHandlingWallpaper 1.0
import PQHandlingFaceTags 1.0
import PQSystemTrayIcon 1.0
import PQHandlingExternal 1.0

import "./mainwindow"
import "./shortcuts"
import "./menumeta"
import "./histogram"
import "./slideshow"
import "./settingsmanager"

import "./loadfiles.js" as LoadFiles

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

        id: bgimage

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

            Text {
                id: emptymessage
                anchors.centerIn: parent
                text: em.pty+qsTranslate("other", "Open a file to begin")
                visible: !variables.filterSet&&variables.indexOfCurrentImage==-1
                font.pointSize: 50
                font.bold: true
                color: "#bb808080"
            }

            Text {
                id: filtermessage
                anchors.centerIn: parent
                //: Used as in: No matches found for the currently set filter
                text: em.pty+qsTranslate("other", "No matches found")
                visible: variables.filterSet&&variables.indexOfCurrentImage==-1
                font.pointSize: 50
                font.bold: true
                color: "#bb808080"
            }

        }

    }

    //: The window title of PhotoQt
    title: em.pty+qsTranslate("other", "PhotoQt Image Viewer")

    onClosing: {

        if(variables.slideShowActive)
            loader.passOn("slideshowcontrols", "quit", undefined)

        if(PQSettings.saveWindowGeometry) {
            windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
            windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
        }
        if(variables.indexOfCurrentImage > -1 && PQSettings.startupLoadLastLoadedImage)
            handlingGeneral.setLastLoadedImage(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
        else
            handlingGeneral.deleteLastLoadedImage()
        handlingGeneral.cleanUpScreenshotsTakenAtStartup()

        if(PQSettings.trayIcon == 1) {
            close.accepted = false
            toplevel.visible = false
        } else {
            close.accepted = true
            Qt.quit()
        }
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

            LoadFiles.loadFile(folderToLoad)

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

    PQSystemTrayIcon {
        id: trayicon
        visible: PQSettings.trayIcon>0
        trayIconSetting: PQSettings.trayIcon
        onToggleAction: {
            if(PQSettings.trayIcon == 1)
                toplevel.visible = !toplevel.visible
        }
        onQuitAction: {
            Qt.quit();
        }
    }

    // needed to load folders without PQFileDialog
    PQFileFolderModel { id: filefoldermodel }

    PQVariables { id: variables }
    PQLoader { id: loader }

    PQMouseShortcuts { id: mouseshortcuts }

    PQImage { id: imageitem }
    PQQuickInfo { id: quickinfo }
    PQMessage { id: message }
    PQCloseButton { id: closebutton }

    PQThumbnailBar { id: thumbnails }

    Loader { id: histogram }

    Loader { id: mainmenu }
    Loader { id: metadata }

    Loader { id: slideshowsettings }
    Loader { id: slideshowcontrols }
    Loader { id: filedialog }

    Loader { id: filerename }
    Loader { id: filedelete }

    Loader { id: scaleimage }
    Loader { id: about }
    Loader { id: imgur }
    Loader { id: wallpaper }
    Loader { id: filter }
    Loader { id: settingsmanager }

    PQImageProperties { id: imageproperties }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }
    PQHandlingShortcuts { id: handlingShortcuts }
    PQHandlingFileManagement { id: handlingFileManagement }
    PQHandlingManipulation { id: handlingManipulation }
    PQHandlingShareImgur { id: handlingShareImgur }
    PQHandlingWallpaper { id: handlingWallpaper }
    PQHandlingFaceTags { id: handlingFaceTags }
    PQHandlingExternal { id: handlingExternal }

    PQWindowGeometry { id: windowgeometry }
    PQCppMetaData { id: cppmetadata }

    PQKeyShortcuts { id: shortcuts }
    PQKeyMouseStrings { id: keymousestrings }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation {
        id : em
        Component.onCompleted:
            em.setLanguage(PQSettings.language)
    }

    Connections {
        target: PQSettings
        onLanguageChanged:
            em.setLanguage(PQSettings.language)
    }

    function quitPhotoQt() {
        Qt.quit()
    }

    function closePhotoQt() {

        if(PQSettings.trayIcon == 1)
            close()
        else
            Qt.quit()

    }

}
