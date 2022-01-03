/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import "../elements"

Item {

    property int xOffset: (view.contentWidth < (toplevel.width-variables.metaDataWidthWhenKeptOpen) ? ((toplevel.width-variables.metaDataWidthWhenKeptOpen)-view.contentWidth)/2 : 0)
    x: variables.metaDataWidthWhenKeptOpen + xOffset

    // ThumbnailsVisibility
    // 0 = on demand
    // 1 = always
    // 2 = except when zoomed

    y:
        PQSettings.thumbnailsEdge=="Top" ?

           ((PQSettings.thumbnailsVisibility==1 ||
           (variables.mousePos.y < 2*PQSettings.interfaceHotEdgeSize*5 && !visible) ||
           (variables.mousePos.y < height && visible) ||
           (PQSettings.thumbnailsVisibility==2 && variables.currentPaintedZoomLevel<=1) ||
           forceShow)&&!forceHide ? 0 : -height) :

           ((PQSettings.thumbnailsVisibility==1 ||
           (variables.mousePos.y > toplevel.height-2*PQSettings.interfaceHotEdgeSize*5 && !visible) ||
           (variables.mousePos.y > toplevel.height-height && visible) ||
           (PQSettings.thumbnailsVisibility==2 && variables.currentPaintedZoomLevel<=1) ||
           forceShow)&&!forceHide ? (toplevel.height-height-(variables.videoControlsVisible ? 50 : 0)) : toplevel.height)

    property bool forceShow: false
    property bool forceHide: false

    visible: !variables.slideShowActive && !variables.faceTaggingActive && (PQSettings.thumbnailsEdge=="Top" ? (y > -height) : (y < toplevel.height))

    width: toplevel.width-(variables.metaDataWidthWhenKeptOpen + xOffset*2)
    height: PQSettings.thumbnailsSize+PQSettings.thumbnailsLiftUp+scroll.height

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

    ListView {

        id: view

        anchors.fill: parent

        spacing: PQSettings.thumbnailsSpacing

        orientation: ListView.Horizontal

        model: PQSettings.thumbnailsDisable ? 0 : filefoldermodel.countMainView

        property bool excludeCurrentDirectory: false

        ScrollBar.horizontal: PQScrollBar { id: scroll }

        property int mouseOverItem: -1

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        preferredHighlightBegin: currentItem==null ? 0 : (PQSettings.thumbnailsCenterOnActive ? (view.width-currentItem.width)/2 : PQSettings.thumbnailsSize/2)
        preferredHighlightEnd: currentItem==null ? width : (PQSettings.thumbnailsCenterOnActive ? (view.width-currentItem.width)/2+currentItem.width : (width-PQSettings.thumbnailsSize/2))
        highlightRangeMode: ListView.ApplyRange

        Behavior on contentItem.x { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

        delegate: Rectangle {

            x: 0
            y: (view.currentIndex==index||view.mouseOverItem==index) ? 0 : PQSettings.thumbnailsLiftUp
            Behavior on y { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            width: PQSettings.thumbnailsSize
            height: PQSettings.thumbnailsSize

            color: "#88000000"

            Text {

                anchors.fill: parent
                anchors.margins: 5

                visible: PQSettings.thumbnailsFilenameOnly
                color: "white"

                text: handlingFileDir.getFileNameFromFullPath(filefoldermodel.entriesMainView[index])
                font.pointSize: PQSettings.thumbnailsFilenameOnlyFontSize
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            }

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: view.excludeCurrentDirectory ? ("image://icon/IMAGE////"+handlingFileDir.getSuffix(filefoldermodel.entriesMainView[index])) : ((PQSettings.thumbnailsFilenameOnly||PQSettings.thumbnailsDisable) ? "" : "image://thumb/" + filefoldermodel.entriesMainView[index])

                visible: !PQSettings.thumbnailsFilenameOnly

                Image {

                    width: Math.min(PQSettings.thumbnailsSize, 50)
                    height: width

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2

                    visible: imageproperties.isVideo(filefoldermodel.entriesMainView[index])

                    source: visible ? "/multimedia/play.png" : ""

                }

                Rectangle {
                    visible: PQSettings.thumbnailsFilename
                    color: "#88000000"
                    width: parent.width
                    height: parent.height/3
                    x: 0
                    y: 2*parent.height/3
                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.rightMargin: 2
                        color: "white"
                        elide: Text.ElideMiddle
                        font.pointSize: PQSettings.thumbnailsFontSize
                        font.bold: true
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
                onWheel: {
                    // assume horizontal scrolling
                    var newx = view.contentX - wheel.angleDelta.x
                    // if scrolling was vertical
                    if(wheel.angleDelta.x == 0 && wheel.angleDelta.y != 0)
                        var newx = view.contentX - wheel.angleDelta.y
                    // set new contentX, but don't move beyond left/right end of thumbnails
                    view.contentX = Math.max(0, Math.min(newx, view.contentWidth-view.width))
                }
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
        }
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
