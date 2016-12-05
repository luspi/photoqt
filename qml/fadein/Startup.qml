import QtQuick 2.3
import QtQuick.Controls 1.2

import "./"
import "../elements"

Rectangle {

	id: rect

	// Positioning and basic look
	anchors.fill: background
	color: colour.fadein_slidein_bg

	// Invisible at startup
	visible: false
	opacity: 0

	property string type: ""

	property string openFileAfter: ""

	// Catch mouse events
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
	}

	// Scrollarea
	Rectangle {

		id: holder

		color: "transparent"

		width: rect.width
		height: col.height

		anchors.horizontalCenter: rect.horizontalCenter
		anchors.verticalCenter: rect.verticalCenter

		clip: true

		Column {

			id: col

			spacing: 15

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// HEADER LOGO
			Image {
				source: "qrc:/img/logo.png"
				width: Math.min(300, holder.width/2)
				height: sourceSize.height*(width/sourceSize.width)
				x: (holder.width-width)/2
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 10
			}

			Text {
				id: welcome
				text: qsTr("Welcome to PhotoQt")
				color: "white"
				font.pointSize: 45
				width: holder.width
				font.bold: true
				horizontalAlignment: Text.AlignHCenter
			}

			Text {
				color: "white"
				font.pointSize: 20
				width: Math.min(welcome.width-200,600)
				wrapMode: Text.WordWrap
				horizontalAlignment: Text.AlignHCenter
				anchors.horizontalCenter: parent.horizontalCenter
				text: type=="installed" ? qsTr("PhotoQt was successfully installed!") + "<br>" + qsTr("An image viewer packed with features and adjustable in every detail awaits you... Go, enjoy :-)")
										: qsTr("PhotoQt was successfully updated!") + "<br>" + qsTr("Many new features and bug fixes await you... Go, enjoy :-)")
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 15
			}

			CustomButton {
				text: qsTr("Lets get started!")
				fontsize: 30
				anchors.horizontalCenter: col.horizontalCenter
				onClickedButton: hideStartup()
			}

		} // END Column

	} // END Flickable

	function showStartup(t, filenameAfter) {

		type = t;
		openFileAfter = filenameAfter

		showStartupAni.start()

	}

	function hideStartup() {
		hideStartupAni.start()
	}

	PropertyAnimation {
		id: hideStartupAni
		target: rect
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStopped: {
			visible = false
			blocked = false
			if(openFileAfter == "")
				openFile()
			else
				reloadDirectory(openFileAfter,"")
		}
	}

	PropertyAnimation {
		id: showStartupAni
		target: rect
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
		}
	}


}
