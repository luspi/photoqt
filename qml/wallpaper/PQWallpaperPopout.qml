import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: wallpaper_window

    Component.onCompleted: {
        wallpaper_window.setX(windowgeometry.wallpaperWindowGeometry.x)
        wallpaper_window.setY(windowgeometry.wallpaperWindowGeometry.y)
        wallpaper_window.setWidth(windowgeometry.wallpaperWindowGeometry.width)
        wallpaper_window.setHeight(windowgeometry.wallpaperWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.wallpaperWindowGeometry = Qt.rect(wallpaper_window.x, wallpaper_window.y, wallpaper_window.width, wallpaper_window.height)
        windowgeometry.wallpaperWindowMaximized = (wallpaper_window.visibility==Window.Maximized)

        if(variables.visibleItem == "wallpaper")
            variables.visibleItem = ""
    }

    visible: PQSettings.wallpaperPopoutElement&&curloader.item.opacity==1

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

}
