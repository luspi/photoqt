import QtQuick 2.3

Rectangle {

	anchors.fill: parent
	color: "#88ff0000"

	Behavior on opacity { NumberAnimation { duration: 500; } }
	onOpacityChanged: {
		if(opacity == 0)
			visible = false
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onWheel: {
		}
	}

	Rectangle {

		color: "#88000000"

		width: childrenRect.width+100
		height: childrenRect.height+100

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter

		radius: 50

		Item {

			width: childrenRect.width
			height: childrenRect.height

			x: 50
			y: 50

			Column {

				spacing: 20

				Grid {

					columns: 2
					spacing: 5

					Text {
						text: "Button:"
						color: "#bbbbbb"
						font.pointSize: 20
					}
					Text {
						text: "Right"
						color: "#ffffff"
						font.pointSize: 20
					}
					Text {
						text: "Action:"
						color: "#bbbbbb"
						font.pointSize: 20
					}
					Text {
						text: "Single click"
						color: "#ffffff"
						font.pointSize: 20
					}
					Text {
						text: "Movement:"
						color: "#bbbbbb"
						font.pointSize: 20
					}
					Text {
						text: "-"
						color: "#ffffff"
						font.pointSize: 20
					}

				}

				Text {
					text: "Perform any mouse action or gestures you want to use as shortcut"
					color: "#ffffff"
					font.bold: true
					wrapMode: Text.WordWrap
				}

				Text {
					property int secs: 5
					id: countdownlabel
					text: secs + "..."
					x: (parent.width-width)/2
					color: "#ffffff"
					font.pointSize: 25
					font.bold: true
				}

				Timer {
					id: countdown
					interval: 1000
					repeat: true
					running: false
					onTriggered: {
						countdownlabel.secs -= 1
						if(countdownlabel.secs == 0) {
							countdown.stop()
							hide()
						}
					}
				}

			}

		}

	}

	function show() {
		countdown.start()
	}
	function hide() {
		countdown.stop()
		opacity = 0
	}

	function updateGesture(gesture) {
		countdownlabel.secs = 5
	}

}
