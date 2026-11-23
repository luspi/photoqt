/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

Item {

    id: control

    clip: true

    width: pretext.width + sliderrow.width + (editMode||!showSlider ? 0 : txt.width+10)  + controlrow.spacing
    height: controlrow.height

    property alias spinboxItem: spinbox
    property int spinboxItemHeight: spinbox.height

    property int from: 1
    property int to: 10

    property bool logarithmicScale: false

    property alias title: pretext.text
    property int value: spinbox.value
    property string suffix: ""

    property string overrideMinValText: ""
    property string overrideMaxValText: ""

    property bool showSlider: true
    property bool sliderExtraBig: false

    property int titleWeight: PQCLook.fontWeightNormal

    property bool editMode: false || !showSlider

    onVisibleChanged: {
        if(!visible) {
            editMode = false
        }
    }

    Flow {

        id: controlrow

        width: parent.width
        spacing: 10

        PQText {
            id: pretext
            height: spinbox.height
            verticalAlignment: Text.AlignVCenter
            font.weight: control.titleWeight
            text: ""
        }

        Item {

            width: control.showSlider ? sliderrow.width : spinbox.width
            height: spinbox.height

            Row {
                id: sliderrow

                height: spinbox.height
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                visible: control.showSlider && opacity > 0

                Connections {
                    target: control
                    function onEditModeChanged() {
                        sliderrow.opacity = control.editMode ? 0.2 : 1
                    }
                }

                PQText {
                    y: (parent.height-height)/2
                    text: (control.overrideMinValText==="" ? control.from+control.suffix : control.overrideMinValText)
                }

                PQSlider {
                    id: slidervalue
                    y: (parent.height-height)/2
                    extraBig: control.sliderExtraBig
                    from: control.from
                    to: control.to
                    suffix: control.suffix
                    tooltip: spinbox.value
                    logarithmicScale: control.logarithmicScale
                    onValueChanged: {
                        if(control.editMode) return
                        spinbox.setValue(Math.round(value))
                    }
                }

                PQText {
                    y: (parent.height-height)/2
                    text: (control.overrideMaxValText==="" ? control.to+control.suffix : control.overrideMaxValText)
                }

            }

            Row {

                spacing: 10
                opacity: control.editMode||!control.showSlider ? 1 : 0
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                visible: opacity > 0

                PQSpinBox {
                    id: spinbox
                    from: control.from
                    to: control.to
                    width: sliderrow.width-(control.showSlider ? acceptbut.width : 0)
                    //: Tooltip, The value here is a number.
                    tooltip: qsTranslate("settingsmanager", "Enter a value")
                    Keys.onEnterPressed:
                        acceptbut.clicked()
                    Keys.onReturnPressed:
                        acceptbut.clicked()
                }

                PQButton {
                    id: acceptbut
                    text: genericStringSave
                    visible: control.showSlider
                    smallerVersion: true
                    extraSmall: true
                    sizeToText: true
                    height: spinbox.height
                    onClicked: {
                        slidervalue.setValue(spinbox.value)
                        control.editMode = false
                    }
                }

            }

        }

        PQButton {
            id: txt
            smallerVersion: true
            extraSmall: true
            height: spinbox.height
            flat: true
            sizeToText: true
            horizontalAlignment: Text.AlignLeft
            visible: !control.editMode&&control.showSlider
            text: "(" + (control.overrideMinValText!==""&&spinbox.value===control.from
                            ? control.overrideMinValText
                            : (control.overrideMaxValText!==""&&spinbox.value===control.to
                                   ? control.overrideMaxValText
                                   : spinbox.value + control.suffix)) + ")"
            //: Tooltip, used as in: Click to edit this value
            tooltip: qsTranslate("settingsmanager", "Click to edit")
            onClicked: {
                control.editMode = true
            }
        }

    }

    function saveDefault() {
        acceptbut.clicked()
        spinbox.saveDefault()
    }

    function setDefault(val : int) {
        slidervalue.setValue(val)
        spinbox.setDefault(val)
    }

    function loadAndSetDefault(val : int) {
        acceptValue()
        slidervalue.setValue(val)
        spinbox.loadAndSetDefault(val)
    }

    function setValue(val : int) {
        slidervalue.setValue(val)
        spinbox.setValue(val)
    }

    function hasChanged() : bool {
        return spinbox.hasChanged()
    }

    function acceptValue() {
        slidervalue.setValue(spinbox.value)
        control.editMode = false
    }

    function increase() {
        slidervalue.value += 1
    }
    function decrease() {
        slidervalue.value -= 1
    }

}
