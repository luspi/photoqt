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

import QtQuick 2.9
import QtQuick.Controls 2.2
import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: scale_top

    popout: PQSettings.interfacePopoutScale
    shortcut: "__scale"
    title: em.pty+qsTranslate("scale", "Scale image")

    button1.text: em.pty+qsTranslate("scale", "Scale (create new file)")
    button1.enabled: (newwidth.value>0 && newheight.value>0 && !unsupported.visible)

    button2.visible: true
    button2.font.pointSize: baselook.fontsize_l
    button2.text: em.pty+qsTranslate("scale", "Scale (change file in place)")
    button2.font.weight: baselook.boldweight
    button2.enabled: (newwidth.value>0 && newheight.value>0 && !unsupported.visible)

    button3.visible: true
    button3.font.pointSize: baselook.fontsize
    button3.text: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutScale = popout

    button1.onClicked:
        scaleIntoNew()

    button2.onClicked:
        scaleIntoExisting()

    button3.onClicked:
        closeElement()

    content: [

        PQTextL {
            id: error
            x: (parent.width-width)/2
            color: "red"
            visible: false
            horizontalAlignment: Qt.AlignHCenter
            text: em.pty+qsTranslate("scale", "An error occured, file could not be scaled!")
        },

        PQTextL {
            id: unsupported
            x: (parent.width-width)/2
            color: "red"
            visible: false
            horizontalAlignment: Qt.AlignHCenter
            text: em.pty+qsTranslate("scale", "This file format cannot (yet) be scaled with PhotoQt!")
        },

        Item {
            width: 1
            height: 1
        },

        PQTextL {
            x: (parent.width-width)/2
            text: em.pty+qsTranslate("scale", "New width x height:")
        },

        Row {

            x: (parent.width-width)/2
            spacing: 10

            PQSlider {
                id: newwidth
                stepSize: 50
                property int origVal: 0
                property real ratio: newheight.origVal/origVal
                onMoved: {
                    if(preserveaspect.checked)
                        newheight.value = value*ratio
                }
            }

            PQText {
                font.weight: baselook.boldweight
                text: Math.round(newwidth.value)+"px"
            }

        },

        Row {

            x: (parent.width-width)/2
            spacing: 10

            PQSlider {
                id: newheight
                stepSize: 50
                property int origVal: 0
                property real ratio: origVal/newwidth.origVal
                onMoved: {
                    if(preserveaspect.checked)
                        newwidth.value = value/ratio
                }
            }

            PQText {
                font.weight: baselook.boldweight
                text: Math.round(newheight.value)+"px"
            }
        },

        Item {
            width: 1
            height: 1
        },

        Row {
            x: (parent.width-width)/2
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
        },

        Item {
            width: 1
            height: 1
        },

        PQCheckbox {
            id: preserveaspect
            x: (parent.width-width)/2
            //: The aspect ratio refers to the ratio of the width to the height of the image, e.g., 16:9 for most movies
            text: em.pty+qsTranslate("scale", "Preserve aspect ratio")
            checked: true
        },

        Item {
            width: 1
            height: 1
        },

        Row {
            x: (parent.width-width)/2
            spacing: 5
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
        },

        Item {
            width: 1
            height: 1
        },

        Item {
            width: 1
            height: 1
        },

        PQTextS {
            x: (parent.width-width)/2
            font.weight: baselook.boldweight
            textFormat: Text.RichText
            text: "<table><tr><td align=right>" + keymousestrings.translateShortcut("Enter") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "Scale (create new file)") + "</td></tr>
                  <tr><td align=right>" + keymousestrings.translateShortcut("Shift+Enter") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "Scale (change file in place)") + "</td></tr>
                  <tr><td align=right>" + keymousestrings.translateShortcut("Left") + "/" + keymousestrings.translateShortcut("Right") + "</td><td>=</td><td>" + em.pty+qsTranslate("scale", "De-/Increase width and height by 10%") + "</td></tr>
                  <tr><td align=right>+/-</td><td>=</td><td>" + em.pty+qsTranslate("scale", "In-/Decrease quality by 5%") + "</td></tr>
                  </table>"

        }

    ]

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
                button3.clicked()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    button3.clicked()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return) {
                    if(param[1] & Qt.ShiftModifier)
                        button2.clicked()
                    else
                        button1.clicked()
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

    function scaleIntoNew() {

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

        closeElement()

    }

    function scaleIntoExisting() {

        if(newwidth.value == 0 || newheight.value == 0 || unsupported.visible)
            return

        if(!handlingManipulation.scaleImage(filefoldermodel.currentFilePath, true, Qt.size(newwidth.value, newheight.value), quality.value)) {
            error.visible = true
            return
        }

        closeElement()

    }

    function closeElement() {
        scale_top.opacity = 0
        variables.visibleItem = ""
    }

}
