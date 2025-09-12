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

    id: set_docu

    content: [

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "PDF")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show PDF and Postscript documents alongside your images, you can even enter a multi-page document and browse its pages as if they were images in a folder. The quality setting here - specified in dots per pixel (dpi) - affects the resolution and speed of loading such pages.")

            showLineAbove: false

        },

        PQSliderSpinBox {
            id: pdf_quality
            width: set_docu.contentWidth
            minval: 50
            maxval: 300
            title: qsTranslate("settingsmanager", "quality:")
            suffix: " dpi"
            onValueChanged:
                set_docu.checkForChanges()
        },

        PQCheckBox {
            id: pdf_escape
            text: qsTranslate("settingsmanager", "Escape key leaves document viewer")
            onCheckedChanged: set_docu.checkForChanges()
        },

        PQCheckBox {
            id: pdf_exitbutton
            text: qsTranslate("settingsmanager", "Show button to exit document viewer")
            onCheckedChanged: set_docu.checkForChanges()
        },

        PQCheckBox {
            id: pdf_autoenter
            text: qsTranslate("settingsmanager", "Automatically enter document viewer")
            onCheckedChanged: set_docu.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                pdf_quality.setValue(PQCSettings.getDefaultForFiletypesPDFQuality())
                pdf_escape.checked = PQCSettings.getDefaultForImageviewEscapeExitDocument()
                pdf_exitbutton.checked = PQCSettings.getDefaultForFiletypesDocumentViewerModeExitButton()
                pdf_autoenter.checked = PQCSettings.getDefaultForFiletypesDocumentAlwaysEnterAutomatically()

                set_docu.checkForChanges()

            }
        },

        /***************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Documents")

            helptext: qsTranslate("settingsmanager", "When a document is loaded it is possible to navigate through the pages of such a file either through floating controls that show up when the document contains more than one page, or by entering the viewer mode. When the viewer mode is activated all pages are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating navigation.")

        },

        PQCheckBox {
            id: documentcontrols
            enforceMaxWidth: set_docu.contentWidth
            text: qsTranslate("settingsmanager", "show floating controls for documents")
            onCheckedChanged: set_docu.checkForChanges()
        },

        PQCheckBox {
            id: documentleftright
            enforceMaxWidth: set_docu.contentWidth
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
            onCheckedChanged: set_docu.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                documentcontrols.checked = PQCSettings.getDefaultForFiletypesDocumentControls()
                documentleftright.checked = PQCSettings.getDefaultForFiletypesDocumentLeftRight()

                set_docu.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        pdf_quality.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (documentcontrols.hasChanged() || documentleftright.hasChanged() || pdf_quality.hasChanged() ||
                                                      pdf_escape.hasChanged() || pdf_exitbutton.hasChanged() || pdf_autoenter.hasChanged())

    }

    function load() {

        settingsLoaded = false

        documentcontrols.loadAndSetDefault(PQCSettings.filetypesDocumentControls)
        documentleftright.loadAndSetDefault(PQCSettings.filetypesDocumentLeftRight)

        pdf_quality.loadAndSetDefault(PQCSettings.filetypesPDFQuality)
        pdf_escape.loadAndSetDefault(PQCSettings.imageviewEscapeExitDocument)
        pdf_exitbutton.loadAndSetDefault(PQCSettings.filetypesDocumentViewerModeExitButton)
        pdf_autoenter.loadAndSetDefault(PQCSettings.filetypesDocumentAlwaysEnterAutomatically)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesDocumentControls = documentcontrols.checked
        PQCSettings.filetypesDocumentLeftRight = documentleftright.checked
        documentcontrols.saveDefault()
        documentleftright.saveDefault()

        PQCSettings.filetypesPDFQuality = pdf_quality.value
        PQCSettings.imageviewEscapeExitDocument = pdf_escape.checked
        PQCSettings.filetypesDocumentViewerModeExitButton = pdf_exitbutton.checked
        PQCSettings.filetypesDocumentAlwaysEnterAutomatically = pdf_autoenter.checked
        pdf_quality.saveDefault()
        pdf_escape.saveDefault()
        pdf_exitbutton.saveDefault()
        pdf_autoenter.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
