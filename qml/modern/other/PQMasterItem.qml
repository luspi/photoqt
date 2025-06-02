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

        Timer {
            id: checkForFileFinished
            interval: 100
            onTriggered: {
                if(!PQCConstants.imageInitiallyLoaded) {
                    checkForFileFinished.restart()
                    return
                }
                finishSetup()
            }
        }

        function finishSetup() {
            masteritem.readyToContinueLoading = true
            PQCNotify.loaderSetup("mainmenu")
            PQCNotify.loaderSetup("metadata")
            PQCNotify.loaderSetup("thumbnails")
        }

    }

}
