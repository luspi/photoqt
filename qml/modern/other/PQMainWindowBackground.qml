/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick
import PhotoQt

Item {

    id: mwbg

    anchors.fill: parent

    Image {
        id: bgimage
        anchors.fill: parent
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
    }

    Component.onCompleted: {
        setBackground()
    }

    function setBackground() {
        if(PQCSettings.interfaceBackgroundSolid) { // qmllint disable unqualified
            bgimage.source = ""
            overlay.color = PQCSettings.interfaceBackgroundCustomOverlay ? PQCSettings.interfaceBackgroundCustomOverlayColor : PQCLook.baseColor
        } else if(PQCSettings.interfaceBackgroundImageUse) {
            if(PQCSettings.interfaceBackgroundImagePath !== "")
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
            toplevel.color = PQCSettings.interfaceBackgroundCustomOverlay ? PQCSettings.interfaceBackgroundCustomOverlayColor : PQCLook.baseColor
            overlay.color = PQCSettings.interfaceBackgroundCustomOverlay ? PQCScriptsOther.addAlphaToColor(PQCSettings.interfaceBackgroundCustomOverlayColor, 222) : PQCLook.transColor
        } else if(PQCSettings.interfaceBackgroundImageScreenshot && PQCNotify.haveScreenshots) {
            var sc = PQCScriptsOther.getCurrentScreen(fullscreenitem.mapToGlobal(toplevel.x+toplevel.width/2, toplevel.y+toplevel.height/2))
            bgimage.source = "image://full/" + PQCScriptsFilesPaths.getTempDir() + "/photoqt_screenshot_" + sc + ".jpg"
            bgimage.fillMode = Image.PreserveAspectCrop
        } else if(PQCSettings.interfaceBackgroundFullyTransparent) {
            console.warn("Window background set to full transparency!")
            bgimage.source = ""
            overlay.color = "transparent"
            toplevel.color = "transparent"
        } else {
            bgimage.source = ""
            overlay.color = PQCSettings.interfaceBackgroundCustomOverlay ? PQCScriptsOther.addAlphaToColor(PQCSettings.interfaceBackgroundCustomOverlayColor, 222) : PQCLook.transColor
            toplevel.color = "transparent"
        }
    }

    Timer {
        id: resetBG
        interval: 500
        onTriggered:
            mwbg.setBackground()
    }

    Connections {
        target: PQCSettings // qmllint disable unqualified

        function onInterfaceAccentColorChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundSolidChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundFullyTransparentChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImageUseChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImagePathChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImageScaleChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImageScaleCropChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImageStretchChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImageCenterChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundImageScreenshotChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundCustomOverlayChanged() {
            resetBG.restart()
        }

        function onInterfaceBackgroundCustomOverlayColorChanged() {
            resetBG.restart()
        }

    }

}
