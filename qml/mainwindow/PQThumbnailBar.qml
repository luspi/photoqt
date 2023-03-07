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
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../elements"

Item {

    id: thumb_top

    property int xOffset: (view.contentWidth < toplevel.width ? (toplevel.width-view.contentWidth)/2 : 0)
    x: xOffset

    // ThumbnailsVisibility
    // 0 = on demand
    // 1 = always
    // 2 = except when zoomed

    y: shouldBeVisible ? posVisible : posHidden

    property bool forceShow: false
    property bool forceHide: false
    onForceShowChanged: calculateY()
    onForceHideChanged: calculateY()

    property int posVisible: 0
    property int posHidden: 0

    property bool shouldBeVisible: false

    function checkVisibility() {

        if(variables.visibleItem != "") {
            shouldBeVisible = false
            return
        }

        if(PQSettings.thumbnailsEdge == "Top") {

            if(filefoldermodel.current == -1)
                shouldBeVisible = false

            // force it hidden
            else if(forceHide)
                shouldBeVisible = false

            // always visible
            else if(PQSettings.thumbnailsVisibility == 1)
                shouldBeVisible = true
            // mouse pointer close to top edge and bar not visible
            else if(variables.mousePos.y < 2*PQSettings.interfaceHotEdgeSize*5 && !visible && variables.mousePos.x < toplevel.width-windowbuttons.width-50)
                shouldBeVisible = (toplevel.height > 500)
            else if(variables.mousePos.y < height+windowbuttons.height && visible)
                shouldBeVisible = (toplevel.height > 500)
            // mouse pointer hovering visible bar
            else if(variables.mousePos.y < height && visible)
                shouldBeVisible = (toplevel.height > 500)
            // thumbnails set to 'hide when zoomed in' but we're not zoomed in
            else if(PQSettings.thumbnailsVisibility==2 && variables.currentPaintedZoomLevel<=1)
                shouldBeVisible = true
            else if(forceShow)
                shouldBeVisible = true

            else
                shouldBeVisible = false

        } else {

            if(filefoldermodel.current == -1)
                shouldBeVisible = false

            else if(forceHide)
                shouldBeVisible = false

            else if(PQSettings.thumbnailsVisibility==1)
                shouldBeVisible = true

            else if(variables.mousePos.y > toplevel.height-2*PQSettings.interfaceHotEdgeSize*5 && !visible)
                shouldBeVisible = (toplevel.height > 500)

            else if(variables.mousePos.y > toplevel.height-height-(variables.videoControlsVisible ? 100 : 25) && visible)
                shouldBeVisible = (toplevel.height > 500)

            else if(PQSettings.thumbnailsVisibility==2 && variables.currentPaintedZoomLevel<=1)
                shouldBeVisible = true

            else if(forceShow)
                shouldBeVisible = true

            else
                shouldBeVisible = false

        }

    }

    function calculateY() {

        if(PQSettings.thumbnailsEdge == "Top") {

            posVisible = 0
            posHidden = -height

        } else {

            posVisible = toplevel.height-height-(variables.videoControlsVisible ? 100 : 0)
            posHidden = toplevel.height

        }

    }

    visible: !variables.slideShowActive && !variables.faceTaggingActive && y!=posHidden
    onVisibleChanged:
        checkVisibility()

    width: toplevel.width - xOffset*2
    height: PQSettings.thumbnailsSize+PQSettings.thumbnailsLiftUp+scroll.height
    onHeightChanged: calculateY()

    clip: true

    Behavior on x { NumberAnimation { duration: justAfterStartup ? 0 : PQSettings.imageviewAnimationDuration*100 } }
    Behavior on y { NumberAnimation { duration: justAfterStartup ? 0 : PQSettings.imageviewAnimationDuration*100 } }

    property bool justAfterStartup: true
    Timer {
        running: true
        repeat: false
        interval: 250
        onTriggered: justAfterStartup = false
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onWheel: {
            scrollViewFromWheel(wheel.angleDelta)
            wheel.accepted = true
        }
    }

    ListView {

        id: view

        anchors.fill: parent

        orientation: ListView.Horizontal

        model: PQSettings.thumbnailsDisable ? 0 : filefoldermodel.countMainView

        property bool excludeCurrentDirectory: false

        ScrollBar.horizontal: PQScrollBar { id: scroll }
        boundsBehavior: xOffset==0 ? ListView.DragOverBounds : ListView.StopAtBounds

        property int mouseOverItem: -1

        // count continuing scroll
        property int flickCounter: 0
        // after stopping to scroll for a little, we reset the continuing scroll counter
        onFlickCounterChanged:
            resetFlickCounter.restart()
        Timer {
            id: resetFlickCounter
            interval: 400
            repeat: false
            running: false
            onTriggered:
                view.flickCounter = 0
        }

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        preferredHighlightBegin: currentItem==null ? 0 : (PQSettings.thumbnailsCenterOnActive ? (view.width-currentItem.width)/2 : PQSettings.thumbnailsSize/2)
        preferredHighlightEnd: currentItem==null ? width : (PQSettings.thumbnailsCenterOnActive ? (view.width-currentItem.width)/2+currentItem.width : (width-PQSettings.thumbnailsSize/2))
        highlightRangeMode: ListView.ApplyRange

        Behavior on contentItem.x { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

        delegate: Item {

            id: deleg

            x: 0
            y: (view.currentIndex==index||view.mouseOverItem==index) ? 0 : PQSettings.thumbnailsLiftUp
            Behavior on y { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            width: PQSettings.thumbnailsSize+PQSettings.thumbnailsSpacing
            height: PQSettings.thumbnailsSize

            Item {
                id: empty
                width: 1
                height: 1
            }

            ShaderEffectSource{
                id: shader
                sourceItem: PQSettings.interfaceBlurElementsInBackground ? imageitem : empty
                anchors.fill: parent
                property point glob: view.mapToGlobal((deleg.width*index)-view.contentX-toplevel.x, view.y+deleg.y-toplevel.y)
                sourceRect: Qt.rect(glob.x-imageitem.x, glob.y-imageitem.y, deleg.width, deleg.height)
            }

            GaussianBlur {
                anchors.fill: parent
                source: shader
                radius: 9
                samples: 19
                deviation: 10
                transparentBorder: false
            }

            Connections {
                target: view
                onContentXChanged:
                    shader.glob = view.mapToGlobal((deleg.width*index)-view.contentX-toplevel.x, view.y+deleg.y-toplevel.y)
                onContentYChanged:
                    shader.glob = view.mapToGlobal((deleg.width*index)-view.contentX-toplevel.x, view.y+deleg.y-toplevel.y)
            }

            Connections {
                target: thumb_top
                onXChanged:
                    shader.glob = view.mapToGlobal((deleg.width*index)-view.contentX-toplevel.x, view.y+deleg.y-toplevel.y)
                onYChanged:
                    shader.glob = view.mapToGlobal((deleg.width*index)-view.contentX-toplevel.x, view.y+deleg.y-toplevel.y)
            }

            Timer {
                id: forceBlur
                repeat: false
                running: true
                interval: 300
                onTriggered:
                    shader.glob = view.mapToGlobal((deleg.width*index)-view.contentX-toplevel.x, view.y+deleg.y-toplevel.y)
            }

            Rectangle {
                anchors.fill: parent
                color: PQSettings.interfaceBlurElementsInBackground ? "#99000000" : "#bb000000"
            }

            PQText {

                anchors.fill: parent
                anchors.margins: 5

                visible: PQSettings.thumbnailsFilenameOnly

                text: handlingFileDir.getFileNameFromFullPath(filefoldermodel.entriesMainView[index])
                font.pointSize: PQSettings.thumbnailsFilenameOnlyFontSize
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            }

            Image {
                x: PQSettings.thumbnailsSpacing/2
                y: 0
                width: PQSettings.thumbnailsSize
                height: PQSettings.thumbnailsSize
                fillMode: PQSettings.thumbnailsCropToFit ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                source: view.excludeCurrentDirectory ? ("image://icon/IMAGE////"+handlingFileDir.getSuffix(filefoldermodel.entriesMainView[index])) : ((PQSettings.thumbnailsFilenameOnly||PQSettings.thumbnailsDisable) ? "" : "image://thumb/" + filefoldermodel.entriesMainView[index])

                visible: !PQSettings.thumbnailsFilenameOnly

                Image {

                    width: Math.min(PQSettings.thumbnailsSize, 50)
                    height: width

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2

                    visible: imageproperties.isVideo(filefoldermodel.entriesMainView[index])

                    source: visible ? "/multimedia/play.svg" : ""

                    sourceSize: Qt.size(width, height)

                }

                Rectangle {
                    visible: PQSettings.thumbnailsFilename
                    color: "#aa2f2f2f"
                    width: deleg.width
                    height: parent.height/3
                    x: (parent.width-width)/2
                    y: 2*parent.height/3
                    PQText {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        elide: Text.ElideMiddle
                        font.pointSize: PQSettings.thumbnailsFontSize
                        font.weight: baselook.boldweight
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: handlingFileDir.getFileNameFromFullPath(filefoldermodel.entriesMainView[index], true)
                    }
                }
            }

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                property bool tooltipSetup: false
                acceptedButtons: Qt.RightButton|Qt.MiddleButton|Qt.LeftButton
                onEntered: {

                    if(!tooltipSetup) {

                        var fpath = filefoldermodel.entriesMainView[index]

                        tooltip = "<b><span style=\"font-size: x-large\">" + handlingGeneral.escapeHTML(handlingFileDir.getFileNameFromFullPath(fpath, true)) + "</span></b><br><br>" +
                                 em.pty+qsTranslate("thumbnailbar", "File size:") + " " + handlingGeneral.convertBytesToHumanReadable(handlingFileDir.getFileSize(fpath)) + "<br>" +
                                 em.pty+qsTranslate("thumbnailbar", "File type:" ) + " " + handlingFileDir.getFileType(fpath)

                        tooltipSetup = true

                    }

                    view.mouseOverItem = index
                }
                onClicked:
                    filefoldermodel.current = index
                onExited:
                    view.mouseOverItem = -1
                onWheel:
                    scrollViewFromWheel(wheel.angleDelta)
            }

        }

    }

    Connections {
        target: filefoldermodel
        onCurrentChanged:
            view.currentIndex = filefoldermodel.current
        onNewDataLoadedMainView: {
            view.model = 0
            if(filefoldermodel.countMainView == 0)
                return
            view.excludeCurrentDirectory = handlingFileDir.isExcludeDirFromCaching(handlingFileDir.getFilePathFromFullPath(filefoldermodel.fileInFolderMainView))
            view.model = Qt.binding(function() { return (PQSettings.thumbnailsDisable ? 0 : filefoldermodel.countMainView) })
            view.currentIndex = filefoldermodel.current
        }
    }

    Connections {
        target: variables
        onMousePosChanged: {
            forceShow = false
            forceHide = false
            checkVisibility()
        }
        onCurrentPaintedZoomLevelChanged:
            checkVisibility()
        onVideoControlsVisibleChanged:
            calculateY()
    }

    Connections {
        target: PQSettings
        onThumbnailsEdgeChanged: {
            calculateY()
            checkVisibility()
        }
        onThumbnailsVisibilityChanged:
            checkVisibility()
        onInterfaceHotEdgeSizeChanged:
            checkVisibility()
    }

    Connections {
        target: toplevel
        onHeightChanged:
            calculateY()
    }

    Component.onCompleted: {
        calculateY()
        checkVisibility()
    }

    function scrollViewFromWheel(angleDelta) {

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

        var fac = 10 + Math.min(20, Math.abs(view.flickCounter))

        // flick horizontally
        view.flick(fac*val, 0)

    }

    function toggle() {
        if(forceShow || visible) {
            forceShow = false
            forceHide = true
        } else {
            forceShow = true
            forceHide = false
        }
    }

}
