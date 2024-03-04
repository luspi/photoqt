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
import QtQuick.Controls.Basic

ComboBox {

    id: control

    property string prefix: ""
    property bool firstItemEmphasized: false
    property var lineBelowItem: []

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    implicitWidth: extrawide ? 300 : 200

    property bool extrawide: false

    property int elide: Text.ElideRight

    property bool transparentBackground: false

    delegate: ItemDelegate {
        width: control.width
        height: 40
        contentItem: Text {
            text: prefix+(firstItemEmphasized&&index===0 ? modelData.toUpperCase() : modelData)
            color: enabled ? PQCLook.textColor : PQCLook.textColorHighlight
            font: control.font
            elide: control.elide
            verticalAlignment: Text.AlignVCenter
            style: highlighted ? Text.Sunken : Text.Normal
            styleColor: PQCLook.textColorHighlight
            PQToolTip {
                visible: highlighted
                text: parent.text
                timeout: 3000
            }
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: (highlighted ? PQCLook.baseColorHighlight : (enabled ? PQCLook.baseColor : PQCLook.baseColorHighlight))
            Behavior on color { ColorAnimation { duration: 200 } }

            Rectangle {
                width: parent.width
                height: 1
                y: parent.height-1
                color: PQCLook.inverseColorHighlight
                visible: lineBelowItem.indexOf(index)!==-1
            }
        }

        highlighted: control.highlightedIndex === index
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
            context.fillStyle = (control.pressed||popup.visible) ? PQCLook.baseColor : PQCLook.baseColorActive;
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: prefix+control.displayText
        font: control.font
        color: enabled ? PQCLook.textColor : PQCLook.textColorHighlight
        style: highlighted ? Text.Sunken : Text.Normal
        styleColor: PQCLook.textColorHighlight
        Behavior on color { ColorAnimation { duration: 200 } }
        verticalAlignment: Text.AlignVCenter
        elide: control.elide
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: transparentBackground ? "transparent" : ((control.pressed||popup.visible) ? PQCLook.baseColorActive : PQCLook.baseColor)
        border.color: control.pressed ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
        border.width: transparentBackground ? 0 : (control.visualFocus ? 2 : 1)
        radius: 2
    }

    popup: Popup {

        id: popup

        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight+lineBelowItem.length*2
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: PQCLook.baseColor
            border.color: PQCLook.inverseColorHighlight
            border.width: 1
            radius: 2
        }
    }

}
