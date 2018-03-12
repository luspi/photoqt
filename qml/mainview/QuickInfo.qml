/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import PContextMenu 1.0
import "../elements"
import "../handlestuff.js" as Handle

Item {

    id: item

    x: 5+metadata.nonFloatWidth
    y: 5
    Behavior on x { SmoothedAnimation { duration: variables.animationSpeed } }
    Behavior on y { SmoothedAnimation { duration: variables.animationSpeed } }

    width: childrenRect.width
    height: childrenRect.height

    visible: ((!settings.quickInfoHideCounter || !settings.quickInfoHideFilename || !settings.quickInfoHideFilepath || variables.filter!="") && !variables.slideshowRunning && variables.currentFile!="") || (variables.slideshowRunning && !settings.slideShowHideQuickInfo)
    opacity: variables.guiBlocked&&!variables.slideshowRunning ? 0.2 : 1
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    Rectangle {

        id: containerRect

        x: 0
        y: settings.thumbnailPosition != "Top" ? 0 : background.height-height-6

        // it is always as big as the item it contains
        width: childrenRect.width+6
        height: childrenRect.height+6
        clip: true
        Behavior on width { SmoothedAnimation { duration: variables.animationSpeed } }
        Behavior on height { SmoothedAnimation { duration: variables.animationSpeed } }

        // Some styling
        color: colour.quickinfo_bg
        radius: variables.global_item_radius

        // COUNTER
        Text {

            id: counter

            x:3
            y:3

            text: (variables.currentFile==""||settings.quickInfoHideCounter) ? "" : (variables.currentFilePos+1).toString() + "/" + variables.totalNumberImagesCurrentFolder.toString()

            visible: !settings.quickInfoHideCounter

            color: colour.quickinfo_text
            font.bold: true
            font.pointSize: 10

        }

        // FILENAME
        Text {

            id: filename

            y: 3
            anchors.left: counter.right
            anchors.leftMargin: visible ? (counter.visible ? 10 : 5) : 0

            // This keeps the binding while allowing to convert ".pdf?p=n" into ".pdf - Page #n"
            property string textWithBinding: (variables.currentFile==""||(settings.quickInfoHideFilepath&&settings.quickInfoHideFilename) ? "" : (settings.quickInfoHideFilepath ? variables.currentFile :(settings.quickInfoHideFilename ? variables.currentDir : variables.currentDir+"/"+variables.currentFile)))
            onTextWithBindingChanged: {
                var txt = textWithBinding
                if(txt.indexOf("__::pqt::__") != -1) {
                    var pts = txt.split("__::pqt::__")
                    var page = (pts[1].split("__")[0]*1+1)
                    var totalpage = (pts[1].split("__")[1].split(".")[0]*1)
                    txt = pts[0] + ".pdf - Page #" + (pts[1].split("__")[0]*1+1)+""
                    if(totalpage != -1)
                        txt += "/" + totalpage
                }
                text = txt
            }

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
                }
                Text {
                    color: colour.quickinfo_text
                    font.pointSize: 10
                    //: Used as in 'Filter images'
                    text: em.pty+qsTr("Filter:") + " " + variables.filter
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
                Handle.loadFile(variables.currentDir+"/"+variables.currentFile, "", true)
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

    PContextMenu {

        id: context

        Component.onCompleted: {

            //: The counter shows the position of the currently loaded image in the folder
            addItem(em.pty+qsTr("Show counter"))
            setCheckable(0, true)
            setChecked(0, !settings.quickInfoHideCounter)

            addItem(em.pty+qsTr("Show filepath"))
            setCheckable(1, true)
            setChecked(1, !settings.quickInfoHideFilepath)

            addItem(em.pty+qsTr("Show filename"))
            setCheckable(2, true)
            setChecked(2, !settings.quickInfoHideFilename)

            //: The clsoing 'x' is the button in the top right corner of the screen for closing PhotoQt
            addItem(em.pty+qsTr("Show closing 'x'"))
            setCheckable(3, true)
            setChecked(3, !settings.quickInfoHideX)

        }

        onCheckedChanged: {
            if(index == 0)
                settings.quickInfoHideCounter = !checked
            else if(index == 1)
                settings.quickInfoHideFilepath = !checked
            else if(index == 2)
                settings.quickInfoHideFilename = !checked
            else if(index == 3)
                settings.quickInfoHideX = !checked
        }

    }

}
