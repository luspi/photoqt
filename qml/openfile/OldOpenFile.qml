import QtQuick 2.2
import QtQuick.Dialogs 1.0

FileDialog {

	id: fileDialog

	title: "Select an image file"
	folder: getanddostuff.getHomeDir()

	onAccepted:
		reloadDirectory(fileDialog.fileUrl,"")

	function show() {
		updateNameFilters()
		if(thumbnailBar.currentFile != "")
			folder = getanddostuff.removeFilenameFromPath(thumbnailBar.currentFile)
		else
			folder = getanddostuff.getHomeDir()
		visible = true
	}

	function updateNameFilters() {

		var all = "All supported images ("
		var qt = "Qt images ("
		var gm = "GraphicsMagick ("
		var raw = "LibRaw ("

		var first = true
		for(var t in fileformats.formats_qt) {
			if(!first) {
				qt += " "
				all += " "
			}
			first = false
			qt += fileformats.formats_qt[t];
			all += fileformats.formats_qt[t];
		}

		first = true
		for(var t in fileformats.formats_gm) {
			if(!first) {
				gm += " "
				all += " "
			}
			first = false
			gm += fileformats.formats_gm[t];
			all += fileformats.formats_gm[t];
		}
		for(var t in fileformats.formats__gm_ghostscript) {
			if(!first) {
				gm += " "
				all += " "
			}
			first = false
			gm += fileformats.formats_gm_ghostscript[t];
			all += fileformats.formats_gm_ghostscript[t];
		}

		first = true
		for(var t in fileformats.formats_raw) {
			if(!first) {
				raw += " "
				all += " "
			}
			first = false
			raw += fileformats.formats_raw[t];
			all += fileformats.formats_raw[t];
		}

		first = true
		for(var t in fileformats.formats_untested) {
			if(!first)
				all += " "
			first = false
			all += fileformats.formats_untested[t];
		}

		first = true
		for(var t in fileformats.formats_extras) {
			if(!first)
				all += " "
			first = false
			all += fileformats.formats_extras[t];
		}

		all += ")"
		qt += ")"
		gm += ")"
		raw += ")"

		fileDialog.nameFilters = [all,qt,gm,raw]

	}
}
