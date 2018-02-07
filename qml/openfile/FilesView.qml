import QtQuick 2.5
import QtQuick.Layouts 1.2

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    // minimum width, but this one always is the one to stretch to fill the rest of available space
    Layout.minimumWidth: 200
    Layout.fillWidth: true

    // some aliases to access things from outside
    property alias filesViewModel: gridview.model
    property alias filesView: gridview
    property alias filesEditRect: editRect

    // when this is set to true, an 'unsupported protocol' message is displayed
    property bool showUnsupportedProtocolFolderMessage: false

    // make sure settings values are valid
    property string settingsOpenDefaultView: (settings.openDefaultView==="icons" ? "icons" : "list")
    property int settingsOpenZoomLevel: Math.max(10, Math.min(50, settings.openZoomLevel))*1.5

    // if in focus, show a slight blue glimmer
    color: (openvariables.currentFocusOn=="filesview") ? "#44000055" : "#44000000"

    // Entering the pane (even if not hovering a file) sets the current focus to folders
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: openvariables.currentFocusOn = "filesview"
    }

    // This gridview holds all the items for each file, either in a list of in a grid
    GridView {

        id: gridview

        // position and size
        anchors.fill: parent
        anchors.bottomMargin: editRect.height+editRect.anchors.margins*2
        clip: true

        // size of individual items depend on type of view. A list is nothing but a grid with one column
        // we animate switching the view mode
        cellWidth: settingsOpenDefaultView=="icons" ? settingsOpenZoomLevel*4 : width
        cellHeight: settingsOpenDefaultView=="icons" ? settingsOpenZoomLevel*4 : settingsOpenZoomLevel
        Behavior on cellWidth { NumberAnimation { id: cellWidthAni; duration: variables.animationSpeed; } }
        Behavior on cellHeight { NumberAnimation { id: cellHeightAni; duration: variables.animationSpeed/2; } }

        // changing the width of the filesview should not be animated, it feels more natural when the width follows directly what the mouse does
        // thus we remove the animation when changing width and reset it again shortly after
        onWidthChanged: {
            cellWidthAni.duration = 0
            cellHeightAni.duration = 0
            resetAniDurations.restart()
        }
        // reset the animation durations after 250 ms
        Timer {
            id: resetAniDurations
            interval: 250
            repeat: false
            onTriggered: {
                cellWidthAni.duration = 200
                cellHeightAni.duration = 100
            }
        }

        // highlight item moves relatively fast
        highlightMoveDuration: 100

        // Some status messages if no image is found in the folder or the protocol is not supported (like network:/)
        Text {

            // tie size to parent
            anchors.fill: parent

            // displayed in center
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter

            // visibility depends on model count and property value
            visible: (opacity!=0)
            opacity: (gridview.model.count===0||showUnsupportedProtocolFolderMessage) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            // some additional styling
            color: "grey"
            font.bold: true
            font.pointSize: 20
            wrapMode: Text.WordWrap

            // the text status messages
            text: showUnsupportedProtocolFolderMessage
                      //: Protocol refers to a file protocol (e.g., for network folders)
                    ? em.pty+qsTr("This protocol is currently not supported")
                      //: Can also be expressed as 'zero subfolders' or '0 subfolders'. It is also possible to drop the 'sub' leaving 'folders' if that works better
                    : em.pty+qsTr("No image files found")


        }

        // The preview background thumbnail image
        Image {

            id: bgthumb

            // fill view
            anchors.fill: parent

            // visibility
            opacity: settings.openPreview ? 0.8 : 0
            visible: (opacity != 0)
            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            // some properties
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(width,height)
            z: -1

            // set the source, at start of course empty
            source: ""

        }

        // the model is a simple ListModel, filled by handlestuff.js
        model: ListModel { }

        // the delegate for the item
        delegate: files

        // the item for showing which entry is highlighted
        highlight: Rectangle {

            // it fill the full cell
            width: gridview.cellWidth
            height: gridview.cellHeight

            // slight white background signals highlighted entry
            color: "#88ffffff"

        }

    }

    // This is shown at the bottom, shows the filename and allows the user to enter terms to search for a file
    CustomLineEdit {

        id: editRect

        // size and position
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 5
        }

    }

    // This is the component that makes up each file entry
    Component {

        id: files

        Rectangle {

            // size and position inside component (i.e., inside cell)
            y: settingsOpenDefaultView=="icons" ? 0 : 1
            width: gridview.cellWidth
            height: gridview.cellHeight-(settingsOpenDefaultView=="icons" ? 0 : 2)

            // some faint background color
            color: "#44000000"

            // The thumbnail image
            Image {

                id: thumb

                // position and size, depends on type of view
                x: 3
                y: 3
                height: settingsOpenDefaultView=="icons" ? 2*parent.height/3 -6 : parent.height-6
                width: settingsOpenDefaultView=="icons" ? parent.width-6 : parent.height-6

                // some properties
                asynchronous: true
                fillMode: Image.PreserveAspectFit

                // the source depends on settings and visibility
                source: (filename!=undefined&&settings.openThumbnails&&openfile_top.visible)
                          ? ("image://thumb/" + openvariables.currentDirectory + "/" + filename)
                          : "image://icon/image-" + getanddostuff.getSuffix(openvariables.currentDirectory + "/" + filename)

                // the thumbnail fades in when ready
                opacity: Image.Ready&&source!="" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            }

            // This is the temporary image showing an image icon while thumbnail is loading
            Image {

                // same size/position as thumbnail image
                anchors.fill: thumb

                // it fades out once the full thumbnail image is available
                visible: opacity!=0
                opacity: thumb.status==Image.Ready&&thumb.source!="" ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

                // same fill mode as thumb image, but NOT assynchronous! If set to asynchronous, it will never load before the thumb image...
                fillMode: Image.PreserveAspectFit

                // the source is always this, as this icon image loads almost instantly there is no need to set/remove it
                source: "image://icon/image-" + getanddostuff.getSuffix(openvariables.currentDirectory + "/" + filename)

            }

            // The filename when files are shown in list
            Text {

                id: fn_list

                anchors.fill: parent
                anchors.leftMargin: thumb.width+10
                anchors.rightMargin: fs_list.width+20

                // visible when view mode is list
                visible: settingsOpenDefaultView=="list"

                // some properties
                verticalAlignment: Qt.AlignVCenter
                elide: Text.ElideRight
                color: "white"
                font.bold: true
                font.pixelSize: settingsOpenZoomLevel/2

                // the filename set as text
                text: filename

            }

            // This is the filename when files are shown as icons
            Rectangle {

                id: fn_icon

                // size and position
                x: 2
                y: 2*parent.height/3 +2
                width: parent.width-4
                height: parent.height/3 -4

                // visible when view mode is icons
                visible: settingsOpenDefaultView=="icons"

                // some properties
                color: "#88000000"
                radius: 5

                Text {

                    // fill rectangle
                    anchors.fill: parent

                    // center text
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter

                    // some properties
                    color: "white"
                    font.bold: true
                    font.pixelSize: settingsOpenZoomLevel/2
                    maximumLineCount: 1
                    elide: Text.ElideMiddle

                    // and the filename
                    text: filename

                }
            }

            // The filesize is shown only for the list
            // we wrap it into an item as this gives us better access to the required width
            Item {

                id: fs_list

                // visibility depends on view mode
                visible: settingsOpenDefaultView=="list"

                // size and position
                anchors{
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 10
                }
                width: settingsOpenDefaultView=="icons" ? 0 : fs_listtext.width

                // the actual filesize text
                Text {

                    id: fs_listtext

                    // size and position
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right

                    // center filesize text
                    verticalAlignment: Qt.AlignVCenter

                    // some properties
                    color: "white"
                    font.bold: true
                    font.pixelSize: settingsOpenZoomLevel/2

                    // the actual filesize text
                    text: filesize

                }
            }

            // The tooltip for each item is the full name and the filesize
            ToolTip {

                // clicking anywhere will load the file
                anchors.fill: parent

                // To avoid gaps between the items (in list view) that are not clickable, we extend the mousearea to y=0 and y=height
                anchors.topMargin: settingsOpenDefaultView=="icons" ? 0 : -1
                anchors.bottomMargin: settingsOpenDefaultView=="icons" ? 0 : -1

                // some properties
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                // the currentIndex follows the mouse cursor
                onEntered: gridview.currentIndex = index

                // a click loads the highlighted image
                onClicked: {
                    openvariables.currentFocusOn = "filesview"
                    loadHighlightedPicture()
                }

                // The tooltip text is a html table
                                                    //: Refers to the filename. Keep string short!
                text: "<tr><td align='right'><b>" + em.pty+qsTr("Name") + ": </b></td><td>" + filename + "</td></tr>" +
                                                    //: Refers to the filesize. Keep string short!
                      "<tr><td align='right'><b>" + em.pty+qsTr("Size") + ": </b></td><td>" + filesize + "</td></tr>"
            }

        }

    }

    // React to changes to highlighted entry
    Connections {

        target: gridview

        // a new highlighted entry means the currentIndex property changed
        onCurrentIndexChanged: {

            // ensure filesview is in focus
            if(gridview.currentIndex != -1)
                openvariables.currentFocusOn = "filesview"

            // update background/preview image
            reloadBackgroundThumbnail()

        }
    }

    // Also rect to changes in the folder (the currentIndex might not change)
    Connections {

        target: openvariables

        // update background/preview image
        onCurrentDirectoryChanged:
            reloadBackgroundThumbnail()

    }

    // React to the user editing the text in the rectangle
    Connections {

        target: editRect

        onTextEdited: {

            // This is set to true when the text was set programatically (not by user)
            if(openvariables.textEditedFromHighlighting)
                return

            // build regular expression and try to find the first file that matches that expression
            var pattern = new RegExp(editRect.getText().replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&") + ".*","i")
            var index = -1
            for(var i = 0; i < openvariables.currentDirectoryFiles.length; i+=2) {
                if(pattern.test(openvariables.currentDirectoryFiles[i])) {
                    index = i/2
                    break;
                }
            }

            // update the current index (without messing with the text in the edit rect)
            openvariables.highlightingFromUserInput = true
            if(index != -1)
                gridview.currentIndex = index
            openvariables.highlightingFromUserInput = false
        }
    }

    // React to shortcut actions
    Connections {
        target: openfile_top
        onHighlightEntry:
            highlightEntry(distance)
        onHighlightFirst:
            highlightFirst()
        onHighlightLast:
            highlightLast()
        onLoadEntry:
            loadHighlightedPicture()
    }

    // highlight an entry up or down (at given distance)
    function highlightEntry(distance) {

        // check if we have focus
        if(openvariables.currentFocusOn != "filesview") return

        verboseMessage("OpenFile/FilesView", "highlightEntry(): " + distance)

        // >0 means go down
        if(distance > 0)
            gridview.currentIndex = Math.min(gridview.currentIndex+distance, gridview.model.count-1)
        // <0 means go up
        else
            gridview.currentIndex = Math.max(gridview.currentIndex+distance, 0)

    }

    // highlight the first entry in the list
    function highlightFirst() {

        // check if we have focus
        if(openvariables.currentFocusOn != "filesview") return

        verboseMessage("OpenFile/FilesView", "highlightFirst()")

        // if there are any items, go to first one
        if(gridview.model.count > 0)
            gridview.currentIndex = 0

    }

    // highlight the lasy entry in the list
    function highlightLast() {

        // check if we have focus
        if(openvariables.currentFocusOn != "filesview") return

        verboseMessage("OpenFile/FilesView", "highlightLast()")

        // if there are any items, go to last one
        if(gridview.model.count > 0)
            gridview.currentIndex = gridview.model.count-1

    }

    // Reload the background/preview image
    function reloadBackgroundThumbnail() {

        verboseMessage("OpenFile/FilesView", "reloadBackgroundThumbnail()")

        // This holds the filename that is to be shown
        var f = ""

        // If currentIndex is invalid (e.g., -1), leave f empty
        if(gridview.model.get(gridview.currentIndex) === undefined)
            f = ""
        // otherwise try to get the filename from the model
        else {
            f = gridview.model.get(gridview.currentIndex).filename
            // If it fails, reset f to empty string
            if(f == undefined) f = ""
        }

        // If f is empty, i.e., no valid file is highlighted
        if(f == "") {
            // set background/preview image to empty
            bgthumb.source = ""
            // if the change in currentIndex hasn't happened through user input, clear the text in the editRect
            if(!openvariables.highlightingFromUserInput) {
                // This variable keeps PhotoQt from trying to find a file matching this as regular expression, not necessary
                openvariables.textEditedFromHighlighting = true
                editRect.text = ""
                openvariables.textEditedFromHighlighting = false
            }
        // if we have a filename
        } else {
            // set background/preview image (if enabled)
            bgthumb.source = settings.openPreview
                                ? "image://" + (settings.openPreviewHighQuality ? "full" : "thumb") + "/" + openvariables.currentDirectory + "/" + f
                                : ""
            // if the change in currentIndex hasn't happened through user input, update the text in the edit rect and select it all
            if(!openvariables.highlightingFromUserInput) {
                // This variable keeps PhotoQt from trying to find a file matching this as regular expression, not necessary
                openvariables.textEditedFromHighlighting = true
                editRect.text = gridview.model.get(gridview.currentIndex).filename
                editRect.selectAll()
                openvariables.textEditedFromHighlighting = false
            }
        }
    }

    // Load the entry that is currently highlighted
    function loadHighlightedPicture() {

        // check if we have focus
        if(openvariables.currentFocusOn != "filesview") return

        verboseMessage("OpenFile/FilesView", "loadHighlightedPicture()")

        // if the entry is valid
        if(gridview.model.get(gridview.currentIndex) === undefined)
            return

        // load file and hide element
        mainwindow.loadFile(openvariables.currentDirectory + "/" + gridview.model.get(gridview.currentIndex).filename)
        openfile_top.hide()

    }

}
