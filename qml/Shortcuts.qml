import QtQuick 2.3
import QtQuick.Controls 1.2

Item {
    Action {
        shortcut: "Right"
         onTriggered:
             thumbnailBar.nextImage()
    }
    Action {
        shortcut: "Space"
         onTriggered:
             thumbnailBar.nextImage()
    }
    Action {
        shortcut: "Left"
         onTriggered:
             thumbnailBar.previousImage()
    }
    Action {
        shortcut: "Backspace"
         onTriggered:
             thumbnailBar.previousImage()
    }
    Action {
        shortcut: "Escape"
        onTriggered:
            Qt.quit()
    }
    Action {
        shortcut: "O"
        onTriggered:
            openFile()
    }
    Action {
        shortcut: "0"
        onTriggered:
            image.resetZoom()
    }
    Action {
        shortcut: "Ctrl++"
        onTriggered:
            image.zoomIn()
    }
    Action {
        shortcut: "+"
        onTriggered:
            image.zoomIn()
    }
    Action {
        shortcut: "Ctrl+-"
        onTriggered:
            image.zoomOut()
    }
    Action {
        shortcut: "-"
        onTriggered:
            image.zoomOut()
    }
}
