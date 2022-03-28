/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: advancedsort_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.interfacePopoutAdvancedSort ? dummyitem : imageitem
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

        Column {

            id: insidecont

            spacing: 20

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            Text {
                x: (busycont.width-width)/2
                color: "white"
                font.bold: true
                font.pointSize: 15
                text: "Busy with sorting images..."
            }

            Item {

                id: busycont

                width: 150
                height: 150

                Repeater {

                    model: 3

                    delegate: Canvas {
                        id: load
                        x: (parent.width-width)/2
                        y: (parent.height-height)/2
                        width: busycont.width - index*25
                        height: busycont.height - index*25
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.strokeStyle = "#ffffff";
                            ctx.lineWidth = 3
                            ctx.beginPath();
                            ctx.arc(width/2, height/2, width/2-3, 0, 3.14, false);
                            ctx.stroke();
                        }
                        RotationAnimator {
                            target: load
                            from: index%2 ? 360 : 0
                            to: index%2 ? 0 : 360
                            duration: 1000 - index*100
                            running: advancedsort_top.visible
                            onStopped: {
                                if(advancedsort_top.visible)
                                    start()
                            }
                        }
                    }

                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    font.bold: true
                    text: filefoldermodel.advancedSortDone + "/" + filefoldermodel.countMainView
                }

            }

            PQButton {
                id: butcancel
                x: (busycont.width-width)/2
                text: genericStringCancel
                onClicked: {
                    filefoldermodel.advancedSortMainViewCANCEL()
                    advancedsort_top.opacity = 0
                    variables.visibleItem = ""
                }
            }

        }

        Connections {
            target: loader
            onAdvancedSortBusyPassOn: {
                if(what == "show") {
                    opacity = 1
                    variables.visibleItem = "advancedsortbusy"
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        butcancel.clicked()
                }
            }
        }

        Connections {
            target: filefoldermodel
            onAdvancedSortingComplete: {
                butcancel.clicked()
            }
        }

    }

}
