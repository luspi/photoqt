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
import PQFileFolderModel 1.0
import QtQuick.Controls 2.2
import "../../elements"

GridView {

    id: files_grid

    clip: true

    cacheBuffer: 1

    property int dragItemIndex: -1

    property bool rightclickopen: false

    property bool currentIndexChangedUsingKeyIgnoreMouse: false
    onCurrentIndexChangedUsingKeyIgnoreMouseChanged:
        resetCurrentIndexChangedUsingKeyIgnoreMouse.restart()

    Timer {
        id: resetCurrentIndexChangedUsingKeyIgnoreMouse
        interval: 300
        repeat: false
        running: false
        onTriggered:
            currentIndexChangedUsingKeyIgnoreMouse = false
    }

    ScrollBar.vertical: PQScrollBar { id: scroll }

    Component.onCompleted: {
        filedialog_top.historyListDirectory = [filefoldermodel.folderFileDialog]
        filedialog_top.historyListIndex = 0
        loadFolder()
    }

    // we connect to this model instead of a property binding of model to countFileDialog
    // this way we also rebuild the model if the count has remained the same
    Connections {
        target: filefoldermodel
        onNewDataLoadedFileDialog: {
            files_grid.model = 0
            files_grid.model = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog
        }
    }

    cellWidth: PQSettings.openDefaultView=="icons" ? PQSettings.openZoomLevel*6 : width-scroll.width
    cellHeight: PQSettings.openDefaultView=="icons" ? PQSettings.openZoomLevel*6 : PQSettings.openZoomLevel*2

    PQMouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.RightButton
        onClicked: {
            var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
            rightclickmenu_bg.popup(Qt.point(pos.x, pos.y))
        }
    }

    PQRightClickMenu {
        id: rightclickmenu_bg
        isFolder: false
        isFile: false
        onVisibleChanged: {
            if(visible) {
                rightclickmenu_timer.stop()
                files_grid.rightclickopen = true
            } else
                rightclickmenu_timer.restart()
        }
    }

    Text {
        visible: (filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog)==0
        anchors.fill: parent
        anchors.margins: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 15
        color: "#888888"
        font.bold: true
        wrapMode: Text.WordWrap
        text: em.pty+qsTranslate("filedialog", "no supported files/folders found")
    }

    delegate: Item {

        width: files_grid.cellWidth
        height: files_grid.cellHeight

        readonly property string fpath: filefoldermodel.entriesFileDialog[index]
        readonly property string fname: handlingFileDir.getFileNameFromFullPath(fpath)
        readonly property int fsize: handlingFileDir.getFileSize(fpath)

        Rectangle {

            id: deleg_container

            width: files_grid.cellWidth
            height: files_grid.cellHeight

            // these anchors make sure the item falls back into place after being dropped
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            property bool mouseInside: false
            color: index < filefoldermodel.countFoldersFileDialog
                       ? (files_grid.currentIndex==index ? "#44888899" : "#44222233")
                       : (files_grid.currentIndex==index ? "#44aaaaaa" : "#44444444")

            border.width: 1
            border.color: "#282828"

            Behavior on color { ColorAnimation { duration: 200 } }

            Image {

                id: fileicon

                x: 5
                y: 5
                width: PQSettings.openDefaultView=="icons" ? parent.width-10 : parent.height-10
                height: parent.height-10

                asynchronous: true

                opacity: files_grid.currentIndex==index ? 1 : 0.6
                Behavior on opacity { NumberAnimation { duration: 200 } }

                source: filethumb.status==Image.Ready ? "" : "image://icon/" + (index < filefoldermodel.countFoldersFileDialog ? "folder" : "image")

                Text {
                    id: numberOfFilesInsideFolder
                    visible: PQSettings.openDefaultView=="icons" && index < filefoldermodel.countFoldersFileDialog
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    font.pointSize: 11
                    font.bold: true
                    elide: Text.ElideMiddle
                    text: ""
                }

                Image {

                    id: filethumb
                    anchors.fill: parent
                    visible: index >= filefoldermodel.countFoldersFileDialog

                    cache: false

                    sourceSize: Qt.size(256, 256)

                    fillMode: Image.PreserveAspectFit

                    // mipmap does not look good, use only smooth
                    smooth: true
                    asynchronous: true

                    source: (index < filefoldermodel.countFoldersFileDialog || !PQSettings.openThumbnails || filefoldermodel.entriesFileDialog[index]=="") ? "" : ("image://thumb/" + filefoldermodel.entriesFileDialog[index])

                }

                PQMouseArea {

                    id: dragArea

                    anchors.fill: parent

                    drag.target: parent.parent

                    hoverEnabled: true
                    tooltip: em.pty+qsTranslate("filedialog", "Click and drag to favorites")

                    cursorShape: Qt.OpenHandCursor

                    onPressed:
                        cursorShape = Qt.ClosedHandCursor
                    onReleased:
                        cursorShape = Qt.OpenHandCursor

                    drag.onActiveChanged: {
                        if (dragArea.drag.active) {
                            dragArea.cursorShape = Qt.ClosedHandCursor
                            // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                            files_grid.dragItemIndex = index
                            splitview.dragSource = "folders"
                            splitview.dragItemPath = filefoldermodel.entriesFileDialog[index]
                        }
                        deleg_container.Drag.drop();
                        if(!dragArea.drag.active) {
                            dragArea.cursorShape = Qt.OpenHandCursor
                            // reset variables used for drag/drop
                            files_grid.dragItemIndex = -1
                            splitview.dragItemPath = ""
                        }
                    }

                }

            }

            Rectangle {

                width: parent.width
                height: files_grid.currentIndex == index ? parent.height/2 : parent.height/3.5
                y: parent.height-height

                Behavior on height { NumberAnimation { duration: 100 } }

                opacity: PQSettings.openDefaultView=="icons" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                color: "#66000000"

                Text {

                    width: parent.width-20
                    height: parent.height
                    x: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    text: decodeURIComponent(fname)
                    maximumLineCount: 2
                    elide: Text.ElideMiddle
                    wrapMode: Text.Wrap

                    font.pointSize: files_grid.currentIndex == index ? 10 : 8
                    Behavior on font.pointSize { NumberAnimation { duration: 100 } }


                }

            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: fileicon.width+10

                opacity: PQSettings.openDefaultView=="list" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                verticalAlignment: Text.AlignVCenter

                font.bold: true

                color: "white"
                text: decodeURIComponent(fname)
                maximumLineCount: 2
                elide: Text.ElideMiddle
                wrapMode: Text.Wrap
            }

            Text {
                id: filesizenum
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 5
                }
                verticalAlignment: Qt.AlignVCenter
                visible: PQSettings.openDefaultView=="list"
                color: "white"
                font.bold: true
                text: index < filefoldermodel.countFoldersFileDialog ? "" : handlingGeneral.convertBytesToHumanReadable(fsize)
            }

            PQMouseArea {

                id: mouseArea

                anchors.fill: parent
                anchors.leftMargin: PQSettings.openDefaultView=="list"?fileicon.width:0

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                acceptedButtons: Qt.LeftButton|Qt.RightButton

                property bool tooltipSetup: false

                onEntered: {

                    if(!tooltipSetup) {

                        var fmodi = handlingFileDir.getFileModified(fpath)
                        var ftype = handlingFileDir.getFileType(fpath)

                        if(index < filefoldermodel.countFoldersFileDialog) {
                            tooltip = "<b><span style=\"font-size: x-large\">" + fname + "</span></b><br><br>" +
                                      (numberOfFilesInsideFolder.text=="" ? "" : (em.pty+qsTranslate("filedialog", "# images")+": <b>" + numberOfFilesInsideFolder.text + "</b><br>")) +
                                      em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString() + "</b>"
                        } else {
                            tooltip = "<img src=\"image://thumb/" + filefoldermodel.entriesFileDialog[index].replace("'","&#39;") + "\"><br><br>" +
                                      "<b><span style=\"font-size: x-large\">" + fname + "</span></b>" + "<br><br>" +
                                      em.pty+qsTranslate("filedialog", "File size:")+" <b>" + handlingGeneral.convertBytesToHumanReadable(fsize) + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b>"
                        }

                        tooltipSetup = true
                    }

                    if(!currentIndexChangedUsingKeyIgnoreMouse)
                        files_grid.currentIndex = index
                }
                onExited: {
                    if(!currentIndexChangedUsingKeyIgnoreMouse)
                        files_grid.currentIndex = -1
                }
                onClicked: {
                    if(mouse.button == Qt.LeftButton) {
                        if(!files_grid.rightclickopen) {
                            if(index < filefoldermodel.countFoldersFileDialog)
                                filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[index])
                            else {
                                filefoldermodel.setFileNameOnceReloaded = filefoldermodel.entriesFileDialog[index]
                                filefoldermodel.fileInFolderMainView = filefoldermodel.entriesFileDialog[index]
                                filedialog_top.hideFileDialog()
                            }
                        }
                    } else {
                        var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                        rightclickmenu.popup(Qt.point(deleg_container.x+pos.x+(PQSettings.openDefaultView=="icons" ? 0 : fileicon.width), deleg_container.y+pos.y))
                    }
                }
            }

            PQRightClickMenu {
                id: rightclickmenu
                isFolder: index < filefoldermodel.countFoldersFileDialog
                isFile: !isFolder
                path: filefoldermodel.entriesFileDialog[index]
                onVisibleChanged: {
                    if(visible) {
                        rightclickmenu_timer.stop()
                        files_grid.rightclickopen = true
                    } else
                        rightclickmenu_timer.restart()
                }

            }

            Drag.active: dragArea.drag.active
            Drag.hotSpot.x: fileicon.width/2
            Drag.hotSpot.y: fileicon.height/2

            states: [
                State {
                    // when drag starts, reparent entry to splitview
                    when: deleg_container.Drag.active
                    ParentChange {
                        target: deleg_container
                        parent: splitview
                    }
                    // (temporarily) remove anchors
                    AnchorChanges {
                        target: deleg_container
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: undefined
                    }
                }
            ]

            Component.onCompleted: {
                if(index < filefoldermodel.countFoldersFileDialog) {
                    handlingFileDialog.getNumberOfFilesInFolder(filefoldermodel.entriesFileDialog[index], function(count) {
                        if(count > 0) {
                            numberOfFilesInsideFolder.text = count
                            if(count == 1)
                                filesizenum.text = em.pty+qsTranslate("filedialog", "%1 image").arg(count)
                            else
                                filesizenum.text = em.pty+qsTranslate("filedialog", "%1 images").arg(count)
                        }
                    })
                }
            }

        }

    }

    function keyEvent(key, modifiers) {

        if(key == Qt.Key_Down) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.NoModifier) {
                if(currentIndex == -1)
                    currentIndex = 0
                else if(currentIndex < filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)
                    currentIndex += 1
            } else if(modifiers == Qt.ControlModifier)
                currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1

        } else if(key == Qt.Key_Up) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.NoModifier) {
                if(currentIndex == -1)
                    currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1
                else if(currentIndex > 0)
                    currentIndex -= 1
            } else if(modifiers == Qt.ControlModifier)
                currentIndex = 0
            else if(modifiers == Qt.AltModifier && handlingFileDir.cleanPath(filefoldermodel.folderFileDialog) != "/")
                filedialog_top.setCurrentDirectory(filefoldermodel.folderFileDialog+"/..")

        } else if(key == Qt.Key_Left) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.AltModifier)
                breadcrumbs.goBackwards()
            else if(modifiers == Qt.NoModifier) {
                if(currentIndex == -1)
                    currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1
                else if(currentIndex > 0)
                    currentIndex -= 1
            }


        } else if(key == Qt.Key_Right) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.AltModifier)
                breadcrumbs.goForwards()
            else if(modifiers == Qt.NoModifier) {
                if(currentIndex == -1)
                    currentIndex = 0
                else if(currentIndex < filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)
                    currentIndex += 1
            }

        } else if(key == Qt.Key_PageUp && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = Math.max(currentIndex-5, 0)

        } else if(key == Qt.Key_PageDown && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = Math.min(currentIndex+5, filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)

        } else if((key == Qt.Key_Enter || key == Qt.Key_Return) && modifiers == Qt.NoModifier) {

            if(currentIndex < filefoldermodel.countFoldersFileDialog) {
                filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[currentIndex])
            } else {
                filefoldermodel.setFileNameOnceReloaded = filefoldermodel.entriesFileDialog[currentIndex]
                filefoldermodel.fileInFolderMainView = filefoldermodel.setFileNameOnceReloaded
                filedialog_top.hideFileDialog()
            }

        } else if((key == Qt.Key_Plus || key == Qt.Key_Equal) && modifiers == Qt.ControlModifier)

            tweaks.zoomIn()

        else if(key == Qt.Key_Minus && modifiers == Qt.ControlModifier)

            tweaks.zoomOut()

        else if((key == Qt.Key_H && modifiers == Qt.ControlModifier) || (key == Qt.Key_Period && modifiers == Qt.AltModifier)) {

            var old = PQSettings.openShowHiddenFilesFolders
            PQSettings.openShowHiddenFilesFolders = !old

        } else if(key == Qt.Key_Escape && modifiers == Qt.NoModifier)

            filedialog_top.hideFileDialog()

        else {

            currentIndexChangedUsingKeyIgnoreMouse = true

            var tmp = (currentIndex==-1 ? 0 : currentIndex+1)

            for(var i = tmp; i < filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog; ++i) {

                if(handlingShortcuts.convertCharacterToKeyCode(handlingFileDir.getFileNameFromFullPath(filefoldermodel.entriesFileDialog[currentIndex][0])) == key) {
                    currentIndex = i
                    break;
                }

            }

        }

    }

    // using this timer has the following effect:
    // right click menu open, click on file/folder -> don't open file/folder but only close menu
    Timer {
        id: rightclickmenu_timer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            if(!rightclickmenu.visible)
                files_grid.rightclickopen = false
        }
    }

    function setNameMimeTypeFilters() {

        // set right name filter
        if(tweaks.showWhichFileTypeIndex == "all") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormats()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypes()
        } else if(tweaks.showWhichFileTypeIndex == "qt") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsQt()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesQt()
        } else if(tweaks.showWhichFileTypeIndex == "magick") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsMagick()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesMagick()
        } else if(tweaks.showWhichFileTypeIndex == "libraw") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsLibRaw()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesLibRaw()
        } else if(tweaks.showWhichFileTypeIndex == "devil") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsDevIL()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesDevIL()
        } else if(tweaks.showWhichFileTypeIndex == "freeimage") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsFreeImage()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesFreeImage()
        } else if(tweaks.showWhichFileTypeIndex == "poppler") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsPoppler()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesPoppler()
        } else if(tweaks.showWhichFileTypeIndex == "video") {
            filefoldermodel.defaultNameFilters = PQImageFormats.getEnabledFormatsVideo()
            filefoldermodel.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesVideo()
        } else if(tweaks.showWhichFileTypeIndex == "allfiles") {
            filefoldermodel.defaultNameFilters = []
            filefoldermodel.mimeTypeFilter = []
        } else
            console.log("PQFileView.loadFolder(): ERROR: file type unknown:", tweaks.showWhichFileTypeIndex)

    }

    function loadFolder() {

        setNameMimeTypeFilters()

        currentIndex = (filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog > 0 ? 0 : -1)

        var cleaned = handlingFileDir.cleanPath(filefoldermodel.folderFileDialog)
        if(cleaned == "/")
            breadcrumbs.pathParts = [""]
        else
            breadcrumbs.pathParts = cleaned.split("/")

    }

    Connections {
        target: filefoldermodel
        onFolderFileDialogChanged:
            loadFolder()
    }

    Connections {
        target: tweaks
        onShowWhichFileTypeIndexChanged:
            setNameMimeTypeFilters()
    }

}
