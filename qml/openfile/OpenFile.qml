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

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        hoverEnabled: true
    }

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

        property int hoveringOver: -1
        property var dragSource: undefined

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

    Connections {
        target: call
        onOpenfileShow:
            show()
        onShortcut: {
            if(!openfile_top.visible) return
            if(sh == "Escape")
                hide()
            else if(sh == "Alt+Left") {
                if(openvariables.currentFocusOn == "userplaces")
                    openvariables.currentFocusOn = "filesview"
                else if(openvariables.currentFocusOn == "folders")
                    openvariables.currentFocusOn = "userplaces"
                else
                    openvariables.currentFocusOn = "folders"
            } else if(sh == "Alt+Right") {
                if(openvariables.currentFocusOn == "userplaces")
                    openvariables.currentFocusOn = "folders"
                else if(openvariables.currentFocusOn == "folders")
                    openvariables.currentFocusOn = "filesview"
                else
                    openvariables.currentFocusOn = "userplaces"
            }
        }
    }

    Connections {
        target: watcher
        onFolderUpdated:
            Handle.loadDirectoryFolders()
    }

    function show() {
        opacity = 1
        openvariables.history = []
        openvariables.historypos = -1
        variables.guiBlocked = true
    }
    function hide() {
        opacity = 0
        variables.guiBlocked = false
    }

}
