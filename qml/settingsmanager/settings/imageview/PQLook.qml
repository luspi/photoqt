import QtQuick
import QtQuick.Controls

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

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Margin")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt shows the main image fully stretched across its application window. For an improved visual experience, it can add a small margin of some pixels around the image to not have it stretch completely from edge to edge. Note that once an image is zoomed in the margin might be filled, it only applies to the default zoom level of an image.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                text: "none"
            }
            PQSlider {
                id: marginslider
                from: 0
                to: 100
                value: PQCSettings.imageviewMargin
                onValueChanged: checkDefault()
            }

            PQText {
                text: marginslider.to+"px"
            }
        }
        PQText {
            x: (parent.width-width)/2
            text: "current value: " + marginslider.value + "px"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Image size")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt ensures that an image is fully visible when first loaded. To achieve this, large images are zoomed out to fit into the view, but images smaller than the view are left as-is. Alternatively, large images can be loaded at full scale, and small images can be zoomed in to also fit into view. The latter option might result in small images appearing pixelated.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                y: (large_fit.height-height)/2
                text: "large images:"
            }
            PQRadioButton {
                id: large_fit
                text: "fit to view"
            }
            PQRadioButton {
                id: large_full
                text: "load at full scale"
                checked: PQCSettings.imageviewAlwaysActualSize
                onCheckedChanged: checkDefault()
            }
        }

        Item {
            width: 1
            height: 1
        }

        Row {
            x: (parent.width-width)/2

            PQText {
                y: (small_fit.height-height)/2
                text: "small images:"
            }
            PQRadioButton {
                id: small_fit
                text: "fit to view"
                checked: PQCSettings.imageviewFitInWindow
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: small_asis
                text: "load as-is"
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Transparency marker")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When an image contains transparent areas, then that area can be left transparent resulting in the background of PhotoQt to show. Alternatively, it is possible to show a checkerboard pattern behind the image, exposing the transparent areas of an image much clearer.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: checkerboard
            x: (parent.width-width)/2
            text: "show checkerboard pattern"
            checked: PQCSettings.imageviewTransparencyMarker
            onCheckedChanged: checkDefault()
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(marginslider.hasChanged() || large_fit.hasChanged() || large_full.hasChanged() || small_fit.hasChanged() || small_asis.hasChanged() ||
                checkerboard.hasChanged()) {
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

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.imageviewMargin = marginslider.value

        PQCSettings.imageviewAlwaysActualSize = large_full.checked
        PQCSettings.imageviewFitInWindow = small_fit.checked

        PQCSettings.imageviewTransparencyMarker = checkerboard.checked

        PQCSettings.imageviewInterpolationDisableForSmallImages = interp_check.checked
        PQCSettings.imageviewInterpolationThreshold = interp_slider.value

        marginslider.saveDefault()
        large_fit.saveDefault()
        large_full.saveDefault()
        small_fit.saveDefault()
        small_asis.saveDefault()
        checkerboard.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
