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
        onClicked: {
            if(mouse.button == Qt.LeftButton) {
                resetSelectedFiles()
            } else {
                var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                rightclickmenu_bg.popup(Qt.point(pos.x, pos.y))
            }
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

        Rectangle {

            id: deleg_container

            width: files_grid.cellWidth
            height: files_grid.cellHeight

            // these anchors make sure the item falls back into place after being dropped
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            property bool mouseInside: false
            color: maindeleg.selected ? "#88ffffff" :
                        (index < filefoldermodel.countFoldersFileDialog
                               ? (files_grid.currentIndex==index ? "#448888ee" : "#44222288")
                               : (files_grid.currentIndex==index ? "#44aaaaaa" : "#44444444"))

            border.width: 1
            border.color: "#282828"

            Behavior on color { ColorAnimation { duration: 200 } }

            Image {

                id: fileicon

                x: PQSettings.openfileDefaultView=="icons" ? 17.5 : 5
                y: 5
                width: PQSettings.openfileDefaultView=="icons" ? parent.width-10-25 : parent.height-10
                height: parent.height-10 - (PQSettings.openfileDefaultView=="icons" ? 25 : 0)

                asynchronous: true

                fillMode: Image.PreserveAspectFit

                smooth: true
                mipmap: true

                opacity: 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // if we do not cache this image, then we keep the generic icon here
                source: ((filethumb.status==Image.Ready&&!currentFolderExcluded)||(index < filefoldermodel.countFoldersFileDialog&&folderthumbs.sourceSize.width>1)) ? "" : "image://icon/" + (index < filefoldermodel.countFoldersFileDialog ? "folder" : ("IMAGE////"+handlingFileDir.getSuffix(filefoldermodel.entriesFileDialog[index])))

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
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                            source: "image://folderthumb/" + folder + ":://::" + num
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
                        interval: PQSettings.openfileFolderContentThumbnailsSpeed==1 ?
                                      2000 :
                                      (PQSettings.openfileFolderContentThumbnailsSpeed==2 ?
                                           1000 :
                                           500)

                        repeat: false
                        running: false
                        onTriggered: {
                            if(!PQSettings.openfileFolderContentThumbnails)
                                return
                            if(index >= filefoldermodel.countFoldersFileDialog || handlingFileDir.isExcludeDirFromCaching(filefoldermodel.entriesFileDialog[index]))
                                return
                            if(numberOfFilesInsideFolder.text*1 == 0)
                                return
                            folderthumbs.curnum = (folderthumbs.curnum%(1*numberOfFilesInsideFolder.text))+1
                            ftmodel.append({"folder": filefoldermodel.entriesFileDialog[index], "num": folderthumbs.curnum, "curindex": index})
                        }
                    }
                    Connections {
                        target: files_grid
                        onCurrentIndexChanged: {
                            if(currentIndex==index)
                                nextfolderthumb.restart()
                        }
                    }
                    Component.onCompleted: {
                        if(ftmodel.count==0 && PQSettings.openfileFolderContentThumbnailsAlwaysLoadFirst)
                            nextfolderthumb.restart()
                    }
                }

                Rectangle {
                    x: parent.width-width
                    y: 0
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
                    x: 0
                    y: 0
                    width: currentNumberOfFileInsideFolder.width + 20
                    height: 30
                    radius: 5
                    color: "#444444"
                    opacity: 0.6
                    visible: PQSettings.openfileDefaultView=="icons" && index < filefoldermodel.countFoldersFileDialog && currentNumberOfFileInsideFolder.text != ""

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

                    fillMode: Image.PreserveAspectFit

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

                opacity: PQSettings.openfileDefaultView=="icons" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                color: "#aa2f2f2f"

                PQTextS {

                    width: parent.width-20
                    height: parent.height
                    x: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: decodeURIComponent(fname)
                    maximumLineCount: 2
                    elide: Text.ElideMiddle
                    wrapMode: Text.Wrap
                    font.weight: baselook.boldweight

                }

            }

            PQText {
                anchors.fill: parent
                anchors.leftMargin: fileicon.width+10

                opacity: PQSettings.openfileDefaultView=="list" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                verticalAlignment: Text.AlignVCenter

                font.weight: baselook.boldweight

                text: decodeURIComponent(fname)
                maximumLineCount: 2
                elide: Text.ElideMiddle
                wrapMode: Text.Wrap
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

                onEntered: {

                    if(!tooltipSetup) {

                        var fmodi = handlingFileDir.getFileModified(fpath)
                        var ftype = handlingFileDir.getFileType(fpath)

                        if(index < filefoldermodel.countFoldersFileDialog) {

                            tooltipStr = "<b>" + handlingFileDialog.createTooltipFilename(fname) + "</b><br><br>" +
                                         (numberOfFilesInsideFolder.text=="" ? "" : (em.pty+qsTranslate("filedialog", "# images")+": <b>" + numberOfFilesInsideFolder.text + "</b><br>")) +
                                         em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                         em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString() + "</b>"

                            tooltipSetup = true

                        } else {

                            var str = ""

                            // if we do not cache this directory, we do not show a thumbnail image
                            if(currentFolderExcluded || fileicon.source != "")
                                str += "<img src=\"image://icon/IMAGE////::fixedsize::" + handlingFileDir.getSuffix(filefoldermodel.entriesFileDialog[index]) + "\"><br><br>"
                            else
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
                onMouseXChanged: {
                    if(!currentIndexChangedUsingKeyIgnoreMouse && containsMouse)
                        files_grid.currentIndex = index
                }
                onMouseYChanged: {
                    if(!currentIndexChangedUsingKeyIgnoreMouse && containsMouse)
                        files_grid.currentIndex = index
                }

                onExited: {
                    if(!currentIndexChangedUsingKeyIgnoreMouse)
                        files_grid.currentIndex = -1
                }
                onClicked: {
                    if(mouse.button == Qt.LeftButton) {
                        if(!files_grid.rightclickopen) {

                            // click on folder
                            if(index < filefoldermodel.countFoldersFileDialog)

                                filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[index])

                            else {

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

                                    if(index < filefoldermodel.countFoldersFileDialog)
                                        filedialog_top.setCurrentDirectory(filefoldermodel.entriesFileDialog[index])
                                    else {
                                        filefoldermodel.setFileNameOnceReloaded = filefoldermodel.entriesFileDialog[index]
                                        filefoldermodel.fileInFolderMainView = filefoldermodel.entriesFileDialog[index]
                                        filedialog_top.hideFileDialog()
                                    }
                                }
                            }
                        }
                    } else {
                        var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                        rightclickmenu.popup(Qt.point(deleg_container.x+pos.x+(PQSettings.openfileDefaultView=="icons" ? 0 : fileicon.width), deleg_container.y+pos.y))
                    }
                }
            }

            Image {
                id: selectedornot
                x: (parent.width-width)
                y: 0
                width: 30
                height: 30
                source: (maindeleg.selected ? "/filedialog/deselectfile.svg" : "/filedialog/selectfile.svg")
                mipmap: true
                opacity: selectmouse.containsMouse ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: index >= filefoldermodel.countFoldersFileDialog
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

            if(PQSettings.openfileDefaultView=="list")

                currentIndex = Math.max(currentIndex-5, 0)
            else
                currentIndex = Math.max(currentIndex-5*Math.floor(files_grid.width/files_grid.cellWidth), 0)

        } else if(key == Qt.Key_PageDown && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            if(PQSettings.openfileDefaultView=="list")
                currentIndex = Math.min(currentIndex+5, filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)
            else
                currentIndex = Math.min(currentIndex+5*Math.floor(files_grid.width/files_grid.cellWidth), filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1)

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

            var old = PQSettings.openfileShowHiddenFilesFolders
            PQSettings.openfileShowHiddenFilesFolders = !old

        } else if(key == Qt.Key_Escape && modifiers == Qt.NoModifier)

            filedialog_top.hideFileDialog()

        else if(key == Qt.Key_Home && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = 0

        } else if(key == Qt.Key_End && modifiers == Qt.NoModifier) {

            currentIndexChangedUsingKeyIgnoreMouse = true

            currentIndex = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog-1

        } else {

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

    function setModelToGridView() {

        // the order below is important to avoid 'accidentally' preloading/caching excluded folders
        files_grid.model = 0
        currentFolderExcluded = handlingFileDir.isExcludeDirFromCaching(filefoldermodel.folderFileDialog)
        files_grid.model = filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog

    }

    function loadFolder() {

        setNameMimeTypeFilters()

        currentIndex = (filefoldermodel.countFoldersFileDialog+filefoldermodel.countFilesFileDialog > 0 ? 0 : -1)

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

    }

    function resetSelectedFiles() {
        files_grid.selectedFiles = ({})
        files_grid.latestIndexSelected = -1
    }

    function isCurrentFileSelected() {
        return files_grid.selectedFiles.hasOwnProperty(files_grid.currentIndex) && files_grid.selectedFiles[files_grid.currentIndex]==1
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
        for(var i = 0; i < filefoldermodel.countFilesFileDialog; ++i)
            files_grid.selectedFiles[filefoldermodel.countFoldersFileDialog+i] = selected

        files_grid.latestIndexSelected = -1

        files_grid.selectedFilesChanged()
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
