/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9
import "../../elements"

// This listview holds the currently connected storage devices (harddrives, usb, ...)
ListView {

    id: storageinfo

    boundsBehavior: Flickable.StopAtBounds

    visible: PQSettings.openfileUserPlacesVolumes

    height: childrenRect.height

    property int hoverIndex: -1

    // The model is a simple listmodel, not editable by user
    model: ListModel { id: storage_model }

    // This is the component that makes up each file entry of the storageinfo category
    delegate: Item {

        // full width, fixed height of 30
        width: parent.width
        height: 30

        // A rectangle for each of the items
        Rectangle {

            id: deleg_container

            // full width and height
            width: parent.width
            height: 30

            color: hoverIndex==index ? "#555555" : (location!=""&&(filefoldermodel.folderFileDialog == location||filefoldermodel.folderFileDialog == location+"/") ? "#88555555" : "#00555555")
            Behavior on color { ColorAnimation { duration: 200 } }

            // This item holds the icon for the folders
            Item {

                id: entryicon

                // its size is square (height==width)
                width: parent.height
                height: width

                opacity: hoverIndex==index ? 1 : 0.8

                // the icon image
                Image {

                    // fill parent (with margin for better looks)
                    anchors.fill: parent
                    anchors.margins: 5

                    // not shown for first entry (first entry is category title)
                    visible: index>0

                    // the location icon taken from image loader (i.e., from system theme if available)
                    source: ((icon!==undefined&&icon!="") ? ("image://icon/" + icon) : "")

                }

            }

            // The text of each entry
            Text {

                id: entrytextStorage

                // size and position
                anchors.fill: parent
                anchors.leftMargin: entryicon.width
                anchors.rightMargin: entrytextStorageSize.width+10

                // vertically center text
                verticalAlignment: Qt.AlignVCenter

                // some styling
                color: index==0 ? "grey" : "white"
                font.bold: true
                font.pixelSize: 15
                elide: Text.ElideLeft

                //: This is the category title of storage devices to open (like USB keys) in the element for opening files
                text: index==0 ? em.pty+qsTranslate("filedialog", "Storage devices") : (name!=undefined ? name : "")

            }

            Text {

                id: entrytextStorageSize

                height: parent.height
                anchors.right: parent.right
                anchors.rightMargin: 10

                verticalAlignment: Text.AlignVCenter

                // some styling
                color: "white"
                font.bold: true
                font.pixelSize: 15
                elide: Text.ElideRight

                text: index==0 ? "" : size + " GB"

            }

            // mouse area handles changes to currentIndex and clicked events
            PQMouseArea {

                // a click everywhere works
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton|Qt.RightButton

                tooltip: index == 0 ? em.pty+qsTranslate("filedialog", "Detected storage devices on your system") : (location + "<br><i>" + entrytextStorageSize.text + " (" + filesystemtype + ")</i>")

                // some properties
                hoverEnabled: true
                cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                // entering the area sets entry as current item
                onEntered:
                    hoverIndex = (index>0 ? index : -1)
                onExited:
                    hoverIndex = -1

                // clicking an entry loads the location
                onClicked: {
                    if(mouse.button == Qt.LeftButton)
                        filedialog_top.setCurrentDirectory(location)
                    else {
                        var pos = storageinfo.mapFromItem(parent, mouse.x, mouse.y)
                        filedialog_top.leftPanelPopupGenericRightClickMenu(Qt.point(storageinfo.x+pos.x, storageinfo.y+pos.y))
                    }
                }

            }

        }

    }

    Component.onCompleted:
        loadStorageInfo()

    function loadStorageInfo() {

        var s = handlingFileDialog.getStorageInfo()

        storage_model.clear()

        // for the heading
        storage_model.append({"name" : "",
                              "location" : "",
                              "filesystemtype" : "",
                              "icon" : ""})

        for(var i = 0; i < s.length; i+=4) {

            var name = s[i]
            var size = Math.round(s[i+1]/1024/1024/1024 +1);
            var filesystemtype = s[i+2]
            var path = s[i+3]

            storage_model.append({"name" : name,
                                  "size" : size,
                                  "location" : path,
                                  "filesystemtype" : filesystemtype,
                                  "icon" : "drive-harddisk"})

        }

    }

}
