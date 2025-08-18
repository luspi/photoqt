/**************************************************************************
 * *                                                                      **
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
import Qt.labs.platform
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Column {

    id: setting_top

    width: parent.width

    SystemPalette { id: pqtPalette }

    PQSetting {

        id: set_accent

        helptext: qsTranslate("settingsmanager", "Here an accent color of PhotoQt can be selected, with the whole interface colored with shades of it. After selecting a new color it is recommended to first test the color using the provided button to make sure that the interface is readable with the new color.")

        //: A settings title
        title: qsTranslate("settingsmanager", "Accent color")

        property list<string> hexes: PQCLook.getColorHexes()
        property list<string> colnames: PQCLook.getColorNames()

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

        content: [

            PQRadioButton {
                text: "Pre-defined accent colors"
            },

            Flow {

                x: 50
                width: set_accent.width-50

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
                        border.width: deleg.isSelected ? 2 : 1
                        border.color: deleg.isSelected ? pqtPalette.text : PQCLook.baseBorder
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
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
                            color: pqtPalette.base
                            border.width: 2
                            border.color: pqtPalette.text
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
                text: "Custom accent color"
            },

            Item {
                width: 1
                height: 10
            },

            PQComboBox {
                id: accentcolor
                property list<string> hexes: PQCLook.getColorHexes()
                property list<string> options: PQCLook.getColorNames().concat(qsTranslate("settingsmanager", "custom color"))
                model: options
                onCurrentIndexChanged: {
                    set_accent.checkForChanges()
                }
            },

            Item {

                width: accentcustom.width
                height: accentcolor.currentIndex<accentcolor.options.length-1 ? 0 : accentcustom.height
                Behavior on height { NumberAnimation { duration: 200 } }

                clip: true

                Rectangle {
                    id: accentcustom
                    width: 200
                    height: 50
                    clip: true
                    color: PQCSettings.interfaceAccentColor
                    border.width: 1
                    border.color: PQCLook.baseBorder
                    Item {
                        x: (parent.width-width)/2
                        y: (parent.height-height)/2
                        width: accent_coltxt.width+20
                        height: accent_coltxt.height+10
                        Rectangle {
                            color: pqtPalette.text
                            opacity: 0.8
                            radius: 5
                        }
                        PQText {
                            id: accent_coltxt
                            color: pqtPalette.base
                            x: 10
                            y: 5
                            text: PQCScriptsOther.convertRgbToHex([255*accentcustom.color.r, 255*accentcustom.color.g, 255*accentcustom.color.b])
                        }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            coldiag.section = "accent"
                            coldiag.currentColor = accentcustom.color
                            coldiag.open()
                        }
                    }
                }

            },

            PQButton {
                id: testbut
                property int secs: 3
                text: qsTranslate("settingsmanager", "Test color for %1 seconds").arg(secs)
                property string backupcolor: ""
                smallerVersion: true
                onClicked: {
                    backupcolor = PQCSettings.interfaceAccentColor

                    if(accentcolor.currentIndex < accentcolor.hexes.length)
                        PQCSettings.interfaceAccentColor = accentcolor.hexes[accentcolor.currentIndex]
                    else
                        PQCSettings.interfaceAccentColor = accent_coltxt.text

                    testtimer.restart()
                    testbut.enabled = false
                }

                Component.onDestruction: {
                    if(!testbut.enabled && settingsmanager_top.opacity > 0) {
                        PQCSettings.interfaceAccentColor = testbut.backupcolor
                    }
                }

                Timer {
                    id: testtimer
                    interval: 1000
                    onTriggered: {
                        testbut.secs -= 1
                        if(testbut.secs == 0) {
                            testtimer.stop()
                            testbut.secs = 3
                            testbut.enabled = true
                            PQCSettings.interfaceAccentColor = testbut.backupcolor
                        } else {
                            testtimer.restart()
                        }
                    }
                }

            },

            Flow {
                width: set_accent.width
                spacing: 5
                PQRadioButton {
                    id: bgaccentusecheck
                    text: qsTranslate("settingsmanager", "use accent color for background")
                    checked: !PQCSettings.interfaceBackgroundCustomOverlay
                    onCheckedChanged: set_accent.checkForChanges()
                }
                PQRadioButton {
                    id: bgcustomusecheck
                    text: qsTranslate("settingsmanager", "use custom color for background")
                    checked: PQCSettings.interfaceBackgroundCustomOverlay
                    onCheckedChanged: set_accent.checkForChanges()
                }
                Rectangle {
                    id: bgcustomuse
                    height: bgcustomusecheck.height+10
                    width: bgcustomusecheck.checked ? 200 : 0
                    Behavior on width { NumberAnimation { duration: 200 } }
                    opacity: bgcustomusecheck.checked ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    clip: true
                    color: PQCSettings.interfaceBackgroundCustomOverlayColor==="" ? pqtPalette.base : PQCSettings.interfaceBackgroundCustomOverlayColor
                    onColorChanged: set_accent.checkForChanges()
                    border.width: 1
                    border.color: PQCLook.baseBorder
                    Rectangle {
                        x: (parent.width-width)/2
                        y: (parent.height-height)/2
                        width: bgcustomusetxt.width+20
                        height: bgcustomusetxt.height+10
                        radius: 5
                        color: "#88000000"
                        PQText {
                            id: bgcustomusetxt
                            x: 10
                            y: 5
                            text: PQCScriptsOther.convertRgbToHex([255*bgcustomuse.color.r, 255*bgcustomuse.color.g, 255*bgcustomuse.color.b])
                        }
                    }

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

                }

            }

        ]

        onResetToDefaults: {

            var valCol = PQCSettings.getDefaultForInterfaceAccentColor()

            accentcustom.color = valCol
            var index = accentcolor.hexes.indexOf(valCol)
            if(index === -1) index = accentcolor.options.length-1
            accentcolor.currentIndex = index

            var valOver = PQCSettings.getDefaultForInterfaceBackgroundCustomOverlay()
            bgaccentusecheck.checked = (valOver === 0)
            bgcustomusecheck.checked = (valOver === 1)

            thisSettingHasChanged = false

        }

        onThisSettingHasChangedChanged:
            setting_top.checkForChanges()

        function handleEscape() {}

        function checkForChanges() {
            if(!settingsLoaded) return
            thisSettingHasChanged = (accentcolor.hasChanged() || bgaccentusecheck.hasChanged() || bgcustomusecheck.hasChanged() ||
                                     (bgcustomusecheck.checked && bgcustomuse.color !== PQCSettings.interfaceBackgroundCustomOverlayColor))
        }

        function load() {

            settingsLoaded = false

            var index = accentcolor.hexes.indexOf(PQCSettings.interfaceAccentColor)
            accentcustom.color = PQCSettings.interfaceAccentColor
            if(index === -1) index = accentcolor.options.length-1
            accentcolor.loadAndSetDefault(index)

            bgaccentusecheck.loadAndSetDefault(!PQCSettings.interfaceBackgroundCustomOverlay)
            bgcustomusecheck.loadAndSetDefault(PQCSettings.interfaceBackgroundCustomOverlay)

            thisSettingHasChanged = false
            settingsLoaded = true

        }

        function applyChanges() {

            if(accentcolor.currentIndex < accentcolor.hexes.length)
                PQCSettings.interfaceAccentColor = accentcolor.hexes[accentcolor.currentIndex]
            else
                PQCSettings.interfaceAccentColor = accent_coltxt.text

            PQCSettings.interfaceBackgroundCustomOverlay = bgcustomusecheck.checked
            if(bgcustomusecheck.checked)
                PQCSettings.interfaceBackgroundCustomOverlayColor = PQCScriptsOther.convertRgbToHex([255*bgcustomuse.color.r, 255*bgcustomuse.color.g, 255*bgcustomuse.color.b])

            accentcolor.saveDefault()

            bgcustomusecheck.saveDefault()
            bgaccentusecheck.saveDefault()

        }

    }

    ColorDialog {
        id: coldiag
        modality: Qt.ApplicationModal
        property string section: ""
        onAccepted: {
            if(section == "accent")
                accentcustom.color = coldiag.currentColor
            else
                bgcustomuse.color = coldiag.currentColor
        }
    }

    function checkForChanges() {
        PQCConstants.settingsManagerSettingChanged = set_accent.thisSettingHasChanged
    }

}
