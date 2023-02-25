/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9

import "../../elements"

//********//
// PLASMA 5

Column {

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    property var numWorkspaces: [1, 1]
    property bool msgbusError: true
    property bool enlightenmentRemoteError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property var checkedScreens: []
    property var checkedWorkspaces: []

    spacing: 10

    PQTextL {
        x: (parent.width-width)/2
        text: "Enlightenment"
        font.weight: baselook.boldweight
    }

    Item {
        width: 1
        height: 10
    }

    PQText {
        x: (parent.width-width)/2
        visible: msgbusError
        color: "red"
        font.weight: baselook.boldweight
        text: em.pty+qsTranslate("wallpaper", "Warning: %1 module not activated").arg("<i>msgbus (DBUS)</i>")
    }

    PQText {
        x: (parent.width-width)/2
        visible: enlightenmentRemoteError
        color: "red"
        font.weight: baselook.boldweight
        text: em.pty+qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>enlightenment_remote</i>")
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

        PQTextL {
            x: (parent.width-width)/2
            //: As in: Set wallpaper to which screens
            text: em.pty+qsTranslate("wallpaper", "Set to which screens")
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: desk_col
            spacing: 10
            Repeater {
                model: numDesktops
                PQCheckbox {
                    //: Used in wallpaper element
                    text: em.pty+qsTranslate("wallpaper", "Screen") + " #" + (index+1)
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

        PQTextL {
            x: (parent.width-width)/2
            //: Enlightenment desktop environment handles wallpapers per workspace (different from screen)
            text: em.pty+qsTranslate("wallpaper", "Set to which workspaces")
        }

        Column {
            x: (parent.width-width)/2
            width: childrenRect.width
            height: childrenRect.height
            id: ws_col
            spacing: 10
            Repeater {
                model: numWorkspaces[0]*numWorkspaces[1]
                PQCheckbox {
                    property string num: ((index%numWorkspaces[1] +1) + " - " + (Math.floor(index/numWorkspaces[1]) +1))
                    //: Enlightenment desktop environment handles wallpapers per workspace (different from screen)
                    text: em.pty+qsTranslate("wallpaper", "Workspace:") + " " + num
                    checked: true
                    onCheckedChanged: {
                        if(!checked)
                            checkedWorkspaces.splice(checkedWorkspaces.indexOf(num), 1)
                        else
                            checkedWorkspaces.push(num)
                    }
                    Component.onCompleted: {
                        checkedWorkspaces.push(num)
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
