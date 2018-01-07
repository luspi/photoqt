import QtQuick 2.6

import "./tweaks"
import "handlestuff.js" as Handle

Rectangle {

    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    property alias tweaksZoom: zoom

    height: 50

    color: "#44000000"

    TweaksZoom { id: zoom }

    TweaksFileType { id: ft }

    TweaksPreview { id: prev }

    TweaksThumbnails { id: thumb }

    TweaksViewMode { id: viewmode }

}
