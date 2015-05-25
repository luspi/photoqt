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

	property var selectedScreens_xfce4: []
	property var selectedScreens_enlightenment: []
	property var selectedWorkspaces_enlightenment: []

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
							text: qsTr("Set as Wallpaper:")
						}
						Text {
							y: parent.height-height
							color: "white"
							font.pointSize: 19
							text: ""
						}
					}
				}


				Rectangle { color: "#00000000"; width: 1; height: 1; }


				// WINDOW MANAGER SETTINGS
				Text {
					color: "white"
					font.bold: true
					font.pointSize: 16
					text: qsTr("Window Manager")
				}

				Text {
					color: "white"
					font.pointSize: 11
					width: rect.width
					wrapMode: Text.WordWrap
					text: qsTr("PhotoQt tries to detect your window manager according to the environment variables set by your system. If it still got it wrong, you can change the window manager manually.")
				}

				CustomComboBox {
					id: wm_selection
					x: (rect.width-width)/2
					fontsize: 14
					width: 200
					model: ["KDE4","Plasma 5","Gnome/Unity","XFCE4","Enlightenment","Other"]
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
						if(wm === "enlightenment")
							wm_selection.currentIndex = 4
						if(wm === "other")
							wm_selection.currentIndex = 5
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
								text: qsTr("Sorry, KDE4 doesn't offer the feature to change the wallpaper except from their own system settings. Unfortunately there's nothing I can do about that.")

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
								text: qsTr("Sorry, Plasma 5 doesn't yet offer the feature to change the wallpaper except from their own system settings. Hopefully this will change soon, but until then there's nothing I can do about that.")

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

								// NOTE (tool not existing)
								Text {
									id: gnome_unity_error
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: 'gsettings' doesn't seem to be available! Are you sure Gnome/Unity is installed?");
								}

								// PICTURE OPTIONS HEADING
								Text {
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("There are several picture options that can be set for the wallpaper image.")
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

								// NOTE (tool not existing)
								Text {
									id: xfce4_error
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: 'xfconf-query' doesn't seem to be available! Are you sure XFCE4 is installed?");
								}

								Rectangle { id: xfce4_error_spacing; color: "#00000000"; width: 1; height: 1; }

								// MONITOR HEADING
								Text {
									id: xfce4_monitor_part_1
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("The wallpaper can be set to either of the available monitors (or any combination).")
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
											text: qsTr("Screen #") + index
											checkedButton: true
											fsize: 11
											Component.onCompleted: {
												selectedScreens_xfce4[selectedScreens_xfce4.length] = index
												if(xfce4_monitor.width < width)
													xfce4_monitor.width = width
											}
											onCheckedButtonChanged: {
												if(checkedButton)
													selectedScreens_xfce4[selectedScreens_xfce4.length] = index
												else {
													var newlist = []
													for(var i = 0; i < selectedScreens_xfce4.length; ++i)
														if(selectedScreens_xfce4[i] !== index)
															newlist[newlist.length] = selectedScreens_xfce4[i]
													selectedScreens_xfce4 = newlist
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
									text: qsTr("There are several picture options that can be set for the wallpaper image.")
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
						// ENLIGHTENMENT
						/**********************************************************************************/

						Rectangle {

							visible: (wm_selection.currentIndex == 4)

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 4 ? childrenRect.height : 10)

							Column {

								spacing: 15

								// NOTE (dbus error)
								Text {
									id: enlightenment_error_msgbus
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: It seems that the 'msgbus' (DBUS) module is not activated! It can be activated in the settings console > Add-ons > Modules > System.");
								}
								// NOTE (tool not existing)
								Text {
									id: enlightenment_error_exitence
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: 'enlightenment_remote' doesn't seem to be available! Are you sure Enlightenment is installed?");
								}

								// MONITOR HEADING
								Text {
									id: enlightenment_monitor_part_1
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("The wallpaper can be set to either of the available monitors (or any combination).")
								}

								// MONITOR SELECTION
								Rectangle {
									id: enlightenment_monitor_part_2
									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (rect.width-width)/2
									ListView {
										id: enlightenment_monitor
										width: 10
										spacing: 5
										height: childrenRect.height
										delegate: CustomCheckBox {
											text: qsTr("Screen #") + index
											checkedButton: true
											fsize: 11
											Component.onCompleted: {
												selectedScreens_enlightenment[selectedScreens_enlightenment.length] = index
												if(enlightenment_monitor.width < width)
													enlightenment_monitor.width = width
											}
											onCheckedButtonChanged: {
												if(checkedButton)
													selectedScreens_enlightenment[selectedScreens_enlightenment.length] = index
												else {
													var newlist = []
													for(var i = 0; i < selectedScreens_enlightenment.length; ++i)
														if(selectedScreens_enlightenment[i] !== index)
															newlist[newlist.length] = selectedScreens_enlightenment[i]
													selectedScreens_enlightenment = newlist
												}
												okay.enabled = enDisableEnter()
											}
										}
										model: ListModel { id: enlightenment_monitor_model; }
									}
								}

								Rectangle { id: enlightenment_monitor_part_3; color: "#00000000"; width: 1; height: 1; }
								Rectangle { id: enlightenment_monitor_part_4; color: "#00000000"; width: 1; height: 1; }

								// PICTURE OPTIONS HEADING
								Text {
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("You can set the wallpaper to any sub-selection of workspaces")
								}

								Rectangle { color: "#00000000"; width: 1; height: 1; }

								// WORKSPACE SELECTION
								Rectangle {
									color: "#00000000"
									width: childrenRect.width
									height: childrenRect.height
									x: (rect.width-width)/2
									ListView {
										id: enlightenment_workspace
										width: 10
										spacing: 5
										height: childrenRect.height
										property int index: selectedWorkspaces_enlightenment.length
										delegate: CustomCheckBox {
											text: {
												if(row == -1)
													return qsTr("Workspace #") + column
												if(column == -1)
													return qsTr("Workspace #") + row
												return qsTr("Workspace #") + row + "-" + column
											}
											checkedButton: true
											fsize: 11
											Component.onCompleted: {
												// SINGLE COLUMNS/ROWS ARE TREATED SPECIALLY (DIFFERENTLY DISPLAYED!)
												selectedWorkspaces_enlightenment[index] = (row == -1 ? 10000*(column+1) : (column == -1 ? 10000000*(row+1) : row*100+column))
												if(enlightenment_workspace.width < width)
													enlightenment_workspace.width = width
											}
											onCheckedButtonChanged: {
												if(checkedButton)
													selectedWorkspaces_enlightenment[selectedWorkspaces_enlightenment.length] = (row == -1 ? 10000*(column+1) : (column == -1 ? 10000000*(row+1) : row*100+column))
												else {
													var newlist = []
													for(var i = 0; i < selectedWorkspaces_enlightenment.length; ++i)
														if(selectedWorkspaces_enlightenment[i] !== (row == -1 ? 10000*(column+1) : (column == -1 ? 10000000*(row+1) : row*100+column)))
															newlist[newlist.length] = selectedWorkspaces_enlightenment[i]
													selectedWorkspaces_enlightenment = newlist
												}
												okay.enabled = enDisableEnter()
											}
										}
										model: ListModel { id: enlightenment_workspace_model; }
									}
								}

							}

						}


						/**********************************************************************************/
						/**********************************************************************************/
						// OTHER
						/**********************************************************************************/
						Rectangle {

							visible: (wm_selection.currentIndex == 5)

							color: "#00000000"
							width: childrenRect.width
							height: (wm_selection.currentIndex == 5 ? childrenRect.height : 10)

							Column {

								spacing: 15

								// NOTE for feh (tool not existing)
								Text {
									id: other_error_feh
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: 'feh' doesn't seem to be installed!");
								}
								// NOTE for nitrogen (tool not existing)
								Text {
									id: other_error_nitrogen
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: 'nitrogen' doesn't seem to be installed!");
								}
								// NOTE for feh AND nitrogen (tool not existing)
								Text {
									id: other_error_feh_nitrogen
									visible: false
									color: "red"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("Warning: Both 'feh' and 'nitrogen' don't seem to be installed!");
								}


								// HEADING
								Text {
									color: "white"
									font.pointSize: 11
									width: rect.width
									wrapMode: Text.WordWrap
									horizontalAlignment: Text.AlignHCenter
									text: qsTr("PhotoQt can use 'feh' or 'nitrogen' to change the background of the desktop.<br>This is intended particularly for window managers that don't natively support wallpapers (e.g., like Openbox).")
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
											//: feh is an application, do not translate
											text: qsTr("Use 'feh'")
											checkedButton: true
											onButtonCheckedChanged: nitrogen.checkedButton = !feh.checkedButton
										}
										CustomCheckBox {
											id: nitrogen
											//: nitrogen is an application, do not translate
											text: qsTr("Use 'nitrogen'")
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

			}

		}	// END id: rect

	}

	// Detect if settings are valid or not
	function enDisableEnter() {
		if(wm_selection.currentIndex == 3 && selectedScreens_xfce4.length != 0)
			return true
		else if(wm_selection.currentIndex != 0 && wm_selection.currentIndex != 1 && wm_selection.currentIndex != 3)
			return true;
		return false;
	}

	function simulateEnter() {

		// This way we detect if the current setting is valid or not
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
			options = { "screens" : selectedScreens_xfce4,
						"option" : wallpaperoptions_xfce.current.text }
		}
		if(wm_selection.currentIndex == 4) {
			wm = "enlightenment"
			options = { "screens" : selectedScreens_enlightenment,
						"workspaces" : selectedWorkspaces_enlightenment }
		}

		if(wm_selection.currentIndex == 5) {
			wm = "other"
			options = { "app" : (feh.checkedButton ? "feh" : "nitrogen"),
						"feh_option" : fehexclusive.current.text,
						"nitrogen_option" : nitrogenexclusive.current.text }
		}
		getanddostuff.setWallpaper(wm, options, thumbnailBar.currentFile)

		hideWallpaper()

	}

	function showWallpaper() {

		if(thumbnailBar.currentFile === "") return

		// Set-up monitor checkboxes
		var c = getanddostuff.getScreenCount()
		xfce4_monitor_model.clear()
		enlightenment_monitor_model.clear()
		for(var i = 0; i < c; ++i) {
			xfce4_monitor_model.append({ "index" : i })
			enlightenment_monitor_model.append({ "index" : i })
		}

		// Set-up enlightenment workspaces
		enlightenment_workspace_model.clear()
		var d = getanddostuff.getEnlightenmentWorkspaceCount()
		for(var i = 0; i < d[0]; ++i)
			for(var j = 0; j < d[1]; ++j)
				enlightenment_workspace_model.append({"row" : (d[0] === 1 ? -1 : i), "column" : (d[1] === 1 ? -1 : j)})

		// Hide screen selection elements for single screen set-ups
		xfce4_monitor_part_1.visible = (c > 1)
		xfce4_monitor_part_2.visible = (c > 1)
		xfce4_monitor_part_3.visible = (c > 1)
		xfce4_monitor_part_4.visible = (c > 1)

		enlightenment_monitor_part_1.visible = (c > 1)
		enlightenment_monitor_part_2.visible = (c > 1)
		enlightenment_monitor_part_3.visible = (c > 1)
		enlightenment_monitor_part_4.visible = (c > 1)

		// Check for tools (and display appropriate error messages
		var ret = getanddostuff.checkWallpaperTool("enlightenment")
		enlightenment_error_exitence.visible = (ret === 1)
		enlightenment_error_msgbus.visible = (ret === 2)
		ret = getanddostuff.checkWallpaperTool("gnome_unity")
		gnome_unity_error.visible = (ret === 1)
		ret = getanddostuff.checkWallpaperTool("xfce4")
		xfce4_error.visible = (ret === 1)
		xfce4_error_spacing.visible = (ret === 1)
		ret = getanddostuff.checkWallpaperTool("other")
		other_error_feh_nitrogen.visible = (ret === 3)
		other_error_nitrogen.visible = (ret === 2)
		other_error_feh.visible = (ret === 1)

		showWallpaperAni.start()
	}

	function hideWallpaper() {
		hideWallpaperAni.start()
	}

	PropertyAnimation {
		id: hideWallpaperAni
		target:  wallpaper
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStopped: {
			visible = false
			blocked = false
		}
	}

	PropertyAnimation {
		id: showWallpaperAni
		target:  wallpaper
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
