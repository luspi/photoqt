/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../loadfiles.js" as LoadFile

Item {

    id: scale_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0
    enabled: visible

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
        color: "#cc000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
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

                Text {
                    id: heading
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 30
                    font.bold: true
                    text: em.pty+qsTranslate("scale", "Scale file")
                }

                Text {
                    id: error
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    font.pointSize: 15
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("scale", "An error occured, file could not be scaled!")
                }

                Text {
                    id: unsupported
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    font.pointSize: 15
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("scale", "This file format cannot (yet) be scaled with PhotoQt!")
                }

                Item {
                    width: 1
                    height: 1
                }

                Text {
                    x: (insidecont.width-width)/2
                    color: "white"
                    text: em.pty+qsTranslate("scale", "New width x height:") + " " + Math.round(newwidth.value) + " x " + Math.round(newheight.value)
                    font.pointSize: 12
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
                    Text {
                        y: (quality.height-height)/2
                        color: "white"
                        font.pointSize: 12
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

                                if(!handlingManipulation.scaleImage(variables.allImageFilesInOrder[variables.indexOfCurrentImage], false, Qt.size(newwidth.value, newheight.value), quality.value)) {
                                    error.visible = true
                                    return
                                }

                                var cur = variables.allImageFilesInOrder[variables.indexOfCurrentImage]
                                var dir = handlingGeneral.getFilePathFromFullPath(cur)
                                var bas = handlingFileDialog.getBaseName(cur, false)
                                var suf = handlingFileDialog.getSuffix(cur, false)

                                LoadFile.addFilenameToList(dir + "/" + bas + "_" + newwidth.value+"x"+newheight.value+"."+suf, variables.indexOfCurrentImage+1)
                                ++variables.indexOfCurrentImage
                                thumbnails.reloadThumbnails()

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

                                if(!handlingManipulation.scaleImage(variables.allImageFilesInOrder[variables.indexOfCurrentImage], true, Qt.size(newwidth.value, newheight.value), quality.value)) {
                                    error.visible = true
                                    return
                                }

                                var tmp = variables.indexOfCurrentImage
                                variables.indexOfCurrentImage = -1
                                variables.indexOfCurrentImage = tmp

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

                Text {
                    x: (parent.width-width)/2
                    font.pointSize: 8
                    font.bold: true
                    color: "white"
                    textFormat: Text.RichText
                    text: "<table><tr><td align=right>" + keymousestrings.translateShortcut("Enter") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "Scale (create new file)") + "</td</tr>
                          <tr><td align=right>" + keymousestrings.translateShortcut("Shift+Enter") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "Scale (change file in place)") + "</td></tr>
                          <tr><td align=right>" + keymousestrings.translateShortcut("Left") + "/" + keymousestrings.translateShortcut("Right") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "De-/Increase width and height by 10%") + "</td></tr>
                          <tr><td align=right>+/-</td><td>=</td><td>" + em.pty+qsTranslate("scale", "In-/Decrease quality by 5%") + "</td></tr>
                          </table>"
                }

            }

        }

        Connections {
            target: loader
            onScalePassOn: {
                if(what == "show") {
                    if(variables.indexOfCurrentImage == -1)
                        return

                    unsupported.visible = !handlingManipulation.canThisBeScaled(variables.allImageFilesInOrder[variables.indexOfCurrentImage])

                    var s = handlingManipulation.getCurrentImageResolution(variables.allImageFilesInOrder[variables.indexOfCurrentImage])

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



        Shortcut {
            sequence: "Esc"
            enabled: PQSettings.scalePopoutElement
            onActivated: button_cancel.clicked()
        }

        Shortcut {
            sequences: ["Enter", "Return"]
            enabled: PQSettings.scalePopoutElement
            onActivated: button_scalenew.clicked()
        }

        Shortcut {
            sequences: ["Shift+Enter", "Shift+Return"]
            enabled: PQSettings.scalePopoutElement
            onActivated: button_scaleinplace.clicked()
        }

        Shortcut {
            sequences: ["Left", "Down"]
            enabled: PQSettings.scalePopoutElement
            onActivated: {
                newwidth.value -= newwidth.origVal*0.1
                newheight.value -= newheight.origVal*0.1
            }
        }

        Shortcut {
            sequences: ["Right", "Up"]
            enabled: PQSettings.scalePopoutElement
            onActivated: {
                newwidth.value += newwidth.origVal*0.1
                newheight.value += newheight.origVal*0.1
            }
        }

        Shortcut {
            sequences: ["+", "="]
            enabled: PQSettings.scalePopoutElement
            onActivated:
                quality.value += 5
        }

        Shortcut {
            sequence: "-"
            enabled: PQSettings.scalePopoutElement
            onActivated:
                quality.value -= 5
        }

    }

}
