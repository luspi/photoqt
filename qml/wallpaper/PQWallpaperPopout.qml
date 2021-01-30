/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../elements"

Window {

    id: wallpaper_window

    //: Window title
    title: em.pty+qsTranslate("wallpaper", "Set as Wallpaper")

    Component.onCompleted: {
        wallpaper_window.setX(windowgeometry.wallpaperWindowGeometry.x)
        wallpaper_window.setY(windowgeometry.wallpaperWindowGeometry.y)
        wallpaper_window.setWidth(windowgeometry.wallpaperWindowGeometry.width)
        wallpaper_window.setHeight(windowgeometry.wallpaperWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    objectName: "wallpaperpopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "wallpaper")
            variables.visibleItem = ""
    }

    visible: PQSettings.wallpaperPopoutElement&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onWallpaperPopoutElementChanged: {
            if(!PQSettings.wallpaperPopoutElement)
                wallpaper_window.visible = Qt.binding(function() { return PQSettings.wallpaperPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQWallpaper.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return wallpaper_window.width })
                item.parentHeight = Qt.binding(function() { return wallpaper_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(wallpaper_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.wallpaperWindowGeometry = Qt.rect(wallpaper_window.x, wallpaper_window.y, wallpaper_window.width, wallpaper_window.height)
        windowgeometry.wallpaperWindowMaximized = (wallpaper_window.visibility==Window.Maximized)
    }

}
