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
import PhotoQt.Integrated
import PhotoQt.Shared

Item {

    PQMenu {

        id: rightclickmenu

        property bool resetPosAfterHide: false

        PQMenuItem {
            iconSource: PQCConstants.currentlyShowingVideoPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
            text: PQCConstants.currentlyShowingVideoPlaying ? qsTranslate("image", "Pause video") : qsTranslate("image", "Play video")
            onTriggered: {
                PQCNotify.playPauseAnimationVideo()
            }
        }

        PQMenuItem {
            id: volmenuitem
            //: refers to muting sound
            text: PQCSettings.filetypesVideoVolume===0 ?qsTranslate("image", "Unmute") : qsTranslate("image", "Mute")
            onTriggered: {
                PQCNotify.currentVideoMuteUnmute()
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
            text: PQCSettings.filetypesVideoLeftRightJumpVideo ? qsTranslate("image", "Unlock arrow keys") : qsTranslate("image", "Lock arrow keys")
            onTriggered: {
                PQCSettings.filetypesVideoLeftRightJumpVideo = !PQCSettings.filetypesVideoLeftRightJumpVideo
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
            text: qsTranslate("image", "Reset position")
            onTriggered: {
                rightclickmenu.resetPosAfterHide = true
            }
        }

        onVisibleChanged: {
            if(!visible && resetPosAfterHide) {
                resetPosAfterHide = false
                PQCNotify.currentVideoControlsResetPosition()
            }
        }

    }

    Connections {

        target: PQCNotify

        function onShowVideoControlsContextMenu() {
            rightclickmenu.popup()
        }

    }

}
