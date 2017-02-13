import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

    id: background

    // BELOW ARE FOUR ELMENETS THAT CAN ACT AS BACKGROUND.
    // ONLY ONE OF THEM IS VISIBLE AT A TIME (DEPENDING ON SETTINGS)

    // True transparency
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

    /******* END BACKGROUND ELEMENTS **********/


    width: parent.width
    height: parent.height

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        // Hides everything when no other area is hovered
        onPositionChanged: {
            hideEverything()
        }

        // METADATA
        MouseArea {
            x: 0
            y: 0
            height: background.height-(thumbnailBar.y<background.height ? thumbnailBar.height : settings.menusensitivity*3)
            width: metaData.visible ? metaData.width : settings.menusensitivity*5
            hoverEnabled: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: if((softblocked == 0 || slideshowRunning) && metaData.opacity != 1 && !thumbnailBar.contains(Qt.point(localcursorpos.x,localcursorpos.y-thumbnailBar.y))) {
                               hideEverything()
                               showMetadata()
                           }
            }

        }

        // THUMBNAILBAR
        MouseArea {
            x: metaData.nonFloatWidth
            y: settings.thumbnailposition == "Bottom"
               ? (thumbnailBar.opacity == 0 ? background.height-settings.menusensitivity*5 : background.height-thumbnailBar.height)
               : 0
            width: background.width
            height: (thumbnailBar.opacity != 0 ? thumbnailBar.height : settings.menusensitivity*5)
            hoverEnabled: true

            onEntered: {
                hideEverything()
                thumbnailBar.show()
            }

        }

        // MAINMENU
        MouseArea {
            x: mainmenu.opacity == 0 ? background.width-settings.menusensitivity*5 : mainmenu.x
            y: 0
            width: mainmenu.opacity == 0 ? settings.menusensitivity*5 : mainmenu.width
            height: background.height
            hoverEnabled: true
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered:
                    if(softblocked == 0 && !thumbnailBar.contains(Qt.point(localcursorpos.x,localcursorpos.y-thumbnailBar.y))) {
                        hideEverything()
                        mainmenu.show()
                    }
            }
        }

    }

    // SLIDESHOWBAR
    MouseArea {
        x: 0
        y: 0
        width: background.width
        height: slideshowRunning ? ((slideshowbar.y <= -slideshowbar.height) ? 3*settings.menusensitivity : slideshowbar.height) : 0
        hoverEnabled: true
        onEntered: slideshowbar.showBar()
    }

    // Show elements
    function showMetadata(from_mainmenu) {
        if(settings.exifenablemousetriggering || (from_mainmenu !== undefined && from_mainmenu === true))
            metaData.show()
    }

    // Hide elements

    function hideEverything() {

        var thumbPos = Qt.point(localcursorpos.x-thumbnailBar.x,localcursorpos.y-thumbnailBar.y)
        var mainmenuPos = Qt.point(localcursorpos.x-mainmenu.x, localcursorpos.y)

        if(!thumbnailBar.contains(thumbPos))
            thumbnailBar.hide()
        if(!metaData.contains(localcursorpos) && !metaData.getButtonState())
            metaData.hide()
        if(!mainmenu.contains(mainmenuPos) || thumbnailBar.contains(thumbPos))
            mainmenu.hide()
        if(!slideshowbar.contains(localcursorpos))
            slideshowbar.hideBar()
    }
    function hideMetadata() {
        metaData.uncheckCheckbox()
        metaData.hide()
    }

}
