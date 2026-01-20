/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import QtQuick.Controls
import Qt.labs.platform
import PhotoQt

PQSetting {

    id: set_accent

    property list<string> hexes: PQCLook.getColorHexes()
    property list<string> colnames: PQCLook.getColorNames()

    onSelectedColorChanged:
        checkForChanges()

    property string selectedColor: ""
    property string testcolor: ""
    Timer {
        id: resetTestColor
        property string oldvalue
        interval: 200
        onTriggered: {
            if(set_accent.testcolor === oldvalue) {
                if(PQCSettings.interfaceAccentColor !== set_accent.selectedColor) {
                    PQCLook.testColor(set_accent.selectedColor)
                    set_accent.testcolor = set_accent.selectedColor
                } else {
                    PQCLook.testColor("")
                    set_accent.testcolor = ""
                }
            }
        }
    }
    Component.onDestruction: {
        if(set_accent.testcolor !== "")
            PQCLook.testColor("")
    }

    ButtonGroup { id: grp_accent }
    ButtonGroup { id: grp_accentbg }

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Accent color")

            helptext: qsTranslate("settingsmanager", "Here an accent color of PhotoQt can be selected, with the whole interface colored with shades of it. After selecting a new color it is recommended to first test the color using the provided button to make sure that the interface is readable with the new color.")

            showLineAbove: false

        },

        PQRadioButton {
            id: color_predefined
            text: qsTranslate("settingsmanager", "Pre-defined accent colors")
            onCheckedChanged: {
                if(checked) {
                    resetTestColor.stop()
                    set_accent.testcolor = set_accent.selectedColor
                    PQCLook.testColor(set_accent.selectedColor)
                }
            }
            ButtonGroup.group: grp_accent
        },

        Flow {

            x: 50
            width: set_accent.contentWidth-50

            enabled: color_predefined.checked

            spacing: 5

            Repeater {
                model: set_accent.hexes.length
                Rectangle {
                    id: deleg
                    required property int index
                    property string colorhex: set_accent.hexes[index]
                    property bool isSelected: set_accent.selectedColor===colorhex
                    width: 100
                    height: 50
                    color: colorhex
                    opacity: enabled ? 1 : 0.5
                    border.width: deleg.isSelected ? 2 : 1
                    border.color: deleg.isSelected ? palette.text : PQCLook.baseBorder
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: color_predefined.checked
                        cursorShape: Qt.PointingHandCursor
                        text: set_accent.colnames[deleg.index]
                        onEntered: {
                            resetTestColor.stop()
                            set_accent.testcolor = deleg.colorhex
                            PQCLook.testColor(deleg.colorhex)
                        }
                        onExited: {
                            resetTestColor.oldvalue = colorhex
                            resetTestColor.restart()
                        }
                        onClicked: {
                            set_accent.selectedColor = deleg.colorhex
                        }
                    }
                    Rectangle {
                        x: (parent.width-width)
                        y: (parent.height-height)
                        width: 25
                        height: 25
                        opacity: 0.8
                        visible: deleg.isSelected
                        color: palette.base
                        border.width: 2
                        border.color: palette.text
                        Image {
                            anchors.fill: parent
                            anchors.margins: 5
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/checkmark.svg"
                        }
                    }
                }
            }

        },

        PQRadioButton {
            id: color_custom
            text: qsTranslate("settingsmanager", "Custom accent color")
            onCheckedChanged: {
                if(checked) {
                    resetTestColor.stop()
                    set_accent.selectedColor = customrect.colorAsHex
                    PQCLook.testColor(customrect.colorAsHex)
                }
            }
            ButtonGroup.group: grp_accent
        },

        Rectangle {
            id: customrect
            enabled: color_custom.checked
            x: 50
            width: 100
            height: 50
            color: "transparent"
            opacity: enabled ? 1 : 0.5
            border.width: 2
            border.color: palette.text
            property string colorAsHex: PQCScriptsOther.convertRgbToHex([255*customrect.color.r, 255*customrect.color.g, 255*customrect.color.b])
            PQMouseArea {
                anchors.fill: parent
                enabled: color_custom.checked
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: PQCSettings.interfaceAccentColor
                onClicked: {
                    coldiag.section = "accent"
                    coldiag.currentColor = set_accent.selectedColor
                    coldiag.open()
                }
            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var valCol = PQCSettings.getDefaultForInterfaceAccentColor()

                set_accent.selectedColor = valCol
                color_predefined.checked = set_accent.hexes.indexOf(set_accent.selectedColor)>-1
                color_custom.checked = !color_predefined.checked
                customrect.color = valCol

                set_accent.checkForChanges()

            }
        },

        /*******************************************/

        PQSettingSubtitle {
            title: qsTranslate("settingsmanager", "Background accent")
        },

        PQRadioButton {
            id: bgaccentusecheck
            text: qsTranslate("settingsmanager", "use accent color for background")
            checked: !PQCSettings.interfaceBackgroundCustomOverlay
            onCheckedChanged: set_accent.checkForChanges()
            ButtonGroup.group: grp_accentbg
        },

        PQRadioButton {
            id: bgcustomusecheck
            text: qsTranslate("settingsmanager", "use custom color for background")
            checked: PQCSettings.interfaceBackgroundCustomOverlay
            onCheckedChanged: set_accent.checkForChanges()
            ButtonGroup.group: grp_accentbg
        },

        Rectangle {
            id: bgcustomuse
            x: 25
            height: bgcustomusecheck.checked ? 50 : 0
            Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            width: 200
            opacity: bgcustomusecheck.checked ? 1 : 0
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }
            clip: true
            color: PQCSettings.interfaceBackgroundCustomOverlayColor==="" ? palette.base : PQCSettings.interfaceBackgroundCustomOverlayColor
            onColorChanged: set_accent.checkForChanges()
            border.width: 1
            border.color: PQCLook.baseBorder

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("settingsmanager", "Click to change color")
                onClicked: {
                    coldiag.section = "bgcustom"
                    coldiag.currentColor = bgcustomuse.color
                    coldiag.open()
                }
            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var valOver = PQCSettings.getDefaultForInterfaceBackgroundCustomOverlay()
                bgaccentusecheck.checked = !valOver
                bgcustomusecheck.checked = valOver

                set_accent.checkForChanges()

            }
        }

    ]

    ColorDialog {
        id: coldiag
        modality: Qt.ApplicationModal
        property string section
        onAccepted: {
            if(section == "accent") {
                var col = PQCScriptsOther.convertRgbToHex([255*coldiag.currentColor.r, 255*coldiag.currentColor.g, 255*coldiag.currentColor.b])
                customrect.color = col
                set_accent.selectedColor = col
                PQCLook.testColor(col)
            } else
                bgcustomuse.color = coldiag.currentColor
        }
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (selectedColor !== PQCSettings.interfaceAccentColor ||
                                                      bgaccentusecheck.hasChanged() || bgcustomusecheck.hasChanged() ||
                                                     (bgcustomusecheck.checked && bgcustomuse.color !== PQCSettings.interfaceBackgroundCustomOverlayColor))

    }

    function load() {

        settingsLoaded = false

        set_accent.selectedColor = PQCSettings.interfaceAccentColor
        color_predefined.checked = set_accent.hexes.indexOf(set_accent.selectedColor)>-1

        // the color needs to be set BEFORE setting the checkbox as the color will be read as reaction to setting the checkbox
        customrect.color = PQCSettings.interfaceAccentColor
        color_custom.checked = !color_predefined.checked

        bgaccentusecheck.loadAndSetDefault(!PQCSettings.interfaceBackgroundCustomOverlay)
        bgcustomusecheck.loadAndSetDefault(PQCSettings.interfaceBackgroundCustomOverlay)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceAccentColor = set_accent.selectedColor

        PQCSettings.interfaceBackgroundCustomOverlay = bgcustomusecheck.checked
        if(bgcustomusecheck.checked)
            PQCSettings.interfaceBackgroundCustomOverlayColor = PQCScriptsOther.convertRgbToHex([255*bgcustomuse.color.r, 255*bgcustomuse.color.g, 255*bgcustomuse.color.b])

        bgcustomusecheck.saveDefault()
        bgaccentusecheck.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
