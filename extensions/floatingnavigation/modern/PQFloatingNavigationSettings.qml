import QtQuick
import QtQuick.Controls

import PQCScriptsConfig

import PhotoQt

PQSetting {

    id: settop

    signal checkHasChanged()

    //: Settings title
    title: qsTranslate("settingsmanager", "Floating navigation")

    helptext: qsTranslate("settingsmanager", "Switching between images can be done in various ways. It is possible to do so through the shortcuts, through the main menu, or through floating navigation buttons. These floating buttons were added especially with touch screens in mind, as it allows easier navigation without having to use neither the keyboard nor the mouse. In addition to buttons for navigation it also includes a button to hide and show the main menu.")

    content: [
        PQCheckBox {
            id: floatingnav
            enforceMaxWidth: settop.rightcol
            text: qsTranslate("settingsmanager", "show floating navigation buttons")
            onCheckedChanged: settop.checkHasChanged()
        }
    ]

    onResetToDefaults: {
        floatingnav.checked = PQCSettings.getDefaultForExtension("FloatingNavigation")
    }

    function handleEscape() {
    }

    function hasChanged() {
        return floatingnav.hasChanged()
    }

    function load() {
        floatingnav.loadAndSetDefault(PQCSettings.extensions.FloatingNavigation)
    }

    function applyChanges() {
        PQCSettings.extensions.FloatingNavigation = floatingnav.checked
        floatingnav.saveDefault()
    }

}
