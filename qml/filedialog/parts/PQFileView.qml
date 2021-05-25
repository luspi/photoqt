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

//    PQFileFolderModel {
//        id: files_model

//        showHidden: PQSettings.openShowHiddenFilesFolders
//        sortField: PQSettings.sortby=="name" ?
//                       PQFileFolderModel.Name :
//                       (PQSettings.sortby == "naturalname" ?
//                            PQFileFolderModel.NaturalName :
//                            (PQSettings.sortby == "time" ?
//                                 PQFileFolderModel.Time :
//                                 (PQSettings.sortby == "size" ?
//                                     PQFileFolderModel.Size :
//                                     PQFileFolderModel.Type)))
//        sortReversed: !PQSettings.sortbyAscending

//        Component.onCompleted: {
//            loadFolder(variables.openCurrentDirectory)
//            filedialog_top.historyListDirectory = [variables.openCurrentDirectory]
//            filedialog_top.historyListIndex = 0
//        }

//    }

//    model: files_model

    Component.onCompleted: {
        loadFolder(variables.openCurrentDirectory)
        filedialog_top.historyListDirectory = [variables.openCurrentDirectory]
        filedialog_top.historyListIndex = 0
    }

    model: filefoldermodel.countFileDialog

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

    delegate: Item {

        width: files_grid.cellWidth
        height: files_grid.cellHeight

        // 0 = fileName
        // 1 = filePath
        // 2 = fileSize
        // 3 = fileModified
        // 4 = fileIsDir
        // 5 = fileType
        property var entry: ["","",0,0,true,""]
        Component.onCompleted:
            entry = filefoldermodel.getValuesFileDialog(index)

        Rectangle {

            id: deleg_container

            width: files_grid.cellWidth
            height: files_grid.cellHeight

            // these anchors make sure the item falls back into place after being dropped
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            property bool mouseInside: false
            color: entry[4]
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

                source: entry[0]==".."||filethumb.status==Image.Ready ? "" : "image://icon/" + (entry[4] ? "folder" : "image")

                Text {
                    id: numberOfFilesInsideFolder
                    visible: PQSettings.openDefaultView=="icons" && fileIsDir
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
                    visible: !entry[4]

                    cache: false

                    sourceSize: Qt.size(256, 256)

                    fillMode: Image.PreserveAspectFit

                    // mipmap does not look good, use only smooth
                    smooth: true
                    asynchronous: true

                    source: (entry[4]||!PQSettings.openThumbnails) ? "" : ("image://thumb/" + entry[1])

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
                            splitview.dragItemPath = filePath
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
                height: entry[0]==".." ? parent.height : (files_grid.currentIndex == index ? parent.height/2 : parent.height/3.5)
                y: parent.height-height

                Behavior on height { NumberAnimation { duration: 100 } }

                opacity: PQSettings.openDefaultView=="icons" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                color: "#66000000"

                Text {

                    width: parent.width-20
                    height: entry[0]==".." ? parent.height-20 : parent.height
                    x: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    text: decodeURIComponent(entry[0])
                    maximumLineCount: 2
                    elide: Text.ElideMiddle
                    wrapMode: Text.Wrap

                    font.pointSize: entry[0]==".." ? 20 : (files_grid.currentIndex == index ? 10 : 8)
                    Behavior on font.pointSize { NumberAnimation { duration: 100 } }


                }

            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: entry[0] == ".." ? fileicon.width/2 : fileicon.width+10

                opacity: PQSettings.openDefaultView=="list" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                verticalAlignment: Text.AlignVCenter

                font.bold: true //fileName == ".."

                color: "white"
                text: decodeURIComponent(entry[0])
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
                text: entry[4] ? "" : handlingGeneral.convertBytesToHumanReadable(1*entry[2])
            }

            PQMouseArea {

                id: mouseArea

                anchors.fill: parent
                anchors.leftMargin: PQSettings.openDefaultView=="list"?fileicon.width:0

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                tooltip: (entry[4] ?

                          ("<b><span style=\"font-size: x-large\">" + entry[0] + "</span></b><br><br>" +
                           (numberOfFilesInsideFolder.text=="" ? "" : (em.pty+qsTranslate("filedialog", "# images")+": <b>" + numberOfFilesInsideFolder.text + "</b><br>")) +
                           em.pty+qsTranslate("filedialog", "Date:")+" <b>" + entry[3].toLocaleDateString() + "</b><br>" +
                           em.pty+qsTranslate("filedialog", "Time:")+" <b>" + entry[3].toLocaleTimeString() + "</b>") :

                         ("<img src=\"image://thumb/" + entry[1].replace("'","&#39;") + "\"><br><br>" +
                          "<b><span style=\"font-size: x-large\">" + entry[0] + "</span></b>" + "<br><br>" +
                          em.pty+qsTranslate("filedialog", "File size:")+" <b>" + handlingGeneral.convertBytesToHumanReadable(1*entry[2]) + "</b><br>" +
                          em.pty+qsTranslate("filedialog", "File type:")+" <b>" + entry[5] + "</b><br>" +
                          em.pty+qsTranslate("filedialog", "Date:")+" <b>" + entry[3].toLocaleDateString() + "</b><br>" +
                          em.pty+qsTranslate("filedialog", "Time:")+" <b>" + entry[3].toLocaleTimeString()+ "</b>"))

                acceptedButtons: Qt.LeftButton|Qt.RightButton

                onEntered: {
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
                            if(entry[4])
                                filedialog_top.setCurrentDirectory(entry[1])
                            else {
                                filefoldermodel.setFileNameOnceReloaded = filefoldermodel.folderFileDialog + "/" + entry[0]
                                filefoldermodel.fileInFolderMainView = filefoldermodel.folderFileDialog + "/" + entry[0]
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
                isFolder: entry[4]
                isFile: !entry[4]
                path: entry[1]
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
                if(entry[4] && entry[0] != "..") {
                    handlingFileDialog.getNumberOfFilesInFolder(entry[1], function(count) {
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
                else if(currentIndex < model.count-1)
                    currentIndex += 1
            } else if(modifiers == Qt.ControlModifier)
                currentIndex = model.count-1

        } else if(key == Qt.Key_Up) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.NoModifier) {
                if(currentIndex == -1)
                    currentIndex = model.count-1
                else if(currentIndex > 0)
                    currentIndex -= 1
            } else if(modifiers == Qt.ControlModifier)
                currentIndex = 0
            else if(modifiers == Qt.AltModifier && handlingFileDir.cleanPath(variables.openCurrentDirectory) != "/")
                filedialog_top.setCurrentDirectory(variables.openCurrentDirectory+"/..")

        } else if(key == Qt.Key_Left) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.AltModifier)
                breadcrumbs.goBackwards()
            else if(modifiers == Qt.NoModifier) {
                if(currentIndex == -1)
                    currentIndex = model.count-1
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
                else if(currentIndex < model.count-1)
                    currentIndex += 1
            }

        } else if(key == Qt.Key_PageUp && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = Math.max(currentIndex-5, 0)

        } else if(key == Qt.Key_PageDown && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = Math.min(currentIndex+5, filefoldermodel.countFileDialog-1)

        } else if((key == Qt.Key_Enter || key == Qt.Key_Return) && modifiers == Qt.NoModifier) {

            if(filefoldermodel.entriesFileDialog[currentIndex].fileIsDir) {
                filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[currentIndex].filePath)
            } else {
//                foldermodel.setFolderAndImages(files_model.getFilePath(currentIndex), files_model.getCopyOfAllFiles())
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
            var foundSomething = false

            for(var i = tmp; i < filefoldermodel.countFileDialog; ++i) {

                if(handlingShortcuts.convertCharacterToKeyCode(filefoldermodel.getFileNameFileDialog(currentIndex)[0]) == key) {
                    currentIndex = i
                    foundSomething = true
                    break;
                }

            }

            if(!foundSomething) {

                for(var i = 0; i < tmp; ++i) {

                    if(handlingShortcuts.convertCharacterToKeyCode(filefoldermodel.getFileNameFileDialog(currentIndex)[0]) == key) {
                        currentIndex = i
                        foundSomething = true
                        break;
                    }

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

    function loadFolder(loc) {

        // set right name filter
//        if(tweaks.showWhichFileTypeIndex == "all") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormats()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypes()
//        } else if(tweaks.showWhichFileTypeIndex == "qt") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsQt()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesQt()
//        } else if(tweaks.showWhichFileTypeIndex == "magick") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsMagick()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesMagick()
//        } else if(tweaks.showWhichFileTypeIndex == "libraw") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsLibRaw()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesLibRaw()
//        } else if(tweaks.showWhichFileTypeIndex == "devil") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsDevIL()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesDevIL()
//        } else if(tweaks.showWhichFileTypeIndex == "freeimage") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsFreeImage()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesFreeImage()
//        } else if(tweaks.showWhichFileTypeIndex == "poppler") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsPoppler()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesPoppler()
//        } else if(tweaks.showWhichFileTypeIndex == "video") {
//            files_model.nameFilters = PQImageFormats.getEnabledFormatsVideo()
//            files_model.mimeTypeFilters = PQImageFormats.getEnabledMimeTypesVideo()
//        } else if(tweaks.showWhichFileTypeIndex == "allfiles") {
//            files_model.nameFilters = []
//            files_model.mimeTypeFilter = []
//        } else
//            console.log("PQFileView.loadFolder(): ERROR: file type unknown:", tweaks.showWhichFileTypeIndex)

        loc = handlingFileDir.cleanPath(loc)

        filefoldermodel.folderFileDialog = loc
//        currentIndex = (filefoldermodel.countFileDialog > 0 ? 0 : -1)
        currentIndex = 0

        if(loc == "/")
            breadcrumbs.pathParts = [""]
        else
            breadcrumbs.pathParts = loc.split("/")

    }

    Connections {
        target: variables
        onOpenCurrentDirectoryChanged:
            loadFolder(variables.openCurrentDirectory)
    }

}
