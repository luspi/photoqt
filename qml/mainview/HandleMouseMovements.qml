import QtQuick 2.6

MouseArea {

    anchors.fill: parent

    hoverEnabled: true
    propagateComposedEvents: true

    onPositionChanged: {
        handleMousePositionChange(mouse.x, mouse.y)
    }

    // We pass those on to below, to keep the main image movable
    onClicked: mouse.accepted = false
    onPressed: mouse.accepted = false
    onReleased: mouse.accepted = false
    onPressAndHold: mouse.accepted = false

    function handleMousePositionChange(xPos, yPos) {

        var w = settings.menusensitivity*5

        if(xPos > mainwindow.width-w)
            mainmenu.show()
        else
            mainmenu.hide()

        if(xPos < w)
            metadata.show()
        else
            metadata.hide()

        if(yPos > mainwindow.height-w)
            call.show("thumbnails")
        else
            call.hide("thumbnails")

        if(yPos < w)
            call.show("slideshowbar")
        else
            call.hide("slideshowbar")

    }

}
