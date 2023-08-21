import QtQuick
import QtQuick.Controls

import PQCNotify
import PQCScriptsFilesPaths
import PQCFileFolderModel

import "../elements"

Rectangle {

    id: thumbnails_top

    // semi-transparent background color
    color: PQCLook.transColor

    // positioning
    x: (setVisible||holdVisible) ? visiblePos[0] : invisiblePos[0]
    y: (setVisible||holdVisible) ? visiblePos[1] : invisiblePos[1]
    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    // visibility status
    opacity: ((setVisible||holdVisible) && !PQCSettings.thumbnailsDisable) ? 1 : 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    // which edge the bar should be shown at
    state: PQCSettings.interfaceEdgeBottomAction==="thumbnails"
            ? "bottom"
            : (PQCSettings.interfaceEdgeLeftAction==="thumbnails"
                ? "left"
                : (PQCSettings.interfaceEdgeRightAction==="thumbnails"
                    ? "right"
                    : (PQCSettings.interfaceEdgeTopAction==="thumbnails"
                        ? "top"
                        : "disabled" )))

    // visibility handlers
    property bool holdVisible: (PQCSettings.thumbnailsVisibility===1 || (PQCSettings.thumbnailsVisibility===2 && Math.abs(image.currentScale-image.defaultScale) < 1e-6))
    property bool setVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]

    // which area triggers the bar to be shown
    property rect hotArea: Qt.rect(0, toplevel.height-10, toplevel.width, 10)

    property int extraSpacing: Math.max(20,2*PQCSettings.thumbnailsHighlightAnimationLiftUp)

    // the four states corresponding to screen edges
    states: [
        State {
            name: "bottom"
            PropertyChanges {
                target: thumbnails_top
                visiblePos: [0,toplevel.height-height]
                invisiblePos: [0, toplevel.height]
                hotArea: Qt.rect(0, toplevel.height-10, toplevel.width, 10)
                width: toplevel.width
                height: PQCSettings.thumbnailsSize+extraSpacing
            }
        },
        State {
            name: "left"
            PropertyChanges {
                target: thumbnails_top
                visiblePos: [0,0]
                invisiblePos: [-width,0]
                hotArea: Qt.rect(0,0,10,toplevel.height)
                width: PQCSettings.thumbnailsSize+extraSpacing
                height: toplevel.height
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: thumbnails_top
                visiblePos: [toplevel.width-width,0]
                invisiblePos: [toplevel.width,0]
                hotArea: Qt.rect(toplevel.width-10,0,10,toplevel.height)
                width: PQCSettings.thumbnailsSize+extraSpacing
                height: toplevel.height
            }
        },
        State {
            name: "top"
            PropertyChanges {
                target: thumbnails_top
                visiblePos: [0,0]
                invisiblePos: [0,-height]
                hotArea: Qt.rect(0,0,toplevel.width, 10)
                width: toplevel.width
                height: PQCSettings.thumbnailsSize+extraSpacing
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: thumbnails_top
                setVisible: false
                hotArea: Qt.rect(0,0,0,0)
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: (wheel) => {
            flickView(wheel.angleDelta)
        }
    }

    // the view for the actual thumbnails
    ListView {

        id: view

        // the model is the total image count
        model: PQCSettings.thumbnailsDisable||thumbnails_top.state==="disabled" ? 0 : PQCFileFolderModel.countMainView
        onModelChanged: {
            delegZ = 0
        }

        // some visual settings
        spacing: PQCSettings.thumbnailsSpacing
        boundsBehavior: smallerThanSize ? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds

        // whether the view is smaller than screen edge
        property bool smallerThanSize: contentWidth<parent.width

        // some animations (like magnify) require counting up the z property of the thumbnails
        property int delegZ: 0

        // state follows the global thumbnail state
        state: thumbnails_top.state

        // highlight animations
        property bool hlLiftUp: PQCSettings.thumbnailsHighlightAnimation.includes("liftup")
        property bool hlMagnify: PQCSettings.thumbnailsHighlightAnimation.includes("magnify")
        property bool hlLine: PQCSettings.thumbnailsHighlightAnimation.includes("line")
        property bool hlInvertLabel: PQCSettings.thumbnailsHighlightAnimation.includes("invertlabel")
        property bool hlInvertBg: PQCSettings.thumbnailsHighlightAnimation.includes("invertbg")

        // the current index follows the model
        currentIndex: PQCFileFolderModel.currentIndex
        property var previousIndices: [currentIndex, currentIndex]
        onCurrentIndexChanged: {
            previousIndices[1] = previousIndices[0]
            previousIndices[0] = currentIndex
            previousIndicesChanged()
        }
        property bool previousIndexWithinView: false

        // the highlight index is set when hovering thumbnails
        property int highlightIndex: -1
        Timer {
            id: resetHighlightIndex
            interval: 100
            property int oldIndex
            onTriggered: {
                if(view.highlightIndex==oldIndex)
                    view.highlightIndex = -1
            }
        }

        property var previousItem: view.model>0 ? view.itemAtIndex(view.previousIndices[1]) : null

        // used for converting vertical into horizontal flick
        property int flickCounter: 0

        // some highlight properties
        // these follow the currentIndex property
        highlightFollowsCurrentItem: true
        highlightMoveDuration: previousIndexWithinView ? 200 : 0
        preferredHighlightBegin: PQCSettings.thumbnailsCenterOnActive
                                 ? ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize)/2
                                 : PQCSettings.thumbnailsSize/2
        preferredHighlightEnd: PQCSettings.thumbnailsCenterOnActive
                               ? ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize)/2+PQCSettings.thumbnailsSize
                               : ((orientation==Qt.Horizontal ? width : height)-PQCSettings.thumbnailsSize/2)
        highlightRangeMode: ListView.ApplyRange

        // bottom scroll bar
        PQHorizontalScrollBar {
            id: scrollbar_bottom
            visible: thumbnails_top.state==="bottom"
            anchors.bottomMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_bottom.height)/2
        }

        // top scroll bar
        PQHorizontalScrollBar {
            id: scrollbar_top
            parent: view.parent
            visible: thumbnails_top.state==="top"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_top.height)/2
        }

        // set bottom or top scroll bar
        ScrollBar.horizontal: thumbnails_top.state==="bottom" ? scrollbar_bottom : scrollbar_top

        // left scroll bar
        PQVerticalScrollBar {
            id: scrollbar_left
            parent: view.parent
            visible: thumbnails_top.state==="left"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_left.width)/2
        }

        // right scroll bar
        PQVerticalScrollBar {
            id: scrollbar_right
            parent: view.parent
            visible: thumbnails_top.state==="right"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_right.width)/2
        }

        // set left or right scrollbar
        ScrollBar.vertical: thumbnails_top.state==="left" ? scrollbar_left : scrollbar_right

        // the ListView states (they follow the global thumbnail state)
        states: [
            State {
                name: "bottom"
                PropertyChanges {
                    target: view
                    x: (parent.width-width)/2
                    y: Math.max(10,PQCSettings.thumbnailsHighlightAnimationLiftUp)
                    implicitWidth: Math.min(parent.width, contentWidth)
                    implicitHeight: parent.height-y
                    orientation: Qt.Horizontal
                    smallerThanSize: contentHeight<parent.height
                    previousIndexWithinView: (previousItem!==null && previousItem.x >= contentX && previousItem.x+previousItem.width <= contentX+width)
                }
            },
            State {
                name: "left"
                PropertyChanges {
                    target: view
                    x: Math.max(10,PQCSettings.thumbnailsHighlightAnimationLiftUp)
                    y: (parent.height-height)/2
                    implicitWidth: parent.width
                    implicitHeight: Math.min(parent.height, contentHeight)
                    orientation: Qt.Vertical
                    smallerThanSize: contentHeight<parent.height
                    previousIndexWithinView: (previousItem!==null && previousItem.y >= contentY && previousItem.y+previousItem.height <= contentY+height)
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    target: view
                    x: Math.max(10,PQCSettings.thumbnailsHighlightAnimationLiftUp)
                    y: (parent.height-height)/2
                    implicitWidth: parent.width
                    implicitHeight: Math.min(parent.height, contentHeight)
                    orientation: Qt.Vertical
                    smallerThanSize: contentHeight<parent.height
                    previousIndexWithinView: (previousItem!==null && previousItem.y >= contentY && previousItem.y+previousItem.height <= contentY+height)
                }
            },
            State {
                name: "top"
                PropertyChanges {
                    target: view
                    x: (parent.width-width)/2
                    y: Math.max(10,PQCSettings.thumbnailsHighlightAnimationLiftUp)
                    implicitWidth: toplevel.width
                    implicitHeight: 100
                    orientation: Qt.Horizontal
                    smallerThanSize: contentWidth<parent.width
                    previousIndexWithinView: (previousItem!==null && previousItem.x >= contentX && previousItem.x+previousItem.width <= contentX+width)
                }
            }
        ]

        // each actual thumbnail
        delegate: Rectangle {

            id: deleg

            // the active property is set when either the current thumbnail corresponds to the main image
            // or when the mouse is hovering the current thumbnail
            property bool active: index===PQCFileFolderModel.currentIndex || index===view.highlightIndex
            onActiveChanged: {
                if(active) {
                    view.delegZ += 1
                    deleg.z = view.delegZ
                }
            }

            property string filepath: PQCFileFolderModel.entriesMainView[index]
            property string filename: PQCScriptsFilesPaths.getFilename(filepath)

            // set the background color
            color: (active&&view.hlInvertBg) ? PQCLook.transColorActive : PQCLook.transColor
            Behavior on color { ColorAnimation { duration: 200 } }

            // size the thumbnail image
            width: PQCSettings.thumbnailsSize
            height: PQCSettings.thumbnailsSize

            // the image
            Image {

                id: img

                // the transform origin follows the edge
                // this way the magnify property magnifies the thumbnail outward from the edge
                transformOrigin: view.state==="left"
                                    ? Item.Left
                                    : (view.state==="right"
                                            ? Item.Right
                                            : (view.state==="top"
                                                ? Item.Top
                                                : Item.Bottom))

                // the image position can change depending on the highlight animation
                x: (deleg.active&&view.hlLiftUp)
                        ? (view.state==="left" ? PQCSettings.thumbnailsHighlightAnimationLiftUp
                                               : (view.state==="right" ? -PQCSettings.thumbnailsHighlightAnimationLiftUp : 0))
                        : 0
                y: (deleg.active&&view.hlLiftUp)
                        ? (view.state==="top" ? PQCSettings.thumbnailsHighlightAnimationLiftUp
                                              : (view.state==="bottom" ? -PQCSettings.thumbnailsHighlightAnimationLiftUp : 0))
                        : 0

                Behavior on x { NumberAnimation { duration: 200 } }
                Behavior on y { NumberAnimation { duration: 200 } }

                // the magnify animation
                scale: (deleg.active&&view.hlMagnify) ? 1.2 : 1
                Behavior on scale { NumberAnimation { duration: 200 } }

                // some general properties
                width: PQCSettings.thumbnailsSize
                height: PQCSettings.thumbnailsSize
                asynchronous: true
                fillMode: PQCSettings.thumbnailsCropToFit ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                source: "image://thumb/" + deleg.filepath

            }

            // line-below highlight animation
            Rectangle {

                id: linebelow

                opacity: (deleg.active&&view.hlLine) ? 1 : 0
                visible: opacity>0

                Behavior on opacity { NumberAnimation { duration: 200 } }
                color: "white"

                // the state follows the global thumbnails state
                state: view.state
                states: [
                    State {
                        name: "bottom"
                        PropertyChanges {
                            target: linebelow
                            x: 0
                            y: parent.height-height
                            width: parent.width
                            height: 5
                        }
                    },
                    State {
                        name: "left"
                        PropertyChanges {
                            target: linebelow
                            x: 0
                            y: 0
                            width: 5
                            height: parent.height
                        }
                    },
                    State {
                        name: "right"
                        PropertyChanges {
                            target: linebelow
                            x: parent.width-width
                            y: 0
                            width: 5
                            height: parent.height
                        }
                    },
                    State {
                        name: "top"
                        PropertyChanges {
                            target: linebelow
                            x: 0
                            y: 0
                            width: parent.width
                            height: 5
                        }
                    }

                ]
            }

            // the mouse area for the current thumbnail
            PQMouseArea {

                id: delegmouse

                anchors.fill: parent
                anchors.bottomMargin: -extraSpacing/2
                anchors.topMargin: -extraSpacing/2

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                property bool tooltipSetup: false

                onEntered: {
                    view.highlightIndex = index

                    if(!tooltipSetup && PQCSettings.thumbnailsTooltip) {

                        tooltipSetup = true

                        var str = "<div style='font-size: " + PQCLook.fontSize + "pt; font-weight: bold'>" + deleg.filename + "</div>" +
                                  "<br><br>" +
                                  "<span style='font-size: " + PQCLook.fontSize + "pt'>" + qsTranslate("thumbnails", "File size:")+" <b>" + PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.filepath) + "</b></span><br>" +
                                  "<span style='font-size: " + PQCLook.fontSize + "pt'>" + qsTranslate("thumbnails", "File type:")+" <b>" + PQCScriptsFilesPaths.getFileType(deleg.filepath) + "</b></span>"

                        text = str

                    }

                }

                onExited: {
                    resetHighlightIndex.stop()
                    resetHighlightIndex.oldIndex = index
                    resetHighlightIndex.restart()
                }

                onClicked: {
                    PQCFileFolderModel.currentIndex = index
                }
                onWheel: (wheel) => {
                    flickView(wheel.angleDelta)
                }

            }

            Loader {
                asynchronous: true
                active: PQCSettings.thumbnailsFilename===1
                Rectangle {
                    color: PQCLook.transColor
                    opacity: (PQCSettings.thumbnailsInactiveTransparent&&!deleg.active) ? 0.5 : 1
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    y: (img.y+img.height-height)
                    width: deleg.width
                    height: Math.min(200, Math.max(30, deleg.height*0.3))

                    PQText {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: PQCSettings.thumbnailsFontSize
                        font.weight: PQCLook.fontWeightBold
                        elide: Text.ElideMiddle
                        text: deleg.filename
                    }
                }
            }

        }

    }

    Connections {
        target: PQCNotify
        function onMouseMove(posx, posy) {
            if(setVisible) {
                if(posx < thumbnails_top.x-50 || posx > thumbnails_top.x+thumbnails_top.width+50 || posy < thumbnails_top.y-50 || posy > thumbnails_top.y+thumbnails_top.height+50)
                    setVisible = false
            } else {
                if(hotArea.x < posx && hotArea.x+hotArea.width > posx && hotArea.y < posy && hotArea.height+hotArea.y > posy)
                    setVisible = true
            }
        }
    }

    function flickView(angleDelta) {

        // only scroll horizontally
        var val = angleDelta.y
        if(Math.abs(angleDelta.x) > Math.abs(angleDelta.y))
            val = angleDelta.x

        // continuing scroll makes the scroll go faster
        if((val < 0 && view.flickCounter > 0) || (val > 0 && view.flickCounter < 0))
            view.flickCounter = 0
        else if(val < 0)
            view.flickCounter -=1
        else if(val > 0)
            view.flickCounter += 1

        var fac = 5 + Math.min(20, Math.abs(view.flickCounter))

        // flick horizontally
        view.flick(fac*val, 0)

    }

}
