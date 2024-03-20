/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

Row {

    property int leftcol: 300
    property int rightcol: parent.width-leftcol-30

    property string helptext: ""
    property string title: ""
    property alias content: contcol.children

    Row {

        width: leftcol
        spacing: 10

        PQButtonIcon {
            y: (parent.height/ttl.lineCount -height)/2
            width: 30
            height: 30
            source: "image://svg/:/white/help.svg"
            tooltip: helptext
            onClicked: {
                settinginfomessage.show(helptext)
            }
        }

        PQTextXXL {
            id: ttl
            font.weight: PQCLook.fontWeightBold
            text: title
            font.capitalization: Font.SmallCaps
            width: leftcol-40
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

    }

    Item {
        width: 20
        height: 1
    }

    Column {

        id: contcol

        spacing: 15

        width: rightcol

    }

}
