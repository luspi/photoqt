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
import PQCFileFolderModel
import PQCScriptsConfig

import "../elements"

Item {

    width: toplevel.width
    height: toplevel.height
    visible: PQCFileFolderModel.countMainView===0 && PQCNotify.filePath===""

    property var entries: {
                       //: Label shown at startup before a file is loaded
        "thumbnails" : qsTranslate("other", "Thumbnails"),
                       //: Label shown at startup before a file is loaded
        "mainmenu"   : qsTranslate("other", "Main menu"),
                       //: Label shown at startup before a file is loaded
        "metadata"   : qsTranslate("other", "Metadata"),
        "" : ""
    }

    Item {
        id: startmessage
        anchors.fill: parent
        anchors.margins: 160
        Column {
            y: (parent.height-height)/2.5

            spacing: 10

            Item {

                id: clickhere
                x: (parent.width-100)/2

                width: 100
                height: 100

                visible: startmessage.visible

                Rectangle {

                    id: clickcircle

                    width: 20
                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    height: width
                    radius: width/2
                    color: "transparent"
                    opacity: 1 - (width-20)/40
                    border {
                        width: 5
                        color: PQCLook.textColor
                    }

                    NumberAnimation {
                        id: clickani
                        target: clickcircle
                        property: "width"
                        from: 20
                        to: 50
                        duration: 1000
                        loops: Animation.Infinite
                        running: visible&&loader.visibleItem===""
                        easing.type: Easing.OutCirc
                    }
                }

                Image {

                    x: parent.width/2
                    y: parent.height/2

                    width: 40*(2/3)
                    height: 40
                    smooth: false
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/white/mouse.svg"

                }

            }

            Item {
                width: 1
                height: 20
            }

            Text {
                id: openmessage
                width: startmessage.width
                //: Part of the message shown in the main view before any image is loaded
                text: qsTranslate("other", "Open a file")
                font.pointSize: Math.min(40, Math.max(20, (toplevel.width+toplevel.height)/80))
                font.bold: true
                opacity: 0.8
                color: PQCLook.textColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Item {

        id: edgearrows
        anchors.fill: parent

        visible: startmessage.visible

        Image {
            id: arrleft
            x: 10
            y: (parent.height-height)/2
            visible: PQCSettings.interfaceEdgeLeftAction!==""
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/white/leftarrow.svg"

            SequentialAnimation on x {

                id: seqleft

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: 10
                    to: 30
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: 30
                    to: 10
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            x: arrleft.width+20
            y: (parent.height-height)/2
            width: ltx.width+20
            height: ltx.height+10
            color: PQCLook.transColor
            radius: 5
            visible: arrleft.visible&&ltx.text!=""

            PQTextL {
                id: ltx
                x: 10
                y: 5
                text: entries[PQCSettings.interfaceEdgeLeftAction]
                font.bold: true
            }

            SequentialAnimation on x {

                id: seqleft_txt

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: arrleft.width+20
                    to: arrleft.width+40
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: arrleft.width+40
                    to: arrleft.width+20
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }
        }


        Image {
            id: arrright
            x: parent.width-width-10
            y: (parent.height-height)/2
            visible: PQCSettings.interfaceEdgeRightAction!==""
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/white/rightarrow.svg"

            SequentialAnimation on x {

                id: seqright

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: toplevel.width-110
                    to: toplevel.width-130
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: toplevel.width-130
                    to: toplevel.width-110
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: right_txt
            x: arrright.x-width-20
            y: (parent.height-height)/2
            width: rtx.width+20
            height: rtx.height+10
            color: PQCLook.transColor
            radius: 5
            visible: arrright.visible&&rtx.text!=""

            PQTextL {
                id: rtx
                x: 10
                y: 5
                text: entries[PQCSettings.interfaceEdgeRightAction]
                font.bold: true
            }

            SequentialAnimation on x {

                id: seqright_txt

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: toplevel.width-arrright.width-right_txt.width-20
                    to: toplevel.width-arrright.width-right_txt.width-40
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: toplevel.width-arrright.width-right_txt.width-40
                    to: toplevel.width-arrright.width-right_txt.width-20
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

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
            visible: PQCSettings.interfaceEdgeBottomAction!==""

            source: "image://svg/:/white/leftarrow.svg"
            rotation: -90

            SequentialAnimation on y {

                id: seqdown

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: toplevel.height-110
                    to: toplevel.height-130
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: toplevel.height-130
                    to: toplevel.height-110
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: bottom_txt
            x: (parent.width-width)/2
            y: parent.height-arrdown.height-height-20
            width: btx.width+20
            height: btx.height+10
            color: PQCLook.transColor
            radius: 5
            visible: arrdown.visible&&btx.text!=""

            PQTextL {
                id: btx
                x: 10
                y: 5
                text: entries[PQCSettings.interfaceEdgeBottomAction]
                font.bold: true
            }

            SequentialAnimation on y {

                id: seqdown_txt

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: toplevel.height-arrdown.height-bottom_txt.height-20
                    to: toplevel.height-arrdown.height-bottom_txt.height-40
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: toplevel.height-arrdown.height-bottom_txt.height-40
                    to: toplevel.height-arrdown.height-bottom_txt.height-20
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }
        }

        Image {
            id: arrup
            x: (parent.width-width)/2
            y: 10
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            visible: PQCSettings.interfaceEdgeTopAction!==""

            source: "image://svg/:/white/leftarrow.svg"
            rotation: 90

            SequentialAnimation on y {

                id: sequp

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: 10
                    to: 30
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: 30
                    to: 10
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: up_txt
            x: (parent.width-width)/2
            y: arrup.height+20
            width: utx.width+20
            height: utx.height+10
            color: PQCLook.transColor
            radius: 5
            visible: arrup.visible&&utx.text!=""

            PQTextL {
                id: utx
                x: 10
                y: 5
                text: entries[PQCSettings.interfaceEdgeTopAction]
                font.bold: true
            }

            SequentialAnimation on y {

                id: sequp_txt

                running: visible&&loader.visibleItem===""
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: arrup.height+20
                    to: arrup.height+40
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: arrup.height+40
                    to: arrup.height+20
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: restartAllAnimations()
                    onToChanged: restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }
        }

    }

    PQText {
        visible: PQCScriptsConfig.isBetaVersion()
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        font.weight: PQCLook.fontWeightBold
        text: "This is a beta release and might still contains bugs."
    }

    PQMouseArea {

        id: imagemouse

        anchors.fill: parent
        anchors.topMargin: PQCSettings.interfaceWindowMode && !PQCSettings.interfaceWindowDecoration ? 30 : 0
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.AllButtons
        doubleClickThreshold: PQCSettings.interfaceDoubleClickThreshold

        property bool holdTrigger: false
        property point touchPos

        onPositionChanged: (mouse) => {
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            if(Math.abs(pos.x - touchPos.x) > 20 || Math.abs(pos.y - touchPos.y) > 20)
                holdTrigger = false
            PQCNotify.mouseMove(pos.x, pos.y)
        }
        onWheel: (wheel) => {
            wheel.accepted = true
            PQCNotify.mouseWheel(wheel.angleDelta, wheel.modifiers)
        }
        onPressed: (mouse) => {
            holdTrigger = false
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            touchPos = pos
            PQCNotify.mousePressed(mouse.modifiers, mouse.button, pos)
        }
        onDoubleClicked: (mouse) => {
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            PQCNotify.mouseDoubleClicked(mouse.modifiers, mouse.button, pos)
        }
        onReleased: (mouse) => {
            if(holdTrigger) {
                holdTrigger = false
                return
            }

            // a context menu is open -> don't continue
            if(PQCNotify.whichContextMenusOpen.length > 0) {
                PQCNotify.closeAllContextMenus()
                return
            }

            if(mouse.button === Qt.LeftButton)
                loader.show("filedialog")
            else {
                var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
                PQCNotify.mouseReleased(mouse.modifiers, mouse.button, pos)
            }
        }
        onPressAndHold: (mouse) => {
            holdTrigger = true
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            if(Math.abs(pos.x - touchPos.x) < 20 && Math.abs(pos.y - touchPos.y) < 20)
                shortcuts.item.executeInternalFunction("__contextMenuTouch", pos)
        }
    }

    // restarting all at the same time keeps all animations in sync
    function restartAllAnimations() {
        seqdown.restart()
        seqdown_txt.restart()
        seqright.restart()
        seqright_txt.restart()
        seqleft.restart()
        seqleft_txt.restart()
        sequp.restart()
        sequp_txt.restart()
        clickani.restart()
    }

    // make sure they are all in syc at start
    Component.onCompleted:
        restartAllAnimations()

}
