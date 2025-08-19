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

    id: set_anim

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Animate switching images")

            helptext: qsTranslate("settingsmanager",  "When switching between images PhotoQt can add an animation to smoothes such a transition. There are a whole bunch of transitions to choose from, and also an option for PhotoQt to choose one at random each time. Additionally, the speed of the chosen animation can be chosen from very slow to very fast.")

            showLineAbove: false

        },

        PQCheckBox {
            id: anispeed_check
            enforceMaxWidth: set_anim.contentWidth
            text: qsTranslate("settingsmanager", "animate switching between images")
            onCheckedChanged: set_anim.checkForChanges()
        },

        Column {

            spacing: 15

            enabled: anispeed_check.checked
            clip: true

            height: enabled ? (anirow1.height+anirow2.height+spacing) : 0
            opacity: enabled ? 1 : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Flow {
                id: anirow1
                spacing: 5
                width: set_anim.contentWidth
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
                    onCurrentIndexChanged: set_anim.checkForChanges()
                }
            }

            Column {

                id: anirow2

                spacing: 5

                PQSliderSpinBox {
                    id: anispeed
                    width: set_anim.contentWidth
                    minval: 1
                    maxval: 10
                    title: qsTranslate("settingsmanager", "speed:")
                    suffix: ""
                    onValueChanged:
                        set_anim.checkForChanges()
                }

                PQText {
                    width: set_anim.contentWidth
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    //: The value is a numerical value expressing the speed of animating between images
                    text: qsTranslate("settingsmanager", "(higher value = slower)")
                }

            }

        }

    ]

    onResetToDefaults: {

        anispeed_check.checked = (PQCSettings.getDefaultForImageviewAnimationDuration() > 0)
        anicombo.currentIndex = 0
        anispeed.setValue(PQCSettings.getDefaultForImageviewAnimationDuration())

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {
        anispeed.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        PQCConstants.settingsManagerSettingChanged = (anispeed_check.hasChanged() || anispeed.hasChanged() || anicombo.hasChanged())

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

        PQCConstants.settingsManagerSettingChanged = false

    }

}
