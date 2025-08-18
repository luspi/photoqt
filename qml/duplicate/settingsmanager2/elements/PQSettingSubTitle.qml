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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Column {

    id: settitle

    // this value needs to match the spacer width in PQSettingSpacer.qml
    x: -20
    width: parent.width-x
    spacing: 5

    property string title: ""
    property string helptext: ""

    PQSettingsSeparator {}

    PQTextXL {
        text: settitle.title
        font.capitalization: Font.SmallCaps
        font.weight: PQCLook.fontWeightBold
    }

    Item {
        width: 1
        height: 5
    }

    PQText {
        visible: text!==""
        text: settitle.helptext
        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

}
