import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "handlestuff.js" as Handle

Rectangle {

    id: openfile_top

    x: mainwindow.x
    y: mainwindow.y
    width: mainwindow.width
    height: mainwindow.height

    color: "#88000000"

    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: 200 } }

    OpenVariables { id: openvariables }

    // Bread crumb navigation
    BreadCrumbs { id: breadcrumbs }

    // Seperating Line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: breadcrumbs.bottom
        height: 1
        color: "white"
    }

    SplitView {

        id: splitview

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: tweaks.top
        anchors.top: breadcrumbs.bottom

        orientation: Qt.Horizontal

        UserPlaces { id: userplaces }

        Folders { id: folders }

        FilesView { id: filesview }

    }

    // Seperating Line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: splitview.bottom
        height: 1
        color: "white"
    }

    Tweaks { id: tweaks }

    Component.onCompleted: {
        Handle.loadDirectory()
    }

    Connections {
        target: call
        onOpenfileShow:
            show()
        onShortcut: {
            if(!openfile_top.visible) return
            if(sh == "Escape")
                hide()
        }
    }

    function show() {
        opacity = 1
        variables.guiBlocked = true
    }
    function hide() {
        opacity = 0
        variables.guiBlocked = false
    }

}
