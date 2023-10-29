import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - filetypesPDFQuality
// - filetypesExternalUnrar
// - filetypesVideoAutoplay
// - filetypesVideoLoop
// - filetypesVideoThumbnailer
// - filetypesVideoPreferLibmpv

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
            text: qsTranslate("settingsmanager_filetypes", "PDF")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_filetypes", "PhotoQt can show PDF and Postscript documents alongside your images, you can even enter a multi-page document and browse its pages as if they were images in a folder. The quality setting here - specified in dots per pixel (dpi) - affects the resolution and speed of loading such pages.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {

            x: (parent.width-width)/2
            spacing: 5

            PQText {
                text: pdf_quality.from+" dpi"
            }

            PQSlider {
                id: pdf_quality
                from: 50
                to: 300
                value: PQCSettings.filetypesPDFQuality
                onValueChanged: checkDefault()
            }

            PQText {
                text: pdf_quality.to+" dpi"
            }
        }

        PQText {
            x: (parent.width-width)/2
            //: The current value of the slider specifying the PDF quality
            text: qsTranslate("settingsmanager_filetypes", "current value:") + " " + pdf_quality.value + " dpi"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_filetypes", "Archive")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_filetypes",  "PhotoQt allows the browsing of all images contained in an archive file (ZIP, RAR, etc.) as if they all are located in a folder. By default, PhotoQt uses Libarchive for this purpose, but for RAR archives in particular PhotoQt can call the external tool unrar to load and display the archive and its contents. Note that this requires unrar to be installed and located in your path.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: arc_extunrar
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_filetypes", "use external tool: unrar")
            checked: PQCSettings.filetypesExternalUnrar
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_filetypes", "Video")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_filetypes",  "PhotoQt can treat video files the same as image files, as long as the respective video formats are enabled. There are a few settings available for managing how videos behave in PhotoQt: Whether they should autoplay when loaded, whether they should loop from the beginning when the end is reached, whether to prefer libmpv (if available) or Qt for video playback, and which video thumbnail generator to use.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQCheckBox {
                id: vid_autoplay
                text: qsTranslate("settingsmanager_filetypes", "Autoplay")
                checked: PQCSettings.filetypesVideoAutoplay
                onCheckedChanged: checkDefault()
            }
            PQCheckBox {
                id: vid_loop
                text: qsTranslate("settingsmanager_filetypes", "Loop")
                checked: PQCSettings.filetypesVideoLoop
                onCheckedChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            PQRadioButton {
                id: vid_qtmult
                text: qsTranslate("settingsmanager_filetypes", "prefer Qt Multimedia")
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: vid_libmpv
                text: qsTranslate("settingsmanager_filetypes", "prefer Libmpv")
                checked: PQCSettings.filetypesVideoPreferLibmpv
                onCheckedChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 10
            PQText {
                y: (videothumb.height-height)/2
                text: qsTranslate("settingsmanager_filetypes", "Video thumbnail generator:")
            }
            PQComboBox {
                id: videothumb
                model: ["------",
                        "ffmpegthumbnailer"]
                currentIndex: (PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)
                onCurrentIndexChanged: checkDefault()
            }
        }

        Item {
            width: 1
            height: 1
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(pdf_quality.hasChanged() || arc_extunrar.hasChanged()) {
            settingChanged = true
            return
        }

        if(vid_autoplay.hasChanged() || vid_loop.hasChanged() || vid_qtmult.hasChanged() ||
                vid_libmpv.hasChanged() || (videothumb.currentIndex==1 && PQCSettings.filetypesVideoThumbnailer==="") ||
                (videothumb.currentIndex==0 && PQCSettings.filetypesVideoThumbnailer!=="")) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        pdf_quality.loadAndSetDefault(PQCSettings.filetypesPDFQuality)

        arc_extunrar.loadAndSetDefault(PQCSettings.filetypesExternalUnrar)

        vid_autoplay.loadAndSetDefault(PQCSettings.filetypesVideoAutoplay)
        vid_loop.loadAndSetDefault(PQCSettings.filetypesVideoLoop)
        vid_qtmult.loadAndSetDefault(!PQCSettings.filetypesVideoPreferLibmpv)
        vid_libmpv.loadAndSetDefault(PQCSettings.filetypesVideoPreferLibmpv)
        videothumb.currentIndex = (PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.filetypesPDFQuality = pdf_quality.value

        PQCSettings.filetypesExternalUnrar = arc_extunrar.checked

        PQCSettings.filetypesVideoAutoplay = vid_autoplay.checked
        PQCSettings.filetypesVideoLoop = vid_loop.checked
        PQCSettings.filetypesVideoPreferLibmpv = vid_libmpv.checked
        PQCSettings.filetypesVideoThumbnailer = (videothumb.currentIndex===1 ? videothumb.currentText : "")

        pdf_quality.saveDefault()
        arc_extunrar.saveDefault()
        vid_autoplay.saveDefault()
        vid_loop.saveDefault()
        vid_qtmult.saveDefault()
        vid_libmpv.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
