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
import PQCNotify

Item {

    id: control

    clip: true

    property bool animateWidth: false
    property bool animateHeight: false

    width: (enabled||!animateWidth) ? (pretext.width + spinbox.width + controlrow.spacing + (showSlider ? (sliderrow.width + controlrow.spacing) : 0) +
                                       (acceptbut.visible ? (acceptbut.width+controlrow.spacing) : 0)) : 0
    height: (enabled||!animateHeight) ? controlrow.height : 0
    opacity: (enabled||(!animateWidth&&!animateHeight)) ? 1 : 0

    Behavior on width { NumberAnimation { duration: animateWidth ? 200 : 0 } }
    Behavior on height { NumberAnimation { duration: animateHeight ? 200 : 0 } }
    Behavior on opacity { NumberAnimation { duration: animateWidth||animateHeight ? 150 : 0 } }

    visible: width>0&&height>0

    property alias spinboxItem: spinbox

    property int minval: 1
    property int maxval: 10

    property alias title: pretext.text
    property alias value: spinbox.liveValue
    property string suffix: ""

    property bool showSlider: true
    property bool sliderExtraSmall: true

    property int titleWeight: PQCLook.fontWeightNormal

    property bool editMode: !txt.visible

    onVisibleChanged: {
        if(!visible) {
            PQCNotify.spinBoxPassKeyEvents = false
            txt.visible = true
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

        Row {
            id: sliderrow
            height: spinbox.height
            visible: showSlider
            PQText {
                y: (parent.height-height)/2
                text: control.minval+suffix
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
                    if(value !== spinbox.liveValue)
                        spinbox.liveValue = value
                }
            }

            PQText {
                y: (parent.height-height)/2
                text: control.maxval+suffix
            }

        }

        Item {

            width: spinbox.width
            height: spinbox.height

            PQSpinBox {
                id: spinbox
                from: minval
                to: maxval
                width: 120
                tooltipSuffix: control.suffix
                visible: !txt.visible
                Component.onDestruction:
                    PQCNotify.spinBoxPassKeyEvents = false
                Keys.onEnterPressed:
                    acceptbut.clicked()
                Keys.onReturnPressed:
                    acceptbut.clicked()
                onLiveValueChanged: {
                    if(showSlider && liveValue !== slidervalue.value)
                        slidervalue.value = liveValue
                }
            }

            PQButton {
                id: txt
                anchors.fill: parent
                smallerVersion: true
                text: spinbox.liveValue + suffix
                //: Tooltip, used as in: Click to edit this value
                tooltip: qsTranslate("settingsmanager", "Click to edit")
                onClicked: {
                    PQCNotify.spinBoxPassKeyEvents = true
                    txt.visible = false
                }
            }

        }

        PQButton {
            id: acceptbut
            text: genericStringSave
            smallerVersion: true
            height: spinbox.height
            visible: !txt.visible
            onClicked: {
                PQCNotify.spinBoxPassKeyEvents = false
                txt.visible = true
            }
        }

    }

    function saveDefault() {
        acceptbut.clicked()
        spinbox.saveDefault()
    }

    function setDefault(val) {
        spinbox.setDefault(val)
    }

    function loadAndSetDefault(val) {
        acceptValue()
        spinbox.loadAndSetDefault(val)
    }

    function hasChanged() {
        return spinbox.hasChanged()
    }

    function acceptValue() {
        PQCNotify.spinBoxPassKeyEvents = false
        txt.visible = true
    }

}
