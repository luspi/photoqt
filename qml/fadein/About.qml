import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: about

	anchors.fill: background
	color: colour.fadein_slidein_block_bg

	opacity: 0
	visible: false

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideAboutAni.start()
	}

	Rectangle {

		id: item

		// Set size
		anchors {
			fill: parent
			topMargin: 50
			bottomMargin: 50
			leftMargin: 100
			rightMargin: 100
		}

		// Some styling
		border.width: 1
		border.color: colour.fadein_slidein_border
		radius: global_element_radius
		color: colour.fadein_slidein_bg

		// Clicks INSIDE element doesn't close it
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
		}

		Rectangle {

			id: rect

			// Set inner area for display
			anchors.fill: parent
			anchors.margins: item.radius
			color: "#00000000"

			Column {

				id: topcol

				spacing: 5

				// Set license (not scrolled)
				Text {
					id: license
					color: colour.text
					font.pointSize: 9
					text: "PhotoQt QML, Lukas Spies, 2015 (Lukas@photoqt.org) - " + qsTr("website:") + " photoqt.org - " + qsTr("Licensed under GPLv2 or later, without any guarantee")
				}

				// Main text (scrollable)
				Flickable {

					id: flickarea

					// Size
					width: rect.width
					height: rect.height-license.height-but.height-4*topcol.spacing
					contentHeight: col.height+10

					// Behaviour
					clip: true
					boundsBehavior: ListView.StopAtBounds

					Column {

						id: col

						// Icon logo
						Rectangle {
							width: rect.width
							height: childrenRect.height+10
							color: "#00000000"
							Image {
								y: 10
								width: rect.width
								fillMode: Image.PreserveAspectFit
								horizontalAlignment: Image.AlignHCenter
								source: "qrc:/img/logo.png"
							}
						}

						// Main text
						Text {
							id: txt
							width: rect.width
							color: colour.text
							font.pointSize: 11
							wrapMode: Text.WordWrap
							textFormat:Text.RichText
							text: {
								"<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>"
								+ qsTr("PhotoQt is a simple image viewer, designed to be good looking, highly configurable, yet easy to use and fast.")
								+ "<br><br>"
								+ qsTr("With PhotoQt I try to be different than other image viewers (after all, there are plenty of good image viewers already out there). Its interface is kept very simple, yet there is an abundance of settings to customize the look and feel to make PhotoQt YOUR image viewer.")
								+ "<br><br>"
								+ qsTr("I'm not a trained programmer. I'm a simple Maths student that loves doing stuff like this. Most of my programming knowledge I taught myself over the past 10-ish years, and it has been developing a lot since I started PhotoQt. During my studies in university I learned a lot about the basics of programming that I was missing. And simply working on PhotoQt gave me a lot of invaluable experience. So the code of PhotoQt might in places not quite be done in the best of ways, but I think it's getting better and better with each release.")
								+ "<br><br>"
								+ qsTr("I heard a number of times people saying, that PhotoQt is a 'copy' of Picasa's image viewer. Well, it's not. In fact, I myself have never used Picasa. I have seen it in use though by others, and I can't deny that it influenced the basic design idea a little. But I'm not trying to do something 'like Picasa'. I try to do my own thing, and to do it as good as I can.")
								+ "<br><br>"
								+ qsTr("Don't forget to check out the website:")
								+ " <a href=\"http://photoqt.org\">http://PhotoQt.org</a><br><br>"
								+ qsTr("If you find a bug or if you have a question or suggestion, tell me. I'm open to any feedback I get :)")
								+ "<br>";

							}
							// Pointing hand cursor and click when over link
							MouseArea {
								anchors.fill: parent
								cursorShape: txt.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
								onClicked: {
									if(txt.hoveredLink)
										Qt.openUrlExternally(txt.hoveredLink)
								}
							}
						}

						// Big text thanking supporters and contributors
						Rectangle {

							width: rect.width
							height: childrenRect.height
							color: "#00000000"

							Text {
								x: (parent.width-width)/2
								width: rect.width/2

								horizontalAlignment: Qt.AlignHCenter
								color: colour.text

								font.pointSize: 20
								font.bold: true

								wrapMode: Text.WordWrap
								textFormat: Text.RichText

								text: qsTr("Thanks to everybody who contributed to PhotoQt and/or translated PhotoQt to another language! You guys rock!")
							}
						}

						Text {

							width: rect.width

							color: colour.text

							font.pointSize: 11
							wrapMode: Text.WordWrap
							textFormat: Text.RichText

							//: Don't forget to add the %1 in your translation!!
							text: "<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>"
								+ qsTr("You want to join the team and do something, e.g. translating PhotoQt to another language? Drop me and email (%1), and for translations, check the project page on Transifex:").arg("<a href=\"mailto:Lukas@photoqt.org\">Lukas@photoqt.org</a>") + " <a href=\"http://transifex.com/p/photo\">http://transifex.com/p/photo</a>."

							MouseArea {
								anchors.fill: parent
								cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
								onClicked: {
									if(parent.hoveredLink)
										Qt.openUrlExternally(parent.hoveredLink)
								}
							}
						}
					}
				}

				// Horizontal line
				Rectangle {
					width: rect.width
					height: 1
					color: colour.linecolour
				}

				Rectangle {

					width: rect.width
					height: but.height+10

					color: "#00000000"

					CustomButton {

						id: but

						// The button is in the middle of the space between line above and end of rectangle below
						x: (parent.width-width)/2
						y: 5

						height: 30

						text: "Okay I got enough of that"

						onClickedButton: hideAbout()

					}
				}

			}

		}

	}

	function showAbout() {
		showAboutAni.start()
	}
	function hideAbout() {
		hideAboutAni.start()
	}

	PropertyAnimation {
		id: hideAboutAni
		target:  about
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStopped: {
			visible = false
			blocked = false
			if(thumbnailBar.currentFile == "")
			openFile()
		}
	}

	PropertyAnimation {
		id: showAboutAni
		target:  about
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
