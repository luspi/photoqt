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
import "../../../elements"

Rectangle {

    id: popuptop

    parent: settings_top
    anchors.fill: parent

    color: "#87000000"

    // This is used to change all endings in the current category that have the same description (i.e., belong to the same image type)
    signal changeAllWithDescription(var desc, var chkd)

    // Select all/no items of the current category
    signal selectAllItems()
    signal selectNoItems()

    // Reset the state of all items to reflect the settings
    signal resetCheckedItems()
    signal resetDefaultItems()

    property string title: ""
    property var availableFormats: []
    property var enabledFormats: []
    property var defaultFormats: []

    property int numItemsChecked: 0

    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }


    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: hide()
    }

    Rectangle {

        id: inside

        anchors.fill: parent
        anchors.margins: 200

        color: "#bb000000"
        border.width: 1
        border.color: "#88bbbbbb"
        radius: 5

        Text {
            id: titletext
            anchors {
                top: inside.top
                left: inside.left
                right: inside.right
                margins: 10
                bottomMargin: 25
            }
            text: popuptop.title
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            font.pointSize: 30
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Item {

            id: buttons

            x: (parent.width-width)/2
            width: buttonsrow.width
            height: buttonsrow.height+10
            anchors.top: titletext.bottom
            anchors.topMargin: 25

            Row {
                id: buttonsrow
                spacing: 10
                CustomButton {
                    text: em.pty+qsTr("Enable default")
                    onClickedButton: resetDefaultItems()
                }
                CustomButton {
                    text: em.pty+qsTr("Enable all")
                    onClickedButton: selectAllItems()
                }
                CustomButton {
                    text: em.pty+qsTr("Disable all")
                    onClickedButton: selectNoItems()
                }
                CustomButton {
                    text: em.pty+qsTr("Reset selection")
                    onClickedButton: resetCheckedItems()
                }
            }


        }

        GridView {

            id: grid

            property int spacing: 3

            anchors {
                top: buttons.bottom
                left: inside.left
                right: inside.right
                bottom: donebutton.top
                margins: 10
            }

            cellWidth: 125
            cellHeight: 30+spacing*2

            clip: true

            property var available: popuptop.availableFormats

            // which items are checked
            property var checkeditems: []

            model: available.length

            delegate: ImageFormatsTile {

                id: tile

                // Set the data of the current file ending
                displaytext: grid.available[index][0]
                description: grid.available[index][1]
                category: grid.available[index][2]

                // some spacing around each entry
                x: grid.spacing
                y: grid.spacing
                width: grid.cellWidth-grid.spacing*2
                height: grid.cellHeight-grid.spacing*2

                // If the checked state of the item has changed
                onCheckedChanged: {

                    // Item is now checked
                    if(checked && grid.checkeditems.indexOf(displaytext)==-1)
                        // Add to the list of checked items (if not already in it)
                        grid.checkeditems.push(displaytext)

                    // Item is not checked anymore
                    else if(!checked && grid.checkeditems.indexOf(displaytext)!=-1) {
                        // Remove from list of checked items (if contained in it)
                        var pos = grid.checkeditems.indexOf(displaytext)
                        grid.checkeditems.splice(pos, 1)
                    }
                    popuptop.numItemsChecked = grid.checkeditems.length
                }

                // If the image formats changed, reset the checked state
                Connections {
                    target: popuptop
                    onEnabledFormatsChanged:
                        tile.checked = (popuptop.enabledFormats.indexOf(displaytext)!=-1)
                }

                // After setup, load settings
                Component.onCompleted:
                    tile.checked = (popuptop.enabledFormats.indexOf(displaytext)!=-1)

                Connections {
                    target: popuptop

                    // Select all items in this category
                    onSelectAllItems:
                        tile.checked = true

                    // Select no items in this category
                    onSelectNoItems:
                        tile.checked = false

                    onResetCheckedItems:
                        tile.checked = (popuptop.enabledFormats.indexOf(tile.displaytext)!=-1)

                    onResetDefaultItems:
                        tile.checked = (popuptop.defaultFormats.indexOf(tile.displaytext)!=-1)

                }

            }

        }

        CustomButton {
            id: donebutton
            text: em.pty+qsTr("Done!")
            anchors {
                left: inside.left
                right: inside.right
                bottom: inside.bottom
                margins: 10
            }
            fontsize: 20
            fontBold: true
            onClickedButton: hide()
        }

    }

    function setDefault() {
        resetDefaultItems()
    }
    function setCurrentlySet() {
        resetCheckedItems()
    }

    function setNone() {
        selectNoItems()
    }
    function getEnabledFormats() {
        return grid.checkeditems
    }

    function show() {
        opacity = 1
    }
    function hide() {
        opacity = 0
    }

}
