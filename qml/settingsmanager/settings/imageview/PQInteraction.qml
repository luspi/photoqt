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
import PQCNotify

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imageviewZoomSpeed
// - imageviewZoomToCenter (currently not implemented)
// - imageviewZoomMinEnabled
// - imageviewZoomMin
// - imageviewZoomMaxEnabled
// - imageviewZoomMax
// - interfaceNavigationFloating

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false
    property bool settingsLoaded: false

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Zoom")

            helptext: qsTranslate("settingsmanager", "PhotoQt allows for a great deal of flexibility in viewing images at the perfect size. Additionally it allows for control of how fast the zoom happens, and if there is a minimum/maximum zoom level at which it should always stop no matter what. Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")

            content: [

                PQSpinBoxAdvanced {
                    id: zoomspeed
                    minval: 0
                    maxval: 100
                    title: qsTranslate("settingsmanager", "zoom speed:")
                    suffix: " %"
                    onValueChanged:
                        checkDefault()
                },

                Row {
                    PQCheckBox {
                        id: minzoom_check
                        text: qsTranslate("settingsmanager", "minimum zoom") + (checked ? ": " : "  ")
                        onCheckedChanged: checkDefault()
                    }

                    PQSpinBoxAdvanced {
                        id: minzoom_slider
                        minval: 1
                        maxval: 100
                        enabled: minzoom_check.checked
                        animateWidth: true
                        title: ""
                        suffix: " %"
                        onValueChanged:
                            checkDefault()
                    }

                },

                Row {

                    PQCheckBox {
                        id: maxzoom_check
                        text: qsTranslate("settingsmanager", "minimum zoom") + (checked ? ": " : "  ")
                        onCheckedChanged: checkDefault()
                    }

                    PQSpinBoxAdvanced {
                        id: maxzoom_slider
                        minval: 1
                        maxval: 100
                        enabled: maxzoom_check.checked
                        animateWidth: true
                        title: ""
                        suffix: " %"
                        onValueChanged:
                            checkDefault()
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title. The minimap is a small version of the image used to show where the view is at.
            title: qsTranslate("settingsmanager", "Minimap")

            helptext: qsTranslate("settingsmanager", "The minimap is a small version of the image that is shown in the lower right corner whenever the image has been zoomed in. It shows the currently visible section of the image and allows to navigate to other parts of the image by clicking at a location or by dragging the highlighted rectangle.")

            content: [
                PQCheckBox {
                    id: minimap
                    text: qsTranslate("settingsmanager", "Show minimap")
                    onCheckedChanged: checkDefault()
                },
                Item {
                    enabled: minimap.checked
                    clip: true
                    width: minimapsizelevel.width
                    height: enabled ? minimapsizelevel.height : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity{ NumberAnimation { duration: 150 } }
                    PQComboBox {
                        id: minimapsizelevel
                        model: [qsTranslate("settingsmanager", "small minimap"),
                                qsTranslate("settingsmanager", "normal minimap"),
                                qsTranslate("settingsmanager", "large minimap"),
                                qsTranslate("settingsmanager", "very large minimap")]
                        onCurrentIndexChanged:
                            checkDefault()
                    }
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Mirror/Flip")

            helptext: qsTranslate("settingsmanager", "Images can be manipulated inside PhotoQt in a variety of ways, including their zoom and rotation. Another property that can be manipulated is the mirroring (or flipping) of images both vertically and horizontally. By default, PhotoQt animates this process, but this behavior can be disabled here. In that case the mirror/flip happens instantaneously.")

            content: [
                PQCheckBox {
                    id: mirroranim
                    text: qsTranslate("settingsmanager", "Animate mirror/flip")
                    onCheckedChanged: checkDefault()
                }
            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Floating navigation")

            helptext: qsTranslate("settingsmanager", "Switching between images can be done in various ways. It is possible to do so through the shortcuts, through the main menu, or through floating navigation buttons. These floating buttons were added especially with touch screens in mind, as it allows easier navigation without having to use neither the keyboard nor the mouse. In addition to buttons for navigation it also includes a button to hide and show the main menu.")

            content: [
                PQCheckBox {
                    id: floatingnav
                    text: qsTranslate("settingsmanager", "show floating navigation buttons")
                    onCheckedChanged: checkDefault()
                }
            ]

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        if(zoomspeed.hasChanged() || minzoom_check.hasChanged() || minzoom_slider.hasChanged() ||
                maxzoom_check.hasChanged() || maxzoom_slider.hasChanged() || floatingnav.hasChanged() ||
                mirroranim.hasChanged() || minimap.hasChanged() || minimapsizelevel.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        zoomspeed.loadAndSetDefault(PQCSettings.imageviewZoomSpeed)
        minzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMinEnabled)
        minzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMin)
        maxzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMaxEnabled)
        maxzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMax)

        mirroranim.loadAndSetDefault(PQCSettings.imageviewMirrorAnimate)

        floatingnav.loadAndSetDefault(PQCSettings.interfaceNavigationFloating)

        minimap.loadAndSetDefault(PQCSettings.imageviewShowMinimap)
        minimapsizelevel.loadAndSetDefault(PQCSettings.imageviewMinimapSizeLevel)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewZoomSpeed = zoomspeed.value
        PQCSettings.imageviewZoomMinEnabled = minzoom_check.checked
        PQCSettings.imageviewZoomMin = minzoom_slider.value
        PQCSettings.imageviewZoomMaxEnabled = maxzoom_check.checked
        PQCSettings.imageviewZoomMax = maxzoom_slider.value

        PQCSettings.imageviewMirrorAnimate = mirroranim.checked

        PQCSettings.interfaceNavigationFloating = floatingnav.checked

        PQCSettings.imageviewShowMinimap = minimap.checked
        PQCSettings.imageviewMinimapSizeLevel = minimapsizelevel.currentIndex

        zoomspeed.saveDefault()
        minzoom_check.saveDefault()
        minzoom_slider.saveDefault()
        maxzoom_check.saveDefault()
        maxzoom_slider.saveDefault()
        mirroranim.saveDefault()
        floatingnav.saveDefault()
        minimap.saveDefault()
        minimapsizelevel.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
