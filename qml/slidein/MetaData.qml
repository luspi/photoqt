import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: meta

	// Set up model on first load, afetrwards just change data
	property bool imageLoaded: false

	property string orientation: ""

	// Background/Border color
	color: colour.fadein_slidein_bg
	border.width: 1
	border.color: colour.fadein_slidein_border

	// Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
	x: -width-safetyDistanceForSlidein
	y: (background.height-meta.height)/3

	// Adjust size
	width: ((view.width+2*radius < 350) ? 350 : view.width+2*radius)
	height: ((imageLoaded) ? (view.contentHeight > width/2 ? view.contentHeight : width/2) : width)+2*check.height+2*spacing.height

	// Corner radius
	radius: global_element_radius

	// Label at first start-up
	Text {

		anchors.fill: parent

		color: colour.bg_label

		visible: !imageLoaded && !unsupportedLabel.visible && !invalidLabel.visible
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
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
		text: qsTr("Invalid File")

	}

	ListView {

		id: view

		x: meta.radius+10
		y: radius

		width: childrenRect.width
		height: meta.height-2*check.height-2*spacing.height

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
		y: view.height+view.y+spacing.height+3
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
				settingssession.setValue("metadatakeepopen",check.checkedButton)
		}
		CustomCheckBox {
			id: check_enable
			textOnRight: true
			anchors.left: parent.left
			anchors.leftMargin: meta.radius+5
			fsize: 8
			checkedButton: settings.exifenablemousetriggering
			textColour: getanddostuff.addAlphaToColor(colour.text,100)
			text: qsTr("Enable Mouse Trigger")
			onButtonCheckedChanged:
				settings.exifenablemousetriggering = checkedButton
		}
	}
	function uncheckCheckbox() { check.checkedButton = false; }
	function checkCheckbox() { check.checkedButton = true; }
	function uncheckEnableMetadataCheckbox() { check_enable.checkedButton = false; }
	function checkEnableMetadataCheckbox() { check_enable.checkedButton = true; }

	Component {

		id: deleg

		Rectangle {

			id: rect

			color: "#00000000";
			height: val.height;

			Text {

				id: val;

				visible: imageLoaded
				color: colour.text
				font.pointSize: settings.exiffontsize
				lineHeight: (name == "" ? 0.8 : 1.3);
				textFormat: Text.RichText
				text: name !== "" ? "<b>" + name + "</b>: " + value : ""

				MouseArea {
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

				mod.append({"name" : qsTr("Filesize"), "prop" : "", "value" : d["filesize"], "tooltip" : d["filesize"]})
				if("dimensions" in d)
					mod.append({"name" : qsTr("Dimensions"), "prop" : "", "value" : d["dimensions"], "tooltip" : d["dimensions"]})
				else if("Exif.Photo.PixelXDimension" in d && "Exif.Photo.PixelYDimension" in d) {
					var dim = d["Exif.Photo.PixelXDimension"] + "x" + d["Exif.Photo.PixelYDimension"]
					mod.append({"name" : qsTr("Dimensions"), "prop" : "", "value" : dim, "tooltip" : dim})
				}

				mod.append({"name" : "", "prop" : "", "value" : ""})

				var labels = ["Exif.Image.Make", qsTr("Make"), "",
						"Exif.Image.Model", qsTr("Model"), "",
						"Exif.Image.Software", qsTr("Software"), "",
						"","", "",
						"Exif.Photo.DateTimeOriginal", qsTr("Time Photo was Taken"), "",
						"Exif.Photo.ExposureTime", qsTr("Exposure Time"), "",
						"Exif.Photo.Flash", qsTr("Flash"), "",
						"Exif.Photo.ISOSpeedRatings", qsTr("ISO"), "",
						"Exif.Photo.SceneCaptureType", qsTr("Scene Type"), "",
						"Exif.Photo.FocalLength", qsTr("Focal Length"), "",
						"Exif.Photo.FNumber", qsTr("F Number"), "",
						"Exif.Photo.LightSource", qsTr("Light Source"), "",
						"","", "",
						"Iptc.Application2.Keywords", qsTr("Keywords"), "",
						"Iptc.Application2.City", qsTr("Location"), "",
						"Iptc.Application2.Copyright", qsTr("Copyright"), "",
						"","", "",
						"Exif.GPSInfo.GPSLongitudeRef", qsTr("GPS Position"), "Exif.GPSInfo.GPSLatitudeRef",
						"","",""]


				/*

				Exif.Image.Orientation


				*/

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

		verboseMessage("MetaData::gpsClick()",value)

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

}
