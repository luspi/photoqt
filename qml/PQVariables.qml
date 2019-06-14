import QtQuick 2.9

Item {

    property var shortcuts: []
    property string visibleItem: ""
    property var allImageFilesInOrder: []
    property int indexOfCurrentImage: -1
    property real currentZoomLevel: 1

    property string openCurrentDirectory: handlingFileDialog.getHomeDir()

    property point mousePos: Qt.point(-1, -1)


    Connections {
        target: PQCppVariables

        onCmdFilePathChanged: {
            if(PQCppVariables.cmdFilePath != "") {
                console.log("filepath:", PQCppVariables.cmdFilePath)
                PQCppVariables.cmdFilePath = ""
            }
        }

        onCmdOpenChanged: {
            if(PQCppVariables.cmdOpen) {
                console.log("open")
                PQCppVariables.cmdOpen = false
            }
        }

        onCmdShowChanged: {
            if(PQCppVariables.cmdShow) {
                console.log("show")
                PQCppVariables.cmdShow = false
            }
        }

        onCmdHideChanged: {
            if(PQCppVariables.cmdHide) {
                console.log("hide")
                PQCppVariables.cmdHide = false
            }
        }

        onCmdToggleChanged: {
            if(PQCppVariables.cmdToggle) {
                console.log("toggle")
                PQCppVariables.cmdToggle = false
            }
        }

        onCmdThumbsChanged: {
            if(PQCppVariables.cmdThumbs) {
                console.log("thumbs")
                PQCppVariables.cmdThumbs = false
            }
        }

        onCmdNoThumbsChanged: {
            if(PQCppVariables.cmdNoThumbs) {
                console.log("nothumbs")
                PQCppVariables.cmdNoThumbs = false
            }
        }

        onCmdTrayChanged: {
            if(PQCppVariables.cmdTray) {
                console.log("tray")
                PQCppVariables.cmdTray = false
            }
        }

        onCmdDebugChanged: {
            if(PQCppVariables.cmdDebug) {
                console.log("debug")
                PQCppVariables.cmdDebug = false
            }
        }

    }

}
