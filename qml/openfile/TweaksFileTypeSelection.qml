import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements"

Rectangle {
	id: hovprev_but
	y: 10
	width: select.width+20
	height: parent.height-20
	color: "#00000000"

	// Select which group of images to display
	CustomComboBox {
		id: select
		y: (parent.height-height)/2
		width: 200
		backgroundColor: "#313131"
		radius: 5
		showBorder: false
		currentIndex: 0
		onCurrentIndexChanged: {
			openfile_top.loadCurrentDirectory(openfile_top.currentlyLoadedDir)
		}
		model: [qsTr("All supported images"), "Qt " +
			//: 'images' as in the term 'something images'
			qsTr("images"), "GraphicsMagick " +
			//: 'images' as in the term 'something images'
			qsTr("images"), "LibRaw " +
			//: 'images' as in the term 'something images'
			qsTr("images")]
	}

	function getFileTypeSelection() {
		return select.currentIndex
	}
	function setFileTypeSelection(i) {
		select.currentIndex = i
	}
}
