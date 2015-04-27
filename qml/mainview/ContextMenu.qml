import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	color: "red"

	x: 0
	y: 0
	width: 200
	height: 200
	visible: false


	function popup(p) {

		if(p.x+width > background.width) x = background.width-width
		else x = p.x

		if(p.y+height > background.height) x = background.height-height
		else y = p.y

		visible = true
		softblocked = 1

	}

	function hide() {
		visible = false
	}

}
