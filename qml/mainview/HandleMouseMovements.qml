import QtQuick 2.6

MouseArea {

    anchors.fill: parent

    hoverEnabled: true

    property point pressedPos: Qt.point(-1,-1)

    acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

    onPositionChanged: handleMousePositionChange(mouse.x, mouse.y)

    drag.target: settings.leftButtonMouseClickAndMove ? imageitem.returnImageContainer() : undefined

    onPressed: pressedPos = Qt.point(mouse.x, mouse.y)
    onReleased: shortcuts.analyseMouseEvent(pressedPos, mouse)

    onWheel: shortcuts.analyseWheelEvent(wheel)

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
