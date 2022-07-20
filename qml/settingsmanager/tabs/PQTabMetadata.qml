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

import "./metadata"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height
        onContentHeightChanged: {
            if(visible)
                settingsmanager_top.scrollBarVisible = scroll.visible
        }

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        PQMouseArea {
            anchors.fill: parent
            onWheel: {
                var newy = cont.contentY - wheel.angleDelta.y
                // set new contentY, but don't move beyond top/bottom end of view
                cont.contentY = Math.max(0, Math.min(newy, cont.contentHeight-cont.height))
            }
        }

        Rectangle {

            x: 278
            y: title.height+desc.height+30
            width: 2
            height: cont.contentHeight-y
            color: "#88444444"

        }

        Column {

            id: col

            x: 10

            spacing: 15

            Item {
                width: 1
                height: 1
            }

            Text {
                id: title
                width: cont.width-20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Metadata settings")
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "These settings affect the metadata element, what information it should show and some of its behavior.") + "\n" + em.pty+qsTranslate("settingsmanager", "Some settings are only shown in expert mode.")
            }

            PQMetaData { id: mtd }
                PQHorizontalLine { expertModeOnly: mtd.expertmodeonly }
            PQHotEdge { id: hot }
                PQHorizontalLine { expertModeOnly: hot.expertmodeonly }
            PQGPSMap { id: gps }
                PQHorizontalLine { expertModeOnly: gps.expertmodeonly }
            PQRotation { id: rot }
                PQHorizontalLine { expertModeOnly: rot.expertmodeonly }
            PQFaceTags { id: ftg }
                PQHorizontalLine { expertModeOnly: ftg.expertmodeonly }
            PQFaceTagsFontSize { id: ftf }
                PQHorizontalLine { expertModeOnly: ftf.expertmodeonly }
            PQFaceTagsBorder { id: ftb }
                PQHorizontalLine { expertModeOnly: ftb.expertmodeonly }
            PQFaceTagsVisibility { id: ftv }

            // add some spacing at the bottom
            Item { width: 1; height: 25 }


        }

        Connections {
            target: settingsmanager_top
            onIsScrollBarVisible: {
                if(visible)
                    settingsmanager_top.scrollBarVisible = scroll.visible
            }
        }

    }

}
