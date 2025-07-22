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

    id: bgmsg

    width: PQCConstants.windowWidth
    height: PQCConstants.windowHeight
    visible: PQCFileFolderModel.countMainView===0 && PQCConstants.startupFilePath===""

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
            x: (parent.width-width)/2
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
                        running: clickhere.visible&&!PQCConstants.modalWindowOpen 
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
                    source: "image://svg/:/" + PQCLook.iconShade + "/mouse.svg" 

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
                font.pointSize: Math.min(40, Math.max(20, (PQCConstants.windowWidth+PQCConstants.windowHeight)/80)) 
                font.bold: true
                opacity: PQCConstants.windowWidth>750&&PQCConstants.windowHeight>500 ? 0.8 : 0 
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
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
            x: extraSpace
            y: (parent.height-height)/2
            visible: PQCSettings.interfaceEdgeLeftAction!==""&&opacity>0 
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/leftarrow.svg" 

            property int extraSpace: (PQCSettings.interfaceEdgeLeftAction === "thumbnails" && PQCSettings.thumbnailsVisibility>0 ?
                                          PQCSettings.thumbnailsSize+20 : 0)

            opacity: PQCConstants.windowWidth>500&&PQCConstants.windowHeight>500 ? 0.5 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            SequentialAnimation on x {

                id: seqleft

                running: arrleft.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: 10+arrleft.extraSpace
                    to: 30+arrleft.extraSpace
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: 30+arrleft.extraSpace
                    to: 10+arrleft.extraSpace
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: rectleft
            x: arrleft.width+20+arrleft.extraSpace
            y: (parent.height-height)/2
            width: ltx.width+20
            height: ltx.height+10
            color: PQCLook.transColor 
            border.width: 1
            border.color: PQCLook.transInverseColor 
            radius: 5
            visible: arrleft.visible&&ltx.text!=""&&opacity>0

            opacity: PQCConstants.windowWidth>750&&PQCConstants.windowHeight>500 ? 0.8 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            PQTextL {
                id: ltx
                x: 10
                y: 5
                text: bgmsg.entries[PQCSettings.interfaceEdgeLeftAction] 
                font.bold: true
            }

            SequentialAnimation on x {

                id: seqleft_txt

                running: rectleft.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: arrleft.width+20+arrleft.extraSpace
                    to: arrleft.width+40+arrleft.extraSpace
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: arrleft.width+40+arrleft.extraSpace
                    to: arrleft.width+20+arrleft.extraSpace
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }
        }


        Image {
            id: arrright
            x: parent.width-width-10-extraSpace
            y: (parent.height-height)/2
            visible: PQCSettings.interfaceEdgeRightAction!==""&&opacity>0 
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/rightarrow.svg" 

            property int extraSpace: (PQCSettings.interfaceEdgeRightAction === "thumbnails" && PQCSettings.thumbnailsVisibility>0 ?
                                          PQCSettings.thumbnailsSize+20 : 0)

            opacity: PQCConstants.windowWidth>500&&PQCConstants.windowHeight>500 ? 0.5 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            SequentialAnimation on x {

                id: seqright

                running: arrright.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: PQCConstants.windowWidth-110-arrright.extraSpace 
                    to: PQCConstants.windowWidth-130-arrright.extraSpace 
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: PQCConstants.windowWidth-130-arrright.extraSpace 
                    to: PQCConstants.windowWidth-110-arrright.extraSpace 
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: right_txt
            x: arrright.x-width-20-arrright.extraSpace
            y: (parent.height-height)/2
            width: rtx.width+20
            height: rtx.height+10
            color: PQCLook.transColor 
            border.width: 1
            border.color: PQCLook.transInverseColor 
            radius: 5
            visible: arrright.visible&&rtx.text!=""&&opacity>0
            opacity: PQCConstants.windowWidth>750&&PQCConstants.windowHeight>500 ? 0.8 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            PQTextL {
                id: rtx
                x: 10
                y: 5
                text: bgmsg.entries[PQCSettings.interfaceEdgeRightAction] 
                font.bold: true
            }

            SequentialAnimation on x {

                id: seqright_txt

                running: right_txt.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: PQCConstants.windowWidth-arrright.width-right_txt.width-20-arrright.extraSpace 
                    to: PQCConstants.windowWidth-arrright.width-right_txt.width-40-arrright.extraSpace 
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: PQCConstants.windowWidth-arrright.width-right_txt.width-40-arrright.extraSpace 
                    to: PQCConstants.windowWidth-arrright.width-right_txt.width-20-arrright.extraSpace 
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }
        }

        Image {
            id: arrdown
            x: (parent.width-width)/2
            y: parent.height-height-10 - extraSpace

            property int extraSpace: (PQCSettings.interfaceEdgeBottomAction === "thumbnails" && PQCSettings.thumbnailsVisibility>0 ?
                                          PQCSettings.thumbnailsSize+20 : 0)

            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            visible: PQCSettings.interfaceEdgeBottomAction!==""&&opacity>0 

            source: "image://svg/:/" + PQCLook.iconShade + "/leftarrow.svg" 
            rotation: -90

            opacity: PQCConstants.windowWidth>500&&PQCConstants.windowHeight>500 ? 0.5 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            SequentialAnimation on y {

                id: seqdown

                running: arrdown.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: PQCConstants.windowHeight-110-arrdown.extraSpace 
                    to: PQCConstants.windowHeight-130-arrdown.extraSpace 
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: PQCConstants.windowHeight-130-arrdown.extraSpace 
                    to: PQCConstants.windowHeight-110-arrdown.extraSpace 
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: bottom_txt
            x: (parent.width-width)/2
            y: parent.height-arrdown.height-height-20 - arrdown.extraSpace
            width: btx.width+20
            height: btx.height+10
            color: PQCLook.transColor 
            border.width: 1
            border.color: PQCLook.transInverseColor 
            radius: 5
            visible: arrdown.visible&&btx.text!=""&&opacity>0
            opacity: PQCConstants.windowWidth>500&&PQCConstants.windowHeight>625 ? 0.8 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            PQTextL {
                id: btx
                x: 10
                y: 5
                text: bgmsg.entries[PQCSettings.interfaceEdgeBottomAction] 
                font.bold: true
            }

            SequentialAnimation on y {

                id: seqdown_txt

                running: bottom_txt.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: PQCConstants.windowHeight-arrdown.height-bottom_txt.height-20-arrdown.extraSpace 
                    to: PQCConstants.windowHeight-arrdown.height-bottom_txt.height-40-arrdown.extraSpace 
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: PQCConstants.windowHeight-arrdown.height-bottom_txt.height-40-arrdown.extraSpace 
                    to: PQCConstants.windowHeight-arrdown.height-bottom_txt.height-20-arrdown.extraSpace 
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }
        }

        Image {
            id: arrup
            x: (parent.width-width)/2
            y: arrup.extraSpace
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            visible: PQCSettings.interfaceEdgeTopAction!==""&&opacity>0 

            property int extraSpace: (PQCSettings.interfaceEdgeTopAction === "thumbnails" && PQCSettings.thumbnailsVisibility>0 ?
                                          PQCSettings.thumbnailsSize+20 : 0)

            source: "image://svg/:/" + PQCLook.iconShade + "/leftarrow.svg" 
            rotation: 90

            opacity: PQCConstants.windowWidth>500&&PQCConstants.windowHeight>500 ? 0.5 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            SequentialAnimation on y {

                id: sequp

                running: arrup.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: 10+arrup.extraSpace
                    to: 30+arrup.extraSpace
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: 30+arrup.extraSpace
                    to: 10+arrup.extraSpace
                    easing.type: Easing.OutBounce
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // short pause
                PauseAnimation { duration: 500 }

            }

        }

        Rectangle {
            id: up_txt
            x: (parent.width-width)/2
            y: arrup.height+20+arrup.extraSpace
            width: utx.width+20
            height: utx.height+10
            color: PQCLook.transColor 
            border.width: 1
            border.color: PQCLook.transInverseColor 
            radius: 5
            visible: arrup.visible&&utx.text!=""&&opacity>0
            opacity: PQCConstants.windowWidth>500&&PQCConstants.windowHeight>625 ? 0.8 : 0 
            Behavior on opacity { NumberAnimation { duration: 200 } }

            PQTextL {
                id: utx
                x: 10
                y: 5
                text: bgmsg.entries[PQCSettings.interfaceEdgeTopAction] 
                font.bold: true
            }

            SequentialAnimation on y {

                id: sequp_txt

                running: up_txt.visible&&!PQCConstants.modalWindowOpen 
                loops: Animation.Infinite

                // move out quick
                NumberAnimation {
                    from: arrup.height+20+arrup.extraSpace
                    to: arrup.height+40+arrup.extraSpace
                    easing.type: Easing.OutExpo
                    duration: 500
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
                }

                // bounce back in
                NumberAnimation {
                    from: arrup.height+40+arrup.extraSpace
                    to: arrup.height+20+arrup.extraSpace
                    easing.type: Easing.InQuad
                    duration: 1000
                    onFromChanged: bgmsg.restartAllAnimations()
                    onToChanged: bgmsg.restartAllAnimations()
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
        property point touchPos: Qt.point(-1,-1)

        onPositionChanged: (mouse) => {
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y) 
            if(Math.abs(pos.x - touchPos.x) > 20 || Math.abs(pos.y - touchPos.y) > 20)
                holdTrigger = false
            PQCNotify.mouseMove(pos.x, pos.y)
        }
        onWheel: (wheel) => {
            wheel.accepted = true
            PQCNotify.mouseWheel(Qt.point(wheel.x, wheel.y), wheel.angleDelta, wheel.modifiers)
        }
        onPressed: (mouse) => {
            holdTrigger = false
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            touchPos = pos
            PQCNotify.mousePressed(mouse.modifiers, mouse.button, pos)
        }
        onMouseDoubleClicked: (mouse) => {
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y) 
            PQCNotify.mouseDoubleClicked(mouse.modifiers, mouse.button, pos)
        }
        onReleased: (mouse) => {
            if(holdTrigger) {
                holdTrigger = false
                return
            }

            // a context menu is open -> don't continue
            if(PQCConstants.whichContextMenusOpen.length > 0) {
                PQCNotify.closeAllContextMenus()
                return
            }

            if(mouse.button === Qt.LeftButton)
                PQCNotify.loaderShow("filedialog")
            else {
                var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
                PQCNotify.mouseReleased(mouse.modifiers, mouse.button, pos)
            }
        }
        onPressAndHold: (mouse) => {
            holdTrigger = true
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y) 
            if(Math.abs(pos.x - touchPos.x) < 20 && Math.abs(pos.y - touchPos.y) < 20)
                shortcuts.item.executeInternalFunction("__contextMenuTouch", pos, Qt.point(0,0))
        }
    }

    MultiPointTouchArea {

        id: backtouch

        anchors.fill: parent
        mouseEnabled: false

        maximumTouchPoints: 1

        property point initPoint: Qt.point(-1,-1)

        property bool cmdTriggered: false

        onPressed: (points) => {
                       reEnableMouseWithDelay.stop()
                       imagemouse.enabled = false
                       initPoint.x = points[0].x
                       initPoint.y = points[0].y
                   }

        onUpdated: (points) => {
            if(cmdTriggered) return


                       if(Math.abs(points[0].y-initPoint.y) < 50 && Math.abs(points[0].x-initPoint.x) > 50) {

                           cmdTriggered = true

                           if(points[0].x-initPoint.x > 0)
                               handleEdge("lefttoright")
                           else if(points[0].x-initPoint.x < 0)
                               handleEdge("righttoleft")

                       } else if(Math.abs(points[0].x-initPoint.x) < 50 && Math.abs(points[0].y-initPoint.y) > 50) {

                           cmdTriggered = true

                           if(points[0].y-initPoint.y > 10)
                               handleEdge("toptobottom")
                           else
                               handleEdge("bottomtotop")

                       }

        }

        function handleEdge(direction : string) {

            // swipe from left to right
            if(direction === "lefttoright") {

                if(checkVisibility(PQCSettings.interfaceEdgeRightAction)) {
                    hideElement(PQCSettings.interfaceEdgeRightAction)
                } else if(!checkVisibility(PQCSettings.interfaceEdgeLeftAction)) {
                    showElement(PQCSettings.interfaceEdgeLeftAction)
                }

            // swipe from right to left
            } else if(direction === "righttoleft") {

                if(checkVisibility(PQCSettings.interfaceEdgeLeftAction)) {
                    hideElement(PQCSettings.interfaceEdgeLeftAction)
                } else if(!checkVisibility(PQCSettings.interfaceEdgeRightAction)) {
                    showElement(PQCSettings.interfaceEdgeRightAction)
                }

            } else if(direction === "toptobottom") {

                if(checkVisibility(PQCSettings.interfaceEdgeBottomAction)) {
                    hideElement(PQCSettings.interfaceEdgeBottomAction)
                } else if(!checkVisibility(PQCSettings.interfaceEdgeTopAction)) {
                    showElement(PQCSettings.interfaceEdgeTopAction)
                }

            } else if(direction === "bottomtotop") {

                if(checkVisibility(PQCSettings.interfaceEdgeTopAction)) {
                    hideElement(PQCSettings.interfaceEdgeTopAction)
                } else if(!checkVisibility(PQCSettings.interfaceEdgeBottomAction)) {
                    showElement(PQCSettings.interfaceEdgeBottomAction)
                }

            }

        }

        function checkVisibility(item : string) : bool {

            console.log("args: item =", item)

            if(item === "metadata")
                return PQCConstants.metadataOpacity > 0
            if(item === "mainmenu")
                return PQCConstants.mainmenuOpacity > 0
            if(item === "thumbnails")
                return PQCConstants.thumbnailsBarOpacity > 0

            return false

        }

        function hideElement(item : string) {
            if(item === "") return
            PQCNotify.loaderPassOn("forcehide", [item])
        }

        function showElement(item : string) {
            if(item === "") return
            PQCNotify.loaderPassOn("forceshow", [item])
        }

        onReleased: (points) => {
            if(!cmdTriggered && Math.abs(points[0].x-initPoint.x) < 50 && Math.abs(points[0].y-initPoint.y) < 50) {
                hideElement("metadata")
                hideElement("mainmenu")
                hideElement("thumbnails")
                PQCNotify.loaderShow("filedialog")
            }

            reEnableMouseWithDelay.start()
            initPoint = Qt.point(-1,-1)
        }

    }

    Timer {
        id: reEnableMouseWithDelay
        interval: 250
        onTriggered: {
            imagemouse.enabled = true
            backtouch.cmdTriggered = false
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
