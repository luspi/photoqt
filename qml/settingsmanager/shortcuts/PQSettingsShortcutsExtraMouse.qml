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
import PhotoQt

PQSetting {

    id: set_exmo

    content: [

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Move image with mouse")

            helptext: qsTranslate("settingsmanager", "PhotoQt can use both the left button of the mouse and the mouse wheel to move the image around. In that case, however, these actions are not available for shortcuts anymore, except when combined with one or more modifier buttons (Alt, Ctrl, etc.).")

            showLineAbove: false

        },

        PQCheckBox {
            id: movebut
            enforceMaxWidth: set_exmo.contentWidth
            text: qsTranslate("settingsmanager", "move image with left button")
            onCheckedChanged: set_exmo.checkForChanges()
        },

        PQCheckBox {
            id: movewhl
            enforceMaxWidth: set_exmo.contentWidth
            text: qsTranslate("settingsmanager", "move image with mouse wheel")
            onCheckedChanged: set_exmo.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                movewhl.checked = PQCSettings.getDefaultForImageviewUseMouseWheelForImageMove()
                movebut.checked = PQCSettings.getDefaultForImageviewUseMouseLeftButtonForImageMove()

                checkForChanges()

            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Double click")

            helptext: qsTranslate("settingsmanager", "A double click is defined as two clicks in quick succession. This means that PhotoQt will have to wait a certain amount of time to see if there is a second click before acting on a single click. Thus, the threshold (specified in milliseconds) for detecting double clicks should be as small as possible while still allowing for reliable detection of double clicks. Setting this value to zero disables double clicks and treats them as two distinct single clicks.")
        },

        PQAdvancedSlider {
            id: dblclk
            width: set_exmo.contentWidth
            minval: 0
            maxval: 1000
            title: qsTranslate("settingsmanager", "threshold:")
            suffix: " ms"
            onValueChanged:
                set_exmo.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                dblclk.setValue(PQCSettings.getDefaultForInterfaceDoubleClickThreshold())

                set_exmo.checkForChanges()

            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Mouse Wheel")

            helptext: qsTranslate("settingsmanager", "The speed of scrolling is determined by a variety of factors. A touchpad typically allows for near pixel-perfect movements, whereas physical mice typically move the wheel in fixed steps. With certain hardware this can result in the physical mouse wheel to register a slow scrolling speed. Thus, the speed of scrolling with a mouse wheel can be scaled up here. Note that this setting does not affect the zoom speed!")

        },

        PQCheckBox {
            id: scrollspeed
            text: qsTranslate("settingsmanager", "Increase scroll speed")
            onCheckedChanged: set_exmo.checkForChanges()
        },

        PQAdvancedSlider {
            id: scrollspeed_value
            width: set_exmo.contentWidth
            minval: 1
            maxval: 10
            title: "Scaling factor"
            suffix: ""
            enabled: scrollspeed.checked
            onValueChanged:
                set_exmo.checkForChanges()

        },

        Item {
            x: -set_exmo.indentWidth
            width: set_exmo.contentWidth
            height: PQCSettings.generalCompactSettings||!desc_txt.visible ? 0 : desc_txt.height
            Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            clip: true
            PQText {
                id: desc_txt
                text: "On certain hardware, moving the mouse wheel by a single click can trigger multiple distinct mouse wheel events. Here a repeat delay can be set, which makes sure that any shortcut using mouse wheels is only triggered once until the configured delay has passed. Setting this to a value of 0 disabled this check altogether."
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        },

        PQAdvancedSlider {
            id: repeatdelay_value
            width: set_exmo.contentWidth
            minval: 0
            maxval: 250
            title: "Repeat delay"
            suffix: "ms"
            onValueChanged:
                set_exmo.checkForChanges()

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                scrollspeed.checked = PQCSettings.getDefaultForInterfaceFlickAdjustSpeed()
                scrollspeed_value.value = PQCSettings.getDefaultForInterfaceFlickAdjustSpeedSpeedup()
                repeatdelay_value.value = PQCSettings.getDefaultForImageviewMouseWheelRepeatDelay()

                set_exmo.checkForChanges()

            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Hide mouse cursor")

            helptext: qsTranslate("settingsmanager", "Whenever an image is viewed and mouse cursor rests on the image it is possible to hide the mouse cursor after a set timeout. This way the cursor does not get in the way of actually viewing an image.")

        },

        PQCheckBox {
            id: hidetimeout_check
            enforceMaxWidth: set_exmo.contentWidth
            text: qsTranslate("settingsmanager", "hide cursor after timeout") + (checked ? ": " : "  ")
            checked: PQCSettings.imageviewHideCursorTimeout===0
        },

        PQAdvancedSlider {
            id: hidetimeout
            width: set_exmo.contentWidth
            minval: 1
            maxval: 10
            title: ""
            suffix: " s"
            enabled: hidetimeout_check.checked
            onValueChanged:
                set_exmo.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                hidetimeout_check.checked = (PQCSettings.getDefaultForImageviewHideCursorTimeout() > 0)
                hidetimeout.setValue(PQCSettings.getDefaultForImageviewHideCursorTimeout())

                set_exmo.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        dblclk.acceptValue()
        hidetimeout.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (movewhl.hasChanged() || movebut.hasChanged() || dblclk.hasChanged() ||
                                                      scrollspeed.hasChanged() || scrollspeed_value.hasChanged() ||
                                                      hidetimeout.hasChanged() || hidetimeout_check.hasChanged() ||
                                                      repeatdelay_value.hasChanged())

    }

    function load() {

        settingsLoaded = false

        movewhl.loadAndSetDefault(PQCSettings.imageviewUseMouseWheelForImageMove)
        movebut.loadAndSetDefault(PQCSettings.imageviewUseMouseLeftButtonForImageMove)

        dblclk.loadAndSetDefault(PQCSettings.interfaceDoubleClickThreshold)

        scrollspeed.loadAndSetDefault(PQCSettings.interfaceFlickAdjustSpeed)
        scrollspeed_value.loadAndSetDefault(PQCSettings.interfaceFlickAdjustSpeedSpeedup)
        repeatdelay_value.loadAndSetDefault(PQCSettings.imageviewMouseWheelRepeatDelay)

        hidetimeout_check.loadAndSetDefault(PQCSettings.imageviewHideCursorTimeout!==0)
        hidetimeout.loadAndSetDefault(PQCSettings.imageviewHideCursorTimeout)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewUseMouseWheelForImageMove = movewhl.checked
        PQCSettings.imageviewUseMouseLeftButtonForImageMove = movebut.checked
        movewhl.saveDefault()
        movebut.saveDefault()

        PQCSettings.interfaceDoubleClickThreshold = dblclk.value
        dblclk.saveDefault()

        PQCSettings.interfaceFlickAdjustSpeed = scrollspeed.checked
        PQCSettings.interfaceFlickAdjustSpeedSpeedup = scrollspeed_value.value
        PQCSettings.imageviewMouseWheelRepeatDelay = repeatdelay_value.value
        scrollspeed.saveDefault()
        scrollspeed_value.saveDefault()
        repeatdelay_value.saveDefault()

        PQCSettings.imageviewHideCursorTimeout = (hidetimeout_check.checked ? hidetimeout.value : 0)
        hidetimeout.saveDefault()
        hidetimeout_check.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
