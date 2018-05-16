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
import QtQuick.Controls 1.4

import "../../elements"

Rectangle {

    property bool currentlySelected: false

    visible: (wm_selection.currentIndex == 5)

    color: "#00000000"
    width: childrenRect.width
    height: (wm_selection.currentIndex == 5 ? childrenRect.height : 10)

    Column {

        spacing: 15

        // NOTE for feh (tool not existing)
        Text {
            id: other_error_feh
            visible: false
            color: colour.text_warning
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //: "feh" is a fixed name (name of a tool), please don't translate
            text: em.pty+qsTr("Warning: 'feh' doesn't seem to be installed!");
        }
        // NOTE for nitrogen (tool not existing)
        Text {
            id: other_error_nitrogen
            visible: false
            color: colour.text_warning
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //: "nitrogen" is a fixed name (name of a tool), please don't translate
            text: em.pty+qsTr("Warning: 'nitrogen' doesn't seem to be installed!");
        }
        // NOTE for feh AND nitrogen (tool not existing)
        Text {
            id: other_error_feh_nitrogen
            visible: false
            color: colour.text_warning
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //: "feh" and "nitrogen" are a fixed names (names of tools), please don't translate
            text: em.pty+qsTr("Warning: Both 'feh' and 'nitrogen' don't seem to be installed!");
        }


        // HEADING
        Text {
            color: colour.text
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //: "feh" and "nitrogen" are a fixed names (names of tools), please don't translate
            text: em.pty+qsTr("PhotoQt can use 'feh' or 'nitrogen' to change the background of the desktop.")
                  + "<br>"
                    //: "Blackbox", "Fluxbox" and "Openbox" are fixed names, please don't translate
                  + em.pty+qsTr("This is intended particularly for window managers that don't natively support wallpapers (like Blackbox, Fluxbox,\
 or Openbox).")
        }

        // SWITCH BETWEEN feh AND nitrogen
        Rectangle {

            color: "#00000000"
            width: childrenRect.width
            height: childrenRect.height
            x: (parent.width-width)/2

            Row {
                spacing: 15
                CustomCheckBox {
                    id: feh
                    //: Used as in "Use 'feh'" (feh is a tool)
                    text: em.pty+qsTr("Use") +" 'feh'"
                    checkedButton: true
                    onButtonCheckedChanged: nitrogen.checkedButton = !feh.checkedButton
                }
                CustomCheckBox {
                    id: nitrogen
                    //: Used as in "Use 'nitrogen'" (nitrogen is a tool)
                    text: em.pty+qsTr("Use") + " 'nitrogen'"
                    checkedButton: false
                    onButtonCheckedChanged: feh.checkedButton = !nitrogen.checkedButton
                }
            }

        }

        Rectangle { color: "#00000000"; width: 1; height: 1; }

        // feh SETTINGS
        Rectangle {

            color: "#00000000"
            width: childrenRect.width
            height: childrenRect.height
            x: (parent.width-width)/2

            Column {
                id: fehcolumn
                visible: feh.checkedButton
                spacing: 10
                ExclusiveGroup { id: fehexclusive; }
                CustomRadioButton {
                    exclusiveGroup: fehexclusive
                    text: "--bg-center"
                    checked: true
                }
                CustomRadioButton {
                    exclusiveGroup: fehexclusive
                    text: "--bg-fill"
                }
                CustomRadioButton {
                    exclusiveGroup: fehexclusive
                    text: "--bg-max"
                }
                CustomRadioButton {
                    exclusiveGroup: fehexclusive
                    text: "--bg-scale"
                }
                CustomRadioButton {
                    exclusiveGroup: fehexclusive
                    text: "--bg-tile"
                }
            }

            // nitrogen SETTINGS
            Column {
                id: nitrogencolumn
                visible: nitrogen.checkedButton
                spacing: 10
                ExclusiveGroup { id: nitrogenexclusive; }
                CustomRadioButton {
                    exclusiveGroup: nitrogenexclusive
                    text: "--set-auto"
                    checked: true
                }
                CustomRadioButton {
                    exclusiveGroup: nitrogenexclusive
                    text: "--set-centered"
                }
                CustomRadioButton {
                    exclusiveGroup: nitrogenexclusive
                    text: "--set-scaled"
                }
                CustomRadioButton {
                    exclusiveGroup: nitrogenexclusive
                    text: "--set-tiled"
                }
                CustomRadioButton {
                    exclusiveGroup: nitrogenexclusive
                    text: "--set-zoom"
                }
                CustomRadioButton {
                    exclusiveGroup: nitrogenexclusive
                    text: "--set-zoom-fill"
                }
            }

        }

    }

    function loadOther() {
        verboseMessage("Wallpaper/Other","loadOther()")
        var ret = getanddostuff.checkWallpaperTool("other")
        other_error_feh_nitrogen.visible = (ret === 3)
        other_error_nitrogen.visible = (ret === 2)
        other_error_feh.visible = (ret === 1)
    }

    function getWhichToolChecked() {
        if(feh.checkedButton)
            return "feh"
        return "nitrogen"
    }

    function getFehCurrentText() {
        return fehexclusive.current.text
    }

    function getNitrogenCurrentText() {
        return nitrogenexclusive.current.text
    }

}
