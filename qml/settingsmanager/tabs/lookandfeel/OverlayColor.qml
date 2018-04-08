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

import "../../../elements"
import "../../"

Entry {

    //: This refers to the background color of PhotoQt, behind the main image (the part not covered by the image itself)
    title: em.pty+qsTr("Overlay Color")
    helptext: em.pty+qsTr("Here you can adjust the background colour of PhotoQt (of the part not covered by an image). When using compositing or a background image, then you can also specify an alpha value, i.e. the transparency of the coloured overlay layer. When neither compositing is enabled nor a background image is set, then this colour will be the non-transparent background of PhotoQt.")

    content: [

        Column {

            id: slider_column
            spacing: 5

            Rectangle {
                color: "#00000000"
                height: childrenRect.height
                width: childrenRect.width
                Row {
                    spacing: 5
                    Text {
                        id: redtxt
                        width: 50
                        horizontalAlignment: Qt.AlignRight
                        color: colour.text
                        font.pointSize: 10
                        text: em.pty+qsTr("Red:")
                    }

                    CustomSlider {
                        id: red
                        height: redtxt.height
                        minimumValue: 0
                        maximumValue: 1
                        stepSize: 0.01
                        scrollStep: 0.01
                    }
                }
            }
            Rectangle {
                color: "#00000000"
                height: childrenRect.height
                width: childrenRect.width
                Row {
                    spacing: 5
                    Text {
                        id: greentxt
                        width: 50
                        horizontalAlignment: Qt.AlignRight
                        color: colour.text
                        font.pointSize: 10
                        text: em.pty+qsTr("Green:")
                    }

                    CustomSlider {
                        id: green
                        minimumValue: 0
                        height: greentxt.height
                        maximumValue: 1
                        stepSize: 0.01
                        scrollStep: 0.01
                    }
                }
            }
            Rectangle {
                color: "#00000000"
                height: childrenRect.height
                width: childrenRect.width
                Row {
                    spacing: 5
                    Text {
                        id: bluetxt
                        width: 50
                        horizontalAlignment: Qt.AlignRight
                        color: colour.text
                        font.pointSize: 10
                        text: em.pty+qsTr("Blue:")
                    }

                    CustomSlider {
                        id: blue
                        height: bluetxt.height
                        minimumValue: 0
                        maximumValue: 1
                        stepSize: 0.01
                        scrollStep: 0.01
                    }
                }
            }
            Rectangle {
                color: "#00000000"
                height: childrenRect.height
                width: childrenRect.width
                Row {
                    spacing: 5
                    Text {
                        id: alphatxt
                        width: 50
                        horizontalAlignment: Qt.AlignRight
                        color: colour.text
                        font.pointSize: 10
                        //: This refers to the alpha value of a color (i.e., how opaque/transparent the colour is)
                        text: em.pty+qsTr("Alpha:")
                    }

                    CustomSlider {
                        id: alpha
                        height: alphatxt.height
                        minimumValue: 0
                        maximumValue: 1
                        stepSize: 0.01
                        scrollStep: 0.01
                    }
                }
            }

        },

                /* Image, Rectangle, and Label to preview background colour */

        Image {

            id: background_colour

            width: 150
            height: slider_column.height

            source: "qrc:/img/transparent.png"
            fillMode: Image.Tile

            Rectangle {

                id: background_colour_label_back

                anchors.fill: parent

                color: Qt.rgba(red.value,green.value,blue.value,alpha.value)

                border.width: 1
                border.color: "#99969696"

                Rectangle {

                    color: "#88000000"

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2

                    width: col_txt.width+10
                    height: col_txt.height+10

                    radius: variables.global_item_radius

                    Text {

                        id: col_txt

                        x: 5
                        y: 5

                        font.pointSize: 10

                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter

                        color: "white"
                        text: em.pty+qsTr("Preview")

                    }

                }

            }

        }

    ]

    function setData() {
        red.value = settings.backgroundColorRed/255
        green.value = settings.backgroundColorGreen/255
        blue.value = settings.backgroundColorBlue/255
        alpha.value = settings.backgroundColorAlpha/255
    }

    function saveData() {
        settings.backgroundColorRed = red.value*255
        settings.backgroundColorGreen = green.value*255
        settings.backgroundColorBlue = blue.value*255
        settings.backgroundColorAlpha = alpha.value*255
    }

}
