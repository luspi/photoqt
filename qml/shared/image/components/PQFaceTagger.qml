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

Loader {

    id: ldr_top

    SystemPalette { id: pqtPalette }

    property string imageSource
    property bool isMainImage

    asynchronous: true

    active: !PQCConstants.currentImageIsDocument && !PQCConstants.currentImageIsAnimated &&
            !PQCConstants.currentImageIsArchive && !PQCConstants.currentImageIsPhotoSphere &&
            !PQCConstants.slideshowRunning && !PQCConstants.showingPhotoSphere

    sourceComponent:
    Item {

        id: facetagger_top

        parent: ldr_top.parent

        anchors.fill: parent

        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        property list<var> faceTags: []
        property int threshold: 5

        Item {

            parent: ldr_top.parent.parent
            x: 20
            y: 20
            width: 42
            height: 42

            visible: PQCConstants.faceTaggingMode


            Rectangle {
                anchors.fill: parent
                color: pqtPalette.base
                radius: 21
                opacity: 0.8
            }

            Image {
                x: 5
                y: 5
                width: 32
                height: 32
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
            }

            PQGenericMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: qsTranslate("facetagging", "Click to exit face tagging mode")
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
                    color: pqtPalette.base
                    radius: Math.min(width/2, 2)
                    border.width: 5
                    border.color: pqtPalette.base
                    opacity: facedeleg.hovered ? 0.8 : 0.4
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Text {
                    id: del
                    anchors.centerIn: bg
                    text: "x"
                    font.pointSize: PQCLook.fontSizeXL
                    color: pqtPalette.text
                    opacity: facedeleg.hovered ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
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
                        color: pqtPalette.base
                        radius: 10
                        opacity: 0.8
                    }

                    // This holds the person's name
                    Text {
                        id: faceLabel
                        x: 7
                        y: 5
                        color: pqtPalette.text
                        font.pointSize: PQCLook.fontSize/PQCConstants.currentImageScale
                        text: " "+facedeleg.curdata[5]+" "
                    }

                }

                property point mousePressed: Qt.point(-1,-1)

                Connections {
                    target: PQCNotify

                    enabled: !newmarker.visible && PQCConstants.faceTaggingMode

                    function onMouseMove(x : int, y : int) {
                        var pos = facedeleg.mapFromItem(fullscreenitem, Qt.point(x,y))
                        facedeleg.hovered = (pos.x >= 0 && pos.x <= facedeleg.width && pos.y >= 0 && pos.y <= facedeleg.height)
                    }

                    function onMouseReleased(modifiers : int, button : int, pos : point) {
                        pos = facedeleg.mapFromItem(fullscreenitem, pos)
                        if(Math.abs(facedeleg.mousePressed.x - pos.x) < facetagger_top.threshold && Math.abs(facedeleg.mousePressed.y-pos.y) < facetagger_top.threshold) {
                            if(facedeleg.hovered) {
                                facetagger_top.deleteFaceTag(facedeleg.curdata[0])
                            }
                        }
                    }

                    function onMousePressed(modifiers : int, button : int, pos : point) {
                        facedeleg.mousePressed = facedeleg.mapFromItem(fullscreenitem, pos)
                    }

                }

            }

        }

        Rectangle {
            id: newmarker
            color: pqtPalette.base
            radius: Math.min(width/2, 2)
            border.width: 5
            border.color: pqtPalette.alternateBase
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

        Item {
            id: whoisthis
            parent: facetagger_top.parent
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: whoisthis_col.width
            height: whoisthis_col.height
            opacity: 0
            visible: opacity>0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            scale: facetagger_top.adjustedScale ? 1/ldr_top.parent.scale : (1/PQCConstants.currentImageDefaultScale)

            Rectangle {
                anchors.fill: parent
                anchors.margins: -20
                color: pqtPalette.base
                opacity: 0.9
                radius: 5
            }

            Column {

                id: whoisthis_col

                spacing: 10

                Text {
                    x: (parent.width-width)/2
                    font.weight: PQCLook.fontWeightBold
                    font.pointSize: PQCLook.fontSizeXL
                    color: pqtPalette.text
                    text: qsTranslate("facetagging", "Who is this?")
                }

                Item {

                    x: (parent.width-width)/2

                    width: whoisthis_name.width
                    height: whoisthis_name.height

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -5
                        color: pqtPalette.base
                    }

                    TextInput {
                        id: whoisthis_name
                        color: pqtPalette.text
                        selectedTextColor: pqtPalette.highlightedText
                        selectionColor: pqtPalette.highlight
                        width: 200
                        onVisibleChanged: {
                            if(visible)
                                forceActiveFocus()
                        }
                        onAccepted: {
                            whoisthis.save()
                        }
                        Keys.onEscapePressed:
                            whoisthis.hide()
                    }
                }

                Row {

                    x: (parent.width-width)/2
                    spacing: 10

                    Button {
                        id: but_save
                        text: "Save"
                        onClicked: whoisthis.save()
                    }

                    Button {
                        id: save_cancel
                        text: "Cancel"
                        onClicked: whoisthis.hide()
                    }

                }

            }

            function show() {
                opacity = 1
                whoisthis_name.text = ""
                whoisthis_name.forceActiveFocus()
            }

            function hide() {
                opacity = 0
                facetagger_top.mouseDown = false
                newmarker.visible = false
                ldr_top.forceActiveFocus()
            }

            function save() {
                facetagger_top.faceTags.push(facetagger_top.faceTags.length/6 + 1)
                facetagger_top.faceTags.push(newmarker.x/facetagger_top.width)
                facetagger_top.faceTags.push(newmarker.y/facetagger_top.height)
                facetagger_top.faceTags.push(newmarker.width/facetagger_top.width)
                facetagger_top.faceTags.push(newmarker.height/facetagger_top.height)
                facetagger_top.faceTags.push(whoisthis_name.text)
                facetagger_top.faceTagsChanged()
                PQCScriptsMetaData.setFaceTags(ldr_top.imageSource, facetagger_top.faceTags)
                facetagger_top.loadData()
                PQCNotify.currentFaceTagsReload()
                whoisthis.hide()
            }
        }

        property bool mouseDown: false
        property point mousePressed: Qt.point(-1,-1)

        Connections {

            target: PQCFileFolderModel

            function onCurrentFileChanged() {
                whoisthis.hide()
                facetagger_top.hide()
            }

        }

        Connections {

            target: PQCNotify

            enabled: PQCConstants.faceTaggingMode && !whoisthis.visible

            function onMouseMove(x : int, y : int) {
                if(!facetagger_top.mouseDown) return
                var pos = facetagger_top.mapFromItem(fullscreenitem, Qt.point(x,y))
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
                pos = facetagger_top.mapFromItem(fullscreenitem, pos)
                if(Math.abs(facetagger_top.mousePressed.x - pos.x) >= facetagger_top.threshold || Math.abs(facetagger_top.mousePressed.y-pos.y) >= facetagger_top.threshold) {
                    whoisthis.show()
                } else {
                    facetagger_top.mouseDown = false
                    newmarker.visible = false
                }
            }

            function onMousePressed(modifiers : int, button : int, pos : point) {
                facetagger_top.mouseDown = true
                facetagger_top.mousePressed = facetagger_top.mapFromItem(fullscreenitem, pos)
            }

            function onStopFaceTagging() {
                if(whoisthis.visible)
                    whoisthis.hide()
                else
                    facetagger_top.hide()
            }

        }

        // This needs to be seperate from the Connections above
        // as we need this to be always enabled
        Connections {

            target: PQCNotify

            function onLoaderPassOn(what : string, param : list<var>) {

                if(ldr_top.isMainImage) {

                    if(what === "tagFaces") {

                        if(!PQCScriptsMetaData.areFaceTagsSupported(ldr_top.imageSource)) {
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

            if(!PQCConstants.faceTaggingMode) return

            for(var i = 0; i < faceTags.length/6; ++i) {
                if(parseInt(faceTags[6*i]) === number) {
                    faceTags.splice(6*i, 6)
                    break
                }
            }
            PQCScriptsMetaData.setFaceTags(ldr_top.imageSource, faceTags)
            loadData()
            PQCNotify.currentFaceTagsReload()

        }

        property bool adjustedScale: false
        property real backupScale: 1
        function show() {

            adjustedScale = false

            if(PQCConstants.currentImageResolution.width/PQCConstants.devicePixelRatio < PQCConstants.imageDisplaySize.width &&
                    PQCConstants.currentImageResolution.height/PQCConstants.devicePixelRatio < PQCConstants.imageDisplaySize.height) {
                var fact = Math.min(PQCConstants.imageDisplaySize.width/PQCConstants.currentImageResolution.width,
                                    PQCConstants.imageDisplaySize.height/PQCConstants.currentImageResolution.height)
                backupScale = ldr_top.parent.scale
                ldr_top.parent.scale = fact
                adjustedScale = true
            }

            opacity = 1
            loadData()
        }


        function loadData() {
            repeatermodel.clear()

            faceTags = PQCScriptsMetaData.getFaceTags(ldr_top.imageSource)
            for(var i = 0; i < faceTags.length/6; ++i)
                repeatermodel.append({"index" : i})
        }

        function hide() {
            if(adjustedScale)
                ldr_top.parent.scale = backupScale
            whoisthis.hide()
            opacity = 0
            PQCConstants.faceTaggingMode = false
            PQCNotify.loaderRegisterClose("facetagger")
        }

    }

}
