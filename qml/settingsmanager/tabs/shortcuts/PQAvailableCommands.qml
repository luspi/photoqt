/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9

import "../../../elements"

Item {

    id: availtop

    width: shcont.width/2-15
    height: col.height+20

    property bool thisIsAnExternalCategory: false

    Column {

        id: col

        x: 10
        y: 10

        spacing: 5

        Repeater {
            model: thisIsAnExternalCategory ? 1 : shcont.available.length

            Rectangle {
                radius: 5
                width: availtop.width-20
                height: cmdtxt.height+10
                color: hovered ? "#2a2a2a" : "#222222"
                Behavior on color { ColorAnimation { duration: 100 } }

                property bool hovered: false

                Text {
                    id: cmdtxt
                    x: 10
                    y: 5
                    color: "#dddddd"
                    text: thisIsAnExternalCategory ? em.pty+qsTranslate("settingsmanager_shortcuts", "External shortcut") : shcont.available[index][1]
                }

                Text {
                    id: clicktoadd
                    x: parent.width-width-10
                    y: 5
                    color: "#666666"
                    text: em.pty+qsTranslate("settingsmanager_shortcuts", "Click to add shortcut")
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: "<b>" + cmdtxt.text + "</b><br><br>" + em.pty+qsTranslate("settingsmanager_shortcuts", "Click to add shortcut")
                    onEntered:
                        parent.hovered = true
                    onExited:
                        parent.hovered = false
                    onClicked: {
                        shcont.addShortcut((thisIsAnExternalCategory ? "" : shcont.available[index][0]))
                    }
                }

            }

        }

    }

}