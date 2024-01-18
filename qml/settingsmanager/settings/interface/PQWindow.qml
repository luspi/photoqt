/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfaceWindowMode
// - interfaceKeepWindowOnTop
// - interfaceSaveWindowGeometry
// - interfaceWindowDecoration
// - interfaceWindowButtonsDuplicateDecorationButtons
// - interfaceWindowButtonsShow
// - interfaceWindowButtonsSize
// - interfaceWindowButtonsAutoHide
// - interfaceWindowButtonsAutoHideTopEdge
// - interfaceWindowButtonsAutoHideTimeout
// - interfaceNavigationTopRight

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Fullscreen or window mode")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "There are two main states that the applicaiton window can be in. It can either be in fullscreen mode or in window mode. In fullscreen mode, PhotoQt will act more like a floating layer that allows you to quickly look at images. In window mode, PhotoQt can be used in combination with other applications. When in window mode, it can also be set to always be above any other windows, and to remember the window geometry in between sessions.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {
            x: (parent.width-width)/2
            PQRadioButton {
                id: fsmode
                text: qsTranslate("settingsmanager", "fullscreen mode")
                checked: !PQCSettings.interfaceWindowMode
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: wmmode
                text: qsTranslate("settingsmanager", "window mode")
                checked: PQCSettings.interfaceWindowMode
                onCheckedChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            PQCheckBox {
                id: keeptop
                enabled: wmmode.checked
                text: qsTranslate("settingsmanager", "keep above other windows")
                checked: PQCSettings.interfaceKeepWindowOnTop
                onCheckedChanged: checkDefault()
            }
            PQCheckBox {
                id: rememgeo
                enabled: wmmode.checked
                //: remember the geometry of PhotoQts window between sessions
                text: qsTranslate("settingsmanager", "remember its geometry")
                checked: PQCSettings.interfaceSaveWindowGeometry
                onCheckedChanged: checkDefault()
            }
        }

        PQCheckBox {
            id: wmdeco_show
            enabled: wmmode.checked
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "enable window decoration")
            checked: PQCSettings.interfaceWindowDecoration
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Window buttons")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "PhotoQt can show some integrated window buttons for basic window managements both when shown in fullscreen and when in window mode. In window mode with window decoration enabled it can either hide or show buttons from its integrated set that are duplicates of buttons in the window decoration. For help with navigating through a folder, small left/right arrows for navigation and a menu button can also be added next to the window buttons.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: integbut_show
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show integrated window buttons")
            checked: PQCSettings.interfaceWindowButtonsShow
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: integbut_dup
            x: (parent.width-width)/2
            enabled: integbut_show.checked
            text: qsTranslate("settingsmanager", "duplicate buttons from window decoration")
            checked: PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: integbut_nav
            x: (parent.width-width)/2
            enabled: integbut_show.checked
            text: qsTranslate("settingsmanager", "add navigation buttons")
            checked: PQCSettings.interfaceNavigationTopRight
            onCheckedChanged: checkDefault()
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                enabled: integbut_show.checked
                text: butsize.from+"px"
            }
            PQSlider {
                id: butsize
                enabled: integbut_show.checked
                from: 5
                to: 50
                value: PQCSettings.interfaceWindowButtonsSize
                onValueChanged: checkDefault()
            }
            PQText {
                enabled: integbut_show.checked
                text: butsize.to+"px"
            }
        }
        PQText {
            x: (parent.width-width)/2
            enabled: integbut_show.checked
            //: The current value of the slider specifying the size of the window buttons
            text: qsTranslate("settingsmanager", "current value:") + " " + butsize.value + "px"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Hide automatically")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "The window buttons can either be shown at all times, or they can be hidden automatically based on different criteria. They can either be hidden unless the mouse cursor is near the top edge of the screen or until the mouse cursor is moved anywhere. After a specified timeout they will then hide again.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            PQRadioButton {
                id: autohide_always
                //: visibility status of the window buttons
                text: qsTranslate("settingsmanager", "keep always visible")
                checked: !PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: autohide_anymove
                //: visibility status of the window buttons
                text: qsTranslate("settingsmanager", "only show with any cursor move")
                checked: PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: autohide_topedge
                //: visibility status of the window buttons
                text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                checked: PQCSettings.interfaceWindowButtonsAutoHideTopEdge
                onCheckedChanged: checkDefault()
            }

        }

        PQText {
            enabled: !autohide_always.checked
            x: (parent.width-width)/2
            //: the window buttons can be hidden automatically after a set timeout
            text: qsTranslate("settingsmanager", "hide again after timeout:")
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                enabled: !autohide_always.checked
                y: (autohide_timeout.height-height)/2
                text: autohide_timeout.from+"s"
            }
            PQSlider {
                id: autohide_timeout
                enabled: !autohide_always.checked
                from: 0
                to: 5
                stepSize: 0.1
                wheelStepSize: 0.1
                value: PQCSettings.interfaceWindowButtonsAutoHideTimeout/1000
                onValueChanged: checkDefault()
            }
            PQText {
                enabled: !autohide_always.checked
                y: (autohide_timeout.height-height)/2
                text: autohide_timeout.to+"s"
            }
        }
        PQText {
            enabled: !autohide_always.checked
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "current value:") + " " + autohide_timeout.value.toFixed(1) + "s"
        }

        /**********************************************************************/

        Item {
            width: 1
            height: 1
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(wmmode.hasChanged() || keeptop.hasChanged() || rememgeo.hasChanged() || wmdeco_show.hasChanged()) {
            settingChanged = true
            return
        }

        if(integbut_show.hasChanged() || integbut_dup.hasChanged() || integbut_nav.hasChanged() || butsize.hasChanged()) {
            settingChanged = true
            return
        }

        if(autohide_topedge.hasChanged() || autohide_anymove.hasChanged() || autohide_always.hasChanged() || autohide_timeout.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {
        fsmode.loadAndSetDefault(!PQCSettings.interfaceWindowMode)
        wmmode.loadAndSetDefault(!fsmode.checked)

        keeptop.loadAndSetDefault(PQCSettings.interfaceKeepWindowOnTop)
        rememgeo.loadAndSetDefault(PQCSettings.interfaceSaveWindowGeometry)

        wmdeco_show.loadAndSetDefault(PQCSettings.interfaceWindowDecoration)

        integbut_show.loadAndSetDefault(PQCSettings.interfaceWindowButtonsShow)
        integbut_dup.loadAndSetDefault(PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons)
        integbut_nav.loadAndSetDefault(PQCSettings.interfaceNavigationTopRight)
        butsize.loadAndSetDefault(PQCSettings.interfaceWindowButtonsSize)

        autohide_always.loadAndSetDefault(!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_anymove.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_topedge.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_timeout.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTimeout/1000)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.interfaceWindowMode = wmmode.checked

        PQCSettings.interfaceKeepWindowOnTop = keeptop.checked
        PQCSettings.interfaceSaveWindowGeometry = rememgeo.checked

        PQCSettings.interfaceWindowDecoration = wmdeco_show.checked

        PQCSettings.interfaceWindowButtonsShow = integbut_show.checked
        PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons = integbut_dup.checked
        PQCSettings.interfaceNavigationTopRight = integbut_nav.checked
        PQCSettings.interfaceWindowButtonsSize = butsize.value

        PQCSettings.interfaceWindowButtonsAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
        PQCSettings.interfaceWindowButtonsAutoHideTopEdge = autohide_topedge.checked
        PQCSettings.interfaceWindowButtonsAutoHideTimeout = autohide_timeout.value.toFixed(1)*1000

        fsmode.saveDefault()
        wmmode.saveDefault()

        keeptop.saveDefault()
        rememgeo.saveDefault()

        wmdeco_show.saveDefault()

        integbut_show.saveDefault()
        integbut_dup.saveDefault()
        integbut_nav.saveDefault()
        butsize.saveDefault()

        autohide_always.saveDefault()
        autohide_anymove.saveDefault()
        autohide_topedge.saveDefault()
        autohide_timeout.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
