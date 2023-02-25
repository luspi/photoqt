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

import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: scale_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Rectangle {

        anchors.fill: parent
        color: "#f41f1f1f"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.interfacePopoutScale
            onClicked:
                button_cancel.clicked()
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 10

                PQTextXL {
                    id: heading
                    x: (insidecont.width-width)/2
                    font.bold: true
                    text: em.pty+qsTranslate("scale", "Scale file")
                }

                PQTextL {
                    id: error
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("scale", "An error occured, file could not be scaled!")
                }

                PQTextL {
                    id: unsupported
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("scale", "This file format cannot (yet) be scaled with PhotoQt!")
                }

                Item {
                    width: 1
                    height: 1
                }

                PQText {
                    x: (insidecont.width-width)/2
                    text: em.pty+qsTranslate("scale", "New width x height:") + " " + Math.round(newwidth.value) + " x " + Math.round(newheight.value)
                }

                PQSlider {
                    x: (insidecont.width-width)/2
                    id: newwidth
                    stepSize: 50
                    property int origVal: 0
                    property real ratio: newheight.origVal/origVal
                    onMoved: {
                        if(preserveaspect.checked)
                            newheight.value = value*ratio
                    }
                }

                PQSlider {
                    x: (insidecont.width-width)/2
                    id: newheight
                    stepSize: 50
                    property int origVal: 0
                    property real ratio: origVal/newwidth.origVal
                    onMoved: {
                        if(preserveaspect.checked)
                            newwidth.value = value/ratio
                    }
                }

                Row {
                    x: (insidecont.width-width)/2
                    spacing: 5
                    PQButton {
                        text: "0.25x"
                        onClicked: {
                            newwidth.value = newwidth.origVal*0.25
                            newheight.value = newheight.origVal*0.25
                        }
                    }
                    PQButton {
                        text: "0.5x"
                        onClicked: {
                            newwidth.value = newwidth.origVal*0.5
                            newheight.value = newheight.origVal*0.5
                        }
                    }
                    PQButton {
                        text: "0.75x"
                        onClicked: {
                            newwidth.value = newwidth.origVal*0.75
                            newheight.value = newheight.origVal*0.75
                        }
                    }
                    PQButton {
                        text: "1x"
                        onClicked: {
                            newwidth.value = newwidth.origVal
                            newheight.value = newheight.origVal
                        }
                    }
                    PQButton {
                        text: "1.5x"
                        onClicked: {
                            newwidth.value = newwidth.origVal*1.5
                            newheight.value = newheight.origVal*1.5
                        }
                    }
                }


                PQCheckbox {
                    id: preserveaspect
                    x: (insidecont.width-width)/2
                    //: The aspect ratio refers to the ratio of the width to the height of the image, e.g., 16:9 for most movies
                    text: em.pty+qsTranslate("scale", "Preserve aspect ratio")
                    checked: true
                }

                Row {
                    x: (insidecont.width-width)/2
                    PQText {
                        y: (quality.height-height)/2
                        //: This refers to the quality to be used to scale the image
                        text: em.pty+qsTranslate("scale", "Quality:")
                    }
                    PQSlider {
                        id: quality
                        from: 0
                        to: 100
                        value: 80
                        toolTipSuffix: "%"
                    }
                }

                Item {
                    width: 1
                    height: 1
                }

                Item {

                    id: butcont

                    x: 0
                    width: insidecont.width
                    height: childrenRect.height

                    Row {

                        spacing: 5

                        x: (parent.width-width)/2

                        PQButton {
                            id: button_scalenew
                            //: Written on a clickable button
                            text: em.pty+qsTranslate("scale", "Scale (create new file)")
                            enabled: (newwidth.value>0 && newheight.value>0 && !unsupported.visible)
                            onClicked: {

                                if(newwidth.value == 0 || newheight.value == 0 || unsupported.visible)
                                    return

                                if(!handlingManipulation.scaleImage(filefoldermodel.currentFilePath, false, Qt.size(newwidth.value, newheight.value), quality.value)) {
                                    error.visible = true
                                    return
                                }

                                var cur = filefoldermodel.currentFilePath
                                var dir = handlingFileDir.getFilePathFromFullPath(cur)
                                var bas = handlingFileDir.getBaseName(cur, false)
                                var suf = handlingFileDir.getSuffix(cur, false)

                                filefoldermodel.setAsCurrent(dir + "/" + bas + "_" + Math.round(newwidth.value)+"x"+Math.round(newheight.value)+"."+suf)

                                scale_top.opacity = 0
                                variables.visibleItem = ""

                            }
                        }

                        PQButton {
                            id: button_scaleinplace
                            //: Written on a clickable button
                            text: em.pty+qsTranslate("scale", "Scale (change file in place)")
                            enabled: (newwidth.value>0 && newheight.value>0 && !unsupported.visible)
                            onClicked: {

                                if(newwidth.value == 0 || newheight.value == 0 || unsupported.visible)
                                    return

                                if(!handlingManipulation.scaleImage(filefoldermodel.currentFilePath, true, Qt.size(newwidth.value, newheight.value), quality.value)) {
                                    error.visible = true
                                    return
                                }

                                scale_top.opacity = 0
                                variables.visibleItem = ""

                            }
                        }

                        PQButton {
                            id: button_cancel
                            text: genericStringCancel
                            onClicked: {
                                scale_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }

                    }

                }

                Item {
                    width: 1
                    height: 1
                }

                PQTextS {
                    x: (parent.width-width)/2
                    font.bold: true
                    textFormat: Text.RichText
                    text: "<table><tr><td align=right>" + keymousestrings.translateShortcut("Enter") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "Scale (create new file)") + "</td</tr>
                          <tr><td align=right>" + keymousestrings.translateShortcut("Shift+Enter") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "Scale (change file in place)") + "</td></tr>
                          <tr><td align=right>" + keymousestrings.translateShortcut("Left") + "/" + keymousestrings.translateShortcut("Right") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "De-/Increase width and height by 10%") + "</td></tr>
                          <tr><td align=right>+/-</td><td>=</td><td>" + em.pty+qsTranslate("scale", "In-/Decrease quality by 5%") + "</td></tr>
                          </table>"
                }

            }

        }

        Image {
            x: 5
            y: 5
            width: 15
            height: 15
            source: "/popin.svg"
            sourceSize: Qt.size(width, height)
            opacity: popinmouse.containsMouse ? 1 : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                id: popinmouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: PQSettings.interfacePopoutScale ?
                             //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                             em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                             //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                             em.pty+qsTranslate("popinpopout", "Move to its own window")
                onClicked: {
                    if(PQSettings.interfacePopoutScale)
                        scale_window.storeGeometry()
                    button_cancel.clicked()
                    PQSettings.interfacePopoutScale = !PQSettings.interfacePopoutScale
                    HandleShortcuts.executeInternalFunction("__scale")
                }
            }
        }

        Connections {
            target: loader
            onScalePassOn: {
                if(what == "show") {
                    if(filefoldermodel.current == -1)
                        return

                    unsupported.visible = !handlingManipulation.canThisBeScaled(filefoldermodel.currentFilePath)

                    var s = handlingManipulation.getCurrentImageResolution(filefoldermodel.currentFilePath)

                    newwidth.to = s.width*1.5
                    newheight.to = s.height*1.5
                    newwidth.value = s.width
                    newheight.value = s.height
                    newwidth.origVal = s.width
                    newheight.origVal = s.height

                    quality.value = 80

                    opacity = 1
                    error.visible = false
                    variables.visibleItem = "scale"
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return) {
                        if(param[1] & Qt.ShiftModifier)
                            button_scaleinplace.clicked()
                        else
                            button_scalenew.clicked()
                    } else if(param[0] == Qt.Key_Left) {
                        newwidth.value -= newwidth.origVal*0.1
                        newheight.value -= newheight.origVal*0.1
                    } else if(param[0] == Qt.Key_Right) {
                        newwidth.value += newwidth.origVal*0.1
                        newheight.value += newheight.origVal*0.1
                    } else if(param[0] == Qt.Key_Plus || param[0] == Qt.Key_Equal)
                        quality.value += 5
                    else if(param[0] == Qt.Key_Minus)
                        quality.value -= 5
                }
            }
        }

    }

}
