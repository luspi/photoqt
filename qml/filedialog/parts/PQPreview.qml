/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

    id: prev_top

    property string filePath: ""

    Image {

        id: img

        sourceSize: PQSettings.openfilePreviewHigherResolution ? Qt.size(width, height) : Qt.size(256, 256)

        asynchronous: true
        source: (filePath==""||!PQSettings.openfilePreview||fileview.currentFolderExcluded) ? "" : (PQSettings.openfileThumbnails ? ("image://thumb/" + filePath) : ("image://icon/"+(PQSettings.openfileThumbnailsScaleCrop ? "::squared::" : "")+handlingFileDir.getSuffix(filePath)))
        fillMode: PQSettings.openfilePreviewCropToFit ? Image.PreserveAspectCrop : Image.PreserveAspectFit

        anchors.fill: parent

        visible: !PQSettings.openfilePreviewBlur

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

    // specify as source only the actual painted image
    // this avoid srtefats around the edge of the preview image
    ShaderEffectSource{
        id: shader
        sourceItem: img
        x: (img.width-img.paintedWidth)/2
        y: (img.height-img.paintedHeight)/2
        width: img.paintedWidth
        height: img.paintedHeight
        sourceRect: Qt.rect((img.width-img.paintedWidth)/2, (img.height-img.paintedHeight)/2, img.paintedWidth-1, img.paintedHeight)
    }

    // blurring the image
    GaussianBlur {
        id: blur
        visible: PQSettings.openfilePreviewBlur

        x: (img.width-img.paintedWidth)/2
        y: (img.height-img.paintedHeight)/2
        width: img.paintedWidth
        height: img.paintedHeight

        source: PQSettings.openfilePreviewBlur ? shader : empty
        radius: 9
        samples: 19
        deviation: 10
    }

    // mute the colors to various extents
    Rectangle {

        x: (img.width-img.paintedWidth)/2
        y: (img.height-img.paintedHeight)/2
        width: img.paintedWidth
        height: img.paintedHeight

        color: filedialog_top.color
        opacity:  0.1*(10-PQSettings.openfilePreviewColorIntensity)

    }

}
