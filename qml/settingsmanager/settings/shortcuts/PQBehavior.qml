import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imageviewUseMouseWheelForImageMove
// - imageviewUseMouseLeftButtonForImageMove
// - interfaceDoubleClickThreshold
// - interfaceMouseWheelSensitivity
// - imageviewHideCursorTimeout

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
            text: qsTranslate("settingsmanager_shortcuts", "Move image with mouse")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_shortcuts", "PhotoQt can use both the left button of the mouse and the mouse wheel to move the image around. In that case, however, these actions are not available for shortcuts anymore, except when combined with one or more modifier buttons (Alt, Ctrl, etc.).")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQCheckBox {
                id: movebut
                text: qsTranslate("settingsmanager_shortcuts", "move image with left button")
                checked: PQCSettings.imageviewUseMouseWheelForImageMove
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: movewhl
                text: qsTranslate("settingsmanager_shortcuts", "move image with mouse wheel")
                checked: PQCSettings.imageviewUseMouseLeftButtonForImageMove
                onCheckedChanged: checkDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_shortcuts", "Double click")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_shortcuts", "A double click is defined as two clicks in quick succession. This means that PhotoQt will have to wait a certain amount of time to see if there is a second click before acting on a single click. Thus, the threshold (specified in milliseconds) for detecting double clicks should be as small as possible while still allowing for reliable detection of double clicks. Setting this value to zero disables double clicks and treats them as two distinct single clicks.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        Row {

            x: (parent.width-width)/2

            PQText {
                text: dblclk.from+"ms"
            }

            PQSlider {
                id: dblclk
                from: 0
                to: 1000
                stepSize: 10
                wheelStepSize: 10
                value: PQCSettings.interfaceDoubleClickThreshold
                onValueChanged: checkDefault()
            }

            PQText {
                text: dblclk.to+"ms"
            }

        }

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_shortcuts", "current value:") + " " + dblclk.value + "ms"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_shortcuts", "Mouse wheel")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_shortcuts", "Depending on any particular hardware, the mouse wheel moves either a set amount each time it is moved, or relative to how long/fast it is moved. The sensitivity allows to account for very sensitive hardware to decrease the likelihood of accidental/multiple triggers caused by wheel movement.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                text: "very sensitive"
            }
            PQSlider {
                id: whl_sens
                from: 0
                to: 10
                value: PQCSettings.interfaceMouseWheelSensitivity
            }
            PQText {
                text: "not sensitive"
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_shortcuts", "Hide mouse cursor")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_shortcuts", "Whenever an image is viewed and mouse cursor rests on the image it is possible to hide the mouse cursor after a set timeout. This way the cursor does not get in the way of actually viewing an image.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: hidetimeout_check
            x: (parent.width-width)/2
            text: "hide cursor after timeout"
            checked: PQCSettings.imageviewHideCursorTimeout===0
        }

        Row {
            x: (parent.width-width)/2
            enabled: hidetimeout_check.checked
            PQText {
                text: hidetimeout.from+"s"
            }
            PQSlider {
                id: hidetimeout
                from: 1
                to: 10
                value: PQCSettings.imageviewHideCursorTimeout
            }
            PQText {
                text: hidetimeout.to+"s"
            }
        }
        PQText {
            x: (parent.width-width)/2
            enabled: hidetimeout_check.checked
            text: "current value: " + hidetimeout.value + "s"
        }

        Item {
            width: 1
            height: 1
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(movewhl.hasChanged() || movebut.hasChanged() || dblclk.hasChanged() || whl_sens.hasChanged() || hidetimeout.hasChanged() || hidetimeout_check.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        movewhl.loadAndSetDefault(PQCSettings.imageviewUseMouseWheelForImageMove)
        movebut.loadAndSetDefault(PQCSettings.imageviewUseMouseLeftButtonForImageMove)
        dblclk.loadAndSetDefault(PQCSettings.interfaceDoubleClickThreshold)
        whl_sens.loadAndSetDefault(PQCSettings.interfaceMouseWheelSensitivity)
        hidetimeout_check.loadAndSetDefault(PQCSettings.imageviewHideCursorTimeout!==0)
        hidetimeout.loadAndSetDefault(PQCSettings.imageviewHideCursorTimeout)

        settingChanged = false

    }

    function applyChanges() {


        PQCSettings.imageviewUseMouseWheelForImageMove = movewhl.checked
        PQCSettings.imageviewUseMouseLeftButtonForImageMove = movebut.checked
        PQCSettings.interfaceDoubleClickThreshold = dblclk.value
        PQCSettings.interfaceMouseWheelSensitivity = whl_sens.value
        if(!hidetimeout_check.checked)
            PQCSettings.imageviewHideCursorTimeout = 0
        else
            PQCSettings.imageviewHideCursorTimeout = hidetimeout.value

        movewhl.saveDefault()
        movebut.saveDefault()
        dblclk.saveDefault()
        whl_sens.saveDefault()
        hidetimeout.saveDefault()
        hidetimeout_check.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
