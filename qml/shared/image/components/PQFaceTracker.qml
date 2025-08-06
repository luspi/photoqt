/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import PhotoQt.Shared

/* :-)) <3 */

Loader {

    id: ldr_top

    SystemPalette { id: pqtPalette }

    property string imageSource
    property bool isMainImage

    asynchronous: true

    active: !PQCConstants.currentImageIsDocument && !PQCConstants.currentImageIsAnimated &&
            !PQCConstants.currentImageIsArchive && !PQCConstants.currentImageIsPhotoSphere &&
            !PQCConstants.slideshowRunning && !PQCConstants.showingPhotoSphere && isMainImage

    sourceComponent:
    Item {

        id: facetracker_top

        parent: ldr_top.parent

        anchors.fill: parent

        property list<var> faceTags: []

        Repeater {

            id: repeat

            model: ListModel { id: repeatermodel }

            delegate: Item {

                id: facedeleg

                required property int index

                property list<var> curdata: facetracker_top.faceTags.slice(6*index, 6*(index+1))

                property bool hovered: false

                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0 && width > 10 && height > 10

                state: "hideentry"

                states: [
                    State {
                        name: "showentry"
                        PropertyChanges {
                            facedeleg.opacity: 1
                        }
                    },
                    State {
                        name: "hideentry"
                        PropertyChanges {
                            facedeleg.opacity: 0
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
                    border.width: PQCSettings.metadataFaceTagsBorderWidth/PQCConstants.currentImageScale
                    border.color: PQCSettings.metadataFaceTagsBorderColor
                }

                // This is the background of the text (semi-transparent black rectangle)
                Item {
                    id: labelcont
                    x: (parent.width-width)/2
                    y: parent.height
                    width: faceLabel.width+14
                    height: faceLabel.height+10
                    rotation: -PQCConstants.currentImageRotation

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: pqtPalette.base
                        opacity: 0.8
                    }

                    // This holds the person's name
                    Label {
                        id: faceLabel
                        x: 7
                        y: 5
                        font.pointSize: PQCLook.fontSize/PQCConstants.currentImageScale
                        text: " "+facedeleg.curdata[5]+" "
                    }

                }

                Connections {

                    target: PQCNotify

                    function onMouseMove(x : int, y : int) {

                        var pos = image_wrapper.mapFromItem(fullscreenitem, Qt.point(x,y))

                        facedeleg.hovered = false

                        if(pos.x >= facedeleg.x && pos.x <= facedeleg.x+facedeleg.width &&
                           pos.y >= facedeleg.y && pos.y <= facedeleg.y+facedeleg.height)
                            facedeleg.hovered = true

                        facedeleg.updateVisibility()

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

                    if(PQCConstants.faceTaggingMode) {
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

                        if(x >= facetracker_top.parent.x && x <= facetracker_top.parent.x+facetracker_top.parent.width &&
                           y >= facetracker_top.parent.y && y <= facetracker_top.parent.y+facetracker_top.parent.height) {
                            facedeleg.state = "showentry"
                            triggerTimeout.restart()
                        } else
                            facedeleg.state = "hideentry"

                    }

                }

            }

        }

        Timer {
            interval: 500
            running: true
            onTriggered:
                facetracker_top.loadData()
        }

        Connections {

            target: PQCNotify

            function onCurrentFaceTagsReload() {
                facetracker_top.loadData()
            }

            function onStopFaceTagging() {
                facetracker_top.loadData()
            }

        }

        function loadData() {
            repeatermodel.clear()

            if(!PQCSettings.metadataFaceTagsEnabled || PQCConstants.showingPhotoSphere)
                return

            faceTags = PQCScriptsMetaData.getFaceTags(PQCFileFolderModel.currentFile)
            for(var i = 0; i < faceTags.length/6; ++i)
                repeatermodel.append({"index" : i})
        }

    }

}
