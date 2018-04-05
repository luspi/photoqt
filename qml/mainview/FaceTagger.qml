import QtQuick 2.5
import "../elements"
Item {

    id: top

    anchors.fill: parent

    // The top left corner of rectangle
    property int pressedStartX
    property int pressedStartY

    // This is a short instruction message displayed along top left of window edge
    Rectangle {
        parent: mainwindow
        visible: (opacity!=0)
        opacity: top.visible?1:0
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
        anchors {
            top: parent.top
            left: parent.left
            margins: 5
        }
        width: childrenRect.width
        height: childrenRect.height
        color: "#88000000"
        radius: 5
        Text {
            text: " "+em.pty+qsTranslate("PeopleFaceTags", "Click and drag to tag a face. Press Escape to return to normal PhotoQt use")+" "
            color: "white"
            font.bold: true
            font.pointSize: 10
        }
    }

    // Triggered by shortcut
    visible: false

    // React to click&drag (draw rectangle)
    Connections {
        target: variables
        onMousePressedChanged: {

            // Is currently visible?
            if(entername.visible || !variables.taggingFaces || !top.visible) return

            // Click or release of mouse
            if(variables.mousePressed) {

                var localPos = top.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)

                pressedStartX = localPos.x
                pressedStartY = localPos.y

                drawrect.x = localPos.x
                drawrect.y = localPos.y
                drawrect.width = 0
                drawrect.height = 0

                drawrect.visible = true

            } else if(drawrect.visible) {

                // If the whole drawn rectangle is outside the image: Ignore tag
                if(drawrect.x > imageContainer.width || drawrect.x+drawrect.width < 0 || drawrect.y > imageContainer.height || drawrect.y+drawrect.height < 0) {
                    cancelNameEnter()
                    return
                }

                // Make sure drawn rectangle is fully inside the image

                if(drawrect.x < 0) {
                    drawrect.width += drawrect.x
                    drawrect.x = 0
                }
                if(drawrect.y < 0) {
                    drawrect.height += drawrect.y
                    drawrect.y = 0
                }
                if(drawrect.x+drawrect.width > imageContainer.width) drawrect.width = imageContainer.width-drawrect.x
                if(drawrect.y+drawrect.height > imageContainer.height) drawrect.height = imageContainer.height-drawrect.y

                // If rectangle is not too small
                if(drawrect.width >= 10 && drawrect.height >= 10) {

                    entername.visible = true
                    enternamelineedit.clear()
                    enternamelineedit.selectAll()

                } else
                    cancelNameEnter()

            }
        }
        onMouseCurrentPosChanged: {
            if(entername.visible || !variables.taggingFaces || !top.visible) return
            if(variables.mousePressed) {
                var localPos = top.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                drawrect.width = localPos.x-pressedStartX
                drawrect.height = localPos.y-pressedStartY
            }
        }
    }

    // The rectangle the is being drawn by click&drag
    Rectangle {
        id: drawrect
        color: "#aa000000"
        border.width: 2
        border.color: "black"
    }

    // Line Edit to enter the name of the tag
    Rectangle {
        id: entername
        parent: mainwindow
        anchors.fill: parent
        color: "#88000000"
        visible: false

        // Title text
        Text {
            anchors.bottom: enternamelineedit.top
            anchors.bottomMargin: 10
            x: (parent.width-width)/2
            color: "white"
            font.pointSize: 20
            font.bold: true
            text: em.pty+qsTranslate("PeopleFaceTags", "Who is this? Enter a name...")
        }

        // box to enter name
        CustomLineEdit {
            id: enternamelineedit
            enabled: visible
            width: 500
            height: 100
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            fontsize: 20
        }

        // button to confirm or cancel
        Item {
            anchors.top: enternamelineedit.bottom
            anchors.topMargin: 10
            width: butrow.width
            height: butrow.height
            x: (parent.width-width)/2
            Row {
                id: butrow
                spacing: 10
                CustomButton {
                    text: em.pty+qsTranslate("PeopleFaceTags", "Save")
                    fontsize: 30
                    onClickedButton: addFaceTag()
                }
                CustomButton {
                    text: em.pty+qsTranslate("PeopleFaceTags", "Cancel")
                    fontsize: 30
                    onClickedButton: cancelNameEnter()
                }
            }
        }
    }

    // React to some shortcuts
    Connections {
        target: call
        onShortcut: {
            if(!top.visible) return
            if(sh == "Escape") {
                if(entername.visible)
                    cancelNameEnter()
                else
                    stopTagging()
            } else if(sh == "Enter" || sh == "Return")
                addFaceTag()
        }
        // This is emitted by shortcut and triggers tagging mode
        onTagFaces: {
            if(!managepeopletags.canWriteXmpTags(variables.currentDir+"/"+variables.currentFileWithoutExtras))
                return;
            if(variables.taggingFaces)
                top.stopTagging()
            else
                top.startTagging()
        }
    }

    // Add a new face tag
    function addFaceTag() {

        // If it is not the currently used instance, abort now
        if(!imageContainer.visible) return

        // If some name was entered...
        if(enternamelineedit.getText() != "") {

            // Add new face tag to list
            variables.peopleFaceTags.push(variables.peopleFaceTags.length/6 +1)
            variables.peopleFaceTags.push(Math.round(1e6*(drawrect.x/imageContainer.width))/1e6)
            variables.peopleFaceTags.push(Math.round(1e6*(drawrect.y/imageContainer.height))/1e6)
            variables.peopleFaceTags.push(Math.round(1e6*(drawrect.width/imageContainer.width))/1e6)
            variables.peopleFaceTags.push(Math.round(1e6*(drawrect.height/imageContainer.height))/1e6)
            variables.peopleFaceTags.push(enternamelineedit.getText())

            // Save new data
            managepeopletags.setFaceTags(variables.currentDir+"/"+variables.currentFileWithoutExtras, variables.peopleFaceTags)

            // Update model that displays the tags
            facetracker.resetModel()

        }

        // reset tagging tools
        entername.visible = false
        drawrect.width = 0
        drawrect.height = 0
        drawrect.visible = false

    }

    // No name entered, entering cancelled
    function cancelNameEnter() {

        // If it is not the currently used instance, abort now
        if(!imageContainer.visible) return

        // reset tagging tools
        entername.visible = false
        drawrect.width = 0
        drawrect.height = 0
        drawrect.visible = false

    }

    function startTagging() {

        // If it is not the currently used instance, abort now
        if(!imageContainer.visible) return

        // Disable watching of image. Adding/Removing face tags would otherwise trigger a reload (and reset) of the image.
        watcher.setCurrentImageForWatching("")

        // update variables signalling tag mode
        variables.taggingFaces = true
        variables.guiBlocked = true
        variables.imageItemBlocked = true

        // show tagger
        top.visible = true

    }

    function stopTagging() {

        // If it is not the currently used instance, abort now
        if(!imageContainer.visible) return

        // Re-enable the currently watched image
        watcher.setCurrentImageForWatching(variables.currentDir+"/"+variables.currentFileWithoutExtras)

        // update variables signalling end of tag mode
        variables.taggingFaces = false
        variables.guiBlocked = false
        variables.imageItemBlocked = false

        // hide tagger
        top.visible = false

    }

}
