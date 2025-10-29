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
import QtQuick.Controls
import PhotoQt

ComboBox {

    id: control

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property string selectedPrefix: ""

    // not used but needed for compatibility
    property string prefix
    property int elide: Text.ElideRight
    property bool transparentBackground: false
    property var lineBelowItem: []

    onDisplayTextChanged: {
        if(displayText !== "") {
            displayText = ""
        }
    }

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    delegate: ItemDelegate {

        id: deleg

        width: control.width
        height: 40

        required property var model
        required property int index

        contentItem: Text {
            id: contitem
            text: control.prefix+deleg.model[control.textRole]
            color: delegate.highlighted ? pqtPalette.highlightedText : (enabled ? pqtPalette.text : pqtPaletteDisabled.text)
            font: control.font
            elide: control.elide
            verticalAlignment: Text.AlignVCenter
            style: deleg.highlighted ? Text.Sunken : Text.Normal
            styleColor: pqtPaletteDisabled.text
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
            color: pqtPalette.alternateBase
            PQHighlightMarker {
                visible: deleg.highlighted
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
            context.fillStyle = pqtPalette.text
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: control.selectedPrefix + control.textAt(control.currentIndex)
        font: control.font
        color: enabled ? pqtPalette.text : pqtPaletteDisabled.text
        style: control.highlighted ? Text.Sunken : Text.Normal
        styleColor: pqtPaletteDisabled.text
        verticalAlignment: Text.AlignVCenter
        elide: control.elide
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: control.transparentBackground ? "transparent" : ((control.pressed||popup.visible) ? PQCLook.baseBorder : pqtPalette.alternateBase)
        border.color: PQCLook.baseBorder
        border.width: control.transparentBackground ? 0 : (control.visualFocus ? 2 : 1)
        radius: 5
    }

    popup: Popup {

        y: control.height - 1
        width: control.width
        implicitHeight: Math.min(contentItem.implicitHeight+2, PQCConstants.availableHeight - topMargin - bottomMargin)
        padding: 0

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: pqtPalette.alternateBase
            border.color: PQCLook.baseBorder
            border.width: 1
            radius: 2
        }
    }

    // TODO !!!
    property list<int> hideEntries: []

    implicitWidth: extrawide ? 300 : (extrasmall ? 100 : 200)

    property bool extrawide: false
    property bool extrasmall: false

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
