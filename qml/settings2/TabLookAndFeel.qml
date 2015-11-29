import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./"
import "./lookandfeel"
import "../elements"


Rectangle {

	id: tab

	color: "#00000000"

	anchors {
		fill: parent
		leftMargin: 20
		rightMargin: 20
		topMargin: 15
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		x: 0
		y: 0
		width: parent.width
		height: parent.height

		contentHeight: contentItem.childrenRect.height+50
		contentWidth: maincol.width

		boundsBehavior: Flickable.StopAtBounds

		Column {

			id: maincol

			property int flickablewidth: flickable.width

			property int titlewidth: 100
			property int titlespacing: 20
			property int spacingbetween: 100

			SortBy { }
			WindowMode { color: "#06ffffff" }
			TrayIcon { }
			ClosingX { color: "#06ffffff" }
			FitInWindow { }
			Quickinfo { color: "#06ffffff" }
			Background { }
			OverlayColor { color: "#06ffffff" }
			BorderAroundImage { }
			CloseOnClick { color: "#06ffffff" }
			Loop { }
			Transition { color: "#06ffffff" }
			HotEdge { }
			MouseWheelSensitivity { color: "#06ffffff" }
			Interpolation { }
			Remember { color: "#06ffffff" }
			Animation { }
		}

	}

}
