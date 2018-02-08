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

    height: (handleSize + 2 * (backScrollbar.border.width +1));
    visible: (flickable.visibleArea.widthRatio < 1.0);

    anchors {
        left: flickable.left;
        right: flickable.right;
        bottom: flickable.bottom;
        margins: 1;
    }

    color: (clicker.containsMouse || clicker.pressed || parent.moving) ? "#22ffffff" : "transparent"
    Behavior on color { ColorAnimation { duration: variables.animationSpeed/5 } }

    property Flickable flickable: null;
    property int handleSize: 8;

    property real opacityVisible: 0.8
    property real opacityHidden: 0.1

    property bool displayAtBottomEdge: true
    onDisplayAtBottomEdgeChanged: {
        if(!displayAtBottomEdge) {
            anchors.bottom = undefined
            state = "reanchor_top"
        } else {
            anchors.top = undefined
            state = "reanchor_bottom"
        }
    }

    states: [
        State {
            name: "reanchor_bottom"
            AnchorChanges {
                target: scrollbar
                anchors.left: flickable.left;
                anchors.right: flickable.right;
                anchors.bottom: flickable.bottom
            }
        },
        State {
            name: "reanchor_top"
            AnchorChanges {
                target: scrollbar
                anchors.left: flickable.left;
                anchors.right: flickable.right;
                anchors.top: flickable.top
            }
        }
    ]

    signal scrollFinished();

    Binding {
        target: handle;
        property: "x";
        value: (flickable.contentX * clicker.drag.maximumX / (flickable.contentWidth - flickable.width));
        when: (!clicker.drag.active);
    }

    Binding {
        target: flickable;
        property: "contentX";
        value: (handle.x * (flickable.contentWidth - flickable.width) / clicker.drag.maximumX);
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
                minimumX: 0;
                maximumX: (groove.width - handle.width);
                axis: Drag.XAxis;
            }

            onClicked: flickable.contentX = (mouse.x / groove.width * (flickable.contentWidth - flickable.width));
            onReleased: scrollFinished();

        }

        Item {

            id: handle;

            width: Math.max (20, (flickable.visibleArea.widthRatio * groove.width));

            anchors {
                top: parent.top;
                bottom: parent.bottom;
            }

            Rectangle {

                id: backHandle;

                anchors.fill: parent;
                color: "black"
                border.color: "#bbbbbb"
                border.width: 1
                opacity: ((clicker.containsMouse || clicker.pressed || parent.moving) ? opacityVisible : opacityHidden);

                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            }

            property bool moving: false
            onXChanged: { moving = true; moving_reset.restart(); }
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
