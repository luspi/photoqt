import QtQuick

import PQCNotify
import PQCScriptsOther
import PQCScriptsFilesPaths

Item {

    anchors.fill: parent

    Image {
        id: bgimage
        anchors.fill: parent
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
    }

    function setBackground() {
        if(PQCSettings.interfaceBackgroundSolid) {
            bgimage.source = ""
            overlay.color = PQCLook.baseColor
        } else if(PQCSettings.interfaceBackgroundImageUse) {
            bgimage.source = "image://full/" + PQCSettings.interfaceBackgroundImagePath
            if(PQCSettings.interfaceBackgroundImageScale)
                bgimage.fillMode = Image.PreserveAspectFit
            else if(PQCSettings.interfaceBackgroundImageScaleCrop)
                bgimage.fillMode = Image.PreserveAspectCrop
            else if(PQCSettings.interfaceBackgroundImageStretch)
                bgimage.fillMode = Image.Stretch
            else if(PQCSettings.interfaceBackgroundImageCenter)
                bgimage.fillMode = Image.Pad
            else
                bgimage.fillMode = Image.Tile
            toplevel.color = PQCLook.baseColor
            overlay.color = PQCLook.transColor
        } else if(PQCSettings.interfaceBackgroundImageScreenshot && PQCNotify.haveScreenshots) {
            var sc = PQCScriptsOther.getCurrentScreen(fullscreenitem.mapToGlobal(toplevel.x+toplevel.width/2, toplevel.y+toplevel.height/2))
            bgimage.source = "image://full/" + PQCScriptsFilesPaths.getTempDir() + "/photoqt_screenshot_" + sc + ".jpg"
            bgimage.fillMode = Image.PreserveAspectCrop
        } else {
            bgimage.source = ""
            overlay.color = PQCLook.transColor
            toplevel.color = "transparent"
        }
    }

    Timer {
        id: resetBG
        interval: 500
        onTriggered:
            setBackground()
    }

    Connections {
        target: PQCSettings

        function oninterfaceBackgroundSolidChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImageUseChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImagePathChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImageScaleChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImageScaleCropChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImageStretchChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImageCenterChanged() {
            resetBG.restart()
        }

        function oninterfaceBackgroundImageScreenshotChanged() {
            resetBG.restart()
        }

    }

}
