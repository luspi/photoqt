pragma ComponentBehavior: Bound
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
import QtQuick.Controls

import PQCNotify
import PQCScriptsFilesPaths
import PQCFileFolderModel
import PQCScriptsImages

import "../elements"
import "../image"
import "../"

Item {

    id: thumbnails_top

    // positioning
    x: (setVisible||holdVisible) ? visiblePos[0] : invisiblePos[0]
    y: (setVisible||holdVisible) ? visiblePos[1] : invisiblePos[1]
    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    // visibility status
    opacity: ((setVisible||holdVisible) && windowSizeOkay && PQCFileFolderModel.countMainView>0) ? 1 : 0 // qmllint disable unqualified
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property int radius:0

    property PQImage access_image: image // qmllint disable unqualified
    property PQMainWindow access_toplevel: toplevel // qmllint disable unqualified

    // which edge the bar should be shown at
    state: PQCSettings.interfaceEdgeBottomAction==="thumbnails" ? // qmllint disable unqualified
               "bottom" :
               (PQCSettings.interfaceEdgeLeftAction==="thumbnails" ?
                    "left" :
                    (PQCSettings.interfaceEdgeRightAction==="thumbnails" ?
                         "right" :
                         (PQCSettings.interfaceEdgeTopAction==="thumbnails" ?
                              "top" : "disabled" )))

    // visibility handlers
    property bool holdVisible: access_image.thumbnailsHoldVisible
    property bool setVisible: false
    property var visiblePos: [0,0]      // changing these from var to list<int>
    property var invisiblePos: [0, 0]   // causes a crash for some reason

    // which area triggers the bar to be shown
    property int hotAreaSize: PQCSettings.interfaceHotEdgeSize*5 // qmllint disable unqualified
    property rect hotArea: Qt.rect(0, access_toplevel.height-hotAreaSize, access_toplevel.width, hotAreaSize)

    property int effectiveThumbnailLiftup: PQCSettings.thumbnailsHighlightAnimation.includes("liftup") ? PQCSettings.thumbnailsHighlightAnimationLiftUp : 0 // qmllint disable unqualified
    property int extraSpacing: Math.max(20,2*effectiveThumbnailLiftup)
    property bool windowSizeOkay: true

    PQBlurBackground { thisis: "thumbnails" }
    PQShadowEffect { masterItem: thumbnails_top }

    // the four states corresponding to screen edges
    states: [
        State {
            name: "bottom"
            PropertyChanges {
                thumbnails_top.visiblePos: [0,thumbnails_top.access_toplevel.height-thumbnails_top.height]
                thumbnails_top.invisiblePos: [0, thumbnails_top.access_toplevel.height]
                thumbnails_top.hotArea: Qt.rect(0, thumbnails_top.access_toplevel.height-thumbnails_top.hotAreaSize, thumbnails_top.access_toplevel.width, thumbnails_top.hotAreaSize)
                thumbnails_top.width: thumbnails_top.access_toplevel.width
                thumbnails_top.height: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.windowSizeOkay: thumbnails_top.access_toplevel.height>500
            }
        },
        State {
            name: "left"
            PropertyChanges {
                thumbnails_top.visiblePos: [0,0]
                thumbnails_top.invisiblePos: [-thumbnails_top.width,0]
                thumbnails_top.hotArea: Qt.rect(0,0,thumbnails_top.hotAreaSize,thumbnails_top.access_toplevel.height)
                thumbnails_top.width: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.height: thumbnails_top.access_toplevel.height
                thumbnails_top.windowSizeOkay: thumbnails_top.access_toplevel.width>500
            }
        },
        State {
            name: "right"
            PropertyChanges {
                thumbnails_top.visiblePos: [thumbnails_top.access_toplevel.width-thumbnails_top.width,0]
                thumbnails_top.invisiblePos: [thumbnails_top.access_toplevel.width,0]
                thumbnails_top.hotArea: Qt.rect(thumbnails_top.access_toplevel.width-thumbnails_top.hotAreaSize,0,thumbnails_top.hotAreaSize,thumbnails_top.access_toplevel.height)
                thumbnails_top.width: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.height: thumbnails_top.access_toplevel.height
                thumbnails_top.windowSizeOkay: thumbnails_top.access_toplevel.width>500
            }
        },
        State {
            name: "top"
            PropertyChanges {
                thumbnails_top.visiblePos: [0,0]
                thumbnails_top.invisiblePos: [0,-thumbnails_top.height]
                thumbnails_top.hotArea: Qt.rect(0,0,thumbnails_top.access_toplevel.width,thumbnails_top.hotAreaSize)
                thumbnails_top.width: thumbnails_top.access_toplevel.width
                thumbnails_top.height: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.windowSizeOkay: thumbnails_top.access_toplevel.height>500
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                thumbnails_top.setVisible: false
                thumbnails_top.hotArea: Qt.rect(0,0,0,0)
            }
        }
    ]

    onSetVisibleChanged: {
        if(!setVisible)
            menu.item.dismiss() // qmllint disable missing-property
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) => {
            thumbnails_top.flickView(wheel.angleDelta.x, wheel.angleDelta.y)
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.item.popup() // qmllint disable missing-property
        }
    }

    // the view for the actual thumbnails
    ListView {

        id: view

        // the model is the total image count
        model: thumbnails_top.state==="disabled"||!thumbnails_top.access_image.initialLoadingFinished ? 0 : PQCFileFolderModel.countMainView // qmllint disable unqualified
        onModelChanged: {
            delegZ = 0
        }

        // some visual settings
        spacing: PQCSettings.thumbnailsSpacing // qmllint disable unqualified
        boundsBehavior: smallerThanSize ? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds

        // whether the view is smaller than screen edge
        property bool smallerThanSize: contentWidth<parent.width

        // some animations (like magnify) require counting up the z property of the thumbnails
        property int delegZ: 0

        // state follows the global thumbnail state
        state: thumbnails_top.state

        // if the width of the delegates can vary, then only keeping a few delegates ready makes the view jump back to the beginning when scrolling away from there
        // the only solution is to make sure that all the delegates are set up and thumbnails loaded so that the view can scroll as expected
        cacheBuffer: PQCSettings.thumbnailsSameHeightVaryWidth ? (PQCFileFolderModel.countMainView*PQCSettings.thumbnailsSize*2) : 320

        // highlight animations
        property bool hlLiftUp: PQCSettings.thumbnailsHighlightAnimation.includes("liftup") // qmllint disable unqualified
        property bool hlMagnify: PQCSettings.thumbnailsHighlightAnimation.includes("magnify") // qmllint disable unqualified
        property bool hlLine: PQCSettings.thumbnailsHighlightAnimation.includes("line") // qmllint disable unqualified
        property bool hlInvertLabel: PQCSettings.thumbnailsHighlightAnimation.includes("invertlabel") // qmllint disable unqualified
        property bool hlInvertBg: PQCSettings.thumbnailsHighlightAnimation.includes("invertbg") // qmllint disable unqualified

        // the current index follows the model
        currentIndex: PQCFileFolderModel.currentIndex // qmllint disable unqualified
        property list<int> previousIndices: [currentIndex, currentIndex]
        onCurrentIndexChanged: {
            previousIndices[1] = previousIndices[0]
            previousIndices[0] = currentIndex
            previousIndicesChanged()
        }
        property bool previousIndexWithinView: false

        signal reloadThumbnail(var index)

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

        property Item previousItem: view.model>0 ? view.itemAtIndex(view.previousIndices[1]) : null

        // used for converting vertical into horizontal flick
        property int flickCounter: 0

        // some highlight properties
        // these follow the currentIndex property
        highlightFollowsCurrentItem: true
        highlightMoveDuration: previousIndexWithinView ? 200 : 0
        preferredHighlightBegin: PQCSettings.thumbnailsCenterOnActive // qmllint disable unqualified
                                 ? ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize)/2
                                 : PQCSettings.thumbnailsSize/2
        preferredHighlightEnd: PQCSettings.thumbnailsCenterOnActive // qmllint disable unqualified
                               ? ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize)/2+PQCSettings.thumbnailsSize
                               : ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize/2)
        highlightRangeMode: ListView.ApplyRange

        // bottom scroll bar
        PQHorizontalScrollBar {
            id: scrollbar_bottom
            visible: thumbnails_top.state==="bottom"
            anchors.bottomMargin: (thumbnails_top.effectiveThumbnailLiftup-scrollbar_bottom.height)/2
        }

        // top scroll bar
        PQHorizontalScrollBar {
            id: scrollbar_top
            parent: view.parent
            visible: thumbnails_top.state==="top"
            anchors.left: parent ? parent.left : undefined
            anchors.right: parent ? parent.right : undefined
            anchors.top: parent ? parent.top : undefined
            anchors.topMargin: (thumbnails_top.effectiveThumbnailLiftup-scrollbar_top.height)/2
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
            anchors.leftMargin: (thumbnails_top.effectiveThumbnailLiftup-scrollbar_left.width)/2
        }

        // right scroll bar
        PQVerticalScrollBar {
            id: scrollbar_right
            parent: view.parent
            visible: thumbnails_top.state==="right"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: (thumbnails_top.effectiveThumbnailLiftup-scrollbar_right.width)/2
        }

        // set left or right scrollbar
        ScrollBar.vertical: thumbnails_top.state==="left" ? scrollbar_left : scrollbar_right

        // the ListView states (they follow the global thumbnail state)
        states: [
            State {
                name: "bottom"
                PropertyChanges {
                    view.x: (thumbnails_top.width-view.width)/2
                    view.y: Math.max(10,thumbnails_top.effectiveThumbnailLiftup)
                    view.implicitWidth: Math.min(thumbnails_top.width, view.contentWidth)
                    view.implicitHeight: thumbnails_top.height-view.y
                    view.orientation: Qt.Horizontal
                    view.smallerThanSize: view.contentHeight<thumbnails_top.height
                    view.previousIndexWithinView: (view.previousItem!==null && view.previousItem.x >= view.contentX && view.previousItem.x+view.previousItem.width <= view.contentX+view.width)
                }
            },
            State {
                name: "left"
                PropertyChanges {
                    view.x: Math.max(10,thumbnails_top.effectiveThumbnailLiftup)
                    view.y: (thumbnails_top.height-view.height)/2
                    view.implicitWidth: thumbnails_top.width
                    view.implicitHeight: Math.min(thumbnails_top.height, view.contentHeight)
                    view.orientation: Qt.Vertical
                    view.smallerThanSize: view.contentHeight<thumbnails_top.height
                    view.previousIndexWithinView: (view.previousItem!==null && view.previousItem.y >= view.contentY && view.previousItem.y+view.previousItem.height <= view.contentY+view.height)
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    view.x: Math.max(10,thumbnails_top.effectiveThumbnailLiftup)
                    view.y: (thumbnails_top.height-view.height)/2
                    view.implicitWidth: thumbnails_top.width
                    view.implicitHeight: Math.min(thumbnails_top.height, view.contentHeight)
                    view.orientation: Qt.Vertical
                    view.smallerThanSize: view.contentHeight<thumbnails_top.height
                    view.previousIndexWithinView: (view.previousItem!==null && view.previousItem.y >= view.contentY && view.previousItem.y+view.previousItem.height <= view.contentY+view.height)
                }
            },
            State {
                name: "top"
                PropertyChanges {
                    view.x: (thumbnails_top.width-view.width)/2
                    view.y: Math.max(10,thumbnails_top.effectiveThumbnailLiftup)
                    view.implicitWidth: thumbnails_top.access_toplevel.width
                    view.implicitHeight: 100
                    view.orientation: Qt.Horizontal
                    view.smallerThanSize: view.contentWidth<thumbnails_top.width
                    view.previousIndexWithinView: (view.previousItem!==null && view.previousItem.x >= view.contentX && view.previousItem.x+view.previousItem.width <= view.contentX+view.width)
                }
            }
        ]

        // each actual thumbnail
        delegate: Rectangle {

            id: deleg

            required property int modelData

            // the active property is set when either the current thumbnail corresponds to the main image
            // or when the mouse is hovering the current thumbnail
            property bool active: modelData===PQCFileFolderModel.currentIndex || modelData===view.highlightIndex // qmllint disable unqualified
            onActiveChanged: {
                if(active) {
                    view.delegZ += 1
                    deleg.z = view.delegZ
                }
            }

            property string filepath: PQCFileFolderModel.entriesMainView[modelData] // qmllint disable unqualified
            property string filename: PQCScriptsFilesPaths.getFilename(filepath) // qmllint disable unqualified

            // set the background color
            color: (active&&view.hlInvertBg) ? PQCLook.baseColorActive : "transparent" // qmllint disable unqualified
            Behavior on color { ColorAnimation { duration: 200 } }

            state: thumbnails_top.state

            // the thumbnail/container sizes depend on the state as there might be some variation in it
            states: [
                State {
                    name: "bottom"
                    PropertyChanges {
                        deleg.width: PQCSettings.thumbnailsSameHeightVaryWidth ? img.width : PQCSettings.thumbnailsSize
                        deleg.height: PQCSettings.thumbnailsSize
                        img.width: PQCSettings.thumbnailsSameHeightVaryWidth ? ((img.height/img.sourceSize.height) * img.sourceSize.width) : PQCSettings.thumbnailsSize
                        img.height: PQCSettings.thumbnailsSize
                    }
                },
                State {
                    name: "left"
                    PropertyChanges {
                        deleg.width: PQCSettings.thumbnailsSize
                        deleg.height: PQCSettings.thumbnailsSameHeightVaryWidth ? img.height : PQCSettings.thumbnailsSize
                        img.width: PQCSettings.thumbnailsSize
                        img.height: PQCSettings.thumbnailsSameHeightVaryWidth ? ((img.width/img.sourceSize.width) * img.sourceSize.height) : PQCSettings.thumbnailsSize
                    }
                },
                State {
                    name: "right"
                    PropertyChanges {
                        deleg.width: PQCSettings.thumbnailsSize
                        deleg.height: PQCSettings.thumbnailsSameHeightVaryWidth ? img.height : PQCSettings.thumbnailsSize
                        img.width: PQCSettings.thumbnailsSize
                        img.height: PQCSettings.thumbnailsSameHeightVaryWidth ? ((img.width/img.sourceSize.width) * img.sourceSize.height) : PQCSettings.thumbnailsSize
                    }
                },
                State {
                    name: "top"
                    PropertyChanges {
                        deleg.width: PQCSettings.thumbnailsSameHeightVaryWidth ? img.width : PQCSettings.thumbnailsSize
                        deleg.height: PQCSettings.thumbnailsSize
                        img.width: PQCSettings.thumbnailsSameHeightVaryWidth ? ((img.height/img.sourceSize.height) * img.sourceSize.width) : PQCSettings.thumbnailsSize
                        img.height: PQCSettings.thumbnailsSize
                    }
                }
            ]

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
                        ? (view.state==="left" ? thumbnails_top.effectiveThumbnailLiftup
                                               : (view.state==="right" ? -thumbnails_top.effectiveThumbnailLiftup : 0))
                        : 0
                y: (deleg.active&&view.hlLiftUp)
                        ? (view.state==="top" ? thumbnails_top.effectiveThumbnailLiftup
                                              : (view.state==="bottom" ? -thumbnails_top.effectiveThumbnailLiftup : 0))
                        : 0

                Behavior on x { NumberAnimation { duration: 200 } }
                Behavior on y { NumberAnimation { duration: 200 } }

                // the magnify animation
                scale: (deleg.active&&view.hlMagnify) ? 1.2 : 1
                Behavior on scale { NumberAnimation { duration: 200 } }

                // some general properties
                // the width/height is set by the state above
                asynchronous: true
                cache: false
                fillMode: (PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth) ? Image.PreserveAspectCrop : Image.PreserveAspectFit // qmllint disable unqualified
                source: "image://thumb/" + deleg.filepath

            }

            // the mouse area for the current thumbnail
            PQMouseArea {

                id: delegmouse

                anchors.fill: parent
                anchors.bottomMargin: -thumbnails_top.extraSpacing/2
                anchors.topMargin: -thumbnails_top.extraSpacing/2

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                property bool tooltipSetup: false

                onEntered: {

                    view.highlightIndex = deleg.modelData

                    if(!tooltipSetup && PQCSettings.thumbnailsTooltip) { // qmllint disable unqualified

                        tooltipSetup = true

                        var str = "<div style='font-size: " + PQCLook.fontSize + "pt; font-weight: bold'>" + deleg.filename + "</div>" +
                                  "<br><br>" +
                                  "<span style='font-size: " + PQCLook.fontSize + "pt'>" + qsTranslate("thumbnails", "File size:")+" <b>" + PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.filepath) + "</b></span><br>" +
                                  "<span style='font-size: " + PQCLook.fontSize + "pt'>" + qsTranslate("thumbnails", "File type:")+" <b>" + PQCScriptsFilesPaths.getFileType(deleg.filepath) + "</b></span>"

                        text = str

                    } else if(!PQCSettings.thumbnailsTooltip) {

                        tooltipSetup = false
                        text = ""

                    }

                }

                onExited: {
                    resetHighlightIndex.stop()
                    resetHighlightIndex.oldIndex = deleg.modelData
                    resetHighlightIndex.restart()
                }

                onClicked: {
                    if(PQCNotify.whichContextMenusOpen.length === 0) // qmllint disable unqualified
                        PQCFileFolderModel.currentIndex = deleg.modelData
                }
                onWheel: (wheel) => {
                    if(PQCNotify.whichContextMenusOpen.length === 0) // qmllint disable unqualified
                        thumbnails_top.flickView(wheel.angleDelta.x, wheel.angleDelta.y)
                }

            }

            Loader {
                asynchronous: true
                active: PQCSettings.thumbnailsFilename // qmllint disable unqualified
                Rectangle {
                    color: view.hlInvertLabel&&deleg.active ? PQCLook.inverseColor : PQCLook.transColor // qmllint disable unqualified
                    Behavior on color { ColorAnimation { duration: 200 } }
                    opacity: (PQCSettings.thumbnailsInactiveTransparent&&!deleg.active) ? 0.5 : 1 // qmllint disable unqualified
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    visible: PQCSettings.thumbnailsFilename // qmllint disable unqualified
                    x: (img.x+img.width-width)
                    y: (img.y+img.height-height)
                    width: deleg.width
                    height: Math.min(200, Math.max(30, deleg.height*0.3))

                    PQText {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: PQCSettings.thumbnailsFontSize // qmllint disable unqualified
                        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                        elide: Text.ElideMiddle
                        text: deleg.filename
                        color: view.hlInvertLabel&&deleg.active ? PQCLook.textColorDisabled : PQCLook.textColor // qmllint disable unqualified
                    }
                }
            }

            // line-below highlight animation
            Rectangle {

                id: linebelow

                opacity: (deleg.active&&view.hlLine) ? 1 : 0
                visible: opacity>0

                Behavior on opacity { NumberAnimation { duration: 200 } }
                color: PQCLook.baseColorActive // qmllint disable unqualified

                // the state follows the global thumbnails state
                state: view.state
                states: [
                    State {
                        name: "bottom"
                        PropertyChanges {
                            linebelow.x: 0
                            linebelow.y: deleg.height-linebelow.height
                            linebelow.width: deleg.width
                            linebelow.height: 5
                        }
                    },
                    State {
                        name: "left"
                        PropertyChanges {
                            linebelow.x: 0
                            linebelow.y: 0
                            linebelow.width: 5
                            linebelow.height: deleg.height
                        }
                    },
                    State {
                        name: "right"
                        PropertyChanges {
                            linebelow.x: deleg.width-linebelow.width
                            linebelow.y: 0
                            linebelow.width: 5
                            linebelow.height: deleg.height
                        }
                    },
                    State {
                        name: "top"
                        PropertyChanges {
                            linebelow.x: 0
                            linebelow.y: 0
                            linebelow.width: deleg.width
                            linebelow.height: 5
                        }
                    }

                ]
            }

            Connections {
                target: view
                function onReloadThumbnail(ind : int) {
                    if(deleg.modelData === ind) {
                        img.source = ""
                        img.source = "image://thumb/" + deleg.filepath
                    }
                }
            }

        }

    }

    ButtonGroup { id: grp1 }
    ButtonGroup { id: grp2 }

    property int menuReloadIndex: -1
    property bool menuReloadIndexVisible: menuReloadIndex>-1

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {

            id: menudeleg

            PQMenuItem {
                enabled: false
                font.italic: true
                moveToRightABit: true
                text: qsTranslate("MainMenu", "Thumbnails")
            }

            PQMenuSeparator { }

            PQMenuItem {
                visible: thumbnails_top.menuReloadIndexVisible
                text: qsTranslate("thumbnails", "Reload thumbnail")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg" // qmllint disable unqualified
                onTriggered: {
                    PQCScriptsImages.removeThumbnailFor(PQCFileFolderModel.entriesMainView[thumbnails_top.menuReloadIndex]) // qmllint disable unqualified
                    view.reloadThumbnail(thumbnails_top.menuReloadIndex)
                }
            }

            PQMenuSeparator { lighterColor: true; visible: thumbnails_top.menuReloadIndexVisible }

            PQMenu {

                title: "thumbnail image"

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "fit thumbnails")
                    ButtonGroup.group: grp1
                    checked: (!PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth) // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked && (PQCSettings.thumbnailsCropToFit || PQCSettings.thumbnailsSameHeightVaryWidth)) { // qmllint disable unqualified
                            PQCSettings.thumbnailsCropToFit = false
                            PQCSettings.thumbnailsSameHeightVaryWidth = false
                        }
                    }
                }

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "scale and crop thumbnails")
                    ButtonGroup.group: grp1
                    checked: PQCSettings.thumbnailsCropToFit // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.thumbnailsCropToFit = true // qmllint disable unqualified
                            PQCSettings.thumbnailsSameHeightVaryWidth = false
                        }
                    }
                }

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "same height, varying width")
                    ButtonGroup.group: grp1
                    checked: PQCSettings.thumbnailsSameHeightVaryWidth // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked) {
                            // See the comment below for why this check is here
                            if(PQCSettings.thumbnailsCropToFit) { // qmllint disable unqualified
                                PQCSettings.thumbnailsCropToFit = false
                                delayChecking.restart()
                            } else
                                PQCSettings.thumbnailsSameHeightVaryWidth = true
                        }
                    }
                    // When switching from CropToFit to SameHeightVaryWidth we can't go immediately there
                    // If we do then the padding/sourceSize of the images might not cooperate well
                    // This short delay in that case ensures that everything works just fine
                    Timer {
                        id: delayChecking
                        interval: 100
                        onTriggered: {
                            PQCSettings.thumbnailsSameHeightVaryWidth = true // qmllint disable unqualified
                        }
                    }
                }

                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "keep small thumbnails small")
                    checked: PQCSettings.thumbnailsSmallThumbnailsKeepSmall // qmllint disable unqualified
                    onCheckedChanged:
                        PQCSettings.thumbnailsSmallThumbnailsKeepSmall = checked // qmllint disable unqualified
                }

            }

            PQMenu {

                title: "visibility"

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "hide when not needed")
                    ButtonGroup.group: grp2
                    checked: PQCSettings.thumbnailsVisibility===0 // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.thumbnailsVisibility = 0 // qmllint disable unqualified
                    }
                }

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "always keep visible")
                    ButtonGroup.group: grp2
                    checked: PQCSettings.thumbnailsVisibility===1 // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.thumbnailsVisibility = 1 // qmllint disable unqualified
                    }
                }

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "hide when zoomed in")
                    ButtonGroup.group: grp2
                    checked: PQCSettings.thumbnailsVisibility===2 // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.thumbnailsVisibility = 2 // qmllint disable unqualified
                    }
                }

            }

            PQMenuSeparator {}

            PQMenuItem {
                checkable: true
                text: qsTranslate("settingsmanager", "show filename labels")
                checked: PQCSettings.thumbnailsFilename // qmllint disable unqualified
                onCheckedChanged:
                    PQCSettings.thumbnailsFilename = checked // qmllint disable unqualified
            }

            PQMenuItem {
                checkable: true
                text: qsTranslate("settingsmanager", "show tooltips")
                checked: PQCSettings.thumbnailsTooltip // qmllint disable unqualified
                onCheckedChanged:
                    PQCSettings.thumbnailsTooltip = checked // qmllint disable unqualified
            }

            PQMenuSeparator {}

            PQMenuItem {
                text: qsTranslate("settingsmanager", "Manage in settings manager")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg" // qmllint disable unqualified
                onTriggered: {
                    loader.ensureItIsReady("settingsmanager", loader.loadermapping["settingsmanager"]) // qmllint disable unqualified
                    loader.passOn("showSettings", "thumbnails")
                }
            }

            onAboutToHide:
                recordAsClosed.restart()

            onAboutToShow: {
                PQCNotify.addToWhichContextMenusOpen("thumbnails") // qmllint disable unqualified
                thumbnails_top.menuReloadIndex = view.highlightIndex
            }

            Connections {
                target: view
                function onHighlightIndexChanged() {
                    if(!menudeleg.visible)
                        thumbnails_top.menuReloadIndex = view.highlightIndex
                }
            }

            Timer {
                id: recordAsClosed
                interval: 200
                onTriggered: {
                    if(!menudeleg.visible)
                        PQCNotify.removeFromWhichContextMenusOpen("thumbnails") // qmllint disable unqualified
                }
            }

        }
    }

    // if a small play/pause button is shown then moving the mouse to the screen edge around it does not trigger the thumbnail bar
    property int ignoreRightMotion: state==="bottom"&&PQCNotify.isMotionPhoto&&PQCSettings.filetypesMotionPhotoPlayPause ? 150 : 0 // qmllint disable unqualified

    Connections {
        target: PQCNotify // qmllint disable unqualified
        function onMouseMove(posx : int, posy : int) {

            if(PQCNotify.slideshowRunning || PQCNotify.faceTagging) { // qmllint disable unqualified
                thumbnails_top.setVisible = false
                return
            }

            if(menu.item != null && menu.item.opened) {
                thumbnails_top.setVisible = true
                return
            }

            if(thumbnails_top.setVisible) {
                if(posx < thumbnails_top.x-50 || posx > thumbnails_top.x+thumbnails_top.width+50 || posy < thumbnails_top.y-50 || posy > thumbnails_top.y+thumbnails_top.height+50)
                    thumbnails_top.setVisible = false
            } else {
                if(thumbnails_top.hotArea.x <= posx && thumbnails_top.hotArea.x+thumbnails_top.hotArea.width-thumbnails_top.ignoreRightMotion > posx && thumbnails_top.hotArea.y < posy && thumbnails_top.hotArea.height+thumbnails_top.hotArea.y > posy)
                    thumbnails_top.setVisible = true
            }
        }
        function onCloseAllContextMenus() {
            menu.item.dismiss() // qmllint disable missing-property
        }
    }

    Connections {
        target: loader // qmllint disable unqualified

        function onPassOn(what : string, param : string) {

            if(what === "show") {
                if(param === "thumbnails")
                    thumbnails_top.setVisible = !thumbnails_top.setVisible
            }

        }

    }

    function flickView(angleDeltaX : int, angleDeltaY : int) {

        var val, fac

        if(thumbnails_top.state == "bottom" || thumbnails_top.state == "top") {

            // only scroll horizontally
            val = angleDeltaY
            if(Math.abs(angleDeltaX) > Math.abs(angleDeltaY))
                val = angleDeltaX

            // continuing scroll makes the scroll go faster
            if((val < 0 && view.flickCounter > 0) || (val > 0 && view.flickCounter < 0))
                view.flickCounter = 0
            else if(val < 0)
                view.flickCounter -=1
            else if(val > 0)
                view.flickCounter += 1

            fac = 5 + Math.min(20, Math.abs(view.flickCounter))

            // flick horizontally
            view.flick(fac*val, 0)

        } else {

            // only scroll vertically
            val = angleDeltaX
            if(Math.abs(angleDeltaY) > Math.abs(angleDeltaX))
                val = angleDeltaY

            // continuing scroll makes the scroll go faster
            if((val < 0 && view.flickCounter > 0) || (val > 0 && view.flickCounter < 0))
                view.flickCounter = 0
            else if(val < 0)
                view.flickCounter -=1
            else if(val > 0)
                view.flickCounter += 1

            fac = 5 + Math.min(20, Math.abs(view.flickCounter))

            // flick vertically
            view.flick(0, fac*val)

        }

    }

}
