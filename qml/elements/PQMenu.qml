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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Menu {

    id: control

    style: MenuStyle {
        id: styleroot
        frame: Rectangle {
            color: "#44000000"
            border.width: 1
            border.color: "gray" // must be a color NAME
        }
        itemDelegate {
            background:
                Rectangle {
                    color: (styleData.selected&&styleData.enabled) ? "#bb333333" : "#bb000000"
                }
            label:
                Row {
                    Image {
                        y: 5
                        visible: styleData.iconSource!=""
                        opacity: styleData.enabled ? 1 : 0.6
                        height: visible ? (txt.height-10) : 0
                        width: height
                        source: styleData.iconSource
                        sourceSize: Qt.size(width, height)
                    }

                    Text {
                        id: txt
                        color: styleData.enabled ? "white" : "#aaaaaa"
                        text: styleData.text
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 5
                        bottomPadding: 5
                    }
                }
            submenuIndicator:
                Text {
                    y: 2*height/3
                    topPadding: 5
                    bottomPadding: 5
                    text: "\u25b8"
                    font: styleroot.font
                    color: styleData.enabled ? "white" : "#aaaaaa"
                    style: styleData.selected ? Text.Normal : Text.Raised
                }

            checkmarkIndicator:
                Rectangle {

                    implicitWidth: 20
                    implicitHeight: 20
                    radius: styleData.exclusive ? 13 : 3
                    color: styleData.checked ? (styleData.enabled ? "#ffffff" : "#dddddd" ) : "#aaaaaa"
                    Behavior on color { ColorAnimation { duration: 50 } }
                    border.color: "#333333"

                    Rectangle {
                        visible: styleData.exclusive
                        anchors.fill: parent
                        anchors.margins: 5
                        radius: 5
                        color: "#333333"
                        opacity: styleData.checked ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 50 } }
                    }

                    // indicator checkmark
                    Canvas {
                        id: canvas
                        visible: !styleData.exclusive
                        anchors {
                            fill: parent
                            topMargin: 3
                            rightMargin: 4
                            bottomMargin: 3
                            leftMargin: 4
                        }
                        contextType: "2d"
                        opacity: styleData.checked ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 50 } }

                        Connections {
                            target: styleData
                            onEnabledChanged:
                                canvas.requestPaint();
                        }

                        onPaint: {
                            var w = 3;
                            context.reset()
                            context.moveTo(0, height/2);
                            context.lineTo(width/2, height-w)
                            context.lineTo(width, 0)
                            context.lineWidth = w
                            context.lineJoint = "round"
                            context.strokeStyle = styleData.enabled ? "#333333" : "#aaaaaa";
                            context.stroke()

                        }
                    }

                }

        }
    }

    property bool isOpen: false

    onAboutToShow:
        isOpen = true
    onAboutToHide:
        isOpen = false

}
