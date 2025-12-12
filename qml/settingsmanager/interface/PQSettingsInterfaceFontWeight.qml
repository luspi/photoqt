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
import PhotoQt

PQSetting {

    id: set_fowe

    property list<string> values: [
                //: This refers to a type of font weight (thin is the lightest weight)
                qsTranslate("settingsmanager", "thin"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "very light"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "light"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "normal"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "medium"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "medium bold"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "bold"),
                //: This refers to a type of font weight
                qsTranslate("settingsmanager", "extra bold"),
                //: This refers to a type of font weight (black is the darkest, most bold weight)
                qsTranslate("settingsmanager", "black")
    ]

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Font weight")

            helptext: qsTranslate("settingsmanager", "All text in PhotoQt is shown with one of two weights, either as regular text or in bold face. Here the actual weight used can be adjusted for the two types. The default weight for normal text is 400 and for bold text is 700.")

        },

        Flow {
            width: set_fowe.contentWidth
            spacing: 5
            PQText {
                y: (fw_normalslider.height-height)/2
                text: qsTranslate("settingsmanager", "normal font weight:")
            }
            PQSlider {
                id: fw_normalslider
                from: 100
                to: 900
                stepSize: 10
                wheelStepSize: 10
                onValueChanged: set_fowe.checkForChanges()
            }

        },

        PQText {
            text: qsTranslate("settingsmanager", "current weight:") + " " + fw_normalslider.value + " (" + set_fowe.values[Math.floor(fw_normalslider.value/100)-1] + ")"
        },

        Item {
            width: 1
            height: 10
        },

        Flow {
            width: set_fowe.contentWidth
            spacing: 5
            PQText {
                y: (fw_boldslider.height-height)/2
                //: The weight here refers to the font weight
                text: qsTranslate("settingsmanager", "bold font weight:")
            }
            PQSlider {
                id: fw_boldslider
                from: 100
                to: 900
                stepSize: 10
                wheelStepSize: 10
                onValueChanged: set_fowe.checkForChanges()
            }

        },

        PQText {
            text: qsTranslate("settingsmanager", "current weight:") + " " + fw_boldslider.value + " (" + set_fowe.values[Math.round(fw_boldslider.value/100)-1] + ")"
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                fw_normalslider.value = PQCSettings.getDefaultForInterfaceFontNormalWeight()
                fw_boldslider.value = PQCSettings.getDefaultForInterfaceFontBoldWeight()

                set_fowe.checkForChanges()

            }
        }

    ]

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (fw_normalslider.hasChanged() || fw_boldslider.hasChanged())

    }

    function load() {

        settingsLoaded = false

        fw_normalslider.loadAndSetDefault(PQCSettings.interfaceFontNormalWeight)
        fw_boldslider.loadAndSetDefault(PQCSettings.interfaceFontBoldWeight)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceFontNormalWeight = fw_normalslider.value
        PQCSettings.interfaceFontBoldWeight = fw_boldslider.value
        fw_normalslider.saveDefault()
        fw_boldslider.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
