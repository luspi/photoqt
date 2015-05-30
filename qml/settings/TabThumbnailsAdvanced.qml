import QtQuick 2.3
import QtQuick.Controls 1.2

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

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+50
		contentWidth: tab.width

		boundsBehavior: Flickable.StopAtBounds

		Column {

			id: maincol

			spacing: 15

			/**********
			* HEADER *
			**********/

			Rectangle {
				id: header
				width: flickable.width
				height: childrenRect.height
				color: "#00000000"
				Text {
					color: colour.text
					font.pointSize: global_fontsize_title
					font.bold: true
					text: qsTr("Advanced Settings")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/******************
			* THUMBNAIL EDGE *
			******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Change Thumbnail Position") + "</h2><br>" + qsTr("Per default the bar with the thumbnails is shown at the lower edge. However, some might find it nice and handy to have the thumbnail bar at the upper edge, so that's what can be changed here.")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					ExclusiveGroup { id: edgegroup; }

					CustomRadioButton {
						id: loweredge
						text: qsTr("Show at lower edge")
						checked: true
						exclusiveGroup: edgegroup
					}

					CustomRadioButton {
						id: upperedge
						text: qsTr("Show at upper edge")
						exclusiveGroup: edgegroup
					}

				}

			}


			/**********************
			* FILENAME/DIMENSION *
			**********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Filename? Dimension? Or both?") + "</h2><br>" + qsTr("When thumbnails are displayed at the top/bottom, PhotoQt usually writes the filename on them (if not disabled). You can also use the slider below to adjust the font size.")
//				text: "<h2>" + qsTr("Filename? Dimension? Or both?") + "</h2><br>" + qsTr("When thumbnails are displayed at the top/bottom, PhotoQt usually writes the filename on them. But also the dimension of the image can be written on it. Or also both or none. You can use the slider below to adjust the font size.")

			}

			/* WHICH ONE? */

			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomCheckBox {
						id: writefilename
						text: qsTr("Write Filename")
					}

					// CURRENTLY UNAVAILABLE
//					CustomCheckBox {
//						id: writedimension
//						text: qsTr("Write Dimension")
//					}

				}

			}

			/* FONT SIZE? */

			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomSlider {

						id: fontsize_slider

						width: 400

						minimumValue: 5
						maximumValue: 20

						value: fontsize_spinbox.value
						stepSize: 1
						scrollStep: 1
						tickmarksEnabled: true

						enabled: writefilename.checkedButton /*|| writedimension.checkedButton*/

					}

					CustomSpinBox {

						id: fontsize_spinbox

						width: 75

						minimumValue: 5
						maximumValue: 20

						value: fontsize_slider.value

						enabled: writefilename.checkedButton /*|| writedimension.checkedButton*/

					}

				}

			}



			/******************
			* FILENAME ONLY? *
			******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Use file-name-only Thumbnails") + "</h2><br>" + qsTr("If you don't want PhotoQt to always load the actual image thumbnail in the background, but you still want to have something for better navigating, then you can set a file-name-only thumbnail, i.e. PhotoQt wont load any thumbnail images but simply puts the file name into the box. You can also adjust the font size of this text.")

			}

			CustomCheckBox {
				id: filenameonly
				text: qsTr("Use filename-only thumbnail")
				x: (flickable.width-width)/2
			}


			/* FONT SIZE? */

			Rectangle {

			color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomSlider {

						id: filenameonly_fontsize_slider

						width: 400

						minimumValue: 5
						maximumValue: 20

						enabled: filenameonly.checkedButton

						value: filenameonly_fontsize_spinbox.value
						stepSize: 1
						scrollStep: 1
						tickmarksEnabled: true

					}

					CustomSpinBox {

						id: filenameonly_fontsize_spinbox

						width: 75

						minimumValue: 5
						maximumValue: 20

						enabled: filenameonly.checkedButton

						value: filenameonly_fontsize_slider.value

					}

				}

			}


			/**********************
			* DISABLE THUMBNAILS *
			**********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Disable Thumbnails") + "</h2><br>" + qsTr("If you just don't need or don't want any thumbnails whatsoever, then you can disable them here completely. This option can also be toggled remotely via command line (run 'photoqt --help' for more information on that). This might increase the speed of PhotoQt a good bit, however, navigating through a folder might be a little harder without thumbnails.")

			}

			CustomCheckBox {

				id: disable

				text: qsTr("Disable Thumbnails altogether")

				x: (flickable.width-width)/2

			}


			/*******************
			* THUMBNAIL CACHE *
			*******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Thumbnail Cache") + "</h2><br>" + qsTr("Thumbnails can be cached in two different ways:<br>1) File Caching (following the freedesktop.org standard) or<br>2) Database Caching (better performance and management, default option).") + "<br><br>" + qsTr("Both ways have their advantages and disadvantages:") + "<br>" + qsTr("File Caching is done according to the freedesktop.org standard and thus different applications can share the same thumbnail for the same image file. However, it's not possible to check for obsolete thumbnails (thus this may lead to many unneeded thumbnail files).") + "<br>" + qsTr("Database Caching doesn't have the advantage of sharing thumbnails with other applications (and thus every thumbnails has to be newly created for PhotoQt), but it brings a slightly better performance, and it allows a better handling of existing thumbnails (e.g. deleting obsolete thumbnails).") + "<br><br>" + qsTr("PhotoQt works with either option, though the second way is set as default.") + "<br><br>" + qsTr("Although everybody is encouraged to use at least one of the two options, caching can be completely disabled altogether. However, that does affect the performance and usability of PhotoQt, since thumbnails have to be newly re-created every time they are needed.")

			}

			Rectangle {

				id: cacherect

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				color: "#00000000"

				Column {

					spacing: 15

					CustomCheckBox {

						id: cache

						x: (parent.width-width)/2

						text: qsTr("Enable Thumbnail Cache")

					}

					Rectangle {

						width: childrenRect.width
						height: childrenRect.height

						x: (parent.width-width)/2

						color: "#00000000"

						Row {

							spacing: 10

							ExclusiveGroup { id: cachegroup; }

							CustomRadioButton {
								id: cache_file
								text: qsTr("File Caching")
								enabled: cache.checkedButton
								exclusiveGroup: cachegroup
							}
							CustomRadioButton {
								id: cache_db
								text: qsTr("Database Caching")
								enabled: cache.checkedButton
								exclusiveGroup: cachegroup
							}

						}

					}

					Column {

						Rectangle {

							width: childrenRect.width
							height: childrenRect.height

							color: "#00000000"

							x: (cacherect.width-width)/2

							Row {
								spacing: 5
								Text {
									font.pointSize: global_fontsize_normal
									color: cache.checkedButton ? colour.text : colour.disabled
									text: qsTr("Current database filesize:")
								}
								Text {
									font.pointSize: global_fontsize_normal
									id: db_filesize
									color: cache.checkedButton ? colour.text : colour.disabled
									text: "0 KB"
								}
							}
						}


						Rectangle {

							width: childrenRect.width
							height: childrenRect.height

							color: "#00000000"

							x: (cacherect.width-width)/2

							Row {
								spacing: 5
								Text {
									font.pointSize: global_fontsize_normal
									color: cache.checkedButton ? colour.text : colour.disabled
									text: qsTr("Entries in database:")
								}
								Text {
									font.pointSize: global_fontsize_normal
									id: db_entries
									color: cache.checkedButton ? colour.text : colour.disabled
									text: "0"
								}
							}
						}

					}

					Row {

						spacing: 10

						CustomButton {

							id: cleanup
							height: 35
							text: qsTr("CLEAN UP database")

							enabled: cache.checkedButton

							onClickedButton: confirmclean.show()

						}

						CustomButton {

							id: erase
							height: 35
							text: qsTr("ERASE database")

							enabled: cache.checkedButton

							onClickedButton: confirmerase.show()

						}

					}

				}

			}

		}

	}

	function setData() {

		loweredge.checked = (settings.thumbnailposition === "Bottom")
		upperedge.checked = (settings.thumbnailposition === "Top")

		writefilename.checkedButton = settings.thumbnailWriteFilename
//		writedimension.checkedButton = settings.thumbnailWriteResolution
		fontsize_slider.value = settings.thumbnailFontSize

		filenameonly.checkedButton = settings.thumbnailFilenameInstead
		filenameonly_fontsize_slider.value = settings.thumbnailFilenameInsteadFontSize

		disable.checkedButton = settings.thumbnailDisable

		cache.checkedButton = settings.thumbnailcache
		cache_file.checked = settings.thbcachefile
		cache_db.checked = !settings.thbcachefile

		// Update db info
		updateDatabaseInfo()

	}

	function saveData() {

		if(loweredge.checked) settings.thumbnailposition = "Bottom"
		else settings.thumbnailposition = "Top"

		settings.thumbnailWriteFilename = writefilename.checkedButton
//		settings.thumbnailWriteResolution = writedimension.checkedButton
		settings.thumbnailFontSize = fontsize_slider.value

		settings.thumbnailFilenameInstead = filenameonly.checkedButton
		settings.thumbnailFilenameInsteadFontSize = filenameonly_fontsize_slider.value

		settings.thumbnailDisable = disable.checkedButton

		settings.thumbnailcache = cache.checkedButton
		settings.thbcachefile = cache_file.checked

	}

	function updateDatabaseInfo() {

		var filesize = thumbnailmanagement.getDatabaseFilesize()
		db_filesize.text = filesize + " KB  (" + Math.round(filesize*100/1024)/100 + " MB)"
		db_entries.text = thumbnailmanagement.getNumberDatabaseEntries()

	}

	function eraseDatabase() {
		thumbnailmanagement.eraseDatabase()
		updateDatabaseInfo()
	}

	function cleanDatabase() {
		thumbnailmanagement.cleanDatabase()
		updateDatabaseInfo()
	}

}
