import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	color: "#00000000"

	width: childrenRect.width
	height: childrenRect.height

	property string source: ""
	onSourceChanged: {
		one_fadein.stop()
		one_fadeout.stop()
		two_fadein.stop()
		two_fadeout.stop()

		if(settings.transition == 0) {

			if(currentone == "one") {
				one.opacity = 1
				two.opacity = 0
				one.source = source
			}
			if(currentone == "two") {
				two.opacity = 1
				one.opacity = 0
				two.source = source
			}

		} else {

			one_fadein.duration = settings.transition*150
			one_fadeout.duration = settings.transition*150
			two_fadein.duration = settings.transition*150
			two_fadeout.duration = settings.transition*150

			if(currentone == "one") {
				one.opacity = 1
				two.opacity = 0
				two.scale = 1
				two.visible = true
				two.source = ""
				two.source = source
				two_fadein.start()
				one_fadeout.start()
				currentone = "two"
			} else {
				two.opacity = 1
				one.opacity = 0
				one.scale = 1
				one.visible = true
				one.source = ""
				one.source = source
				one_fadein.start()
				two_fadeout.start()
				currentone = "one"
			}

		}
	}
	property string currentone: "one"

	property bool asynchronous: false
	property int fillMode: Image.PreserveAspectFit

	property size sourceSize: Qt.size(0,0);
	onSourceSizeChanged: {
		if(one.opacity != 0) {
			one.sourceSize.width = sourceSize.width
			one.sourceSize.height = sourceSize.height
		}

		if(opacity != 0) {
			two.sourceSize.width = sourceSize.width
			two.sourceSize.height = sourceSize.height
		}

	}

	signal statusChanged(var status)

	Image {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: one

		x: (Math.max(one.width,two.width)-width)/2
		y: (Math.max(one.height,two.height)-height)/2

		opacity: 1

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	Image {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: two

		x: (Math.max(one.width,two.width)-width)/2
		y: (Math.max(one.height,two.height)-height)/2

		opacity: 1

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	PropertyAnimation {
		id: one_fadein
		target: one
		properties: "opacity"
		from: 0
		to: 1
		duration: 300
	}
	PropertyAnimation {
		id: two_fadein
		target: two
		properties: "opacity"
		from: 0
		to: 1
		duration: 300
	}
	PropertyAnimation {
		id: one_fadeout
		target: one
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: one.visible = false
	}
	PropertyAnimation {
		id: two_fadeout
		target: two
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: two.visible = false
	}

	function resetZoom(loadNewImage) {

		if(loadNewImage !== undefined && loadNewImage === true && settings.transition != 0) {
			if(currentone == "one") {
				one.scale = scale
				scale = 1
			}
			if(currentone == "two") {
				two.scale = scale
				scale = 1
			}
		} else {
			one.scale = 1
			two.scale = 1
			scale = 1
		}

	}

}
