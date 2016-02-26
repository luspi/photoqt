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
			title: qsTr("File Formats") + ":<br>&gt; Raw"
			helptext: qsTr("PhotoQt can open and display most (if not all) raw image formats. Here you can adjust the list of fileformats known to PhotoQt.")

		}

		EntrySetting {

			id: entry

			// the model array
			property var types_raw: [["", "", true]]
			// which item is checked
			property var modeldata: {"" : ""}

			GridView {

				id: grid
				width: item_top.width-title.x-title.width
				height: childrenRect.height
				cellWidth: 300
				cellHeight: 30+spacing*2
				property int spacing: 3

				model: entry.types_raw.length
				delegate: FileTypesTile {
					id: tile
					fileType: entry.types_raw[index][0]
					fileEnding: entry.types_raw[index][1]
					checked: entry.types_raw[index][2]
					width: grid.cellWidth-grid.spacing*2
					x: grid.spacing
					height: grid.cellHeight-grid.spacing*2
					y: grid.spacing

					// Store updates
					Component.onCompleted:
						entry.modeldata[entry.types_raw[index][1]] = checked
					onCheckedChanged:
						entry.modeldata[entry.types_raw[index][1]] = checked
				}

			}

		}

	}

	function setData() {

		verboseMessage("Settings::TabFiletypes::setData()","")

		// Remove data
		entry.types_raw = []

		// storing intermediate results
		var tmp_types_raw = []

		// Get current settings
		var setformats = fileformats.formats_raw

		// Valid fileformats
		var raw = [["Hasselblad", "*.3fr"],
				  ["ARRIFLEX","*.ari"],
				  ["Sony","*.arw","*.srf","*.sr2"],
				  ["Casio","*.bay"],
				  ["Canon","*.crw","*.crr"],
				  ["Phase_one","*.cap","*.liq","*.eip"],
				  ["Kodak","*.dcs","*.dcr","*.drf","*.k25","*.kdc"],
				  ["Adobe","*.dng"],
				  ["Epson","*.erf"],
				  ["Imacon/Hasselblad raw","*.fff"],
				  ["Mamiya","*.mef"],
				  ["Minolta, Agfa","*.mdc"],
				  ["Leaf","*.mos"],
				  ["Minolta, Konica Minolta","*.mrw"],
				  ["Nikon","*.nef","*.nrw"],
				  ["Olympus","*.orf"],
				  ["Pentax","*.pef","*.ptx"],
				  ["Logitech","*.pxn"],
				  ["RED Digital Cinema","*.r3d"],
				  ["Fuji","*.raf"],
				  ["Panasonic","*.raw","*.rw2"],
				  ["Leica","*.raw","*.rwl","*.dng"],
				  ["Rawzor","*.rwz"],
				  ["Samsung","*.srw"],
				  ["Sigma","*.x3f"]
				]

		for(var i = 0; i < raw.length; ++i) {

			// the current file ending
			var cur = raw[i]
			// if it has been found
			var found = true
			// And the file endings composed in string
			var composed = ""

			for(var j = 1; j < cur.length; ++j) {

				// If found, then the current file format is ENabled, if not then it is DISabled
				if(setformats.indexOf(cur[j]) === -1)
					found = false

				// The space aftet eh comma is very important! It is needed when saving data
				if(composed != "") composed += ", "
				composed += cur[j]
			}

			// Add to temporary array
			tmp_types_raw = tmp_types_raw.concat([[cur[0],composed,found]])

		}

		// Set new data
		entry.types_raw = tmp_types_raw

	}

	function saveData() {

		// Storing valid elements
		var tobesaved = []

		// Loop over all data and store checked elements
		for(var ele in entry.modeldata) {
			if(entry.modeldata[ele])
				tobesaved = tobesaved.concat(ele.split(", "))
		}

		// Update data
		fileformats.formats_raw = tobesaved.filter(function(n){ return n !== ""; })

	}

}
