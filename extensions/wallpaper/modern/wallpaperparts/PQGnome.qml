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
// GNOME/UNITY

Column {

    id: gnome_top

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    property bool gsettingsError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property string checkedOption: ""

    PQTextXL {
        x: (parent.width-width)/2
        text: "Gnome/Unity/Cinnamon"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    Item {
        width: 1
        height: 10
    }

    PQText {
        x: (parent.width-width)/2
        visible: gnome_top.gsettingsError
        color: "red"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        text: qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>gsettings</i>")
    }

    Item {
        visible: gnome_top.gsettingsError
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
            id: opt_wallpaper
            text: "wallpaper"
            onCheckedChanged:
                if(checked)
                    gnome_top.checkedOption = text
        }
        PQRadioButton {
            id: opt_centered
            text: "centered"
            onCheckedChanged:
                if(checked)
                    gnome_top.checkedOption = text
        }
        PQRadioButton {
            id: opt_scaled
            text: "scaled"
            onCheckedChanged:
                if(checked)
                    gnome_top.checkedOption = text
        }
        PQRadioButton {
            id: opt_zoom
            text: "zoom"
            checked: true
            Component.onCompleted:
                gnome_top.checkedOption = text
            onCheckedChanged:
                if(checked)
                    gnome_top.checkedOption = text
        }
        PQRadioButton {
            id: opt_spanned
            text: "spanned"
            onCheckedChanged:
                if(checked)
                    gnome_top.checkedOption = text
        }
    }

    function check() {

        wallpaper_top.numDesktops = PQCScriptsWallpaper.getScreenCount() // qmllint disable unqualified
        gsettingsError = PQCScriptsWallpaper.checkGSettings()

    }

}
