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

import PQCFileFolderModel

import "../ongoing"

Loader {

    id: masteritemloader

    active: false
    asynchronous: true

    sourceComponent:
    Item {

        id: masteritem

        anchors.fill: parent

        property bool readyToContinueLoading: false

        PQLoader { id: masterloader }

        // status info
        Loader { id: statusinfo; active: masteritem.readyToContinueLoading; asynchronous: true; source: "../ongoing/PQStatusInfo.qml" }

        Loader { id: loader_contextmenu; active: masteritem.readyToContinueLoading; asynchronous: true; source: "../ongoing/PQContextMenu.qml" }

        // the thumbnails loader can be asynchronous as it is always integrated and never popped out
        Loader { id: loader_thumbnails; asynchronous: true; }

        Loader { id: loader_metadata }
        Loader { id: loader_mainmenu }

        /****************************************************/

        Loader {
            id: bgmessage
            asynchronous: true
            source: "PQBackgroundMessage.qml"
        }

        /****************************************************/

        // If an image has been passed on then we wait with loading the rest of the interface until the image has been loaded
        // After 2s of loading we show some first (and quick to set up) interface elements
        // After an additional 2s if the image is still not loaded we also set up the rest of the interface

        // If no image has been passed on we skip all of that and immediately set up the full interface

        Component.onCompleted: {

            // load files in folder
            if(PQCConstants.startupFileLoad != "") {
                PQCFileFolderModel.fileInFolderMainView = PQCConstants.startupFileLoad
                checkForFileFinished.restart()
            } else {
                masteritem.readyToContinueLoading = true
                finishSetup()
            }

        }

        Connections {
            target: PQCConstants
            enabled: PQCConstants.startupFileLoad!=""
            function onImageInitiallyLoadedChanged() {
                if(PQCConstants.imageInitiallyLoaded && checkForFileFinished.running) {
                    checkForFileFinished.stop()
                    masteritem.finishSetup()
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
                finishSetup()
            }
        }
        function finishSetup() {
            finishSetup_part1()
            finishSetup_part2()
        }

        function finishSetup_part1() {
            masteritem.readyToContinueLoading = true
            PQCNotify.loaderSetup("mainmenu")
            PQCNotify.loaderSetup("metadata")
        }

        function finishSetup_part2() {
            PQCNotify.loaderSetup("thumbnails")
        }

    }

}
