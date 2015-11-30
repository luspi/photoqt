import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Overlay Color"

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
								width: 60
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
								width: 60
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
								width: 60
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
								width: 60
								horizontalAlignment: Qt.AlignRight
								color: colour.text
								font.pointSize: 10
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

				/* Image, Rectangle, and Label to preview background colour */

				Image {

					id: background_colour

					width: 200
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
								text: qsTr("Preview colour")

							}

						}

					}

				}

			}

		}

	}

}
