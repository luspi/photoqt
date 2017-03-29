import QtQuick 2.4
import QtQuick.Controls 1.3

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
            text: qsTr("Warning: 'feh' doesn't seem to be installed!");
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
            text: qsTr("Warning: 'nitrogen' doesn't seem to be installed!");
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
            text: qsTr("Warning: Both 'feh' and 'nitrogen' don't seem to be installed!");
        }


        // HEADING
        Text {
            color: colour.text
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("PhotoQt can use 'feh' or 'nitrogen' to change the background of the desktop.<br>This is intended particularly for window managers that don't natively support wallpapers (like Blackbox, Fluxbox, or Openbox).")
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
                    //: feh is an application, do not translate
                    text: qsTr("Use 'feh'")
                    checkedButton: true
                    onButtonCheckedChanged: nitrogen.checkedButton = !feh.checkedButton
                }
                CustomCheckBox {
                    id: nitrogen
                    //: nitrogen is an application, do not translate
                    text: qsTr("Use 'nitrogen'")
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
