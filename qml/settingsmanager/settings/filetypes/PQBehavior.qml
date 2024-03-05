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
// - filetypesPDFQuality
// - filetypesExternalUnrar
// - filetypesVideoAutoplay
// - filetypesVideoLoop
// - filetypesVideoThumbnailer
// - filetypesVideoPreferLibmpv
// - imageviewAnimatedControls

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

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "PDF")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt can show PDF and Postscript documents alongside your images, you can even enter a multi-page document and browse its pages as if they were images in a folder. The quality setting here - specified in dots per pixel (dpi) - affects the resolution and speed of loading such pages.")
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
            text: qsTranslate("settingsmanager", "current value:") + " " + pdf_quality.value + " dpi"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Archive")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "PhotoQt allows the browsing of all images contained in an archive file (ZIP, RAR, etc.) as if they all are located in a folder. By default, PhotoQt uses Libarchive for this purpose, but for RAR archives in particular PhotoQt can call the external tool unrar to load and display the archive and its contents. Note that this requires unrar to be installed and located in your path.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: arc_extunrar
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "use external tool: unrar")
            checked: PQCSettings.filetypesExternalUnrar
            onCheckedChanged: checkDefault()
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "When an archive is loaded it is possible to browse through the contents of such a file either through floating controls that show up when the document contains more than one page, or by entering the viewer mode. When the viewer mode is activated all files in the archive are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating controls.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: archivecontrols
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show floating controls for archives")
            checked: PQCSettings.imageviewArchiveControls
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: archiveleftright
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
            checked: PQCSettings.imageviewArchiveLeftRight
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Video")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "PhotoQt can treat video files the same as image files, as long as the respective video formats are enabled. There are a few settings available for managing how videos behave in PhotoQt: Whether they should autoplay when loaded, whether they should loop from the beginning when the end is reached, whether to prefer libmpv (if available) or Qt for video playback, and which video thumbnail generator to use.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQCheckBox {
                id: vid_autoplay
                text: qsTranslate("settingsmanager", "Autoplay")
                checked: PQCSettings.filetypesVideoAutoplay
                onCheckedChanged: checkDefault()
            }
            PQCheckBox {
                id: vid_loop
                text: qsTranslate("settingsmanager", "Loop")
                checked: PQCSettings.filetypesVideoLoop
                onCheckedChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            PQRadioButton {
                id: vid_qtmult
                text: qsTranslate("settingsmanager", "prefer Qt Multimedia")
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: vid_libmpv
                text: qsTranslate("settingsmanager", "prefer Libmpv")
                checked: PQCSettings.filetypesVideoPreferLibmpv
                onCheckedChanged: checkDefault()
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 10
            PQText {
                y: (videothumb.height-height)/2
                text: qsTranslate("settingsmanager", "Video thumbnail generator:")
            }
            PQComboBox {
                id: videothumb
                model: ["------",
                        "ffmpegthumbnailer"]
                currentIndex: (PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)
                onCurrentIndexChanged: checkDefault()
            }
        }

        PQCheckBox {
            id: videojump
            x: (parent.width-width)/2
            spacing: 10
            text: qsTranslate("settingsmanager", "Always use left/right arrow keys to jump back/ahead in videos")
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: videospace
            x: (parent.width-width)/2
            spacing: 10
            text: qsTranslate("settingsmanager", "Always use space key to play/pause videos")
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Animated images")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt can show controls for animated images that allow for stepping through an animated image frame by frame, jumping to a specific frame, and play/pause the animation. Additionally is is possible to force the left/right arrow keys to load the previous/next frame and/or use the space key to play/pause the animation, no matter what shortcut action is set to these keys.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: animatedcontrol
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show floating controls for animated images")
            checked: PQCSettings.imageviewAnimatedControls
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: animatedleftright
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next frame")
            checked: PQCSettings.imageviewAnimatedLeftRight
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: animspace
            x: (parent.width-width)/2
            spacing: 10
            text: qsTranslate("settingsmanager", "Always use space key to play/pause animation")
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "RAW images")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Some RAW images have embedded thumbnail images. If available, PhotoQt will always use those for generating a thumbnail image. Some embedded thumbnails are even as large as the actual RAW image. In that case, PhotoQt can simply load those embedded images instead of the full RAW image. This can result in much faster load times.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: rawembed
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "use embedded image if available")
            checked: PQCSettings.filetypesRAWUseEmbeddedIfAvailable
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Documents")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When a document is loaded it is possible to navigate through the pages of such a file either through floating controls that show up when the document contains more than one page, or by entering the viewer mode. When the viewer mode is activated all pages are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating navigation.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: documentcontrols
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show floating controls for documents")
            checked: PQCSettings.imageviewDocumentControls
            onCheckedChanged: checkDefault()
        }

        PQCheckBox {
            id: documentleftright
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
            checked: PQCSettings.imageviewDocumentLeftRight
            onCheckedChanged: checkDefault()
        }

        Item {
            width: 1
            height: 1
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

        if(pdf_quality.hasChanged() || arc_extunrar.hasChanged()) {
            settingChanged = true
            return
        }

        if(vid_autoplay.hasChanged() || vid_loop.hasChanged() || vid_qtmult.hasChanged() ||
                vid_libmpv.hasChanged() || (videothumb.currentIndex===1 && PQCSettings.filetypesVideoThumbnailer==="") ||
                (videothumb.currentIndex===0 && PQCSettings.filetypesVideoThumbnailer!=="") ||
                videojump.hasChanged() || videospace.hasChanged()) {
            settingChanged = true
            return
        }

        if(animatedcontrol.hasChanged() || animatedleftright.hasChanged() || animspace.hasChanged()) {
            settingChanged = true
            return
        }

        if(documentcontrols.hasChanged() || documentleftright.hasChanged()) {
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
        videojump.loadAndSetDefault(PQCSettings.imageviewVideoLeftRightJumpVideo)
        videospace.loadAndSetDefault(PQCSettings.imageviewVideoSpacePause)

        animatedcontrol.loadAndSetDefault(PQCSettings.imageviewAnimatedControls)
        animatedleftright.loadAndSetDefault(PQCSettings.imageviewAnimatedLeftRight)
        animspace.loadAndSetDefault(PQCSettings.imageviewAnimatedSpacePause)

        documentcontrols.loadAndSetDefault(PQCSettings.imageviewDocumentControls)
        documentleftright.loadAndSetDefault(PQCSettings.imageviewDocumentLeftRight)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesPDFQuality = pdf_quality.value

        PQCSettings.filetypesExternalUnrar = arc_extunrar.checked

        PQCSettings.filetypesVideoAutoplay = vid_autoplay.checked
        PQCSettings.filetypesVideoLoop = vid_loop.checked
        PQCSettings.filetypesVideoPreferLibmpv = vid_libmpv.checked
        PQCSettings.filetypesVideoThumbnailer = (videothumb.currentIndex===1 ? videothumb.currentText : "")
        PQCSettings.imageviewVideoLeftRightJumpVideo = videojump.checked
        PQCSettings.imageviewVideoSpacePause = videospace.checked

        PQCSettings.imageviewAnimatedControls = animatedcontrol.checked
        PQCSettings.imageviewAnimatedLeftRight = animatedleftright.checked
        PQCSettings.imageviewAnimatedSpacePause = animspace.checked

        PQCSettings.imageviewDocumentControls = documentcontrols.checked
        PQCSettings.imageviewDocumentLeftRight = documentleftright.checked

        pdf_quality.saveDefault()
        arc_extunrar.saveDefault()
        vid_autoplay.saveDefault()
        vid_loop.saveDefault()
        vid_qtmult.saveDefault()
        vid_libmpv.saveDefault()
        videojump.saveDefault()
        videospace.saveDefault()
        documentcontrols.saveDefault()
        documentleftright.saveDefault()
        animatedcontrol.saveDefault()
        animatedleftright.saveDefault()
        animspace.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
