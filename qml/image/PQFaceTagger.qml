import QtQuick

import PQCFileFolderModel
import PQCScriptsMetaData
import PQCNotify

import "../elements"

Item {

    id: facetagger_top

    property var faceTags: []

    anchors.fill: parent

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property int threshold: 5

    Rectangle {

        parent: fullscreenitem_foreground
        x: 20
        y: 20
        width: 42
        height: 42
        radius: 21

        visible: PQCNotify.faceTagging

        color: PQCLook.transColor

        Image {
            x: 5
            y: 5
            width: 32
            height: 32
            sourceSize: Qt.size(width, height)
            source: "/white/close.svg"
        }

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: qsTranslate("facetagging", "Click to exit face tagging mode")
            onClicked: hide()
        }

    }

    Repeater {

        id: repeat

        model: ListModel { id: repeatermodel }

        delegate: Item {

            id: facedeleg
            property var curdata: faceTags.slice(6*index, 6*(index+1))

            x: facetagger_top.width*curdata[1]
            y: facetagger_top.height*curdata[2]
            width: facetagger_top.width*curdata[3]
            height: facetagger_top.height*curdata[4]

            property bool hovered: false

            Rectangle {
                id: bg
                anchors.fill: parent
                color: PQCLook.transColor
                radius: Math.min(width/2, 2)
                border.width: 5
                border.color: PQCLook.baseColorActive
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
                color: PQCLook.transColor
                rotation: -deleg.imageRotation

                // This holds the person's name
                PQText {
                    id: faceLabel
                    x: 7
                    y: 5
                    font.pointSize: PQCLook.fontSize/image_top.currentScale
                    text: " "+facedeleg.curdata[5]+" "
                }

            }

            property point mousePressed

            Connections {
                target: PQCNotify

                enabled: !newmarker.visible && PQCNotify.faceTagging

                function onMouseMove(x,y) {
                    var pos = facedeleg.mapFromItem(fullscreenitem, Qt.point(x,y))
                    facedeleg.hovered = (pos.x >= 0 && pos.x <= facedeleg.width && pos.y >= 0 && pos.y <= facedeleg.height)
                }

                function onMouseReleased(modifiers, button, pos) {
                    pos = facedeleg.mapFromItem(fullscreenitem, pos)
                    if(Math.abs(facedeleg.mousePressed.x - pos.x) < threshold && Math.abs(facedeleg.mousePressed.y-pos.y) < threshold) {
                        if(facedeleg.hovered) {
                            deleteFaceTag(facedeleg.curdata[0])
                        }
                    }
                }

                function onMousePressed(modifiers, button, pos) {
                    facedeleg.mousePressed = facedeleg.mapFromItem(fullscreenitem, pos)
                }

            }

        }

    }

    Rectangle {
        id: newmarker
        color: PQCLook.transColor
        radius: Math.min(width/2, 2)
        border.width: 5
        border.color: PQCLook.baseColorActive
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
        parent: fullscreenitem_foreground
        anchors.fill: parent
        color: PQCLook.transColor
        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Column {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            spacing: 10

            PQTextXL {
                x: (parent.width-width)/2
                font.weight: PQCLook.fontWeightBold
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
            PQCNotify.ignoreKeysExceptEnterEsc = true
            opacity = 1
            whoisthis_name.text = ""
            whoisthis_name.setFocus()
        }

        function hide() {
            PQCNotify.ignoreKeysExceptEnterEsc = false
            opacity = 0
            mouseDown = false
            newmarker.visible = false
        }

        function save() {
            faceTags.push(faceTags.length/6 + 1)
            faceTags.push(newmarker.x/facetagger_top.width)
            faceTags.push(newmarker.y/facetagger_top.height)
            faceTags.push(newmarker.width/facetagger_top.width)
            faceTags.push(newmarker.height/facetagger_top.height)
            faceTags.push(whoisthis_name.text)
            faceTagsChanged()
            PQCScriptsMetaData.setFaceTags(PQCFileFolderModel.currentFile, faceTags)
            loadData()
            facetracker.loadData()
            whoisthis.hide()
        }
    }

    property bool mouseDown: false
    property point mousePressed

    Connections {

        target: PQCNotify

        enabled: PQCNotify.faceTagging && !whoisthis.visible

        function onMouseMove(x,y) {
            if(!mouseDown) return
            var pos = facetagger_top.mapFromItem(fullscreenitem, Qt.point(x,y))
            if(Math.abs(mousePressed.x - pos.x) >= threshold || Math.abs(mousePressed.y-pos.y) >= threshold) {
                newmarker.newX = mousePressed.x
                newmarker.newY = mousePressed.y
                newmarker.newWidth = pos.x - mousePressed.x
                newmarker.newHeight = pos.y - mousePressed.y
                newmarker.updatePos()
                newmarker.visible = true
            } else
                newmarker.visible = false
        }

        function onMouseReleased(modifiers, button, pos) {
            pos = facetagger_top.mapFromItem(fullscreenitem, pos)
            if(Math.abs(mousePressed.x - pos.x) >= threshold || Math.abs(mousePressed.y-pos.y) >= threshold) {
                whoisthis.show()
            } else {
                mouseDown = false
                newmarker.visible = false
            }
        }

        function onMousePressed(modifiers, button, pos) {
            mouseDown = true
            mousePressed = facetagger_top.mapFromItem(fullscreenitem, pos)
        }

    }

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(deleg.itemIndex === PQCFileFolderModel.currentIndex) {

                if(what === "tagFaces") {

                    image.zoomReset()
                    image.rotateReset()
                    image.mirrorReset()

                    loader.visibleItem = "facetagger"
                    PQCNotify.faceTagging = true
                    facetagger_top.show()

                } else if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape) {

                        if(whoisthis.visible)
                            whoisthis.hide()
                        else
                            hide()

                    } else if(param[0] === Qt.Key_Return || param[0] === Qt.Key_Enter)
                        whoisthis.save()

                }

            }

        }

    }

    function deleteFaceTag(number) {

        if(!PQCNotify.faceTagging) return

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

        faceTags = PQCScriptsMetaData.getFaceTags(PQCFileFolderModel.currentFile)
        for(var i = 0; i < faceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

    function hide() {
        opacity = 0
        PQCNotify.faceTagging = false
        loader.visibleItem = ""
    }

}
