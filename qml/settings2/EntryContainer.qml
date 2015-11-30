import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

Rectangle {

	id: item_top

	property bool alternating: false

	color: alternating ? "#06ffffff" : "transparent"
	width: flickable.width
	height: childrenRect.height+20

}
