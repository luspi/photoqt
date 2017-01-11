import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: meta

	// Set up model on first load, afetrwards just change data
	property bool imageLoaded: false

	property string orientation: ""

	// Background/Border color
	color: getanddostuff.addAlphaToColor(colour.fadein_slidein_bg,settings.exifopacity)
	border.width: 1
	border.color: colour.fadein_slidein_border

	// Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
	x: -1
	y: -1

	// Adjust size
	width: settings.exifMetadaWindowWidth
	height: parent.height+2

	property int nonFloatWidth: 0

	opacity: 0
	visible: false

	// HEADING OF RECTANGLE
	Text {

		id: heading
		y: 10
		x: (parent.width-width)/2
		font.pointSize: 15
		color: colour.text
		font.bold: true
		text: qsTr("Metadata")

	}

	Rectangle {
		id: spacingbelowheader
		x: 5
		y: heading.y+heading.height+10
		height: 1
		width: parent.width-10
		color: "white"
	}

	// Label at first start-up
	Text {

		anchors.fill: parent

		color: colour.bg_label

		visible: !imageLoaded && !unsupportedLabel.visible && !invalidLabel.visible
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
		wrapMode: Text.WordWrap
		//: This is used in the metadata element on the left
		text: qsTr("No File Loaded")

	}

	Text {

		id: unsupportedLabel

		anchors.fill: parent

		color: colour.bg_label

		visible: false
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
		wrapMode: Text.WordWrap
		//: This is used in the metadata element on the left
		text: qsTr("File Format Not Supported")

	}

	Text {

		id: invalidLabel

		anchors.fill: parent

		color: colour.bg_label

		visible: false
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
		wrapMode: Text.WordWrap
		text: qsTr("Invalid File")

	}

	ListView {

		id: view

		x: 10
		y: spacingbelowheader.y + spacingbelowheader.height + 10

		width: childrenRect.width
		height: parent.height - spacingbelowheader.y-spacingbelowheader.height-20 - check.height-10

		visible: imageLoaded
		model: ListModel { id: mod; }
		delegate: deleg

	}

	Rectangle {
		id: spacing
		width: meta.width
		height: 1
		x: 0
		y: view.height+view.y
		color: colour.linecolour
	}

	Rectangle {
		id: keepopen
		color: "#00000000"
		x: 0
		y: view.height+view.y+spacing.height+3 + 5
		width: meta.width
		CustomCheckBox {
			id: check
			textOnRight: false
			anchors.right: parent.right
			anchors.rightMargin: 5
			fsize: 8
			textColour: getanddostuff.addAlphaToColor(colour.text,100)
			text: qsTr("Keep Open")
			onButtonCheckedChanged:
				updateNonFloatWidth()
		}
	}
	function updateNonFloatWidth() {
		verboseMessage("MetaData::updateNonFloatWidth()",check.checkedButton + " - " + nonFloatWidth + " - " + meta.width)
		if(check.checkedButton)
			nonFloatWidth = meta.width
		else
			nonFloatWidth = 0
	}

	function uncheckCheckbox() { check.checkedButton = false; }
	function checkCheckbox() { check.checkedButton = true; }
	function getButtonState() { return check.checkedButton; }

	Component {

		id: deleg

		Rectangle {

			id: rect

			color: "#00000000";
			height: val.height;
			width: meta.width-view.x*2

			Text {

				id: val;

				visible: imageLoaded
				color: colour.text
				font.pointSize: settings.exiffontsize
				lineHeight: (name == "" ? 0.8 : 1.3);
				textFormat: Text.RichText
				width: parent.width
				wrapMode: Text.WordWrap
				text: name !== "" ? "<b>" + name + "</b>: " + value : ""

				ToolTip {
					text: prop=="Exif.GPSInfo.GPSLongitudeRef" ? qsTr("Click to open GPS position with online map")
									: (name !== "" ? "<b>" + name + "</b><br>" + value : "")
					anchors.fill: parent
					cursorShape: prop == "Exif.GPSInfo.GPSLongitudeRef" ? Qt.PointingHandCursor : Qt.ArrowCursor
					onClicked: {
						if(prop == "Exif.GPSInfo.GPSLongitudeRef")
							gpsClick(value)
					}
				}

			}

		}

	}

	// 'Hide' animation
	PropertyAnimation {
		id: hideMetaData
		target: metaData
		property: "opacity"
		to: 0
		onStopped: {
			if(opacity == 0 && !showMetaData.running)
				visible = false
		}
	}

	PropertyAnimation {
		id: showMetaData
		target:  metaData
		property: "opacity"
		to: 1
		onStarted:
			visible=true
	}



	MouseArea {
		x: parent.width-8
		width: 8
		y: 0
		height: parent.height
		cursorShape: Qt.SplitHCursor
		property int oldMouseX

		onPressed:
			oldMouseX = mouseX

		onReleased: {
			updateNonFloatWidth()
			settings.exifMetadaWindowWidth = parent.width
		}

		onPositionChanged: {
			if (pressed) {
				var w = parent.width + (mouseX - oldMouseX)
				if(w >= 250 && w <= background.width/2)
					parent.width = w
			}
		}
	}


	function setData(d) {

		invalidLabel.visible = false
		unsupportedLabel.visible = false
		view.visible = false

		if(d["validfile"] == "0") {
			verboseMessage("MetaData::setData()","Invalid file")
			invalidLabel.visible = true
		} else {

			if(d["supported"] == "0") {
				verboseMessage("MetaData::setData()","Unsupported file format")
				unsupportedLabel.visible = true
			} else {

				verboseMessage("MetaData::setData()","Setting data")

				orientation = d["Exif.Image.Orientation"]

				view.visible = true

				mod.clear()

				if(settings.exiffilename) {
					var fname = getanddostuff.removePathFromFilename(thumbnailBar.currentFile, false)
					mod.append({"name" : qsTr("Filename"), "prop" : "", "value" : fname, "tooltip" : fname })
				}

				if(settings.exiffilesize)
					mod.append({"name" : qsTr("Filesize"), "prop" : "", "value" : d["filesize"], "tooltip" : d["filesize"]})

				if(settings.exifimagenumber) {
					var pos = (thumbnailBar.currentPos+1) + "/" + thumbnailBar.totalNumberImages
					mod.append({"name" : qsTr("Image") + " #/#", "prop" : "", "value" : pos, "tooltip" : pos })
				}

				if(settings.exifdimensions) {
					if("dimensions" in d)
						mod.append({"name" : qsTr("Dimensions"), "prop" : "", "value" : d["dimensions"], "tooltip" : d["dimensions"]})
					else if("Exif.Photo.PixelXDimension" in d && "Exif.Photo.PixelYDimension" in d) {
						var dim = d["Exif.Photo.PixelXDimension"] + "x" + d["Exif.Photo.PixelYDimension"]
						mod.append({"name" : qsTr("Dimensions"), "prop" : "", "value" : dim, "tooltip" : dim})
					}
				}

				mod.append({"name" : "", "prop" : "", "value" : ""})

				//: The next string refers to Exif image metadata
				var labels = ["Exif.Image.Make", qsTr("Make"), "",
						//: The next string refers to Exif image metadata
						"Exif.Image.Model", qsTr("Model"), "",
						//: The next string refers to Exif image metadata
						"Exif.Image.Software", qsTr("Software"), "",
						"","", "",
						//: The next string refers to Exif image metadata
						"Exif.Photo.DateTimeOriginal", qsTr("Time Photo was Taken"), "",
						//: The next string refers to Exif image metadata
						"Exif.Photo.ExposureTime", qsTr("Exposure Time"), "",
						//: The next string refers to Exif image metadata
						"Exif.Photo.Flash", qsTr("Flash"), "",
						"Exif.Photo.ISOSpeedRatings", qsTr("ISO"), "",
						//: The next string refers to Exif image metadata
						"Exif.Photo.SceneCaptureType", qsTr("Scene Type"), "",
						//: The next string refers to Exif image metadata
						//: The next string refers to Exif image metadata
						"Exif.Photo.FocalLength", qsTr("Focal Length"), "",
						"Exif.Photo.FNumber", qsTr("F Number"), "",
						//: The next string refers to Exif image metadata
						"Exif.Photo.LightSource", qsTr("Light Source"), "",
						"","", "",
						//: The next string refers to Exif image metadata
						"Iptc.Application2.Keywords", qsTr("Keywords"), "",
						//: The next string refers to Exif image metadata
						"Iptc.Application2.City", qsTr("Location"), "",
						//: The next string refers to Exif image metadata
						"Iptc.Application2.Copyright", qsTr("Copyright"), "",
						"","", "",
						//: The next string refers to Exif image metadata
						"Exif.GPSInfo.GPSLongitudeRef", qsTr("GPS Position"), "Exif.GPSInfo.GPSLatitudeRef",
						"","",""]

				var oneEmpty = false;

				for(var i = 0; i < labels.length; i+=3) {
					if(labels[i] == "" && labels[i+1] == "") {
						if(!oneEmpty) {
							oneEmpty = true
							mod.append({"name" : "", "prop" : "", "value" : "", "tooltip" : ""})
						}
					} else if(d[labels[i]] != "" && d[labels[i+1]] != "") {
						oneEmpty = false;
						mod.append({"name" : labels[i+1],
								"prop" : labels[i],
								"value" : d[labels[i]],
								"tooltip" : d[labels[i+2] == "" ? d[labels[i]] : d[labels[i+2]]]})
					}
				}

				view.model = mod
				imageLoaded = true

			}

		}

	}

	function gpsClick(value) {

		verboseMessage("MetaData::gpsClick()",value + " - " + settings.exifgpsmapservice)

		if(settings.exifgpsmapservice == "bing.com/maps")
			Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + value + "&obox=1")
		else if(settings.exifgpsmapservice == "maps.google.com")
			Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + value)
		else {

			// For openstreetmap.org, we need to convert the GPS location into decimal format

			var one = value.split(", ")[0]
			var one_dec = 1*one.split("°")[0] + (1*(one.split("°")[1].split("'")[0]))/60 + (1*(one.split("'")[1].split("''")[0]))/3600
			if(one.indexOf("S") !== -1)
				one_dec *= -1;

			var two = value.split(", ")[1]
			var two_dec = 1*two.split("°")[0] + (1*(two.split("°")[1].split("'")[0]))/60 + (1*(two.split("'")[1].split("''")[0]))/3600
			if(two.indexOf("W") !== -1)
				two_dec *= -1;

			Qt.openUrlExternally("http://www.openstreetmap.org/#map=15/" + "" + one_dec + "/" + two_dec)
		}

	}

	function clear() {
		imageLoaded = false
	}



	function hide() {
		if(!check.checkedButton) {
			if(opacity != 0) verboseMessage("MetaData::hide()", opacity + " to 0")
			hideMetaData.start()
		}
	}
	function show() {
		if(opacity != 1) verboseMessage("MetaData::show()", opacity + " to 1")
		showMetaData.start()
	}

	function clickInMetaData(pos) {
		var ret = meta.contains(meta.mapFromItem(toplevel,pos.x,pos.y))
		verboseMessage("MetaData::clickInMetaData()", pos)
		return ret
	}

}
