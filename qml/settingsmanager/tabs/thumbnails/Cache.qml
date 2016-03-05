import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Thumbnail Cache"
			helptext: qsTr("Thumbnails can be cached in two different ways:<br>1) File Caching (following the freedesktop.org standard) or<br>2) Database Caching (better performance and management, default option).") + "<br><br>" + qsTr("Both ways have their advantages and disadvantages:") + "<br>" + qsTr("File Caching is done according to the freedesktop.org standard and thus different applications can share the same thumbnail for the same image file. However, it's not possible to check for obsolete thumbnails (thus this may lead to many unneeded thumbnail files).") + "<br>" + qsTr("Database Caching doesn't have the advantage of sharing thumbnails with other applications (and thus every thumbnails has to be newly created for PhotoQt), but it brings a slightly better performance, and it allows a better handling of existing thumbnails (e.g. deleting obsolete thumbnails).") + "<br><br>" + qsTr("PhotoQt works with either option, though the second way is set as default.") + "<br><br>" + qsTr("Although everybody is encouraged to use at least one of the two options, caching can be completely disabled altogether. However, that does affect the performance and usability of PhotoQt, since thumbnails have to be newly re-created every time they are needed.")

		}

		EntrySetting {

			id: entry

			Row {

				spacing: 10

				CustomCheckBox {

					id: cache
					y: (parent.height-height)/2
					text: qsTr("Enable Cache")

				}

				Rectangle {
					color: "transparent"
					width: 10
					height: 1
				}

				Column {

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

					Rectangle {
						color: "transparent"
						width: 1
						height: 5
					}

					Rectangle {

						width: childrenRect.width
						height: childrenRect.height
						x: (parent.width-width)/2

						color: "#00000000"

						Row {
							spacing: 5
							Text {
								font.pointSize: 10
								color: cache.checkedButton ? colour.text : colour.text_disabled
								Behavior on color { ColorAnimation { duration: 150; } }
								text: qsTr("Database filesize:")
							}
							Text {
								font.pointSize: 10
								id: db_filesize
								color: cache.checkedButton ? colour.text : colour.text_disabled
								Behavior on color { ColorAnimation { duration: 150; } }
								text: "0 KB"
							}
						}
					}


					Rectangle {

						width: childrenRect.width
						height: childrenRect.height
						x: (parent.width-width)/2

						color: "#00000000"

						Row {
							spacing: 5
							Text {
								font.pointSize: 10
								color: cache.checkedButton ? colour.text : colour.text_disabled
								Behavior on color { ColorAnimation { duration: 150; } }
								text: qsTr("Entries in database:")
							}
							Text {
								font.pointSize: 10
								id: db_entries
								color: cache.checkedButton ? colour.text : colour.text_disabled
								Behavior on color { ColorAnimation { duration: 150; } }
								text: "0"
							}
						}

					}

				}

				Rectangle {
					color: "transparent"
					width: 10
					height: 1
				}

				CustomButton {

					id: cleanup
					height: 35
					y: (parent.height-height)/2
					text: qsTr("CLEAN UP")

					enabled: cache.checkedButton

					onClickedButton: confirmclean.show()

				}

				CustomButton {

					id: erase
					height: 35
					y: (parent.height-height)/2
					text: qsTr("ERASE")

					enabled: cache.checkedButton

					onClickedButton: confirmerase.show()

				}


			}

		}

	}

	function updateDatabaseInfo() {

		var filesize = thumbnailmanagement.getDatabaseFilesize()
		if(filesize < 1024)
			db_filesize.text = filesize + " KB"
		else
			db_filesize.text = Math.round(filesize*100/1024)/100 + " MB"
		db_entries.text = thumbnailmanagement.getNumberDatabaseEntries()

	}

	function setData() {
		cache.checkedButton = settings.thumbnailcache
		cache_file.checked = settings.thbcachefile
		cache_db.checked = !settings.thbcachefile
		updateDatabaseInfo()
	}

	function saveData() {
		settings.thumbnailcache = cache.checkedButton
		settings.thbcachefile = cache_file.checked
	}

}
