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
import PhotoQt.Modern

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
// - interfaceFlickAdjustSpeed
// - interfaceFlickAdjustSpeedSpeedup
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

    PQScrollManager { flickable: setting_top }

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
                movewhl.checked = PQCSettings.getDefaultForImageviewUseMouseWheelForImageMove()
                movebut.checked = PQCSettings.getDefaultForImageviewUseMouseLeftButtonForImageMove()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (movewhl.hasChanged() || movebut.hasChanged())
            }

            function load() {
                movewhl.loadAndSetDefault(PQCSettings.imageviewUseMouseWheelForImageMove) 
                movebut.loadAndSetDefault(PQCSettings.imageviewUseMouseLeftButtonForImageMove)
            }

            function applyChanges() {
                PQCSettings.imageviewUseMouseWheelForImageMove = movewhl.checked 
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
                dblclk.setValue(PQCSettings.getDefaultForInterfaceDoubleClickThreshold())
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
            title: qsTranslate("settingsmanager", "Mouse Wheel")

            helptext: qsTranslate("settingsmanager", "The speed of scrolling is determined by a variety of factors. A touchpad typically allows for near pixel-perfect movements, whereas physical mice typically move the wheel in fixed steps. With certain hardware this can result in the physical mouse wheel to register a slow scrolling speed. Thus, the speed of scrolling with a mouse wheel can be scaled up here. Note that this setting does not affect the zoom speed!")

            content: [

                PQCheckBox {
                    id: scrollspeed
                    text: qsTranslate("settingsmanager", "Increase scroll speed")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Item {
                    width: scrollspeed_value.width
                    height: scrollspeed_value.enabled ? scrollspeed_value.height : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    PQSliderSpinBox {
                        id: scrollspeed_value
                        width: set_whl.rightcol
                        minval: 1
                        maxval: 10
                        title: "Scaling factor"
                        suffix: ""
                        enabled: scrollspeed.checked
                        animateWidth: true
                        onValueChanged:
                            setting_top.checkDefault()
                    }
                }

            ]

            onResetToDefaults: {
                scrollspeed.checked = PQCSettings.getDefaultForInterfaceFlickAdjustSpeed()
                scrollspeed_value.value = PQCSettings.getDefaultForInterfaceFlickAdjustSpeedSpeedup()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return scrollspeed.hasChanged() || scrollspeed_value.hasChanged()
            }

            function load() {
                scrollspeed.loadAndSetDefault(PQCSettings.interfaceFlickAdjustSpeed)
                scrollspeed_value.loadAndSetDefault(PQCSettings.interfaceFlickAdjustSpeedSpeedup)
            }

            function applyChanges() {
                PQCSettings.interfaceFlickAdjustSpeed = scrollspeed.checked
                PQCSettings.interfaceFlickAdjustSpeedSpeedup = scrollspeed_value.value
                scrollspeed.saveDefault()
                scrollspeed_value.saveDefault()
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
                    checked: PQCSettings.imageviewHideCursorTimeout===0 
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
                hidetimeout_check.checked = (PQCSettings.getDefaultForImageviewHideCursorTimeout() > 0)
                hidetimeout.setValue(PQCSettings.getDefaultForImageviewHideCursorTimeout())
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
                escape_doc.checked = PQCSettings.getDefaultForImageviewEscapeExitDocument()
                escape_arc.checked = PQCSettings.getDefaultForImageviewEscapeExitArchive()
                escape_bar.checked = PQCSettings.getDefaultForImageviewEscapeExitBarcodes()
                escape_flt.checked = PQCSettings.getDefaultForImageviewEscapeExitFilter()
                escape_sph.checked = PQCSettings.getDefaultForImageviewEscapeExitSphere()
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
        if(PQCSettings.generalAutoSaveSettings) { 
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
