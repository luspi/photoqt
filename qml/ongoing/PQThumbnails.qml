/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

Rectangle {

    id: thumbnails_top

    // positioning
    x: (setVisible||holdVisible) ? visiblePos[0] : invisiblePos[0]
    y: (setVisible||holdVisible) ? visiblePos[1] : invisiblePos[1]
    Behavior on x { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: holdVisible ? 0 : 200 } }
    Behavior on y { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: holdVisible ? 0 : 200 } }

    // visibility status
    opacity: ((setVisible||holdVisible) && windowSizeOkay) ? 1 : 0
    visible: opacity>0
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

    radius: 0

    // which edge the bar should be shown at
    state: PQCSettings.interfaceEdgeBottomAction==="thumbnails" ?
               "bottom" :
               (PQCSettings.interfaceEdgeLeftAction==="thumbnails" ?
                    "left" :
                    (PQCSettings.interfaceEdgeRightAction==="thumbnails" ?
                         "right" :
                         (PQCSettings.interfaceEdgeTopAction==="thumbnails" ?
                              "top" : "disabled" )))

    // visibility handlers
    property bool holdVisible: (PQCSettings.thumbnailsVisibility===1 ||
                                 (PQCSettings.thumbnailsVisibility===2 &&
                                   (Math.abs(PQCConstants.currentImageScale-PQCConstants.currentImageDefaultScale) < 1e-6 ||
                                     PQCConstants.currentImageScale < PQCConstants.currentImageDefaultScale)))
    property bool setVisible: false
    property var visiblePos: [0,0]      // changing these from var to list<int>
    property var invisiblePos: [0, 0]   // causes a crash for some reason

    // which area triggers the bar to be shown
    property int hotAreaSize: PQCSettings.interfaceHotEdgeSize*5
    property rect hotArea: Qt.rect(0, PQCConstants.availableHeight-hotAreaSize, PQCConstants.availableWidth, hotAreaSize)

    property int effectiveThumbnailLiftup: PQCSettings.thumbnailsHighlightAnimation.includes("liftup") ? PQCSettings.thumbnailsHighlightAnimationLiftUp : 0
    property int extraSpacing: Math.max(20,2*effectiveThumbnailLiftup)
    property bool windowSizeOkay: true

    color: palette.base

    PQShadowEffect { masterItem: thumbnails_top }

    onWidthChanged: {
        PQCConstants.thumbnailsBarWidth = (windowSizeOkay ? thumbnails_top.width : 0)
    }
    onHeightChanged: {
        PQCConstants.thumbnailsBarHeight = (windowSizeOkay ? thumbnails_top.height : 0)
    }
    onOpacityChanged: {
        PQCConstants.thumbnailsBarOpacity = thumbnails_top.opacity
    }
    onWindowSizeOkayChanged: {
        PQCConstants.thumbnailsBarWidth = (windowSizeOkay ? thumbnails_top.width : 0)
        PQCConstants.thumbnailsBarHeight = (windowSizeOkay ? thumbnails_top.height : 0)
    }

    // the four states corresponding to screen edges
    states: [
        State {
            name: "bottom"
            PropertyChanges {
                thumbnails_top.visiblePos: [0,PQCConstants.availableHeight-thumbnails_top.height]
                thumbnails_top.invisiblePos: [0, PQCConstants.availableHeight]
                thumbnails_top.hotArea: Qt.rect(0, PQCConstants.availableHeight-thumbnails_top.hotAreaSize, PQCConstants.availableWidth, thumbnails_top.hotAreaSize)
                thumbnails_top.width: PQCConstants.availableWidth
                thumbnails_top.height: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.windowSizeOkay: PQCConstants.availableHeight>500
            }
        },
        State {
            name: "left"
            PropertyChanges {
                thumbnails_top.visiblePos: [0,0]
                thumbnails_top.invisiblePos: [-thumbnails_top.width,0]
                thumbnails_top.hotArea: Qt.rect(0,0,thumbnails_top.hotAreaSize,PQCConstants.availableHeight)
                thumbnails_top.width: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.height: PQCConstants.availableHeight
                thumbnails_top.windowSizeOkay: PQCConstants.availableWidth>500
            }
        },
        State {
            name: "right"
            PropertyChanges {
                thumbnails_top.visiblePos: [PQCConstants.availableWidth-thumbnails_top.width,0]
                thumbnails_top.invisiblePos: [PQCConstants.availableWidth,0]
                thumbnails_top.hotArea: Qt.rect(PQCConstants.availableWidth-thumbnails_top.hotAreaSize,0,thumbnails_top.hotAreaSize,PQCConstants.availableHeight)
                thumbnails_top.width: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.height: PQCConstants.availableHeight
                thumbnails_top.windowSizeOkay: PQCConstants.availableWidth>500
            }
        },
        State {
            name: "top"
            PropertyChanges {
                thumbnails_top.visiblePos: [0,0]
                thumbnails_top.invisiblePos: [0,-thumbnails_top.height]
                thumbnails_top.hotArea: Qt.rect(0,0,PQCConstants.availableWidth,thumbnails_top.hotAreaSize)
                thumbnails_top.width: PQCConstants.availableWidth
                thumbnails_top.height: PQCSettings.thumbnailsSize+thumbnails_top.extraSpacing
                thumbnails_top.windowSizeOkay: PQCConstants.availableHeight>500
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
            rightclickmenu.dismiss()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton) {
                PQCConstants.thumbnailsMenuReloadIndex = view.highlightIndex
                rightclickmenu.popup()
            }
        }
    }

    PQTextXL {
        anchors.fill: parent
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTranslate("thumbnails", "No file loaded")
        font.bold: PQCLook.fontWeightBold
        color: palette.disabled.text
        visible: PQCFileFolderModel.countMainView===0
    }

    // the view for the actual thumbnails
    ListView {

        id: view

        // the model is the total image count
        property int numModel: thumbnails_top.state==="disabled"||!PQCConstants.imageInitiallyLoaded ? 0 : PQCFileFolderModel.countMainView
        onNumModelChanged: {

            // if the width of the delegates can vary, then only keeping a few delegates ready makes the view jump back to the beginning when scrolling away from there
            // the only solution is to make sure that all the delegates are set up and thumbnails loaded so that the view can scroll as expected
            // to accomplish that we calculate the total necessary width of the thumbnail bar and adjust the cacheBuffer variable accordingly

            if(PQCSettings.thumbnailsSameHeightVaryWidth) {
                loadCacheBuffer.restart()
            } else {
                cacheBuffer = 320
                model = numModel
                currentIndex = PQCFileFolderModel.currentIndex
                currentIndex = Qt.binding(function() { return PQCFileFolderModel.currentIndex })
                view.positionViewAtIndex(view.currentIndex, ListView.Contain)
            }

        }

        Timer {
            id: loadCacheBuffer
            // this interval corresponds to the usual animation duration.
            // this ensures that the chosen image is first fully shown before we load this in the background
            interval: 200
            onTriggered: {
                var pix = 0

                if(thumbnails_top.state==="left" || thumbnails_top.state==="right") {
                    for(var i = 0; i < view.numModel; ++i)
                        pix += PQCScriptsImages.getCurrentImageResolution(PQCFileFolderModel.entriesMainView[i]).height
                } else {
                    for(var j = 0; j < view.numModel; ++j)
                        pix += PQCScriptsImages.getCurrentImageResolution(PQCFileFolderModel.entriesMainView[j]).width
                }

                view.thumbwidths = []
                for(var k = 0; k < view.numModel; ++k)
                    view.thumbwidths.push(0)

                view.cacheBuffer = Math.max(320, pix)
                view.model = 0
                view.model = view.numModel
                view.currentIndex = Qt.binding(function() { return PQCFileFolderModel.currentIndex })
            }
        }

        Connections {
            target: PQCSettings
            function onThumbnailsSameHeightVaryWidthChanged() {
                if(PQCSettings.thumbnailsSameHeightVaryWidth)
                    loadCacheBuffer.triggered()
                else {
                    view.width = Qt.binding(function() { return view.implicitWidth })
                    view.height = Qt.binding(function() { return view.implicitHeight })
                }
            }
        }

        // some visual settings
        spacing: PQCSettings.thumbnailsSpacing
        boundsBehavior: smallerThanSize ? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds

        /*************************************************************/

        // if thumbnailsSameHeightVaryWidth setting is set, then we need to be a little smarter with the side of the view
        // otherwise some of the thumbnails will be cut off and either not show at all or require scrolling
        // this recheck here makes sure that if the size of all thumbnails is smaller than the max size of the bar we reduce its size
        // (which causes the bar to be centered). Otherwise we keep the bar at maximum size and provide scrolling for the thumbnails
        property list<int> thumbwidths: []
        onThumbwidthsChanged: {
            if(PQCSettings.thumbnailsSameHeightVaryWidth) {
                recheckSize.restart()
            }
        }

        Connections {
            target: thumbnails_top
            enabled: PQCSettings.thumbnailsSameHeightVaryWidth
            function onWidthChanged() {
                recheckSize.restart()
            }
            function onHeightChanged() {
                recheckSize.restart()
            }
        }

        Timer {
            id: recheckSize
            interval: 200
            onTriggered: {
                var w = view.thumbwidths.reduce((partialSum, a) => partialSum + a, 0)
                if(view.state === "left" || view.state === "right") {
                    if(w < thumbnails_top.height) {
                        view.height = w
                    } else if(w > thumbnails_top.height)
                        view.height = thumbnails_top.height
                } else {
                    if(w < thumbnails_top.width) {
                        view.width = w
                    } else if(w > thumbnails_top.width)
                        view.width = thumbnails_top.width
                }
            }
        }

        /*************************************************************/

        // make the potential adjustments to its size based on above timer smooth
        Behavior on width { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: PQCSettings.thumbnailsSameHeightVaryWidth ? 200 : 0 } }
        Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: PQCSettings.thumbnailsSameHeightVaryWidth ? 200 : 0 } }

        // whether the view is smaller than screen edge
        property bool smallerThanSize: contentWidth<parent.width

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
        property list<int> previousIndices: [currentIndex, currentIndex]
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

        property Item previousItem: view.model>0 ? view.itemAtIndex(view.previousIndices[1]) : null

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
                               : ((orientation==Qt.Horizontal ? view.width : view.height)-PQCSettings.thumbnailsSize/2)
        highlightRangeMode: PQCSettings.thumbnailsCenterOnActive ? ListView.StrictlyEnforceRange : ListView.ApplyRange

        maximumFlickVelocity: 5000 * Math.max(1, PQCSettings.thumbnailsSize/250)

        // bottom scroll bar
        PQHorizontalScrollBar {
            id: scrollbar_bottom
            orientation: Qt.Horizontal
            visible: thumbnails_top.state==="bottom"
            anchors.bottomMargin: (thumbnails_top.effectiveThumbnailLiftup-scrollbar_bottom.height)/2
        }

        // top scroll bar
        PQHorizontalScrollBar {
            id: scrollbar_top
            orientation: Qt.Horizontal
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
        ScrollBar {
            id: scrollbar_left
            orientation: Qt.Vertical
            parent: view.parent
            visible: thumbnails_top.state==="left"
            anchors.top: parent==null ? undefined : parent.top
            anchors.bottom: parent==null ? undefined : parent.bottom
            anchors.left: parent==null ? undefined : parent.left
            anchors.leftMargin: (thumbnails_top.effectiveThumbnailLiftup-scrollbar_left.width)/2
        }

        // right scroll bar
        ScrollBar {
            id: scrollbar_right
            orientation: Qt.Vertical
            parent: view.parent
            visible: thumbnails_top.state==="right"
            anchors.top: parent==null ? undefined : parent.top
            anchors.bottom: parent==null ? undefined : parent.bottom
            anchors.right: parent==null ? undefined : parent.right
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
                    view.implicitWidth: view.numModel==0 ? 0 : (PQCSettings.thumbnailsSameHeightVaryWidth||PQCSettings.thumbnailsCenterOnActive ?
                                                                    thumbnails_top.width :
                                                                    Math.min(thumbnails_top.width, view.contentWidth+view.numModel*PQCSettings.thumbnailsSpacing))
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
                    view.implicitHeight: view.numModel==0 ? 0 : (PQCSettings.thumbnailsSameHeightVaryWidth||PQCSettings.thumbnailsCenterOnActive ?
                                                                     thumbnails_top.height :
                                                                     Math.min(thumbnails_top.height, view.contentHeight+view.numModel*PQCSettings.thumbnailsSpacing))
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
                    view.implicitHeight: view.numModel==0 ? 0 : (PQCSettings.thumbnailsSameHeightVaryWidth||PQCSettings.thumbnailsCenterOnActive ?
                                                                     thumbnails_top.height :
                                                                     Math.min(thumbnails_top.height, view.contentHeight+view.numModel*PQCSettings.thumbnailsSpacing))
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
                    view.implicitWidth: view.numModel==0 ? 0 : (PQCSettings.thumbnailsSameHeightVaryWidth||PQCSettings.thumbnailsCenterOnActive ?
                                                                    thumbnails_top.width :
                                                                    Math.min(thumbnails_top.width, view.contentWidth+view.numModel*PQCSettings.thumbnailsSpacing))
                    view.implicitHeight: thumbnails_top.height
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
            property bool active: modelData===PQCFileFolderModel.currentIndex ||
                                  modelData===PQCConstants.thumbnailsMenuReloadIndex ||
                                  modelData===view.highlightIndex

            z: (modelData===PQCFileFolderModel.currentIndex) ? 2 : (active ? 1 : 0)

            property string filepath: PQCFileFolderModel.entriesMainView[modelData]
            property string filename: PQCScriptsFilesPaths.getFilename(filepath)

            // set the background color
            color: (active&&view.hlInvertBg) ? palette.alternateBase : "transparent"
            Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }

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

                Behavior on x { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                Behavior on y { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                // the magnify animation
                scale: (deleg.active&&view.hlMagnify) ? 1.2 : 1
                Behavior on scale { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                // some general properties
                // the width/height is set by the state above
                asynchronous: true
                cache: false
                fillMode: (PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth) ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                source: "image://thumb/" + deleg.filepath

                onWidthChanged: {
                    if(view.state === "left" || view.state === "right") return
                    if(PQCSettings.thumbnailsSameHeightVaryWidth)
                        view.thumbwidths[deleg.modelData] = width
                }
                onHeightChanged: {
                    if(view.state === "top" || view.state === "bottom") return
                    if(PQCSettings.thumbnailsSameHeightVaryWidth)
                        view.thumbwidths[deleg.modelData] = height
                }

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

                    if(rightclickmenu.opened) return

                    view.highlightIndex = deleg.modelData

                    if(!tooltipSetup && PQCSettings.thumbnailsTooltip) {

                        tooltipSetup = true

                        var str = "<div style='font-size: " + PQCLook.fontSize + "pt; font-weight: bold'>" + deleg.filename + "</div>" +
                                  "<br><br>" +
                                  "<span style='font-size: " + PQCLook.fontSize + "pt'>" + qsTranslate("thumbnails", "File size:")+" <b>" + PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.filepath) + "</b></span><br>" +
                                  "<span style='font-size: " + PQCLook.fontSize + "pt'>" + qsTranslate("thumbnails", "File type:")+" <b>" + PQCScriptsFilesPaths.getFileType(deleg.filepath) + "</b></span>"

                        tooltip = str

                    } else if(!PQCSettings.thumbnailsTooltip) {

                        tooltipSetup = false
                        tooltip = ""

                    }

                }

                onExited: {
                    resetHighlightIndex.stop()
                    resetHighlightIndex.oldIndex = deleg.modelData
                    resetHighlightIndex.restart()
                }

                onClicked: {
                    executeClick()
                }
                function executeClick() {
                    if(PQCConstants.whichContextMenusOpen.length === 0)
                        PQCFileFolderModel.currentIndex = deleg.modelData
                }

            }

            Loader {
                asynchronous: true
                active: PQCSettings.thumbnailsFilename
                Item {
                    Rectangle {
                        anchors.fill: parent
                        color: view.hlInvertLabel&&deleg.active ? palette.text : palette.base
                        Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                        opacity: (PQCSettings.thumbnailsInactiveTransparent&&!deleg.active) ? 0.5 : 0.8
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    }
                    visible: PQCSettings.thumbnailsFilename
                    x: (img.x+img.width-width)
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
                        color: view.hlInvertLabel&&deleg.active ? palette.base : palette.text
                        Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                        opacity: (PQCSettings.thumbnailsInactiveTransparent&&!deleg.active) ? 0.5 : 0.8
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    }
                }
            }

            // line-below highlight animation
            Rectangle {

                id: linebelow

                opacity: (deleg.active&&view.hlLine) ? 1 : 0
                visible: opacity>0

                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                color: palette.text

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
                target: PQCNotify
                function onThumbnailReloadImage(ind : int) {
                    if(deleg.modelData === ind) {
                        img.source = ""
                        img.source = "image://thumb/" + deleg.filepath
                    }
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!rightclickmenu.opened)
                        delegmouse.executeClick()
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        PQCConstants.thumbnailsMenuReloadIndex = view.highlightIndex
                        rightclickmenu.popup(toucharea.mapToItem(thumbnails_top, toucharea.touchPos))
                    }
                }

            }

        }

    }


    WheelHandler {
        target: thumbnails_top
        acceptedDevices: PointerDevice.Mouse|PointerDevice.TouchPad
        orientation: Qt.Vertical|Qt.Horizontal
        onWheel: (event) => {

            if(thumbnails_top.state === "bottom" || thumbnails_top.state === "top") {

                if(Math.abs(event.angleDelta.x) > 5) return

                if(PQCSettings.thumbnailsCenterOnActive)
                    view.contentX = Math.max(-view.width/2, Math.min(view.contentWidth-view.width/2-PQCSettings.thumbnailsSize/2, view.contentX-event.angleDelta.y))
                else
                    view.contentX = Math.max(0, Math.min(view.contentWidth-view.width, view.contentX-event.angleDelta.y))

            } else if(thumbnails_top.state === "left" || thumbnails_top.state === "right") {

                if(Math.abs(event.angleDelta.y) > 5) return

                if(PQCSettings.thumbnailsCenterOnActive)
                    view.contentY = Math.max(-view.height/2, Math.min(view.contentHeight-view.height/2-PQCSettings.thumbnailsSize/2, view.contentY-event.angleDelta.x))
                else
                    view.contentY = Math.max(0, Math.min(view.contentHeight-view.height, view.contentY-event.angleDelta.x))

            }

            event.accepted = true
        }
    }

    ButtonGroup { id: grp1 }
    ButtonGroup { id: grp2 }

    PQMenu {

        id: rightclickmenu

        PQMenuItem {
            enabled: false
            font.italic: true
            // moveToRightABit: true
            text: qsTranslate("MainMenu", "Thumbnails")
        }

        PQMenuSeparator { }

        PQMenuItem {
            visible: PQCConstants.thumbnailsMenuReloadIndex>-1
            text: qsTranslate("thumbnails", "Reload thumbnail")
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg"
            onTriggered: {
                PQCScriptsImages.removeThumbnailFor(PQCFileFolderModel.entriesMainView[PQCConstants.thumbnailsMenuReloadIndex])
                PQCNotify.thumbnailReloadImage(PQCConstants.thumbnailsMenuReloadIndex)
            }
        }

        PQMenuSeparator { /*lighterColor: true; */visible: PQCConstants.thumbnailsMenuReloadIndex>-1 }

        PQMenu {

            title: "thumbnail image"

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "fit thumbnails")
                // ButtonGroup.group: grp1
                checked: (!PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth)
                onCheckedChanged: {
                    if(checked && (PQCSettings.thumbnailsCropToFit || PQCSettings.thumbnailsSameHeightVaryWidth)) {
                        PQCSettings.thumbnailsCropToFit = false
                        PQCSettings.thumbnailsSameHeightVaryWidth = false
                    }
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "scale and crop thumbnails")
                // ButtonGroup.group: grp1
                checked: PQCSettings.thumbnailsCropToFit
                onCheckedChanged: {
                    if(checked) {
                        PQCSettings.thumbnailsCropToFit = true
                        PQCSettings.thumbnailsSameHeightVaryWidth = false
                    }
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "same height, varying width")
                // ButtonGroup.group: grp1
                checked: PQCSettings.thumbnailsSameHeightVaryWidth
                onCheckedChanged: {
                    if(checked) {
                        // See the comment below for why this check is here
                        if(PQCSettings.thumbnailsCropToFit) {
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
                        PQCSettings.thumbnailsSameHeightVaryWidth = true
                    }
                }
            }

            PQMenuItem {
                checkable: true
                text: qsTranslate("settingsmanager", "keep small thumbnails small")
                checked: PQCSettings.thumbnailsSmallThumbnailsKeepSmall
                onCheckedChanged:
                PQCSettings.thumbnailsSmallThumbnailsKeepSmall = checked
            }

        }

        PQMenu {

            title: "visibility"

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "hide when not needed")
                // ButtonGroup.group: grp2
                checked: PQCSettings.thumbnailsVisibility===0
                onCheckedChanged: {
                    if(checked && PQCSettings.thumbnailsVisibility !== 0)
                        PQCSettings.thumbnailsVisibility = 0
                    checked = Qt.binding(function() { return PQCSettings.thumbnailsVisibility===0 })
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "always keep visible")
                // ButtonGroup.group: grp2
                checked: PQCSettings.thumbnailsVisibility===1
                onCheckedChanged: {
                    if(checked && PQCSettings.thumbnailsVisibility !== 1)
                        PQCSettings.thumbnailsVisibility = 1
                    checked = Qt.binding(function() { return PQCSettings.thumbnailsVisibility===1 })
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "hide when zoomed in")
                // ButtonGroup.group: grp2
                checked: PQCSettings.thumbnailsVisibility===2
                onCheckedChanged: {
                    if(checked && PQCSettings.thumbnailsVisibility !== 2)
                        PQCSettings.thumbnailsVisibility = 2
                    checked = Qt.binding(function() { return PQCSettings.thumbnailsVisibility===2 })
                }
            }

        }

        PQMenuSeparator {}

        PQMenuItem {
            checkable: true
            text: qsTranslate("settingsmanager", "show filename labels")
            checked: PQCSettings.thumbnailsFilename
            onCheckedChanged:
            PQCSettings.thumbnailsFilename = checked
        }

        PQMenuItem {
            checkable: true
            text: qsTranslate("settingsmanager", "show tooltips")
            checked: PQCSettings.thumbnailsTooltip
            onCheckedChanged:
            PQCSettings.thumbnailsTooltip = checked
        }

        PQMenuSeparator {}

        PQMenuItem {
            text: qsTranslate("settingsmanager", "Manage in settings manager")
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
            onTriggered: {
                PQCNotify.openSettingsManagerAt(2, "imag")
            }
        }

        onAboutToHide: {
            PQCConstants.thumbnailsMenuReloadIndex = -1
        }

    }

    // if a small play/pause button is shown then moving the mouse to the screen edge around it does not trigger the thumbnail bar
    property int ignoreRightMotion: state==="bottom"&&PQCConstants.currentImageIsMotionPhoto&&PQCSettings.filetypesMotionPhotoPlayPause ? 150 : 0

    Timer {
        id: hideElementWithDelay
        interval: 1000
        onTriggered: {
            thumbnails_top.setVisible = false
        }
    }

    property bool ignoreMouseMoveShortly: false

    Connections {

        target: PQCNotify

        function onMouseMove(posx : int, posy : int) {

            if(ignoreMouseMoveShortly || PQCConstants.modalWindowOpen || rightclickmenu.opened)
                return

            if(PQCConstants.slideshowRunning || PQCConstants.faceTaggingMode) {
                thumbnails_top.setVisible = false
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

        function onMouseWindowExit() {
            hideElementWithDelay.restart()
        }

        function onMouseWindowEnter() {
            hideElementWithDelay.stop()
        }

        function onCloseAllContextMenus() {
            rightclickmenu.dismiss()
        }
    }

    Connections {
        target: PQCConstants
        function onAvailableWidthChanged() {
            thumbnails_top.setVisible = false
        }
        function onAvailableHeightChanged() {
            thumbnails_top.setVisible = false
        }
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show" && param[0] === "thumbnails")
                thumbnails_top.setVisible = !thumbnails_top.setVisible
            else if(what === "forceshow" && param[0] === "thumbnails") {
                thumbnails_top.ignoreMouseMoveShortly = true
                thumbnails_top.setVisible = true
                resetIgnoreMouseMoveShortly.restart()
            } else if(what === "forcehide" && param[0] === "thumbnails") {
                thumbnails_top.ignoreMouseMoveShortly = true
                thumbnails_top.setVisible = false
                resetIgnoreMouseMoveShortly.restart()
            }

        }

    }

    Timer {
        id: resetIgnoreMouseMoveShortly
        interval: 250
        onTriggered: {
            thumbnails_top.ignoreMouseMoveShortly = false
        }
    }

}
