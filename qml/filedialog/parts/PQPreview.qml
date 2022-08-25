/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import QtGraphicalEffects 1.0

Item {

    property string filePath: ""

    opacity: PQSettings.openfilePreviewFullColors ? 1 : 0.2

    Image {

        id: img

        sourceSize: PQSettings.openfilePreviewHigherResolution ? Qt.size(width, height) : Qt.size(256, 256)

        asynchronous: true
        source: (filePath==""||!PQSettings.openfilePreview||fileview.currentFolderExcluded) ? "" : (PQSettings.openfileThumbnails ? ("image://thumb/" + (PQSettings.openfilePreviewMuted ? "::muted::" : "") + filePath) : ("image://icon/IMAGE////"+handlingFileDir.getSuffix(filePath)))
        fillMode: Image.PreserveAspectFit

        anchors.fill: parent

        Image {

            width: Math.min(200, parent.width-50)
            height: Math.min(200, parent.height-50)

            sourceSize: Qt.size(width, height)

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            visible: imageproperties.isVideo(filePath)

            opacity: 0.5

            source: visible ? "/multimedia/play.svg" : ""

        }

    }

    Item {
        id: empty
        width: 1
        height: 1
    }

    GaussianBlur {
        visible: PQSettings.openfilePreviewBlur
        anchors.fill: img
        source: PQSettings.openfilePreviewBlur ? img : empty
        radius: 50
        samples: 20
    }

}
