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

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.interfacePopoutAdvancedSort
            onClicked:
                button_cancel.clicked()
        }

        Item {

            id: insidecont

            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 20

                Text {
                    id: heading
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 20
                    font.bold: true
                    text: em.pty+qsTranslate("advancedsort", "Advanced Sorting")
                }

                Text {
                    id: description1
                    x: (insidecont.width-width)/2
                    width: Math.min(800, insidecont.width-20)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("advancedsort", "It is possible to sort the images in the current folder by color properties. Depending on the number of images and the settings, this might take a few seconds.")

                }

                Row {
                    id: sortbyrow
                    x: (insidecont.width-width)/2
                    spacing: 10
                    Text {
                        id: sortbytxt
                        color: "white"
                        //: Used as 'sort by dominant/average color'
                        text: em.pty+qsTranslate("advancedsort", "Sort by:")
                    }
                    PQRadioButton {
                        id: sortbyDom
                        //: The color that is most common in the image
                        text: em.pty+qsTranslate("advancedsort", "Dominant color")
                    }
                    PQRadioButton {
                        id: sortbyAvg
                        //: the average color of the image
                        text: em.pty+qsTranslate("advancedsort", "Average color")
                    }

                }

                Row {
                    x: sortbyrow.x
                    spacing: 10
                    Item {
                        width: sortbytxt.width
                        height: 1
                    }
                    PQRadioButton {
                        id: asc
                        //: sort order, i.e., 'ascending order'
                        text: em.pty+qsTranslate("advancedsort", "ascending")
                    }
                    PQRadioButton {
                        id: desc
                        //: sort order, i.e., 'descending order'
                        text: em.pty+qsTranslate("advancedsort", "descending")
                    }
                }

                Row {
                    x: (insidecont.width-width)/2
                    spacing: 10
                    Text {
                        id: qualtxt
                        y: (qual.height-height)/2
                        color: "white"
                        //: Please keep short! Sorting images by color comes with a speed vs quality tradeoff.
                        text: em.pty+qsTranslate("advancedsort", "speed vs quality:")
                    }
                    PQComboBox {
                        id: qual
                                //: quality and speed of sorting image by color
                        model: [em.pty+qsTranslate("advancedsort", "low quality (fast)"),
                                //: quality and speed of sorting image by color
                                em.pty+qsTranslate("advancedsort", "medium quality"),
                                //: quality and speed of sorting image by color
                                em.pty+qsTranslate("advancedsort", "high quality (slow)")]
                    }

                }

                Text {
                    x: 10
                    width: insidecont.width-20
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("advancedsort", "There is also a quickstart shortcut that immediately starts the sorting using the latest settings.")
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
                            id: button_ok
                            //: Written on a clickable button - please keep short
                            text: em.pty+qsTranslate("advancedsort", "Sort images")
                            onClicked: {
                                saveSettings()
                                advancedsort_top.opacity = 0
                                variables.visibleItem = ""
                                filefoldermodel.advancedSortMainView()
                            }
                        }
                        PQButton {
                            id: button_cancel
                            text: genericStringCancel
                            onClicked: {
                                advancedsort_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }

                    }

                }

            }

        }

        Connections {
            target: loader
            onAdvancedSortPassOn: {
                if(what == "show") {
                    if(filefoldermodel.current == -1)
                        return

                    loadSettings()

                    opacity = 1
                    variables.visibleItem = "advancedsort"

                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_ok.clicked()
                }
            }
        }

    }

    function loadSettings() {

        sortbyDom.checked = (PQSettings.imageviewAdvancedSortCriteria=="dominant")
        sortbyAvg.checked = (PQSettings.imageviewAdvancedSortCriteria=="average" || !sortbyDom.checked)

        asc.checked = (PQSettings.imageviewAdvancedSortAscending)
        desc.checked = (!PQSettings.imageviewAdvancedSortAscending)

        qual.currentIndex = (PQSettings.imageviewAdvancedSortQuality=="low" ? 0 : (PQSettings.imageviewAdvancedSortQuality=="high" ? 2 : 1))

    }

    function saveSettings() {

        PQSettings.imageviewAdvancedSortCriteria = (sortbyDom.checked ? "dominant" : "average")
        PQSettings.imageviewAdvancedSortAscending = asc.checked
        var opt = ["low", "medium", "high"]
        PQSettings.imageviewAdvancedSortQuality = opt[qual.currentIndex]

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        source: "/popin.png"
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutAdvancedSort ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutAdvancedSort)
                    advancedsort_window.storeGeometry()
                button_cancel.clicked()
                PQSettings.interfacePopoutAdvancedSort = !PQSettings.interfacePopoutAdvancedSort
                HandleShortcuts.executeInternalFunction("__advancedSort")
            }
        }
    }

}
