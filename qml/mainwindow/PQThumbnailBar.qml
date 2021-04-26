/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

    y:
        PQSettings.thumbnailPosition=="Top" ?

           ((PQSettings.thumbnailKeepVisible ||
           (variables.mousePos.y < PQSettings.hotEdgeWidth*5 && !visible) ||
           (variables.mousePos.y < height && visible) ||
           (PQSettings.thumbnailKeepVisibleWhenNotZoomedIn && variables.currentPaintedZoomLevel<=1)) ? 0 : -height) :

           ((PQSettings.thumbnailKeepVisible ||
           (variables.mousePos.y > toplevel.height-PQSettings.hotEdgeWidth*5 && !visible) ||
           (variables.mousePos.y > toplevel.height-height && visible) ||
           (PQSettings.thumbnailKeepVisibleWhenNotZoomedIn && variables.currentPaintedZoomLevel<=1)) ? (toplevel.height-height-(variables.videoControlsVisible ? 50 : 0)) : toplevel.height)


    visible: !variables.slideShowActive && !variables.faceTaggingActive && (PQSettings.thumbnailPosition=="Top" ? (y > -height) : (y < toplevel.height))

    width: toplevel.width-(variables.metaDataWidthWhenKeptOpen + xOffset*2)
    height: PQSettings.thumbnailSize+PQSettings.thumbnailLiftUp+scroll.height

    clip: true

    Behavior on x { NumberAnimation { duration: justAfterStartup ? 0 : PQSettings.animationDuration*100 } }
    Behavior on y { NumberAnimation { duration: justAfterStartup ? 0 : PQSettings.animationDuration*100 } }

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

        spacing: PQSettings.thumbnailSpacingBetween

        orientation: ListView.Horizontal

        model: PQSettings.thumbnailDisable ? 0 : foldermodel.count

        ScrollBar.horizontal: PQScrollBar { id: scroll }

        property int mouseOverItem: -1

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        preferredHighlightBegin: currentItem==null ? 0 : (PQSettings.thumbnailCenterActive ? (view.width-currentItem.width)/2 : PQSettings.thumbnailSize/2)
        preferredHighlightEnd: currentItem==null ? width : (PQSettings.thumbnailCenterActive ? (view.width-currentItem.width)/2+currentItem.width : (width-PQSettings.thumbnailSize/2))
        highlightRangeMode: ListView.ApplyRange

        Behavior on contentItem.x { NumberAnimation { duration: PQSettings.animationDuration*100 } }

        delegate: Rectangle {

            x: 0
            y: (view.currentIndex==index||view.mouseOverItem==index) ? 0 : PQSettings.thumbnailLiftUp
            Behavior on y { NumberAnimation { duration: PQSettings.animationDuration*100 } }

            width: PQSettings.thumbnailSize
            height: PQSettings.thumbnailSize

            color: "#88000000"

            Text {

                anchors.fill: parent
                anchors.margins: 5

                visible: PQSettings.thumbnailFilenameInstead
                color: "white"

                text: handlingFileDir.getFileNameFromFullPath(foldermodel.getFilePath(index))
                font.pointSize: PQSettings.thumbnailFilenameInsteadFontSize
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            }

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: (PQSettings.thumbnailFilenameInstead||PQSettings.thumbnailDisable) ? "" : "image://thumb/" + foldermodel.getFilePath(index)

                visible: !PQSettings.thumbnailFilenameInstead

                Rectangle {
                    visible: PQSettings.thumbnailWriteFilename
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
                        font.pointSize: PQSettings.thumbnailFontSize
                        font.bold: true
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: handlingFileDir.getFileNameFromFullPath(foldermodel.getFilePath(index), true)
                    }
                }
            }

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                tooltip: "<b><span style=\"font-size: x-large\">" + handlingFileDir.getFileNameFromFullPath(foldermodel.getFilePath(index), true) + "</span></b><br><br>" +
                         em.pty+qsTranslate("thumbnailbar", "File size:") + " " + handlingGeneral.convertBytesToHumanReadable(1024*handlingFileDir.getFileSize(foldermodel.getFilePath(index)).split(" ")[0]) + "<br>" +
                         em.pty+qsTranslate("thumbnailbar", "File type:" ) + " " + handlingFileDir.getFileType(foldermodel.getFilePath(index))
                onEntered:
                    view.mouseOverItem = index
                onClicked:
                    foldermodel.current = index
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
        target: foldermodel
        onCurrentChanged:
            view.currentIndex = foldermodel.current
        onFolderContentChanged: {
            view.model = 0
            if(foldermodel.count == 0)
                return
            view.model = Qt.binding(function() { return (PQSettings.thumbnailDisable ? 0 : foldermodel.count) })
            view.currentIndex = foldermodel.current
        }
    }

}
