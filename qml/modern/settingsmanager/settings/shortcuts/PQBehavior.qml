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
import QtQuick.Controls
import PQCScriptsConfig
import PhotoQt

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - imageviewUseMouseWheelForImageMove
// - imageviewUseMouseLeftButtonForImageMove
// - interfaceDoubleClickThreshold
// - interfaceMouseWheelSensitivity
// - imageviewHideCursorTimeout
// - imageviewEscapeExitDocument
// - imageviewEscapeExitArchive
// - imageviewEscapeExitBarcodes
// - imageviewEscapeExitFilter
// - imageviewEscapeExitSphere

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: dblclk.contextMenuOpen || dblclk.editMode ||
                               hidetimeout.contextMenuOpen || hidetimeout.editMode

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQSetting {

            id: set_move

            //: Settings title
            title: qsTranslate("settingsmanager", "Move image with mouse")

            helptext: qsTranslate("settingsmanager", "PhotoQt can use both the left button of the mouse and the mouse wheel to move the image around. In that case, however, these actions are not available for shortcuts anymore, except when combined with one or more modifier buttons (Alt, Ctrl, etc.).")

            content: [

                PQCheckBox {
                    id: movebut
                    enforceMaxWidth: set_move.rightcol
                    text: qsTranslate("settingsmanager", "move image with left button")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: movewhl
                    enforceMaxWidth: set_move.rightcol
                    text: qsTranslate("settingsmanager", "move image with mouse wheel")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                movewhl.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewUseMouseWheelForImageMove") == 1) // qmllint disable unqualified
                movebut.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewUseMouseLeftButtonForImageMove") == 1)
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (movewhl.hasChanged() || movebut.hasChanged())
            }

            function load() {
                movewhl.loadAndSetDefault(PQCSettings.imageviewUseMouseWheelForImageMove) // qmllint disable unqualified
                movebut.loadAndSetDefault(PQCSettings.imageviewUseMouseLeftButtonForImageMove)
            }

            function applyChanges() {
                PQCSettings.imageviewUseMouseWheelForImageMove = movewhl.checked // qmllint disable unqualified
                PQCSettings.imageviewUseMouseLeftButtonForImageMove = movebut.checked
                movewhl.saveDefault()
                movebut.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_dbl

            //: Settings title
            title: qsTranslate("settingsmanager", "Double click")

            helptext: qsTranslate("settingsmanager", "A double click is defined as two clicks in quick succession. This means that PhotoQt will have to wait a certain amount of time to see if there is a second click before acting on a single click. Thus, the threshold (specified in milliseconds) for detecting double clicks should be as small as possible while still allowing for reliable detection of double clicks. Setting this value to zero disables double clicks and treats them as two distinct single clicks.")

            content: [
                PQSliderSpinBox {
                    id: dblclk
                    width: set_dbl.rightcol
                    minval: 0
                    maxval: 1000
                    title: qsTranslate("settingsmanager", "threshold:")
                    suffix: " ms"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                dblclk.setValue(1*PQCScriptsConfig.getDefaultSettingValueFor("interfaceDoubleClickThreshold"))
            }

            function handleEscape() {
                dblclk.closeContextMenus()
                dblclk.acceptValue()
            }

            function hasChanged() {
                return dblclk.hasChanged()
            }

            function load() {
                dblclk.loadAndSetDefault(PQCSettings.interfaceDoubleClickThreshold)
            }

            function applyChanges() {
                PQCSettings.interfaceDoubleClickThreshold = dblclk.value
                dblclk.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_whl

            //: Settings title
            title: qsTranslate("settingsmanager", "Mouse wheel")

            helptext: qsTranslate("settingsmanager", "Depending on any particular hardware, the mouse wheel moves either a set amount each time it is moved, or relative to how long/fast it is moved. The sensitivity allows to account for very sensitive hardware to decrease the likelihood of accidental/multiple triggers caused by wheel movement.")

            content: [

                Flow {
                    width: set_whl.rightcol
                    PQText {
                        //: used as in: very sensitive mouse wheel
                        text: qsTranslate("settingsmanager", "very sensitive")
                    }
                    PQSlider {
                        id: whl_sens
                        from: 0
                        to: 10
                        onValueChanged: setting_top.checkDefault()
                    }
                    PQText {
                        //: used as in: not at all sensitive mouse wheel
                        text: qsTranslate("settingsmanager", "not sensitive")
                    }
                }

            ]

            onResetToDefaults: {
                whl_sens.value = (1*PQCScriptsConfig.getDefaultSettingValueFor("interfaceMouseWheelSensitivity"))
            }

            function handleEscape() {
            }

            function hasChanged() {
                return whl_sens.hasChanged()
            }

            function load() {
                whl_sens.loadAndSetDefault(PQCSettings.interfaceMouseWheelSensitivity)
            }

            function applyChanges() {
                PQCSettings.interfaceMouseWheelSensitivity = whl_sens.value
                whl_sens.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_hidemouse

            //: Settings title
            title: qsTranslate("settingsmanager", "Hide mouse cursor")

            helptext: qsTranslate("settingsmanager", "Whenever an image is viewed and mouse cursor rests on the image it is possible to hide the mouse cursor after a set timeout. This way the cursor does not get in the way of actually viewing an image.")

            content: [

                PQCheckBox {
                    id: hidetimeout_check
                    enforceMaxWidth: set_hidemouse.rightcol
                    text: qsTranslate("settingsmanager", "hide cursor after timeout") + (checked ? ": " : "  ")
                    checked: PQCSettings.imageviewHideCursorTimeout===0 // qmllint disable unqualified
                },

                PQSliderSpinBox {
                    id: hidetimeout
                    width: set_hidemouse.rightcol
                    minval: 1
                    maxval: 10
                    title: ""
                    suffix: " s"
                    enabled: hidetimeout_check.checked
                    animateWidth: true
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                hidetimeout_check.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewHideCursorTimeout") > 0)
                hidetimeout.setValue(1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewHideCursorTimeout"))
            }

            function handleEscape() {
                hidetimeout.closeContextMenus()
                hidetimeout.acceptValue()
            }

            function hasChanged() {
                return (hidetimeout.hasChanged() || hidetimeout_check.hasChanged())
            }

            function load() {
                hidetimeout_check.loadAndSetDefault(PQCSettings.imageviewHideCursorTimeout!==0)
                hidetimeout.loadAndSetDefault(PQCSettings.imageviewHideCursorTimeout)
            }

            function applyChanges() {
                PQCSettings.imageviewHideCursorTimeout = (hidetimeout_check.checked ? hidetimeout.value : 0)
                hidetimeout.saveDefault()
                hidetimeout_check.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_escape

            //: Settings title
            title: qsTranslate("settingsmanager", "Escape key handling")

            helptext: qsTranslate("settingsmanager", "The Escape key can be used to cancel special actions or modes instead of any configured shortcut action. Here you can enable or disable any one of them.")

            content: [

                PQCheckBox {
                    id: escape_doc
                    enforceMaxWidth: set_hidemouse.rightcol
                    text: qsTranslate("settingsmanager", "leave document viewer if inside")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: escape_arc
                    enforceMaxWidth: set_hidemouse.rightcol
                    text: qsTranslate("settingsmanager", "leave archive viewer if inside")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: escape_bar
                    enforceMaxWidth: set_hidemouse.rightcol
                    text: qsTranslate("settingsmanager", "hide barcodes if any visible")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: escape_flt
                    enforceMaxWidth: set_hidemouse.rightcol
                    text: qsTranslate("settingsmanager", "remove filter if any set")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: escape_sph
                    enforceMaxWidth: set_hidemouse.rightcol
                    text: qsTranslate("settingsmanager", "leave photo sphere if any entered")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                escape_doc.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewEscapeExitDocument") == 1)
                escape_arc.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewEscapeExitArchive") == 1)
                escape_bar.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewEscapeExitBarcodes") == 1)
                escape_flt.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewEscapeExitFilter") == 1)
                escape_sph.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("imageviewEscapeExitSphere") == 1)
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (escape_doc.hasChanged() || escape_arc.hasChanged() || escape_bar.hasChanged() || escape_flt.hasChanged() || escape_sph.hasChanged())
            }

            function load() {
                escape_doc.loadAndSetDefault(PQCSettings.imageviewEscapeExitDocument)
                escape_arc.loadAndSetDefault(PQCSettings.imageviewEscapeExitArchive)
                escape_bar.loadAndSetDefault(PQCSettings.imageviewEscapeExitBarcodes)
                escape_flt.loadAndSetDefault(PQCSettings.imageviewEscapeExitFilter)
                escape_sph.loadAndSetDefault(PQCSettings.imageviewEscapeExitSphere)
            }

            function applyChanges() {

                PQCSettings.imageviewEscapeExitDocument = escape_doc.checked
                PQCSettings.imageviewEscapeExitArchive = escape_arc.checked
                PQCSettings.imageviewEscapeExitBarcodes = escape_bar.checked
                PQCSettings.imageviewEscapeExitFilter = escape_flt.checked
                PQCSettings.imageviewEscapeExitSphere = escape_sph.checked

                escape_doc.saveDefault()
                escape_arc.saveDefault()
                escape_bar.saveDefault()
                escape_flt.saveDefault()
                escape_sph.saveDefault()

            }

        }

        Item {
            width: 1
            height: 1
        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_move.handleEscape()
        set_dbl.handleEscape()
        set_whl.handleEscape()
        set_hidemouse.handleEscape()
        set_escape.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        settingChanged = (set_move.hasChanged() || set_dbl.hasChanged() || set_whl.hasChanged() ||
                          set_hidemouse.hasChanged() || set_escape.hasChanged())

    }

    function load() {

        set_move.load()
        set_dbl.load()
        set_whl.load()
        set_hidemouse.load()
        set_escape.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_move.applyChanges()
        set_dbl.applyChanges()
        set_whl.applyChanges()
        set_hidemouse.applyChanges()
        set_escape.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
