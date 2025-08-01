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
import QtQuick.Controls
import QtQuick.Layouts
import PhotoQt.Integrated
import PhotoQt.Shared

ToolBar {

    id: ftr

    onHeightChanged:
        PQCConstants.footerHeight = height

    RowLayout {

        anchors.fill: parent
        spacing: 5

        Label {
            visible: PQCFileFolderModel.countMainView===0
            text: "Click anywhere to open a file"
        }

        Label {
            text: PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)
            elide: Label.ElideMiddle
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }

        Label {
            text: "1920x1080"
            elide: Label.ElideMiddle
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            visible: specialaction.visible
            text:"|"
        }

        ToolButton {
            id: specialaction

            property string whatisit

            visible: false
            text: "Special Action"

            onClicked: {
                if(whatisit == "photosphere") {
                    if(PQCConstants.showingPhotoSphere)
                        PQCNotify.exitPhotoSphere()
                    else
                        PQCNotify.enterPhotoSphere()
                } else if(whatisit == "viewermode") {
                    if(PQCFileFolderModel.isARC || PQCFileFolderModel.isPDF)
                        PQCFileFolderModel.disableViewerMode()
                    else
                        PQCFileFolderModel.enableViewerMode()
                } else if(whatisit == "facetagging") {
                    PQCNotify.stopFaceTagging()
                }
            }
        }

        Connections {

            target: PQCConstants

            function onFaceTaggingModeChanged() {
                ftr.checkFooterSpecialAction()
            }

        }

        Connections {

            target: PQCNotify

            function onNewImageHasBeenDisplayed() {
                ftr.checkFooterSpecialAction()
            }
        }

    }

    function checkFooterSpecialAction() {

        specialaction.visible = false

        if(PQCConstants.faceTaggingMode) {

            specialaction.whatisit = "facetagging"
            specialaction.text = "Exit face tagging mode"
            specialaction.visible = true

        } else if(PQCConstants.currentImageIsPhotoSphere && !PQCSettings.filetypesPhotoSphereAutoLoad && !PQCConstants.slideshowRunning) {

            specialaction.whatisit = "photosphere"
            specialaction.text = Qt.binding(function() { return (PQCConstants.showingPhotoSphere ? "Exit photo sphere" : "Enter photo sphere") })
            specialaction.visible = true

        } else if(PQCConstants.currentImageIsArchive || PQCConstants.currentImageIsDocument) {

            specialaction.whatisit = "viewermode"
            specialaction.text = Qt.binding(function() { return (PQCFileFolderModel.activeViewerMode ? "Exit viewer mode" : "Enter viewer mode") })
            specialaction.visible = true

        }

    }

}
