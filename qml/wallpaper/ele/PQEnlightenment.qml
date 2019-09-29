import QtQuick 2.9

import "../../elements"

//********//
// PLASMA 5

Column {

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    property int numWorkspaces: 2
    property bool msgbusError: true
    property bool enlightenmentRemoteError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property var checkedScreens: []
    property var checkedWorkspaces: []

    spacing: 10

    Text {
        x: (parent.width-width)/2
        color: "white"
        font.pointSize: 15
        text: "Enlightenment"
        font.bold: true
    }

    Item {
        width: 1
        height: 10
    }

    Text {
        x: (parent.width-width)/2
        visible: msgbusError
        color: "red"
        font.pointSize: 12
        font.bold: true
        text: "Warning: <i>msgbus (DBUS)</i> module not activated"
    }

    Text {
        x: (parent.width-width)/2
        visible: enlightenmentRemoteError
        color: "red"
        font.pointSize: 12
        font.bold: true
        text: "Warning: <i>enlightenment_remote</i> not found"
    }

    Item {
        visible: enlightenmentRemoteError || msgbusError
        width: 1
        height: 10
    }

    Column {

        id: col

        spacing: 10
        width: parent.width
        height: childrenRect.height

        Text {
            x: (parent.width-width)/2
            color: "white"
            font.pointSize: 15
            text: "Set to which screens"
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: desk_col
            Repeater {
                model: numDesktops
                PQCheckbox {
                    text: "Screen #" + (index+1)
                    checked: true
                    onCheckedChanged: {
                        if(!checked)
                            checkedScreens.splice(checkedScreens.indexOf(index+1), 1)
                        else
                            checkedScreens.push(index+1)
                    }
                    Component.onCompleted: {
                        checkedScreens.push(index+1)
                    }
                }
            }
        }

        Item {
            width: 1
            height: 10
        }

        Text {
            x: (parent.width-width)/2
            color: "white"
            font.pointSize: 15
            text: "Set to which workspaces"
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: ws_col
            Repeater {
                model: numWorkspaces
                PQCheckbox {
                    text: "Workspace #" + (index+1)
                    checked: true
                    onCheckedChanged: {
                        if(!checked)
                            checkedWorkspaces.splice(checkedWorkspaces.indexOf(index+1), 1)
                        else
                            checkedWorkspaces.push(index+1)
                    }
                    Component.onCompleted: {
                        checkedWorkspaces.push(index+1)
                    }
                }
            }
        }

    }

    function check() {

        wallpaper_top.numDesktops = handlingWallpaper.getScreenCount()
        numWorkspaces = handlingWallpaper.getEnlightenmentWorkspaceCount()
        enlightenmentRemoteError = handlingWallpaper.checkEnlightenmentRemote()
        msgbusError = handlingWallpaper.checkEnlightenmentMsgbus();

    }

}
