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
import PhotoQt

Item {

    id: control

    clip: true

    width: pretext.width + controlrow.spacing
    height: controlrow.height

    property alias spinboxItem: spinbox
    property int spinboxItemHeight: spinbox.height

    property int minval: 1
    property int maxval: 10

    property alias title: pretext.text
    property alias value: spinbox.liveValue
    property string suffix: ""

    property string overrideMinValText: ""
    property string overrideMaxValText: ""

    property bool showSlider: true
    property bool sliderExtraSmall: true

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

            width: sliderrow.width
            height: spinbox.height

            Row {
                id: sliderrow

                height: spinbox.height
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                visible: opacity > 0

                Connections {
                    target: control
                    function onEditModeChanged() {
                        sliderrow.opacity = control.editMode ? 0.2 : 1
                    }
                }

                PQText {
                    y: (parent.height-height)/2
                    text: (overrideMinValText==="" ? control.minval+control.suffix : overrideMinValText)
                }

                PQSlider {
                    id: slidervalue
                    y: (parent.height-height)/2
                    extraSmall: control.sliderExtraSmall
                    from: control.minval
                    to: control.maxval
                    suffix: control.suffix
                    tooltip: ""
                    onValueChanged: {
                        if(!control.editMode)
                            spinbox.setValue(value)
                    }
                }

                PQText {
                    y: (parent.height-height)/2
                    text: (overrideMaxValText==="" ? control.maxval+control.suffix : overrideMaxValText)
                }

            }

            Row {

                spacing: 10
                opacity: control.editMode ? 1 : 0
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                visible: opacity > 0

                PQSpinBox {
                    id: spinbox
                    from: control.minval
                    to: control.maxval
                    width: sliderrow.width-(control.showSlider ? acceptbut.width : 0)
                    tooltipSuffix: control.suffix
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
                        slidervalue.value = spinbox.liveValue
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
            visible: !control.editMode
            text: "(" + (overrideMinValText!==""&&spinbox.liveValue===control.minval
                            ? overrideMinValText
                            : (overrideMaxValText!==""&&spinbox.liveValue===control.maxval
                                   ? overrideMaxValText
                                   : spinbox.liveValue + control.suffix)) + ")"
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
        slidervalue.value = val
        spinbox.setDefault(val)
    }

    function loadAndSetDefault(val : int) {
        acceptValue()
        slidervalue.value = val
        spinbox.loadAndSetDefault(val)
    }

    function setValue(val : int) {
        slidervalue.value = val
        spinbox.setValue(val)
    }

    function hasChanged() : bool {
        return spinbox.hasChanged()
    }

    function acceptValue() {
        control.editMode = false
    }

    function increase() {
        slidervalue.value += 1
    }
    function decrease() {
        slidervalue.value -= 1
    }

}
