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
import QtQuick.Controls 2.2

Item {

    id: set_top

    width: stack.width-20
    height: (available && ((expertmodeonly && variables.settingsManagerExpertMode) || (!normalmodeonly && variables.settingsManagerExpertMode) || (!expertmodeonly && !variables.settingsManagerExpertMode))) ? cont.height+20 : 0
    Behavior on height { NumberAnimation { duration: 200 } }
    visible: height>0
    clip: true

    property alias title: txt.text
    property alias content: cont.children
    property string helptext: ""

    property alias contwidth: cont.width

    property bool expertmodeonly: false
    property bool normalmodeonly: false

    property bool available: true

    Row {

        id: row

        y: 10

        Text {
            id: txt
            y: (parent.height-height)/2
            text: ""
            color: "white"
            width: 260
            font.bold: true
            font.pointSize: 12
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                tooltip: helptext
                cursorShape: Qt.WhatsThisCursor
            }
        }

        Item {
            width: 40
            height: 1
        }

        Item {
            id: cont_container
            y: (parent.height-height)/2
            width: set_top.width - txt.width-40
            height: cont.height
            Item {
                id: cont
                width: parent.width
                height: childrenRect.height
            }
        }

    }

}
