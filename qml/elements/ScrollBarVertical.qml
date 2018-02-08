/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5

Rectangle {

    id: scrollbar;

    width: (handleSize + 2 * (backScrollbar.border.width +1));
    visible: (flickable.visibleArea.heightRatio < 1.0 && flickable.visible);

    anchors {
        top: flickable.top;
        bottom: flickable.bottom;
        right: flickable.right;
        margins: 1;
        rightMargin: showOutside ? -width : 1
    }

    property Flickable flickable: null;
    property int handleSize: 8;

    property real opacityVisible: 0.8
    property real opacityHidden: 0.1

    property bool showOutside: false

    signal scrollFinished();

    color: (clicker.containsMouse || clicker.pressed || parent.moving) ? "#22ffffff" : "transparent"
    Behavior on color { ColorAnimation { duration: variables.animationSpeed/5 } }

    Binding {
        target: handle;
        property: "y";
        value: (flickable.contentY * clicker.drag.maximumY / (flickable.contentHeight - flickable.height));
        when: (!clicker.drag.active);
    }

    Binding {
        target: flickable;
        property: "contentY";
        value: (handle.y * (flickable.contentHeight - flickable.height) / clicker.drag.maximumY);
        when: (clicker.drag.active || clicker.pressed);
    }

    Rectangle {
        id: backScrollbar;
        antialiasing: true;
        color: Qt.rgba(0, 0, 0, 0.2);
        anchors.fill: parent;
    }

    Item {

        id: groove;
        clip: true;

        anchors {
            fill: parent;
            topMargin: (backScrollbar.border.width +1);
            leftMargin: (backScrollbar.border.width +1);
            rightMargin: (backScrollbar.border.width +1);
            bottomMargin: (backScrollbar.border.width +1);
        }

        MouseArea {

            id: clicker;

            anchors.fill: parent;
            cursorShape: (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
            hoverEnabled: true

            drag {
                target: handle;
                minimumY: 0;
                maximumY: (groove.height - handle.height);
                axis: Drag.YAxis;
            }

            onClicked: flickable.contentY = (mouse.y / groove.height * (flickable.contentHeight - flickable.height));
            onReleased: scrollFinished();

        }

        Item {

            id: handle;

            height: Math.max (20, (flickable.visibleArea.heightRatio * groove.height));

            anchors {
                left: parent.left;
                right: parent.right;
            }

            Rectangle {

                id: backHandle;

                anchors.fill: parent;
                color: "black"
                border.color: "#bbbbbb"
                radius: 5
                border.width: 1
                opacity: ((clicker.containsMouse || clicker.pressed || parent.moving) ? opacityVisible : opacityHidden);

                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            }

            property bool moving: false
            onYChanged: { moving = true; moving_reset.restart(); }
            Timer {
                id: moving_reset
                interval: 500
                repeat: false
                running: false
                onTriggered: parent.moving = false
            }

        }
    }
}
