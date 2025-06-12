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

//*************//
// WINDOWS

Column {

    id: windows_top

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    onVisibleChanged: {
        if(visible)
            check()
    }

    property int checkedOption: 4

    PQTextXL {
        x: (parent.width-width)/2
        text: "Microsoft Windows"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    Item {
        width: 1
        height: 10
    }

    PQTextL {
        x: (parent.width-width)/2
        //: picture option refers to how to format a pictrue when setting it as wallpaper
        text: qsTranslate("wallpaper", "Choose picture option")
    }

    Column {
        id: col
        x: (parent.width-width)/2
        width: childrenRect.width
        spacing: 10
        PQRadioButton {
            id: opt_center
            text: "Center"
            onCheckedChanged:
                if(checked)
                    windows_top.checkedOption = 0
        }
        PQRadioButton {
            id: opt_tile
            text: "Tile"
            onCheckedChanged:
                if(checked)
                    windows_top.checkedOption = 1
        }
        PQRadioButton {
            id: opt_stretch
            text: "Stretch"
            onCheckedChanged:
                if(checked)
                    windows_top.checkedOption = 2
        }
        PQRadioButton {
            id: opt_fit
            text: "Fit"
            onCheckedChanged:
                if(checked)
                    windows_top.checkedOption = 3
        }
        PQRadioButton {
            id: opt_fill
            text: "Fill"
            checked: true
            onCheckedChanged:
                if(checked)
                    windows_top.checkedOption = 4
        }
        PQRadioButton {
            id: opt_span
            text: "Span"
            onCheckedChanged:
                if(checked)
                    windows_top.checkedOption = 5
        }
    }

    function check() {

    }

}
