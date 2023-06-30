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

    // the first entry of the history list is set in Component.onCompleted
    // we do not want a property binding here!
    property var history: []
    property int historyIndex: 0

    property int leftColMinWidth: 200

    color: PQCLook.baseColor

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

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
            color: SplitHandle.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
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

    Component.onCompleted: {
        // this needs to come here as we do not want a property binding
        // otherwise the history feature wont work
        history.push(PQCFileFolderModel.folderFileDialog)
    }

    function loadNewPath(path) {
        PQCFileFolderModel.folderFileDialog = path
        if(historyIndex < history.length-1)
            history.splice(historyIndex+1)
        history.push(path)
        historyIndex = history.length-1
    }

    function goBackInHistory() {
        historyIndex = Math.max(0, historyIndex-1)
        PQCFileFolderModel.folderFileDialog = history[historyIndex]
    }

    function goForwardsInHistory() {
        historyIndex = Math.min(history.length-1, historyIndex+1)
        PQCFileFolderModel.folderFileDialog = history[historyIndex]
    }

    function show() {
        opacity = 1
    }

    function hide() {
        opacity = 0
        loader.elementClosed(thisis)
    }

}
