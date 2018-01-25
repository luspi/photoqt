import QtQuick 2.5

import "./tweaks"
import "handlestuff.js" as Handle

Rectangle {

    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    property alias tweaksZoom: zoom

    height: 50

    color: "#44000000"

    TweaksUserPlaces { id: up }

    // Zoom files view
    TweaksZoom { id: zoom }

    // choose which file type group to show
    TweaksFileType { id: ft }

    // remember the current location in between PhotoQt sessions
    TweaksRememberLocation { id: remember }

    // control the preview image
    TweaksPreview { id: prev }

    // manage the file thumbnails
    TweaksThumbnails { id: thumb }

    // which view mode to use (lists vs icons)
    TweaksViewMode { id: viewmode }

}
