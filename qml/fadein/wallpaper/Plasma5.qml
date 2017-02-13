import QtQuick 2.3

Rectangle {

    property bool currentlySelected: false

    visible: currentlySelected

    color: "#00000000"
    width: childrenRect.width
    height: (currentlySelected ? childrenRect.height : 10)

    Text {

        width: wallpaper_top.width*0.75
        x: (wallpaper_top.width-width)/2
        color: colour.text_warning
        font.bold: true
        font.pointSize: 10
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Sorry, Plasma 5 doesn't yet offer the feature to change the wallpaper except from their own system settings. Hopefully this will change soon, but until then there's nothing I can do about that.")

    }

}
