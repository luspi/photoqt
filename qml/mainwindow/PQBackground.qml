/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Window 2.2
import "../elements"

Item {

    width: parent.width
    height: parent.height

    property bool isStartupMessageShown: emptymessage.visible

    Image {

        id: bgimage

        anchors.fill: parent

        source: PQSettings.interfaceBackgroundImageScreenshot ?
                    ("image://full/" + handlingFileDir.getTempDir() + "/photoqt_screenshot_0.jpg") :
                    (PQSettings.interfaceBackgroundImageUse ? ("image://full/"+PQSettings.interfaceBackgroundImagePath) : "")

        fillMode: PQSettings.interfaceBackgroundImageScale ?
                      Image.PreserveAspectFit :
                      PQSettings.interfaceBackgroundImageScaleCrop ?
                          Image.PreserveAspectCrop :
                          PQSettings.interfaceBackgroundImageStretch ?
                              Image.Stretch :
                              PQSettings.interfaceBackgroundImageCenter ?
                                  Image.Pad :
                                  Image.Tile

        Rectangle {

            anchors.fill: parent

            color: (toplevel.visibility==Window.FullScreen&&PQSettings.interfaceFullscreenOverlayColorDifferent) ?
                       Qt.rgba(PQSettings.interfaceFullscreenOverlayColorRed/255.0,
                                  PQSettings.interfaceFullscreenOverlayColorGreen/255.0,
                                  PQSettings.interfaceFullscreenOverlayColorBlue/255.0,
                                  PQSettings.interfaceFullscreenOverlayColorAlpha/255.0) :
                        Qt.rgba(PQSettings.interfaceOverlayColorRed/255.0,
                                   PQSettings.interfaceOverlayColorGreen/255.0,
                                   PQSettings.interfaceOverlayColorBlue/255.0,
                                   PQSettings.interfaceOverlayColorAlpha/255.0)

            Behavior on color { ColorAnimation { duration: 200 } }

        }

    }

    Item {
        id: emptymessage
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: parent.width-160
        height: col.height
        visible: filefoldermodel.current==-1&&!filefoldermodel.filterCurrentlyActive&&variables.startupCompleted
        Column {
            id: col
            spacing: 5
            Text {
                id: openmessage
                width: emptymessage.width
                //: Part of the message shown in the main view before any image is loaded
                text: em.pty+qsTranslate("other", "Click anywhere to open a file")
                font.pointSize: Math.min(60, Math.max(20, (toplevel.width+toplevel.height)/60))
                font.bold: true
                color: "#c0c0c0"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                width: emptymessage.width
                //: Part of the message shown in the main view before any image is loaded
                text: em.pty+qsTranslate("other", "Move your cursor to:")
                font.pointSize: Math.min(40, Math.max(15, (toplevel.width+toplevel.height)/90))
                font.bold: true
                color: "#c0c0c0"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                width: emptymessage.width
                //: Part of the message shown in the main view before any image is loaded, first option for where to move cursor to
                text: ">> " + em.pty+qsTranslate("other", "RIGHT EDGE for the main menu")
                font.pointSize: Math.max(10, (toplevel.width+toplevel.height)/130)
                font.bold: true
                color: "#c0c0c0"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                width: emptymessage.width
                visible: PQSettings.metadataElementBehindLeftEdge
                //: Part of the message shown in the main view before any image is loaded, second option for where to move cursor to
                text: ">> " + em.pty+qsTranslate("other", "LEFT EDGE for the metadata")
                font.pointSize: Math.max(10, (toplevel.width+toplevel.height)/130)
                font.bold: true
                color: "#c0c0c0"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Column {
                Text {
                    width: emptymessage.width
                    //: Part of the message shown in the main view before any image is loaded, third option for where to move cursor to
                    text: ">> " + em.pty+qsTranslate("other", "BOTTOM EDGE to show the thumbnails")
                    font.pointSize: Math.min(30, Math.max(10, (toplevel.width+toplevel.height)/130))
                    font.bold: true
                    color: "#c0c0c0"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: emptymessage.width
                    //: Part of the message shown in the main view before any image is loaded
                    text: em.pty+qsTranslate("other", "(once an image/folder is loaded)")
                    font.pointSize: Math.min(30, Math.max(10, (toplevel.width+toplevel.height)/130))
                    font.bold: true
                    color: "#c0c0c0"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Text {
        id: filtermessage
        anchors.centerIn: parent
        //: Used as in: No matches found for the currently set filter
        text: em.pty+qsTranslate("other", "No matches found")
        visible: filefoldermodel.current==-1&&filefoldermodel.filterCurrentlyActive
        font.pointSize: Math.min(60, Math.max(20, (toplevel.width+toplevel.height)/60))
        font.bold: true
        color: "#bb808080"
    }

    Item {

        id: edgearrows
        anchors.fill: parent

        visible: emptymessage.visible && variables.startupCompleted

        Image {
            id: arrleft
            x: 10
            y: (parent.height-height)/2
            visible: PQSettings.metadataElementBehindLeftEdge
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/leftarrow.svg"

            SequentialAnimation on x {
                loops: Animation.Infinite

                running: visible

                // move out quick
                NumberAnimation {
                    from: 10
                    to: 30
                    easing.type: Easing.OutExpo
                    duration: 500
                }

                // bounce back in
                NumberAnimation {
                    from: 30
                    to: 10
                    easing.type: Easing.OutBounce
                    duration: 1000
                }

                // short pause
                PauseAnimation { duration: 500 }
            }

        }

        PQText {

            id: arrlefttxt

            y: arrleft.y + (arrleft.height-height)/2
            text: em.pty+qsTranslate("metadata", "Metadata")

            SequentialAnimation on x {

                id: seqlefttxt

                loops: Animation.Infinite

                running: visible

                // move out at same speed as arrow animation
                NumberAnimation {
                    from: arrleft.width+10 + 10
                    to: arrleft.width+10 + 30
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: seqlefttxt.restart()
                    onToChanged: seqlefttxt.restart()
                }

                // move in with delay
                NumberAnimation {
                    from: arrleft.width+10 + 30
                    to: arrleft.width+10 + 10
                    easing.type: Easing.InExpo
                    duration: 1300
                    onFromChanged: seqlefttxt.restart()
                    onToChanged: seqlefttxt.restart()
                }

                // short pause
                PauseAnimation { duration: 200 }
            }

        }

        Image {
            id: arrright
            x: parent.width-width-10
            y: (parent.height-height)/2
            visible: !PQSettings.interfacePopoutMainMenu
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/rightarrow.svg"

            SequentialAnimation on x {

                id: seqright

                loops: Animation.Infinite

                running: visible

                // move out quick
                NumberAnimation {
                    from: toplevel.width-110
                    to: toplevel.width-130
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: seqright.restart()
                    onToChanged: seqright.restart()
                }

                // bounce back in
                NumberAnimation {
                    from: toplevel.width-130
                    to: toplevel.width-110
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: seqright.restart()
                    onToChanged: seqright.restart()
                }

                // short pause
                PauseAnimation { duration: 500 }
            }

        }

        PQText {

            id: arrrighttxt

            y: arrright.y + (arrright.height-height)/2
            text: em.pty+qsTranslate("MainMenu", "Main menu")

            SequentialAnimation on x {

                id: seqrighttxt

                loops: Animation.Infinite

                running: visible

                // move out at same speed as arrow animation
                NumberAnimation {
                    from: toplevel.width-110 - arrrighttxt.width-10
                    to: toplevel.width-130 - arrrighttxt.width-10
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: seqrighttxt.restart()
                    onToChanged: seqrighttxt.restart()
                }

                // move in with delay
                NumberAnimation {
                    from: toplevel.width-130 - arrrighttxt.width-10
                    to: toplevel.width-110 - arrrighttxt.width-10
                    easing.type: Easing.InExpo
                    duration: 1300
                    onFromChanged: seqrighttxt.restart()
                    onToChanged: seqrighttxt.restart()
                }

                // short pause
                PauseAnimation { duration: 200 }
            }

        }

        Image {
            id: arrdown
            x: (parent.width-width)/2
            y: parent.height-height-10
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)

            source: "/mainwindow/leftarrow.svg"
            rotation: -90

            SequentialAnimation on y {

                id: seqdown

                loops: Animation.Infinite

                running: visible

                // move out quick
                NumberAnimation {
                    from: toplevel.height-110
                    to: toplevel.height-130
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: seqdown.restart()
                    onToChanged: seqdown.restart()
                }

                // bounce back in
                NumberAnimation {
                    from: toplevel.height-130
                    to: toplevel.height-110
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: seqdown.restart()
                    onToChanged: seqdown.restart()
                }

                // short pause
                PauseAnimation { duration: 500 }
            }

        }

        PQText {

            id: arrdowntxt

            x: arrdown.x+(arrdown.width-width)/2
            text: em.pty+qsTranslate("thumbnailbar", "Thumbnails (once a folder is loaded)")

            SequentialAnimation on y {

                id: seqdowntxt

                loops: Animation.Infinite

                running: visible

                // move out at same speed as arrow animation
                NumberAnimation {
                    from: toplevel.height-110 - arrdowntxt.height-10
                    to: toplevel.height-130 - arrdowntxt.height-10
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: seqdowntxt.restart()
                    onToChanged: seqdowntxt.restart()
                }

                // move in with delay
                NumberAnimation {
                    from: toplevel.height-130 - arrdowntxt.height-10
                    to: toplevel.height-110 - arrdowntxt.height-10
                    easing.type: Easing.InExpo
                    duration: 1300
                    onFromChanged: seqdowntxt.restart()
                    onToChanged: seqdowntxt.restart()
                }

                // short pause
                PauseAnimation { duration: 200 }
            }
        }

    }

}
