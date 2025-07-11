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

Rectangle {

    id: explorertweaks

    color: PQCLook.baseColor // qmllint disable unqualified

    Row {

        id: row

        x: 10+closebutton.width/2 // qmllint disable unqualified
        y: (parent.height-height)/2
        spacing: 10

        PQText {

            id: zoomtext

            y: (parent.height-height)/2

            text: qsTranslate("mapexplorer", "Image zoom:")

        }

        PQSlider {

            y: (parent.height-height)/2

            from: 10
            to: 50
            value: PQCSettings.mapviewExplorerThumbnailsZoomLevel // qmllint disable unqualified

            onValueChanged: {
                PQCSettings.mapviewExplorerThumbnailsZoomLevel = value // qmllint disable unqualified
            }
        }

        Item {
            width: 10
            height: 1
        }

        PQCheckBox {
            text: qsTranslate("mapexplorer", "scale and crop thumbnails")
            checked: PQCSettings.mapviewExplorerThumbnailsScaleCrop // qmllint disable unqualified
            onCheckedChanged:
                PQCSettings.mapviewExplorerThumbnailsScaleCrop = checked // qmllint disable unqualified
        }

    }

    Rectangle {

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: "#aaaaaa"
    }

}
