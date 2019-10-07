import QtQuick 2.9

import "../../elements"

//********//
// PLASMA 5

Column {

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    onVisibleChanged: {
        if(visible)
            check()
    }

    property var checkedScreens: []

    Text {
        x: (parent.width-width)/2
        color: "white"
        font.pointSize: 15
        text: "Plasma 5"
        font.bold: true
    }

    Item {
        width: 1
        height: 10
    }

    Text {
        x: (parent.width-width)/2
        color: "white"
        font.pointSize: 15
        //: As in 'set wallpaper to which screens'
        text: em.pty+qsTranslate("wallpaper", "Set to which screens")
    }

    Column {
        x: (parent.width-width)/2
        width: childrenRect.width
        id: desk_col
        Repeater {
            model: numDesktops
            PQCheckbox {
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

    function check() {

        wallpaper_top.numDesktops = handlingWallpaper.getScreenCount()
        checkedScreens = []
        for(var i = 0; i < wallpaper_top.numDesktops; ++i)
            checkedScreens.push(i+1)

    }

}
