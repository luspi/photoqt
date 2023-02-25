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
import QtQuick.Layouts 1.2

Popup {

    id: control

    property var entries: []

    property bool isOpen: control.visible

    padding: 1
    margins: 0

    signal triggered(var index)

    property int maxWidth: 100

    property int leftrightpadding: 5

    font.pointSize: baselook.fontsize

    background: Rectangle {
        color: "#88000000"
        border.width: 1
        border.color: "gray"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: control.entries.length
            Rectangle {
                implicitWidth: control.maxWidth
                implicitHeight: 1.8*txt.height
                property bool mouseOver: false
                opacity: enabled ? 1 : 0.3
                color: mouseOver ? "#454545" : "#202020"
                Behavior on color { ColorAnimation { duration: 200 } }
                Text {
                    id: txt
                    x: leftrightpadding
                    y: (parent.height-height)/2
                    text: control.entries[index]
                    font: control.font
                    opacity: enabled ? 1.0 : 0.3
                    color: "white"
                    Behavior on color { ColorAnimation { duration: 200 } }
                    horizontalAlignment: Text.AlignLeft // Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    leftPadding: 10
                    rightPadding: 10
                    Component.onCompleted:
                        if(width+2*leftrightpadding > control.maxWidth)
                            control.maxWidth = width+2*leftrightpadding
                    onWidthChanged: {
                        if(width+2*leftrightpadding > control.maxWidth)
                            control.maxWidth = width+2*leftrightpadding
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.mouseOver = true
                    onExited: parent.mouseOver = false
                    onClicked: {
                        control.triggered(index)
                        control.close()
                    }
                }
            }
        }

    }

    function popup(pos) {
        control.x = pos.x
        control.y = pos.y
        control.open()
    }

}
