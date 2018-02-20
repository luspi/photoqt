/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import PContextMenu 1.0

Button {

    id: but

    property int fontsize: 10
    property bool transparentBackground: false
    property string backgroundColor: ""
    property bool displayAsError: false
    property bool showBorder: true
    property string tooltip: text
    property int radius: 0
    property real disabledOpacity: 0.5

    property var model: []
    property int currentIndex: -1

    opacity: enabled ? 1 : disabledOpacity
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    onWidthChanged: context.setFixedWidth(but.width)
    onFontsizeChanged: context.setFontSize(but.fontsize)

    style: ButtonStyle {
        background: Rectangle {
            clip: true
            radius: control.radius
            color: transparentBackground ? "transparent" : (backgroundColor=="" ? colour.element_bg_color : backgroundColor)
            border.width: showBorder ? 1 : 0
            border.color: transparentBackground ? colour.element_border_color_disabled : colour.element_border_color
            implicitWidth: 100
        }
        label: Text {
            id: txt
            font.pointSize: fontsize
            text: currentIndex==-1 ? "" : model[currentIndex]
            font.bold: displayAsError
            elide: Text.ElideRight
            color: displayAsError ? colour.text_warning : colour.text
        }

    }

    PContextMenu {

        id: context

        Component.onCompleted: {

            for(var i = 0; i < model.length; ++i)
                addItem(model[i])

            setFixedWidth(but.width)
            setFontSize(but.fontsize)

        }

        onSelectedIndexChanged: {
            but.currentIndex = index
        }

    }

    ToolTip {
        id: ttip
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        text: ""
        onClicked: {
            var pos = but.parent.mapToItem(mainwindow, but.x, but.y)
            context.popup(Qt.point(pos.x+variables.windowXY.x, pos.y+but.height+variables.windowXY.y))
        }
        Component.onCompleted: setupText()
        Connections {
            target: but
            onModelChanged: ttip.setupText()
            onCurrentIndexChanged: ttip.setupText()
        }
        function setupText() {
            var txt = ""
            for(var i = 0; i < but.model.length; ++i) {
                if(i == currentIndex)
                    txt += "<b>"
                txt += (i+1) + ") " + but.model[i]
                if(i == currentIndex)
                    txt += "</b>"
                if(i != but.model.length-1)
                    txt += "<br>"
            }
            ttip.text = txt
        }
    }

}
