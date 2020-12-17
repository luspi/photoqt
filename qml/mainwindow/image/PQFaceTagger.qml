/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
import "../../elements"

Item {

    id: facetagger_top

    property string filename: ""
    property var faceTags: []
    property var deletedFaceTagsIds: []

    signal hasBeenUpdated()

    visible: false

    // mouse area to tag new faces
    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: false
        onClicked: {

            if(newtag.visible) {

                if(newtag.width/facetagger_top.scale < 10 || newtag.height/facetagger_top.scale < 10) {
                    newtag.visible = false
                    return
                }

                namecont.opacity = 1
                nameedit.text = ""
                nameedit.setFocus()

            } else {
                var p = facetagger_top.mapFromItem(theimage, mouse.x, mouse.y)

                if(p.x < 0 || p.x > facetagger_top.width || p.y < 0 || p.y > facetagger_top.height)
                    return

                newtag.setX = p.x
                newtag.x = p.x
                newtag.setY = p.y
                newtag.y = p.y
                newtag.setWidth = 0
                newtag.setHeight = 0
                updateNewtagPos()
                newtag.visible = true
            }

        }

    }

    Repeater {

        id: repeat

        // this makes it easy for the model to be refreshed
        // easier than when using faceTags.length/6 as model
        model: ListModel { id: repeatermodel }

        delegate: Item {

            id: deleg

            x: facetagger_top.width*faceTags[6*index+1]
            y: facetagger_top.height*faceTags[6*index+2]
            width: facetagger_top.width*faceTags[6*index+3]
            height: facetagger_top.height*faceTags[6*index+4]

            property bool hovered: false

            // mark tags, change to red when hovered (for deletion)
            Rectangle {
                anchors.fill: parent
                color: hovered ? "#88ff0000" : "#88000000"
                Behavior on color { ColorAnimation { duration: 150 } }
                border.width: 3
                border.color: "#44ff0000"
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    color: "white"
                    font.bold: true
                    font.pointSize: 12
                    text: "x"
                    opacity: hovered ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
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
                    font.pointSize: PQSettings.peopleTagInMetaFontSize/facetagger_top.scale
                    color: "white"
                    text: " "+faceTags[6*index+5]+" "
                }

            }

            // delete this tag
            // this works as new tags are set using the global mouse events below
            PQMouseArea {
                anchors.fill: parent
                enabled: !newtag.visible
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered:
                    parent.hovered = true
                onExited:
                    parent.hovered = false
                onClicked:
                    deleteFaceTag(faceTags[6*index])
            }

        }

    }

    // mark a new tag
    Rectangle {
        id: newtag
        visible: false
        color: "#8800ff00"
        border.color: "#ccff0000"
        border.width: 2
        // we use set* to allow for negative width/height (requires computation, see below)
        property int setX: -1
        property int setY: -1
        property int setWidth: -1
        property int setHeight: -1
    }

    // enter new name
    Rectangle {

        id: namecont

        anchors.fill: parent
        color: "#cc000000"

        scale: 1/parent.scale

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        Column {
            y: (parent.height-height)/2
            width: parent.width
            height: childrenRect.height
            spacing: 10

            // heading
            Text {
                x: (parent.width-width)/2
                color: "white"
                font.pointSize: 15
                font.bold: true
                //: This question is asked in the face tagger to ask for the name of a tagged face
                text: em.pty+qsTranslate("facetagging", "Who is this?")
            }

            // edit name
            PQLineEdit {
                id: nameedit
                x: (parent.width-width)/2
                placeholderText: em.pty+qsTranslate("facetagging", "Enter name")
            }

            // buttons to save/cancel
            Row {
                x: (parent.width-width)/2
                width: childrenRect.width
                spacing: 10
                PQButton {
                    id: savename
                    text: genericStringSave
                    onClicked: {
                        addFaceTag()
                        newtag.visible = false
                        namecont.opacity = 0
                    }
                }
                PQButton {
                    id: cancelname
                    text: genericStringCancel
                    onClicked: {
                        namecont.opacity = 0
                        newtag.visible = false
                    }
                }
            }
        }
    }

    // react to mouse movements
    Connections {

        target: variables

        onMousePosChanged: {
            if(newtag.visible && !namecont.visible) {

                var p = facetagger_top.mapFromItem(bgimage, variables.mousePos.x, variables.mousePos.y)

                var newWidth = p.x-newtag.setX
                var newHeight = p.y-newtag.setY

                if(newtag.setX+newWidth > facetagger_top.width)
                    newWidth = facetagger_top.width-newtag.setX
                newtag.setWidth = newWidth

                if(newtag.setY+newHeight > facetagger_top.height)
                    newHeight = facetagger_top.height-newtag.setY
                newtag.setHeight = newHeight

                updateNewtagPos()

            }
        }

    }

    Connections {

        target: loader
        onFaceTaggerPassOn: {

            if(what == "start") {

                // start tagger
                if(variables.visibleItem == "" && handlingFaceTags.canWriteXmpTags(facetagger_top.filename)) {
                    variables.visibleItem = "facetagger"
                    variables.faceTaggingActive = true
                    imageitem.zoomReset()
                    imageitem.rotateReset()
                    imageitem.mirrorReset()
                    facetagger_top.visible = true
                    facetagger_top.deletedFaceTagsIds = []
                    facetagger_top.faceTags = handlingFaceTags.getFaceTags(facetagger_top.filename)
                    refreshModel()
                }

            } else if(what == "stop") {

                variables.visibleItem = ""
                variables.faceTaggingActive = false
                facetagger_top.visible = false

            } else if(what == "keyevent") {

                if(param[0] == Qt.Key_Escape) {
                    if(namecont.visible) {
                        cancelname.clicked()
                    } else if(newtag.visible) {
                        newtag.visible = false
                    } else {
                        variables.visibleItem = ""
                        variables.faceTaggingActive = false
                        facetagger_top.visible = false
                    }
                } else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    savename.clicked()

            }

        }

    }

    function updateNewtagPos() {
        if(newtag.setWidth >= 0) {
            newtag.x = newtag.setX
            newtag.width = newtag.setWidth
        } else {
            if(newtag.setX+newtag.setWidth >= 0) {
                newtag.x = newtag.setX+newtag.setWidth
                newtag.width = newtag.setX-newtag.x
            } else {
                newtag.x = 0
                newtag.width = newtag.setX-newtag.x
            }
        }

        if(newtag.setHeight >= 0) {
            newtag.y = newtag.setY
            newtag.height = newtag.setHeight
        } else {
            if(newtag.setY+newtag.setHeight >= 0) {
                newtag.y = newtag.setY+newtag.setHeight
                newtag.height = newtag.setY-newtag.y
            } else {
                newtag.y = 0
                newtag.height = newtag.setY-newtag.y
            }
        }
    }

    function addFaceTag() {
        faceTags.push(faceTags.length/6 +1)
        faceTags.push(newtag.x/facetagger_top.width)
        faceTags.push(newtag.y/facetagger_top.height)
        faceTags.push(newtag.width/facetagger_top.width)
        faceTags.push(newtag.height/facetagger_top.height)
        faceTags.push(nameedit.text)
        handlingFaceTags.setFaceTags(facetagger_top.filename, facetagger_top.faceTags)
        refreshModel()
        facetagger_top.hasBeenUpdated()
    }

    function deleteFaceTag(number) {

        for(var i = 0; i < faceTags.length/6; ++i) {
            if(faceTags[6*i] == number) {
                faceTags.splice(6*i, 6)
                break
            }
        }
        handlingFaceTags.setFaceTags(facetagger_top.filename, facetagger_top.faceTags)
        refreshModel()
        facetagger_top.hasBeenUpdated()

    }

    function refreshModel() {
        repeatermodel.clear()
        for(var i = 0; i < faceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

}
