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
			title: qsTr("File Formats") + ":<br>&gt; Qt"
			helptext: qsTr("These are the file types natively supported by Qt. Make sure, that you'll have the required libraries installed (e.g., qt5-imageformats), otherwise some of them might not work on your system.<br>If a file ending for one of the formats is missing, you can add it below, formatted like '*.ending' (without single quotation marks), multiple entries seperated by commas.")

		}

		EntrySetting {

			id: entry

			// the model array
			property var types_qt: [["", "", true]]
			// which item is checked
			property var modeldata: {"" : ""}

			GridView {

				id: grid
				width: item_top.width-title.x-title.width
				height: childrenRect.height
				cellWidth: 300
				cellHeight: 30+spacing*2
				property int spacing: 3

				model: entry.types_qt.length
				delegate: FileTypesTile {
					id: tile
					fileType: entry.types_qt[index][0]
					fileEnding: entry.types_qt[index][1]
					checked: entry.types_qt[index][2]
					width: grid.cellWidth-grid.spacing*2
					x: grid.spacing
					height: grid.cellHeight-grid.spacing*2
					y: grid.spacing

					// Store updates
					Component.onCompleted:
						entry.modeldata[entry.types_qt[index][1]] = checked
					onCheckedChanged:
						entry.modeldata[entry.types_qt[index][1]] = checked
				}

			}

		}

	}

	function setData() {

		verboseMessage("Settings::TabFiletypes::setData()","")

		// Remove data
		entry.types_qt = []

		// storing intermediate results
		var tmp_types_qt = []

		// Get current settings
		var setformats = fileformats.formatsQtEnabled

		// Valid fileformats
		var qt = [["Bitmap", "*.bmp", "*.bitmap"],
			["Direct Draw Surface", "*.dds"],
			["Graphics Interchange Format (GIF)", "*.gif"],
			["Microsoft Icon", "*.ico", "*.icns"],
			["Joint Photographic Experts Group (JPEG)", "*.jpg", "*.jpeg"],
			["JPEG-2000", "*.jpeg2000", "*.jp2", "*.jpc", "*.j2k", "*.jpf", "*.jpx", "*.jpm", "*.mj2"],
			["Multiple-image Network Graphics", "*.mng"],
			["Portable Network Graphics (PNG)", "*.png"],
			["Portable bitmap", "*.pbm"],
			["Portable graymap", "*.pgm"],
			["Portable pixmap", "*.ppm"],
			["Scalable Vector Graphics (SVG)", "*.svg", "*.svgz"],
			["Tagged Image File Format (TIFF)", "*.tif", "*.tiff"],
			["Wireless bitmap", "*.wbmp", "*.webp"],
			["X Windows system bitmap", "*.xbm"],
			["X Windows system pixmap", "*.xpm"]]

		for(var i = 0; i < qt.length; ++i) {

			// the current file ending
			var cur = qt[i]
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
			tmp_types_qt = tmp_types_qt.concat([[cur[0],composed,found]])

		}

		// Set new data
		entry.types_qt = tmp_types_qt

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
		fileformats.formatsQtEnabled = tobesaved.filter(function(n){ return n !== ""; })

	}

}
