/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.9
import QtQuick.Window 2.2

import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQHandlingFileDir 1.0
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
                    ("file://" + handlingFileDir.getTempDir() + "/photoqt_screenshot_0.jpg") :
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

        loader.ensureItIsReady("mainmenu")
        loader.ensureItIsReady("metadata")

        if(PQSettings.histogram)
            loader.ensureItIsReady("histogram")

        var filenameToLoad = handlingGeneral.getLastLoadedImage()

        if(PQCppVariables.cmdFilePath != "" || (PQSettings.startupLoadLastLoadedImage && filenameToLoad != "")) {

            if(PQCppVariables.cmdFilePath != "")
                filenameToLoad = PQCppVariables.cmdFilePath

            var folderToLoad = handlingFileDir.getFilePathFromFullPath(filenameToLoad)

            LoadFiles.loadFile(folderToLoad)

            variables.openCurrentDirectory = folderToLoad

            if(handlingFileDir.isDir(filenameToLoad)) {
                if(variables.allImageFilesInOrder.length == 0) {
                    loader.show("filedialog")
                    variables.openCurrentDirectory = filenameToLoad
                    return
                } else
                    filenameToLoad = variables.allImageFilesInOrder[0]
            }
            variables.indexOfCurrentImage = variables.allImageFilesInOrder.indexOf(filenameToLoad)
            variables.newFileLoaded()

        } else
            loader.show("filedialog")

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
    Loader { id: copymove }

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
    PQHandlingFileDir { id: handlingFileDir }
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
