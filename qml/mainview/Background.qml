import QtQuick 2.5

Rectangle {

    id: top

    anchors.fill: parent

    color: settings.composite ? getanddostuff.convertRgbaToHex(settings.backgroundColorRed, settings.backgroundColorGreen, settings.backgroundColorBlue, settings.backgroundColorAlpha) : "#00000000"

    // Fake transparency
    Image {
        id: fake
        anchors.fill: parent
        visible: !settings.composite && settings.backgroundImageScreenshot
        source: (!settings.composite && settings.backgroundImageScreenshot) ? "file:/" + getanddostuff.getTempDir() +"/photoqt_screenshot_" + getanddostuff.getCurrentScreen(variables.windowXY.x, variables.windowXY.y) + ".jpg" : ""
        cache: false
        Rectangle {
            anchors.fill: parent
            visible: parent.visible
            color: getanddostuff.convertRgbaToHex(settings.backgroundColorRed, settings.backgroundColorGreen, settings.backgroundColorBlue, settings.backgroundColorAlpha)
        }
    }
    function reloadScreenshot() {
        verboseMessage("MainView/Background", "reloadScreenshot()")
        fake.source = ""
        if(!settings.composite && settings.backgroundImageScreenshot)
            fake.source = "file:/" + getanddostuff.getTempDir() +"/photoqt_screenshot_" + getanddostuff.getCurrentScreen(variables.windowXY.x+background.width/2,variables.windowXY.y+background.height/2) + ".jpg"
    }

    // Background screenshot
    Image {
        visible: settings.backgroundImageUse
        anchors.fill: parent
        horizontalAlignment: settings.backgroundImageCenter||settings.backgroundImageScale ? Image.AlignHCenter : Image.AlignLeft
        verticalAlignment: settings.backgroundImageCenter||settings.backgroundImageScale ? Image.AlignVCenter : Image.AlignTop
        fillMode: settings.backgroundImageScale ? Image.PreserveAspectFit
                                                : (settings.backgroundImageScaleCrop ? Image.PreserveAspectCrop
                                                    : (settings.backgroundImageStretch ? Image.Stretch
                                                        : (settings.backgroundImageTile ? Image.Tile : Image.Pad)))
        source: getanddostuff.doesThisExist(settings.backgroundImagePath) ? settings.backgroundImagePath : "qrc:/img/plainerrorimg.png"
        Rectangle {
            anchors.fill: parent
            visible: parent.visible
            color: getanddostuff.convertRgbaToHex(settings.backgroundColorRed, settings.backgroundColorGreen, settings.backgroundColorBlue, settings.backgroundColorAlpha)
        }

    }

    // BACKGROUND COLOR
    Rectangle {
        anchors.fill: parent
        color: getanddostuff.convertRgbaToHex(settings.backgroundColorRed, settings.backgroundColorGreen, settings.backgroundColorBlue, settings.backgroundColorAlpha)
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
        text: em.pty+qsTr("Open a file to begin")
        opacity: variables.guiBlocked ? 0.2 : 1
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

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
        text: em.pty+qsTr("Folder is now empty")
        opacity: variables.guiBlocked ? 0.2 : 1
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

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
        text: em.pty+qsTr("No image matches selected filter")
        opacity: variables.guiBlocked ? 0.2 : 1
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

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
