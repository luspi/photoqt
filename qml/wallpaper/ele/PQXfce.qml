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

    property bool xfconfQueryError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property var checkedScreens: []
    property string checkedOption: ""

    Text {
        x: (parent.width-width)/2
        color: "white"
        font.pointSize: 15
        text: "XFCE 4"
        font.bold: true
    }

    Item {
        width: 1
        height: 10
    }

    Text {
        x: (parent.width-width)/2
        visible: xfconfQueryError
        color: "red"
        font.pointSize: 12
        font.bold: true
        text: em.pty+qsTranslate("wallpaper", "Warning: %1 not found").arg("<i>xfconf-query</i>")
    }

    Item {
        visible: xfconfQueryError
        width: 1
        height: 10
    }

    Column {

        id: col

        spacing: 10
        width: parent.width
        height: childrenRect.height

        Text {
            x: (parent.width-width)/2
            color: "white"
            font.pointSize: 15
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

        Text {
            x: (parent.width-width)/2
            color: "white"
            font.pointSize: 15
            //: picture option refers to how to format a pictrue when setting it as wallpaper
            text: em.pty+qsTranslate("wallpaper", "Choose picture option")
        }

        PQComboBox {
            x: (parent.width-width)/2
            model: ListModel {
                id: model
                ListElement { text: "Automatic" }
                ListElement { text: "Centered" }
                ListElement { text: "Tiled" }
                ListElement { text: "Stretched" }
                ListElement { text: "Scaled" }
                ListElement { text: "Zoomed" }
            }
            onCurrentIndexChanged: {
                checkedOption = currentText
            }
        }

    }

    function check() {

        wallpaper_top.numDesktops = handlingWallpaper.getScreenCount()
        xfconfQueryError = handlingWallpaper.checkXfce()

    }

}
