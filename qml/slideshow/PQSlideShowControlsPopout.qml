import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: slideshowcontrols_window

    Component.onCompleted: {
        slideshowcontrols_window.x = windowgeometry.slideshowControlsWindowGeometry.x
        slideshowcontrols_window.y = windowgeometry.slideshowControlsWindowGeometry.y
        slideshowcontrols_window.width = windowgeometry.slideshowControlsWindowGeometry.width
        slideshowcontrols_window.height = windowgeometry.slideshowControlsWindowGeometry.height
    }

    minimumWidth: 200
    minimumHeight: 200

    modality: Qt.NonModal

    onClosing: {

        windowgeometry.slideshowControlsWindowGeometry = Qt.rect(slideshowcontrols_window.x, slideshowcontrols_window.y, slideshowcontrols_window.width, slideshowcontrols_window.height)
        windowgeometry.slideshowControlsWindowMaximized = (slideshowcontrols_window.visibility==Window.Maximized)

        loader.passOn("slideshowcontrols", "quit", undefined)

        if(variables.visibleItem == "slideshowcontrols")
            variables.visibleItem = ""

    }

    visible: PQSettings.slideShowControlsPopoutElement

    color: "#88000000"

    Loader {
        source: "PQSlideShowControls.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return slideshowcontrols_window.width })
                item.parentHeight = Qt.binding(function() { return slideshowcontrols_window.height })
                slideshowcontrols_window.minimumHeight  = item.childrenRect.height
                slideshowcontrols_window.minimumWidth  = item.childrenRect.width
            }
    }

}
