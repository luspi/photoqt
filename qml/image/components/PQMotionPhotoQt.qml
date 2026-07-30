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
    property bool forcedMirror: false

    /*
     * A FEW NOTES ABOUT ORIENTATION
     *
     * If a video is recorded with orientation, then the embedded video is ALSO rotated already.
     * We detect that based on the metaData below. If both values agree, we are done.
     * If the video has any sort of orientation already embedded, we prioritize that one and ignore our calculations
     * Mirroring is not something that a camera typically can do, so those are most likely done
     * afterwards by the user and this transformation still needs to be applied.
     *
     * If a photo was rotated by the user, that typically does not change the video, but there is no
     * reliable way to figure this out. We do our best, but there are cases where this might not work properly.
     *
     */

    transform:
        Rotation {
            origin.x: videotop.width/2
            origin.y: videotop.height/2
            axis { x: forceRotation%180==90; y: forceRotation%180==0; z: 0 }
            angle: videotop.forcedMirror ? 180 : 0
        }

    Video {

        id: mediaplayer

        anchors.fill: parent
        anchors.margins: rotation%180==0 ? 0 : -(videotop.height-videotop.width)/2

        rotation: videoAlreadyTransformed ? 0 : videotop.forceRotation

        property bool videoAlreadyTransformed: false
        property int alreadyRotated: 0

        source: "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.sourceCache)

        Component.onCompleted: {
            if(PQCSettings.filetypesMotionAutoPlay)
                play()
        }
        onPlaybackStateChanged: {
            PQCConstants.motionPhotoIsPlaying = (mediaplayer.playbackState == MediaPlayer.PlayingState)
        }

        onMetaDataChanged: {
            if(metaData.keys().includes(MediaMetaData.Orientation)) {
                alreadyRotated = metaData.value(MediaMetaData.Orientation)
                videoAlreadyTransformed = (alreadyRotated!=0 || alreadyRotated==videotop.forceRotation)
            }
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
