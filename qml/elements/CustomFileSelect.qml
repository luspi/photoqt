import QtQuick 2.3

Rectangle {

	id: ele_top

	width: 300
	height: 30

	color: "transparent"

	property string file: ""

	Rectangle {

		id: ed1

		x: 3
		y: (parent.height-height)/2

		height: 30

		color: colour.element_bg_color_disabled
		radius: 5
		border.width: 1
		border.color: colour.element_border_color_disabled

		width: parent.width-selbut.width-6

		Text {
			id: filepath
			anchors.fill: parent
			anchors.leftMargin: 5
			anchors.rightMargin: 5
			color: colour.text
			verticalAlignment: Text.AlignVCenter
			clip: true
			elide: Text.ElideLeft

			Text {
				anchors.fill: parent
				color: colour.text_inactive
				opacity: 0.7
				verticalAlignment: Text.AlignVCenter
				clip: true
				text: qsTr("Click here to select a configuration file")
			}

		}

		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: getConfigFile()
		}

	}

	CustomButton {
		id: selbut
		text: "..."
		x: ed1.x+ed1.width+3
		width: 50
		onClickedButton: getConfigFile()
	}

	function getConfigFile() {
		var startfolder = getanddostuff.getHomeDir()
		if(filepath.text != "")
			startfolder = filepath.text
		var str = getanddostuff.getFilename(qsTr("Select PhotoQt config file..."),startfolder,qsTr("PhotoQt Config Files") + " (*.pqt);;" + qsTr("All Files") + " (*.*)")
		if(str !== "") {
			filepath.text = str
			file = str
		}
	}

}
