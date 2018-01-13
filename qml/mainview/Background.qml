import QtQuick 2.6

Rectangle {

    id: top

    anchors.fill: parent

    color: settings.composite ? getanddostuff.addAlphaToColor(Qt.rgba(settings.bgColorRed, settings.bgColorGreen, settings.bgColorBlue, settings.bgColorAlpha), settings.bgColorAlpha)
                                  : "#00000000"
    // Fake transparency
    Image {
        id: fake
        anchors.fill: parent
        visible: !settings.composite && settings.backgroundImageScreenshot
        source: (!settings.composite && settings.backgroundImageScreenshot) ? "file:/" + getanddostuff.getTempDir() +"/photoqt_screenshot_" + getanddostuff.getCurrentScreen(toplevel.windowx,toplevel.windowy) + ".jpg" : ""
        cache: false
        Rectangle {
            anchors.fill: parent
            visible: parent.visible
            color: getanddostuff.addAlphaToColor(Qt.rgba(settings.bgColorRed, settings.bgColorGreen, settings.bgColorBlue, settings.bgColorAlpha), settings.bgColorAlpha)
        }
    }
    function reloadScreenshot() {
        verboseMessage("Background::reloadScreenshot()","")
        fake.source = ""
        if(!settings.composite && settings.backgroundImageScreenshot)
            fake.source = "file:/" + getanddostuff.getTempDir() +"/photoqt_screenshot_" + getanddostuff.getCurrentScreen(toplevel.windowx+background.width/2,toplevel.windowy+background.height/2) + ".jpg"
    }

    // Background screenshot
    Image {
        visible: settings.backgroundImageUse
        anchors.fill: parent
        horizontalAlignment: settings.backgroundImageCenter ? Image.AlignHCenter : Image.AlignLeft
        verticalAlignment: settings.backgroundImageCenter ? Image.AlignVCenter : Image.AlignTop
        fillMode: settings.backgroundImageScale ? Image.PreserveAspectFit
                                                : (settings.backgroundImageScaleCrop ? Image.PreserveAspectCrop
                                                    : (settings.backgroundImageStretch ? Image.Stretch
                                                        : (settings.backgroundImageTile ? Image.Tile : Image.Pad)))
        source: settings.backgroundImagePath
        Rectangle {
            anchors.fill: parent
            visible: parent.visible
            color: getanddostuff.addAlphaToColor(Qt.rgba(settings.bgColorRed, settings.bgColorGreen, settings.bgColorBlue, settings.bgColorAlpha), settings.bgColorAlpha)
        }

    }

    // BACKGROUND COLOR
    Rectangle {
        anchors.fill: parent
        // The Qt.rgba() function IGNORES the alpha value by default (that's why above we use a custom function to add it!)
        color: Qt.rgba(settings.bgColorRed,settings.bgColorGreen,settings.bgColorBlue,settings.bgColorAlpha)
        visible: !settings.composite && !settings.backgroundImageScreenshot && !settings.backgroundImageUse
    }

    Text {

        anchors.fill: parent
        visible: variables.currentFile=="" && !variables.deleteNothingLeft && !variables.filterNoMatch
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 50
        color: colour.bg_label
        wrapMode: Text.WordWrap
        font.bold: true
        text: qsTr("Open a file to begin")
        opacity: variables.guiBlocked ? 0.2 : 1
        Behavior on opacity { NumberAnimation { duration: 200 } }

    }

    Text {

        anchors.fill: parent
        visible: variables.deleteNothingLeft
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 50
        color: colour.bg_label
        wrapMode: Text.WordWrap
        font.bold: true
        text: qsTr("Folder is now empty")
        opacity: variables.guiBlocked ? 0.2 : 1
        Behavior on opacity { NumberAnimation { duration: 200 } }

    }

    Text {

        anchors.fill: parent
        visible: variables.filterNoMatch
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 50
        color: colour.bg_label
        wrapMode: Text.WordWrap
        font.bold: true
        text: qsTr("No image matches selected filter")
        opacity: variables.guiBlocked ? 0.2 : 1
        Behavior on opacity { NumberAnimation { duration: 200 } }

    }

    // Arrow pointing to metadata widget
    Image {
        id: metadataarrow
        visible: variables.currentFile=="" && !variables.deleteNothingLeft && !variables.filterNoMatch
        opacity: variables.guiBlocked ? 0.2 : 1
        x: 0
        y: metadata.y+metadata.height/2-height/2
        source: "qrc:/img/arrowleft.png"
        width: 150
        height: 60
    }

    // Arrow pointing to mainmenu widget
    Image {
        id: mainmenuarrow
        visible: variables.currentFile=="" && !variables.deleteNothingLeft && !variables.filterNoMatch
        opacity: variables.guiBlocked ? 0.2 : 1
        x: background.width-width-5
        y: mainmenu.y+mainmenu.height/2-height/2
        source: "qrc:/img/arrowright.png"
        width: 150
        height: 60
    }

}
