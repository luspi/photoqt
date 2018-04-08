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
import "../../../elements"

Rectangle {

    id: top

    // The height depends on how many elements there are
    height: Math.max(childrenRect.height,5)
    Behavior on height { NumberAnimation { duration: variables.animationSpeed/2 } }

    // The available shortcuts
    property var shortcuts: []
    // temporary solution for sharing titles with DetectShortcut
    onShortcutsChanged: {
        if(shortcuts.length != 0) {
            for(var i = 0; i < shortcuts.length; ++i) {
                var internal = shortcuts[i][0]
                var title = shortcuts[i][1]
                if(internal !== "")
                    variables.shortcutTitles[internal] = title
            }
        }
    }

    color: "transparent"
    clip: true

    // A new shortcut is to be added
    signal addShortcut(var shortcut)

    ListView {

        id: listview

        x: 3
        y: 3
        width: parent.width-6
        height: count*(elementHeight+spacing)

        spacing: 6

        interactive: false

        property int elementHeight: 24

        model: shortcuts.length

        delegate: Rectangle {

            id: deleg_top

            x: 3
            y: 3
            width: listview.width
            height: listview.elementHeight

            radius: 8

            // Color changes when hovered
            property bool hovered: false
            color: hovered ? colour.tiles_inactive : colour.tiles_disabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }


            Item {

                id: sh_title

                width: Math.max(parent.width/2, parent.width-shaddtext.width-30)
                height: parent.height

                // Which shortcut this is
                Text {

                    anchors.fill: parent
                    anchors.margins: 2
                    anchors.leftMargin: 4
                    color: colour.tiles_text_active
                    text: shortcuts[index][1]
                    elide: Text.ElideRight

                }

            }

            Text {

                id: shaddtext
                height: parent.height
                anchors.right: parent.right
                anchors.rightMargin: 20
                verticalAlignment: Text.AlignVCenter
                color: "grey"
                text: em.pty+qsTr("Click to add shortcut")

            }

            // When hovered, change color of this element AND of 'key' button
            // A click adds a new shortcut
            ToolTip {

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                text: em.pty+qsTr("Click to add shortcut")+":<br><b>" + shortcuts[index][1] + "</b>"

                onEntered:
                    deleg_top.hovered = true
                onExited:
                    deleg_top.hovered = false
                onClicked:
                    set.addShortcut(shortcuts[index])

            }

        }

    }

}
