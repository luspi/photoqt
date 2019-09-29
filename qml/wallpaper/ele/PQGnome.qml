import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../elements"

//*************//
// GNOME/UNITY

Column {

    x: 0
    y: 0

    width: parent.width
    height: childrenRect.height

    spacing: 10

    property bool gsettingsError: true

    onVisibleChanged: {
        if(visible)
            check()
    }

    property string checkedOption: ""

    Text {
        x: (parent.width-width)/2
        color: "white"
        font.pointSize: 15
        text: "Gnome/Unity/Cinnamon"
        font.bold: true
    }

    Item {
        width: 1
        height: 10
    }

    Text {
        x: (parent.width-width)/2
        visible: gsettingsError
        color: "red"
        font.pointSize: 12
        font.bold: true
        text: "Warning: <i>gsettings</i> not found"
    }

    Item {
        visible: gsettingsError
        width: 1
        height: 10
    }

    Text {
        x: (parent.width-width)/2
        color: "white"
        font.pointSize: 15
        text: "Choose picture option"
    }

    Column {
        id: col
        x: (parent.width-width)/2
        width: childrenRect.width
        PQRadioButton {
            id: opt_wallpaper
            text: "wallpaper"
            checked: true
            Component.onCompleted:
                checkedOption = text
            onCheckedChanged:
                if(checked)
                    checkedOption = text
        }
        PQRadioButton {
            id: opt_centered
            text: "centered"
            onCheckedChanged:
                if(checked)
                    checkedOption = text
        }
        PQRadioButton {
            id: opt_scaled
            text: "scaled"
            onCheckedChanged:
                if(checked)
                    checkedOption = text
        }
        PQRadioButton {
            id: opt_zoom
            text: "zoom"
            onCheckedChanged:
                if(checked)
                    checkedOption = text
        }
        PQRadioButton {
            id: opt_spanned
            text: "spanned"
            onCheckedChanged:
                if(checked)
                    checkedOption = text
        }
    }

    function check() {

        wallpaper_top.numDesktops = handlingWallpaper.getScreenCount()
        gsettingsError = handlingWallpaper.checkGSettings()

    }

}
