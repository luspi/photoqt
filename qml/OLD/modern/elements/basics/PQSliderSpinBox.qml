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
import PhotoQt.CPlusPlus
import PhotoQt.Modern

Item {

    id: control

    clip: true

    property bool animateWidth: false
    property bool animateHeight: false

    width: (enabled||!animateWidth) ? (pretext.width + spinbox.width + controlrow.spacing + (showSlider ? (sliderrow.width + controlrow.spacing) : 0) +
                                       (acceptbut.visible ? (acceptbut.width+controlrow.spacing) : 0)) : 0
    height: (enabled||!animateHeight) ? controlrow.height : 0
    opacity: (enabled||(!animateWidth&&!animateHeight)) ? 1 : 0

    Behavior on width { NumberAnimation { duration: control.animateWidth ? 200 : 0 } }
    Behavior on height { NumberAnimation { duration: control.animateHeight ? 200 : 0 } }
    Behavior on opacity { NumberAnimation { duration: control.animateWidth||control.animateHeight ? 150 : 0 } }

    visible: width>0&&height>0

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

    property bool editMode: false

    property bool contextMenuOpen: txt.contextmenu.visible || acceptbut.contextmenu.visible

    onVisibleChanged: {
        if(!visible) {
            txt.visible = true
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

        Row {
            id: sliderrow
            height: spinbox.height
            visible: control.showSlider
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
                    if(value !== spinbox.liveValue)
                        spinbox.liveValue = value
                }
            }

            PQText {
                y: (parent.height-height)/2
                text: (overrideMaxValText==="" ? control.maxval+control.suffix : overrideMaxValText)
            }

        }

        Item {

            width: spinbox.width
            height: spinbox.height

            PQSpinBox {
                id: spinbox
                from: control.minval
                to: control.maxval
                width: 120
                tooltipSuffix: control.suffix
                visible: control.editMode
                Keys.onEnterPressed:
                    acceptbut.clicked()
                Keys.onReturnPressed:
                    acceptbut.clicked()
                onLiveValueChanged: {
                    if(control.showSlider && liveValue !== slidervalue.value)
                        slidervalue.value = liveValue
                }
            }

            PQButton {
                id: txt
                anchors.fill: parent
                smallerVersion: true
                text: (overrideMinValText!==""&&spinbox.liveValue==control.minval ?
                           overrideMinValText :
                           (overrideMaxValText!==""&&spinbox.liveValue==control.maxval ?
                                overrideMaxValText :
                                spinbox.liveValue + control.suffix))
                //: Tooltip, used as in: Click to edit this value
                tooltip: qsTranslate("settingsmanager", "Click to edit")
                onClicked: {
                    txt.visible = false
                    control.editMode = true
                }
            }

        }

        PQButton {
            id: acceptbut
            text: genericStringSave
            smallerVersion: true
            height: spinbox.height
            visible: control.editMode
            onClicked: {
                txt.visible = true
                control.editMode = false
            }
        }

    }

    function closeContextMenus() {
        txt.contextmenu.close()
        acceptbut.contextmenu.close()
    }

    function saveDefault() {
        acceptbut.clicked()
        spinbox.saveDefault()
    }

    function setDefault(val : int) {
        spinbox.setDefault(val)
    }

    function loadAndSetDefault(val : int) {
        acceptValue()
        spinbox.loadAndSetDefault(val)
    }

    function setValue(val : int) {
        spinbox.setValue(val)
    }

    function hasChanged() : bool {
        return spinbox.hasChanged()
    }

    function acceptValue() {
        txt.visible = true
        control.editMode = false
    }

    function increase() {
        slidervalue.value += 1
    }
    function decrease() {
        slidervalue.value -= 1
    }

}
