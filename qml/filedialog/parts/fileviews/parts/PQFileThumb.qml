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

import QtQuick
import PhotoQt

Image {

    id: filethumb

    visible: !isFolder && PQCSettings.filedialogThumbnails && !PQGlobalItems.filedialogFileview.currentFolderExcluded && !onNetwork

    property bool isFileCut
    property bool isFolder
    property bool onNetwork
    property string currentPath
    property string myIndex

    signal hideFileIcon()
    signal showFileIcon()

    opacity: isFileCut ? 0.3 : 1
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

    // On older systems (e.g., Ubuntu 24.04), some file types cause a crash in the folder view due to some jasper/magick issues.
    // To avoid this, we use the `full` image provider in those cases instead of the `thumb` provider.
    property list<string> useFullImageProvider: PQCScriptsConfig.isJasperWorkaroundsEnabled() ? ["j2k", "jp2", "jpx", "jpc", "jpeg2000", "icns"] : []

    smooth: true
    mipmap: false
    asynchronous: true
    cache: false

    property bool dontSetSourceSize: false

    onWidthChanged:
        updateSizeDelay.restart()
    onHeightChanged:
        updateSizeDelay.restart()
    Timer {
        id: updateSizeDelay
        interval: 1000
        onTriggered: {
            if(filethumb.dontSetSourceSize) return
            filethumb.sourceSize = Qt.size(filethumb.width, filethumb.height)
        }
    }

    fillMode: PQCSettings.filedialogThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit

    // when changing this line also change the line in the Connections below
    source: visible&&currentPath!=="" ?
                encodeURI("image://" + (useFullImageProvider.indexOf(PQCScriptsFilesPaths.getSuffixLowerCase(currentPath)) > -1 ? "full" : "thumb") + "/" + currentPath) :
                ""
    onSourceChanged: {
        if(!visible)
            showFileIcon()
    }

    onStatusChanged: {
        if(status == Image.Ready) {
            hideFileIcon()
        }
    }

    Component.onCompleted: {
        if(dontSetSourceSize) return
        sourceSize = Qt.size(width, height)
    }

    Connections {
        target: PQCNotify
        function onFiledialogReloadCurrentThumbnail() {
            if(filethumb.myIndex === PQGlobalItems.filedialogFileview.currentIndex) {
                filethumb.source = ""
                // when changing the following line also change the line in source: above
                filethumb.source = Qt.binding(function() { return (filethumb.visible&&filethumb.currentPath!=="" ? encodeURI("image://thumb/" + filethumb.currentPath) : ""); })
            }
        }
    }

}
