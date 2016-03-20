import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./lookandfeel"
import "../../elements"


Rectangle {

	id: tab_top

	property int titlewidth: 100

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

		Column {

			id: maincol

			Rectangle { color: "transparent"; width: 1; height: 10; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 20
				font.bold: true
				text: qsTr("Look and Feel")
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 9
				text: qsTr("Move your mouse cursor over the different settings titles to see more information.")
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			SortBy { id: sortby; }
			WindowMode { id: windowmode; alternating: true }
			TrayIcon { id: trayicon }
			ClosingX { id: closingx; alternating: true }
			FitInWindow { id: fitin }
			Quickinfo { id: quickinfo; alternating: true }
			Background { id: background }
			OverlayColor { id: overlay; alternating: true }
			Blur { id: blur }
			BorderAroundImage { id: border; alternating: true }
			CloseOnClick { id: closeonclick }
			Loop { id: loop; alternating: true }
			Transition { id: transition }
			HotEdge { id: hotedge; alternating: true }
			MouseWheelSensitivity { id: mousewheel }
			Interpolation { id: interpolation; alternating: true }
			Remember { id: remember }
			Animation { id: animation; alternating: true }
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
		blur.setData()
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
		blur.saveData()
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
