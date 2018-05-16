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

Rectangle {

    property bool currentlySelected: false

    visible: currentlySelected

    color: "#00000000"
    width: childrenRect.width
    height: (currentlySelected ? childrenRect.height : 10)

    Text {

        width: wallpaper_top.width*0.75
        x: (wallpaper_top.width-width)/2
        color: colour.text_warning
        font.bold: true
        font.pointSize: 10
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        //: "Plasma 5" is a fixed name, please don't translate
        text: em.pty+qsTr("Sorry, Plasma 5 doesn't yet offer the feature to change the wallpaper except from their own system settings.\
 Hopefully this will change soon, but until then there's nothing I can do about that.")

    }

}
