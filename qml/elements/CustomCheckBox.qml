import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

// This checkbox is a 'normal' checkbox with text either on the left or on the right (default)
Rectangle {

	id: rect

	// Container for items
	color: "#00000000"

	// Some properties that can be adjusted from parent
	property bool checkedButton: false
	property string text: ""
	property int fsize: 9
	property string textColour: "white"

	property string indicatorColourEnabled: "#ffffff"
	property string indicatorBackgroundColourEnabled: "#22FFFFFF"

	// Per default the text in on the right
	property bool textOnRight: true

	// Set size
	width: childrenRect.width
	height: childrenRect.height

	// 'Copy' functionality of checkedChanged of Button Item
	signal buttonCheckedChanged()

	// If the text is displayed on the left, we have to use a seperate text label for that
	Text {

		id: txt

		visible: !textOnRight

		color: textColour
		text: !textOnRight ? rect.text : ""
		font.pointSize: fsize

	}

	// This is the checkbox, with or without text (depending on location of label)
	CheckBox {

		id: check

		anchors.left: txt.right
		anchors.leftMargin: textOnRight ? 0 : 5

		// Checked state is tied to this global property
		checked: rect.checkedButton

		// Styling
		style: CheckBoxStyle {
			indicator: Rectangle {
				implicitWidth: fsize*2
				implicitHeight: fsize*2
				radius: 3
				color: control.enabled ? indicatorBackgroundColourEnabled : "#11CCCCCC"
				Rectangle {
					visible: rect.checkedButton
					color: control.enabled ? indicatorColourEnabled : "#555555"
					radius: 2
					anchors.margins: 4
					anchors.fill: parent
				}
			}
			label: Text {
				color: control.enabled ? "white" : "grey"
				visible: textOnRight
				text: textOnRight ? rect.text : ""
				font.pointSize: fsize
			}

		}

		onCheckedChanged: buttonCheckedChanged()

	}

	// Change cursor and catch click on whole container
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: checkedButton = !checkedButton
	}

}
