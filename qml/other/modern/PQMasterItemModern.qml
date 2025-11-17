/**************************************************************************
 **                                                                      **
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
import PQCExtensionsHandler
import PhotoQt

Loader {

    id: masteritemloader

    active: false
    anchors.fill: parent

    // If no file has been passed on at startup we don't want to load this item asynchronously.
    // Otherwise the UI will seem to not work when, e.g., immediately clicking to open a file.
    Component.onCompleted: {
        asynchronous = (PQCConstants.startupFilePath === "" || PQCConstants.startupFileIsFolder)
    }

    // this tells us when the background message is ready
    // that way we can have an active mouse area to register clicks right away
    // this will make the UI appear more responsive
    property bool backgroundMessageReady: false

    sourceComponent:
    Item {

        id: masteritem

        anchors.fill: masteritemloader

        property bool readyToContinueLoading: false

        Loader {
            id: bgmessage
            asynchronous: true
            sourceComponent: PQBackgroundMessageModern {}
            onStatusChanged: (status) => {
                if(status === Loader.Ready)
                    masteritemloader.backgroundMessageReady = true
            }
        }

        // The tray icon loads right away WITHOUT any delay.
        Loader {
            id: loader_trayicon
            asynchronous: true
            sourceComponent: PQTrayIcon {}
        }

        Loader {
            id: windowbuttons
            asynchronous: true
            active: masteritem.readyToContinueLoading
            sourceComponent: PQWindowButtonsModern {}
        }
        Loader {
            id: windowbuttons_ontop
            asynchronous: true
            active: masteritem.readyToContinueLoading
            sourceComponent: PQWindowButtonsModern {}
            visible: opacity>0
            opacity: PQCConstants.idOfVisibleItem!=="" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            z: PQCConstants.idOfVisibleItem!=="FileDialog" ? 999 : 0
            onStatusChanged: {
                if(windowbuttons_ontop.status == Loader.Ready)
                    windowbuttons_ontop.item.visibleAlways = true
            }
        }

        Loader {
            id: statusinfo
            active: masteritem.readyToContinueLoading
            asynchronous: true
            sourceComponent: PQStatusInfoModern {}
        }

        /******************************************/

        // These are the extensions loader
        Repeater {
            id: loader_extensions
            model: PQCExtensionsHandler.numExtensions
            Loader {

                id: ldr

                required property int modelData

                active: false
                asynchronous: false

                sourceComponent:
                PQTemplateExtensionContainer {

                    extensionId: PQCExtensionsHandler.getExtensions()[ldr.modelData]

                }

            }

        }

        // we check for this with a little delay to allow for other things to get ready first
        Timer {
            id: waitForExtLoaderToBeReady
            interval: 200
            onTriggered: {
                // set up extensions if necessary
                var exts = PQCExtensionsHandler.getExtensions()
                for(var iE in exts) {
                    var ext = exts[iE]
                    if(PQCSettings.generalExtensionsEnabled.indexOf(ext) > -1 && PQCSettings.generalExtensionsFloatingSetup.indexOf(ext) > -1) {
                        PQCNotify.loaderSetupExtension(ext)
                    }
                }
            }
        }

        /******************************************/

        // the thumbnails loader can be asynchronous as it is always integrated and never popped out
        Loader {
            id: loader_thumbnails
            active: masteritem.readyToContinueLoading
            asynchronous: true
            sourceComponent: PQThumbnails {}
        }

        PQLoaderModern { id: masterloader }

        Loader {
            id: mastertouchareas
            active: masteritem.readyToContinueLoading
            asynchronous: true
            sourceComponent: PQGestureTouchAreasModern {}
        }

        /******************************************/

        Loader {
            id: loader_windowhandles
            asynchronous: true
            active: masteritem.readyToContinueLoading && PQCSettings.interfaceWindowMode && !PQCSettings.interfaceWindowDecoration
            sourceComponent: PQWindowHandlesModern {}
        }

        Loader {
            id: loader_contextmenu
            active: masteritem.readyToContinueLoading
            asynchronous: true
            sourceComponent: PQContextMenu {}
        }

        /******************************************/

        Loader {
            id: loader_filedialog
            active: false
            anchors.fill: parent
            sourceComponent: PQCSettings.filedialogUseNativeFileDialog ?
                                 comp_filedialog_native :
                                 ((PQCSettings.interfacePopoutFileDialog || PQCWindowGeometry.filedialogForcePopout) ? comp_filedialog_popout : comp_filedialog)
            Connections {
                target: PQCNotify
                function onLoaderShow(ele : string) {
                    if(ele === "FileDialog") {
                        loader_filedialog.active = true
                        if(!PQCSettings.interfacePopoutFileDialog || !PQCSettings.interfacePopoutFileDialogNonModal)
                            PQCConstants.idOfVisibleItem = "FileDialog"
                        PQCNotify.loaderPassOn("show", ["FileDialog"])
                    }
                }
            }
        }
        Component { id: comp_filedialog_native; PQFileDialogNative {} }
        Component {
            id: comp_filedialog
            PQTemplateModal {
                id: smmod
                function showing() { return tmpl.showing() }
                function hiding() { return tmpl.hiding() }
                showTopBottom: false
                dontAnimateFirstShow: true
                content: PQFileDialog {
                    id: tmpl
                    button1: smmod.button1
                    button2: smmod.button2
                    button3: smmod.button3
                    bottomLeft: smmod.bottomLeft
                    popInOutButton: smmod.popInOutButton
                    availableHeight: smmod.contentHeight
                    Component.onCompleted: {
                        smmod.elementId = elementId
                        smmod.title = title
                        smmod.letElementHandleClosing = letMeHandleClosing
                        smmod.bottomLeftContent = bottomLeftContent
                    }
                }
            }
        }
        Component {
            id: comp_filedialog_popout
            PQTemplateModalPopout {
                id: smpop
                defaultPopoutGeometry: PQCWindowGeometry.filedialogGeometry
                defaultPopoutMaximized: PQCWindowGeometry.filedialogMaximized
                function showing() { return tmpl.showing() }
                function hiding() { return tmpl.hiding() }
                showTopBottom: false
                onRectUpdated: (r) => {
                    PQCWindowGeometry.filedialogGeometry = r
                }
                onMaximizedUpdated: (m) => {
                    PQCWindowGeometry.filedialogMaximized = m
                }
                content: PQFileDialog {
                    id: tmpl
                    button1: smpop.button1
                    button2: smpop.button2
                    button3: smpop.button3
                    bottomLeft: smpop.bottomLeft
                    popInOutButton: smpop.popInOutButton
                    availableHeight: smpop.contentHeight
                    Component.onCompleted: {
                        smpop.elementId = elementId
                        smpop.title = title
                        smpop.letElementHandleClosing = letMeHandleClosing
                        smpop.bottomLeftContent = bottomLeftContent
                    }
                }
            }
        }

        /******************************************/

        Loader {
            active: masteritem.readyToContinueLoading
            sourceComponent: PQToolTipDisplay {}
        }

        /*****************************************/

        // If an image has been passed on then we wait with loading the rest of the interface until the image has been loaded
        // After 2s of loading we show some first (and quick to set up) interface elements
        // After an additional 2s if the image is still not loaded we also set up the rest of the interface

        // If no image has been passed on we skip all of that and immediately set up the full interface

        Component.onCompleted: {

            // load files in folder
            if(PQCConstants.startupFilePath !== "") {
                PQCFileFolderModel.fileInFolderMainView = PQCConstants.startupFilePath
                if(PQCConstants.imageInitiallyLoaded) {
                    masteritem.readyToContinueLoading = true
                    finishSetup()
                } else
                    checkForFileFinished.restart()
            } else {
                masteritem.readyToContinueLoading = true
                finishSetup()
            }

            if(PQCConstants.startupFilePath === "" || (PQCFileFolderModel.firstFolderMainViewLoaded && PQCFileFolderModel.countMainView === 0)) {
                PQCNotify.loaderShow("FileDialog")
            }

        }

        Connections {
            target: PQCConstants
            enabled: PQCConstants.startupFilePath!==""
            function onImageInitiallyLoadedChanged() {
                // don't rely on checking whether the timer below is running.
                // For very small/fast images we might get here BEFORE that timer reports as running!
                if(PQCConstants.imageInitiallyLoaded && masteritem.finishSetupCalled < 2) {
                    checkForFileFinished.stop()
                    if(masteritem.finishSetupCalled == 0)
                        masteritem.finishSetup()
                    else if(masteritem.finishSetupCalled == 1)
                        masteritem.finishSetup_part2()
                }
            }
        }

        Timer {
            id: checkForFileFinished
            interval: 2000
            property bool secondrun: false
            onTriggered: {
                if(secondrun) {
                    masteritem.finishSetup_part2()
                    return
                }
                if(!PQCConstants.imageInitiallyLoaded) {
                    masteritem.finishSetup_part1()
                    secondrun = true
                    checkForFileFinished.restart()
                    return
                }
                masteritem.finishSetup()
            }
        }

        property int finishSetupCalled: 0

        function finishSetup() {
            finishSetup_part1()
            finishSetup_part2()
        }

        function finishSetup_part1() {
            finishSetupCalled += 1
            masteritem.readyToContinueLoading = true
            PQCNotify.loaderSetup("MainMenu")
            PQCNotify.loaderSetup("MetaData")
        }

        function finishSetup_part2() {
            finishSetupCalled += 1
            PQCNotify.loaderSetup("thumbnails")

            PQCExtensionsHandler.setup()

            waitForExtLoaderToBeReady.start()

            if(PQCConstants.startupHaveSettingUpdate.length === 2)
                PQCSettings.updateFromCommandLine();

            PQCSettings.generalInterfaceVariant = "modern"

        }

    }

}
