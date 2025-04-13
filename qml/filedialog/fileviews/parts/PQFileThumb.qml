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

Image {

    id: filethumb

    visible: !listdeleg.isFolder && PQCSettings.filedialogThumbnails && !view_top.currentFolderExcluded && !listdeleg.onNetwork // qmllint disable unqualified

    opacity: view_top.currentFileCut ? 0.3 : 1
    Behavior on opacity { NumberAnimation { duration: 200 } }

    smooth: true
    mipmap: false
    asynchronous: true
    cache: false
    sourceSize: Qt.size(view_top.currentThumbnailWidth-2*PQCSettings.filedialogElementPadding, view_top.currentThumbnailHeight-2*PQCSettings.filedialogElementPadding)

    fillMode: PQCSettings.filedialogThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit // qmllint disable unqualified

    source: visible ? encodeURI("image://thumb/" + listdeleg.currentPath) : "" // qmllint disable unqualified
    onSourceChanged: {
        if(!visible)
            fileicon.source = fileicon.sourceString
    }

    onStatusChanged: {
        if(status == Image.Ready) {
            fileicon.source = ""
        }
    }

    Connections {
        target: view_top
        function onRefreshThumbnails() {
            filethumb.source = ""
            filethumb.source = Qt.binding(function() { return (visible ? encodeURI("image://thumb/" + listdeleg.currentPath) : ""); })
        }
        function onRefreshCurrentThumbnail() {
            if(listdeleg.modelData === view_top.currentIndex) {
                filethumb.source = ""
                filethumb.source = Qt.binding(function() { return (visible ? encodeURI("image://thumb/" + listdeleg.currentPath) : ""); })
            }
        }
    }

}
