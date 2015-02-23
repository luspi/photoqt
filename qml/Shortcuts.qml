import QtQuick 2.3
import QtQuick.Controls 1.2

Item {
    Action {
        shortcut: "Right"
         onTriggered:
             if(!blocked)
                 thumbnailBar.nextImage()
    }
    Action {
        shortcut: "Space"
         onTriggered:
             if(!blocked)
                 thumbnailBar.nextImage()
    }
    Action {
        shortcut: "Left"
         onTriggered:
             if(!blocked)
                 thumbnailBar.previousImage()
    }
    Action {
        shortcut: "Backspace"
         onTriggered:
             if(!blocked)
                 thumbnailBar.previousImage()
    }
    Action {
        shortcut: "Escape"
        onTriggered:
            if(about.opacity == 1)
                about.hideAbout()
            else if(settingsitem.opacity == 1)
                settingsitem.hideSettings()
            else if(!blocked)
                Qt.quit()
    }
    Action {
        shortcut: "O"
        onTriggered:
            if(!blocked)
                openFile()
    }
    Action {
        shortcut: "0"
        onTriggered:
            if(!blocked)
                image.resetZoom()
    }
    Action {
        shortcut: "Ctrl+0"
        onTriggered:
            if(!blocked)
                image.resetRotation()
    }
    Action {
        shortcut: "Ctrl++"
        onTriggered:
            if(!blocked)
                image.zoomIn()
    }
    Action {
        shortcut: "+"
        onTriggered:
            if(!blocked)
                image.zoomIn()
    }
    Action {
        shortcut: "Ctrl+-"
        onTriggered:
            if(!blocked)
                image.zoomOut()
    }
    Action {
        shortcut: "-"
        onTriggered:
            if(!blocked)
                image.zoomOut()
    }

    Action {
        shortcut: "R"
        onTriggered:
            if(!blocked)
                image.rotateRight()
    }
    Action {
        shortcut: "L"
        onTriggered:
            if(!blocked)
                image.rotateLeft()
    }
    Action {
        shortcut: "I"
        onTriggered:
            if(!blocked)
                about.showAbout()
    }
    Action {
        shortcut: "E"
        onTriggered:
            if(!blocked)
                settingsitem.showSettings()
    }
}
