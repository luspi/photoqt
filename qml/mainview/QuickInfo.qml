import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "../elements"
import "../loadfile.js" as Load

Item {

    id: item

    x: 5+metadata.nonFloatWidth
    y: 5

    width: childrenRect.width
    height: childrenRect.height

    visible: variables.currentFile!=""&&!variables.slideshowRunning
    opacity: variables.guiBlocked ? 0.2 : 1
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Rectangle {

        id: containerRect

        x: 0
        y: settings.thumbnailposition == "Bottom" ? 0 : background.height-height-6

        // it is always as big as the item it contains
        width: childrenRect.width+6
        height: childrenRect.height+6
        clip: true
        Behavior on width { SmoothedAnimation { duration: 100 } }
        Behavior on height { SmoothedAnimation { duration: 100 } }

        // Some styling
        color: colour.quickinfo_bg
        radius: variables.global_item_radius

        // COUNTER
        Text {

            id: counter

            x:3
            y:3

            text: settings.hidecounter ? "" : (variables.currentFilePos+1).toString() + "/" + variables.totalNumberImagesCurrentFolder.toString()

            visible: !settings.hidecounter

            color: colour.quickinfo_text
            font.bold: true
            font.pointSize: 10

        }

        // FILENAME
        Text {

            id: filename

            y: 3
            anchors.left: counter.right
            anchors.leftMargin: counter.visible ? 10 :5

            text: (settings.hidefilepathshowfilename&&settings.hidefilename ? "" : (settings.hidefilepathshowfilename ? variables.currentFile :(settings.hidefilename ? variables.currentDir : variables.currentDir+"/"+variables.currentFile)))
            color: colour.quickinfo_text
            font.bold: true
            font.pointSize: 10
            visible: text!=""

        }

        // Filter label
        Rectangle {
            id: filterLabel
            visible: (variables.filter != "")
            x: ((!filename.visible && !counter.visible) ? 5 : filename.x-filter_delete.width-filterrow.spacing)
            y: ((!filename.visible && !counter.visible) ? (filename.height-height/2)/2 : filename.y+filename.height+2)
            width: childrenRect.width
            height: childrenRect.height
            color: "#00000000"
            Row {
                id: filterrow
                spacing: 5
                // A label for deletion. The one main MouseArea below trackes whether it is hovered or not
                Text {
                    id: filter_delete
                    color: colour.quickinfo_text
                    visible: (variables.filter != "")
                    text: "x"
                    font.pointSize: 10
                    y: (parent.height-height)/2
                }
                Text {
                    color: colour.quickinfo_text
                    font.pointSize: 10
                    //: As in: FILTER images
                    text: qsTr("Filter:") + " " + variables.filter
                    visible: (variables.filter != "")
                }
            }
        }


    }

    // One big MouseArea for everything
    MouseArea {

        id: contextmouse

        anchors.fill: parent

        // The label is draggable, though its position is not stored between sessions (i.e., at startup it is always reset to default)
        drag.target: parent

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        // The cursor shape depends on whether we hover the 'x' for deleting the filter or not
        cursorShape: overDeleteFilterLabel?Qt.PointingHandCursor:Qt.ArrowCursor
        property bool overDeleteFilterLabel: false
        onClicked: {
            // A right click shows context menu
            if(mouse.button == Qt.RightButton)
                context.popup()
            // A left click on 'x' deletes filter (only if set)
            if(overDeleteFilterLabel && Qt.LeftButton) {
                variables.filter = ""
                Load.loadFile(variables.currentDir+"/"+variables.currentFile, "", true)
            }

        }
        onPositionChanged: {
            // No filter visible => nothing to do
            if(!filterLabel.visible)  {
                overDeleteFilterLabel = false
                return
            }
            // Check if within text label of 'x'
            var filterXY = mapFromItem(filter_delete, filter_delete.x, filter_delete.y)
            if(mouse.x > filterXY.x && mouse.x < filterXY.x+filter_delete.width
                    && mouse.y > filterXY.y && mouse.y < filterXY.y+filter_delete.height)
                overDeleteFilterLabel = true
            else
                overDeleteFilterLabel = false
        }
    }

    ContextMenu {

        id: context

        MenuItem {
            //: This shows part of the quickinfo labels in the top left corner
            text: qsTr("Show counter")
            checkable: true
            checked: !settings.hidecounter
            onTriggered:
                settings.hidecounter = !checked
        }

        MenuItem {
            //: This shows part of the quickinfo labels in the top left corner
            text: qsTr("Show filepath")
            checkable: true
            checked: !settings.hidefilepathshowfilename
            onTriggered:
                settings.hidefilepathshowfilename = !checked
        }

        MenuItem {
            //: This shows part of the quickinfo labels in the top left corner
            text: qsTr("Show filename")
            checkable: true
            checked: !settings.hidefilename
            onTriggered:
                settings.hidefilename = !checked
        }

        MenuItem {
            //: This shows part of the quickinfo labels in the top right corner
            text: qsTr("Show closing 'x'")
            checkable: true
            checked: !settings.hidex
            onTriggered:
                settings.hidex = !checked
        }

    }

}
