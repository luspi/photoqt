/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import QtMultimedia
import PhotoQt

Item {

    id: videotop

    property string sourceCache: ""
    property bool isMainImage: false
    property int forceRotation: 0

    Video {

        id: mediaplayer

        anchors.fill: parent
        anchors.margins: rotation%180==0 ? 0 : -(videotop.height-videotop.width)/2

        rotation: videotop.forceRotation

        source: "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.sourceCache)

        Component.onCompleted: {
            if(PQCSettings.filetypesMotionAutoPlay)
                play()
        }
        onPlaybackStateChanged: {
            PQCConstants.motionPhotoIsPlaying = (mediaplayer.playbackState == MediaPlayer.PlayingState)
        }

        Connections {

            target: PQCNotify

            function onPlayPauseAnimationVideo() {

                if(!videotop.isMainImage)
                    return

                if(mediaplayer.playbackState == MediaPlayer.PausedState)
                    mediaplayer.play()
                else if(mediaplayer.playbackState == MediaPlayer.StoppedState) {
                    mediaplayer.source = "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.sourceCache)
                    mediaplayer.play()
                } else
                    mediaplayer.pause()

            }

        }

    }

}
