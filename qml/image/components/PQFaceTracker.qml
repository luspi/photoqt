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

import PQCFileFolderModel
import PQCScriptsMetaData
import PQCNotify

import "../../elements"

Item {

    id: facetracker_top

    property var faceTags: []

    anchors.fill: parent

    visible: deleg.itemIndex===PQCFileFolderModel.currentIndex && !PQCNotify.slideshowRunning && !PQCNotify.showingPhotoSphere

    Repeater {

        id: repeat

        model: ListModel { id: repeatermodel }

        delegate: Item {

            id: facedeleg
            property var curdata: faceTags.slice(6*index, 6*(index+1))

            property bool hovered: false

            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0 && width > 10 && height > 10

            state: "hideentry"

            states: [
                State {
                    name: "showentry"
                    PropertyChanges {
                        target: facedeleg
                        opacity: 1
                    }
                },
                State {
                    name: "hideentry"
                    PropertyChanges {
                        target: facedeleg
                        opacity: 0
                    }
                }

            ]

            x: facetracker_top.width*curdata[1]
            y: facetracker_top.height*curdata[2]
            width: facetracker_top.width*curdata[3]
            height: facetracker_top.height*curdata[4]

            Rectangle {

                visible: PQCSettings.metadataFaceTagsBorder
                anchors.fill: parent
                color: "transparent"
                radius: Math.min(width/2, 10)
                border.width: PQCSettings.metadataFaceTagsBorderWidth/image_top.currentScale
                border.color: PQCSettings.metadataFaceTagsBorderColor
            }

            // This is the background of the text (semi-transparent black rectangle)
            Rectangle {
                id: labelcont
                x: (parent.width-width)/2
                y: parent.height
                width: faceLabel.width+14
                height: faceLabel.height+10
                radius: 10
                color: PQCLook.transColor
                rotation: -loader_top.imageRotation

                // This holds the person's name
                PQText {
                    id: faceLabel
                    x: 7
                    y: 5
                    font.pointSize: PQCLook.fontSize/image_top.currentScale
                    text: " "+facedeleg.curdata[5]+" "
                }

            }

            Connections {

                target: PQCNotify

                function onMouseMove(x, y) {

                    var pos = image_wrapper.mapFromItem(fullscreenitem, Qt.point(x,y))

                    hovered = false

                    if(pos.x >= facedeleg.x && pos.x <= facedeleg.x+facedeleg.width &&
                       pos.y >= facedeleg.y && pos.y <= facedeleg.y+facedeleg.height)
                        hovered = true

                    updateVisibility()

                }

            }

            Component.onCompleted: {
                updateVisibility()
            }

            Timer {
                id: triggerTimeout
                interval: 2000
                onTriggered: {
                    if(PQCSettings.metadataFaceTagsVisibility === 3)
                        facedeleg.state = "hideentry"
                }
            }

            function updateVisibility() {

                if(PQCNotify.faceTagging) {
                    facedeleg.state = "hideentry"
                    return
                }

                triggerTimeout.stop()

                if(PQCSettings.metadataFaceTagsVisibility === 1)
                    facedeleg.state = "showentry"

                else if(PQCSettings.metadataFaceTagsVisibility === 2) {
                    if(facedeleg.hovered)
                        facedeleg.state = "showentry"
                    else
                        facedeleg.state = "hideentry"
                } else if(PQCSettings.metadataFaceTagsVisibility === 3) {

                    if(x >= image_wrapper.x && x <= image_wrapper.x+image_wrapper.width &&
                       y >= image_wrapper.y && y <= image_wrapper.y+image_wrapper.height) {
                        facedeleg.state = "showentry"
                        triggerTimeout.restart()
                    } else
                        facedeleg.state = "hideentry"

                }

            }

        }

    }

    Timer {
        interval: PQCSettings.imageviewAnimationDuration*100
        running: true
        onTriggered:
            loadData()
    }

    function loadData() {
        repeatermodel.clear()

        if(!PQCSettings.metadataFaceTagsEnabled || PQCNotify.showingPhotoSphere)
            return

        faceTags = PQCScriptsMetaData.getFaceTags(PQCFileFolderModel.currentFile)
        for(var i = 0; i < faceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

}
