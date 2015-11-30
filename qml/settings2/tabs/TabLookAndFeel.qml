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
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+20
		contentWidth: maincol.width

		boundsBehavior: Flickable.StopAtBounds

		Column {

			id: maincol

			Rectangle { color: "transparent"; width: 1; height: 10; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 20
				font.bold: true
				text: "Look and Feel"
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 10; }

			SortBy { id: sortby; }
			WindowMode { id: windowmode; alternating: true }
			TrayIcon { id: trayicon }
			ClosingX { id: closingx; alternating: true }
			FitInWindow { id: fitin }
			Quickinfo { id: quickinfo; alternating: true }
			Background { id: background }
			OverlayColor { id: overlay; alternating: true }
			BorderAroundImage { id: border }
			CloseOnClick { id: closeonclick; alternating: true }
			Loop { id: loop }
			Transition { id: transition; alternating: true }
			HotEdge { id: hotedge }
			MouseWheelSensitivity { id: mousewheel; alternating: true }
			Interpolation { id: interpolation }
			Remember { id: remember; alternating: true }
			Animation { id: animation }
		}

	}

	function setData() {

		sortby.setData()
		windowmode.setData()
		trayicon.setData()
		closingx.setData()
		fitin.setData()
		quickinfo.setData()
		background.setData()
		overlay.setData()
		border.setData()
		closeonclick.setData()
		loop.setData()
		transition.setData()
		hotedge.setData()
		mousewheel.setData()
		interpolation.setData()
		remember.setData()
		animation.setData()

	}

	function saveData() {

		sortby.saveData()
		windowmode.saveData()
		trayicon.saveData()
		closingx.saveData()
		fitin.saveData()
		quickinfo.saveData()
		background.saveData()
		overlay.saveData()
		border.saveData()
		closeonclick.saveData()
		loop.saveData()
		transition.saveData()
		hotedge.saveData()
		mousewheel.saveData()
		interpolation.saveData()
		remember.saveData()
		animation.saveData()

	}

}
