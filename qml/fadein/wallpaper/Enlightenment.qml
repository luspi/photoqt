import QtQuick 2.3

import "../../elements"

Rectangle {

    property bool currentlySelected: false

    property var selectedScreens_enlightenment: []
    property var selectedWorkspaces_enlightenment: []

    visible: currentlySelected

    color: "#00000000"
    width: childrenRect.width
    height: currentlySelected

    Column {

        spacing: 15

        // NOTE (dbus error)
        Text {
            id: enlightenment_error_msgbus
            visible: false
            color: colour.text_warning
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //: Wallpaper: Enlightenment warning
            text: qsTr("Warning: It seems that the 'msgbus' (DBUS) module is not activated! It can be activated in the settings console > Add-ons > Modules > System.");
        }
        // NOTE (tool not existing)
        Text {
            id: enlightenment_error_exitence
            visible: false
            color: colour.text_warning
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //: Wallpaper: Enlightenment warning
            text: qsTr("Warning: 'enlightenment_remote' doesn't seem to be available! Are you sure Enlightenment is installed?");
        }

        // MONITOR HEADING
        Text {
            id: enlightenment_monitor_part_1
            color: colour.text
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("The wallpaper can be set to any of the available monitors (one or any combination).")
        }

        // MONITOR SELECTION
        Rectangle {
            id: enlightenment_monitor_part_2
            color: "#00000000"
            width: childrenRect.width
            height: childrenRect.height
            x: (wallpaper_top.width-width)/2
            ListView {
                id: enlightenment_monitor
                width: 10
                spacing: 5
                height: childrenRect.height
                delegate: CustomCheckBox {
                    text: qsTr("Screen") + " #" + index
                    checkedButton: true
                    fsize: 10
                    Component.onCompleted: {
                        selectedScreens_enlightenment[selectedScreens_enlightenment.length] = index
                        if(enlightenment_monitor.width < width)
                            enlightenment_monitor.width = width
                    }
                    onCheckedButtonChanged: {
                        if(checkedButton)
                            selectedScreens_enlightenment[selectedScreens_enlightenment.length] = index
                        else {
                            var newlist = []
                            for(var i = 0; i < selectedScreens_enlightenment.length; ++i)
                                if(selectedScreens_enlightenment[i] !== index)
                                    newlist[newlist.length] = selectedScreens_enlightenment[i]
                            selectedScreens_enlightenment = newlist
                        }
                        okay.enabled = enDisableEnter()
                    }
                }
                model: ListModel { id: enlightenment_monitor_model; }
            }
        }

        Rectangle { id: enlightenment_monitor_part_3; color: "#00000000"; width: 1; height: 1; }
        Rectangle { id: enlightenment_monitor_part_4; color: "#00000000"; width: 1; height: 1; }

        // PICTURE OPTIONS HEADING
        Text {
            color: colour.text
            font.pointSize: 10
            width: wallpaper_top.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("You can set the wallpaper to any sub-selection of workspaces")
        }

        Rectangle { color: "#00000000"; width: 1; height: 1; }

        // WORKSPACE SELECTION
        Rectangle {
            color: "#00000000"
            width: childrenRect.width
            height: childrenRect.height
            x: (wallpaper_top.width-width)/2
            ListView {
                id: enlightenment_workspace
                width: 10
                spacing: 5
                height: childrenRect.height
                property int index: selectedWorkspaces_enlightenment.length
                delegate: CustomCheckBox {
                    text: {
                        if(row == -1)
                            return qsTr("Workspace") + " #" + column
                        if(column == -1)
                            return qsTr("Workspace") + " #" + row
                        return qsTr("Workspace") + " #" + row + "-" + column
                    }
                    checkedButton: true
                    fsize: 10
                    Component.onCompleted: {
                        // SINGLE COLUMNS/ROWS ARE TREATED SPECIALLY (DIFFERENTLY DISPLAYED!)
                        selectedWorkspaces_enlightenment[index] = (row == -1 ? 10000*(column+1) : (column == -1 ? 10000000*(row+1) : row*100+column))
                        if(enlightenment_workspace.width < width)
                            enlightenment_workspace.width = width
                    }
                    onCheckedButtonChanged: {
                        if(checkedButton)
                            selectedWorkspaces_enlightenment[selectedWorkspaces_enlightenment.length] = (row == -1 ? 10000*(column+1) : (column == -1 ? 10000000*(row+1) : row*100+column))
                        else {
                            var newlist = []
                            for(var i = 0; i < selectedWorkspaces_enlightenment.length; ++i)
                                if(selectedWorkspaces_enlightenment[i] !== (row == -1 ? 10000*(column+1) : (column == -1 ? 10000000*(row+1) : row*100+column)))
                                    newlist[newlist.length] = selectedWorkspaces_enlightenment[i]
                            selectedWorkspaces_enlightenment = newlist
                        }
                        okay.enabled = enDisableEnter()
                    }
                }
                model: ListModel { id: enlightenment_workspace_model; }
            }
        }

    }

    function loadEnlightenment() {
        var c = getanddostuff.getScreenCount()
        enlightenment_monitor_model.clear()
        for(var i = 0; i < c; ++i)
            enlightenment_monitor_model.append({ "index" : i })

        // Set-up enlightenment workspaces
        enlightenment_workspace_model.clear()
        var d = getanddostuff.getEnlightenmentWorkspaceCount()
        for(var i = 0; i < d[0]; ++i)
            for(var j = 0; j < d[1]; ++j)
                enlightenment_workspace_model.append({"row" : (d[0] === 1 ? -1 : i), "column" : (d[1] === 1 ? -1 : j)})

        enlightenment_monitor_part_1.visible = (c > 1)
        enlightenment_monitor_part_2.visible = (c > 1)
        enlightenment_monitor_part_3.visible = (c > 1)
        enlightenment_monitor_part_4.visible = (c > 1)

        // Check for tools (and display appropriate error messages
        var ret = getanddostuff.checkWallpaperTool("enlightenment")
        enlightenment_error_exitence.visible = (ret === 1)
        enlightenment_error_msgbus.visible = (ret === 2)
    }

    function getSelectedWorkspaces() {
        return selectedWorkspaces_enlightenment
    }

    function getSelectedScreens() {
        return selectedScreens_enlightenment
    }

}
