/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import PhotoQt

Column {

    id: settitle

    // this value needs to match the spacer width in PQSettingSpacer.qml
    x: noIndent ? 0 : -20
    width: parent.width-x
    spacing: 5

    property string title: ""
    property string helptext: ""
    property bool noIndent: false

    property bool showLineAbove: true

    PQSettingsSeparator { visible: settitle.showLineAbove }

    Row {
        Item {
            y: (title_txt.height-height)/2
            height: title_txt.height*0.9
            width: PQCSettings.generalCompactSettings&&settitle.title!=="" ? height : 0
            Behavior on width { NumberAnimation { duration: 200 } }
            clip: true
            PQButtonIcon {
                width: parent.width
                height: parent.height
                source: "image://svg/:/" + PQCLook.iconShade + "/help.svg"
                tooltip: settitle.helptext.replace("\n", "<br>")
                cursorShape: Qt.WhatsThisCursor
                tooltipWidth: Math.min(500, settitle.width/2)
            }
        }
        Item {
            width: PQCSettings.generalCompactSettings ? 10 : 0
            Behavior on width { NumberAnimation { duration: 200 } }
            height: 1
        }

        PQTextXL {
            id: title_txt
            text: settitle.title
            font.capitalization: Font.SmallCaps
            font.weight: PQCLook.fontWeightBold
        }
    }

    Item {
        width: 1
        height: 5
    }

    Item {
        width: parent.width
        height: PQCSettings.generalCompactSettings||!desc_txt.visible ? 0 : desc_txt.height
        Behavior on height { NumberAnimation { duration: 200 } }
        clip: true
        PQText {
            id: desc_txt
            visible: text!==""
            text: settitle.helptext
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

}
