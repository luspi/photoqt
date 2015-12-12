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

			GridView {

				property var metadataitems: [["","",false]]
				property var metadachecked: { "" : "" }

				id: grid
				width: Math.floor((item_top.width-title.width-title.x-parent.parent.spacing-5)/(cellWidth)) * (cellWidth)
				height: childrenRect.height
				cellWidth: 200
				cellHeight: 30 + 2*spacing
				property int spacing: 3

				model: metadataitems.length
				delegate: MetadataTile {
					id: tile
					text: grid.metadataitems[index][1]
					checked: grid.metadataitems[index][2]
					width: grid.cellWidth-grid.spacing*2
					x: grid.spacing
					height: grid.cellHeight-grid.spacing*2
					y: grid.spacing
					onCheckedChanged:
						grid.metadachecked[grid.metadataitems[index][0]] = checked
					Component.onCompleted:
						grid.metadachecked[grid.metadataitems[index][0]] = checked
				}


			}

		}

	}

	function setData() {

		var items = [["filesize","Filesize", settings.exiffilesize],
					["dimensions","Dimensions", settings.exifdimensions],
					["make","Make", settings.exifmake],
					["model","Model",settings.exifmodel],
					["software","Software",settings.exifsoftware],
					["time","Time Photo was Taken",settings.exifphototaken],
					["exposure","Exposure Time",settings.exifexposuretime],
					["flash","Flash",settings.exifflash],
					["iso","ISO",settings.exifiso],
					["scenetype","Scene Type",settings.exifscenetype],
					["focal","Focal Length",settings.exifflength],
					["fnumber","F-Number",settings.exiffnumber],
					["light","Light Source",settings.exiflightsource],
					["keywords","Keywords",settings.iptckeywords],
					["location","Location",settings.iptclocation],
					["copyright","Copyright",settings.iptccopyright],
					["gps","GPS Position",settings.exifgps]]

		grid.metadataitems = items

	}

	function saveData() {

		settings.exiffilesize = grid.metadachecked["filesize"]
		settings.exifdimensions = grid.metadachecked["dimensions"]
		settings.exifmake = grid.metadachecked["make"]
		settings.exifmodel = grid.metadachecked["model"]
		settings.exifsoftware = grid.metadachecked["software"]
		settings.exifphototaken = grid.metadachecked["time"]
		settings.exifexposuretime = grid.metadachecked["exposure"]
		settings.exifflash = grid.metadachecked["flash"]
		settings.exifiso = grid.metadachecked["iso"]
		settings.exifscenetype = grid.metadachecked["scenetype"]
		settings.exifflength = grid.metadachecked["focal"]
		settings.exiffnumber = grid.metadachecked["fnumber"]
		settings.exiflightsource = grid.metadachecked["light"]
		settings.iptckeywords = grid.metadachecked["keywords"]
		settings.iptclocation = grid.metadachecked["location"]
		settings.iptccopyright = grid.metadachecked["copyright"]
		settings.exifgps = grid.metadachecked["gps"]

	}

}
