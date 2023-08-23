import QtQuick

import PQCNotify
import PQCFileFolderModel

Item {

    width: toplevel.width
    height: toplevel.height
    visible: PQCFileFolderModel.countMainView===0 && PQCNotify.filePath===""

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
                        running: visible&&loader.numVisible===0
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
                    source: "/white/mouse.svg"

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
                text: qsTranslate("other", "Click anywhere to open a file")
                font.pointSize: Math.min(40, Math.max(20, (toplevel.width+toplevel.height)/80))
                font.bold: true
                opacity: 0.8
                color: PQCLook.textColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: arrowmessage
                width: startmessage.width
                //: Part of the message shown in the main view before any image is loaded
                text: qsTranslate("other", "Move your cursor to the indicated window edges for various actions")
                font.pointSize: Math.min(20, Math.max(15, (toplevel.width+toplevel.height)/100))
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

        visible: startmessage.visible //&& variables.startupCompleted

        Image {
            id: arrleft
            x: 10
            y: (parent.height-height)/2
            visible: PQCSettings.interfaceEdgeLeftAction!==""
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "/white/leftarrow.svg"

            SequentialAnimation on x {

                id: seqleft

                running: visible&&loader.numVisible==0
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


        Image {
            id: arrright
            x: parent.width-width-10
            y: (parent.height-height)/2
            visible: PQCSettings.interfaceEdgeRightAction!==""
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            source: "/white/rightarrow.svg"

            SequentialAnimation on x {

                id: seqright

                running: visible&&loader.numVisible==0
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

        Image {
            id: arrdown
            x: (parent.width-width)/2
            y: parent.height-height-10
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            visible: PQCSettings.interfaceEdgeBottomAction!==""

            source: "/white/leftarrow.svg"
            rotation: -90

            SequentialAnimation on y {

                id: seqdown

                running: visible&&loader.numVisible==0
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

        Image {
            id: arrup
            x: (parent.width-width)/2
            y: 10
            opacity: 0.5
            width: 100
            height: 100
            sourceSize: Qt.size(width, height)
            visible: PQCSettings.interfaceEdgeTopAction!==""

            source: "/white/leftarrow.svg"
            rotation: 90

            SequentialAnimation on y {

                id: sequp

                running: visible&&loader.numVisible==0
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

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: (mouse) => {
            if(mouse.button === Qt.LeftButton)
                loader.show("filedialog")
            else {
                var pos = mapToItem(fullscreenitem, mouse.x, mouse.y)
                PQCNotify.mouseClick(mouse.modifiers, mouse.button, pos)
            }
        }
        onPositionChanged: (mouse) => {
            var pos = mapToItem(fullscreenitem, mouse.x, mouse.y)
            PQCNotify.mouseMove(pos.x, pos.y)
        }
    }

    // restarting all at the same time keeps all animations in sync
    function restartAllAnimations() {
        seqdown.restart()
        seqright.restart()
        seqleft.restart()
        sequp.restart()
        clickani.restart()
    }

    // make sure they are all in syc at start
    Component.onCompleted:
        restartAllAnimations()

}
