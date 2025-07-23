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
import PhotoQt.Modern

Item {

    id: folderthumb

    visible: PQCSettings.filedialogFolderContentThumbnails

    property int curnum: 0
    onCurnumChanged: {
        if(deleg.modelData === view_top.currentIndex)
            view_top.currentFolderThumbnailIndex = folderthumb.curnum
    }

    signal hideExcept(var n)

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
                if(status == Image.Ready) {
                    if((curindex === view_top.currentIndex || PQCSettings.filedialogFolderContentThumbnailsAutoload) && !contextmenu.opened)
                        folderthumb_next.restart()
                    folderthumb.hideExcept(num)
                    fileicon.source = ""
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
        running: false||PQCSettings.filedialogFolderContentThumbnailsAutoload
        onTriggered: {

            var fname = PQCFileFolderModel.entriesFileDialog[deleg.modelData]
            if(!deleg.isFolder)
                return
            if(deleg.numberFilesInsideFolder === 0)
                return
            if(!PQCSettings.filedialogFolderContentThumbnails || PQCScriptsFilesPaths.isExcludeDirFromCaching(fname)) 
                return
            if((view_top.currentIndex===deleg.modelData || PQCSettings.filedialogFolderContentThumbnailsAutoload) && (PQCSettings.filedialogFolderContentThumbnailsLoop || folderthumb.curnum == 0)) {
                folderthumb.curnum = folderthumb.curnum%deleg.numberFilesInsideFolder +1
                folderthumb_model.append({"folder": fname, "num": folderthumb.curnum, "curindex": deleg.modelData})
            }
        }
    }
    Connections {
        target: view_top
        function onCurrentIndexChanged() {
            if(view_top.currentIndex===deleg.modelData && !PQCSettings.filedialogFolderContentThumbnailsAutoload)
                folderthumb_next.restart()
        }
    }

}
