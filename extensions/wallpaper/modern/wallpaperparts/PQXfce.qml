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
pragma ComponentBehavior: Bound

import QtQuick
import PhotoQt

//********//
// PLASMA 5

Column {

    id: xfce_top

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    property bool xfconfQueryError: true

    property alias combobox: checkedOptCombo

    onVisibleChanged: {
        if(visible)
            check()
    }

    property list<int> checkedScreens: []
    property string checkedOption: ""

    PQTextXL {
        x: (parent.width-width)/2
        text: "XFCE 4"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    Item {
        width: 1
        height: 10
    }

    PQText {
        x: (parent.width-width)/2
        visible: xfce_top.xfconfQueryError
        color: "red"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        text: qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>xfconf-query</i>")
    }

    Item {
        visible: xfce_top.xfconfQueryError
        width: 1
        height: 10
    }

    Column {

        id: col

        spacing: 10
        width: parent.width
        height: childrenRect.height

        PQTextL {
            x: (parent.width-width)/2
            //: As in: Set wallpaper to which screens
            text: qsTranslate("wallpaper", "Set to which screens")
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: desk_col
            spacing: 10
            Repeater {
                model: wallpaper_top.numDesktops // qmllint disable unqualified
                PQCheckBox {
                    id: deleg
                    required property int modelData
                    text: qsTranslate("wallpaper", "Screen") + " #" + (modelData+1)
                    checked: true
                    onCheckedChanged: {
                        if(!checked)
                            xfce_top.checkedScreens.splice(xfce_top.checkedScreens.indexOf(modelData+1), 1)
                        else
                            xfce_top.checkedScreens.push(modelData+1)
                    }
                    Component.onCompleted: {
                        xfce_top.checkedScreens.push(modelData+1)
                    }
                }
            }
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

        PQComboBox {
            id: checkedOptCombo
            x: (parent.width-width)/2
            model: ListModel {
                id: model
                ListElement { text: "Automatic" }
                ListElement { text: "Centered" }
                ListElement { text: "Tiled" }
                ListElement { text: "Stretched" }
                ListElement { text: "Scaled" }
                ListElement { text: "Zoomed" }
            }
            onCurrentIndexChanged: {
                xfce_top.checkedOption = currentText
            }
        }

    }

    function check() {

        wallpaper_top.numDesktops = PQCScriptsWallpaper.getScreenCount() // qmllint disable unqualified
        xfconfQueryError = PQCScriptsWallpaper.checkXfce()

    }

}
