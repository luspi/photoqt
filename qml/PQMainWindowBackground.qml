/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

        function onInterfaceBackgroundSolidChanged() {
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

    }

}
