/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import PQHandlingChromecast 1.0
import PQPrintSupport 1.0

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

            color: (toplevel.visibility==Window.FullScreen&&PQSettings.interfaceFullscreenOverlayColorDifferent) ?
                       Qt.rgba(PQSettings.interfaceFullscreenOverlayColorRed/255.0,
                                  PQSettings.interfaceFullscreenOverlayColorGreen/255.0,
                                  PQSettings.interfaceFullscreenOverlayColorBlue/255.0,
                                  PQSettings.interfaceFullscreenOverlayColorAlpha/255.0) :
                        Qt.rgba(PQSettings.interfaceOverlayColorRed/255.0,
                                   PQSettings.interfaceOverlayColorGreen/255.0,
                                   PQSettings.interfaceOverlayColorBlue/255.0,
                                   PQSettings.interfaceOverlayColorAlpha/255.0)

            Behavior on color { ColorAnimation { duration: 200 } }

            Item {
                id: emptymessage
                x: (parent.width-width)/2
                y: (parent.height-height)/2
                width: parent.width-arrright.width-40
                height: col.height
                visible: filefoldermodel.current==-1&&!filefoldermodel.filterCurrentlyActive&&variables.startupCompleted
                Column {
                    id: col
                    spacing: 5
                    Text {
                        id: openmessage
                        width: emptymessage.width
                        //: Part of the message shown in the main view before any image is loaded
                        text: em.pty+qsTranslate("other", "Click anywhere to open a file")
                        font.pointSize: Math.min(60, Math.max(20, (toplevel.width+toplevel.height)/60))
                        font.bold: true
                        color: "#c0c0c0"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: emptymessage.width
                        //: Part of the message shown in the main view before any image is loaded
                        text: em.pty+qsTranslate("other", "Move your cursor to:")
                        font.pointSize: Math.min(40, Math.max(15, (toplevel.width+toplevel.height)/90))
                        font.bold: true
                        color: "#c0c0c0"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: emptymessage.width
                        //: Part of the message shown in the main view before any image is loaded, first option for where to move cursor to
                        text: ">> " + em.pty+qsTranslate("other", "RIGHT EDGE for the main menu")
                        font.pointSize: Math.max(10, (toplevel.width+toplevel.height)/130)
                        font.bold: true
                        color: "#c0c0c0"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: emptymessage.width
                        visible: PQSettings.metadataElementBehindLeftEdge
                        //: Part of the message shown in the main view before any image is loaded, second option for where to move cursor to
                        text: ">> " + em.pty+qsTranslate("other", "LEFT EDGE for the metadata")
                        font.pointSize: 20
                        font.bold: true
                        color: "#c0c0c0"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Column {
                        Text {
                            width: emptymessage.width
                            //: Part of the message shown in the main view before any image is loaded, third option for where to move cursor to
                            text: ">> " + em.pty+qsTranslate("other", "BOTTOM EDGE to show the thumbnails")
                            font.pointSize: Math.min(30, Math.max(10, (toplevel.width+toplevel.height)/130))
                            font.bold: true
                            color: "#c0c0c0"
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            width: emptymessage.width
                            //: Part of the message shown in the main view before any image is loaded
                            text: em.pty+qsTranslate("other", "(once an image/folder is loaded)")
                            font.pointSize: Math.min(30, Math.max(10, (toplevel.width+toplevel.height)/130))
                            font.bold: true
                            color: "#c0c0c0"
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Image {
                id: arrright
                visible: emptymessage.visible
                anchors.right: parent.right
                anchors.rightMargin: 10
                opacity: 0.5
                y: (parent.height-height)/2
                width: 100
                height: 100
                source: "/mainwindow/rightarrow.png"
            }

            Image {
                id: arrleft
                visible: emptymessage.visible && PQSettings.metadataElementBehindLeftEdge
                anchors.left: parent.left
                anchors.leftMargin: 10
                opacity: 0.5
                y: (parent.height-height)/2
                width: 100
                height: 100
                source: "/mainwindow/leftarrow.png"
            }

            Image {
                id: arrdown
                visible: emptymessage.visible
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                opacity: 0.5
                x: (parent.width-width)/2
                width: 100
                height: 100
                source: "/mainwindow/leftarrow.png"
                rotation: -90
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
            handlingchromecast.cancelScanForChromecast()
        }
    }

    Component.onCompleted:  {
        start()
    }

    PQTrayIcon { id: trayicon }

    PQVariables { id: variables }
    PQCmdReceived { id: cmdreceived }
    PQLoader { id: loader }
    PQWindowSizePopupManager { id: windowsizepopup }

    // this needs to come BEFORE some of the following items
    // otherwise they will not be able to receive mouse events at all
    PQMouseShortcuts { id: mouseshortcuts }

    PQImage { id: imageitem }
    PQStatusInfo { id: statusinfo }
    PQMessage { id: message }
    PQWindowButtons { id: windowbuttons }
    PQWindowButtons { id: windowsbuttons_ontop; visibleAlways: true }

    PQThumbnailBar { id: thumbnails }

    PQContextMenu { id: contextmenu }

    PQModel { id: filefoldermodel }

    Loader { id: histogram }

    Loader { id: metadata }
    Loader { id: navigationfloating }
    Loader { id: mainmenu }

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
    Loader { id: logging }

    Loader { id: chromecast }

    Loader { id: advancedsort }
    Loader { id: advancedsortbusy }

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
    PQHandlingChromecast { id: handlingchromecast }
    PQPrintSupport { id: printsupport }

    PQWindowGeometry { id: windowgeometry }
    PQCppMetaData { id: cppmetadata }

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
            if(PQSettings.interfaceWindowMode) {
                toplevel.visibility = Window.Maximized  // calling this only once does not always restore a maximized window but a 'normal' window
                toplevel.visibility = Window.Maximized  // calling it twice has been observed to correct this situation, though ymmv
            } else
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

        if(PQSettings.interfaceNavigationFloating)
            loader.ensureItIsReady("navigationfloating")

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
        }

        setStartupCompleted.start()

    }

    Timer {
        id: setStartupCompleted
        interval: 200
        running: false
        repeat: false
        onTriggered:
            variables.startupCompleted = true
    }


    function handleBeforeClosing() {

        if(variables.chromecastConnected)
            handlingchromecast.disconnectFromDevice()

        if(variables.slideShowActive)
            loader.passOn("slideshowcontrols", "quit", undefined)

        filefoldermodel.advancedSortMainViewCANCEL()

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
