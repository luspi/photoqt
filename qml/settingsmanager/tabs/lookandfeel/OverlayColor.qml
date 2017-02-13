import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Overlay Color")
            helptext: qsTr("Here you can adjust the background colour of PhotoQt (of the part not covered by an image). When using compositing or a background image, then you can also specify an alpha value, i.e. the transparency of the coloured overlay layer. When neither compositing is enabled nor a background image is set, then this colour will be the non-transparent background of PhotoQt.")

        }

        EntrySetting {

            Row {

                spacing: 5

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
                                width: 50
                                horizontalAlignment: Qt.AlignRight
                                color: colour.text
                                font.pointSize: 10
                                text: qsTr("Red:")
                            }

                            CustomSlider {
                                id: red
                                minimumValue: 0
                                maximumValue: 1
                                stepSize: 0.01
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
                                width: 50
                                horizontalAlignment: Qt.AlignRight
                                color: colour.text
                                font.pointSize: 10
                                text: qsTr("Green:")
                            }

                            CustomSlider {
                                id: green
                                minimumValue: 0
                                maximumValue: 1
                                stepSize: 0.01
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
                                width: 50
                                horizontalAlignment: Qt.AlignRight
                                color: colour.text
                                font.pointSize: 10
                                text: qsTr("Blue:")
                            }

                            CustomSlider {
                                id: blue
                                minimumValue: 0
                                maximumValue: 1
                                stepSize: 0.01
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
                                width: 50
                                horizontalAlignment: Qt.AlignRight
                                color: colour.text
                                font.pointSize: 10
                                //: This refers to the alpha value of a color (i.e., how opaque/transparent the colour is)
                                text: qsTr("Alpha:")
                            }

                            CustomSlider {
                                id: alpha
                                minimumValue: 0
                                maximumValue: 1
                                stepSize: 0.01
                            }
                        }
                    }

                }

                // Spacing in between
                Rectangle { color: "transparent"; width: 10; height: 1; }

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

                            radius: global_item_radius

                            Text {

                                id: col_txt

                                x: 5
                                y: 5

                                font.pointSize: 10

                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter

                                color: "white"
                                text: qsTr("Preview")

                            }

                        }

                    }

                }

            }

        }

    }

    function setData() {
        red.value = settings.bgColorRed/255
        green.value = settings.bgColorGreen/255
        blue.value = settings.bgColorBlue/255
        alpha.value = settings.bgColorAlpha/255
    }

    function saveData() {
        settings.bgColorRed = red.value*255
        settings.bgColorGreen = green.value*255
        settings.bgColorBlue = blue.value*255
        settings.bgColorAlpha = alpha.value*255
    }

}
