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
     * If the video has any sort of orientation already embedded, w e prioritize that one and ignore our calculations
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

    opacity: 0

    PQCMPVObject {

        id: mediaplayer

        width: videotop.width
        height: videotop.height

    }

    rotation: videoAlreadyTransformed ? 0 : videotop.forceRotation

    property bool videoAlreadyTransformed: false
    property int alreadyRotated: 0

    property bool videoFileLoaded: false

    // Without this, the video might not be loaded properly or fail altogether
    // It might also cause a seperate instance to be halfway setup with PhotoQt freezing
    // A small timeout like this is enough to avoid all of this
    Timer {
        interval: 100
        running: true
        onTriggered: {
            mediaplayer.command(["loadfile", videotop.sourceCache])
            videotop.videoFileLoaded = true
            if(!PQCSettings.filetypesMotionAutoPlay) {
                mediaplayer.command(["set", "pause", "yes"])
                videotop.opacity = 0
                PQCConstants.motionPhotoIsPlaying = false
            } else {
                videotop.opacity = 1
                PQCConstants.motionPhotoIsPlaying = true
            }
            checkEOF.start()
            checkOrientation.start()
        }
    }

    Timer {
        id: checkOrientation
        interval: 100
        running: false
        onTriggered: {
            var val = mediaplayer.getProperty("video-params/rotate")
            if(!mediaplayer.isError(val)) {
                alreadyRotated = val
                videoAlreadyTransformed = (alreadyRotated!=0 || alreadyRotated==videotop.forceRotation)
            }
        }
    }

    Timer {
        id: checkEOF
        interval: PQCConstants.motionPhotoIsPlaying ? 250 : 500
        repeat: true
        running: false
        onTriggered: {
            if(!videotop.isMainImage) return
            if(mediaplayer.getProperty("eof-reached")) {
                videotop.videoFileLoaded = false
                PQCConstants.motionPhotoIsPlaying = false
                videotop.opacity = 0
            }
        }
    }

    Connections {

        target: PQCNotify

        function onPlayPauseAnimationVideo() {

            if(!videotop.isMainImage)
                return

            if(!PQCConstants.motionPhotoIsPlaying && videotop.videoFileLoaded) {
                mediaplayer.command(["set", "pause", "no"])
                PQCConstants.motionPhotoIsPlaying = true
            } else if(!PQCConstants.motionPhotoIsPlaying && !videotop.videoFileLoaded) {
                mediaplayer.command(["loadfile", videotop.sourceCache])
                PQCConstants.motionPhotoIsPlaying = true
                videotop.videoFileLoaded = true
                videotop.opacity = 1
            } else {
                mediaplayer.command(["set", "pause", "yes"])
                PQCConstants.motionPhotoIsPlaying = false
            }

        }

    }

}
