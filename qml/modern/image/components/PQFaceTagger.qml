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
import PhotoQt

Item {

    id: facetagger_top

    property list<var> faceTags: []

    anchors.fill: parent

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property int threshold: 5

    Rectangle {

        parent: fullscreenitem_foreground // qmllint disable unqualified
        x: 20
        y: 20
        width: 42
        height: 42
        radius: 21

        visible: PQCConstants.faceTaggingMode // qmllint disable unqualified

        color: PQCLook.transColor // qmllint disable unqualified

        Image {
            x: 5
            y: 5
            width: 32
            height: 32
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
        }

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: qsTranslate("facetagging", "Click to exit face tagging mode")
            onClicked: facetagger_top.hide()
        }

    }

    Repeater {

        id: repeat

        model: ListModel { id: repeatermodel }

        delegate: Item {

            id: facedeleg

            required property int index

            property list<var> curdata: facetagger_top.faceTags.slice(6*index, 6*(index+1))

            x: facetagger_top.width*curdata[1]
            y: facetagger_top.height*curdata[2]
            width: facetagger_top.width*curdata[3]
            height: facetagger_top.height*curdata[4]

            property bool hovered: false

            Rectangle {
                id: bg
                anchors.fill: parent
                color: PQCLook.transColor // qmllint disable unqualified
                radius: Math.min(width/2, 2)
                border.width: 5
                border.color: PQCLook.baseColorActive // qmllint disable unqualified
                opacity: facedeleg.hovered ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            PQTextXL {
                id: del
                anchors.centerIn: bg
                text: "x"
                opacity: facedeleg.hovered ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // This is the background of the text (semi-transparent black rectangle)
            Rectangle {
                id: labelcont
                x: (parent.width-width)/2
                y: parent.height
                width: faceLabel.width+14
                height: faceLabel.height+10
                radius: 10
                color: PQCLook.transColor // qmllint disable unqualified
                rotation: -loader_top.imageRotation // qmllint disable unqualified

                // This holds the person's name
                PQText {
                    id: faceLabel
                    x: 7
                    y: 5
                    font.pointSize: PQCLook.fontSize/PQCConstants.currentImageScale // qmllint disable unqualified
                    text: " "+facedeleg.curdata[5]+" "
                }

            }

            property point mousePressed: Qt.point(-1,-1)

            Connections {
                target: PQCNotify

                enabled: !newmarker.visible && PQCConstants.faceTaggingMode // qmllint disable unqualified

                function onMouseMove(x : int, y : int) {
                    var pos = facedeleg.mapFromItem(fullscreenitem, Qt.point(x,y)) // qmllint disable unqualified
                    facedeleg.hovered = (pos.x >= 0 && pos.x <= facedeleg.width && pos.y >= 0 && pos.y <= facedeleg.height)
                }

                function onMouseReleased(modifiers : int, button : int, pos : point) {
                    pos = facedeleg.mapFromItem(fullscreenitem, pos) // qmllint disable unqualified
                    if(Math.abs(facedeleg.mousePressed.x - pos.x) < facetagger_top.threshold && Math.abs(facedeleg.mousePressed.y-pos.y) < facetagger_top.threshold) {
                        if(facedeleg.hovered) {
                            facetagger_top.deleteFaceTag(facedeleg.curdata[0])
                        }
                    }
                }

                function onMousePressed(modifiers : int, button : int, pos : point) {
                    facedeleg.mousePressed = facedeleg.mapFromItem(fullscreenitem, pos) // qmllint disable unqualified
                }

            }

        }

    }

    Rectangle {
        id: newmarker
        color: PQCLook.transColor // qmllint disable unqualified
        radius: Math.min(width/2, 2)
        border.width: 5
        border.color: PQCLook.baseColorActive // qmllint disable unqualified
        opacity: 0.5
        visible: false

        property int newX: x
        property int newY: y
        property int newWidth: width
        property int newHeight: height
        function updatePos() {
            if(newWidth >= 0) {
                x = newX
                width = newWidth
            } else {
                if(newX+newWidth >= 0) {
                    x = newX+newWidth
                    width = newX-x
                } else {
                    x = 0
                    width = newX-x
                }
            }

            if(newHeight >= 0) {
                y = newY
                height = newHeight
            } else {
                if(newY+newHeight >= 0) {
                    y = newY+newHeight
                    height = newY-y
                } else {
                    y = 0
                    height = newY-y
                }
            }
        }
    }

    Rectangle {
        id: whoisthis
        parent: fullscreenitem_foreground // qmllint disable unqualified
        anchors.fill: parent
        color: PQCLook.transColor // qmllint disable unqualified
        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Column {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            spacing: 10

            PQTextXL {
                x: (parent.width-width)/2
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                text: qsTranslate("facetagging", "Who is this?")
            }

            PQLineEdit {
                id: whoisthis_name
                x: (parent.width-width)/2
            }

            Row {

                spacing: 10

                PQButton {
                    id: but_save
                    text: genericStringSave
                    onClicked: whoisthis.save()
                }

                PQButton {
                    id: save_cancel
                    text: genericStringCancel
                    onClicked: whoisthis.hide()
                }

            }

        }

        function show() {
            opacity = 1
            whoisthis_name.text = ""
            whoisthis_name.setFocus()
        }

        function hide() {
            opacity = 0
            mouseDown = false
            newmarker.visible = false
        }

        function save() {
            facetagger_top.faceTags.push(facetagger_top.faceTags.length/6 + 1)
            facetagger_top.faceTags.push(newmarker.x/facetagger_top.width)
            facetagger_top.faceTags.push(newmarker.y/facetagger_top.height)
            facetagger_top.faceTags.push(newmarker.width/facetagger_top.width)
            facetagger_top.faceTags.push(newmarker.height/facetagger_top.height)
            facetagger_top.faceTags.push(whoisthis_name.text)
            facetagger_top.faceTagsChanged()
            PQCScriptsMetaData.setFaceTags(PQCFileFolderModel.currentFile, facetagger_top.faceTags) // qmllint disable unqualified
            facetagger_top.loadData()
            facetracker.loadData()
            whoisthis.hide()
        }
    }

    property bool mouseDown: false
    property point mousePressed: Qt.point(-1,-1)

    Connections {

        target: PQCNotify

        enabled: PQCConstants.faceTaggingMode && !whoisthis.visible // qmllint disable unqualified

        function onMouseMove(x : int, y : int) {
            if(!facetagger_top.mouseDown) return
            var pos = facetagger_top.mapFromItem(fullscreenitem, Qt.point(x,y)) // qmllint disable unqualified
            if(Math.abs(facetagger_top.mousePressed.x - pos.x) >= facetagger_top.threshold || Math.abs(facetagger_top.mousePressed.y-pos.y) >= facetagger_top.threshold) {
                newmarker.newX = facetagger_top.mousePressed.x
                newmarker.newY = facetagger_top.mousePressed.y
                newmarker.newWidth = pos.x - facetagger_top.mousePressed.x
                newmarker.newHeight = pos.y - facetagger_top.mousePressed.y
                newmarker.updatePos()
                newmarker.visible = true
            } else
                newmarker.visible = false
        }

        function onMouseReleased(modifiers : int, button : int, pos : point) {
            pos = facetagger_top.mapFromItem(fullscreenitem, pos) // qmllint disable unqualified
            if(Math.abs(facetagger_top.mousePressed.x - pos.x) >= facetagger_top.threshold || Math.abs(facetagger_top.mousePressed.y-pos.y) >= facetagger_top.threshold) {
                whoisthis.show()
            } else {
                facetagger_top.mouseDown = false
                newmarker.visible = false
            }
        }

        function onMousePressed(modifiers : int, button : int, pos : point) {
            facetagger_top.mouseDown = true
            facetagger_top.mousePressed = facetagger_top.mapFromItem(fullscreenitem, pos) // qmllint disable unqualified
        }

    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(loader_top.isMainImage) { // qmllint disable unqualified

                if(what === "tagFaces") {

                    if(!PQCScriptsMetaData.areFaceTagsSupported(PQCFileFolderModel.currentFile)) {
                        PQCNotify.showNotificationMessage(qsTranslate("unavailable", "Unavailable"), qsTranslate("unavailable", "This file type does not support face tags."))
                        return
                    } else if(PQCConstants.showingPhotoSphere) {
                        PQCNotify.showNotificationMessage(qsTranslate("unavailable", "Unavailable"), qsTranslate("unavailable", "Faces cannot be tagged when inside photo sphere."))
                        return
                    } else
                        PQCNotify.showNotificationMessage(qsTranslate("facetagging", "Tagging faces"), qsTranslate("facetagging", "Face tagging mode activated. Click-and-drag to tag faces."))

                    PQCScriptsShortcuts.sendShortcutZoomReset()
                    PQCScriptsShortcuts.sendShortcutRotateReset()
                    PQCScriptsShortcuts.sendShortcutMirrorReset()

                    PQCNotify.loaderOverrideVisibleItem("facetagger")
                    PQCConstants.faceTaggingMode = true
                    facetagger_top.show()

                } else if(what === "keyEvent" && PQCConstants.faceTaggingMode) {

                    if(param[0] === Qt.Key_Escape) {

                        if(whoisthis.visible)
                            whoisthis.hide()
                        else
                            facetagger_top.hide()

                    } else if(param[0] === Qt.Key_Return || param[0] === Qt.Key_Enter) {
                        whoisthis.save()
                        whoisthis.hide()
                    }

                }

            }

        }

    }

    function deleteFaceTag(number : int) {

        if(!PQCConstants.faceTaggingMode) return // qmllint disable unqualified

        for(var i = 0; i < faceTags.length/6; ++i) {
            if(faceTags[6*i] === number) {
                faceTags.splice(6*i, 6)
                break
            }
        }
        PQCScriptsMetaData.setFaceTags(PQCFileFolderModel.currentFile, faceTags)
        loadData()
        facetracker.loadData()

    }

    function show() {
        opacity = 1
        loadData()
    }


    function loadData() {
        repeatermodel.clear()

        faceTags = PQCScriptsMetaData.getFaceTags(PQCFileFolderModel.currentFile) // qmllint disable unqualified
        for(var i = 0; i < faceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

    function hide() {
        opacity = 0
        PQCConstants.faceTaggingMode = false // qmllint disable unqualified
        PQCNotify.loaderRegisterClose("facetagger")
    }

}
