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
import PQFileFolderModel 1.0
import QtQuick.Controls 2.2
import "../../elements"
import "../../modal"

GridView {

    id: files_grid

    clip: true

    cacheBuffer: 1

    property int dragItemIndex: -1

    property bool rightclickopen: false

    property bool currentIndexChangedUsingKeyIgnoreMouse: false
    onCurrentIndexChangedUsingKeyIgnoreMouseChanged:
        resetCurrentIndexChangedUsingKeyIgnoreMouse.restart()

    property bool currentFolderExcluded: false

    property var selectedFiles: ({})
    property int latestIndexSelected: 0
    property int rangeIndexSelected: 0

    property var cutFiles: []
    property var cutFilesTimestamp: handlingGeneral.getTimestamp()

    property var navigateToFileStartingWith: []

    Connections {
        target: handlingExternal
        onChangedClipboardData: {
            if(Math.abs(cutFilesTimestamp - handlingGeneral.getTimestamp()) > 1)
                fileview.cutFiles= []
        }
    }

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
        setModelToGridView()
    }

    // we connect to this model instead of a property binding of model to countFileDialog
    // this way we also rebuild the model if the count has remained the same
    Connections {
        target: filefoldermodel
        onNewDataLoadedFileDialog:
            setModelToGridView()
    }

    cellWidth: PQSettings.openfileDefaultView=="icons" ? PQSettings.openfileZoomLevel*6 : width-scroll.width
    cellHeight: PQSettings.openfileDefaultView=="icons" ? PQSettings.openfileZoomLevel*6 : PQSettings.openfileZoomLevel*2

    PQMouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.RightButton|Qt.LeftButton
        hoverEnabled: true
        onClicked: {
            if(mouse.button == Qt.LeftButton) {
                resetSelectedFiles()
            } else {
                var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                rightclickmenu_bg.popup(Qt.point(pos.x, pos.y))
            }
        }
        onMouseXChanged: {
            // when the context menu is open then there can be some confusion about where the mouse is -> ignore mouse movements
            if(rightclickmenu.isOpen)
                return
            files_grid.currentIndex = -1
        }
        onMouseYChanged: {
            // when the context menu is open then there can be some confusion about where the mouse is -> ignore mouse movements
            if(rightclickmenu.isOpen)
                return
            files_grid.currentIndex = -1
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
        onClosed: {
            rightclickmenu_timer.stop()
            files_grid.rightclickopen = false
        }
    }

    PQTextL {
        visible: (filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog)==0
        anchors.fill: parent
        anchors.margins: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#888888"
        font.weight: baselook.boldweight
        wrapMode: Text.WordWrap
        text: em.pty+qsTranslate("filedialog", "no supported files/folders found")
    }

    delegate: Item {

        id: maindeleg

        width: files_grid.cellWidth
        height: files_grid.cellHeight

        readonly property string fpath: filefoldermodel.entriesFileDialog[index]
        readonly property string fname: handlingFileDir.getFileNameFromFullPath(fpath)
        readonly property int fsize: handlingFileDir.getFileSize(fpath)

        property bool selected: files_grid.selectedFiles.hasOwnProperty(index)&&files_grid.selectedFiles[index]
        property bool cut: files_grid.cutFiles.indexOf(fpath)!=-1

        Rectangle {

            id: deleg_container

            width: files_grid.cellWidth
            height: files_grid.cellHeight

            // these anchors make sure the item falls back into place after being dropped
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            opacity: cut ? 0.6 : 1
            Behavior on opacity { NumberAnimation { duration: 250 } }

            property bool mouseInside: false
            color: maindeleg.selected ? "#88ffffff" :
                        (index < filefoldermodel.countFoldersFileDialog
                               ? (files_grid.currentIndex==index ? "#44888899" : "#44222233")
                               : (files_grid.currentIndex==index ? "#44aaaaaa" : "#44444444"))

            border.width: 1
            border.color: "#282828"

            Behavior on color { ColorAnimation { duration: 200 } }

            Image {

                id: fileicon

                x: PQSettings.openfileDefaultView=="icons" ? (parent.width-width)/2 : Math.min(5,PQSettings.openfileElementPadding)
                y: PQSettings.openfileDefaultView=="icons" ? (parent.height-height)/2 : Math.min(5,PQSettings.openfileElementPadding)
                width: PQSettings.openfileDefaultView=="icons" ? parent.width-2*PQSettings.openfileElementPadding : parent.height-Math.min(10,2*PQSettings.openfileElementPadding)
                height: PQSettings.openfileDefaultView=="icons" ? parent.height-2*PQSettings.openfileElementPadding : parent.height-Math.min(10,2*PQSettings.openfileElementPadding)

                asynchronous: true

                fillMode: Image.PreserveAspectFit

                smooth: true
                mipmap: false

                opacity: 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // if we do not cache this image, then we keep the generic icon here
                source: ((filethumb.status==Image.Ready&&!currentFolderExcluded)||(index < filefoldermodel.countFoldersFileDialog&&folderthumbs.sourceSize.width>1))
                            ? ""
                            : ("image://icon/"+(index < filefoldermodel.countFoldersFileDialog
                                                    ? (PQSettings.openfileDefaultView=="icons" ? "folder" : "folder_listicon")
                                                    : handlingFileDir.getSuffix(filefoldermodel.entriesFileDialog[index])))

                // rotating through images inside folder and show thumbnails
                Item {
                    id: folderthumbs
                    anchors.fill: parent

                    // the current image id (1-based indexing)
                    property int curnum: 0
                    // the current sourcesize
                    property size sourceSize: Qt.size(1,1)

                    // remove all other thumbnails
                    signal hideExcept(var n)

                    Repeater {
                        model: ListModel { id: ftmodel }
                        delegate: Image {
                            id: deleg
                            anchors.fill: folderthumbs
                            asynchronous: true
                            visible: sourceSize.width>1
                            mipmap: false   // setting this to true blurs too much detail in the thumbnail
                            fillMode: PQSettings.openfileFolderContentThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                            source: PQSettings.openfileFolderContentThumbnails ? ("image://folderthumb/" + folder + ":://::" + num) : ""
                            onSourceSizeChanged:
                                folderthumbs.sourceSize = sourceSize

                            onStatusChanged: {
                                if(status == Image.Ready) {
                                    if(curindex == files_grid.currentIndex)
                                        nextfolderthumb.restart()
                                    folderthumbs.hideExcept(num)
                                }
                            }
                            Connections {
                                target: folderthumbs
                                onHideExcept: {
                                    if(n != num)
                                        deleg.source = ""
                                }
                            }
                        }
                    }
                    Timer {
                        id: nextfolderthumb
                        interval: PQSettings.openfileFolderContentThumbnailsLoop
                                        ? (PQSettings.openfileFolderContentThumbnailsSpeed==1
                                                ? 2000
                                                : (PQSettings.openfileFolderContentThumbnailsSpeed==2
                                                        ? 1000
                                                        : 500))
                                        : 1

                        repeat: false||PQSettings.openfileFolderContentThumbnailsAutoload
                        running: false||PQSettings.openfileFolderContentThumbnailsAutoload
                        onTriggered: {
                            if(!PQSettings.openfileFolderContentThumbnails)
                                return
                            if(index >= filefoldermodel.countFoldersFileDialog || handlingFileDir.isExcludeDirFromCaching(filefoldermodel.entriesFileDialog[index]))
                                return
                            if(numberOfFilesInsideFolder.text*1 == 0)
                                return
                            if((files_grid.currentIndex==index || PQSettings.openfileFolderContentThumbnailsAutoload) && (PQSettings.openfileFolderContentThumbnailsLoop || folderthumbs.curnum == 0)) {
                                folderthumbs.curnum = (folderthumbs.curnum%(1*numberOfFilesInsideFolder.text))+1
                                ftmodel.append({"folder": filefoldermodel.entriesFileDialog[index], "num": folderthumbs.curnum, "curindex": index})
                            }
                        }
                    }
                    Connections {
                        target: files_grid
                        onCurrentIndexChanged: {
                            if(currentIndex==index)
                                nextfolderthumb.restart()
                        }
                    }
                }

                Rectangle {
                    id: numberOfFilesInsideFolder_cont
                    x: (parent.width-width)-5
                    y: 5
                    width: numberOfFilesInsideFolder.width + 20
                    height: 30
                    radius: 5
                    color: "#000000"
                    opacity: 0.8
                    visible: PQSettings.openfileDefaultView=="icons" && index < filefoldermodel.countFoldersFileDialog && numberOfFilesInsideFolder.text != ""

                    PQText {
                        id: numberOfFilesInsideFolder
                        x: 10
                        y: (parent.height-height)/2-2
                        font.weight: baselook.boldweight
                        elide: Text.ElideMiddle
                        text: ""
                    }
                }

                Rectangle {
                    x: (parent.width-width)/2
                    y: 5
                    width: currentNumberOfFileInsideFolder.width + 20
                    height: 30
                    radius: 5
                    color: "#444444"
                    opacity: 0.6
                    visible: PQSettings.openfileDefaultView=="icons" && index < filefoldermodel.countFoldersFileDialog && currentNumberOfFileInsideFolder.text != "" && (parent.width-2*numberOfFilesInsideFolder_cont.width) > width && PQSettings.openfileFolderContentThumbnailsLoop

                    PQText {
                        id: currentNumberOfFileInsideFolder
                        x: 10
                        y: (parent.height-height)/2-2
                        font.weight: baselook.boldweight
                        elide: Text.ElideMiddle
                        text: folderthumbs.curnum==0 ? "" : ("#"+folderthumbs.curnum)
                    }
                }

                Image {

                    id: filethumb
                    anchors.fill: parent
                    visible: index >= filefoldermodel.countFoldersFileDialog

                    cache: false

                    sourceSize: Qt.size(256, 256)

                    fillMode: PQSettings.openfileThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit

                    // mipmap does not look good, use only smooth
                    smooth: true
                    asynchronous: true

                    // if we do not cache this image, then we keep this empty and thus preserve the generic icon in the outside image
                    source: currentFolderExcluded ? "" : ((index < filefoldermodel.countFoldersFileDialog || !PQSettings.openfileThumbnails || filefoldermodel.entriesFileDialog[index]=="") ? "" : ("image://thumb/" + filefoldermodel.entriesFileDialog[index]))

                    Image {

                        width: PQSettings.openfileDefaultView=="icons" ? Math.min(files_grid.cellWidth-40, 50) : Math.min(files_grid.cellHeight-10, 50)
                        height: width

                        x: (parent.width-width)/2
                        y: (parent.height-height)/2

                        sourceSize: Qt.size(width, height)

                        visible: imageproperties.isVideo(filefoldermodel.entriesFileDialog[index])

                        source: visible ? "/multimedia/play.svg" : ""

                    }

                }



                Rectangle {

                    anchors.fill: parent
                    opacity: maindeleg.selected ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    visible: opacity > 0
                    color: "#88ffffff"

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

                id: icn

                width: parent.width
                height: files_grid.currentIndex == index ? parent.height/2 : parent.height/3.5
                y: parent.height-height

                Behavior on height { NumberAnimation { duration: 100 } }

                opacity: PQSettings.openfileDefaultView=="icons" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                color: maindeleg.selected ? "#aa888888" : (index < filefoldermodel.countFoldersFileDialog ? "#aa00002f" : "#aa2f2f2f")
                Behavior on color { ColorAnimation { duration: 200 } }

                PQTextS {

                    width: parent.width-20
                    height: parent.height
                    x: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: decodeURIComponent(fname)
                    elide: Text.ElideMiddle
                    font.weight: baselook.boldweight

                }

                Image {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 5
                    source: "/filedialog/folder.svg"
                    height: 12
                    mipmap: true
                    width: height
                    opacity: 0.75
                    visible: index < filefoldermodel.countFoldersFileDialog
                }

            }

            Image {
                id: fldr
                source: "/filedialog/folder.svg"
                anchors.left: fileicon.right
                anchors.leftMargin: 5
                y: (parent.height-height)/2
                width: height
                height: parent.height*0.35
                visible: index < filefoldermodel.countFoldersFileDialog && PQSettings.openfileFolderContentThumbnails && PQSettings.openfileDefaultView!="icons"

            }

            PQText {
                anchors.left: (index < filefoldermodel.countFoldersFileDialog && PQSettings.openfileFolderContentThumbnails) ? fldr.right : fileicon.right
                anchors.right: filesizenum.left
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                height: parent.height

                opacity: PQSettings.openfileDefaultView=="list" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                verticalAlignment: Text.AlignVCenter

                font.weight: baselook.boldweight

                text: decodeURIComponent(fname)
                elide: Text.ElideMiddle
                textFormat: Text.PlainText

            }

            PQText {
                id: filesizenum
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 5
                }
                verticalAlignment: Qt.AlignVCenter
                visible: PQSettings.openfileDefaultView=="list"
                font.weight: baselook.boldweight
                text: index < filefoldermodel.countFoldersFileDialog ? "" : handlingGeneral.convertBytesToHumanReadable(fsize)
            }

            PQMouseArea {

                id: mouseArea

                anchors.fill: parent
                anchors.leftMargin: PQSettings.openfileDefaultView=="list"?fileicon.width:0

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                acceptedButtons: Qt.LeftButton|Qt.RightButton

                property bool tooltipSetup: false

                property string tooltipStr: ""

                tooltip: PQSettings.openfileDetailsTooltip ? tooltipStr : ""
                tooltipWidth: 282
                tooltipSomeTransparency: false

                onExited:
                    files_grid.currentIndex = -1

                onEntered: {

                    // when the context menu is open then there can be some confusion about where the mouse is -> ignore mouse movements
                    if(rightclickmenu.isOpen)
                        return

                    if(!tooltipSetup) {

                        var fmodi = handlingFileDir.getFileModified(fpath)
                        var ftype = handlingFileDir.getFileType(fpath)

                        if(index < filefoldermodel.countFoldersFileDialog) {

                            var str = ""

                            if(PQSettings.openfileFolderContentThumbnails)
                                str += "<img src=\"image://folderthumb/" + filefoldermodel.entriesFileDialog[index] + ":://::" + folderthumbs.curnum + "\"><br><br>"

                            str += "<b>" + handlingFileDialog.createTooltipFilename(fname) + "</b><br><br>" +
                                   (numberOfFilesInsideFolder.text=="" ? "" : (em.pty+qsTranslate("filedialog", "# images")+": <b>" + numberOfFilesInsideFolder.text + "</b><br>")) +
                                    em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                    em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString() + "</b>"

                            tooltipStr = str
                            tooltipSetup = true

                        } else {

                            var str = ""

                            // if we do not cache this directory, we do not show a thumbnail image
                            if(!currentFolderExcluded && fileicon.source == "")
                                str += "<img src=\"image://thumb/::fixedsize::" + handlingGeneral.toPercentEncoding(filefoldermodel.entriesFileDialog[index]) + "\"><br><br>"

                            // add details
                            str += "<b>" + handlingFileDialog.createTooltipFilename(fname) + "</b>" + "<br><br>" +
                                      em.pty+qsTranslate("filedialog", "File size:")+" <b>" + handlingGeneral.convertBytesToHumanReadable(fsize) + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                      em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b>"

                            tooltipStr = str

                            // if the thumbnail is not yet loaded and a temp icon is shown, we want to check again for the thumbnail the next time the tooltip is shown
                            if(currentFolderExcluded || (!currentFolderExcluded && fileicon.source == ""))
                                tooltipSetup = true

                        }

                    }

                    if(!currentIndexChangedUsingKeyIgnoreMouse)
                        files_grid.currentIndex = index
                }

                Connections {
                    target: PQSettings
                    onOpenfileFolderContentThumbnailsChanged: {
                        mouseArea.tooltipSetup = false
                    }
                    onOpenfileThumbnailsChanged: {
                        mouseArea.tooltipSetup = false
                    }
                }

                onMouseXChanged: {

                    // when the context menu is open then there can be some confusion about where the mouse is -> ignore mouse movements
                    if(rightclickmenu.isOpen)
                        return

                    if(!currentIndexChangedUsingKeyIgnoreMouse && containsMouse)
                        files_grid.currentIndex = index

                }
                onMouseYChanged: {

                    // when the context menu is open then there can be some confusion about where the mouse is -> ignore mouse movements
                    if(rightclickmenu.isOpen)
                        return

                    if(!currentIndexChangedUsingKeyIgnoreMouse && containsMouse)
                        files_grid.currentIndex = index

                }

                onClicked: {
                    if(mouse.button == Qt.LeftButton) {
                        if(!files_grid.rightclickopen) {

                            // Ctrl+click toggles selection
                            if(mouse.modifiers & Qt.ControlModifier)
                                toggleCurrentFileSelection()

                            // Shift+click either toggles selection or selects range, depending on previous click
                            else if(mouse.modifiers & Qt.ShiftModifier) {

                                // if a previous click happened
                                if(files_grid.latestIndexSelected > -1) {

                                    // if the previous click was on the same item or if the currently clicked item is already selected => deselect
                                    if(files_grid.latestIndexSelected == index /*|| files_grid.selectedFiles[index] == 1*/) {

                                        // first reset previous range
                                        if(files_grid.rangeIndexSelected != -1) {
                                            if(files_grid.rangeIndexSelected < files_grid.latestIndexSelected) {
                                                for(var i = files_grid.rangeIndexSelected; i <= latestIndexSelected; ++i)
                                                    files_grid.selectedFiles[i] = 0
                                            } else if(files_grid.rangeIndexSelected > files_grid.latestIndexSelected) {
                                                for(var i = files_grid.latestIndexSelected; i <= rangeIndexSelected; ++i)
                                                    files_grid.selectedFiles[i] = 0
                                            }
                                            files_grid.rangeIndexSelected = -1
                                        }

                                        // set new range
                                        if(files_grid.selectedFiles[index] == 0)
                                            files_grid.selectedFiles[index] = 1

                                        files_grid.selectedFilesChanged()

                                    // if the previous click was on a smaller index, select range to right
                                    } else if(files_grid.latestIndexSelected < index) {

                                        // first reset previous range
                                        if(files_grid.rangeIndexSelected != -1) {
                                            if(files_grid.rangeIndexSelected < files_grid.latestIndexSelected) {
                                                for(var i = files_grid.rangeIndexSelected; i <= latestIndexSelected; ++i)
                                                    files_grid.selectedFiles[i] = 0
                                            } else if(files_grid.rangeIndexSelected > files_grid.latestIndexSelected) {
                                                for(var i = files_grid.latestIndexSelected; i <= rangeIndexSelected; ++i)
                                                    files_grid.selectedFiles[i] = 0
                                            }
                                        }
                                        files_grid.rangeIndexSelected = index

                                        // set new range
                                        for(var i = files_grid.latestIndexSelected; i <= index; ++i)
                                            files_grid.selectedFiles[i] = 1

                                        files_grid.selectedFilesChanged()

                                    // if the previous click was on a larger index, select range to left
                                    } else {

                                        // first reset previous range
                                        if(files_grid.rangeIndexSelected != -1) {
                                            if(files_grid.rangeIndexSelected < files_grid.latestIndexSelected) {
                                                for(var i = files_grid.rangeIndexSelected; i <= latestIndexSelected; ++i)
                                                    files_grid.selectedFiles[i] = 0
                                            } else if(files_grid.rangeIndexSelected > files_grid.latestIndexSelected) {
                                                for(var i = files_grid.latestIndexSelected; i <= rangeIndexSelected; ++i)
                                                    files_grid.selectedFiles[i] = 0
                                            }
                                        }
                                        files_grid.rangeIndexSelected = index

                                        // set new range
                                        for(var i = index; i <= files_grid.latestIndexSelected; ++i)
                                            files_grid.selectedFiles[i] = 1

                                        files_grid.selectedFilesChanged()

                                    }

                                // no previous click was recorded
                                } else {

                                    // toggle current element
                                    if(files_grid.selectedFiles.hasOwnProperty(index))
                                        files_grid.selectedFiles[index] = (files_grid.selectedFiles[index]+1)%2
                                    else
                                        files_grid.selectedFiles[index] = 1

                                    files_grid.selectedFilesChanged()

                                    // store last clicked index if selected
                                    if(files_grid.selectedFiles[index] == 1)
                                        files_grid.latestIndexSelected = index
                                    else
                                        files_grid.latestIndexSelected = -1

                                }

                            // simple click => load image
                            } else {

                                // click on folder
                                if(index < filefoldermodel.countFoldersFileDialog)
                                    filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[index])
                                // click on file
                                else {
                                    filefoldermodel.setFileNameOnceReloaded = filefoldermodel.entriesFileDialog[index]
                                    filefoldermodel.fileInFolderMainView = filefoldermodel.entriesFileDialog[index]
                                    filedialog_top.hideFileDialog()
                                }
                            }
                        }
                    } else {
                        var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                        rightclickmenu.popup(Qt.point(deleg_container.x+pos.x+(PQSettings.openfileDefaultView=="icons" ? 0 : fileicon.width), deleg_container.y+pos.y))
                    }
                }
            }

            Rectangle {
                id: selectedornot
                x: PQSettings.openfileDefaultView=="list" ? (fileicon.x + (fileicon.width-width)/2) : 5
                y: PQSettings.openfileDefaultView=="list" ? (fileicon.y + (fileicon.height-height)/2) : 5
                width: 30
                height: 30
                radius: 5

                color: "#bbbbbb"
                opacity: (selectmouse.containsMouse||maindeleg.selected) ? 0.8 : (files_grid.currentIndex==index ? (PQSettings.openfileDefaultView=="list" ? 0.4 : 0.8) : 0)
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    source: (maindeleg.selected ? "/filedialog/deselectfile.svg" : "/filedialog/selectfile.svg")
                    mipmap: true
                    opacity: selectmouse.containsMouse ? 0.8 : 0.4
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    PQMouseArea {
                        id: selectmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(files_grid.selectedFiles.hasOwnProperty(index))
                                files_grid.selectedFiles[index] = (files_grid.selectedFiles[index]+1)%2
                            else
                                files_grid.selectedFiles[index] = 1

                            if(files_grid.selectedFiles[index] == 1)
                                files_grid.latestIndexSelected = index
                            else
                                files_grid.latestIndexSelected = -1

                            files_grid.selectedFilesChanged()
                        }
                        onEntered: {
                            if(!currentIndexChangedUsingKeyIgnoreMouse)
                                files_grid.currentIndex = index
                        }
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
                onClosed: {
                    rightclickmenu_timer.stop()
                    files_grid.rightclickopen = false
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

            Rectangle {
                anchors.fill: parent
                color: "white"
                opacity: cut ? 0.2 : 0
            }

        }

    }

    Rectangle {
        id: floatingString
        width: floatingStringLabel.width+20
        height: floatingStringLabel.height+10
        color: "black"
        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        radius: 5
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 10
            bottomMargin: 10
        }
        Text {
            id: floatingStringLabel
            x: 10
            y: 5
            verticalAlignment: Text.AlignVCenter
            text: ""
            color: "white"
            font.weight: baselook.boldweight
            Connections {
                target: files_grid
                onNavigateToFileStartingWithChanged: {
                    if(files_grid.navigateToFileStartingWith.length == 0) {
                        floatingString.opacity = 0
                        return
                    }

                    floatingString.opacity = 0.8

                    var s = ""
                    for(var i = 0; i < files_grid.navigateToFileStartingWith.length; ++i) {
                        var n = handlingShortcuts.convertKeyCodeToText(files_grid.navigateToFileStartingWith[i]).toLowerCase()
                        if(n == "space")
                            s += " "
                        else if(n != "shift")
                            s += n
                    }
                    floatingStringLabel.text = s
                }
            }

        }
    }

    function mouseEvent(button, modifiers) {

        if(button == Qt.BackButton)
            breadcrumbs.goBackwards()
        else if(button == Qt.ForwardButton)
            breadcrumbs.goForwards()

    }

    function keyEvent(key, modifiers) {

        if(key == Qt.Key_Down) {

            files_grid.navigateToFileStartingWith = []

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.NoModifier) {
                if(PQSettings.openfileDefaultView=="list") {
                    if(currentIndex == -1)
                        currentIndex = 0
                    else if(currentIndex < filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)
                        currentIndex += 1
                } else {
                    if(currentIndex == -1)
                        currentIndex = 0
                    else if(currentIndex < filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-Math.floor(files_grid.width/files_grid.cellWidth))
                        currentIndex += Math.floor(files_grid.width/files_grid.cellWidth)
                    else
                        currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1
                }
            } else if(modifiers == Qt.ControlModifier)
                currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1

        } else if(key == Qt.Key_Up) {

            files_grid.navigateToFileStartingWith = []

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(modifiers == Qt.NoModifier) {
                if(PQSettings.openfileDefaultView=="list") {
                    if(currentIndex == -1)
                        currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1
                    else if(currentIndex > 0)
                        currentIndex -= 1
                } else {
                    if(currentIndex == -1)
                        currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1
                    else if(currentIndex > Math.floor(files_grid.width/files_grid.cellWidth)-1)
                        currentIndex -= Math.floor(files_grid.width/files_grid.cellWidth)
                    else if(currentIndex > 0)
                        currentIndex = 0
                }
            } else if(modifiers == Qt.ControlModifier)
                currentIndex = 0
            else if(modifiers == Qt.AltModifier && handlingFileDir.cleanPath(filefoldermodel.folderFileDialog) != "/")
                filedialog_top.setCurrentDirectory(filefoldermodel.folderFileDialog+"/..")

        } else if(key == Qt.Key_Left) {

            files_grid.navigateToFileStartingWith = []

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

            files_grid.navigateToFileStartingWith = []

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

            files_grid.navigateToFileStartingWith = []

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(PQSettings.openfileDefaultView=="list")

                currentIndex = Math.max(currentIndex-5, 0)
            else
                currentIndex = Math.max(currentIndex-5*Math.floor(files_grid.width/files_grid.cellWidth), 0)

        } else if(key == Qt.Key_PageDown && modifiers == Qt.NoModifier) {

            files_grid.navigateToFileStartingWith = []

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(PQSettings.openfileDefaultView=="list")
                currentIndex = Math.min(currentIndex+5, filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)
            else
                currentIndex = Math.min(currentIndex+5*Math.floor(files_grid.width/files_grid.cellWidth), filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)

        } else if((key == Qt.Key_Enter || key == Qt.Key_Return) && modifiers == Qt.NoModifier) {

            files_grid.navigateToFileStartingWith = []

            if(currentIndex < filefoldermodel.countFoldersFileDialog) {
                filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[currentIndex])
            } else {
                filefoldermodel.setFileNameOnceReloaded = filefoldermodel.entriesFileDialog[currentIndex]
                filefoldermodel.fileInFolderMainView = filefoldermodel.setFileNameOnceReloaded
                filedialog_top.hideFileDialog()
            }

        } else if((key == Qt.Key_Plus || key == Qt.Key_Equal) && modifiers == Qt.ControlModifier) {

            files_grid.navigateToFileStartingWith = []

            tweaks.zoomIn()

        } else if(key == Qt.Key_Minus && modifiers == Qt.ControlModifier) {

            files_grid.navigateToFileStartingWith = []

            tweaks.zoomOut()

        } else if((key == Qt.Key_H && modifiers == Qt.ControlModifier) || (key == Qt.Key_Period && modifiers == Qt.AltModifier)) {

            files_grid.navigateToFileStartingWith = []

            var old = PQSettings.openfileShowHiddenFilesFolders
            PQSettings.openfileShowHiddenFilesFolders = !old

        } else if(key == Qt.Key_Escape && modifiers == Qt.NoModifier) {

            if(anyFilesSelected())
                setFilesSelection(false)
            else  {
                files_grid.navigateToFileStartingWith = []
                filedialog_top.hideFileDialog()
            }

        } else if(key == Qt.Key_Home && modifiers == Qt.NoModifier) {

            files_grid.navigateToFileStartingWith = []

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = 0

        } else if(key == Qt.Key_End && modifiers == Qt.NoModifier) {

            files_grid.navigateToFileStartingWith = []

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1

        } else if(key == Qt.Key_C && modifiers == Qt.ControlModifier) {

            files_grid.navigateToFileStartingWith = []

            doCopyFiles()

        } else if(key == Qt.Key_X && modifiers == Qt.ControlModifier) {

            files_grid.navigateToFileStartingWith = []

            doCutFiles()

        } else if(key == Qt.Key_V && modifiers == Qt.ControlModifier) {

            files_grid.navigateToFileStartingWith = []

            doPasteFiles()

        } else if(key == Qt.Key_Delete && modifiers == Qt.NoModifier) {

            files_grid.navigateToFileStartingWith = []

            doDeleteFiles()

        } else if(key == Qt.Key_A && modifiers == Qt.ControlModifier) {

            files_grid.navigateToFileStartingWith = []

            setFilesSelection(1)

        } else {

            // ignore modifiers as characters
            if(key > 16000000)
                return

            // ignore modifier modified combos (except for capitalization)
            if(modifiers == Qt.ShiftModifier)
                modifiers = 0
            else if(modifiers != 0)
                return

            // add new key to list
            files_grid.navigateToFileStartingWith.push(key)
            files_grid.navigateToFileStartingWithChanged()

            currentIndexChangedUsingKeyIgnoreMouse = true

            // find starting index
            var tmp = (currentIndex==-1 ? 0 : currentIndex)

            // loop over all indices
            for(var i = tmp; i < tmp+filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog; ++i) {

                // we loop around to the beginning
                var use = i%(filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog)

                // filename
                var fname = handlingFileDir.getFileNameFromFullPath(filefoldermodel.entriesFileDialog[use])

                // check start of filename
                var thisIsIt = true
                for(var j = 0; j < files_grid.navigateToFileStartingWith.length; ++j) {

                    if(j >= fname.length) {
                        thisIsIt = false
                        break
                    }

                    // found mismatch
                    if(handlingShortcuts.convertCharacterToKeyCode(fname[j]) != files_grid.navigateToFileStartingWith[j]) {
                        thisIsIt = false
                        break
                    }

                }

                // done
                if(thisIsIt) {
                    currentIndex = use
                    break
                }

            }

            // restart resetting variable
            resetNavigateToFileStartingWith.restart()

        }

    }

    Timer {
        id: resetNavigateToFileStartingWith
        interval: 2000
        repeat: false
        running: false
        onTriggered:
            files_grid.navigateToFileStartingWith = []
    }

    PQModalConfirm {
        id: confirmDelete
        text: qsTranslate("filedialog", "Are you sure you want to move all selected files/folders to the trash?")
        informativeText: ""
        onConfirmedChanged: {
            if(confirmed) {
                if(isCurrentFileSelected() || (files_grid.currentIndex==-1 && anyFilesSelected())) {
                    for(var key in selectedFiles) {
                        if(selectedFiles[key] == 1)
                            handlingFileDir.deleteFile(filefoldermodel.entriesFileDialog[key], false)
                    }
                } else
                    handlingFileDir.deleteFile(filefoldermodel.entriesFileDialog[files_grid.currentIndex], false)
                files_grid.selectedFiles = ({})
            }
        }
    }

    PQModalConfirm {
        id: confirmCopy
        text: qsTranslate("filedialog", "Some files already exist in the current directory.")
        informativeText: "Do you want to overwrite the existing files?"
        property var files: []
        property bool clearCutFilesAtEnd: false
        onConfirmedChanged: {
            if(confirmed) {
                for(var f in files) {
                    handlingFileDir.copyFileToHere(files[f], filefoldermodel.folderFileDialog)
                    if(cutFiles.indexOf(files[f]) != -1)
                        handlingFileDir.deleteFile(files[f], true)
                }
                if(clearCutFilesAtEnd)
                    cutFiles = []
            }
        }
    }

    PQModalInform {
        id: informUser
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

    function setModelToGridView() {

        // the order below is important to avoid 'accidentally' preloading/caching excluded folders
        files_grid.model = 0
        currentFolderExcluded = handlingFileDir.isExcludeDirFromCaching(filefoldermodel.folderFileDialog)
        files_grid.model = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog

        // to have no item pre-selected when a new folder is loaded we need to set the currentIndex to -1 AFTER the model is set
        // (re-)setting the model will always reset the currentIndex to 0
        currentIndex = -1

        files_grid.navigateToFileStartingWith = []

    }

    function loadFolder() {

        setNameMimeTypeFilters()

        selectedFiles = ({})

        var cleaned = handlingFileDir.cleanPath(filefoldermodel.folderFileDialog)
        if(cleaned == "/" || (handlingGeneral.amIOnWindows() && cleaned.length == 3)) {
            breadcrumbs.pathParts = [cleaned]
        } else {
            var crumbs = cleaned.split("/")
            if(!handlingGeneral.amIOnWindows())
                crumbs[0] = "/"
            var crumbsfiltered = []
            for(var i = 0; i < crumbs.length; ++i) {
                if(crumbs[i] != "")
                    crumbsfiltered.push(crumbs[i])
            }
            breadcrumbs.pathParts = crumbsfiltered
        }

        resetSelectedFiles()

        files_grid.navigateToFileStartingWith = []

    }

    function resetSelectedFiles() {
        files_grid.selectedFiles = ({})
        files_grid.latestIndexSelected = -1
    }

    function isCurrentFileSelected() {
        return files_grid.currentIndex!=-1&&files_grid.selectedFiles.hasOwnProperty(files_grid.currentIndex) && files_grid.selectedFiles[files_grid.currentIndex]==1
    }
    function anyFilesSelected() {
        var s = 0
        for(var key in selectedFiles)
            s += selectedFiles[key]
        return s>0
    }

    function toggleCurrentFileSelection() {
        if(files_grid.selectedFiles.hasOwnProperty(files_grid.currentIndex))
            files_grid.selectedFiles[files_grid.currentIndex] = (files_grid.selectedFiles[files_grid.currentIndex]+1)%2
        else
            files_grid.selectedFiles[files_grid.currentIndex] = 1

        files_grid.selectedFilesChanged()

        if(files_grid.selectedFiles[files_grid.currentIndex] == 1)
            files_grid.latestIndexSelected = files_grid.currentIndex
        else
            files_grid.latestIndexSelected = -1

        files_grid.rangeIndexSelected = -1
    }

    function setFilesSelection(selected) {
        for(var i = 0; i < filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog; ++i)
            files_grid.selectedFiles[i] = selected

        files_grid.latestIndexSelected = -1

        files_grid.selectedFilesChanged()
    }

    function doCopyFiles() {

        cutFiles = []
        if(isCurrentFileSelected() || (files_grid.currentIndex==-1 && anyFilesSelected())) {
            var urls = []
            for(var key in selectedFiles) {
                if(selectedFiles[key] == 1)
                    urls.push(filefoldermodel.entriesFileDialog[key])
            }
            handlingExternal.copyFilesToClipboard(urls)
        } else {
            handlingExternal.copyFilesToClipboard([filefoldermodel.entriesFileDialog[files_grid.currentIndex]])
        }

    }

    function doCutFiles() {

        if(isCurrentFileSelected() || (files_grid.currentIndex==-1 && anyFilesSelected())) {
            var urls = []
            for(var key in selectedFiles) {
                if(selectedFiles[key] == 1)
                    urls.push(filefoldermodel.entriesFileDialog[key])
            }
            handlingExternal.copyFilesToClipboard(urls)
            // this has to come AFTER copying files to clipboard as this resets the cutFiles variable at first
            cutFilesTimestamp = handlingGeneral.getTimestamp()
            cutFiles = urls
        } else {
            handlingExternal.copyFilesToClipboard([filefoldermodel.entriesFileDialog[files_grid.currentIndex]])
            // this has to come AFTER copying files to clipboard as this resets the cutFiles variable at first
            cutFilesTimestamp = handlingGeneral.getTimestamp()
            files_grid.cutFiles = [filefoldermodel.entriesFileDialog[files_grid.currentIndex]]
        }

    }

    function doPasteFiles() {

        var lst = handlingExternal.getListOfFilesInClipboard()

        var nonexisting = []
        var existing = []

        for(var l in lst) {
            if(handlingFileDir.doesItExist(filefoldermodel.folderFileDialog + "/" + handlingFileDir.getFileNameFromFullPath(lst[l])))
                existing.push(lst[l])
            else
                nonexisting.push(lst[l])
        }

        if(existing.length > 0) {
            confirmCopy.files = existing
            confirmCopy.clearCutFilesAtEnd = (nonexisting.length == 0)
            confirmCopy.open()
        }

        if(nonexisting.length > 0) {
            for(var f in nonexisting) {
                if(handlingFileDir.copyFileToHere(nonexisting[f], filefoldermodel.folderFileDialog)) {
                    if(cutFiles.indexOf(nonexisting[f]) != -1)
                        handlingFileDir.deleteFile(nonexisting[f], true)
                }
            }
            if(existing.length == 0)
                cutFiles = []
        }

        if(existing.length == 0 && nonexisting.length == 0)
            informUser.informUser("Nothing found", "There are no files/folders in the clipboard.", "")

    }

    function doDeleteFiles() {

        if(files_grid.currentIndex == -1 && !anyFilesSelected())
            return

        if(handlingGeneral.amIOnWindows() && !handlingGeneral.isAtLeastQt515())
            return

        confirmDelete.open()

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
