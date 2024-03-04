import QtQuick

import "../../elements"

import PQCNotify
import PQCFileFolderModel

Item {

    id: top

    property bool pressed: false

    Loader {

        active: PQCSettings.imageviewArchiveControls&&!PQCFileFolderModel.isARC

        Rectangle {

            id: controlitem

            parent: deleg

            x: (parent.width-width)/2
            y: 0.9*parent.height
            width: controlrow.width+10
            height: controw.height+5
            radius: 5
            color: PQCLook.transColorAccent

            Connections {
                target: image_top
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, image_top.width-controlitem.width-5)
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, image_top.height-controlitem.height-5)
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2) {
                    image_top.extraControlsLocation.x = x
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height) {
                    image_top.extraControlsLocation.y = y
                    y = y
                }
            }

            Component.onCompleted: {
                if(image_top.extraControlsLocation.x !== -1) {
                    controlitem.x = image_top.extraControlsLocation.x
                    controlitem.y = image_top.extraControlsLocation.y
                }
            }

            // only show when needed
            opacity: (image.fileCount>1 && image.visible && PQCSettings.imageviewArchiveControls && !PQCFileFolderModel.isARC) ? (hovered ? 1 : 0.3) : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            enabled: visible

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||leftrightmouse.containsMouse||viewermodemouse.containsMouse||
                                   slidercontrol.backgroundContainsMouse||slidercontrol.handleContainsMouse||slidercontrol.sliderContainsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||fileselect.hovered

            // drag and catch wheel events
            MouseArea {
                id: controldrag
                anchors.fill: parent
                drag.target: parent
                drag.minimumX: 5
                drag.minimumY: 5
                drag.maximumX: image_top.width-controlitem.width-5
                drag.maximumY: image_top.height-controlitem.height-5
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                propagateComposedEvents: true
                onWheel: {}
            }

            Column {

                id: controw

                spacing: 5

                Row {

                    id: controlrow

                    x: 5
                    y: (parent.height-height)/2
                    height: 50

                    Image {
                        id: viewermode
                        y: (parent.height-height)/2
                        width: height
                        height: leftrightlock.height
                        anchors.margins: 5
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/viewermode_on.svg"
                        PQMouseArea {
                            id: viewermodemouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Click to enter viewer mode")
                            onClicked: PQCFileFolderModel.enableViewerMode()
                        }
                    }

                    Item {
                        width: 5
                        height: 1
                    }

                    Rectangle {
                        height: parent.height
                        width: 1
                        color: PQCLook.textColor
                    }

                    Item {
                        width: 5
                        height: 1
                    }

                    Item {

                        id: leftrightlock

                        y: (parent.height-height)/2
                        width: lockrow.width
                        height: lockrow.height

                        opacity: PQCSettings.imageviewArchiveLeftRight ? 1 : 0.3
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        Row {
                            id: lockrow

                            Image {
                                height: slidercontrol.height
                                width: height
                                opacity: PQCSettings.imageviewArchiveLeftRight ? 1 : 0.4
                                source: "image://svg/:/white/padlock.svg"
                                sourceSize: Qt.size(width, height)
                            }

                            PQText {
                                text: "←/→"
                            }

                        }

                        PQMouseArea {
                            id: leftrightmouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Lock left/right arrow keys to page navigation")
                            onClicked:
                                PQCSettings.imageviewArchiveLeftRight = !PQCSettings.imageviewArchiveLeftRight
                        }

                    }

                    PQSlider {
                        id: slidercontrol
                        y: (parent.height-height)/2
                        from: 0
                        to: image.fileCount-1
                        value: image.currentFile
                        wheelEnabled: false
                        onPressedChanged: {
                            top.pressed = pressed
                        }

                        onValueChanged: {
                            if(value !== image.currentFile)
                                image.currentFile = value
                        }

                    }

                }

                PQComboBox {

                    id: fileselect

                    x: 5
                    width: controlrow.width
                    elide: Text.ElideMiddle

                    currentIndex: {
                        image.currentFile
                    }

                    onCurrentIndexChanged: {
                        if(currentIndex !== image.currentFile)
                            image.currentFile = currentIndex
                    }

                    model: image.fileList

                }

            }

            // the close button is only visible when hovered
            Image {
                x: parent.width-width+10
                y: -10
                width: 20
                height: 20
                opacity: controlclosemouse.containsMouse ? 0.75 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
                source: "image://svg/:/white/close.svg"
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: {
                        PQCSettings.imageviewArchiveControls = false
                    }
                }
            }

            Connections {

                target: PQCNotify

                enabled: controlitem.enabled

                function onMouseMove(x, y) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y))
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

            }

        }

    }

}
