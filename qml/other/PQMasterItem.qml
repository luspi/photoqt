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
import PhotoQt
import PQCExtensionsHandler

Loader {

    id: masteritemloader

    active: false
    anchors.fill: parent

    property bool isModern: PQCSettings.generalInterfaceVariant==="modern"
    property bool isIntegrated: !isModern

    // If no file has been passed on at startup we don't want to load this item asynchronously.
    // Otherwise the UI will seem to not work when, e.g., immediately clicking to open a file.
    Component.onCompleted: {
        asynchronous = (PQCConstants.startupFilePath === "" || PQCConstants.startupFileIsFolder)
    }

    signal showExtension(var ele)

    sourceComponent:
    Item {

        id: masteritem

        width: parent.parent.width
        height: parent.parent.height

        property bool readyToContinueLoading: false

        PQLoaderTrayIcon { id: loader_trayicon }

        /******************************************/

        // These are the extensions loader
        Repeater {
            id: loader_extensions
            model: PQCExtensionsHandler.numExtensionsEnabled
            PQLoaderExtension {}
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

        PQLoaderThumbnails { id: loader_thumbnails; active: masteritem.readyToContinueLoading }

        /*********************************************************************/

            // MODERN INTERFACE ONLY
            PQLoaderMainMenu         { id: loader_mainmenu; active: masteritemloader.isModern && masteritem.readyToContinueLoading }
            PQLoaderMetaData         { id: loader_metadata; active: masteritemloader.isModern && masteritem.readyToContinueLoading }
            PQLoaderMasterTouchAreas { id: mastertouchareas; active: masteritemloader.isModern && masteritem.readyToContinueLoading }
            PQLoaderWindowHandles    { id: loader_windowhandles; active: masteritemloader.isModern && masteritem.readyToContinueLoading &&
                                                                         PQCSettings.interfaceWindowMode && !PQCSettings.interfaceWindowDecoration }

        PQLoaderContextMenu { id: loader_contextmenu; active: masteritem.readyToContinueLoading }
        PQLoaderToolTipDisplay { active: masteritem.readyToContinueLoading }

        /*****************************************/

        // If an image has been passed on then we wait with loading the rest of the interface until the image has been loaded
        // After 2s of loading we show some first (and quick to set up) interface elements
        // After an additional 2s if the image is still not loaded we also set up the rest of the interface

        // If no image has been passed on we skip all of that and immediately set up the full interface

        Component.onCompleted: {

            // load files in folder
            if(PQCConstants.startupFilePath !== "") {
                // if it's a folder then we already set this property in PQMainWindow::onCompleted
                if(!PQCConstants.startupFileIsFolder)
                    PQCFileFolderModel.fileInFolderMainView = PQCConstants.startupFilePath
                if(PQCConstants.imageInitiallyLoaded) {
                    masteritem.readyToContinueLoading = true
                    finishSetup()
                } else
                    checkForFileFinished.restart()
            } else {
                if(!PQCSettings.filedialogUseNativeFileDialog || PQCConstants.startupFileIsFolder) {
                    PQCNotify.loaderShow("FileDialog")
                }
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
            interval: 200
            property int numRun: 0
            onTriggered: {
                if(numRun > 9) {
                    masteritem.finishSetup()
                    return
                }
                if(!PQCConstants.imageInitiallyLoaded) {
                    masteritem.finishSetup_part1()
                    numRun += 1
                    checkForFileFinished.restart()
                    return
                }
                masteritem.finishSetup()
            }
        }

        Timer {
            id: showExtensionWhenReady
            property Loader theloader
            property list<var> args: []
            interval: 10
            triggeredOnStart: true
            onTriggered: {
                if(theloader.status !== Loader.Ready) {
                    showExtensionWhenReady.start()
                    return
                }
                PQCNotify.loaderPassOn("show", args)
                args = []
            }
        }

        Timer {
            id: showExtensionWhenReady2
            property Loader theloader
            property list<var> args: []
            interval: 10
            triggeredOnStart: true
            onTriggered: {
                if(theloader.status !== Loader.Ready) {
                    showExtensionWhenReady2.start()
                    return
                }
                PQCNotify.loaderPassOn("show", args)
                args = []
            }
        }

        property int finishSetupCalled: 0

        function finishSetup() {
            if(finishSetupCalled == 0)
                finishSetup_part1()
            if(finishSetupCalled == 1)
                finishSetup_part2()
        }

        function finishSetup_part1() {
            finishSetupCalled += 1
            masteritem.readyToContinueLoading = true
        }

        function finishSetup_part2() {

            finishSetupCalled += 1

            PQCExtensionsHandler.setup()
            PQCExtensionMethods.setup()
            PQCExtensionProperties.setup()

            waitForExtLoaderToBeReady.start()

            if(PQCConstants.startupHaveSettingUpdate.length === 2) {
                var ret = PQCSettings.updateFromCommandLine();
                for(var i in ret) {
                    if(ret[i] === "interfaceLanguage")
                        PQCScriptsLocalization.updateTranslation(PQCSettings.interfaceLanguage)
                }
            }

        }

        Connections {

            target: masteritemloader

            function onShowExtension(ele : string) {

                console.log("args: ele =", ele)

                var ind = PQCExtensionsHandler.getExtensions().indexOf(ele)
                if(ind === -1) {
                    console.warn("Unknown extension requested:", ele)
                    return
                }

                if(PQCExtensionsHandler.getExtensionModal(ele)) {
                    if(PQCConstants.idOfVisibleItem !== "")
                        return
                    else
                        PQCConstants.idOfVisibleItem = ele
                }

                loader_extensions.itemAt(ind).active = true

                // modal elements need to be shown on top, above things like mainmenu or metadata
                // The value should be high but lower than that of the window buttons that are shown on top (currently set to 999)
                if(PQCExtensionsHandler.getExtensionModal(ele))
                    loader_extensions.itemAt(ind).z = 888

                if(!loader_extensions.itemAt(ind).item) {
                    if(showExtensionWhenReady.args.length == 0) {
                        showExtensionWhenReady.theloader = loader_extensions.itemAt(ind)
                        showExtensionWhenReady.args = [ele]
                        showExtensionWhenReady.start()
                    } else if(showExtensionWhenReady2.args.length == 0) {
                        showExtensionWhenReady2.theloader = loader_extensions.itemAt(ind)
                        showExtensionWhenReady2.args = [ele]
                        showExtensionWhenReady2.start()
                    } else
                        console.error("Unable to set up extension, too few timers available.")
                } else {
                    PQCNotify.loaderPassOn("show", [ele])
                }

            }

        }

        Connections {

            target: PQCNotify

            function onLoaderSetupExtension(ele : string) {
                var ind = PQCExtensionsHandler.getExtensions().indexOf(ele)
                loader_extensions.itemAt(ind).active = true
                if(PQCExtensionsHandler.getExtensionModal(ele))
                    loader_extensions.itemAt(ind).z = 888
            }

            function onLoaderShowExtension(ele : string) {
                PQCNotify.loaderShow(ele)
            }

        }

    }

}
