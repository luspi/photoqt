import QtQuick
import QtQuick.Controls

import PQCFileFolderModel

import "../elements"

Rectangle {

    id: thumbnails_top

    // semi-transparent background color
    color: PQCLook.transColor

    // positioning
    x: keepVisible ? visiblePos[0] : invisiblePos[0]
    y: keepVisible ? visiblePos[1] : invisiblePos[1]
    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    // visibility status
    opacity: keepVisible ? 1 : 0
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
    property bool keepVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]

    // which area triggers the bar to be shown
    property rect hotArea: Qt.rect(0, toplevel.height-10, toplevel.width, 10)

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
                height: PQCSettings.thumbnailsSize+Math.max(20,2*PQCSettings.thumbnailsHighlightAnimationLiftUp)
            }
        },
        State {
            name: "left"
            PropertyChanges {
                target: thumbnails_top
                visiblePos: [0,0]
                invisiblePos: [-width,0]
                hotArea: Qt.rect(0,0,10,toplevel.height)
                width: PQCSettings.thumbnailsSize+Math.max(20,2*PQCSettings.thumbnailsHighlightAnimationLiftUp)
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
                width: PQCSettings.thumbnailsSize+Math.max(20,2*PQCSettings.thumbnailsHighlightAnimationLiftUp)
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
                height: PQCSettings.thumbnailsSize+Math.max(20,2*PQCSettings.thumbnailsHighlightAnimationLiftUp)
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: thumbnails_top
                keepVisible: false
                hotArea: Qt.rect(0,0,0,0)
            }
        }
    ]

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

        // some highlight properties
        // these follow the currentIndex property
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        preferredHighlightBegin: PQCSettings.thumbnailsCenterOnActive
                                 ? ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize)/2
                                 : PQCSettings.thumbnailsSize/2
        preferredHighlightEnd: PQCSettings.thumbnailsCenterOnActive
                               ? ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize)/2+PQCSettings.thumbnailsSize
                               : ((orientation==Qt.Horizontal ? width : height)-PQCSettings.thumbnailsSize/2)
        highlightRangeMode: ListView.ApplyRange

        // The horizontal scrollbar
        ScrollBar.horizontal: PQHorizontalScrollBar {
            id: scrollbar_hor
            parent: view.parent
            anchors.left: view.left
            anchors.right: view.right
            state: thumbnails_top.state
            states: [
                State {
                    name: "bottom"
                    PropertyChanges {
                        target: scrollbar_hor
                        anchors.bottom: thumbnails_top.bottom
                        anchors.bottomMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_hor.height)/2
                    }
                },
                State {
                    name: "top"
                    PropertyChanges {
                        target: scrollbar_hor
                        anchors.top: thumbnails_top.top
                        anchors.topMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_hor.height)/2
                    }
                },
                State {
                    name: "left"
                    PropertyChanges {
                        target: scrollbar_hor
                        visible: false
                    }
                },
                State {
                    name: "right"
                    PropertyChanges {
                        target: scrollbar_hor
                        visible: false
                    }
                }
            ]
        }

        // the vertical scrollbar
        ScrollBar.vertical: PQVerticalScrollBar {
            id: scrollbar_ver
            parent: view.parent
            anchors.top: view.top
            anchors.bottom: view.bottom
            state: thumbnails_top.state
            states: [
                State {
                    name: "left"
                    PropertyChanges {
                        target: scrollbar_ver
                        anchors.left: thumbnails_top.left
                        anchors.leftMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_ver.width)/2
                    }
                },
                State {
                    name: "right"
                    PropertyChanges {
                        target: scrollbar_ver
                        anchors.right: thumbnails_top.right
                        anchors.rightMargin: (PQCSettings.thumbnailsHighlightAnimationLiftUp-scrollbar_ver.width)/2
                    }
                },
                State {
                    name: "bottom"
                    PropertyChanges {
                        target: scrollbar_ver
                        visible: false
                    }
                },
                State {
                    name: "top"
                    PropertyChanges {
                        target: scrollbar_ver
                        visible: false
                    }
                }
            ]
        }

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
                                               : (view.state==="left" ? -PQCSettings.thumbnailsHighlightAnimationLiftUp : 0))
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
                source: "image://thumb/" + PQCFileFolderModel.entriesMainView[index]

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
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered:
                    view.highlightIndex = index

                onExited: {
                    resetHighlightIndex.stop()
                    resetHighlightIndex.oldIndex = index
                    resetHighlightIndex.restart()
                }

                onClicked: {
                    PQCFileFolderModel.currentIndex = index
                }

            }
        }

    }

    // check whether the thumbnails should be shown or not
    function checkMousePosition(x,y) {
        if(keepVisible) {
            if(x < thumbnails_top.x-50 || x > thumbnails_top.x+thumbnails_top.width+50 || y < thumbnails_top.y-50 || y > thumbnails_top.y+thumbnails_top.height+50)
                keepVisible = false
        } else {
            if(hotArea.x < x && hotArea.x+hotArea.width>x && hotArea.y < y && hotArea.height+hotArea.y > y)
                keepVisible = true
        }
    }

//    property int ind: 0
//    property var st: ["left", "right", "top", "disabled", "bottom"]
//    Timer {
//        running: true
//        repeat: true
//        interval: 5000
//        onTriggered: {
//            thumbnails_top.state = st[ind]
//            ind = (ind+1)%5
//        }
//    }
//    Timer {
//        running: true
//        repeat: false
//        interval: 0
//        onTriggered: {
//            thumbnails_top.state = "bottom"
//        }
//    }

}
