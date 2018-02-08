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

/****************************
 * CURRENTLY NOT IN USE !!! *
 ****************************/

Rectangle {

    width: 200
    height: 30

    radius: global_item_radius
    color: "#88000000"

    property string text: ed1.text

    property string tooltip: ""

    signal textEdited()

    TextEdit {

        id: ed1

        x: 3
        y: (parent.height-height)/2

        width: parent.width-6

        color: colour.text
//		selectedTextColor: "black"
//		selectionColor: "white"
        text: parent.text

        onTextChanged: parent.textEdited()

        ToolTip {

            text: parent.parent.tooltip

            property bool held: false

            anchors.fill: parent
            cursorShape: Qt.IBeamCursor

            // We use these to re-implement selecting text by mouse (otherwise it'll be overwritten by dragging feature)
            onDoubleClicked: parent.selectAll()
            onPressed: { held = true; ed1.cursorPosition = ed1.positionAt(mouse.x,mouse.y); parent.forceActiveFocus() }
            onReleased: held = false
            onPositionChanged: {if(held) ed1.moveCursorSelection(ed1.positionAt(mouse.x,mouse.y)) }

        }
    }
}
