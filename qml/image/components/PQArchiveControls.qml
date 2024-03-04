import QtQuick

import "../../elements"

import PQCNotify
import PQCFileFolderModel
import PQCScriptsImages

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
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColorAccent

            property bool isComicBook: PQCScriptsImages.isComicBook(deleg.imageSource)

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
                                   emptyAreaHovered||controlclosemouse.containsMouse||fileselect.hovered||fileselect.popup.visible||
                                   mouseprev.containsMouse||mousenext.containsMouse||mousefirst.containsMouse||mouselast.containsMouse

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

            Row {

                id: controlrow

                x: 10
                y: (parent.height-height)/2

                spacing: 5

                PQComboBox {

                    id: fileselect

                    y: (parent.height-height)/2
                    elide: Text.ElideMiddle
                    transparentBackground: true

                    visible: !controlitem.isComicBook

                    currentIndex: {
                        image.currentFile
                    }

                    onCurrentIndexChanged: {
                        if(currentIndex !== image.currentFile)
                            image.currentFile = currentIndex
                    }

                    model: image.fileList

                }



                Row {

                    y: (parent.height-height)/2
                    visible: controlitem.isComicBook

                    Image {
                        y: (parent.height-height)/2
                        width: height
                        height: controlitem.height/3
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/first.svg"
                        PQMouseArea {
                            id: mousefirst
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to first page")
                            onClicked: image_top.archiveJump(-image.currentFile)
                        }
                    }

                    Image {
                        y: (parent.height-height)/2
                        width: height
                        height: controlitem.height/2
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/backwards.svg"
                        PQMouseArea {
                            id: mouseprev
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to previous page")
                            onClicked: image_top.archiveJump(-1)
                        }
                    }

                    Image {
                        y: (parent.height-height)/2
                        width: height
                        height: controlitem.height/2
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/forwards.svg"
                        PQMouseArea {
                            id: mousenext
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to next page")
                            onClicked: image_top.archiveJump(1)
                        }
                    }

                    Image {
                        y: (parent.height-height)/2
                        width: height
                        height: controlitem.height/3
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/last.svg"
                        PQMouseArea {
                            id: mouselast
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to last page")
                            onClicked: image_top.archiveJump(image.fileCount-image.currentFile-1)
                        }
                    }

                }

                Item {
                    width: 5
                    height: 1
                    visible: controlitem.isComicBook
                }

                Rectangle {
                    y: (parent.height-height)/2
                    height: controlitem.height*0.75
                    width: 1
                    color: PQCLook.textColor
                    visible: controlitem.isComicBook
                }

                Item {
                    width: 5
                    height: 1
                    visible: controlitem.isComicBook
                }

                PQText {
                    y: (parent.height-height)/2
                    visible: controlitem.isComicBook
                    text: visible ? qsTranslate("image", "Page %1/%2").arg(image.currentFile+1).arg(image.fileCount) : ""
                }

                Item {
                    width: 5
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    width: 1
                    height: controlitem.height*0.75
                    color: PQCLook.textColor
                }

                Item {
                    width: 5
                    height: 1
                }

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

                    id: leftrightlock

                    y: (parent.height-height)/2
                    width: lockrow.width
                    height: lockrow.height

                    opacity: PQCSettings.imageviewArchiveLeftRight ? 1 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Row {
                        id: lockrow

                        Image {
                            height: controlitem.height/2.5
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
