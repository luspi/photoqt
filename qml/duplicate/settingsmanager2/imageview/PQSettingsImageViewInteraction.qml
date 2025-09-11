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
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_inte

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Zoom")

            helptext: qsTranslate("settingsmanager",  "PhotoQt allows for a great deal of flexibility in viewing images at the perfect size. Additionally it allows for control of how fast the zoom happens (both in relative and absolute terms), and if there is a minimum/maximum zoom level at which it should always stop no matter what. Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")

            showLineAbove: false

        },

        Column {

            spacing: 5

            PQSliderSpinBox {
                id: zoomspeed
                width: set_inte.contentWidth
                minval: 1
                maxval: 100
                title: qsTranslate("settingsmanager", "zoom speed:")
                suffix: " %"
                onValueChanged:
                    set_inte.checkForChanges()
            }

            Flow {
                PQRadioButton {
                    id: zoom_rel
                    text: qsTranslate("settingsmanager", "relative zoom speed")
                    checked: PQCSettings.imageviewZoomSpeedRelative
                    onCheckedChanged: set_inte.checkForChanges()
                }
                PQRadioButton {
                    id: zoom_abs
                    text: qsTranslate("settingsmanager", "absolute zoom speed")
                    checked: !zoom_rel.checked
                    onCheckedChanged: set_inte.checkForChanges()
                }
            }

        },

        Column {

            spacing: 5

            Flow {
                width: set_inte.contentWidth
                PQCheckBox {
                    id: minzoom_check
                    text: qsTranslate("settingsmanager", "minimum zoom") + (checked ? ": " : "  ")
                    onCheckedChanged: set_inte.checkForChanges()
                }

                PQSliderSpinBox {
                    id: minzoom_slider
                    width: set_inte.contentWidth - minzoom_check.width - 10
                    minval: 1
                    maxval: 100
                    enabled: minzoom_check.checked
                    animateWidth: true
                    title: ""
                    suffix: " %"
                    onValueChanged:
                        set_inte.checkForChanges()
                }

            }

            Flow {

                width: set_inte.contentWidth

                PQCheckBox {
                    id: maxzoom_check
                    text: qsTranslate("settingsmanager", "maximum zoom") + (checked ? ": " : "  ")
                    onCheckedChanged: set_inte.checkForChanges()
                }

                PQSliderSpinBox {
                    id: maxzoom_slider
                    width: set_inte.contentWidth - maxzoom_check.width - 10
                    minval: 100
                    maxval: 10000
                    enabled: maxzoom_check.checked
                    animateWidth: true
                    title: ""
                    suffix: " %"
                    onValueChanged:
                        set_inte.checkForChanges()
                }

            }

        },

        Flow {

            width: set_inte.contentWidth

            PQText {
                height: zoom_mousepos.height
                verticalAlignment: Text.AlignVCenter
                text: qsTranslate("settingsmanager", "Zoom to/from:")
            }

            PQRadioButton {
                id: zoom_mousepos
                //: refers to where to zoom to/from
                text: qsTranslate("settingsmanager", "mouse position")
                onCheckedChanged: set_inte.checkForChanges()
            }

            PQRadioButton {
                id: zoom_imcent
                //: refers to where to zoom to/from
                text: qsTranslate("settingsmanager", "image center")
                onCheckedChanged: set_inte.checkForChanges()
            }

        },

        /**************************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Mirror/Flip")

            helptext: qsTranslate("settingsmanager",  "Images can be manipulated inside PhotoQt in a variety of ways, including their zoom and rotation. Another property that can be manipulated is the mirroring (or flipping) of images both vertically and horizontally. By default, PhotoQt animates this process, but this behavior can be disabled here. In that case the mirror/flip happens instantaneously.")

        },

        PQCheckBox {
            id: mirroranim
            enforceMaxWidth: set_inte.contentWidth
            text: qsTranslate("settingsmanager", "Animate mirror/flip")
            onCheckedChanged: set_inte.checkForChanges()
        },

        /**************************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Animate switching images")

            helptext: qsTranslate("settingsmanager",  "When switching between images PhotoQt can add an animation to smoothes such a transition. There are a whole bunch of transitions to choose from, and also an option for PhotoQt to choose one at random each time. Additionally, the speed of the chosen animation can be chosen from very slow to very fast.")

        },

        PQCheckBox {
            id: anispeed_check
            enforceMaxWidth: set_inte.contentWidth
            text: qsTranslate("settingsmanager", "animate switching between images")
            onCheckedChanged: set_inte.checkForChanges()
        },

        Column {

            spacing: 15

            enabled: anispeed_check.checked
            clip: true

            height: anirow1.height+anirow2.height+spacing

            Flow {
                id: anirow1
                spacing: 5
                width: set_inte.contentWidth
                PQText {
                    height: anicombo.height
                    verticalAlignment: Text.AlignVCenter
                    text: qsTranslate("settingsmanager", "Animation:")
                }
                PQComboBox {
                    id: anicombo
                                                      //: This is referring to an in/out animation of images
                    property list<string> modeldata: [qsTranslate("settingsmanager", "opacity"),
                                                      //: This is referring to an in/out animation of images
                                                      qsTranslate("settingsmanager", "along x-axis"),
                                                      //: This is referring to an in/out animation of images
                                                      qsTranslate("settingsmanager", "along y-axis"),
                                                      //: This is referring to an in/out animation of images
                                                      qsTranslate("settingsmanager", "rotation"),
                                                      //: This is referring to an in/out animation of images
                                                      qsTranslate("settingsmanager", "explosion"),
                                                      //: This is referring to an in/out animation of images
                                                      qsTranslate("settingsmanager", "implosion"),
                                                      //: This is referring to an in/out animation of images
                                                      qsTranslate("settingsmanager", "choose one at random")]
                    model: modeldata
                    onCurrentIndexChanged: set_inte.checkForChanges()
                }
            }

            Column {

                id: anirow2

                spacing: 5

                PQSliderSpinBox {
                    id: anispeed
                    width: set_inte.contentWidth
                    minval: 1
                    maxval: 10
                    title: qsTranslate("settingsmanager", "speed:")
                    suffix: ""
                    onValueChanged:
                        set_inte.checkForChanges()
                }

                PQText {
                    width: set_inte.contentWidth
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    //: The value is a numerical value expressing the speed of animating between images
                    text: qsTranslate("settingsmanager", "(higher value = slower)")
                }

            }

        },

        /**************************************************/

        PQSettingSubtitle {

            //: Settings title. The minimap is a small version of the image used to show where the view is at.
            title: qsTranslate("settingsmanager", "Minimap")

            helptext: qsTranslate("settingsmanager",  "The minimap is a small version of the image that is shown in the lower right corner whenever the image has been zoomed in. It shows the currently visible section of the image and allows to navigate to other parts of the image by clicking at a location or by dragging the highlighted rectangle.")

        },

        PQCheckBox {
            id: minimap
            enforceMaxWidth: set_inte.contentWidth
            text: qsTranslate("settingsmanager", "Show minimap")
            onCheckedChanged: set_inte.checkForChanges()
        },

        PQComboBox {
            id: minimapsizelevel
            enabled: minimap.checked
            property list<string> modeldata: [qsTranslate("settingsmanager", "small minimap"),
                                              qsTranslate("settingsmanager", "normal minimap"),
                                              qsTranslate("settingsmanager", "large minimap"),
                                              qsTranslate("settingsmanager", "very large minimap")]
            model: modeldata
            onCurrentIndexChanged:
                set_inte.checkForChanges()
        }

    ]

    onResetToDefaults: {

        anispeed_check.checked = (PQCSettings.getDefaultForImageviewAnimationDuration() > 0)
        anicombo.currentIndex = 0
        anispeed.setValue(PQCSettings.getDefaultForImageviewAnimationDuration())

        zoomspeed.setValue(PQCSettings.getDefaultForImageviewZoomSpeed())
        zoom_rel.checked = PQCSettings.getDefaultForImageviewZoomSpeedRelative()===1
        zoom_abs.checked = PQCSettings.getDefaultForImageviewZoomSpeedRelative()===0
        minzoom_check.checked = PQCSettings.getDefaultForImageviewZoomMinEnabled()
        minzoom_slider.setValue(PQCSettings.getDefaultForImageviewZoomMin())
        maxzoom_check.checked = PQCSettings.getDefaultForImageviewZoomMaxEnabled()
        maxzoom_slider.setValue(PQCSettings.getDefaultForImageviewZoomMax())
        zoom_mousepos.checked = PQCSettings.getDefaultForImageviewZoomToCenter()===0
        zoom_imcent.checked = PQCSettings.getDefaultForImageviewZoomToCenter()===1

        mirroranim.checked = PQCSettings.getDefaultForImageviewMirrorAnimate()

        minimap.checked = PQCSettings.getDefaultForImageviewShowMinimap()
        minimapsizelevel.currentIndex = PQCSettings.getDefaultForImageviewMinimapSizeLevel()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {
        anispeed.acceptValue()
        zoomspeed.acceptValue()
        minzoom_slider.acceptValue()
        maxzoom_slider.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (anispeed_check.hasChanged() || anispeed.hasChanged() || anicombo.hasChanged() ||
                                                      zoomspeed.hasChanged() || minzoom_check.hasChanged() || minzoom_slider.hasChanged() ||
                                                      zoom_rel.hasChanged() || zoom_abs.hasChanged() || maxzoom_check.hasChanged() ||
                                                      maxzoom_slider.hasChanged() || zoom_mousepos.hasChanged() || zoom_imcent.hasChanged() ||
                                                      mirroranim.hasChanged() || minimap.hasChanged() || minimapsizelevel.hasChanged())

    }

    function load() {

        settingsLoaded = false

        anispeed_check.loadAndSetDefault(PQCSettings.imageviewAnimationDuration>0)
        var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        if(aniValues.indexOf(PQCSettings.imageviewAnimationType) > -1)
            anicombo.loadAndSetDefault(aniValues.indexOf(PQCSettings.imageviewAnimationType))
        else
            anicombo.loadAndSetDefault(0)
        anispeed.loadAndSetDefault(PQCSettings.imageviewAnimationDuration)

        zoomspeed.loadAndSetDefault(PQCSettings.imageviewZoomSpeed)
        zoom_rel.loadAndSetDefault(PQCSettings.imageviewZoomSpeedRelative)
        zoom_abs.loadAndSetDefault(!PQCSettings.imageviewZoomSpeedRelative)
        minzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMinEnabled)
        minzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMin)
        maxzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMaxEnabled)
        maxzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMax)
        zoom_mousepos.loadAndSetDefault(!PQCSettings.imageviewZoomToCenter)
        zoom_imcent.loadAndSetDefault(PQCSettings.imageviewZoomToCenter)

        mirroranim.loadAndSetDefault(PQCSettings.imageviewMirrorAnimate)

        minimap.loadAndSetDefault(PQCSettings.imageviewShowMinimap)
        minimapsizelevel.loadAndSetDefault(PQCSettings.imageviewMinimapSizeLevel)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        if(!anispeed_check.checked)
            PQCSettings.imageviewAnimationDuration = 0
        else {
            var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
            PQCSettings.imageviewAnimationType = aniValues[anicombo.currentIndex]
            PQCSettings.imageviewAnimationDuration = anispeed.value
        }

        anicombo.saveDefault()
        anispeed_check.saveDefault()
        anispeed.saveDefault()

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

        PQCSettings.imageviewMirrorAnimate = mirroranim.checked
        mirroranim.saveDefault()

        PQCSettings.imageviewShowMinimap = minimap.checked
        PQCSettings.imageviewMinimapSizeLevel = minimapsizelevel.currentIndex
        minimap.saveDefault()
        minimapsizelevel.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
