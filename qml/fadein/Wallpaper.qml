import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"
import "./wallpaper"

FadeInTemplate {

	id: wallpaper_top

	heading: qsTr("Set as Wallpaper")

	property int currentlySelectedWm: 0

	content: [

		// spacing
		Rectangle {
			color: "transparent"
			height: 5
			width: 1
		},

		// WINDOW MANAGER SETTINGS
		Text {
			color: colour.text
			font.bold: true
			font.pointSize: 15
			text: qsTr("Window Manager")
		},

		Text {
			color: colour.text
			font.pointSize: 10
			width: wallpaper_top.width
			wrapMode: Text.WordWrap
			text: qsTr("PhotoQt tries to detect your window manager according to the environment variables set by your system. If it still got it wrong, you can change the window manager manually.")
		},

		CustomComboBox {
			id: wm_selection
			x: (wallpaper_top.width-width)/2
			fontsize: 13
			width: 200
			model: ["KDE4","Plasma 5","Gnome/Unity","XFCE4","Enlightenment",qsTr("Other")]
			// We detect the wm only here, right at the beginning, and NOT everytime the element is opened, as we don't want to change any settings that the user did during that runtime (this is useful to, e.g., play around with different wallpapers to see which one fits best)
			Component.onCompleted: {
				var wm = getanddostuff.detectWindowManager();
				verboseMessage("Wallpaper","Detected window manager: " + wm)
				if(wm === "kde4")
					wm_selection.currentIndex = 0
				if(wm === "plasma5")
					wm_selection.currentIndex = 1
				if(wm === "gnome_unity")
					wm_selection.currentIndex = 2
				if(wm === "xfce4")
					wm_selection.currentIndex = 3
				if(wm === "enlightenment")
					wm_selection.currentIndex = 4
				if(wm === "other")
					wm_selection.currentIndex = 5
			}
			onCurrentIndexChanged: okay.enabled = enDisableEnter()
		},

		Rectangle { color: "#00000000"; width: 1; height: 1; },

		Rectangle {
			color: colour.linecolour
			width: wallpaper_top.width
			height: 1
		},

		Rectangle { color: "#00000000"; width: 1; height: 1; },


		// A SCROLLABLE AREA CONTAINING THE SETTINGS
		Flickable {

			width: parent.width
			height: Math.min(300,wallpaper.height/3)
			contentHeight: settingsrect.height
			clip: true
			boundsBehavior: Flickable.DragAndOvershootBounds

			Rectangle {

				id: settingsrect

				color: "#00000000"
				width: parent.width
				height: childrenRect.height

				/**********************************************************************************/
				/**********************************************************************************/
				// KDE4
				/**********************************************************************************/
				KDE4 {
					id: kde4
					currentlySelected: wm_selection.currentIndex == 0
				}

				/**********************************************************************************/
				/**********************************************************************************/
				// PLASMA 5
				/**********************************************************************************/
				Plasma5 {
					id: plasma5
					currentlySelected: wm_selection.currentIndex == 1
				}

				/**********************************************************************************/
				/**********************************************************************************/
				// GNOME/UNITY
				/**********************************************************************************/
				GnomeUnity {
					id: gnomeunity
					currentlySelected: wm_selection.currentIndex == 2
				}

				/**********************************************************************************/
				/**********************************************************************************/
				// XFCE4
				/**********************************************************************************/
				XFCE4 {
					id: xfce4
					currentlySelected: wm_selection.currentIndex == 3
				}


				/**********************************************************************************/
				/**********************************************************************************/
				// ENLIGHTENMENT
				/**********************************************************************************/

				Enlightenment {
					id: enlightenment
					currentlySelected: wm_selection.currentIndex == 4
				}


				/**********************************************************************************/
				/**********************************************************************************/
				// OTHER
				/**********************************************************************************/
				Other {
					id: other
					currentlySelected: wm_selection.currentIndex == 5
				}

			}

		}

	]

	buttons: [
		Item {
			anchors.horizontalCenter: parent.horizontalCenter
			width: childrenRect.width
			Row {
				spacing: 10
				CustomButton {
					id: okay
					text: qsTr("Okay, do it!")
					enabled: enDisableEnter()
					onClickedButton: simulateEnter();
				}
				CustomButton {
					text: qsTr("Nooo, don't!")
					onClickedButton: hideWallpaper()
				}
			}
		}
	]

	// Detect if settings are valid or not
	function enDisableEnter() {
		verboseMessage("Wallpaper::enDisableEnter()",wm_selection.currentIndex)
		if(wm_selection.currentIndex == 3 && xfce4.getSelectedScreens().length != 0)
			return true
		else if(wm_selection.currentIndex != 0 && wm_selection.currentIndex != 1 && wm_selection.currentIndex != 3)
			return true;
		return false;
	}

	function simulateEnter() {

		verboseMessage("Wallpaper::simulateEnter()",wm_selection.currentIndex)

		// This way we detect if the current setting is valid or not
		if(!okay.enabled)
			return;

		var wm = ""
		var options = {}

		if(wm_selection.currentIndex == 2)  {
			wm = "gnome_unity"
			options = { "option" : gnomeunity.getCurrentText() }
		}
		if(wm_selection.currentIndex == 3)  {
			wm = "xfce4"
			options = { "screens" : xfce4.getSelectedScreens(),
						"option" : xfce4.getCurrentText() }
		}
		if(wm_selection.currentIndex == 4) {
			wm = "enlightenment"
			options = { "screens" : enlightenment.getSelectedScreens(),
						"workspaces" : enlightenment.getSelectedWorkspaces() }
		}

		if(wm_selection.currentIndex == 5) {
			wm = "other"
			options = { "app" : other.getWhichToolChecked(),
						"feh_option" : other.getFehCurrentText(),
						"nitrogen_option" : other.getNitrogenCurrentText() }
		}
		getanddostuff.setWallpaper(wm, options, thumbnailBar.currentFile)

		hide()

	}

	function showWallpaper() {

		verboseMessage("Wallpaper::showWallpaper()",thumbnailBar.currentFile)

		if(thumbnailBar.currentFile === "") return

		gnomeunity.loadGnomeUnity()
		xfce4.loadXfce4()
		enlightenment.loadEnlightenment()
		other.loadOther()

		show()
	}

	function hideWallpaper() {
		hide()
	}

}
