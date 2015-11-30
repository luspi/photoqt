import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./lookandfeel"
import "../../elements"


Rectangle {

	id: tab_lookandfeel

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

			SortBy { }
			WindowMode { alternating: true }
			TrayIcon { }
			ClosingX { alternating: true }
			FitInWindow { }
			Quickinfo { alternating: true }
			Background { }
			OverlayColor { alternating: true }
			BorderAroundImage { }
			CloseOnClick { alternating: true }
			Loop { }
			Transition { alternating: true }
			HotEdge { }
			MouseWheelSensitivity { alternating: true }
			Interpolation { }
			Remember { alternating: true }
			Animation { }
		}

	}

}
