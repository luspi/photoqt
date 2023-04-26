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

    opacity: (windowsizepopup.fileDialog || PQSettings.interfacePopoutOpenFile) ? 1 : 0
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

    Behavior on opacity { NumberAnimation { id: opacityAnim; duration: PQSettings.imageviewAnimationDuration*100 } }
    Behavior on x { NumberAnimation { id: xAnim; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAnim; duration: 0 } }

    SplitView {

        id: splitview

        anchors.fill: parent

        // Show larger handle with triple dash
        // code inspired by @hadoukez
        handleDelegate: Rectangle {

            width: 8
            color: styleData.hovered ? "#888888" : "#666666"
            Behavior on color { ColorAnimation { duration: 100 } }

            Image {
                y: (parent.height-height)/2
                width: parent.width
                height: width
                source: "/filedialog/handle.svg"
            }

        }

        // the dragsource, used to distinguish between dragging new folder and reordering userplaces
        property string dragSource: ""
        property string dragItemPath: ""

        Rectangle {

            id: leftcol

            width: PQSettings.openfileUserPlacesWidth
            onWidthChanged:
                PQSettings.openfileUserPlacesWidth = width

            color: "#22222222"

            Layout.minimumWidth: 200

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                    rightclickmenu.popup()
                }
            }

            PQMenu {

                id: rightclickmenu

                MenuItem {
                    text: (PQSettings.openfileUserPlacesStandard ? (em.pty+qsTranslate("filedialog", "Hide standard locations")) : (em.pty+qsTranslate("filedialog", "Show standard locations")))
                    onTriggered:
                        PQSettings.openfileUserPlacesStandard = !PQSettings.openfileUserPlacesStandard
                }

                MenuItem {
                    text: (PQSettings.openfileUserPlacesUser ? (em.pty+qsTranslate("filedialog", "Hide favorite locations")) : (em.pty+qsTranslate("filedialog", "Show favorite locations")))
                    onTriggered:
                        PQSettings.openfileUserPlacesUser = !PQSettings.openfileUserPlacesUser
                }

                MenuItem {
                    text: (PQSettings.openfileUserPlacesVolumes ? (em.pty+qsTranslate("filedialog", "Hide storage devices")) : (em.pty+qsTranslate("filedialog", "Show storage devices")))
                    onTriggered:
                        PQSettings.openfileUserPlacesVolumes = !PQSettings.openfileUserPlacesVolumes
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

    PQFileDialogSettings {
        id: filedialogsettings
    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        opacity: popinmouse.containsMouse ? 1 : 0.2
        Behavior on opacity { NumberAnimation { duration: 200 } }
        source: "/popin.svg"
        sourceSize: Qt.size(width, height)
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutOpenFile ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutOpenFile)
                    filedialog_window.storeGeometry()
                hideFileDialog()
                PQSettings.interfacePopoutOpenFile = !PQSettings.interfacePopoutOpenFile
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
            else if(what == "keyevent") {
                if(!filedialogsettings.isOpen())
                    fileview.keyEvent(param[0], param[1])
            } else if(what == "mouseevent") {
                if(!filedialogsettings.isOpen())
                    fileview.mouseEvent(param[0], param[1])
            } else if(what == "newfolder")
                setCurrentDirectory(param, true)
        }
    }

    function showFileDialog() {

        fileview.selectedFiles = ({})
        fileview.cutFiles = []

        if(!PQSettings.interfacePopoutOpenFile && !windowsizepopup.fileDialog) {
            // show in x direction
            if(PQSettings.imageviewAnimationType == "x") {
                xAnim.duration = 0
                filedialog_top.x = -filedialog_top.width
                xAnim.duration = PQSettings.imageviewAnimationDuration*100
                filedialog_top.x = 0
            // show in y direction
            } else if(PQSettings.imageviewAnimationType == "y") {
                yAnim.duration = 0
                filedialog_top.y = -filedialog_top.height
                yAnim.duration = PQSettings.imageviewAnimationDuration*100
                filedialog_top.y = 0
            }
            // fade in item
            filedialog_top.opacity = 1
        } else
            filedialog_window.visible = true

        if(!PQSettings.interfacePopoutOpenFile || !PQSettings.interfacePopoutOpenFileKeepOpen)
            variables.visibleItem = "filedialog"

        tweaks.readFileTypeSettings()
        fileview.setNameMimeTypeFilters()

        // this is necessary in order to catch shortcuts when element is popped out
        filedialog_top.forceActiveFocus()

    }

    function hideFileDialog() {
        if(filedialogsettings.isOpen()) {
            filedialogsettings.hide()
            return
        }
        if(PQSettings.interfacePopoutOpenFile && PQSettings.interfacePopoutOpenFileKeepOpen) {
            fileview.resetSelectedFiles()
            return
        }
        if(!PQSettings.interfacePopoutOpenFile && !windowsizepopup.fileDialog) {
            // hide in x direction
            if(PQSettings.imageviewAnimationType == "x") {
                xAnim.duration = PQSettings.imageviewAnimationDuration*100
                filedialog_top.x = -width
            // hide in y direction
            } else if(PQSettings.imageviewAnimationType == "y") {
                yAnim.duration = PQSettings.imageviewAnimationDuration*100
                filedialog_top.y = -height
            }
            // fade out item
            filedialog_top.opacity = 0
        } else
            filedialog_window.close()

        fileview.resetSelectedFiles()
        variables.visibleItem = ""
    }

    function leftPanelPopupGenericRightClickMenu() {
        rightclickmenu.popup()
    }

}
