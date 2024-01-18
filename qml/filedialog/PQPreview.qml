/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import PQCScriptsConfig
import PQCScriptsFilesPaths

import "../elements"

Item {

    id: previewtop

    anchors.fill: parent

    // the background preview
    Image {

        id: preview

        anchors.fill: parent

        sourceSize: PQCSettings.filedialogPreviewHigherResolution ? Qt.size(width, height) : Qt.size(256,256)
        asynchronous: false
        fillMode: PQCSettings.filedialogPreviewCropToFit ? Image.PreserveAspectCrop : Image.PreserveAspectFit
        opacity: PQCSettings.filedialogPreviewMuted ? 0.5 : 1

        Timer {
            id: setBG
            interval: 250
            onTriggered:
                parent.setCurrentBG()
        }

        Connections {
            target: view
            function onCurrentIndexChanged(currentIndex) {
                setBG.restart()
            }
            function onCurrentFolderThumbnailIndexChanged(currentFolderThumbnailIndex) {
                setBG.restart()
            }
        }

        function setCurrentBG() {
            if(view.currentIndex === -1 || !PQCSettings.filedialogPreview || (view.currentIndex < PQCFileFolderModel.countFoldersFileDialog && view.currentFolderThumbnailIndex == -1)) {
                preview.source = ""
                return
            }
            if(view.currentIndex < PQCFileFolderModel.countFoldersFileDialog) {
                if(PQCSettings.filedialogFolderContentThumbnails)
                    preview.source = "image://folderthumb/" + PQCFileFolderModel.entriesFileDialog[view.currentIndex] + ":://::" + view.currentFolderThumbnailIndex
                else
                    preview.source = ""
            } else {
                if(PQCSettings.filedialogThumbnails)
                    preview.source = "image://thumb/" + PQCFileFolderModel.entriesFileDialog[view.currentIndex]
                else
                    preview.source = "image://icon/"+PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.entriesFileDialog[view.currentIndex]).toLowerCase()
            }
        }

    }
    // Starting with Qt 6.4 we use the MultiEffect module to set blur and/or saturation
    // If a version prior to 6.4 is used, then CMake will copy a fake element there
    PQMultiEffect {
        parent: previewtop
        source: preview
        blurEnabled: true
        blurMax: 32
        blur: PQCSettings.filedialogPreviewBlur ? 1.0 : 0.0
        autoPaddingEnabled: false
        saturation: -1 + 0.1*PQCSettings.filedialogPreviewColorIntensity
        opacity: PQCSettings.filedialogPreviewMuted ? 0.5 : 1
    }

    // pre Qt 6.4 the MultiEffect is not available yet
    Rectangle {
        visible: !PQCScriptsConfig.isQtAtLeast6_4()
        anchors.fill: preview
        color: "#000000"
        opacity: 0.3+0.05*(10-PQCSettings.filedialogPreviewColorIntensity)
    }
}
