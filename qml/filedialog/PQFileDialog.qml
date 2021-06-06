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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "./parts"
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Rectangle {

    id: filedialog_top

    x: 0
    y: 0
    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: PQSettings.openPopoutElement ? 1 : 0
    visible: (opacity != 0)
    enabled: visible

    color: "#333333"

    property var historyListDirectory: []
    property int historyListIndex: -1

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    function setCurrentDirectory(dir, addToHistory) {

        if(dir == filefoldermodel.folderFileDialog)
            return

        filefoldermodel.folderFileDialog = dir
        if(addToHistory === true || addToHistory === undefined) {

            // purge old history beyond current point (if not at end already)
            if(historyListIndex < historyListDirectory.length-1)
                historyListDirectory.splice(historyListIndex+1)

            historyListDirectory.push(handlingFileDir.cleanPath(dir))
            historyListIndex += 1

        }

    }

    Behavior on opacity { NumberAnimation { id: opacityAnim; duration: PQSettings.animationDuration*100 } }
    Behavior on x { NumberAnimation { id: xAnim; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAnim; duration: 0 } }

    SplitView {

        id: splitview

        anchors.fill: parent

        // the dragsource, used to distinguish between dragging new folder and reordering userplaces
        property string dragSource: ""
        property string dragItemPath: ""

        Rectangle {

            id: leftcol

            width: PQSettings.openUserPlacesWidth
            onWidthChanged:
                PQSettings.openUserPlacesWidth = width

            color: "#22222222"

            Layout.minimumWidth: 200

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                    rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
                }
            }

            PQMenu {

                id: rightclickmenu

                model: [
                    (PQSettings.openUserPlacesStandard ? (em.pty+qsTranslate("filedialog", "Hide standard locations")) : (em.pty+qsTranslate("filedialog", "Show standard locations"))),
                    (PQSettings.openUserPlacesUser ? (em.pty+qsTranslate("filedialog", "Hide favorite locations")) : (em.pty+qsTranslate("filedialog", "Show favorite locations"))),
                    (PQSettings.openUserPlacesVolumes ? (em.pty+qsTranslate("filedialog", "Hide storage devices")) : (em.pty+qsTranslate("filedialog", "Show storage devices")))
                ]

                onTriggered: {
                    if(index == 0)
                        PQSettings.openUserPlacesStandard = !PQSettings.openUserPlacesStandard
                    else if(index == 1)
                        PQSettings.openUserPlacesUser = !PQSettings.openUserPlacesUser
                    else if(index == 2)
                        PQSettings.openUserPlacesVolumes = !PQSettings.openUserPlacesVolumes
                }

            }

            PQStandard {
                id: std
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
            }

            PQPlaces {
                id: upl
                anchors.fill: parent
                anchors.topMargin: std.visible ? std.height+15 : 0
                anchors.bottomMargin: dev.visible ? dev.height+15 : 0
            }

            PQDevices {
                id: dev
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

            }

        }

        Item {

            id: rightcol

            Layout.fillWidth: true

            Layout.minimumWidth: 200

            PQBreadCrumbs {

                id: breadcrumbs

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

            }

            PQFileView {

                id: fileview

                anchors.fill: parent
                anchors.bottomMargin: tweaks.height
                anchors.topMargin: breadcrumbs.height

                PQPreview {

                    z: -1

                    anchors.fill: parent
                    filePath: ((filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog)>fileview.currentIndex&&fileview.currentIndex!=-1) ? (fileview.currentIndex<filefoldermodel.countFoldersFileDialog ? "" : filefoldermodel.entriesFileDialog[fileview.currentIndex]) : ""

                }

            }

            PQTweaks {

                id: tweaks

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

            }

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        opacity: popinmouse.containsMouse ? 1 : 0.2
        Behavior on opacity { NumberAnimation { duration: 200 } }
        source: "/popin.png"
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.aboutPopoutElement ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.openPopoutElement)
                    filedialog_window.storeGeometry()
                hideFileDialog()
                PQSettings.openPopoutElement = (PQSettings.openPopoutElement+1)%2
                HandleShortcuts.executeInternalFunction("__open")
            }
        }
    }

    Connections {
        target: loader
        onFiledialogPassOn: {
            if(what == "show")
                filedialog_top.showFileDialog()
            else if(what == "hide")
                filedialog_top.hideFileDialog()
            else if(what == "keyevent")
                fileview.keyEvent(param[0], param[1])
        }
    }

    function showFileDialog() {
        if(!PQSettings.openPopoutElement) {
            // show in x direction
            if(PQSettings.animationType == "x") {
                xAnim.duration = 0
                filedialog_top.x = -filedialog_top.width
                xAnim.duration = PQSettings.animationDuration*100
                filedialog_top.x = 0
            // show in y direction
            } else if(PQSettings.animationType == "y") {
                yAnim.duration = 0
                filedialog_top.y = -filedialog_top.height
                yAnim.duration = PQSettings.animationDuration*100
                filedialog_top.y = 0
            }
            // fade in item
            filedialog_top.opacity = 1
        } else
            filedialog_window.visible = true
        if(!PQSettings.openPopoutElementKeepOpen)
            variables.visibleItem = "filedialog"

        tweaks.readFileTypeSettings()
        fileview.setNameMimeTypeFilters()

        // this is necessary in order to catch shortcuts when element is popped out
        filedialog_top.forceActiveFocus()

    }

    function hideFileDialog() {
        if(PQSettings.openPopoutElementKeepOpen)
            return
        if(!PQSettings.openPopoutElement) {
            // hide in x direction
            if(PQSettings.animationType == "x") {
                xAnim.duration = PQSettings.animationDuration*100
                filedialog_top.x = -width
            // hide in y direction
            } else if(PQSettings.animationType == "y") {
                yAnim.duration = PQSettings.animationDuration*100
                filedialog_top.y = -height
            }
            // fade out item
            filedialog_top.opacity = 0
        } else
            filedialog_window.close()

        variables.visibleItem = ""
    }

    function leftPanelPopupGenericRightClickMenu(pos) {
        rightclickmenu.popup(pos)
    }

}
