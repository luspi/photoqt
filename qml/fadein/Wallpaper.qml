import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: wallpaper

	anchors.fill: background
	color: colour_fadein_block_bg

	opacity: 0
	visible: false

	property int currentlySelectedWm: 0

	property var selectedScreens: []

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideWallpaperAni.start()
	}

	Rectangle {

		id: item

		// Set size
		anchors {
			fill: parent
			topMargin: Math.min((parent.width-400)/2,(parent.height-rect.height)/2)
			bottomMargin: Math.min((parent.width-400)/2,(parent.height-rect.height)/2)
			leftMargin: Math.min((parent.width-800)/2,300)
			rightMargin: Math.min((parent.width-800)/2,300)
		}

		// Some styling
		border.width: 1
		border.color: colour_fadein_border
		radius: 10
		color: colour_fadein_bg

		// Clicks INSIDE element doesn't close it
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
		}

		Rectangle {

			id: rect

			// Set inner area for display
			height: topcol.height+25
			width: parent.width-2*item.radius
			x: item.radius
			color: "#00000000"

			Column {

				id: topcol

				spacing: 10

				Rectangle { color: "#00000000"; width: 1; height: 1; }
				Rectangle { color: "#00000000"; width: 1; height: 1; }


				// HEADING
				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					Row {
						spacing: 5
						Text {
							color: "white"
							font.pointSize: 20
							font.bold: true
							text: "Set as Wallpaper:"
						}
						Text {
							y: parent.height-height
							color: "white"
							font.pointSize: 19
							text: "P1080310.JPG"
						}
					}
				}


				Rectangle { color: "#00000000"; width: 1; height: 1; }


				// WINDOW MANAGER SETTINGS
				Text {
					color: "white"
					font.bold: true
					font.pointSize: 16
					text: "Window Manager"
				}

				Text {
					color: "white"
					font.pointSize: 11
					width: rect.width
					wrapMode: Text.WordWrap
					text: "PhotoQt tries to detect your window manager according to the environment variables set by your system. If it still got it wrong, you can change the window manager manually."
				}

				CustomComboBox {
					id: wm_selection
					x: (rect.width-width)/2
					fontsize: 14
					width: 150
					model: ["KDE4","Plasma 5","Gnome/Unity","XFCE4","Other"]
					// We detect the wm only here, right at the beginning, and NOT everytime the element is opened, as we don't want to change any settings that the user did during that runtime (this is useful to, e.g., play around with different wallpapers to see which one fits best)
					Component.onCompleted: {
						var wm = getanddostuff.detectWindowManager();
						if(wm === "kde4")
							wm_selection.currentIndex = 0
						if(wm === "plasma5")
							wm_selection.currentIndex = 1
						if(wm === "gnome_unity")
							wm_selection.currentIndex = 2
						if(wm === "xfce4")
							wm_selection.currentIndex = 3
						if(wm === "other")
							wm_selection.currentIndex = 4
					}
					onCurrentIndexChanged: okay.enabled = enDisableEnter()
				}

				Rectangle { color: "#00000000"; width: 1; height: 1; }

				Rectangle {
					color: "grey"
					width: rect.width
					height: 1
				}

				Rectangle { color: "#00000000"; width: 1; height: 1; }


				// A SCROLLABLE AREA CONTAINING THE SETTINGS
				Flickable {

					width: parent.width
					height: Math.min(300,wallpaper.height/3)
					contentHeight: settingsrect.height
					clip: true
					boundsBehavior: (settingsrect.height > height ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds)

					Rectangle {

						id: settingsrect

						color: "#00000000"
						width: parent.width
						height: childrenRect.height

						/**********************************************************************************/
						/**********************************************************************************/
						// KDE4
						/**********************************************************************************/
						Rectangle {

							visible: wm_selection.currentIndex == 0

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 0 ? childrenRect.height : 10)

							Text {

								width: rect.width*0.75
								x: (rect.width-width)/2
								color: "red"
								font.bold: true
								wrapMode: Text.WordWrap
								horizontalAlignment: Text.AlignHCenter
								text: "Sorry, KDE4 doesn't offer the feature to change the wallpaper except from their own system settings. Unfortunately there's nothing I can do about that."

							}

						}

						/**********************************************************************************/
						/**********************************************************************************/
						// PLASMA 5
						/**********************************************************************************/
						Rectangle {

							visible: wm_selection.currentIndex == 1

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 1 ? childrenRect.height : 10)

							Text {

								width: rect.width*0.75
								x: (rect.width-width)/2
								color: "red"
								font.bold: true
								wrapMode: Text.WordWrap
								horizontalAlignment: Text.AlignHCenter
								text: "Sorry, Plasma 5 doesn't yet offer the feature to change the wallpaper except from their own system settings. Hopefully this will change soon, but until then there's nothing I can do about that."

							}

						}

						/**********************************************************************************/
						/**********************************************************************************/
						// GNOME/UNITY
						/**********************************************************************************/
						Rectangle {

							visible: wm_selection.currentIndex == 2

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 2 ? childrenRect.height : 10)

							Column {

								spacing: 5

								// PICTURE OPTIONS HEADING
								Text {
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: "There are several picture options that can be set for the wallpaper image."
								}

								Rectangle { color: "#00000000"; width: 1; height: 1; }

								ExclusiveGroup { id: wallpaperoptions_gnomeunity; }
								Rectangle {

									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (rect.width-width)/2

									Column {

										spacing: 10

										CustomRadioButton {
											text: "wallpaper"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_gnomeunity
											checked: true
										}
										CustomRadioButton {
											text: "centered"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_gnomeunity
										}
										CustomRadioButton {
											text: "scaled"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_gnomeunity
										}
										CustomRadioButton {
											text: "zoom"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_gnomeunity
										}
										CustomRadioButton {
											text: "spanned"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_gnomeunity
										}

									}

								}

							}

						}

						/**********************************************************************************/
						/**********************************************************************************/
						// XFCE4
						/**********************************************************************************/
						Rectangle {

							visible: wm_selection.currentIndex == 3

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 3 ? childrenRect.height : 10)

							Column {

								spacing: 5

								// MONITOR HEADING
								Text {
									id: xfce4_monitor_part_1
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: "The wallpaper can be set to either of the available monitors (or any combination)."
								}

								// MONITOR SELECTION
								Rectangle {
									id: xfce4_monitor_part_2
									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (rect.width-width)/2
									ListView {
										id: xfce4_monitor
										width: 10
										spacing: 5
										height: childrenRect.height
										delegate: CustomCheckBox {
											text: "Screen #" + index
											checkedButton: true
											fsize: 11
											Component.onCompleted: {
												selectedScreens[selectedScreens.length] = index
												if(xfce4_monitor.width < width)
													xfce4_monitor.width = width
											}
											onCheckedButtonChanged: {
												if(checkedButton)
													selectedScreens[selectedScreens.length] = index
												else {
													var newlist = []
													for(var i = 0; i < selectedScreens.length; ++i)
														if(selectedScreens[i] !== index)
															newlist[newlist.length] = selectedScreens[i]
													selectedScreens = newlist
												}
												okay.enabled = enDisableEnter()
											}
										}
										model: ListModel { id: xfce4_monitor_model; }
									}
								}

								Rectangle { id: xfce4_monitor_part_3; color: "#00000000"; width: 1; height: 1; }
								Rectangle { id: xfce4_monitor_part_4; color: "#00000000"; width: 1; height: 1; }

								// PICTURE OPTIONS HEADING
								Text {
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: "There are several picture options that can be set for the wallpaper image."
								}

								Rectangle { color: "#00000000"; width: 1; height: 1; }

								// PICTURE OPTIONS RADIOBUTTONS
								ExclusiveGroup { id: wallpaperoptions_xfce; }
								Rectangle {
									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (rect.width-width)/2
									Column {
										spacing: 10
										CustomRadioButton {
											text: "Automatic"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_xfce
										}
										CustomRadioButton {
											text: "Centered"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_xfce
										}
										CustomRadioButton {
											text: "Tiled"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_xfce
										}
										CustomRadioButton {
											text: "Stretched"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_xfce
										}
										CustomRadioButton {
											text: "Scaled"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_xfce
										}
										CustomRadioButton {
											text: "Zoomed"
											fontsize: 11
											exclusiveGroup: wallpaperoptions_xfce
											checked: true
										}

									}

								}


							}

						}


						/**********************************************************************************/
						/**********************************************************************************/
						// OTHER
						/**********************************************************************************/
						Rectangle {

							visible: (wm_selection.currentIndex == 4)

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 4 ? childrenRect.height : 10)

							Column {

								spacing: 15

								// HEADING
								Text {
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: "PhotoQt can use 'feh' or 'nitrogen' to change the background of the desktop.<br>This is intended particularly for window managers that don't natively support wallpapers (e.g., like Openbox)."
								}

								// SWITCH BETWEEN feh AND nitrogen
								Rectangle {

									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (parent.width-width)/2

									Row {
										spacing: 15
										CustomCheckBox {
											id: feh
											text: "Use 'feh'"
											checkedButton: true
											onButtonCheckedChanged: nitrogen.checkedButton = !feh.checkedButton
										}
										CustomCheckBox {
											id: nitrogen
											text: "Use 'nitrogen'"
											checkedButton: false
											onButtonCheckedChanged: feh.checkedButton = !nitrogen.checkedButton
										}
									}

								}

								Rectangle { color: "#00000000"; width: 1; height: 1; }

								// feh SETTINGS
								Rectangle {

									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (parent.width-width)/2

									Column {
										id: fehcolumn
										visible: feh.checkedButton
										spacing: 10
										ExclusiveGroup { id: fehexclusive; }
										CustomRadioButton {
											exclusiveGroup: fehexclusive
											text: "--bg-center"
											checked: true
										}
										CustomRadioButton {
											exclusiveGroup: fehexclusive
											text: "--bg-fill"
										}
										CustomRadioButton {
											exclusiveGroup: fehexclusive
											text: "--bg-max"
										}
										CustomRadioButton {
											exclusiveGroup: fehexclusive
											text: "--bg-scale"
										}
										CustomRadioButton {
											exclusiveGroup: fehexclusive
											text: "--bg-tile"
										}
									}

									// nitrogen SETTINGS
									Column {
										id: nitrogencolumn
										visible: nitrogen.checkedButton
										spacing: 10
										ExclusiveGroup { id: nitrogenexclusive; }
										CustomRadioButton {
											exclusiveGroup: nitrogenexclusive
											text: "--set-auto"
											checked: true
										}
										CustomRadioButton {
											exclusiveGroup: nitrogenexclusive
											text: "--set-centered"
										}
										CustomRadioButton {
											exclusiveGroup: nitrogenexclusive
											text: "--set-scaled"
										}
										CustomRadioButton {
											exclusiveGroup: nitrogenexclusive
											text: "--set-tiled"
										}
										CustomRadioButton {
											exclusiveGroup: nitrogenexclusive
											text: "--set-zoom"
										}
										CustomRadioButton {
											exclusiveGroup: nitrogenexclusive
											text: "--set-zoom-fill"
										}
									}

								}

							}

						}



					}

				}	// END FLickable

				Rectangle {
					color: "grey"
					width: rect.width
					height: 1
				}

				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2

					Row {
						spacing: 10
						CustomButton {
							id: okay
							text: "Okay, do it!"
							enabled: enDisableEnter()
							onClickedButton: simulateEnter();
						}
						CustomButton {
							text: "Nooo, don't!"
							onClickedButton: hideWallpaper()
						}
					}
				}

			}

		}	// END id: rect

	}

	function enDisableEnter() {
		console.log("enDisable:", wm_selection.currentIndex,selectedScreens)
		if(wm_selection.currentIndex == 3 && selectedScreens.length != 0)
			return true
		else if(wm_selection.currentIndex != 0 && wm_selection.currentIndex != 1 && wm_selection.currentIndex != 3)
			return true;
		return false;
	}

	function simulateEnter() {

		if(!okay.enabled)
			return;

		var wm = ""
		var options = {}

		if(wm_selection.currentIndex == 2)  {
			wm = "gnome_unity"
			options = { "option" : wallpaperoptions_gnomeunity.current.text }
		}
		if(wm_selection.currentIndex == 3)  {
			wm = "xfce4"
			options = { "screens" : selectedScreens,
						"option" : wallpaperoptions_xfce.current.text }
		}
		if(wm_selection.currentIndex == 4) {
			wm = "other"
			options = { "app" : (feh.checkedButton ? "feh" : "nitrogen"),
						"feh_option" : fehexclusive.current.text,
						"nitrogen_option" : nitrogenexclusive.current.text }
		}
		getanddostuff.setWallpaper(wm, options, thumbnailBar.currentFile)

		hideWallpaper()

	}

	function showWallpaper() {

		// Set-up monitor checkboxes
		var c = getanddostuff.getScreenCount()
		xfce4_monitor_model.clear()
		for(var i = 0; i < c; ++i)
			xfce4_monitor_model.append({ "index" : i })

		xfce4_monitor_part_1.visible = (c > 1)
		xfce4_monitor_part_2.visible = (c > 1)
		xfce4_monitor_part_3.visible = (c > 1)
		xfce4_monitor_part_4.visible = (c > 1)

		showWallpaperAni.start()
	}
	function hideWallpaper() {

		console.log(selectedScreens)

		hideWallpaperAni.start()

	}

	PropertyAnimation {
		id: hideWallpaperAni
		target:  wallpaper
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
			blocked = false
			if(image.url === "")
				openFile()
		}
	}

	PropertyAnimation {
		id: showWallpaperAni
		target:  wallpaper
		property: "opacity"
		to: 1
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
