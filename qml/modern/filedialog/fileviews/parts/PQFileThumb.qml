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

Image {

    id: filethumb

    visible: !deleg.isFolder && PQCSettings.filedialogThumbnails && !view_top.currentFolderExcluded && !deleg.onNetwork // qmllint disable unqualified

    opacity: view_top.currentFileCut ? 0.3 : 1
    Behavior on opacity { NumberAnimation { duration: 200 } }

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
            if(dontSetSourceSize) return
            filethumb.sourceSize = Qt.size(width, height)
        }
    }

    fillMode: PQCSettings.filedialogThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit // qmllint disable unqualified

    source: visible ? encodeURI("image://thumb/" + deleg.currentPath) : "" // qmllint disable unqualified
    onSourceChanged: {
        if(!visible)
            fileicon.source = fileicon.sourceString
    }

    onStatusChanged: {
        if(status == Image.Ready) {
            fileicon.source = ""
        }
    }

    Component.onCompleted: {
        if(dontSetSourceSize) return
        sourceSize = Qt.size(width, height)
    }

    Connections {
        target: view_top
        function onRefreshThumbnails() {
            filethumb.source = ""
            filethumb.source = Qt.binding(function() { return (visible ? encodeURI("image://thumb/" + deleg.currentPath) : ""); })
        }
        function onRefreshCurrentThumbnail() {
            if(deleg.modelData === view_top.currentIndex) {
                filethumb.source = ""
                filethumb.source = Qt.binding(function() { return (visible ? encodeURI("image://thumb/" + deleg.currentPath) : ""); })
            }
        }
    }

}
