import QtQuick 2.3
import QtQuick.Controls 1.2

import "./"
import "../elements"

Rectangle {

	id: tabrect

	// Positioning and basic look
	anchors.fill: background
	color: colour_fadein_bg

	// Invisible at startup
	visible: false
	opacity: 0

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

	signal updateTheCommand(var id, var close, var mouse, var keys, var cmd)

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
	}

	CustomTabView {

		id: view

		x: 0
		y: 0
		width: parent.width
		height: parent.height-butrow.height

		tabCount: 5     // We currently have 5 tabs in the settings

		Tab {

			title: "Look and Feel"

			CustomTabView {

				id: subtab1

				subtab: true   // this is a subtab
				tabCount: 2    // and we have 2 tabs in it



				Tab {

					title: "Basic"

					TabLookAndFeelBasic {
						Connections {
							target: tabrect
							onSetData:{
								setData()
							}
							onSaveData:{
								saveData()
							}
						}
						Component.onCompleted: {
							setData()
						}
					}

				}

				Tab {

					title: "Advanced"

					TabLookAndFeelAdvanced {
						Connections {
							target: tabrect
							onSetData:{
								setData()
							}
							onSaveData:{
								saveData()
							}
						}
						Component.onCompleted: {
							setData()
						}
					}
				}
			}
		}

		Tab {

			title: "Thumbnails"

			CustomTabView {

				subtab: true
				tabCount: 2

				Tab {

					title: "Basic"

					TabThumbnailsBasic {
						Connections {
							target: tabrect
							onSetData:{
								setData()
							}
							onSaveData:{
								saveData()
							}
						}
						Component.onCompleted: {
							setData()
						}
					}

				}
				Tab {
					title: "Advanced"
					TabThumbnailsAdvanced {
						Connections {
							target: tabrect
							onSetData:{
								setData()
							}
							onSaveData:{
								saveData()
							}
							onCleanDatabase: {
								cleanDatabase()
							}
							onEraseDatabase: {
								eraseDatabase()
							}
							onUpdateDatabaseInfo: {
								updateDatabaseInfo()
							}
						}

						Component.onCompleted: {
							setData()
						}
					}
				}
			}
		}

		Tab {

			title: "Metadata"
			TabDetails {
				Connections {
					target: tabrect
					onSetData:{
						setData()
					}
					onSaveData:{
						saveData()
					}
				}
				Component.onCompleted: {
					setData()
				}
			}

		}

		Tab {

			title: "Other Settings"

			CustomTabView {

				subtab: true
				tabCount: 2

				Tab {
					title: "Other"
					TabOther {
						Connections {
							target: tabrect
							onSetData:{
								setData()
							}
							onSaveData:{
								saveData()
							}
						}
						Component.onCompleted: {
							setData()
						}
					}
				}
				Tab {
					title: "Filetypes"
					TabFiletypes {
						Connections {
							target: tabrect
							onSetData:{
								setData()
							}
							onSaveData:{
//								saveData()
							}
						}
						Component.onCompleted: {
							setData()
						}
					}
				}
			}
		}

		Tab {

			title: "Shortcuts"
			TabShortcuts {
				Connections {
					target: tabrect
					onSetData:{
						setData()
					}
					onSaveData:{
						saveData()
					}
					onNewShortcut: {
						addShortcut(cmd, key)
					}
					onUpdateShortcut: {
						updateExistingShortcut(cmd, key, id)
					}
					onNewMouseShortcut: {
						addMouseShortcut(cmd, key)
					}
					onUpdateMouseShortcut: {
						updateExistingMouseShortcut(cmd, key, id)
					}
					onUpdateTheCommand: {
						updateCommand(id, close, mouse, keys, cmd)
					}
				}
				Component.onCompleted: {
					setData()
				}
			}

		}

	}

	// Line between settings and buttons
	Rectangle {

		id: sep

		x: 0
		y: butrow.y-1
		height: 1
		width: parent.width

		color: colour_linecolour

	}

	// A rectangle holding the three buttons at the bottom
	Rectangle {

		id: butrow

		x: 0
		y: parent.height-40
		width: parent.width
		height: 40

		color: "#33000000"

		// Button to restore default settings - bottom left
		CustomButton {

			id: restoredefault

			x: 5
			y: 5
			height: parent.height-10

			text: "Restore Default Settings"

		}

		// Button to exit without saving - bottom right
		CustomButton {

			id: exitnosave

			x: parent.width-width-10
			y: 5
			height: parent.height-10

			text: "Exit and Discard Changes"

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

			text: "Save Changes and Exit"

			onClickedButton: {
				saveData()
				hideSettings()
			}

		}

	}

	CustomConfirm {
		fillAnchors: tabrect
		id: confirmclean
		header: "Clean Database"
		description: "Do you really want to clean up the database?<br><br>This removes all obsolete thumbnails, thus possibly making PhotoQt a little faster.<bR><br>This process might take a little while."
		confirmbuttontext: "Yes, clean is good"
		rejectbuttontext: "No, don't have time for that"
		onAccepted: cleanDatabase()
	}

	CustomConfirm {
		fillAnchors: tabrect
		id: confirmerase
		header: "Erase Database"
		description: "Do you really want to ERASE the entire database?<br><br>This removes every single item in the database! This step should never really be necessarily. After that, every thumbnail has to be newly re-created.<br>This step cannot be reversed!"
		confirmbuttontext: "Yes, get rid of it all"
		rejectbuttontext: "Nooo, I want to keep it"
		onAccepted: eraseDatabase()
	}

	CustomDetectShortcut {
		fillAnchors: tabrect
		id: detectShortcut
		onUpdateCombo: updateComboString(txt)
		onGotKeyCombo: {
			gotCombo(txt)
			newShortcut(cmd, txt)
		}
	}
	CustomDetectShortcut {
		fillAnchors: tabrect
		id: resetShortcut
		onUpdateNewCombo: updateComboString(txt)
		onGotNewKeyCombo: {
			gotCombo(txt)
			updateShortcut(cmd, txt, id)
		}
	}
	CustomExternalCommand {
		fillAnchors: tabrect
		id: setExternalCommand
		onUpdateCommand: {
			updateTheCommand(id,close,mouse,keys,cmd)
		}
	}

	CustomMouseShortcut {
		fillAnchors: tabrect
		id: detectMouseShortcut
		onGotMouseShortcut: newMouseShortcut(cmd, txt)
	}
	CustomMouseShortcut {
		fillAnchors: tabrect
		id: resetMouseShortcut
		onGotNewMouseShortcut: updateMouseShortcut(cmd, txt, id)
	}

	function showSettings() {
		showAboutAni.start()
		updateDatabaseInfo()
	}
	function hideSettings() {
		if(confirmclean.visible)
			confirmclean.hide()
		else if(confirmerase.visible)
			confirmerase.hide()
		else if(!detectShortcut.visible && !resetShortcut.visible)
			hideAboutAni.start()
	}

	function detectedKeyCombo(combo) {
		if(detectShortcut.opacity == 1)
			detectShortcut.detectedCombo(combo)
		if(resetShortcut.opacity == 1)
			resetShortcut.detectedCombo(combo)
	}
	function keysReleased() {
		if(detectShortcut.opacity == 1)
			detectShortcut.keysReleased()
		if(resetShortcut.opacity == 1)
			resetShortcut.keysReleased()
	}

	PropertyAnimation {
		id: hideAboutAni
		target: tabrect
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
			blocked = false
			if(image.url == "")
				openFile()
		}
	}

	PropertyAnimation {
		id: showAboutAni
		target: tabrect
		property: "opacity"
		to: 1
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


