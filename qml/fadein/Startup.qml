import QtQuick 2.3
import QtQuick.Controls 1.2

import "./"
import "../elements"

Rectangle {

	id: rect

	// Positioning and basic look
	anchors.fill: background
	color: colour.fadein_slidein_bg

	// Invisible at startup
	visible: false
	opacity: 0

	property string type: ""

	// Catch mouse events
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
	}

	// Scrollarea
	Flickable {

		width: rect.width
		height: rect.height-butrect.height

		contentHeight: col.height
		contentWidth: col.width

		clip: true

		// Only vertical though
		flickableDirection: Flickable.VerticalFlick

		Column {

			id: col

			spacing: 15

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// HEADER LOGO
			Image {
				source: "qrc:/img/logo.png"
				x: (rect.width-width)/2
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 10
			}

			// HEADER
			Text {
				color: colour.text
				font.pointSize: 18
				font.bold: true
				wrapMode: Text.WordWrap
				x: 10
				width: rect.width-20
				horizontalAlignment: Text.AlignHCenter
				text: (type == "installed" ? qsTr("PhotoQt was successfully installed") : qsTr("PhotoQt was successfully updated"))
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 10
			}

			// INTRODUCTORY TEXT
			Text {
				color: colour.text
				font.pointSize: 13
				wrapMode: Text.WordWrap
				x: 10
				width: rect.width-20
				text: (type == "installed")
					  ? qsTr("Welcome to PhotoQt. PhotoQt is an image viewer, aimed at being fast and reliable, highly customisable and good looking.") + "<br><br>" + qsTr("This app started out more than three and a half years ago, and it has developed quite a bit since then. It has become very efficient, reliable, and highly flexible (check out the settings). I'm convinced it can hold up to the more 'traditional' image viewers out there in every way.") + "<br><br>" + qsTr("Here below you find a short overview of a selection of a few things PhotoQt has to offer, but feel free to skip it and just get started.")
					  : qsTr("Welcome back to PhotoQt. It hasn't been that long since the last release of PhotoQt. Yet, it changed pretty much entirely, as it now is based on QtQuick rather than QWidgets. A large quantity of the code had to be re-written, while some chunks could be re-used. Thus, it is now more reliable than ever before and overall simply feels well rounded.") + "<br><br>" + qsTr("Here below you find a short overview of a selection of a few things PhotoQt has to offer, but feel free to skip it and just get started.");
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 10
			}

			// FILEFORMATS
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Image {
					id: fileformats_img
					x: 0
					y: 0
					source: "qrc:/img/startup/fileformats.png"
				}

				Text {
					id: gm
					color: getanddostuff.isGraphicsMagickSupportEnabled() ? colour.text : colour.text_disabled
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: fileformats_img.width+25
					y: (Math.max(height,fileformats_img.height)-(getanddostuff.isGraphicsMagickSupportEnabled() ? 0 : gmunavailable.height)-height)/2
					width: parent.width-x
					text: "<h2>" + qsTr("Many File Formats") + "</h2><br>" + qsTr("PhotoQt can make use of GraphicsMagick, an image library, to display many different image formats. Currently, there are up to 72 different file formats supported (exact number depends on your system)! You can find a list of it in the settings (Tab 'Other'). There you can en-/disable different ones and also add custom file endings.")
				}

				Text {
					id: gmunavailable
					visible: !getanddostuff.isGraphicsMagickSupportEnabled()
					color: colour.text_warning
					wrapMode: Text.WordWrap
					x: fileformats_img.width+25
					y: gm.y+gm.height+10
					horizontalAlignment: Text.AlignHCenter
					width: parent.width-x
					text: "SUPPORT FOR GRAPHICSMAGICK WAS DISABLED AT COMPILE TIME!"
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// CUSTOMISABILITY
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Text {
					color: colour.text
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: 0
					y: (Math.max(height,customisability_img.height)-height)/2
					width: parent.width-customisability_img.width
					text: "<h2>" + qsTr("Make PhotoQt your own") + "</h2><br>" + qsTr("PhotoQt has an extensive settings area. By default you can call it with the shortcut 'e' or through the dropdown menu at the top edge towards the top right corner. You can adjust almost everything in PhotoQt, and it's certainly worth having a look there. Each setting usually comes with a little explanation text. Some of the most often used settings can also be conveniently adjusted in a slide-in widget, hidden behind the right screen edge.")
				}

				Image {
					id: customisability_img
					x: parent.width-width
					source: "qrc:/img/startup/settings.png"
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// THUMBNAILS
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Image {
					id: thumbnails_img
					x: 0
					y: 0
					source: "qrc:/img/startup/thumbnails.png"
				}

				Text {
					color: colour.text
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: thumbnails_img.width+25
					y: (Math.max(height,thumbnails_img.height)-height)/2
					width: parent.width-x
					text: "<h2>" + qsTr("Thumbnails") + "</h2><br>" + qsTr("What would be an image viewer without thumbnails support? It would only be half as good. Whenever you load an image, PhotoQt loads the other images in the directory in the background (by default, it tries to be smart about it and only loads the ones that are needed). It lines them up in a row at the bottom edge (move your mouse there to see them). There are many settings just for the thumbnails, like, e.g., size, liftup, en-/disabled, type, filename, permanently shown/hidden, etc. PhotoQt's quite flexible with that.")
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// SHORTCUTS
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Text {
					color: colour.text
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: 0
					y: (Math.max(height,shortcuts_img.height)-height)/2
					width: parent.width-shortcuts_img.width
					text: "<h2>" + qsTr("Shortcuts") + "</h2><br>" + qsTr("One of the many strengths of PhotoQt is the ability to easily set a shortcut for almost anything. Even mouse shortcuts are possible! You can choose from a huge number of internal functions, or you can run any custom script or command.")
				}

				Image {
					id: shortcuts_img
					x: parent.width-width
					source: "qrc:/img/startup/shortcuts.png"
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// EXIF/IPTC
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Image {
					id: exif_img
					x: 0
					y: 0
					source: "qrc:/img/startup/exif.png"
				}

				Text {
					id: exiv
					color: getanddostuff.isExivSupportEnabled() ? colour.text : colour.text_disabled
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: exif_img.width+25
					y: (Math.max(height,exif_img.height)+(getanddostuff.isExivSupportEnabled() ? 0 : exivunavailable.height)-height)/2
					width: parent.width-x
					text: "<h2>" + qsTr("Image Information (Exif/IPTC)") + "</h2><br>" + qsTr("Most images store some additional information within the file's metadata. PhotoQt can read and display a selection of this data. You can find this information in the slide-in window hidden behind the left edge of PhotoQt.")
				}

				Text {
					id: exivunavailable
					visible: !getanddostuff.isExivSupportEnabled()
					color: colour.text_warning
					wrapMode: Text.WordWrap
					x: exif_img.width+25
					y: exiv.y+exiv.height+10
					horizontalAlignment: Text.AlignHCenter
					width: parent.width-x
					text: "SUPPORT FOR EXIF/IPTC TAGS WAS DISABLED AT COMPILE TIME!"
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// SLIDESHOW
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Text {
					color: colour.text
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: 0
					y: (Math.max(height,slideshow_img.height)-height)/2
					width: parent.width-slideshow_img.width
					text: "<h2>" + qsTr("Slideshow") + "</h2><br>" + qsTr("PhotoQt also brings a slideshow feature. When you start a slideshow, it starts at the currently displayed image. There are a couple of settings that can be set, like transition, speed, loop, and shuffle. Plus, you can set a music file that is played in the background. When the slideshow takes longer than the music file, then PhotoQt starts the music file all over from the beginning. At anytime during the slideshow, you can move the mouse cursor to the top edge of the screen to get a little bar, where you can pause/exit the slideshow and adjust the music volume.")
				}

				Image {
					id: slideshow_img
					x: parent.width-width
					source: "qrc:/img/startup/slideshow.png"
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 5
			}

			// LOCALISATION
			Rectangle {
				color: "#00000000"
				x: 10
				width: rect.width-20
				height: childrenRect.height

				Image {
					id: localisation_img
					x: 0
					y: 0
					source: "qrc:/img/startup/localisation.png"
				}

				Text {
					color: colour.text
					font.pointSize: 10
					wrapMode: Text.WordWrap
					x: localisation_img.width+25
					y: (Math.max(height,localisation_img.height)-height)/2
					width: parent.width-x
					text: "<h2>" + qsTr("Localisation") + "</h2><br>" + qsTr("PhotoQt comes with a number of translations. Many have taken some of their time to create/update one of them (Thank you!). Not all of them are complete... do you want to help?")
				}

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 15
			}

			// FINISH TEXT
			Text {
				color: colour.text
				font.pointSize: 10
				wrapMode: Text.WordWrap
				x: 10
				width: rect.width-20
				text: qsTr("There are many many more features. Best is, you just give it a go. Don't forget to check out the settings to make PhotoQt YOUR image viewer. Enjoy :-)")
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 15
			}

		} // END Column

	} // END Flickable

	Rectangle {
		color: colour.linecolour
		x: 0
		width: rect.width
		height: 1
		y: rect.height-butrect.height
	}

	Rectangle {
		id: butrect
		color: "#00000000"
		width: rect.width
		x: 0
		y: rect.height-height
		height: childrenRect.height+20

		CustomButton {
			x: (parent.width-width)/2
			y: 10
			text: qsTr("Okay, I got enough now. Lets start!")
			onClickedButton: hideStartup()
		}
	}



	function showStartup(t) {

		type = t;

		showStartupAni.start()

	}

	function hideStartup() {
		hideStartupAni.start()
	}

	PropertyAnimation {
		id: hideStartupAni
		target: rect
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStopped: {
			visible = false
			blocked = false
			openFile()
		}
	}

	PropertyAnimation {
		id: showStartupAni
		target: rect
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
		}
	}


}
