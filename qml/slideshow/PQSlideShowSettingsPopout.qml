import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: slideshow_window

    Component.onCompleted: {
        slideshow_window.setX(windowgeometry.slideshowWindowGeometry.x)
        slideshow_window.setY(windowgeometry.slideshowWindowGeometry.y)
        slideshow_window.setWidth(windowgeometry.slideshowWindowGeometry.width)
        slideshow_window.setHeight(windowgeometry.slideshowWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.slideshowWindowGeometry = Qt.rect(slideshow_window.x, slideshow_window.y, slideshow_window.width, slideshow_window.height)
        windowgeometry.slideshowWindowMaximized = (slideshow_window.visibility==Window.Maximized)

        if(variables.visibleItem == "slideshowsettings")
            variables.visibleItem = ""
    }

    visible: PQSettings.slideShowSettingsPopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onSlideshowPopoutElementChanged: {
            if(!PQSettings.slideShowSettingsPopoutElement)
                slideshow_window.visible = Qt.binding(function() { return PQSettings.slideShowSettingsPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQSlideShowSettings.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return slideshow_window.width })
                item.parentHeight = Qt.binding(function() { return slideshow_window.height })
            }
    }

}
