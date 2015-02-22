import QtQuick 2.3
import Settings 1.0
import SettingsSession 1.0
import GetStuff 1.0
import GetMetaData 1.0

import "mainview/"
import "slidein/"
import "fadein/"

Item {

    id: toplevel

    // This is how much bigger than the thumbnails the thumbnail bar is (this is the space to the top)
    property int thumbnailbarheight_addon: 50

    // These signals is picked up by the mainwindow.cpp file
    signal thumbScrolled(var filenameAtCenter)
    signal openFile()
    signal loadMoreThumbnails();
    signal didntLoadThisThumbnail(var pos);
    signal imageLoaded(var path)

    property bool blocked: false

    // Access to the permanent settings file (~/.photoqt/settings)
    Settings { id: settings; }
    SettingsSession { id: settingssession; }

    GetStuff { id: getstuff; }

    GetMetaData { id: getmetadata; }

    Shortcuts { id: sh; }

    // Application background
    Background { id: background; }

    // The main displayed image
    Display { id: image; }

    // The thumbnail bar at the bottom
    ThumbnailBar { id: thumbnailBar; }

    // The quickinfo (position in folder, filename)
    QuickInfo { id: quickInfo; }

    MainMenu { id: mainmenu; }

    // MetaData of the image (using the C++ Exiv2 library)
    MetaData { id: metaData; }

    About { id: about; }


    // Adjust size of all the elements
	function resizeElements(w,h) {

		background.width = w
		background.height = h

        thumbnailBar.width = w
        thumbnailBar.y = h-(settings.thumbnailKeepVisible ? settings.thumbnailsize+thumbnailbarheight_addon : 0)

		image.width = w
        image.height = (settings.thumbnailKeepVisible ? h-thumbnailBar.height+thumbnailbarheight_addon/2 : h)

        metaData.x = -metaData.width
        metaData.y = (h-metaData.height)/3

        mainmenu.x = w-mainmenu.width-100
        mainmenu.y = -mainmenu.height

        if(image.zoomSteps == 0) image.setSourceSize(w,h)

    }

    // Slots accessable by mainwindow.cpp, passed on to thumbnailbar
    function reloadImage(pos, smart) { thumbnailBar.reloadImage(pos, smart) }
    function setupModel(stringlist, pos) { thumbnailBar.setupModel(stringlist, pos) }
    function displayImage(pos) { thumbnailBar.displayImage(pos) }
    function nextImage() { thumbnailBar.nextImage(); }
    function previousImage() { thumbnailBar.previousImage(); }
    function getCenterPos() { console.log("center pos"); return thumbnailBar.getCenterPos(); }

}
