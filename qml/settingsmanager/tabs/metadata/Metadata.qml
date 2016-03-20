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
			title: qsTr("Meta Information")
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

		var items;

		if(getanddostuff.isExivSupportEnabled())

			items = [["filesize",qsTr("Filesize"), settings.exiffilesize],
						["dimensions",qsTr("Dimensions"), settings.exifdimensions],
						["make",qsTr("Make"), settings.exifmake],
						["model",qsTr("Model"),settings.exifmodel],
						["software",qsTr("Software"),settings.exifsoftware],
						["time",qsTr("Time Photo was Taken"),settings.exifphototaken],
						["exposure",qsTr("Exposure Time"),settings.exifexposuretime],
						["flash",qsTr("Flash"),settings.exifflash],
						["iso","ISO",settings.exifiso],
						["scenetype",qsTr("Scene Type"),settings.exifscenetype],
						["focal",qsTr("Focal Length"),settings.exifflength],
						["fnumber",qsTr("F-Number"),settings.exiffnumber],
						["light",qsTr("Light Source"),settings.exiflightsource],
						["keywords",qsTr("Keywords"),settings.iptckeywords],
						["location",qsTr("Location"),settings.iptclocation],
						["copyright",qsTr("Copyright"),settings.iptccopyright],
						["gps",qsTr("GPS Position"),settings.exifgps]]

		else
			items = [["filesize",qsTr("Filesize"), settings.exiffilesize],
						["dimensions",qsTr("Dimensions"), settings.exifdimensions]]

		grid.metadataitems = items

	}

	function saveData() {

		settings.exiffilesize = grid.metadachecked["filesize"]
		settings.exifdimensions = grid.metadachecked["dimensions"]
		if(getanddostuff.isExivSupportEnabled()) {
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
		} else {
			// If PhotoQt was compiled WITHOUT Exiv2 support, we set the setting values to true,
			// so that if a version is installed/compiled WITH support, they are enabled by default
			settings.exifmake = true
			settings.exifmodel = true
			settings.exifsoftware = true
			settings.exifphototaken = true
			settings.exifexposuretime = true
			settings.exifflash = true
			settings.exifiso = true
			settings.exifscenetype = true
			settings.exifflength = true
			settings.exiffnumber = true
			settings.exiflightsource = true
			settings.iptckeywords = true
			settings.iptclocation = true
			settings.iptccopyright = true
			settings.exifgps = true
		}

	}

}
