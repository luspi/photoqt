/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
import QtQuick.Controls

ComboBox {

    id: control

    property string prefix: ""
    property bool firstItemEmphasized: false
    property var lineBelowItem: []

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    implicitWidth: 200

    delegate: ItemDelegate {
        width: control.width
        height: 40
        contentItem: Text {
            text: prefix+(firstItemEmphasized&&index==0 ? modelData.toUpperCase() : modelData)
            color: highlighted ? PQCLook.textHighlightColor : PQCLook.textColor
            Behavior on color { ColorAnimation { duration: 200 } }
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: highlighted ? PQCLook.highlightColor : PQCLook.baseColor75
            Behavior on color { ColorAnimation { duration: 200 } }

            Rectangle {
                width: parent.width
                height: 2
                y: parent.height-2
                color: PQCLook.baseColor
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
            context.fillStyle = PQCLook.baseColor;
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: prefix+control.displayText
        font: control.font
        color: PQCLook.textColor
        Behavior on color { ColorAnimation { duration: 200 } }
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: PQCLook.baseColor75
        border.color: control.pressed ? PQCLook.highlightColor : PQCLook.baseColor
        border.width: control.visualFocus ? 2 : 1
        radius: 2
    }

    popup: Popup {
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
            radius: 2
        }
    }

}
