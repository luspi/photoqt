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
import Qt.labs.platform
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_fata

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Face tags")

            helptext: qsTranslate("settingsmanager",  "PhotoQt can read face tags stored in its metadata. It offers a great deal of flexibility in how and when the face tags are shown. It is also possible to remove and add face tags using the face tagger interface (accessible through the context menu or by shortcut).")

            showLineAbove: false

        },

        PQCheckBox {
            id: facetags_show
            enforceMaxWidth: set_fata.contentWidth
            text: qsTranslate("settingsmanager", "show face tags")
            onCheckedChanged: set_fata.checkForChanges()
        },

        Row {

            id: row_showhow

            PQSettingSpacer {}

            Column {

                spacing: 10
                enabled: facetags_show.checked

                PQRadioButton {
                    id: tags_always
                    enforceMaxWidth: set_fata.contentWidth
                    //: used as in: always show all face tags
                    text: qsTranslate("settingsmanager", "always show all")
                    onCheckedChanged: set_fata.checkForChanges()
                }

                PQRadioButton {
                    id: tags_one
                    enforceMaxWidth: set_fata.contentWidth
                    //: used as in: show one face tag on hover
                    text: qsTranslate("settingsmanager", "show one on hover")
                    onCheckedChanged: set_fata.checkForChanges()
                }

                PQRadioButton {
                    id: tags_all
                    enforceMaxWidth: set_fata.contentWidth
                    //: used as in: show one face tag on hover
                    text: qsTranslate("settingsmanager", "show all on hover")
                    onCheckedChanged: set_fata.checkForChanges()
                }

            }

        },

        /*************************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Look of face tags")
            helptext: qsTranslate("settingsmanager", "It is possible to adjust the border shown around tagged faces and the font size used for the displayed name. For the border, not only the width but also the color can be specified.")
        },

        PQSliderSpinBox {
            id: fontsize
            width: set_fata.contentWidth
            minval: 5
            maxval: 50
            title: qsTranslate("settingsmanager", "font size:")
            suffix: " pt"
            onValueChanged:
                set_fata.checkForChanges()
        },

        PQCheckBox {
            id: border_show
            enforceMaxWidth: set_fata.contentWidth
            text: qsTranslate("settingsmanager", "show border around face tags")
            onCheckedChanged: set_fata.checkForChanges()
        },

        Row {

            PQSettingSpacer {}

            Column {

                spacing: 15

                enabled: border_show.checked

                PQSliderSpinBox {
                    id: border_slider
                    width: set_fata.contentWidth - parent.x
                    minval: 1
                    maxval: 20
                    title: qsTranslate("settingsmanager", "border width:")
                    suffix: " px"
                    onValueChanged:
                        set_fata.checkForChanges()
                }

                Row {

                    spacing: 5

                    PQText {
                        y: (border_color.height-height)/2
                        text: qsTranslate("settingsmanager", "color:")
                    }

                    Rectangle {
                        id: border_color
                        width: 100
                        height: border_show.height
                        property list<int> rgba: PQCScriptsOther.convertHexToRgba(PQCSettings.metadataFaceTagsBorderColor)
                        onRgbaChanged: set_fata.checkForChanges()
                        color: Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)

                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                coldiag.currentColor = border_color.color
                                coldiag.open()
                            }
                        }

                    }

                }

            }

        }

    ]

    ColorDialog {
        id: coldiag
        modality: Qt.ApplicationModal
        onAccepted: {
            border_color.rgba = [255*coldiag.currentColor.r, 255*coldiag.currentColor.g, 255*coldiag.currentColor.b, 255*coldiag.currentColor.a]
        }
    }

    onResetToDefaults: {

        facetags_show.checked = PQCSettings.getDefaultForMetadataFaceTagsEnabled()
        var val = PQCSettings.getDefaultForMetadataFaceTagsVisibility()
        tags_always.checked = (val === 1)
        tags_one.checked = (val === 2)
        tags_all.checked = (val === 3)

        fontsize.setValue(PQCSettings.getDefaultForMetadataFaceTagsFontSize())
        border_show.checked = PQCSettings.getDefaultForMetadataFaceTagsBorder()
        border_slider.setValue(PQCSettings.getDefaultForMetadataFaceTagsBorderWidth())
        border_color.rgba = PQCScriptsOther.convertHexToRgba(PQCSettings.getDefaultForMetadataFaceTagsBorderColor())

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {
        fontsize.acceptValue()
        border_slider.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        var colset = PQCScriptsOther.convertHexToRgba(PQCSettings.metadataFaceTagsBorderColor)

        PQCConstants.settingsManagerSettingChanged = (facetags_show.hasChanged() || tags_always.hasChanged() || tags_one.hasChanged() || tags_all.hasChanged() |
                                                      fontsize.hasChanged() || border_show.hasChanged() || border_slider.hasChanged() ||
                                                      border_color.rgba[0] !== colset[0] || border_color.rgba[1] !== colset[1] ||
                                                      border_color.rgba[2] !== colset[2] || border_color.rgba[3] !== colset[3])

    }

    function load() {

        settingsLoaded = false

        facetags_show.loadAndSetDefault(PQCSettings.metadataFaceTagsEnabled)
        tags_always.loadAndSetDefault(PQCSettings.metadataFaceTagsVisibility===1)
        tags_one.loadAndSetDefault(PQCSettings.metadataFaceTagsVisibility===2)
        tags_all.loadAndSetDefault(PQCSettings.metadataFaceTagsVisibility===3)

        fontsize.loadAndSetDefault(PQCSettings.metadataFaceTagsFontSize)
        border_show.loadAndSetDefault(PQCSettings.metadataFaceTagsBorder)
        border_slider.loadAndSetDefault(PQCSettings.metadataFaceTagsBorderWidth)
        border_color.rgba = PQCScriptsOther.convertHexToRgba(PQCSettings.metadataFaceTagsBorderColor)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.metadataFaceTagsEnabled = facetags_show.checked
        if(tags_always.checked)
            PQCSettings.metadataFaceTagsVisibility = 1
        else if(tags_one.checked)
            PQCSettings.metadataFaceTagsVisibility = 2
        else
            PQCSettings.metadataFaceTagsVisibility = 3

        facetags_show.saveDefault()
        tags_always.saveDefault()
        tags_one.saveDefault()
        tags_all.saveDefault()

        PQCSettings.metadataFaceTagsFontSize = fontsize.value
        PQCSettings.metadataFaceTagsBorder = border_show.checked
        PQCSettings.metadataFaceTagsBorderWidth = border_slider.value
        PQCSettings.metadataFaceTagsBorderColor = PQCScriptsOther.convertRgbaToHex(border_color.rgba)

        fontsize.saveDefault()
        border_show.saveDefault()
        border_slider.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
