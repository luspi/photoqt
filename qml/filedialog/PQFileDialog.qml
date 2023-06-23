import QtQuick
import QtQuick.Controls

Rectangle {

    width: container.width
    height: container.height

    color: PQCLook.baseColor50

    PQBreadCrumbs {
        id: fd_breadcrumbs
    }

    SplitView {

        y: fd_breadcrumbs.height
        width: parent.width
        height: parent.height-fd_breadcrumbs.height-fd_tweaks.height
        anchors.topMargin: fd_breadcrumbs.height
        anchors.bottomMargin: fd_tweaks.height

        // Show larger handle with triple dash
        handle: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            color: SplitHandle.hovered ? "#888888" : "#666666"

            Image {
                y: (parent.height-height)/2
                width: parent.implicitWidth
                height: parent.implicitHeight
                sourceSize: Qt.size(width, height)
                source: "/generic/handle.svg"
            }

        }

        PQPlaces {
            id: fd_places
            SplitView.minimumWidth: 200
            SplitView.preferredWidth: PQCSettings.filedialogUserPlacesWidth
            onWidthChanged: {
                PQCSettings.filedialogUserPlacesWidth = width
            }

        }

        PQFileView {
            id: fd_fileview

            SplitView.minimumWidth: 200
            SplitView.fillWidth: true
        }

    }

    PQTweaks {
        id: fd_tweaks
        y: parent.height-height
    }

}
