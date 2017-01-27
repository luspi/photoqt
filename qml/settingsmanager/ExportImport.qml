import QtQuick 2.3
import "../elements"

Rectangle {

	color: colour.fadein_slidein_block_bg

	visible: false
	opacity: 0
	Behavior on opacity { NumberAnimation { duration: 300 } }
	onOpacityChanged: {
		if(opacity == 0) visible = false
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onClicked: hide()
	}

	Rectangle {

		color: colour.fadein_slidein_bg
		border.width: 1
		border.color: colour.fadein_slidein_border
		radius: global_element_radius

		width: 600
		height: 400
		x: (parent.width-width)/2
		y: (parent.height-height)/2

		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
		}

		Rectangle {

			id: contrect

			anchors.fill: parent
			anchors.margins: 10
			color: "transparent"

			Column {

				spacing: 20

				Rectangle {
					color: "transparent"
					width: contrect.width
					height: 10
				}

				Text {
					text: qsTr("Export/Import settings and shortcuts")
					color: "white"
					font.pointSize: 18
					width: contrect.width
					horizontalAlignment: Text.AlignHCenter
					font.bold: true
				}

				Text {
					text: qsTr("Here you can export all settings and shortcuts into a single packed file and, e.g., import it in another installation of PhotoQt.")
					color: "white"
					width: contrect.width
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
				}

				Rectangle {
					color: "#55ffffff"
					width: contrect.width
					height: 1
				}

				CustomButton {
					text: qsTr("Export everything to file")
					x: (contrect.width-width)/2
					fontsize: 18
					onClickedButton: {
						var ret = getanddostuff.exportConfig()
						if(ret != "") {
							errormsg.error = ret
							errormsg.exp = true
							errormsg.show()
						} else
							hide()
					}
				}

				Rectangle {
					color: "#55ffffff"
					width: contrect.width
					height: 1
				}

				CustomFileSelect {
					id: importfilename
					x: (contrect.width-width)/2
					width: 400
				}
				CustomButton {
					x: (contrect.width-width)/2
					text: qsTr("Import settings and shortcuts")
					enabled: importfilename.file!=""
					onClickedButton: {
						var ret = getanddostuff.importConfig(importfilename.file)
						if(ret != "") {
							errormsg.exp = false
							errormsg.error = ret
							errormsg.show()
						} else
							getanddostuff.restartPhotoQt(thumbnailBar.currentFile)
					}
				}

				Text {
					color: enabled ? colour.text : colour.text_disabled
					width: parent.width
					enabled: importfilename.file!=""
					horizontalAlignment: Text.AlignHCenter
					wrapMode: Text.WordWrap
					text: qsTr("PhotoQt will attempt to automatically restart after a successful import!")
				}

			}

		}

	}

	CustomConfirm {
		id: errormsg
		header: qsTr("Error")
		property string error: ""
		property bool exp: false
		description: (exp ? qsTr("Exporting the configuration file failed with the following error message:") : qsTr("Importing the configuration file failed with the following error message:")) + "<br><br>" + error
		rejectbuttontext: qsTr("Oh, okay")
		actAsErrorMessage: true
	}

	function show() {
		visible = true
		opacity = 1
	}

	function hide() {
		opacity = 0;
	}

}
