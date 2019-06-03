import QtQuick 2.9
import PQFileFolderModel 1.0
import QtQuick.Controls 2.2
import "../../elements"

GridView {

    id: files_grid

    clip: true

    cacheBuffer: 1

    property int dragItemIndex: -1

    property int currentlyHoveredIndex: -1

    ScrollBar.vertical: PQScrollBar { id: scroll }

    PQFileFolderModel {
        id: files_model
        nameFilters: tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="all" ?
                         imageformats.getAllEnabledFileformats() :
                         tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="qt" ?
                             imageformats.getEnabledFileFormatsQt() :
                             tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="gm" ?
                                 imageformats.getEnabledFileFormatsGM() :
                                 tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="raw" ?
                                     imageformats.getEnabledFileFormatsRAW() :
                                     tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="devil" ?
                                         imageformats.getEnabledFileFormatsDevIL() :
                                         tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="freeimage" ?
                                             imageformats.getEnabledFileFormatsFreeImage() :
                                             tweaks.allFileTypes[tweaks.showWhichFileTypeIndex]==="poppler" ?
                                                 imageformats.getEnabledFileFormatsPoppler() :
                                                 []
        showHidden: settings.openShowHiddenFilesFolders
        sortField: settings.sortby=="name" ?
                       PQFileFolderModel.Name :
                       (settings.sortby == "naturalname" ?
                            PQFileFolderModel.NaturalName :
                            (settings.sortby == "time" ?
                                 PQFileFolderModel.Time :
                                 (settings.sortby == "size" ?
                                     PQFileFolderModel.Size :
                                     PQFileFolderModel.Type)))
        sortReversed: !settings.sortbyAscending
    }

    model: files_model

    cellWidth: settings.openDefaultView=="icons" ? settings.openZoomLevel*6 : width-scroll.width
    cellHeight: settings.openDefaultView=="icons" ? settings.openZoomLevel*6 : settings.openZoomLevel*2
    Behavior on cellWidth { NumberAnimation { id: cellWidthAni; duration: 125; } }
    Behavior on cellHeight { NumberAnimation { id: cellHeightAni; duration: 125; } }

    PQMouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.RightButton
        onClicked: {
            rightclickmenu_bg.popup()
        }
    }

    PQRightClickMenu {
        id: rightclickmenu_bg
        isFolder: false
        isFile: false
    }

    delegate: Item {

        width: files_grid.cellWidth
        height: files_grid.cellHeight

        Rectangle {

            id: deleg_container

            width: files_grid.cellWidth
            height: files_grid.cellHeight

            // these anchors make sure the item falls back into place after being dropped
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            property bool mouseInside: false
            color: fileIsDir
                       ? (currentlyHoveredIndex==index ? "#44888899" : "#44222233")
                       : (currentlyHoveredIndex==index ? "#44aaaaaa" : "#44444444")

            border.width: 1
            border.color: "#282828"

            Behavior on color { ColorAnimation { duration: 200 } }

            Image {

                id: fileicon

                x: 5
                y: 5
                width: settings.openDefaultView=="icons" ? parent.width-10 : parent.height-10
                height: parent.height-10

                asynchronous: true

                Behavior on width { NumberAnimation { duration: 100 } }
                Behavior on height { NumberAnimation { duration: 100 } }

                opacity: currentlyHoveredIndex==index ? 1 : 0.6
                Behavior on opacity { NumberAnimation { duration: 200 } }

                source: fileName==".."||filethumb.status==Image.Ready ? "" : "image://icon/" + (fileIsDir ? "folder" : "image")

                Text {
                    id: numberOfFilesInsideFolder
                    visible: settings.openDefaultView=="icons" && fileIsDir
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
                    visible: !fileIsDir

                    cache: false

                    sourceSize: Qt.size(256, 256)

                    fillMode: Image.PreserveAspectFit

                    // mipmap does not look good, use only smooth
                    smooth: true
                    asynchronous: true

                    source: (fileIsDir||!settings.openThumbnails) ? "" : ("image://thumb/" + filePath)

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
                height: fileName==".." ? parent.height : parent.height/2
                y: parent.height-height

                opacity: settings.openDefaultView=="icons" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                color: "#66000000"

                Text {

                    width: parent.width-20
                    height: fileName==".." ? parent.height-20 : parent.height
                    x: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    text: decodeURIComponent(fileName)
                    maximumLineCount: 2
                    elide: Text.ElideMiddle
                    wrapMode: Text.Wrap

                    font.pointSize: fileName==".." ? 20 : 10


                }

            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: fileName == ".." ? fileicon.width/2 : fileicon.width+10

                opacity: settings.openDefaultView=="list" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                verticalAlignment: Text.AlignVCenter

                font.bold: true //fileName == ".."

                color: "white"
                text: decodeURIComponent(fileName)
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
                visible: settings.openDefaultView=="list"
                color: "white"
                font.bold: true
                text: fileIsDir ? "" : handlingFileDialog.convertBytesToHumanReadable(fileSize)

            }

            PQMouseArea {

                id: mouseArea

                anchors.fill: parent
                anchors.leftMargin: settings.openDefaultView=="list"?fileicon.width:0

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                tooltip: (fileIsDir ?

                          ("<b><span style=\"font-size: x-large\">" + fileName + "</span></b><br><br>" +
                           (numberOfFilesInsideFolder.text=="" ? "" : (em.pty+qsTranslate("filedialog", "# images")+": <b>" + numberOfFilesInsideFolder.text + "</b><br>")) +
                           em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fileModified.toLocaleDateString() + "</b><br>" +
                           em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fileModified.toLocaleTimeString() + "</b>") :

                          ("<tr><td><img src=\"image://thumb/" + filePath + "\"></td><td>&nbsp;&nbsp;</td>" +
                           "<td valign=middle><b><span style=\"font-size: x-large\">" + fileName + "</span></b>" + "<br><br>" +
                           em.pty+qsTranslate("filedialog", "File size:")+" <b>" + filesizenum.text + "</b><br>" +
                           em.pty+qsTranslate("filedialog", "File type:")+" <b>" + handlingFileDialog.getFileType(filePath) + "</b><br>" +
                           em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fileModified.toLocaleDateString() + "</b><br>" +
                           em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fileModified.toLocaleTimeString()+ "</b></td></tr>"))

                acceptedButtons: Qt.LeftButton|Qt.RightButton

                onEntered:
                    currentlyHoveredIndex = index
                onExited:
                    currentlyHoveredIndex = -1
                onClicked: {
                    if(mouse.button == Qt.LeftButton) {
                        if(fileIsDir)
                            filedialog_top.setCurrentDirectory(filePath)
                        else {
                            hideFileDialog()
                            imageitem.loadImage(filePath)
                        }
                    } else {
                        rightclickmenu.popup()
                    }
                }
            }

            PQRightClickMenu {
                id: rightclickmenu
                isFolder: fileIsDir
                isFile: !fileIsDir
                path: filePath
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
                if(fileIsDir && fileName != "..") {
                    handlingFileDialog.getNumberOfFilesInFolder(filePath, function(count) {
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

            if(modifiers == Qt.NoModifier) {
                if(currentlyHoveredIndex == -1)
                    currentlyHoveredIndex = 0
                else if(currentlyHoveredIndex < model.count-1)
                    currentlyHoveredIndex += 1
            } else if(modifiers == Qt.ControlModifier)
                currentlyHoveredIndex = model.count-1

        } else if(key == Qt.Key_Up) {

            if(modifiers == Qt.NoModifier) {
                if(currentlyHoveredIndex == -1)
                    currentlyHoveredIndex = model.count-1
                else if(currentlyHoveredIndex > 0)
                    currentlyHoveredIndex -= 1
            } else if(modifiers == Qt.ControlModifier)
                currentlyHoveredIndex = 0
            else if(modifiers == Qt.AltModifier && handlingFileDialog.cleanPath(filedialog_top.currentDirectory) != "/")
                filedialog_top.setCurrentDirectory(filedialog_top.currentDirectory+"/..")

        } else if(key == Qt.Key_Left) {

            if(modifiers == Qt.AltModifier)
                breadcrumbs.goBackwards()
            else if(modifiers == Qt.NoModifier) {
                if(currentlyHoveredIndex == -1)
                    currentlyHoveredIndex = model.count-1
                else if(currentlyHoveredIndex > 0)
                    currentlyHoveredIndex -= 1
            }


        } else if(key == Qt.Key_Right) {

            if(modifiers == Qt.AltModifier)
                breadcrumbs.goForwards()
            else if(modifiers == Qt.NoModifier) {
                if(currentlyHoveredIndex == -1)
                    currentlyHoveredIndex = 0
                else if(currentlyHoveredIndex < model.count-1)
                    currentlyHoveredIndex += 1
            }

        } else if(key == Qt.Key_PageUp && modifiers == Qt.NoModifier)

            currentlyHoveredIndex = Math.max(currentlyHoveredIndex-5, 0)

        else if(key == Qt.Key_PageDown && modifiers == Qt.NoModifier)

            currentlyHoveredIndex = Math.min(currentlyHoveredIndex+5, files_model.count-1)

        else if((key == Qt.Key_Enter || key == Qt.Key_Return) && modifiers == Qt.NoModifier) {

            var filePath = files_model.getFilePath(currentlyHoveredIndex)
            var fileIsDir = files_model.getFileIsDir(currentlyHoveredIndex)
            if(fileIsDir)
                filedialog_top.setCurrentDirectory(filePath)
            else {
                hideFileDialog()
                imageitem.loadImage(filePath)
            }


        } else if((key == Qt.Key_Plus || key == Qt.Key_Equal) && modifiers == Qt.ControlModifier)

            tweaks.zoomIn()

        else if(key == Qt.Key_Minus && modifiers == Qt.ControlModifier)

            tweaks.zoomOut()

        else if((key == Qt.Key_H && modifiers == Qt.ControlModifier) || (key == Qt.Key_Period && modifiers == Qt.AltModifier)) {

            var old = settings.openShowHiddenFilesFolders
            settings.openShowHiddenFilesFolders = !old

        } else if(key == Qt.Key_Escape && modifiers == Qt.NoModifier)

            filedialog_top.hideFileDialog()

        else {

            var tmp = (currentlyHoveredIndex==-1 ? 0 : currentlyHoveredIndex+1)
            var foundSomething = false

            for(var i = tmp; i < files_model.count; ++i) {

                if(handlingFileDialog.convertCharacterToKeyCode(files_model.getFileName(i)[0]) == key) {
                    currentlyHoveredIndex = i
                    foundSomething = true
                    break;
                }

            }

            if(!foundSomething) {

                for(var i = 0; i < tmp; ++i) {

                    if(handlingFileDialog.convertCharacterToKeyCode(files_model.getFileName(i)[0]) == key) {
                        currentlyHoveredIndex = i
                        foundSomething = true
                        break;
                    }

                }

            }

        }

    }

    Component.onCompleted:
        loadFolder(filedialog_top.currentDirectory)

    function loadFolder(loc) {

        loc = handlingFileDialog.cleanPath(loc)

        files_model.folder = loc
        currentlyHoveredIndex = -1

        if(loc == "/")
            breadcrumbs.pathParts = [""]
        else
            breadcrumbs.pathParts = loc.split("/")

    }

    Connections {
        target: filedialog_top
        onCurrentDirectoryChanged:
            loadFolder(filedialog_top.currentDirectory)
    }

}
