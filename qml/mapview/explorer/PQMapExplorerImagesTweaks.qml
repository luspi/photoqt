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
import "../../elements"

Rectangle {

    id: explorertweaks

    color: "#333333"

    Row {

        x: 10
        y: (parent.height-height)/2
        spacing: 10

        PQText {

            id: zoomtext

            text: em.pty+qsTranslate("filedialog", "Zoom:")

        }

        PQSlider {

            from: 10
            to: 50
            value: PQSettings.mapviewExplorerThumbnailsZoomLevel

            onValueChanged: {
                PQSettings.mapviewExplorerThumbnailsZoomLevel = value
                // we set the focus to some random element (one that doesn't aid in catching key events (otherwise we catch them twice))
                // this avoids the case where left/right arrow would cause inadvertently a zoom in/out event
                variables.forceActiveFocus()
            }
        }

        Item {
            width: 10
            height: 1
        }

        PQCheckbox {
            text: "scale and crop images"
            checked: PQSettings.mapviewExplorerThumbnailsScaleCrop
            onCheckedChanged:
                PQSettings.mapviewExplorerThumbnailsScaleCrop = checked
        }

    }

    Row {

        x: parent.width-width-10
        y: (parent.height-height)/2

        Image {
            id: leftright
            width: 30
            height: 30
            sourceSize.width: width
            sourceSize.height: height
            source: "/mapview/leftright.svg"
            opacity: PQSettings.mapviewExplorerLayoutLeftRight ? 1 : 0.3
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    PQSettings.mapviewExplorerLayoutLeftRight = 1
                    mapexplorer_top.resetWidthHeight()
                }
            }
        }
        Image {
            id: topbottom
            width: 30
            height: 30
            sourceSize.width: width
            sourceSize.height: height
            source: "/mapview/topbottom.svg"
            opacity: PQSettings.mapviewExplorerLayoutLeftRight ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    PQSettings.mapviewExplorerLayoutLeftRight = 0
                    mapexplorer_top.resetWidthHeight()
                }
            }
        }

    }

}
