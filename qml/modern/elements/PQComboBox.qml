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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import org.photoqt.qml

ComboBox {

    id: control

    property string prefix: ""
    property bool firstItemEmphasized: false
    property var lineBelowItem: []

    font.pointSize: PQCLook.fontSize // qmllint disable unqualified
    font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified

    property list<int> hideEntries: []

    implicitWidth: extrawide ? 300 : (extrasmall ? 100 : 200)

    property bool extrawide: false
    property bool extrasmall: false

    property int elide: Text.ElideRight

    property bool transparentBackground: false

    delegate: ItemDelegate {
        id: deleg
        width: control.width
        height: control.hideEntries.indexOf(index)===-1 ? 40 : 0
        required property var model
        required property int index
        contentItem: Text {
            id: contitem
            text: control.prefix+(control.firstItemEmphasized&&deleg.index===0 ? deleg.model[control.textRole] : deleg.model[control.textRole])
            color: enabled ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
            font: control.font
            elide: control.elide
            verticalAlignment: Text.AlignVCenter
            style: deleg.highlighted ? Text.Sunken : Text.Normal
            styleColor: PQCLook.textColorDisabled // qmllint disable unqualified
            PQToolTip {
                visible: deleg.highlighted
                text: contitem.text
                timeout: 3000
            }
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: (deleg.highlighted ? PQCLook.baseColorHighlight : (enabled ? PQCLook.baseColor : PQCLook.baseColorHighlight)) // qmllint disable unqualified
            Behavior on color { ColorAnimation { duration: 200 } }

            Rectangle {
                width: parent.width
                height: 1
                y: parent.height-1
                color: PQCLook.inverseColorHighlight // qmllint disable unqualified
                visible: control.lineBelowItem.indexOf(deleg.index)!==-1
            }
        }

        highlighted: control.highlightedIndex === deleg.index
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint(); }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = PQCLook.inverseColor // qmllint disable unqualified
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: control.prefix+control.displayText
        font: control.font
        color: enabled ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
        style: control.highlighted ? Text.Sunken : Text.Normal
        styleColor: PQCLook.textColorDisabled // qmllint disable unqualified
        verticalAlignment: Text.AlignVCenter
        elide: control.elide
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: control.transparentBackground ? "transparent" : ((control.pressed||popup.visible) ? PQCLook.baseColorActive : PQCLook.baseColor) // qmllint disable unqualified
        border.color: control.pressed ? PQCLook.baseColorActive : PQCLook.baseColorHighlight // qmllint disable unqualified
        border.width: control.transparentBackground ? 0 : (control.visualFocus ? 2 : 1)
        radius: 2
    }

    popup: Popup {

        id: popup

        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight+control.lineBelowItem.length*2
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: PQCLook.baseColor // qmllint disable unqualified
            border.color: PQCLook.inverseColorHighlight // qmllint disable unqualified
            border.width: 1
            radius: 2
        }
    }

    property int _defaultValue
    Component.onCompleted: {
        _defaultValue = currentIndex
    }

    function saveDefault() {
        _defaultValue = currentIndex
    }

    function setDefault(val : int) {
        _defaultValue = val
    }

    function loadAndSetDefault(val : int) {
        currentIndex = val
        _defaultValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==currentIndex
    }

}
