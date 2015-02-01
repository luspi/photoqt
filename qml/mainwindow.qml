import QtQuick 2.3
import my.settings 1.0

import "mainview/"
import "slidein/"

Item {

    id: toplevel

    // This is how much bigger than the thumbnails the thumbnail bar is (this is the space to the top)
    property int thumbnailbarheight_addon: 50

    // This signal is picked up by the mainwindow.cpp file
    signal thumbScrolled(var filenameAtCenter)
    signal openFile()

    // Access to the permanent settings file (~/.photoqt/settings)
    Settings { id: settings }

    Shortcuts { id: sh }

    // Application background
	Background {
		id: background
		objectName: "background"
	}

    // The main displayed image
	Display {
		id: image
		objectName: "image"
	}

    // The thumbnail bar at the bottom
    ThumbnailBar {
        id: thumbnailBar
        objectName: "thumbnailbar"
		height: settings.value("Thumbnail/ThumbnailSize")*1+thumbnailbarheight_addon
    }

    // The quickinfo (position in folder, filename)
	QuickInfo {
		id: quickInfo
		x:5
		y:5
	}

    // MetaData of the image (using the C++ Exiv2 library)
    MetaData {
        id: metaData
        width: 300
        height: 550
        radius: 10
        objectName: "metaData"
    }


    // Adjust size of all the elements
	function resizeElements(w,h) {

        var thumbKeepVisible = settings.value("Thumbnail/ThumbnailKeepVisible")*1

		background.width = w
		background.height = h

        thumbnailBar.width = w
        thumbnailBar.y = h-(thumbKeepVisible ? settings.value("Thumbnail/ThumbnailSize")*1+thumbnailbarheight_addon : 0)

		image.width = w
        image.height = (thumbKeepVisible ? h-thumbnailBar.height : h)

        metaData.x = -10
        metaData.y = (h-metaData.height)/3

        image.sourceSize.width = w
        image.sourceSize.height = h

    }

    // Slots accessable by mainwindow.cpp, passed on to thumbnailbar
    function reloadImage(pos) { thumbnailBar.reloadImage(pos) }
    function setupModel(stringlist) { thumbnailBar.setupModel(stringlist) }
    function displayImage(pos) { thumbnailBar.displayImage(pos) }
    function nextImage() { thumbnailBar.nextImage(); }
    function previousImage() { thumbnailBar.previousImage(); }

}
