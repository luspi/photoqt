import QtQuick 2.3
import QtQuick.Controls 1.2

import "./"
import "../elements"

Rectangle {

	id: settings_top

	// Positioning and basic look
	anchors.fill: background
	color: colour.fadein_slidein_bg

	property int titlewidth: 100

	// Invisible at startup
//	visible: false
//	opacity: 0

	// setData is only emitted when settings have been 'closed without saving'
	// See comment above 'setData_restore()' function below
	signal setData()

	// Save data
	signal saveData()

	// signals needed for thumbnail db handling (for communication between confirm rect here and thumbnails>advanced tab)
	signal cleanDatabase()
	signal eraseDatabase()
	signal updateDatabaseInfo()

	// signals needed for shortcut handling
	signal newShortcut(var cmd, var key)
	signal newMouseShortcut(var cmd, var key)

	signal updateShortcut(var cmd, var key, var id)
	signal updateMouseShortcut(var cmd, var key, var id)
	signal reloadShortcuts()

	signal updateTheCommand(var id, var close, var mouse, var keys, var cmd)

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
	}

	Component.onCompleted: {
		settingssession.setValue("settings_titlewidth",100)
	}

	CustomTabView {

		id: view

		x: 0
		y: 0
		width: parent.width
		height: parent.height-butrow.height

		tabCount: 5     // We currently have 5 tabs in the settings

		Tab {

			title: qsTr("Look and Feel")

			TabLookAndFeel {

			}

//			CustomTabView {

//				id: subtab1

//				subtab: true   // this is a subtab
//				tabCount: 2    // and we have 2 tabs in it



//				Tab {

//					title: qsTr("Basic")

//					TabLookAndFeelBasic {
//						Connections {
//							target: top
//							onSetData:{
//								setData()
//							}
//							onSaveData:{
//								saveData()
//							}
//						}
//						Component.onCompleted: {
//							setData()
//						}
//					}

//				}

//				Tab {

//					title: qsTr("Advanced")

//					TabLookAndFeelAdvanced {
//						Connections {
//							target: top
//							onSetData:{
//								setData()
//							}
//							onSaveData:{
//								saveData()
//							}
//						}
//						Component.onCompleted: {
//							setData()
//						}
//					}
//				}
//			}
		}

		Tab {

			title: qsTr("Thumbnails")

			CustomTabView {

				subtab: true
				tabCount: 2

				Tab {

					title: qsTr("Basic")

//					TabThumbnailsBasic {
//						Connections {
//							target: top
//							onSetData:{
//								setData()
//							}
//							onSaveData:{
//								saveData()
//							}
//						}
//						Component.onCompleted: {
//							setData()
//						}
//					}

				}
				Tab {
					title: qsTr("Advanced")
//					TabThumbnailsAdvanced {
//						Connections {
//							target: top
//							onSetData:{
//								setData()
//							}
//							onSaveData:{
//								saveData()
//							}
//							onCleanDatabase: {
//								cleanDatabase()
//							}
//							onEraseDatabase: {
//								eraseDatabase()
//							}
//							onUpdateDatabaseInfo: {
//								updateDatabaseInfo()
//							}
//						}

//						Component.onCompleted: {
//							setData()
//						}
//					}
				}
			}
		}

		Tab {

			title: qsTr("Metadata")
//			TabDetails {
//				Connections {
//					target: top
//					onSetData:{
//						setData()
//					}
//					onSaveData:{
//						saveData()
//					}
//				}
//				Component.onCompleted: {
//					setData()
//				}
//			}

		}

		Tab {

			title: qsTr("Other Settings")

			CustomTabView {

				subtab: true
				tabCount: 2

				Tab {
					title: "Other"
//					TabOther {
//						Connections {
//							target: top
//							onSetData:{
//								setData()
//							}
//							onSaveData:{
//								saveData()
//							}
//						}
//						Component.onCompleted: {
//							setData()
//						}
//					}
				}
				Tab {
					title: qsTr("Filetypes")
//					TabFiletypes {
//						Connections {
//							target: top
//							onSetData:{
//								setData()
//							}
//							onSaveData:{
////								saveData()
//							}
//						}
//						Component.onCompleted: {
//							setData()
//						}
//					}
				}
			}
		}

		Tab {

			title: qsTr("Shortcuts")
//			TabShortcuts {
//				Connections {
//					target: top
//					onSetData:{
//						setData()
//					}
//					onSaveData:{
//						saveData()
//					}
//					onNewShortcut: {
//						addShortcut(cmd, key)
//					}
//					onUpdateShortcut: {
//						updateExistingShortcut(cmd, key, id)
//					}
//					onNewMouseShortcut: {
//						addMouseShortcut(cmd, key)
//					}
//					onUpdateMouseShortcut: {
//						updateExistingMouseShortcut(cmd, key, id)
//					}
//					onUpdateTheCommand: {
//						updateCommand(id, close, mouse, keys, cmd)
//					}
//					onReloadShortcuts: {
//						setData()
//					}
//				}
//				Component.onCompleted: {
//					setData()
//				}
//			}

		}

	}

	// Line between settings and buttons
	Rectangle {

		id: sep

		x: 0
		y: butrow.y-1
		height: 1
		width: parent.width

		color: colour.linecolour

	}

	// A rectangle holding the three buttons at the bottom
	Rectangle {

		id: butrow

		x: 0
		y: parent.height-40
		width: parent.width
		height: 40

		color: "#00000000"

		// Button to restore default settings - bottom left
		CustomButton {

			id: restoredefault

			x: 5
			y: 5
			height: parent.height-10

			text: qsTr("Restore Default Settings")

		}

		// Button to exit without saving - bottom right
		CustomButton {

			id: exitnosave

			x: parent.width-width-10
			y: 5
			height: parent.height-10

			text: qsTr("Exit and Discard Changes")

			onClickedButton: {
				setData_restore()
				hideSettings()
			}

		}

		// Button to exit with saving - bottom right, next to exitnosave button
		CustomButton {

			id: exitsave

			x: exitnosave.x-width-10
			y: 5
			height: parent.height-10

			text: qsTr("Save Changes and Exit")

			onClickedButton: {
				saveData()
				hideSettings()
			}

		}

	}

	CustomConfirm {
		fillAnchors: settings_top
		id: confirmclean
		header: qsTr("Clean Database")
		description: qsTr("Do you really want to clean up the database?") + "<br><br>" + qsTr("This removes all obsolete thumbnails, thus possibly making PhotoQt a little faster.") + "<bR><br>" + qsTr("This process might take a little while.")
		confirmbuttontext: qsTr("Yes, clean is good")
		rejectbuttontext: qsTr("No, don't have time for that")
		onAccepted: cleanDatabase()
	}

	CustomConfirm {
		fillAnchors: settings_top
		id: confirmerase
		header: qsTr("Erase Database")
		description: qsTr("Do you really want to ERASE the entire database?") + "<br><br>" + qsTr("This removes every single item in the database! This step should never really be necessarily. After that, every thumbnail has to be newly re-created.") + "<br>" + qsTr("This step cannot be reversed!")
		confirmbuttontext: qsTr("Yes, get rid of it all")
		rejectbuttontext: qsTr("Nooo, I want to keep it")
		onAccepted: eraseDatabase()
	}

	CustomConfirm {
		fillAnchors: settings_top
		id: confirmdefaultshortcuts
		header: qsTr("Set Default Shortcuts")
		description: qsTr("Are you sure you want to reset the shortcuts to the default set?")
		confirmbuttontext: qsTr("Yes, please")
		rejectbuttontext: qsTr("Nah, don't")
		maxwidth: 400
		onAccepted: {
			verboseMessage("Settings","Setting default shortcuts...")
			var m = getanddostuff.getDefaultShortcuts()
			// We need to change the format for the save function (from Map to List)
			var keys = Object.keys(m)
			var l = []
			for(var i = 0; i < keys.length; ++i)
				l[i] = [m[keys[i]][0],
							(keys[i].slice(0,3) === "[M]"),
							(keys[i].slice(0,3) === "[M]") ? getanddostuff.trim(keys[i].slice(3)) : keys[i],
							m[keys[i]][1]]
			getanddostuff.saveShortcuts(l)
			reloadShortcuts()
		}
	}

	CustomDetectShortcut {
		fillAnchors: settings_top
		id: detectShortcut
		onUpdateCombo: updateComboString(txt)
		onGotKeyCombo: {
			gotCombo(txt)
			newShortcut(cmd, txt)
		}
	}
	CustomDetectShortcut {
		fillAnchors: settings_top
		id: resetShortcut
		onUpdateNewCombo: updateComboString(txt)
		onGotNewKeyCombo: {
			gotCombo(txt)
			updateShortcut(cmd, txt, id)
		}
	}
	CustomExternalCommand {
		fillAnchors: settings_top
		id: setExternalCommand
		onUpdateCommand: {
			updateTheCommand(id,close,mouse,keys,cmd)
		}
	}

	CustomMouseShortcut {
		fillAnchors: settings_top
		id: detectMouseShortcut
		onGotMouseShortcut: newMouseShortcut(cmd, txt)
	}
	CustomMouseShortcut {
		fillAnchors: settings_top
		id: resetMouseShortcut
		onGotNewMouseShortcut: updateMouseShortcut(cmd, txt, id)
	}

	function showSettings() {
		verboseMessage("Settings::showSettings()","Showing Settings...")
		showSettingsAni.start()
		updateDatabaseInfo()
	}
	function hideSettings() {
		verboseMessage("Settings::hideSettings()",confirmclean.visible + "/" + confirmerase.visible + "/" + confirmdefaultshortcuts.visible + "/" + detectShortcut.visible + "/" + resetShortcut.visible)
		if(confirmclean.visible)
			confirmclean.hide()
		else if(confirmerase.visible)
			confirmerase.hide()
		else if(confirmdefaultshortcuts.visible)
			confirmdefaultshortcuts.hide()
		else if(!detectShortcut.visible && !resetShortcut.visible)
			hideSettingsAni.start()
	}

	function detectedKeyCombo(combo) {
		verboseMessage("Settings::detectedKeyCombo()",combo)
		if(detectShortcut.opacity == 1)
			detectShortcut.detectedCombo(combo)
		if(resetShortcut.opacity == 1)
			resetShortcut.detectedCombo(combo)
	}
	function keysReleased() {
		verboseMessage("Settings::keysReleased()",detectShortcut.opacity + "/" + resetShortcut.opacity)
		if(detectShortcut.opacity == 1)
			detectShortcut.keysReleased()
		if(resetShortcut.opacity == 1)
			resetShortcut.keysReleased()
	}

	PropertyAnimation {
		id: hideSettingsAni
		target: settings_top
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStopped: {
			visible = false
			blocked = false
			if(thumbnailBar.currentFile == "")
				openFile()
		}
	}

	PropertyAnimation {
		id: showSettingsAni
		target: settings_top
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
			setData()	// We DO need to call setData() here, as otherwise - once set up - a tab would not be updated (e.g. with changes from quicksettings)
		}
	}


	// This function is only called, when settings have been opened and "closed without saving"
	// In any other case, the actual tabs are ONLY SET UP WHEN OPENED (i.e., as needed) and use
	// the Component.onCompleted signal to make sure that the settings are loaded.
	function setData_restore() {
		setData()
	}

	function nextTab() {
		view.nextTab()
	}
	function prevTab() {
		view.prevTab()
	}

	function saveSettings() { saveData(); hideSettings(); }

}


