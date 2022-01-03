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

Item {

    id: facetracker_top

    property string filename: ""
    property var faceTags: []
    property int indexOfLabelHovered: -1

    Repeater {

        id: repeat

        model: ListModel { id: repeatermodel }

        delegate: Item {

            id: deleg

            x: facetracker_top.width*faceTags[6*index+1]
            y: facetracker_top.height*faceTags[6*index+2]
            width: facetracker_top.width*faceTags[6*index+3]
            height: facetracker_top.height*faceTags[6*index+4]

            property bool labelMouseHovered: false
            property bool fullMouseHovered: false

            visible: opacity>0
            // PQSettings.metadataFaceTagsVisibility:
            // 0 = Hybrid
            // 1 = show all always
            // 2 = show one on hover
            // 3 = show all on hover
            opacity: (((PQSettings.metadataFaceTagsVisibility==0 && fullMouseHovered && (indexOfLabelHovered == index || indexOfLabelHovered == -1)) ||
                        PQSettings.metadataFaceTagsVisibility==1 ||
                       (PQSettings.metadataFaceTagsVisibility==2 && labelMouseHovered) ||
                       (PQSettings.metadataFaceTagsVisibility==3 && fullMouseHovered)) && PQSettings.metadataFaceTagsEnabled) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Rectangle {
                visible: PQSettings.metadataFaceTagsBorder
                anchors.fill: parent
                color: "transparent"
                border.width: PQSettings.metadataFaceTagsBorderWidth/facetracker_top.scale
                border.color: PQSettings.metadataFaceTagsBorderColor
            }

            // This is the background of the text (semi-transparent black rectangle)
            Rectangle {
                x: (parent.width-width)/2
                y: parent.height
                width: faceLabel.width+8
                height: faceLabel.height+8
                color: "#bb000000"

                // This holds the person's name
                Text {
                    id: faceLabel
                    x: 4
                    y: 4
                    font.pointSize: PQSettings.metadataFaceTagsFontSize/facetracker_top.scale
                    color: "white"
                    renderType: Text.QtRendering
                    text: " "+faceTags[6*index+5]+" "
                }

            }

            Connections {

                target: variables

                onMousePosChanged:
                    deleg.handleMouseMove()

            }

            function handleMouseMove() {

                var p = deleg.mapFromItem(bgimage, variables.mousePos.x, variables.mousePos.y)
                deleg.labelMouseHovered = !(p.x < 0 || p.x > deleg.width || p.y < 0 || p.y > deleg.height)
                if(deleg.labelMouseHovered)
                    facetracker_top.indexOfLabelHovered = index
                else if(!deleg.labelMouseHovered && facetracker_top.indexOfLabelHovered == index)
                    facetracker_top.indexOfLabelHovered = -1

                p = facetracker_top.mapFromItem(bgimage, variables.mousePos.x, variables.mousePos.y)
                deleg.fullMouseHovered = !(p.x < 0 || p.x > facetracker_top.width || p.y < 0 || p.y > facetracker_top.height)

            }

        }

    }

    Component.onCompleted: {
        faceTags = (PQSettings.metadataFaceTagsVisibility!=0 ? handlingFaceTags.getFaceTags(filename) : [])
        refreshModel()
    }

    Connections {
        target: PQSettings
        onMetadataFaceTagsVisibilityChanged: {
            faceTags = (PQSettings.metadataFaceTagsVisibility!=0 ? handlingFaceTags.getFaceTags(filename) : [])
            refreshModel()
        }

    }

    function updateData() {
        faceTags = (PQSettings.metadataFaceTagsVisibility!=0 ? handlingFaceTags.getFaceTags(filename) : [])
        refreshModel()
    }

    function refreshModel() {
        repeatermodel.clear()
        for(var i = 0; i < faceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

}
