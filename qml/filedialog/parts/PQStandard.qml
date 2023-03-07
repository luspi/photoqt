/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import Qt.labs.platform 1.0
import "../../elements"

ListView {

    id: standard_top

    boundsBehavior: Flickable.StopAtBounds

    model: 5

    height: childrenRect.height

    visible: PQSettings.openfileUserPlacesStandard

    property int hoverIndex: -1

    property var locs: [StandardPaths.displayName(StandardPaths.HomeLocation), handlingFileDir.cleanPath(StandardPaths.writableLocation(StandardPaths.HomeLocation)), "user-home",
                        StandardPaths.displayName(StandardPaths.DesktopLocation), handlingFileDir.cleanPath(StandardPaths.writableLocation(StandardPaths.DesktopLocation)), "user-desktop",
                        StandardPaths.displayName(StandardPaths.PicturesLocation), handlingFileDir.cleanPath(StandardPaths.writableLocation(StandardPaths.PicturesLocation)), "folder-pictures",
                        StandardPaths.displayName(StandardPaths.DownloadLocation), handlingFileDir.cleanPath(StandardPaths.writableLocation(StandardPaths.DownloadLocation)), "folder-downloads"]

    delegate: Rectangle {

        id: deleg_container

        width: parent.width
        height: 30

        color: standard_top.hoverIndex==index ? "#555555" : (locs[(index-1)*3 + 1]!=""&&(filefoldermodel.folderFileDialog == locs[(index-1)*3 + 1]||filefoldermodel.folderFileDialog == locs[(index-1)*3 + 1]+"/") ? "#88555555" : "#00555555")
        Behavior on color { ColorAnimation { duration: 200 } }

        // the icon for this entry (e.g., folder, ...)
        Item {

            id: entryicon

            opacity: 1

            // its size is square (height==width)
            width: deleg_container.height
            height: width

            // the icon image
            Image {

                // fill parent (with margin for better looks)
                anchors.fill: parent
                anchors.margins: 5

                // not shown for first entry (first entry is category title)
                visible: index>0

                // the image icon is taken from image loader (i.e., from system theme if available)
                source: ((locs[(index-1)*3 + 2]!==undefined) ? ("image://icon/" + locs[(index-1)*3 + 2]) : "")

            }

        }

        // The text of each entry
        PQText {

            id: entrytextUser

            // size and position
            anchors.fill: parent
            anchors.leftMargin: entryicon.width

            // vertically center text
            verticalAlignment: Qt.AlignVCenter

            // some styling
            color: index==0 ? "grey" : "white"
            font.weight: baselook.boldweight
            elide: Text.ElideRight

            //: This is the category title of user-set folders (or favorites) in the file dialog
            text: index==0 ? em.pty+qsTranslate("filedialog", "Standard") : locs[(index-1)*3 + 0]
        }

        // mouse area handling clicks
        PQMouseArea {

            id: mouseArea

            // fills full entry
            anchors.fill: parent

            // some properties
            hoverEnabled: true
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            cursorShape: index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

            tooltip: index == 0 ? em.pty+qsTranslate("filedialog", "Some standard locations") : handlingFileDir.pathWithNativeSeparators(locs[(index-1)*3 + 1])

            // clicking an entry loads the location or shows a context menu (depends on which button was used)
            onClicked: {
                if(mouse.button == Qt.LeftButton)
                    filedialog_top.setCurrentDirectory(locs[(index-1)*3 + 1])
                else {
                    var pos = standard_top.mapFromItem(parent, mouse.x, mouse.y)
                    filedialog_top.leftPanelPopupGenericRightClickMenu(Qt.point(standard_top.x+pos.x, standard_top.y+pos.y))
                }
            }

            onEntered:
                hoverIndex = (index>0 ? index : -1)
            onExited:
                hoverIndex = -1

        }

    }

}
