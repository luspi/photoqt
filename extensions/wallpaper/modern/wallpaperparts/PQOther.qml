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

    id: other_top

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    property bool fehError: true
    property bool nitrogenError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property string checkedTool: ""
    property string checkedOption: ""

    PQTextXL {
        x: (parent.width-width)/2
        //: Used as in: Other Desktop Environment
        text: qsTranslate("wallpaper", "Other")
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    Item {
        width: 1
        height: 10
    }

    PQText {
        x: (parent.width-width)/2
        visible: other_top.fehError && feh.checked
        color: "red"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        text: qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>feh</i>")
    }

    PQText {
        x: (parent.width-width)/2
        visible: other_top.nitrogenError && nitrogen.checked
        color: "red"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        text: qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>nitrogen</i>")
    }

    Item {
        visible: (other_top.nitrogenError && nitrogen.checked) || (other_top.fehError && feh.checked)
        width: 1
        height: 10
    }

    Row {

        x: (parent.width-width)/2
        width: childrenRect.width
        spacing: 10

        PQText {
            y: (feh.height-height)/2
            //: Tool refers to a program that can be executed
            text: qsTranslate("wallpaper", "Tool:")
        }

        PQRadioButton {
            id: feh
            checked: true
            text: "feh"
            onCheckedChanged:
                if(checked)
                    other_top.checkedTool = text
            Component.onCompleted:
                other_top.checkedTool = text
        }

        PQRadioButton {
            id: nitrogen
            text: "nitrogen"
            onCheckedChanged:
                if(checked)
                    other_top.checkedTool = text
        }

    }

    Item {
        width: 1
        height: 10
    }

    Item {
        width: parent.width
        height: childrenRect.height
        Column {
            id: col
            x: (parent.width-width)/2
            width: childrenRect.width
            spacing: 10
            PQRadioButton {
                id: opt_one
                text: feh.checked ? "--bg-center" : "--set-auto"
                checked: true
                onCheckedChanged:
                    if(checked)
                        other_top.checkedOption = text
                Component.onCompleted:
                    other_top.checkedOption = text
                Connections {
                    target: feh
                    function onCheckedChanged(checked : bool) {
                        if(opt_one.checked)
                            other_top.checkedOption = opt_one.text
                    }
                }
            }
            PQRadioButton {
                id: opt_two
                text: feh.checked ? "--bg-fill" : "--set-centered"
                onCheckedChanged:
                    if(checked)
                        other_top.checkedOption = text
                Connections {
                    target: feh
                    function onCheckedChanged(checked : bool) {
                        if(opt_two.checked)
                            other_top.checkedOption = opt_two.text
                    }
                }
            }
            PQRadioButton {
                id: opt_three
                text: feh.checked ? "--bg-max" : "--set-scaled"
                onCheckedChanged:
                    if(checked)
                        other_top.checkedOption = text
                Connections {
                    target: feh
                    function onCheckedChanged(checked : bool) {
                        if(opt_three.checked)
                            other_top.checkedOption = opt_three.text
                    }
                }
            }
            PQRadioButton {
                id: opt_four
                text: feh.checked ? "--bg-scale" : "--set-tiled"
                onCheckedChanged:
                    if(checked)
                        other_top.checkedOption = text
                Connections {
                    target: feh
                    function onCheckedChanged(checked : bool) {
                        if(opt_four.checked)
                            other_top.checkedOption = opt_four.text
                    }
                }
            }
            PQRadioButton {
                id: opt_five
                text: feh.checked ? "--bg-tile" : "--set-zoom"
                onCheckedChanged:
                    if(checked)
                        other_top.checkedOption = text
                Connections {
                    target: feh
                    function onCheckedChanged(checked : bool) {
                        if(opt_five.checked)
                            other_top.checkedOption = opt_five.text
                    }
                }
            }
            PQRadioButton {
                id: opt_six
                visible: nitrogen.checked
                text: "--set-zoom-fill"
                onCheckedChanged:
                    if(checked)
                        other_top.checkedOption = text
                Connections {
                    target: feh
                    function onCheckedChanged(checked : bool) {
                        if(opt_six.checked)
                            other_top.checkedOption = opt_six.text
                    }
                }
            }
        }
    }

    function check() {

        wallpaper_top.numDesktops = PQCScriptsWallpaper.getScreenCount() // qmllint disable unqualified
        fehError = PQCScriptsWallpaper.checkFeh()
        nitrogenError = PQCScriptsWallpaper.checkNitrogen()

    }

    function changeTool() {
        if(feh.checked)
            nitrogen.checked = true
        else
            feh.checked = true
    }

}
