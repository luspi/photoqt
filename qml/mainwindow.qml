/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
import PQCppMetaData 1.0
import PQHandlingShareImgur 1.0
import PQHandlingWallpaper 1.0
import PQHandlingFaceTags 1.0
import PQHandlingExternal 1.0
import PQShortcuts 1.0

import "./mainwindow"
import "./shortcuts"
import "./menumeta"
import "./histogram"
import "./slideshow"
import "./settingsmanager"

Window {

    id: toplevel

    visibility: Window.Hidden
    flags: PQSettings.interfaceWindowDecoration ?
               (PQSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint) : Qt.FramelessWindowHint)

    minimumWidth: 600
    minimumHeight: 400

    color: "#00000000"

    Image {

        id: bgimage

        anchors.fill: parent

        source: PQSettings.interfaceBackgroundImageScreenshot ?
                    ("image://full/" + handlingFileDir.getTempDir() + "/photoqt_screenshot_0.jpg") :
                    (PQSettings.interfaceBackgroundImageUse ? ("image://full/"+PQSettings.interfaceBackgroundImagePath) : "")

        fillMode: PQSettings.interfaceBackgroundImageScale ?
                      Image.PreserveAspectFit :
                      PQSettings.interfaceBackgroundImageScaleCrop ?
                          Image.PreserveAspectCrop :
                          PQSettings.interfaceBackgroundImageStretch ?
                              Image.Stretch :
                              PQSettings.interfaceBackgroundImageCenter ?
                                  Image.Pad :
                                  Image.Tile

        Rectangle {

            anchors.fill: parent

            color: Qt.rgba(PQSettings.interfaceOverlayColorRed/256.0,
                           PQSettings.interfaceOverlayColorGreen/256.0,
                           PQSettings.interfaceOverlayColorBlue/256.0,
                           PQSettings.interfaceOverlayColorAlpha/256.0)

            Text {
                id: emptymessage
                anchors.fill: parent
                anchors.leftMargin: arrleft.x+arrleft.width+10
                anchors.rightMargin: parent.width-arrright.x - 20
                text: em.pty+qsTranslate("other", "Open a file to begin")
                visible: filefoldermodel.current==-1&&!filefoldermodel.filterCurrentlyActive
                font.pointSize: 50
                font.bold: true
                color: "#bb808080"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Image {
                id: arrright
                visible: emptymessage.visible
                anchors.right: parent.right
                anchors.rightMargin: 10
                opacity: 0.5
                y: (parent.height-height)/2
                width: 50
                height: 50
                source: "/mainwindow/rightarrow.png"
            }

            Image {
                id: arrleft
                visible: emptymessage.visible
                anchors.left: parent.left
                anchors.leftMargin: 10
                opacity: 0.5
                y: (parent.height-height)/2
                width: 50
                height: 50
                source: "/mainwindow/leftarrow.png"
            }

            Text {
                id: filtermessage
                anchors.centerIn: parent
                //: Used as in: No matches found for the currently set filter
                text: em.pty+qsTranslate("other", "No matches found")
                visible: filefoldermodel.current==-1&&filefoldermodel.filterCurrentlyActive
                font.pointSize: 50
                font.bold: true
                color: "#bb808080"
            }

        }

    }

    //: The window title of PhotoQt
    title: (filefoldermodel.currentFilePath=="" ? "" : (handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath) + " | "))+ em.pty+qsTranslate("other", "PhotoQt Image Viewer")

    onClosing: {

        handleBeforeClosing()

        if(PQSettings.interfaceTrayIcon == 1) {
            close.accepted = false
            toplevel.visible = false
        } else {
            close.accepted = true
            Qt.quit()
        }
    }

    Component.onCompleted:  {
        start()
    }

    PQTrayIcon { id: trayicon }

    PQVariables { id: variables }
    PQCmdReceived { id: cmdreceived }
    PQLoader { id: loader }

    // this needs to come BEFORE some of the following items
    // otherwise they will not be able to receive mouse events at all
    PQMouseShortcuts { id: mouseshortcuts }

    PQImage { id: imageitem }
    PQLabels { id: labels }
    PQMessage { id: message }
    PQWindowButtons { id: windowbuttons }

    PQThumbnailBar { id: thumbnails }

    PQContextMenu { id: contextmenu }

    PQModel { id: filefoldermodel }

    Loader { id: histogram }

    Loader { id: mainmenu }
    Loader { id: metadata }
    Loader { id: quicknavigation }

    Loader { id: slideshowsettings }
    Loader { id: slideshowcontrols }
    Loader { id: filedialog }

    Loader { id: filerename }
    Loader { id: filedelete }
    Loader { id: copymove }
    Loader { id: filesaveas }

    Loader { id: scaleimage }
    Loader { id: about }
    Loader { id: imgur }
    Loader { id: wallpaper }
    Loader { id: filter }
    Loader { id: settingsmanager }

    Loader { id: unavailable }
    Loader { id: unavailablepopout }

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

    PQShortcuts { id: shortcutsettings }
    PQKeyShortcuts { id: shortcuts }
    PQKeyMouseStrings { id: keymousestrings }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation {
        id : em
        Component.onCompleted:
            em.setLanguage(PQSettings.interfaceLanguage)
    }

    Connections {
        target: PQSettings
        onInterfaceLanguageChanged:
            em.setLanguage(PQSettings.interfaceLanguage)
        onInterfaceWindowModeChanged: {
            if(PQSettings.interfaceWindowMode)
                toplevel.visibility = Window.Maximized
            else
                toplevel.visibility = Window.FullScreen
        }
    }

    Connections {
        target: filefoldermodel
        onCurrentFilePathChanged: {
            cppmetadata.updateMetadata(filefoldermodel.currentFilePath)
        }
    }

    function start() {

        if(PQSettings.interfaceWindowMode) {

            if(PQSettings.interfaceSaveWindowGeometry)
                visibility = Window.Windowed

            else if(PQSettings.interfacePopoutMainMenu == 1 &&
                    PQSettings.interfacePopoutMetadata == 1 &&
                    PQSettings.interfacePopoutHistogram == 1 &&
                    PQSettings.interfacePopoutScale == 1 &&
                    PQSettings.interfacePopoutOpenFile == 1 &&
                    PQSettings.interfacePopoutSlideShowSettings == 1 &&
                    PQSettings.interfacePopoutSlideShowControls == 1 &&
                    PQSettings.interfacePopoutFileRename == 1 &&
                    PQSettings.interfacePopoutFileDelete == 1 &&
                    PQSettings.interfacePopoutAbout == 1 &&
                    PQSettings.interfacePopoutImgur == 1 &&
                    PQSettings.interfacePopoutWallpaper == 1 &&
                    PQSettings.interfacePopoutFilter == 1 &&
                    PQSettings.interfacePopoutSettingsManager == 1 &&
                    PQSettings.interfacePopoutFileSaveAs == 1)

                visibility = Window.Windowed

            else
                visibility = Window.Maximized

        } else
            visibility = Window.FullScreen

        if(PQSettings.interfaceSaveWindowGeometry) {

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

        if(PQSettings.histogramVisible)
            loader.ensureItIsReady("histogram")

        if(PQSettings.interfaceQuickNavigation)
            loader.ensureItIsReady("quicknavigation")

        var filenameToLoad = handlingGeneral.getLastLoadedImage()

        if(PQPassOn.getFilePath() != "" || (PQSettings.interfaceRememberLastImage && filenameToLoad != "")) {

            if(PQPassOn.getFilePath() != "")
                filenameToLoad = PQPassOn.getFilePath()

            var folderToLoad = handlingFileDir.getFilePathFromFullPath(filenameToLoad)

            if(handlingFileDir.isDir(filenameToLoad)) {
                loader.show("filedialog")
                filefoldermodel.folderFileDialog = filenameToLoad
            } else {
                filefoldermodel.setFileNameOnceReloaded = filenameToLoad
                filefoldermodel.fileInFolderMainView = filenameToLoad
                filefoldermodel.folderFileDialog = folderToLoad
            }

        } else {
            if(PQSettings.openfileKeepLastLocation)
                filefoldermodel.folderFileDialog = handlingFileDialog.getLastLocation()
            else
                filefoldermodel.folderFileDialog = handlingFileDir.getHomeDir()
            loader.show("filedialog")
        }

    }

    function handleBeforeClosing() {

        if(variables.slideShowActive)
            loader.passOn("slideshowcontrols", "quit", undefined)

        if(PQSettings.interfaceSaveWindowGeometry) {
            windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
            windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
        }
        if(filefoldermodel.current > -1 && PQSettings.interfaceRememberLastImage)
            handlingGeneral.setLastLoadedImage(filefoldermodel.currentFilePath)
        else
            handlingGeneral.deleteLastLoadedImage()
        handlingGeneral.cleanUpScreenshotsTakenAtStartup()

    }

    function quitPhotoQt() {
        handleBeforeClosing()
        Qt.quit()
    }

    function closePhotoQt() {
        close()
    }

}
