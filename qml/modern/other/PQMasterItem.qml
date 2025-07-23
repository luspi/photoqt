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
import PhotoQt.Modern

Loader {

    id: masteritemloader

    active: false

    // If no file has been passed on at startup we don't want to load this item asynchronously.
    // Otherwise the UI will seem to not work when, e.g., immediately clicking to open a file.
    Component.onCompleted: {
        asynchronous = (PQCConstants.startupFilePath === "")
    }

    // this tells us when the background message is ready
    // that way we can have an active mouse area to register clicks right away
    // this will make the UI appear more responsive
    property bool backgroundMessageReady: false

    sourceComponent:
    Item {

        id: masteritem

        anchors.fill: parent

        property bool readyToContinueLoading: false

        PQLoader { id: masterloader }

        Loader {
            id: bgmessage
            asynchronous: true
            source: "PQBackgroundMessage.qml"
            onStatusChanged: (status) => {
                if(status === Loader.Ready)
                    masteritemloader.backgroundMessageReady = true
            }
        }

        // The tray icon loads right away WITHOUT any delay.
        Loader {
            id: loader_trayicon
            asynchronous: true
            source: "../ongoing/PQTrayIcon.qml"
        }

        Loader {
            id: windowbuttons
            asynchronous: true
            active: masteritem.readyToContinueLoading
            source: "../ongoing/PQWindowButtons.qml"
        }
        Loader {
            id: windowbuttons_ontop
            asynchronous: true
            active: masteritem.readyToContinueLoading
            source: "../ongoing/PQWindowButtons.qml"
            visible: opacity>0
            opacity: PQCConstants.idOfVisibleItem!=="" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            z: PQCConstants.idOfVisibleItem!=="filedialog" ? 999 : 0
            onStatusChanged: {
                if(windowbuttons_ontop.status == Loader.Ready)
                    windowbuttons_ontop.item.visibleAlways = true
            }
        }

        Loader {
            id: statusinfo
            active: masteritem.readyToContinueLoading
            asynchronous: true
            source: "../ongoing/PQStatusInfo.qml"
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
                    if(PQCSettings.generalEnabledExtensions.indexOf(ext) > -1 && PQCSettings.generalSetupFloatingExtensionsAtStartup.indexOf(ext) > -1) {
                        PQCNotify.loaderSetupExtension(ext)
                    }
                }
            }
        }

        /******************************************/

        // the thumbnails loader can be asynchronous as it is always integrated and never popped out
        Loader {
            id: loader_thumbnails
            asynchronous: true;
        }

        Loader { id: loader_metadata }
        Loader { id: loader_mainmenu }
        Loader { id: loader_notification }
        Loader { id: loader_chromecast }
        Loader { id: loader_slideshowcontrols }
        Loader { id: loader_slideshowhandler }
        Loader { id: loader_logging }

        Loader {
            id: mastertouchareas
            active: masteritem.readyToContinueLoading
            asynchronous: true
            source: "PQGestureTouchAreas.qml"
        }

        /******************************************/

        Loader {
            id: loader_windowhandles
            asynchronous: true
            active: masteritem.readyToContinueLoading && PQCSettings.interfaceWindowMode && !PQCSettings.interfaceWindowDecoration
            source: "../ongoing/PQWindowHandles.qml"
        }

        Loader {
            id: loader_contextmenu
            active: masteritem.readyToContinueLoading
            asynchronous: true
            source: "../ongoing/PQContextMenu.qml"
        }

        /******************************************/

        Loader { id: loader_mapexplorer }
        Loader { id: loader_about }
        Loader { id: loader_advancedsort }
        Loader { id: loader_filedelete }
        Loader { id: loader_copy }
        Loader { id: loader_move }
        Loader { id: loader_filerename }
        Loader { id: loader_filter }
        Loader { id: loader_slideshowsetup }
        Loader { id: loader_chromecastmanager }
        Loader { id: loader_filedialog }
        Loader { id: loader_settingsmanager }

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
            PQCNotify.loaderSetup("mainmenu")
            PQCNotify.loaderSetup("metadata")
        }

        function finishSetup_part2() {
            finishSetupCalled += 1
            PQCNotify.loaderSetup("thumbnails")

            PQCExtensionsHandler.setup()

            waitForExtLoaderToBeReady.start()

            if(PQCConstants.startupHaveSettingUpdate.length === 2)
                PQCSettings.updateFromCommandLine();

        }

    }

}
