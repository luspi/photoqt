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
// - imageviewMargin
// - imageviewFitInWindow
// - imageviewAlwaysActualSize
// - imageviewTransparencyMarker
// - imageviewCache
// - imageviewInterpolationThreshold
// - imageviewInterpolationDisableForSmallImages

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Margin")

            helptext: qsTranslate("settingsmanager", "PhotoQt shows the main image fully stretched across its application window. For an improved visual experience, it can add a small margin of some pixels around the image to not have it stretch completely from edge to edge. Note that once an image is zoomed in the margin might be filled, it only applies to the default zoom level of an image.")

            content: [

                Row {

                    spacing: 10

                    PQText {
                        y: (parent.height-height)/2
                        text: qsTranslate("settingsmanager", "margin:")
                    }

                    Rectangle {

                        width: marginslider.width
                        height: marginslider.height
                        color: PQCLook.baseColorHighlight

                        PQSpinBox {
                            id: marginslider
                            from: 0
                            to: 100
                            width: 120
                            onValueChanged: checkDefault()
                            visible: !marginslidertxt.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: marginslidertxt
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: marginslider.value + " px"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    marginslidertxt.visible = false
                                    marginslider.forceActiveFocus()
                                }
                            }
                        }

                    }

                    PQButton {
                        //: Written on button, the value is whatever was entered in a spin box
                        text: qsTranslate("settingsmanager", "Accept value")
                        font.pointSize: PQCLook.fontSize
                        font.weight: PQCLook.fontWeightNormal
                        height: 35
                        visible: !marginslidertxt.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            marginslidertxt.visible = true
                        }
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Image size")

            helptext: qsTranslate("settingsmanager", "PhotoQt ensures that an image is fully visible when first loaded. To achieve this, large images are zoomed out to fit into the view, but images smaller than the view are left as-is. Alternatively, large images can be loaded at full scale, and small images can be zoomed in to also fit into view. The latter option might result in small images appearing pixelated.")

            content: [

                Row {
                    PQText {
                        y: (large_fit.height-height)/2
                        text: qsTranslate("settingsmanager", "large images:")
                    }
                    PQRadioButton {
                        id: large_fit
                        text: qsTranslate("settingsmanager", "fit to view")
                    }
                    PQRadioButton {
                        id: large_full
                        text: qsTranslate("settingsmanager", "load at full scale")
                        checked: PQCSettings.imageviewAlwaysActualSize
                        onCheckedChanged: checkDefault()
                    }
                },

                Row {
                    PQText {
                        y: (small_fit.height-height)/2
                        text: qsTranslate("settingsmanager", "small images:")
                    }
                    PQRadioButton {
                        id: small_fit
                        text: qsTranslate("settingsmanager", "fit to view")
                        checked: PQCSettings.imageviewFitInWindow
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: small_asis
                        text: qsTranslate("settingsmanager", "load as-is")
                    }
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Transparency marker")

            helptext: qsTranslate("settingsmanager", "When an image contains transparent areas, then that area can be left transparent resulting in the background of PhotoQt to show. Alternatively, it is possible to show a checkerboard pattern behind the image, exposing the transparent areas of an image much clearer.")

            content: [
                PQCheckBox {
                    id: checkerboard
                    text: qsTranslate("settingsmanager", "show checkerboard pattern")
                    checked: PQCSettings.imageviewTransparencyMarker
                    onCheckedChanged: checkDefault()
                }
            ]
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Interpolation")

            helptext: qsTranslate("settingsmanager", "PhotoQt makes use of interpolation algorithms to show smooth lines and avoid potential artefacts to be shown. However, for small images this can lead to blurry images when no interpolation is necessary. Thus, for small images under the specified threshold PhotoQt can skip the use of interpolation algorithms. Note that both the width and height of an image need to be smaller than the threshold for it to be applied.")

            content: [

                PQCheckBox {
                    id: interp_check
                    text: qsTranslate("settingsmanager", "disable interpolation for small images")
                    onCheckedChanged: checkDefault()
                },

                Row {

                    spacing: 10

                    clip: true
                    enabled: interp_check.checked
                    height: enabled ? interp_spin.height : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQText {
                        y: (parent.height-height)/2
                        text: qsTranslate("settingsmanager", "threshold:")
                    }

                    Rectangle {

                        width: interp_spin.width
                        height: interp_spin.height
                        color: PQCLook.baseColorHighlight

                        PQSpinBox {
                            id: interp_spin
                            from: 0
                            to: 1000
                            width: 120
                            onValueChanged: checkDefault()
                            visible: !interp_txt.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: interp_txt
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: interp_spin.value + " px"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    interp_txt.visible = false
                                    interp_spin.forceActiveFocus()
                                }
                            }
                        }

                    }

                    PQButton {
                        //: Written on button, the value is whatever was entered in a spin box
                        text: qsTranslate("settingsmanager", "Accept value")
                        font.pointSize: PQCLook.fontSize
                        font.weight: PQCLook.fontWeightNormal
                        height: 35
                        visible: !interp_txt.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            interp_txt.visible = true
                        }
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Cache")

            helptext: qsTranslate("settingsmanager", "Whenever an image is loaded in full, PhotoQt caches such images in order to greatly improve performance if that same image is shown again soon after. This is done up to a certain memory limit after which the first images in the cache will be removed again to free up the required memory. Depending on the amount of memory available on the system, a higher value can lead to an improved user experience.")

            content: [

                Row {

                    spacing: 10

                    clip: true

                    PQText {
                        y: (parent.height-height)/2
                        text: qsTranslate("settingsmanager", "cache size:")
                    }

                    Rectangle {

                        width: cache_slider.width
                        height: cache_slider.height
                        color: PQCLook.baseColorHighlight

                        PQSpinBox {
                            id: cache_slider
                            from: 128
                            to: 5120
                            width: 120
                            onValueChanged: checkDefault()
                            visible: !cache_txt.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: cache_txt
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: cache_slider.value + " MB"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    cache_txt.visible = false
                                    cache_slider.forceActiveFocus()
                                }
                            }
                        }

                    }

                    PQButton {
                        //: Written on button, the value is whatever was entered in a spin box
                        text: qsTranslate("settingsmanager", "Accept value")
                        font.pointSize: PQCLook.fontSize
                        font.weight: PQCLook.fontWeightNormal
                        height: 35
                        visible: !cache_txt.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            cache_txt.visible = true
                        }
                    }

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

        if(marginslider.hasChanged() || large_fit.hasChanged() || large_full.hasChanged() || small_fit.hasChanged() || small_asis.hasChanged() ||
                checkerboard.hasChanged() || interp_check.hasChanged() || interp_spin.hasChanged() || cache_slider.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        marginslider.loadAndSetDefault(PQCSettings.imageviewMargin)

        large_fit.loadAndSetDefault(!PQCSettings.imageviewAlwaysActualSize)
        large_full.loadAndSetDefault(PQCSettings.imageviewAlwaysActualSize)
        small_fit.loadAndSetDefault(PQCSettings.imageviewFitInWindow)
        small_asis.loadAndSetDefault(!PQCSettings.imageviewFitInWindow)

        checkerboard.loadAndSetDefault(PQCSettings.imageviewTransparencyMarker)

        interp_check.loadAndSetDefault(PQCSettings.imageviewInterpolationDisableForSmallImages)
        interp_spin.loadAndSetDefault(PQCSettings.imageviewInterpolationThreshold)

        cache_slider.loadAndSetDefault(PQCSettings.imageviewCache)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewMargin = marginslider.value

        PQCSettings.imageviewAlwaysActualSize = large_full.checked
        PQCSettings.imageviewFitInWindow = small_fit.checked

        PQCSettings.imageviewTransparencyMarker = checkerboard.checked

        PQCSettings.imageviewInterpolationDisableForSmallImages = interp_check.checked
        PQCSettings.imageviewInterpolationThreshold = interp_spin.value

        PQCSettings.imageviewInterpolationDisableForSmallImages = interp_check.checked
        PQCSettings.imageviewInterpolationThreshold = interp_spin.value

        PQCSettings.imageviewCache = cache_slider.value

        marginslider.saveDefault()
        large_fit.saveDefault()
        large_full.saveDefault()
        small_fit.saveDefault()
        small_asis.saveDefault()
        checkerboard.saveDefault()
        interp_check.saveDefault()
        interp_spin.saveDefault()
        cache_slider.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
