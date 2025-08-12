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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - filetypesPDFQuality
// - filetypesExternalUnrar
// - filetypesVideoAutoplay
// - filetypesVideoLoop
// - filetypesVideoThumbnailer
// - filetypesVideoPreferLibmpv
// - imageviewAnimatedControls
// - imageviewEscapeExitDocument
// - imageviewEscapeExitArchive

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingsLoaded: false

    property bool catchEscape: pdf_quality.editMode

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQSetting {

            id: set_pdf

            //: Settings title
            title: qsTranslate("settingsmanager", "PDF")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show PDF and Postscript documents alongside your images, you can even enter a multi-page document and browse its pages as if they were images in a folder. The quality setting here - specified in dots per pixel (dpi) - affects the resolution and speed of loading such pages.")

            content: [

                PQSliderSpinBox {
                    id: pdf_quality
                    width: set_pdf.rightcol
                    minval: 50
                    maxval: 300
                    title: qsTranslate("settingsmanager", "quality:")
                    suffix: " dpi"
                    onValueChanged:
                        setting_top.checkDefault()
                },

                PQCheckBox {
                    id: pdf_escape
                    text: qsTranslate("settingsmanager", "Escape key leaves document viewer")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: pdf_exitbutton
                    text: qsTranslate("settingsmanager", "Show button to exit document viewer")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: pdf_autoenter
                    text: qsTranslate("settingsmanager", "Automatically enter document viewer")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                pdf_quality.setValue(PQCSettings.getDefaultForFiletypesPDFQuality())
                pdf_escape.checked = PQCSettings.getDefaultForImageviewEscapeExitDocument()
                pdf_exitbutton.checked = PQCSettings.getDefaultForFiletypesDocumentViewerModeExitButton()
                pdf_autoenter.checked = PQCSettings.getDefaultForFiletypesDocumentAlwaysEnterAutomatically()
            }

            function handleEscape() {
                pdf_quality.acceptValue()
            }

            function hasChanged() {
                return (pdf_quality.hasChanged() || pdf_escape.hasChanged() || pdf_exitbutton.hasChanged() || pdf_autoenter.hasChanged())
            }

            function load() {
                pdf_quality.loadAndSetDefault(PQCSettings.filetypesPDFQuality)
                pdf_escape.loadAndSetDefault(PQCSettings.imageviewEscapeExitDocument)
                pdf_exitbutton.loadAndSetDefault(PQCSettings.filetypesDocumentViewerModeExitButton)
                pdf_autoenter.loadAndSetDefault(PQCSettings.filetypesDocumentAlwaysEnterAutomatically)
            }

            function applyChanges() {
                PQCSettings.filetypesPDFQuality = pdf_quality.value
                PQCSettings.imageviewEscapeExitDocument = pdf_escape.checked
                PQCSettings.filetypesDocumentViewerModeExitButton = pdf_exitbutton.checked
                PQCSettings.filetypesDocumentAlwaysEnterAutomatically = pdf_autoenter.checked
                pdf_quality.saveDefault()
                pdf_escape.saveDefault()
                pdf_exitbutton.saveDefault()
                pdf_autoenter.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_arc

            //: Settings title
            title: qsTranslate("settingsmanager", "Archive")

            helptext: qsTranslate("settingsmanager",  "PhotoQt allows the browsing of all images contained in an archive file (ZIP, RAR, etc.) as if they all are located in a folder. By default, PhotoQt uses Libarchive for this purpose, but for RAR archives in particular PhotoQt can call the external tool unrar to load and display the archive and its contents. Note that this requires unrar to be installed and located in your path.") + (PQCSettings.generalCompactSettings ? ("<br><br>"+secondhelptext) : "")

            property string secondhelptext: qsTranslate("settingsmanager",  "When an archive is loaded it is possible to browse through the contents of such a file either through floating controls that show up when the archive contains more than one file, or by entering the viewer mode. When the viewer mode is activated all files in the archive are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating controls.")

            content: [
                PQCheckBox {
                    id: arc_extunrar
                    enforceMaxWidth: set_arc.rightcol
                    text: qsTranslate("settingsmanager", "use external tool: unrar")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Item {
                    width: set_arc.rightcol
                    height: PQCSettings.generalCompactSettings ? 0 : help2txt.height
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: PQCSettings.generalCompactSettings ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    clip: true
                    PQText {
                        id: help2txt
                        width: parent.width
                        text: set_arc.secondhelptext
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                },

                PQCheckBox {
                    id: archivecontrols
                    enforceMaxWidth: set_arc.rightcol
                    text: qsTranslate("settingsmanager", "show floating controls for archives")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: archiveleftright
                    enforceMaxWidth: set_arc.rightcol
                    text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: archive_escape
                    text: qsTranslate("settingsmanager", "Escape key leaves archive viewer")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: archive_exitbutton
                    text: qsTranslate("settingsmanager", "Show button to exit archive viewer")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: archive_autoenter
                    text: qsTranslate("settingsmanager", "Automatically enter archive viewer")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: archive_comautoenter
                    text: qsTranslate("settingsmanager", "Automatically enter comic book viewer")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                arc_extunrar.checked = PQCSettings.getDefaultForFiletypesExternalUnrar()
                archivecontrols.checked = PQCSettings.getDefaultForFiletypesArchiveControls()
                archiveleftright.checked = PQCSettings.getDefaultForFiletypesArchiveLeftRight()
                archive_escape.checked = PQCSettings.getDefaultForImageviewEscapeExitArchive()
                archive_exitbutton.checked = PQCSettings.getDefaultForFiletypesArchiveViewerModeExitButton()
                archive_autoenter.checked = PQCSettings.getDefaultForFiletypesArchiveAlwaysEnterAutomatically()
                archive_comautoenter.checked = PQCSettings.getDefaultForFiletypesComicBookAlwaysEnterAutomatically()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (arc_extunrar.hasChanged() || archivecontrols.hasChanged() || archiveleftright.hasChanged() || archive_escape.hasChanged() ||
                        archive_exitbutton.hasChanged() || archive_autoenter.hasChanged() || archive_comautoenter.hasChanged())
            }

            function load() {
                arc_extunrar.loadAndSetDefault(PQCSettings.filetypesExternalUnrar)
                archivecontrols.loadAndSetDefault(PQCSettings.filetypesArchiveControls)
                archiveleftright.loadAndSetDefault(PQCSettings.filetypesArchiveLeftRight)
                archive_escape.loadAndSetDefault(PQCSettings.imageviewEscapeExitArchive)
                archive_exitbutton.loadAndSetDefault(PQCSettings.filetypesArchiveViewerModeExitButton)
                archive_autoenter.loadAndSetDefault(PQCSettings.filetypesArchiveAlwaysEnterAutomatically)
                archive_comautoenter.loadAndSetDefault(PQCSettings.filetypesComicBookAlwaysEnterAutomatically)
            }

            function applyChanges() {
                PQCSettings.filetypesExternalUnrar = arc_extunrar.checked
                PQCSettings.filetypesArchiveControls = archivecontrols.checked
                PQCSettings.filetypesArchiveLeftRight = archiveleftright.checked
                PQCSettings.imageviewEscapeExitArchive = archive_escape.checked
                PQCSettings.filetypesArchiveViewerModeExitButton = archive_exitbutton.checked
                PQCSettings.filetypesArchiveAlwaysEnterAutomatically = archive_autoenter.checked
                PQCSettings.filetypesComicBookAlwaysEnterAutomatically = archive_comautoenter.checked
                arc_extunrar.saveDefault()
                archivecontrols.saveDefault()
                archiveleftright.saveDefault()
                archive_escape.saveDefault()
                archive_exitbutton.saveDefault()
                archive_autoenter.saveDefault()
                archive_comautoenter.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_vid

            //: Settings title
            title: qsTranslate("settingsmanager", "Video")

            helptext: qsTranslate("settingsmanager",  "PhotoQt can treat video files the same as image files, as long as the respective video formats are enabled. There are a few settings available for managing how videos behave in PhotoQt: Whether they should autoplay when loaded, whether they should loop from the beginning when the end is reached, whether to prefer libmpv (if available) or Qt for video playback, and which video thumbnail generator to use.")

            content: [

                PQCheckBox {
                    id: vid_autoplay
                    enforceMaxWidth: set_vid.rightcol
                    text: qsTranslate("settingsmanager", "Autoplay")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: vid_loop
                    enforceMaxWidth: set_vid.rightcol
                    text: qsTranslate("settingsmanager", "Loop")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Flow {
                    width: set_vid.rightcol
                    PQRadioButton {
                        id: vid_qtmult
                        text: qsTranslate("settingsmanager", "prefer Qt Multimedia")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: vid_libmpv
                        text: qsTranslate("settingsmanager", "prefer Libmpv")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                },

                Flow {
                    width: set_vid.rightcol
                    spacing: 10
                    Item {
                        width: 25
                        height: 1
                    }

                    PQText {
                        height: videothumb.height
                        verticalAlignment: Text.AlignVCenter
                        text: qsTranslate("settingsmanager", "Video thumbnail generator:")
                    }
                    PQComboBox {
                        id: videothumb
                        model: ["------",
                                "ffmpegthumbnailer"]
                        currentIndex: (PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)
                        onCurrentIndexChanged: setting_top.checkDefault()
                    }
                },

                PQCheckBox {
                    id: videojump
                    enforceMaxWidth: set_vid.rightcol
                    spacing: 10
                    text: qsTranslate("settingsmanager", "Always use left/right arrow keys to jump back/ahead in videos")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: videospace
                    enforceMaxWidth: set_vid.rightcol
                    spacing: 10
                    text: qsTranslate("settingsmanager", "Always use space key to play/pause videos")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                vid_autoplay.checked = PQCSettings.getDefaultForFiletypesVideoAutoplay()
                vid_loop.checked = PQCSettings.getDefaultForFiletypesVideoLoop()
                vid_qtmult.checked = !PQCSettings.getDefaultForFiletypesVideoPreferLibmpv()
                vid_libmpv.checked = PQCSettings.getDefaultForFiletypesVideoPreferLibmpv()
                videothumb.currentIndex = (PQCSettings.getDefaultForFiletypesVideoThumbnailer()==="" ? 0 : 1)
                videojump.checked = PQCSettings.getDefaultForFiletypesVideoLeftRightJumpVideo()
                videospace.checked = PQCSettings.getDefaultForFiletypesVideoSpacePause()
            }

            function handleEscape() {}

            function hasChanged() {
                return (vid_autoplay.hasChanged() || vid_loop.hasChanged() || vid_qtmult.hasChanged() ||
                        vid_libmpv.hasChanged() || videothumb.hasChanged() ||
                        videojump.hasChanged() || videospace.hasChanged())
            }

            function load() {
                vid_autoplay.loadAndSetDefault(PQCSettings.filetypesVideoAutoplay)
                vid_loop.loadAndSetDefault(PQCSettings.filetypesVideoLoop)
                vid_qtmult.loadAndSetDefault(!PQCSettings.filetypesVideoPreferLibmpv)
                vid_libmpv.loadAndSetDefault(PQCSettings.filetypesVideoPreferLibmpv)
                videothumb.loadAndSetDefault(PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)
                videojump.loadAndSetDefault(PQCSettings.filetypesVideoLeftRightJumpVideo)
                videospace.loadAndSetDefault(PQCSettings.filetypesVideoSpacePause)
            }

            function applyChanges() {
                PQCSettings.filetypesVideoAutoplay = vid_autoplay.checked
                PQCSettings.filetypesVideoLoop = vid_loop.checked
                PQCSettings.filetypesVideoPreferLibmpv = vid_libmpv.checked
                PQCSettings.filetypesVideoThumbnailer = (videothumb.currentIndex===1 ? videothumb.currentText : "")
                PQCSettings.filetypesVideoLeftRightJumpVideo = videojump.checked
                PQCSettings.filetypesVideoSpacePause = videospace.checked
                vid_autoplay.saveDefault()
                vid_loop.saveDefault()
                vid_qtmult.saveDefault()
                vid_libmpv.saveDefault()
                videothumb.saveDefault()
                videojump.saveDefault()
                videospace.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_ani

            //: Settings title
            title: qsTranslate("settingsmanager", "Animated images")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show controls for animated images that allow for stepping through an animated image frame by frame, jumping to a specific frame, and play/pause the animation. Additionally is is possible to force the left/right arrow keys to load the previous/next frame and/or use the space key to play/pause the animation, no matter what shortcut action is set to these keys.")

            content: [

                PQCheckBox {
                    id: animatedcontrol
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "show floating controls for animated images")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: animatedleftright
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next frame")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: animspace
                    enforceMaxWidth: set_ani.rightcol
                    text: qsTranslate("settingsmanager", "Always use space key to play/pause animation")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                animatedcontrol.checked = PQCSettings.getDefaultForFiletypesAnimatedControls()
                animatedleftright.checked = PQCSettings.getDefaultForFiletypesAnimatedLeftRight()
                animspace.checked = PQCSettings.getDefaultForFiletypesAnimatedSpacePause()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (animatedcontrol.hasChanged() || animatedleftright.hasChanged() || animspace.hasChanged())
            }

            function load() {
                animatedcontrol.loadAndSetDefault(PQCSettings.filetypesAnimatedControls)
                animatedleftright.loadAndSetDefault(PQCSettings.filetypesAnimatedLeftRight)
                animspace.loadAndSetDefault(PQCSettings.filetypesAnimatedSpacePause)
            }

            function applyChanges() {
                PQCSettings.filetypesAnimatedControls = animatedcontrol.checked
                PQCSettings.filetypesAnimatedLeftRight = animatedleftright.checked
                PQCSettings.filetypesAnimatedSpacePause = animspace.checked
                animatedcontrol.saveDefault()
                animatedleftright.saveDefault()
                animspace.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_raw

            //: Settings title
            title: qsTranslate("settingsmanager", "RAW images")

            helptext: qsTranslate("settingsmanager", "Some RAW images have embedded thumbnail images. If available, PhotoQt will always use those for generating a thumbnail image. Some embedded thumbnails are even as large as the actual RAW image. In that case, PhotoQt can simply load those embedded images instead of the full RAW image. This can result in much faster load times.")

            content: [
                PQCheckBox {
                    id: rawembed
                    enforceMaxWidth: set_raw.rightcol
                    text: qsTranslate("settingsmanager", "use embedded image if available")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                rawembed.checked = PQCSettings.getDefaultForFiletypesRAWUseEmbeddedIfAvailable()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return rawembed.hasChanged()
            }

            function load() {
                rawembed.loadAndSetDefault(PQCSettings.filetypesRAWUseEmbeddedIfAvailable)
            }

            function applyChanges() {
                PQCSettings.filetypesRAWUseEmbeddedIfAvailable = rawembed.checked
                rawembed.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_doc

            //: Settings title
            title: qsTranslate("settingsmanager", "Documents")

            helptext: qsTranslate("settingsmanager", "When a document is loaded it is possible to navigate through the pages of such a file either through floating controls that show up when the document contains more than one page, or by entering the viewer mode. When the viewer mode is activated all pages are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating navigation.")

            content: [

                PQCheckBox {
                    id: documentcontrols
                    enforceMaxWidth: set_doc.rightcol
                    text: qsTranslate("settingsmanager", "show floating controls for documents")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: documentleftright
                    enforceMaxWidth: set_doc.rightcol
                    text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                documentcontrols.checked = PQCSettings.getDefaultForFiletypesDocumentControls()
                documentleftright.checked = PQCSettings.getDefaultForFiletypesDocumentLeftRight()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (documentcontrols.hasChanged() || documentleftright.hasChanged())
            }

            function load() {
                documentcontrols.loadAndSetDefault(PQCSettings.filetypesDocumentControls)
                documentleftright.loadAndSetDefault(PQCSettings.filetypesDocumentLeftRight)
            }

            function applyChanges() {
                PQCSettings.filetypesDocumentControls = documentcontrols.checked
                PQCSettings.filetypesDocumentLeftRight = documentleftright.checked
                documentcontrols.saveDefault()
                documentleftright.saveDefault()
            }

        }

        Item {
            width: 1
            height: 1
        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_pdf.handleEscape()
        set_arc.handleEscape()
        set_vid.handleEscape()
        set_ani.handleEscape()
        set_raw.handleEscape()
        set_doc.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (set_pdf.hasChanged() || set_arc.hasChanged() || set_vid.hasChanged() ||
                                                      set_ani.hasChanged() || set_raw.hasChanged() || set_doc.hasChanged())

    }

    function load() {

        set_pdf.load()
        set_arc.load()
        set_vid.load()
        set_ani.load()
        set_raw.load()
        set_doc.load()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_pdf.applyChanges()
        set_arc.applyChanges()
        set_vid.applyChanges()
        set_ani.applyChanges()
        set_raw.applyChanges()
        set_doc.applyChanges()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function revertChanges() {
        load()
    }

}
