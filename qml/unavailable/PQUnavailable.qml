/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9
import QtGraphicalEffects 1.0
import "../elements"

Item {

    id: unavailable_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    PQMouseArea {
        anchors.fill: parent
        onClicked:
            buttonClose.clicked()
    }

    PQMouseArea {
        anchors.fill: contcol
        anchors.margins: -50
    }

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.scalePopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {
        anchors.fill: parent
        color: "#ee000000"
    }

    Column {

        id: contcol

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: Math.min(600, parent.width-50)
        height: childrenRect.height

        spacing: 10

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            font.bold: true
            font.pointSize: 25
            text: em.pty+qsTranslate("unavailable", "Sorry, but this feature is not yet available on Windows.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item { width: 1; height: 50 }

        PQButton {
            id: buttonClose
            x: (parent.width-width)/2
            text: genericStringClose
            scale: 1.5
            renderType: Text.QtRendering
            onClicked: {
                if(variables.visibleItem == "unavailable") {
                    unavailable_top.opacity = 0
                    variables.visibleItem = ""
                }
            }
        }

    }

    Connections {

        target: loader

        onUnavailablePassOn: {

            if(what == "show") {
                unavailable_top.opacity = 1
                variables.visibleItem = "unavailable"

            } else if(what == "hide") {

                buttonClose.clicked()

            } else if(what == "keyevent") {

                if(param[0] == Qt.Key_Escape)
                    buttonClose.clicked()

            }

        }

    }

}
