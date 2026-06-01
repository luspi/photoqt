/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import PhotoQt

Item {

    id: folderthumb

    visible: PQCSettings.filedialogFolderContentThumbnails

    property bool isFileCut
    property bool isFolder
    property int numberFilesInsideFolder
    property int myIndex

    onNumberFilesInsideFolderChanged: {
        if(PQCSettings.filedialogFolderContentThumbnailsAutoload && folderthumb.curnum === 0)
            folderthumb_next.triggered()
    }

    opacity: isFileCut ? 0.3 : 1

    property int curnum: 0
    onCurnumChanged: {
        if(myIndex === PQGlobalItems.filedialogFileview.currentIndex)
            PQGlobalItems.filedialogFileview.currentFolderThumbnailIndex = folderthumb.curnum
    }

    signal hideExcept(var n)
    signal hideFileIcon()

    Repeater {
        model: ListModel { id: folderthumb_model }
        delegate: Image {
            id: folderdeleg
            required property string folder
            required property int num
            required property int curindex
            anchors.fill: folderthumb
            source: "image://folderthumb/" + folder + ":://::" + num
            smooth: true
            mipmap: false
            fillMode: PQCSettings.filedialogFolderContentThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            onStatusChanged: {
                if(status == Image.Ready && source !== "") {
                    if((curindex === PQGlobalItems.filedialogFileview.currentIndex || PQCSettings.filedialogFolderContentThumbnailsAutoload) && !PQCConstants.isContextmenuOpen("fileviewentry"))
                        folderthumb_next.restart()
                    folderthumb.hideExcept(num)
                    folderthumb.hideFileIcon()
                }
            }
            Connections {
                target: folderthumb
                function onHideExcept(n : int) {
                    if(n !== folderdeleg.num) {
                        folderdeleg.source = ""
                    }
                }
            }
        }
    }

    Timer {
        id: folderthumb_next
        interval: PQCSettings.filedialogFolderContentThumbnailsSpeed===1
                        ? 2000
                        : (PQCSettings.filedialogFolderContentThumbnailsSpeed===2
                                ? 1000
                                : 500)
        running: false
        onTriggered: {

            // if thumbnails are disabled, then do nothing here
            if(!PQCSettings.filedialogThumbnails) return

            if(!folderthumb.isFolder)
                return
            if(folderthumb.numberFilesInsideFolder === 0)
                return
            var fname = PQCFileFolderModel.entriesFileDialog[folderthumb.myIndex]
            if(!PQCSettings.filedialogFolderContentThumbnails || PQCScriptsFilesPaths.isExcludeDirFromCaching(fname))
                return
            if((PQGlobalItems.filedialogFileview.currentIndex===folderthumb.myIndex || PQCSettings.filedialogFolderContentThumbnailsAutoload) && (PQCSettings.filedialogFolderContentThumbnailsLoop || folderthumb.curnum == 0)) {
                folderthumb.curnum = (folderthumb.curnum<0 ? 1 : folderthumb.curnum%folderthumb.numberFilesInsideFolder +1)
                folderthumb_model.append({"folder": fname, "num": folderthumb.curnum, "curindex": folderthumb.myIndex})
            }
        }
    }
    Connections {
        target: PQGlobalItems.filedialogFileview
        function onCurrentIndexChanged() {
            if(PQGlobalItems.filedialogFileview.currentIndex===folderthumb.myIndex && !PQCSettings.filedialogFolderContentThumbnailsAutoload && PQCSettings.filedialogThumbnails)
                folderthumb_next.restart()
        }
    }

    Connections {
        target: PQCSettings
        function onFiledialogFolderContentThumbnailsAutoloadChanged() {
            if(PQCSettings.filedialogFolderContentThumbnailsAutoload && folderthumb.curnum === 0)
                folderthumb_next.triggered()
        }
    }

}
