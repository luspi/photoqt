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
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Item {

    anchors.fill: parent
    id: blurtop

    property var items: [imageitem, thumbnails, statusinfo, histogram, mainmenu, metadata]
    property var thisis: undefined
    property int bluruntil: thisis!=undefined ? items.indexOf(thisis) : items.length-1
    property var reacttoxy: parent

    property bool isPoppedOut: false

    property int radius: 0
    property string color: (PQSettings.interfaceBlurElementsInBackground&&!isPoppedOut) ? "#99000000" : "#bb000000"

    Item {
        id: empty
        width: 1
        height: 1
    }

    Repeater {
        model: (PQSettings.interfaceBlurElementsInBackground&&!isPoppedOut) ? (bluruntil+1) : 0

        Item {

            anchors.fill: parent

            ShaderEffectSource{
                id: shader
                sourceItem: (items[index].enabled&&thisis!==items[index]) ? items[index] : empty
                anchors.fill: parent
                property point glob: blurtop.parent.mapToGlobal(x-toplevel.x, y-toplevel.y)
                sourceRect: Qt.rect(glob.x-items[index].x, glob.y-items[index].y, blurtop.parent.width, blurtop.parent.height)
            }

            GaussianBlur {
                anchors.fill: parent
                source: shader
                radius: 9
                samples: 19
                deviation: 10
                transparentBorder: false
            }

            Connections {
                target: reacttoxy
                onXChanged:
                    shader.glob = reacttoxy.mapToGlobal(shader.x-toplevel.x, shader.y-toplevel.y)
                onYChanged:
                    shader.glob = reacttoxy.mapToGlobal(shader.x-toplevel.x, shader.y-toplevel.y)
            }

        }

    }

    Rectangle {
        anchors.fill: parent
        color: parent.color
    }

    // corner radius
    layer.enabled: blurtop.radius>0
    layer.effect: OpacityMask {
        maskSource: Item {
            width: blurtop.width
            height: blurtop.height
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                radius: blurtop.radius
            }
        }
    }

}
