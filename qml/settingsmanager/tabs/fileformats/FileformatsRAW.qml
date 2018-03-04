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
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    // This is used to change all endings in the current category that have the same description (i.e., belong to the same image type)
    signal changeAllWithDescription(var desc, var chkd)

    // Select all/no items of the current category
    signal selectAllItems()
    signal selectNoItems()

    // Reset the state of all items to reflect the settings
    signal resetCheckedItems()

    Row {

        spacing: 20

        EntryTitle {

            id: title
            title: em.pty+qsTr("File Formats") + ":<br>&gt; RAW"
            helptext: entry.enabled
                        ? em.pty+qsTr("PhotoQt can open and display most raw image formats. It uses libraw for this task. Here you can adjust the list of fileformats known to PhotoQt.")+"<br><br>" + em.pty+qsTr("Use left click to check/uncheck an individual entry, and right click to check/uncheck all endings related to the same image type.")
                        : "<div color='red'>" + em.pty+qsTr("PhotoQt was built without libRAW support!") + "</div>"

        }

        EntrySetting {

            id: entry

            // which items are checked
            property var checkeditems: []

            Item {

                width: item_top.width-title.x-title.width
                height: grid.height+selectrect.height+grid.spacing*2+20

                GridView {

                    id: grid

                    width: item_top.width-title.x-title.width
                    height: childrenRect.height

                    cellWidth: 200
                    cellHeight: 30+spacing*2

                    property int spacing: 3

                    interactive: false

                    property var available: imageformats.getAvailableEndingsWithDescriptionRAW()

                    model: available.length

                    delegate: FileformatsTile {

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
                            if(checked && entry.checkeditems.indexOf(displaytext)==-1)
                                // Add to the list of checked items (if not already in it)
                                entry.checkeditems.push(displaytext)

                            // Item is not checked anymore
                            else if(!checked && entry.checkeditems.indexOf(displaytext)!=-1) {
                                // Remove from list of checked items (if contained in it)
                                var pos = entry.checkeditems.indexOf(displaytext)
                                entry.checkeditems.splice(pos, 1)
                            }
                        }

                        // If the image formats changed, reset the checked state
                        Connections {
                            target: imageformats
                            onEnabledFileformatsRAWChanged:
                                tile.checked = (imageformats.enabledFileformatsRAW.indexOf(grid.available[index][0])!=-1)
                        }

                        // Reset the states of items to reflect the settings
                        Connections {
                            target: item_top
                            onResetCheckedItems:
                                tile.checked = (imageformats.enabledFileformatsRAW.indexOf(grid.available[index][0])!=-1)
                        }

                        // After setup, load settings
                        Component.onCompleted:
                            tile.checked = (imageformats.enabledFileformatsRAW.indexOf(grid.available[index][0])!=-1)

                        Connections {
                            target: item_top

                            // Select all items in this category
                            onSelectAllItems:
                                tile.checked = true

                            // Select no items in this category
                            onSelectNoItems:
                                tile.checked = false

                        }

                    }

                }

                // This holds two buttons below the list of items
                Rectangle {

                    id: selectrect

                    // shown below the items
                    anchors.top: grid.bottom

                    CustomButton {

                        id: selectall

                        // size reflects the size of the entries
                        anchors.left: parent.left
                        anchors.topMargin: grid.spacing
                        width: grid.cellWidth-grid.spacing*2

                        text: qsTr("Select all")
                        onClickedButton: selectAllItems()

                    }

                    CustomButton {

                        id: selectnone

                        // size reflects the size of the entries
                        anchors.left: selectall.right
                        anchors.leftMargin: 2*grid.spacing
                        anchors.topMargin: grid.spacing
                        width: grid.cellWidth-grid.spacing*2

                        text: qsTr("Select none")
                        onClickedButton: selectNoItems()

                    }

                    CustomButton {

                        id: selectdefault

                        // size reflects the size of the entries
                        anchors.left: selectnone.right
                        anchors.leftMargin: 2*grid.spacing
                        anchors.topMargin: grid.spacing
                        width: grid.cellWidth-grid.spacing*2

                        text: qsTr("Set default")
                        onClickedButton: imageformats.setDefaultFormatsRAW()

                    }

                }

            }

        }

    }

    // On show, reset data to settings
    function setData() {
        resetCheckedItems()
    }

    // Save data is as simple as writing them to the imageformats settings property
    function saveData() {
        imageformats.enabledFileformatsRAW = entry.checkeditems
    }

}
