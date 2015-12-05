import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: title
			title: "What Information"
			helptext: qsTr("PhotoQt can display a number of information about the image (often called 'Exif data'). However, you might not be interested in all of them, hence you can choose to disable some of them here.")

		}

		EntrySetting {

			id: entry

			property var metadataitems: [["make","Make"],
										["model","Model"],
										["software","Software"],
										["time","Time Photo was Taken"],
										["exposure","Exposure Time"],
										["flash","Flash"],
										["iso","ISO"],
										["scenetype","Scene Type"],
										["focal","Focal Length"],
										["fnumber","F-Number"],
										["light","Light Source"],
										["keywords","Keywords"],
										["location","Location"],
										["copyright","Copyright"],
										["gps","GPS Position"]]
			property var metadachecked: {"make" : false,
										 "model" : false,
										 "software" : false,
										 "time" : false,
										 "exposure" : false,
										 "flash" : false,
										 "iso" : false,
										 "scenetype" : false,
										 "focal" : false,
										 "fnumber" : false,
										 "light" : false,
										 "keywords" : false,
										 "location" : false,
										 "copyright" : false,
										 "gps" : false }

			Row {

				spacing: 10

				Rectangle {
					id: but
					color: "transparent"
					width: childrenRect.width
					height: childrenRect.height
					y: (parent.height-height)/2
					Column {

						spacing: 10

						CustomButton {
							id: select
							text: "Select all"
							onClickedButton:
								checkAllTiles(true)
						}
						CustomButton {
							id: deselect
							text: "Deselect all"
							onClickedButton:
								checkAllTiles(false)
						}
						Component.onCompleted: {
							var w = Math.max(select.width,deselect.width)
							select.width = w
							deselect.width = w
						}

					}
				}

				GridLayout {

					id: grid
					property int w: item_top.width-title.width-title.x-but.width
					width: columns * (filesize.width+columnSpacing)
					columns: ( 9*(filesize.width+columnSpacing) <= (w-10*columnSpacing)
									? 9 : (6*(filesize.width+columnSpacing) <= (w-7*columnSpacing)
												? 6 : 4) )
					clip: true
					rowSpacing: 3
					columnSpacing: 5

					MetadataTile { id: filesize; text: qsTr("Filesize"); }
					MetadataTile { id: dimensions; text: qsTr("Dimensions"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: make; text: qsTr("Make"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: model; text: qsTr("Model"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: software; text: qsTr("Software"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: timephototaken; text: qsTr("Time Photo was Taken"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: exposuretime; text: qsTr("Exposure Time"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: flash; text: qsTr("Flash"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: iso; text: qsTr("ISO"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: scenetype; text: qsTr("Scene Type"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: focallength; text: qsTr("Focal Length"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: fnumber; text: qsTr("F-Number"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: lightsource; text: qsTr("Light Source"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: keywords; text: qsTr("Keywords"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: location; text: qsTr("Location"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: copyright; text: qsTr("Copyright"); }
					MetadataTile { enabled: getanddostuff.isExivSupportEnabled(); id: gps; text: qsTr("GPS Position"); }

				}

			}

		}

	}

	function checkAllTiles(checked) {

		for(var i = 0; i < grid.children.length; ++i) {
			grid.children[i].checked = checked
		}

	}

	function setData() {
		filesize.checked = settings.exiffilesize
		dimensions.checked = settings.exifdimensions
		make.checked = settings.exifmake
		model.checked = settings.exifmodel
		software.checked = settings.exifsoftware
		timephototaken.checked = settings.exifphototaken
		exposuretime.checked = settings.exifexposuretime
		flash.checked = settings.exifflash
		iso.checked = settings.exifiso
		scenetype.checked = settings.exifscenetype
		focallength.checked = settings.exifflength
		fnumber.checked = settings.exiffnumber
		lightsource.checked = settings.exiflightsource
		keywords.checked = settings.iptckeywords
		location.checked = settings.iptclocation
		copyright.checked = settings.iptccopyright
		gps.checked = settings.exifgps
	}

	function saveData() {

		settings.exiffilesize = filesize.checked
		settings.exifdimensions = dimensions.checked
		settings.exifmake = make.checked
		settings.exifmodel = model.checked
		settings.exifsoftware = software.checked
		settings.exifphototaken = timephototaken.checked
		settings.exifexposuretime = exposuretime.checked
		settings.exifflash = flash.checked
		settings.exifiso = iso.checked
		settings.exifscenetype = scenetype.checked
		settings.exifflength = focallength.checked
		settings.exiffnumber = fnumber.checked
		settings.exiflightsource = lightsource.checked
		settings.iptckeywords = keywords.checked
		settings.iptclocation = location.checked
		settings.iptccopyright = copyright.checked
		settings.exifgps = gps.checked

	}

}
