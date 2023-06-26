import QtQuick
import QtQuick.Controls

Rectangle {

    id: filedialog_top

    width: toplevel.width
    height: toplevel.height

    property string thisis: "filedialog"
    property alias placesWidth: fd_places.width
    property alias fileviewWidth: fd_fileview.width
    property alias splitview: fd_splitview

    property int leftColMinWidth: 200

    color: PQCLook.baseColor

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    PQBreadCrumbs {
        id: fd_breadcrumbs
    }

    SplitView {

        id: fd_splitview

        y: fd_breadcrumbs.height
        width: parent.width
        height: parent.height-fd_breadcrumbs.height-fd_tweaks.height
        anchors.topMargin: fd_breadcrumbs.height
        anchors.bottomMargin: fd_tweaks.height

        // Show larger handle with triple dash
        handle: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            color: SplitHandle.hovered ? PQCLook.baseColorContrast : PQCLook.baseColorDisabled
            Behavior on color { ColorAnimation { duration: 200 } }

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
            SplitView.minimumWidth: leftColMinWidth
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

    Connections {
        target: loader
        function onPassOn(what, param) {
            if(what === "show") {
                if(param === thisis)
                    show()
            } else if(filedialog_top.opacity > 0) {
                if(what === "keyEvent") {
                    if(param[0] === Qt.Key_Escape)
                        hide()
                }
            }
        }
    }

    function show() {
        opacity = 1
    }

    function hide() {
        opacity = 0
        loader.elementClosed(thisis)
    }

}
