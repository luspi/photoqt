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

/* :-)) <3 */

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - imageviewZoomSpeed
// - imageviewZoomToCenter
// - imageviewZoomMinEnabled
// - imageviewZoomMin
// - imageviewZoomMaxEnabled
// - imageviewZoomMax
// - interfaceFloatingNavigation

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: zoomspeed.editMode || minzoom_slider.editMode || maxzoom_slider.editMode

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_zoom

            //: Settings title
            title: qsTranslate("settingsmanager", "Zoom")

            helptext: qsTranslate("settingsmanager", "PhotoQt allows for a great deal of flexibility in viewing images at the perfect size. Additionally it allows for control of how fast the zoom happens (both in relative and absolute terms), and if there is a minimum/maximum zoom level at which it should always stop no matter what. Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")

            content: [

                PQSliderSpinBox {
                    id: zoomspeed
                    width: set_zoom.rightcol
                    minval: 1
                    maxval: 100
                    title: qsTranslate("settingsmanager", "zoom speed:")
                    suffix: " %"
                    onValueChanged:
                        setting_top.checkDefault()
                },

                Flow {
                    PQRadioButton {
                        id: zoom_rel
                        text: qsTranslate("settingsmanager", "relative zoom speed")
                        checked: PQCSettings.imageviewZoomSpeedRelative
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: zoom_abs
                        text: qsTranslate("settingsmanager", "absolute zoom speed")
                        checked: !zoom_rel.checked
                        onCheckedChanged: setting_top.checkDefault()
                    }
                },

                Item {
                    width: 1
                    height: 5
                },

                Flow {
                    width: set_zoom.rightcol
                    PQCheckBox {
                        id: minzoom_check
                        text: qsTranslate("settingsmanager", "minimum zoom") + (checked ? ": " : "  ")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                    PQSliderSpinBox {
                        id: minzoom_slider
                        width: set_zoom.rightcol - minzoom_check.width - 10
                        minval: 1
                        maxval: 100
                        enabled: minzoom_check.checked
                        animateWidth: true
                        title: ""
                        suffix: " %"
                        onValueChanged:
                            setting_top.checkDefault()
                    }

                },

                Flow {

                    width: set_zoom.rightcol

                    PQCheckBox {
                        id: maxzoom_check
                        text: qsTranslate("settingsmanager", "maximum zoom") + (checked ? ": " : "  ")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                    PQSliderSpinBox {
                        id: maxzoom_slider
                        width: set_zoom.rightcol - maxzoom_check.width - 10
                        minval: 100
                        maxval: 10000
                        enabled: maxzoom_check.checked
                        animateWidth: true
                        title: ""
                        suffix: " %"
                        onValueChanged:
                            setting_top.checkDefault()
                    }

                },

                Item {
                    width: 1
                    height: 5
                },

                Flow {

                    width: set_zoom.rightcol

                    PQText {
                        height: zoom_mousepos.height
                        verticalAlignment: Text.AlignVCenter
                        text: qsTranslate("settingsmanager", "Zoom to/from:")
                    }

                    PQRadioButton {
                        id: zoom_mousepos
                        //: refers to where to zoom to/from
                        text: qsTranslate("settingsmanager", "mouse position")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                    PQRadioButton {
                        id: zoom_imcent
                        //: refers to where to zoom to/from
                        text: qsTranslate("settingsmanager", "image center")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                }

            ]

            onResetToDefaults: {

                zoomspeed.setValue(PQCSettings.getDefaultForImageviewZoomSpeed())
                zoom_rel.checked = PQCSettings.getDefaultForImageviewZoomSpeedRelative()===1
                zoom_abs.checked = PQCSettings.getDefaultForImageviewZoomSpeedRelative()===0
                minzoom_check.checked = PQCSettings.getDefaultForImageviewZoomMinEnabled()
                minzoom_slider.setValue(PQCSettings.getDefaultForImageviewZoomMin())
                maxzoom_check.checked = PQCSettings.getDefaultForImageviewZoomMaxEnabled()
                maxzoom_slider.setValue(PQCSettings.getDefaultForImageviewZoomMax())
                zoom_mousepos.checked = PQCSettings.getDefaultForImageviewZoomToCenter()===0
                zoom_imcent.checked = PQCSettings.getDefaultForImageviewZoomToCenter()===1

            }

            function handleEscape() {
                zoomspeed.acceptValue()
                minzoom_slider.acceptValue()
                maxzoom_slider.acceptValue()
            }

            function hasChanged() {
                return (zoomspeed.hasChanged() || minzoom_check.hasChanged() || minzoom_slider.hasChanged() ||
                        zoom_rel.hasChanged() || zoom_abs.hasChanged() || maxzoom_check.hasChanged() ||
                        maxzoom_slider.hasChanged() || zoom_mousepos.hasChanged() || zoom_imcent.hasChanged())
            }

            function load() {
                zoomspeed.loadAndSetDefault(PQCSettings.imageviewZoomSpeed)
                zoom_rel.loadAndSetDefault(PQCSettings.imageviewZoomSpeedRelative)
                zoom_abs.loadAndSetDefault(!PQCSettings.imageviewZoomSpeedRelative)
                minzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMinEnabled)
                minzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMin)
                maxzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMaxEnabled)
                maxzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMax)
                zoom_mousepos.loadAndSetDefault(!PQCSettings.imageviewZoomToCenter)
                zoom_imcent.loadAndSetDefault(PQCSettings.imageviewZoomToCenter)
            }

            function applyChanges() {

                PQCSettings.imageviewZoomSpeed = zoomspeed.value
                PQCSettings.imageviewZoomSpeedRelative = zoom_rel.checked
                PQCSettings.imageviewZoomMinEnabled = minzoom_check.checked
                PQCSettings.imageviewZoomMin = minzoom_slider.value
                PQCSettings.imageviewZoomMaxEnabled = maxzoom_check.checked
                PQCSettings.imageviewZoomMax = maxzoom_slider.value
                PQCSettings.imageviewZoomToCenter = zoom_imcent.checked

                zoomspeed.saveDefault()
                zoom_rel.saveDefault()
                zoom_abs.saveDefault()
                minzoom_check.saveDefault()
                minzoom_slider.saveDefault()
                maxzoom_check.saveDefault()
                maxzoom_slider.saveDefault()
                zoom_mousepos.saveDefault()
                zoom_imcent.saveDefault()

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_mini

            //: Settings title. The minimap is a small version of the image used to show where the view is at.
            title: qsTranslate("settingsmanager", "Minimap")

            helptext: qsTranslate("settingsmanager", "The minimap is a small version of the image that is shown in the lower right corner whenever the image has been zoomed in. It shows the currently visible section of the image and allows to navigate to other parts of the image by clicking at a location or by dragging the highlighted rectangle.")

            content: [
                PQCheckBox {
                    id: minimap
                    enforceMaxWidth: set_mini.rightcol
                    text: qsTranslate("settingsmanager", "Show minimap")
                    onCheckedChanged: setting_top.checkDefault()
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
                        property list<string> modeldata: [qsTranslate("settingsmanager", "small minimap"),
                                                          qsTranslate("settingsmanager", "normal minimap"),
                                                          qsTranslate("settingsmanager", "large minimap"),
                                                          qsTranslate("settingsmanager", "very large minimap")]
                        model: modeldata
                        onCurrentIndexChanged:
                            setting_top.checkDefault()
                    }
                }

            ]

            onResetToDefaults: {
                minimap.checked = PQCSettings.getDefaultForImageviewShowMinimap()
                minimapsizelevel.currentIndex = PQCSettings.getDefaultForImageviewMinimapSizeLevel()
            }

            function handleEscape() {}

            function hasChanged() {
                return (minimap.hasChanged() || minimapsizelevel.hasChanged())
            }

            function load() {
                minimap.loadAndSetDefault(PQCSettings.imageviewShowMinimap)
                minimapsizelevel.loadAndSetDefault(PQCSettings.imageviewMinimapSizeLevel)
            }

            function applyChanges() {
                PQCSettings.imageviewShowMinimap = minimap.checked
                PQCSettings.imageviewMinimapSizeLevel = minimapsizelevel.currentIndex
                minimap.saveDefault()
                minimapsizelevel.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_mirflp

            //: Settings title
            title: qsTranslate("settingsmanager", "Mirror/Flip")

            helptext: qsTranslate("settingsmanager", "Images can be manipulated inside PhotoQt in a variety of ways, including their zoom and rotation. Another property that can be manipulated is the mirroring (or flipping) of images both vertically and horizontally. By default, PhotoQt animates this process, but this behavior can be disabled here. In that case the mirror/flip happens instantaneously.")

            content: [
                PQCheckBox {
                    id: mirroranim
                    enforceMaxWidth: set_mirflp.rightcol
                    text: qsTranslate("settingsmanager", "Animate mirror/flip")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                mirroranim.checked = PQCSettings.getDefaultForImageviewMirrorAnimate()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return mirroranim.hasChanged()
            }

            function load() {
                mirroranim.loadAndSetDefault(PQCSettings.imageviewMirrorAnimate)
            }

            function applyChanges() {
                PQCSettings.imageviewMirrorAnimate = mirroranim.checked
                mirroranim.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        // PQFloatingNavigationSettings {
        //     id: set_float
        //     onCheckHasChanged: {
        //         setting_top.checkDefault()
        //     }
        // }

        Item {
            width: 1
            height: 20
        }


    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_zoom.handleEscape()
        set_mini.handleEscape()
        set_mirflp.handleEscape()
        // set_float.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (set_zoom.hasChanged() || set_mini.hasChanged() || set_mirflp.hasChanged() || set_float.hasChanged())

    }

    function load() {

        set_zoom.load()
        set_mini.load()
        set_mirflp.load()
        // set_float.load()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_zoom.applyChanges()
        set_mini.applyChanges()
        set_mirflp.applyChanges()
        // set_float.applyChanges()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function revertChanges() {
        load()
    }

}
