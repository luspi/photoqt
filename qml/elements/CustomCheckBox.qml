import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

// This checkbox is a 'normal' checkbox with text either on the left or on the right (default)
Item {

	id: rect

	// Some properties that can be adjusted from parent
	property bool checkedButton: false
	property string text: ""
	property int fsize: 10
	property string textColour: colour.text
	property int elide: Text.ElideNone

	property int fixedwidth: -1

	property string indicatorColourEnabled: colour.radio_check_indicator_color
	property string indicatorBackgroundColourEnabled: colour.radio_check_indicator_bg_color

	// Per default the text in on the right
	property bool textOnRight: true

	// Set size
	width: fixedwidth==-1 ? childrenRect.width : fixedwidth
	height: Math.max(txt.height,check.height)

	// 'Copy' functionality of checkedChanged of Button Item
	signal buttonCheckedChanged()

	// If the text is displayed on the left, we have to use a seperate text label for that
	Text {

		id: txt

		visible: !textOnRight

		color: textColour
		Behavior on color { ColorAnimation { duration: 150; } }

		text: !textOnRight ? rect.text : ""
		font.pointSize: fsize
		elide: rect.elide

	}

	// This is the checkbox, with or without text (depending on location of label)
	CheckBox {

		id: check

		anchors.left: txt.right
		anchors.leftMargin: textOnRight ? 0 : 5
		anchors.right: (fixedwidth==-1 ? undefined : rect.right)

		// Checked state is tied to this global property
		checked: rect.checkedButton

		// Styling
		style: CheckBoxStyle {
			indicator: Rectangle {
				implicitWidth: fsize*2
				implicitHeight: fsize*2
				radius: global_item_radius/2
				color: control.enabled ? indicatorBackgroundColourEnabled : colour.radio_check_indicator_bg_color_disabled
				Behavior on color { ColorAnimation { duration: 150; } }
				Rectangle {
					visible: rect.checkedButton
					color: control.enabled ? indicatorColourEnabled : colour.radio_check_indicator_color_disabled
					Behavior on color { ColorAnimation { duration: 150; } }
					radius: global_item_radius/2
					anchors.margins: 4
					anchors.fill: parent
				}
			}
			label: Text {
				color: textColour
				Behavior on color { ColorAnimation { duration: 150; } }
				visible: textOnRight
				elide: rect.elide
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
