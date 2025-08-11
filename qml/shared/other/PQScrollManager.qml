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

Loader {

    id: ldrtop

    // this is the flickable to attach to
    property Flickable flickable

    // changing the cursor shape if desired
    property int cursorShape: Qt.ArrowCursor

    active: PQCSettings.interfaceFlickAdjustSpeed

    asynchronous: true
    sourceComponent:
        Item {

            id: managertop

            // cache the previous contentY
            property int prevContentY: 0

            // counter for detecting touchpad events
            property int likelyTouchPad: 0

            // increase the speed in a few steps when continued scrolling
            property int flickSpeedCounter: 1

            Connections {

                target: ldrtop.flickable

                function onContentYChanged() {
                    // we only react to changes if NO flick is currently happening
                    // we check for a change of at least 10 as this should filter out any pixel-perfect touchpad events
                    if(!ldrtop.flickable.flicking && ldrtop.flickable.contentY >= 0 && Math.abs(managertop.prevContentY-ldrtop.flickable.contentY) > 10) {
                        ldrtop.flickable.flick(0, (ldrtop.flickable.verticalVelocity < 0 ? 300 : -300))
                    }

                    // cache previous contentY
                    managertop.prevContentY = ldrtop.flickable.contentY

                }

                // make sure we are inside bounds
                function onFlickEnded() {
                    ldrtop.flickable.returnToBounds()
                }
            }

            // reset touchpad counter
            Timer {
                id: resetLikelyTouchPad
                interval: 1000
                onTriggered:
                    managertop.likelyTouchPad = 0
            }

            MouseArea {

                width: ldrtop.flickable.width
                height: ldrtop.flickable.height

                // this is only enabled when a flick is currently happening and no touchpad has been used
                enabled: ldrtop.flickable.flicking && managertop.likelyTouchPad < 5

                cursorShape: ldrtop.cursorShape

                onWheel: (wheel) => {

                    // ignore touchpad events
                    if(Math.abs(wheel.angleDelta.y)%60 != 0 || managertop.likelyTouchPad > 5) {
                        managertop.likelyTouchPad += 1
                        resetLikelyTouchPad.restart()
                        return
                    }

                    // reset touchpad counter
                    managertop.likelyTouchPad = 0

                    // prepare velocity variable
                    var vel = 0

                    // scrolling up
                    if(wheel.angleDelta.y < 0) {

                        // scroll up again
                        if(ldrtop.flickable.verticalVelocity > 0) {

                            // increase counter and set speed
                            managertop.flickSpeedCounter = Math.min(managertop.flickSpeedCounter+1, 5)
                            vel = -600

                        // scroll up first time
                        } else if(ldrtop.flickable.verticalVelocity < 0) {

                            // stop current flick and reset counter
                            ldrtop.flickable.cancelFlick()
                            managertop.flickSpeedCounter = 1
                            vel = 0

                        }

                    // scrolling down
                    } else if(wheel.angleDelta.y > 0) {

                        // scroll down first time
                        if(ldrtop.flickable.verticalVelocity > 0) {

                            // stop current flick and reset counter
                            ldrtop.flickable.cancelFlick()
                            managertop.flickSpeedCounter = 1
                            vel = 0

                        // scroll down again
                        } else if(ldrtop.flickable.verticalVelocity < 0) {

                            // increase counter and set speed
                            managertop.flickSpeedCounter = Math.min(managertop.flickSpeedCounter+1, 5)
                            vel = 600

                        }

                    }

                    // flick view
                    ldrtop.flickable.flick(0, PQCSettings.interfaceFlickAdjustSpeedSpeedup*0.5*managertop.flickSpeedCounter*vel)

                }

            }

        }

}
