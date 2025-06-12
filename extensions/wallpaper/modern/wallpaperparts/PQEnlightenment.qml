/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/
pragma ComponentBehavior: Bound

import QtQuick
import PhotoQt

//********//
// PLASMA 5

Column {

    id: enlightenment_top

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    property list<int> numWorkspaces: [1, 1]
    property bool msgbusError: true
    property bool enlightenmentRemoteError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property list<int> checkedScreens: []
    property list<int> checkedWorkspaces: []

    spacing: 10

    PQTextXL {
        x: (parent.width-width)/2
        text: "Enlightenment"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    Item {
        width: 1
        height: 10
    }

    PQText {
        x: (parent.width-width)/2
        visible: enlightenment_top.msgbusError
        color: "red"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        text: qsTranslate("wallpaper", "Warning: %1 module not activated").arg("<i>msgbus (DBUS)</i>")
    }

    PQText {
        x: (parent.width-width)/2
        visible: enlightenment_top.enlightenmentRemoteError
        color: "red"
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        text: qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>enlightenment_remote</i>")
    }

    Item {
        visible: enlightenment_top.enlightenmentRemoteError || enlightenment_top.msgbusError
        width: 1
        height: 10
    }

    Column {

        id: col

        spacing: 10
        width: parent.width
        height: childrenRect.height

        PQTextL {
            x: (parent.width-width)/2
            //: As in: Set wallpaper to which screens
            text: qsTranslate("wallpaper", "Set to which screens")
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: desk_col
            spacing: 10
            Repeater {
                model: wallpaper_top.numDesktops // qmllint disable unqualified
                PQCheckBox {
                    id: deleg
                    required property int modelData
                    //: Used in wallpaper element
                    text: qsTranslate("wallpaper", "Screen") + " #" + (deleg.modelData+1)
                    checked: true
                    onCheckedChanged: {
                        if(!checked)
                            enlightenment_top.checkedScreens.splice(enlightenment_top.checkedScreens.indexOf(deleg.modelData+1), 1)
                        else
                            enlightenment_top.checkedScreens.push(deleg.modelData+1)
                    }
                    Component.onCompleted: {
                        enlightenment_top.checkedScreens.push(deleg.modelData+1)
                    }
                }
            }
        }

        Item {
            width: 1
            height: 10
        }

        PQTextL {
            x: (parent.width-width)/2
            //: Enlightenment desktop environment handles wallpapers per workspace (different from screen)
            text: qsTranslate("wallpaper", "Set to which workspaces")
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: ws_col
            spacing: 10
            Repeater {
                model: enlightenment_top.numWorkspaces[0]*enlightenment_top.numWorkspaces[1]
                PQCheckBox {
                    id: deleg2
                    required property int modelData
                    property string num: ((deleg2.modelData%enlightenment_top.numWorkspaces[1] +1) + " - " + (Math.floor(deleg2.modelData/enlightenment_top.numWorkspaces[1]) +1))
                    //: Enlightenment desktop environment handles wallpapers per workspace (different from screen)
                    text: qsTranslate("wallpaper", "Workspace:") + " " + num
                    checked: true
                    onCheckedChanged: {
                        if(!checked)
                            enlightenment_top.checkedWorkspaces.splice(enlightenment_top.checkedWorkspaces.indexOf(num), 1)
                        else
                            enlightenment_top.checkedWorkspaces.push(num)
                    }
                    Component.onCompleted: {
                        enlightenment_top.checkedWorkspaces.push(num)
                    }
                }
            }
        }

    }

    function check() {

        wallpaper_top.numDesktops = PQCScriptsWallpaper.getScreenCount() // qmllint disable unqualified
        numWorkspaces = PQCScriptsWallpaper.getEnlightenmentWorkspaceCount()
        enlightenmentRemoteError = PQCScriptsWallpaper.checkEnlightenmentRemote()
        msgbusError = PQCScriptsWallpaper.checkEnlightenmentMsgbus();

    }

}
