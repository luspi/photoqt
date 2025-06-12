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

//********//
// PLASMA 5

Column {

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    onVisibleChanged: {
        if(visible)
            check()
    }

    property list<int> checkedScreens: []

    PQTextXL {
        x: (parent.width-width)/2
        text: "Plasma"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    Item {
        width: 1
        height: 10
    }

    PQTextL {
        x: 10
        width: parent.width-20
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: qsTranslate("wallpaper", "The image will be set to all screens at the same time.")
    }

    function check() {

        wallpaper_top.numDesktops = PQCScriptsWallpaper.getScreenCount() // qmllint disable unqualified
        checkedScreens = []
        for(var i = 0; i < wallpaper_top.numDesktops; ++i)
            checkedScreens.push(i+1)

    }

}
