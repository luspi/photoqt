import QtQuick

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imageviewLoopThroughFolder
// - imageviewSortImagesBy
// - imageviewSortImagesAscending
// - imageviewZoomSpeed
// - imageviewZoomToCenter (currently not implemented)
// - imageviewZoomMinEnabled
// - imageviewZoomMin
// - imageviewZoomMaxEnabled
// - imageviewZoomMax
// - imageviewAnimationDuration
// - imageviewAnimationType
// - interfaceNavigationFloating
// - imageviewCache
// - imageviewInterpolationThreshold
// - imageviewInterpolationDisableForSmallImages

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Looping")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "When loading an image PhotoQt loads all images in the folder into the thumbnail for easy navigation. When PhotoQt reaches the end of the list of files, it can either stop right there or loop back to the other end of the list and keep going.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: loop
            x: (parent.width-width)/2
            //: When reaching the end of the images in the folder whether to loop back around to the beginning or not
            text: qsTranslate("settingsmanager_imageview", "Loop around")
            checked: PQCSettings.imageviewLoopThroughFolder
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Sort images")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "Images in a folder can be sorted in different ways depending on your preferences. These criteria here are the ones that can be used in a very quick way. Once a folder is loaded it is possible to further sort a folder in several advanced ways using the menu option for sorting.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQText {
                y: (sortcriteria.height-height)/2
                text: qsTranslate("settingsmanager_imageview", "Sort by:")
            }
            PQComboBox {
                id: sortcriteria
                        //: A criteria for sorting images
                model: [qsTranslate("settingsmanager_imageview", "natural name"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager_imageview", "name"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager_imageview", "time"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager_imageview", "size"),
                        //: A criteria for sorting images
                        qsTranslate("settingsmanager_imageview", "type")]
                onCurrentIndexChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQRadioButton {
                id: sortasc
                //: Sort images in ascending order
                text: qsTranslate("settingsmanager_imageview", "ascending order")
                checked: PQCSettings.imageviewSortImagesAscending
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: sortdesc
                //: Sort images in descending order
                text: qsTranslate("settingsmanager_imageview", "descending order")
                onCheckedChanged: checkDefault()
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Zoom")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "PhotoQt allows for a great deal of flexibility in viewing images at the perfect size. Additionally it allows for control of how fast the zoom happens, and if there is a minimum/maximum zoom level at which it should always stop no matter what. Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                text: qsTranslate("settingsmanager_imageview", "zoom speed:") + " " + zoomspeed.from + "%"
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
            text: qsTranslate("settingsmanager_imageview", "current value:") + " " + zoomspeed.value + "%"
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
                    text: qsTranslate("settingsmanager_imageview", "minimum zoom:") + " "
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
                text: qsTranslate("settingsmanager_imageview", "current value:") + " " + minzoom_slider.value + "%"
            }

            /****************/
            Item {
                width: 1
                height: 10
            }

            Row {
                PQCheckBox {
                    id: maxzoom_check
                    text: qsTranslate("settingsmanager_imageview", "maximum zoom:") + " "
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
                text: qsTranslate("settingsmanager_imageview", "current value:") + " " + maxzoom_slider.value + "%"
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Animation")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "When switching between images PhotoQt can add an animation to smoothes such a transition. There are a whole bunch of transitions to choose from, and also an option for PhotoQt to choose one at random each time. Additionally, the speed of the chosen animation can be chosen from very slow to very fast.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: anispeed_check
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_imageview", "animate switching between images")
            checked: (PQCSettings.imageviewAnimationDuration>0)
            onCheckedChanged: checkDefault()
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            enabled: anispeed_check.checked
            PQText {
                y: (anicombo.height-height)/2
                text: qsTranslate("settingsmanager_imageview", "Animation:")
            }
            PQComboBox {
                id: anicombo
                        //: This is referring to an in/out animation of images
                model: [qsTranslate("settingsmanager_imageview", "opacity"),
                        //: This is referring to an in/out animation of images
                        qsTranslate("settingsmanager_imageview", "along x-axis"),
                        //: This is referring to an in/out animation of images
                        qsTranslate("settingsmanager_imageview", "along y-axis"),
                        //: This is referring to an in/out animation of images
                        qsTranslate("settingsmanager_imageview", "rotation"),
                        //: This is referring to an in/out animation of images
                        qsTranslate("settingsmanager_imageview", "explosion"),
                        //: This is referring to an in/out animation of images
                        qsTranslate("settingsmanager_imageview", "implosion"),
                        //: This is referring to an in/out animation of images
                        qsTranslate("settingsmanager_imageview", "choose one at random")]
                lineBelowItem: [5]
                onCurrentIndexChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            enabled: anispeed_check.checked
            PQText {
                //: used here for the animation speed
                text: qsTranslate("settingsmanager_imageview", "very slow")
            }
            PQSlider {
                id: anispeed
                from: 1
                to: 10
                value: PQCSettings.imageviewAnimationDuration
                onValueChanged: checkDefault()
            }
            PQText {
                //: used here for the animation speed
                text: qsTranslate("settingsmanager_imageview", "very fast")
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Floating navigation")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "Switching between images can be done in various ways. It is possible to do so through the shortcuts, through the main menu, or through floating navigation buttons. These floating buttons were added especially with touch screens in mind, as it allows easier navigation without having to use neither the keyboard nor the mouse. In addition to buttons for navigation it also includes a button to hide and show the main menu.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: floatingnav
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_imageview", "show floating navigation buttons")
            checked: PQCSettings.interfaceNavigationFloating
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Cache")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "Whenever an image is loaded in full, PhotoQt caches such images in order to greatly improve performance if that same image is shown again soon after. This is done up to a certain memory limit after which the first images in the cache will be removed again to free up the required memory. Depending on the amount of memory available on the system, a higher value can lead to an improved user experience.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                text: "128 MB"
            }
            PQSlider {
                id: cache_slider
                from: 128
                to: 5120
                value: PQCSettings.imageviewCache
                onValueChanged: checkDefault()
            }
            PQText {
                text: "4 GB"
            }
        }
        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_imageview", "current value:") + " " + cache_slider.value + " MB"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_imageview", "Interpolation")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_imageview", "PhotoQt makes use of interpolation algorithms to show smooth lines and avoid potential artefacts to be shown. However, for small images this can lead to blurry images when no interpolation is necessary. Thus, for small images under the specified threshold PhotoQt can skip the use of interpolation algorithms. Note that both the width and height of an image need to be smaller than the threshold for it to be applied.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: interp_check
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_imageview", "disable interpolation for small images")
            checked: PQCSettings.imageviewInterpolationDisableForSmallImages
            onCheckedChanged: checkDefault()
        }

        Row {
            x: (parent.width-width)/2
            enabled: interp_check.checked
            PQText {
                text: "0px"
            }
            PQSlider {
                id: interp_slider
                from: 0
                to: 1000
                value: PQCSettings.imageviewInterpolationThreshold
                onValueChanged: checkDefault()
            }
            PQText {
                text: "1000px"
            }
        }

        PQText {
            x: (parent.width-width)/2
            enabled: interp_check.checked
            text: qsTranslate("settingsmanager_imageview", "current value:") + " " + interp_slider.value + "px"
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(loop.hasChanged() || sortasc.hasChanged() || sortdesc.hasChanged() ||
                zoomspeed.hasChanged() || minzoom_check.hasChanged() || minzoom_slider.hasChanged() ||
                maxzoom_check.hasChanged() || maxzoom_slider.hasChanged() || anispeed_check.hasChanged() ||
                anispeed.hasChanged() || floatingnav.hasChanged() || cache_slider.hasChanged() ||
                interp_check.hasChanged() || interp_slider.hasChanged()) {
            settingChanged = true
            return
        }

        var l = ["naturalname", "name", "time", "size", "type"]
        if(PQCSettings.imageviewSortImagesBy !== l[sortcriteria.currentIndex]) {
            settingChanged = true
            return
        }

        var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        if(PQCSettings.imageviewAnimationType !== aniValues[anicombo.currentIndex]) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        loop.loadAndSetDefault(PQCSettings.imageviewLoopThroughFolder)

        var l = ["naturalname", "name", "time", "size", "type"]
        if(l.indexOf(PQCSettings.imageviewSortImagesBy) > -1)
            sortcriteria.currentIndex = l.indexOf(PQCSettings.imageviewSortImagesBy)
        else
            sortcriteria.currentIndex = 0

        sortasc.loadAndSetDefault(PQCSettings.imageviewSortImagesAscending)
        sortdesc.loadAndSetDefault(!PQCSettings.imageviewSortImagesAscending)

        zoomspeed.loadAndSetDefault(PQCSettings.imageviewZoomSpeed)
        minzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMinEnabled)
        minzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMin)
        maxzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMaxEnabled)
        maxzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMax)

        anispeed_check.loadAndSetDefault(PQCSettings.imageviewAnimationDuration>0)
        var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
        if(aniValues.indexOf(PQCSettings.imageviewAnimationType) > -1)
            anicombo.currentIndex = aniValues.indexOf(PQCSettings.imageviewAnimationType)
        else
            anicombo.currentIndex = 0
        anispeed.loadAndSetDefault(PQCSettings.imageviewAnimationDuration)

        floatingnav.loadAndSetDefault(PQCSettings.interfaceNavigationFloating)

        cache_slider.loadAndSetDefault(PQCSettings.imageviewCache)

        interp_check.loadAndSetDefault(PQCSettings.imageviewInterpolationDisableForSmallImages)
        interp_slider.loadAndSetDefault(PQCSettings.imageviewInterpolationThreshold)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.imageviewLoopThroughFolder = loop.checked

        var l = ["naturalname", "name", "time", "size", "type"]
        PQCSettings.imageviewSortImagesBy = l[sortcriteria.currentIndex]

        PQCSettings.imageviewSortImagesAscending = sortasc.checked

        PQCSettings.imageviewZoomSpeed = zoomspeed.value
        PQCSettings.imageviewZoomMinEnabled = minzoom_check.checked
        PQCSettings.imageviewZoomMin = minzoom_slider.value
        PQCSettings.imageviewZoomMaxEnabled = maxzoom_check.checked
        PQCSettings.imageviewZoomMax = maxzoom_slider.value

        if(!anispeed_check.checked)
            PQCSettings.imageviewAnimationDuration = 0
        else {
            var aniValues = ["opacity", "x", "y", "rotation", "explosion", "implosion", "random"]
            PQCSettings.imageviewAnimationType = aniValues[anicombo.currentIndex]
        }
        PQCSettings.imageviewAnimationDuration = anispeed.value

        PQCSettings.interfaceNavigationFloating = floatingnav.checked

        PQCSettings.imageviewCache = cache_slider.value

        PQCSettings.imageviewInterpolationDisableForSmallImages = interp_check.checked
        PQCSettings.imageviewInterpolationThreshold = interp_slider.value

        loop.saveDefault()
        sortasc.saveDefault()
        sortdesc.saveDefault()
        zoomspeed.saveDefault()
        minzoom_check.saveDefault()
        minzoom_slider.saveDefault()
        maxzoom_check.saveDefault()
        maxzoom_slider.saveDefault()
        anispeed_check.saveDefault()
        anispeed.saveDefault()
        floatingnav.saveDefault()
        cache_slider.saveDefault()
        interp_check.saveDefault()
        interp_slider.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
