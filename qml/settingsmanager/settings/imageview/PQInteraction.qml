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

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Zoom")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt allows for a great deal of flexibility in viewing images at the perfect size. Additionally it allows for control of how fast the zoom happens, and if there is a minimum/maximum zoom level at which it should always stop no matter what. Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                text: qsTranslate("settingsmanager", "zoom speed:") + " " + zoomspeed.from + "%"
            }
            PQSlider {
                id: zoomspeed
                from: 1
                to: 100
                value: PQCSettings.imageviewZoomSpeed
                onValueChanged: checkDefault()
            }
            PQText {
                text: zoomspeed.to + "%"
            }
        }

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "current value:") + " " + zoomspeed.value + "%"
        }

        Item {
            width: 1
            height: 1
        }

        Column {
            x: (parent.width-width)/2
            Row {
                PQCheckBox {
                    id: minzoom_check
                    text: qsTranslate("settingsmanager", "minimum zoom:") + " "
                    checked: PQCSettings.imageviewZoomMinEnabled
                    onCheckedChanged: checkDefault()
                }
                PQText {
                    y: (minzoom_check.height-height)/2
                    enabled: minzoom_check.checked
                    text: minzoom_slider.from + "%"
                }

                PQSlider {
                    id: minzoom_slider
                    y: (minzoom_check.height-height)/2
                    enabled: minzoom_check.checked
                    from: 1
                    to: 100
                    value: PQCSettings.imageviewZoomMin
                    onValueChanged: checkDefault()
                }
                PQText {
                    y: (minzoom_check.height-height)/2
                    enabled: minzoom_check.checked
                    text: minzoom_slider.to + "%"
                }
            }
            PQText {
                x: (parent.width-width)/2
                enabled: minzoom_check.checked
                text: qsTranslate("settingsmanager", "current value:") + " " + minzoom_slider.value + "%"
            }

            /****************/
            Item {
                width: 1
                height: 10
            }

            Row {
                PQCheckBox {
                    id: maxzoom_check
                    text: qsTranslate("settingsmanager", "maximum zoom:") + " "
                    checked: PQCSettings.imageviewZoomMaxEnabled
                    onCheckedChanged: checkDefault()
                }
                PQText {
                    y: (maxzoom_check.height-height)/2
                    enabled: maxzoom_check.checked
                    text: maxzoom_slider.from + "%"
                }

                PQSlider {
                    id: maxzoom_slider
                    y: (maxzoom_check.height-height)/2
                    enabled: maxzoom_check.checked
                    from: 100
                    to: 1000
                    value: PQCSettings.imageviewZoomMax
                    onValueChanged: checkDefault()
                }
                PQText {
                    y: (maxzoom_check.height-height)/2
                    enabled: maxzoom_check.checked
                    text: maxzoom_slider.to + "%"
                }
            }
            PQText {
                x: (parent.width-width)/2
                enabled: maxzoom_check.checked
                text: qsTranslate("settingsmanager", "current value:") + " " + maxzoom_slider.value + "%"
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title. The minimap is a small version of the image used to show where the view is at.
            text: qsTranslate("settingsmanager", "Minimap")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The minimap is a small version of the image that is shown in the lower right corner whenever the image has been zoomed in. It shows the currently visible section of the image and allows to navigate to other parts of the image by clicking at a location or by dragging the highlighted rectangle.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: minimap
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "Show minimap")
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Mirror/Flip")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Images can be manipulated inside PhotoQt in a variety of ways, including their zoom and rotation. Another property that can be manipulated is the mirroring (or flipping) of images both vertically and horizontally. By default, PhotoQt animates this process, but this behavior can be disabled here. In that case the mirror/flip happens instantaneously.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: mirroranim
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "Animate mirror/flip")
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Floating navigation")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Switching between images can be done in various ways. It is possible to do so through the shortcuts, through the main menu, or through floating navigation buttons. These floating buttons were added especially with touch screens in mind, as it allows easier navigation without having to use neither the keyboard nor the mouse. In addition to buttons for navigation it also includes a button to hide and show the main menu.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: floatingnav
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show floating navigation buttons")
            checked: PQCSettings.interfaceNavigationFloating
            onCheckedChanged: checkDefault()
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
                mirroranim.hasChanged() || minimap.hasChanged()) {
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

        zoomspeed.saveDefault()
        minzoom_check.saveDefault()
        minzoom_slider.saveDefault()
        maxzoom_check.saveDefault()
        maxzoom_slider.saveDefault()
        mirroranim.saveDefault()
        floatingnav.saveDefault()
        minimap.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
