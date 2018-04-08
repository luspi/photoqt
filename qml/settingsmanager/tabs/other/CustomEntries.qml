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

import "../../../elements"
import "../../"
import "./"

Entry {

    title: em.pty+qsTr("Custom Entries in Main Menu")
    helptext: em.pty+qsTr("Here you can adjust the custom entries in the main menu. You can simply drag and drop the entries, edit them, add a new one and remove an existing one.")

    content: [

        Item {

            // the all-encompassing container
            width: entries.width
            height: entries.height+buts.height

            Rectangle {

                id: entries

                // the dimension of the container for the entries
                width: Math.min(800, parent.parent.parent.width)
                height: 250

                // some styling
                color: colour.tiles_inactive
                radius: 5

                // The header rectangle, outside of ListView
                Rectangle {

                    id: headContext

                    // positioning
                    x: 5
                    y: 5
                    width: parent.width-10
                    height: 30

                    // some styling
                    color: colour.tiles_active
                    radius: variables.global_item_radius

                    // the heading for the executable (binary)
                    Text {

                        x: listview.executableEditX
                        y: (parent.height-height)/2
                        width: listview.executableEditWidth

                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter

                        font.bold: true
                        font.pointSize: 10
                        color: colour.tiles_text_active

                        text: em.pty+qsTr("Executable")

                    }

                    // the heading for the description
                    Text {

                        x: listview.descriptionEditX
                        y: (parent.height-height)/2
                        width: listview.descriptionEditWidth

                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter

                        font.bold: true
                        font.pointSize: 10
                        color: colour.tiles_text_active

                        text: em.pty+qsTr("Menu Text")

                    }

                }


                ScrollBarVertical {
                    id: listview_scrollbar
                    flickable: listview
                    showOutside: true
                    // don't hide, always keep visible
                    opacityVisible: 0.8
                    opacityHidden: 0.5
                    z: listview.z+1
                }

                // The view for all the entries
                ListView {

                    id: listview

                    // anchor in place
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: headContext.bottom
                        bottom: parent.bottom
                        margins: 5
                    }

                    // The currentz property makes sure a dragged item is always displayed above others.
                    // Each time a drag is started, this value plus one is used as z value of item, with this currentz value incremented by one afterwards
                    property int currentz: 100

                    // this hold the index of the item that is being dragged
                    property int dragItemIndex: -1

                    // this is the item that is currently hovered over
                    property int hoveringOver: -1

                    clip: true

                    // used for positioning the header labels properly
                    property int executableEditX: 0
                    property int executableEditWidth: 0
                    property int descriptionEditX: 0
                    property int descriptionEditWidth: 0

                    // The drop area for reordering items
                    DropArea {

                        id: dropArea

                        // fills the entire listview
                        anchors.fill: parent

                        // when item was dropped on it
                        onDropped: {

                            // find the index on which it was dropped
                            var newindex = listview.indexAt(drag.x, drag.y+listview.contentY)

                            // if item was dropped below any item, set new index to very end
                            if(newindex < 0) newindex = listview.model.count-1

                            // if item was moved (if left in place nothing needs to be done)
                            if(listview.dragItemIndex !== newindex)
                                // move item to location
                                listview.model.move(listview.dragItemIndex, newindex, 1)

                            // reset variables used for drag/drop
                            listview.dragItemIndex = -1
                            listview.hoveringOver = -1

                        }

                        // if mouse is moved during a drag
                        onPositionChanged: {

                            // get new index
                            var newindex = listview.indexAt(drag.x, drag.y+listview.contentY)
                            // if drag is below any item, set newindex to end
                            if(newindex === -1)
                                newindex = listview.model.count

                            // store where the drag is located right now (updates marker in model)
                            listview.hoveringOver = newindex

                        }

                        // if drag leaves drop area, we stop following it
                        onExited: listview.hoveringOver = -1

                    }

                    // a simple listmodel
                    model: ListModel { }

                    // the actual individual items
                    delegate: Item {

                        id: deleg

                        // full width, fixed height
                        width: listview.width
                        height: 35

                        // When deleting an item, it's x property is set to -listview.width ...
                        Behavior on x { NumberAnimation { duration: variables.animationSpeed } }
                        // ... Once x reaches that value the item is deleted
                        onXChanged: {
                            if(x <= -listview.width)
                                listview.model.remove(index)
                        }

                        // When a different item is dragged, this one is shown semi transparent
                        opacity: listview.dragItemIndex!=index&&listview.dragItemIndex!=-1 ? 0.5 : 1
                        Behavior on opacity{ NumberAnimation { duration: variables.animationSpeed } }

                        // a marker above item used for drag/drop
                        Rectangle {

                            x: 0
                            y: 0
                            width: listview.width
                            height: 1

                            // Always shown on top of item
                            z: dragitem.z+1

                            // white color
                            color: "white"

                            // some discreet animation on opacity changes
                            opacity: listview.hoveringOver==index ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
                            visible: opacity!=0
                        }

                        // The item containing all the elements for editing the entry
                        Rectangle {

                            id: dragitem

                            // there are 2.5 pixels above and below to provide some spacing
                            y: 2.5
                            height: 30

                            // some styling
                            color: colour.element_bg_color
                            width: listview.width
                            radius: 5

                            // anchors them in place (if not in drag) to make them snap back after drag has ended
                            anchors {
                                horizontalCenter: mousearea.drag.active ? undefined : parent.horizontalCenter;
                                verticalCenter: mousearea.drag.active ? undefined : parent.verticalCenter
                            }

                            // the horizontal spacing between the different elements of one entry
                            property int spacing: 5

                            // the drag is tied to the mouse area
                            Drag.active: mousearea.drag.active

                            // this is the hotspot that has to be dragged somewhere for a drag/drop to occur
                            Drag.hotSpot.x: dragger.width/2
                            Drag.hotSpot.y: 5

                            // A label for dragging the rectangle
                            Text {

                                id: dragger

                                // same height as item
                                height: dragitem.height

                                // anchors in place
                                anchors.left: parent.left
                                anchors.leftMargin: dragitem.spacing

                                // text is shown vertically centered
                                verticalAlignment: Qt.AlignVCenter

                                // some styling
                                font.pointSize: 10
                                color: colour.text

                                text: em.pty+qsTr("Click here to drag entry")

                                // This mousearea facilitates the drag/drop
                                MouseArea {

                                    id: mousearea

                                    // full text element available for drag
                                    anchors.fill: parent

                                    // the cursorshape depends on click and drag
                                    cursorShape: drag.active||press ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                                    // drag the text element
                                    drag.target: dragitem

                                    // store whether element is pressed on or not
                                    property bool press: false
                                    onPressed: press = true
                                    onReleased: press = false

                                    // when drag is activated
                                    drag.onActiveChanged: {

                                        // when drag is started
                                        if(mousearea.drag.active) {

                                            // show element above others
                                            deleg.z = listview.currentz+1
                                            ++listview.currentz

                                            // store which item is being dragged
                                            listview.dragItemIndex = index

                                        }

                                        dragitem.Drag.drop();

                                    }

                                }

                            }

                            // Seperate from rest by thin white line
                            Rectangle {

                                id: seperator1

                                y: 2
                                width: 1
                                height: parent.height-4

                                anchors.left: dragger.right
                                anchors.leftMargin: dragitem.spacing

                                color: colour.text

                            }

                            // Another sub-element for editing the executable
                            CustomLineEdit {

                                id: executable

                                y: 3
                                width: (listview.width-(dragger.width+seperator1.width+quit.width+seperator2.width+del.width+8*dragitem.spacing))/2
                                height: parent.height-6

                                anchors.left: seperator1.right
                                anchors.leftMargin: dragitem.spacing

                                text: exe
                                onTextEdited: listview.model.set(index, {"exe": getText()})

                                // We use this in order to position the header labels in the upper class (file: TabOther.qml)
                                onXChanged: listview.executableEditX = x
                                onWidthChanged: listview.executableEditWidth = width

                                // We catch this one directly from the LineEdit. If we use the shortcuts engine, then the tab gets processed by the LineEdit (i.e., the LineEdit loses focus) BEFORE we rceive it from the shortcuts engine
                                onTabPressed: description.selectAll()

                            }

                            // Another sub-element for editing the menu text
                            CustomLineEdit {

                                id: description

                                y: 3
                                width: (listview.width-(dragger.width+seperator1.width+quit.width+seperator2.width+del.width+8*dragitem.spacing))/2
                                height: parent.height-6

                                anchors.left: executable.right
                                anchors.leftMargin: dragitem.spacing

                                text: desc
                                onTextEdited: listview.model.set(index, {"desc": getText()})

                                // As the width of both textedits is the same, we don't need to check for it here
                                onXChanged: listview.descriptionEditX = x
                                onWidthChanged: listview.descriptionEditWidth = width

                            }

                            // Quit after executing shortcut?
                            CustomCheckBox {

                                id: quit

                                y: (parent.height-height)/2

                                anchors.left: description.right
                                anchors.leftMargin: dragitem.spacing

                                //: KEEP THIS STRING SHORT! It is displayed for external applications of main menu as an option to quit PhotoQt after executing it
                                text: em.pty+qsTr("quit")

                                checkedButton: (close=="1")
                                onCheckedButtonChanged: listview.model.set(index, {"close": (checkedButton?"1":"0")})

                            }

                            // Another small seperator
                            Rectangle {

                                id: seperator2

                                y: 2
                                width: 1
                                height: parent.height-4

                                anchors.left: quit.right
                                anchors.leftMargin: dragitem.spacing

                                color: colour.text

                            }

                            // And a label for deleting the current item
                            Text {

                                id: del

                                y: (parent.height-height)/2

                                anchors.left: seperator2.right
                                anchors.leftMargin: dragitem.spacing

                                color: colour.text
                                font.pointSize: 10

                                text: "x"

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: deleg.x = -listview.width
                                }

                            }

                        }

                        // a marker below item used for drag/drop
                        Rectangle {

                            x: 0
                            y: 35
                            width: listview.width
                            height: 1

                            // Always shown on top of item
                            z: dragitem.z+1

                            // white color
                            color: "white"

                            // some discreet animation on opacity changes
                            opacity: (listview.hoveringOver==index&&index>-1)||(listview.hoveringOver==index+1&&index==listview.model.count-1)
                            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
                            visible: opacity!=0

                        }

                    }

                }

            }

            // The two button below box
            Item {

                id: buts

                // dimensions
                width: entries.width-30
                height: childrenRect.height+5

                // anchor in place
                anchors.top: entries.bottom
                anchors.topMargin: 5

                // button to add a new entry
                CustomButton {

                    id: contextadd

                    x: 10
                    width: entries.width/2-15

                    text: em.pty+qsTr("Add new entry")

                    onClickedButton:
                        addItem("","","")

                }

                // reset default entries to list
                CustomButton {

                    id: contextreset

                    width: entries.width/2-15

                    anchors.left: contextadd.right
                    anchors.leftMargin: 10

                    text: em.pty+qsTr("Set default entries")

                    onClickedButton:
                        setDefaultData()

                }

            }

        }

    ]

    function setData() {
        listview.model.clear()
        var con = getanddostuff.getContextMenu()
        for(var i = 0; i < con.length; i+=3)
            addItem(con[i], con[i+1], con[i+2])
    }

    function setDefaultData() {
        listview.model.clear()
        var con = getanddostuff.getDefaultContextMenuEntries()
        for(var i = 0; i < con.length; i+=3)
            addItem(con[i], con[i+1], con[i+2])
    }

    function addItem(exe, close, desc) {
        listview.model.append({"exe" : exe, "close" : close, "desc" : desc})
    }

    function saveData() {
        var ret = []
        for(var i = 0; i < listview.model.count; ++i) {
            var item = listview.model.get(i)
            ret[i] = {"index" : i,
                      "executable" : item["exe"],
                      "description" : item["desc"],
                      "quit" : item["close"]}
        }
        getanddostuff.saveContextMenu(ret)
    }

}
