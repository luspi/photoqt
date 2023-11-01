import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfaceTrayIcon
// - interfaceTrayIconHideReset
// - interfaceTrayIconMonochrome

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
            text: qsTranslate("settingsmanager_interface", "Tray Icon")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_interface", "PhotoQt can show a small icon in the system tray. The tray icon provides additional ways to control and interact with the application. It is also possible to hide PhotoQt to the system tray instead of closing. By default a colored version of the tray icon is used, but it is also possible to use a monochrome version.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: trayicon_show
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_interface", "Show tray icon")
            checked: (PQCSettings.interfaceTrayIcon>0)
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: trayicon_mono
            enabled: trayicon_show.checked
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_interface", "monochrome icon")
            checked: PQCSettings.interfaceTrayIconMonochrome
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: trayicon_hide
            x: (parent.width-width)/2
            enabled: trayicon_show.checked
            text: qsTranslate("settingsmanager_interface", "hide to tray icon instead of closing")
            checked: (PQCSettings.interfaceTrayIcon===1)
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_interface", "Reset when hiding")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_interface", "When hiding PhotoQt in the system tray, it is possible to reset PhotoQt to its initial state, thus freeing most of the memory tied up by caching. Note that this will also unload any loaded folder and image.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: trayicon_reset
            enabled: trayicon_show.checked
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_interface", "reset session when hiding")
            checked: PQCSettings.interfaceTrayIconHideReset
            onCheckedChanged: checkDefault()
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(trayicon_show.hasChanged() || trayicon_mono.hasChanged() || trayicon_hide.hasChanged() || trayicon_reset.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        trayicon_show.loadAndSetDefault(PQCSettings.interfaceTrayIcon>0)
        trayicon_hide.loadAndSetDefault(PQCSettings.interfaceTrayIcon===1)
        trayicon_mono.loadAndSetDefault(PQCSettings.interfaceTrayIconMonochrome)

        trayicon_reset.loadAndSetDefault(PQCSettings.interfaceTrayIconHideReset)

        settingChanged = false

    }

    function applyChanges() {

        if(trayicon_show.checked) {
            if(trayicon_hide.checked)
                PQCSettings.interfaceTrayIcon = 1
            else
                PQCSettings.interfaceTrayIcon = 2
        } else
            PQCSettings.interfaceTrayIcon = 0

        PQCSettings.interfaceTrayIconMonochrome = trayicon_mono.checked
        PQCSettings.interfaceTrayIconHideReset = trayicon_reset.checked

        trayicon_show.saveDefault()
        trayicon_hide.saveDefault()
        trayicon_mono.saveDefault()
        trayicon_reset.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}