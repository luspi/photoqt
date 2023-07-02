import QtQuick
import "../elements"

GridView {

    id: view

    y: 1
    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height-2

    model: 0
    // we need to do all the below as otherwise loading a folder with the same number of items as the previous one would not reload the model
    Connections {
        target: PQCFileFolderModel
        function onNewDataLoadedFileDialog() {
            view.model = 0
            view.model = PQCFileFolderModel.countAllFileDialog
        }
    }
    Component.onCompleted:
        model = PQCFileFolderModel.countAllFileDialog

    property var currentSelection: []
    onCurrentSelectionChanged:
        currentFileSelected = (currentSelection.indexOf(currentIndex)!==-1)

    property var currentCuts: []

    property bool currentFileSelected: false


    property bool showGrid: PQCSettings.filedialogDefaultView==="icons"

    cellWidth: showGrid ? 50 + PQCSettings.filedialogZoom*3 : width
    cellHeight: showGrid ? 50 + PQCSettings.filedialogZoom*3 : 15 + PQCSettings.filedialogZoom
    clip: true

    // reset index to -1 if no other item has been hovered in the meantime
    Timer {
        id: resetCurrentIndex
        property int oldIndex
        interval: 200
        onTriggered: {
            if(oldIndex === view.currentIndex)
                view.currentIndex = -1
        }
    }

    PQPreview {
        z: -1
    }

    // each entry in the list or icon view
    delegate: Rectangle {

        id: deleg

        width: view.cellWidth
        height: view.cellHeight

        color: PQCLook.transColorAccent
        border.color: PQCLook.baseColor
        border.width: 1

        property string currentPath: PQCFileFolderModel.entriesFileDialog[index]
        property string currentFile: decodeURIComponent(PQCScriptsFilesPaths.getFilename(currentPath))
        property int numberFilesInsideFolder: 0
        property bool currentFileCut: false

        Item {

            anchors.fill: parent

            // the file type icon
            Image {

                id: fileicon

                x: 1
                y: 1
                width: view.cellHeight-2
                height: view.cellHeight-2
                sourceSize: Qt.size(width,height)

                opacity: deleg.currentFileCut ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                source: ("image://icon/"+(index < PQCFileFolderModel.countFoldersFileDialog
                            ? (view.showGrid ? "folder" : "folder_listicon")
                            : PQCScriptsFilesPaths.getSuffix(deleg.currentPath)))

            }

            // the file thumbnail
            Image {

                id: filethumb

                x: 1
                y: 1
                width: view.cellHeight-2
                height: view.cellHeight-2

                visible: index >= PQCFileFolderModel.countFoldersFileDialog && PQCSettings.filedialogThumbnails

                opacity: deleg.currentFileCut ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                smooth: true
                asynchronous: true
                cache: false
                sourceSize: Qt.size(512,512)

                fillMode: PQCSettings.filedialogThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit

                source: visible ? ("image://thumb/" + deleg.currentPath) : ""

                onStatusChanged: {
                    if(status == Image.Ready) {
                        fileicon.source = ""
                    }
                }

            }

            // how many files inside folder
            Rectangle {
                id: numberOfFilesInsideFolder_cont
                x: (deleg.width-width)-5
                y: 5
                width: numberOfFilesInsideFolder.width + 20
                height: 30
                radius: 5
                color: "#000000"
                opacity: 0.8
                visible: view.showGrid && numberOfFilesInsideFolder.text != "" && numberOfFilesInsideFolder.text != "0"

                PQText {
                    id: numberOfFilesInsideFolder
                    x: 10
                    y: (parent.height-height)/2-2
                    font.weight: PQCLook.fontWeightBold
                    elide: Text.ElideMiddle
                    text: deleg.numberFilesInsideFolder
                }
            }

            // load async for files
            Timer {
                running: index>=PQCFileFolderModel.countFoldersFileDialog
                interval: 1
                onTriggered: {
                    fileinfo.text = PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.currentPath)
                }
            }

            // load async for folders
            Timer {
                running: index < PQCFileFolderModel.countFoldersFileDialog
                interval: 1
                onTriggered: {
                    PQCScriptsFileDialog.getNumberOfFilesInFolder(deleg.currentPath, function(count) {
                        if(count > 0) {
                            deleg.numberFilesInsideFolder = count
                            fileinfo.text = count===1 ? qsTranslate("filedialog", "%1 image").arg(count) : qsTranslate("filedialog", "%1 images").arg(count)
                            if(count === 1)
                                fileinfo.text = qsTranslate("filedialog", "%1 image").arg(count)
                            else
                                fileinfo.text = qsTranslate("filedialog", "%1 images").arg(count)
                        }
                    })
                }
            }



            // the filename - icon view
            Rectangle {
                visible: view.showGrid
                width: parent.width
                height: parent.height/4
                y: parent.height-height
                color: "#cc2f2f2f"

                PQText {
                    id: filename
                    anchors.fill: parent
                    anchors.margins: 5
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    elide: Text.ElideMiddle
                    text: deleg.currentFile
                }

            }

            // the filename - list view
            PQText {
                visible: !view.showGrid
                opacity: deleg.currentFileCut ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }
                x: fileicon.width+10
                width: deleg.width-fileicon.width-10
                height: deleg.height
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                text: filename.text
            }

            // the file size/number of images
            PQText {
                id: fileinfo
                visible: !view.showGrid
                opacity: deleg.currentFileCut ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }
                x: deleg.width-width-10
                height: deleg.height
                verticalAlignment: Text.AlignVCenter
                text: ""
            }

            // cutting an item
            Rectangle {

                id: cutindicator
                anchors.fill: parent
                color: "#44ffffff"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0

            }

            // hovering an item
            Rectangle {

                anchors.fill: parent
                color: "#22ffffff"
                opacity: view.currentIndex==index ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0

            }

            // selecting an item
            Rectangle {

                anchors.fill: parent
                color: "#88ffffff"
                opacity: view.currentSelection.indexOf(index)==-1 ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0

            }

        }

        // mouse area handling mouse events
        PQMouseArea {

            anchors.fill: parent
            anchors.leftMargin: view.showGrid ? 0 : fileicon.width

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            property bool tooltipSetup: false
            tooltipReference: fd_splitview

            acceptedButtons: Qt.LeftButton|Qt.RightButton

            onEntered: {
                if(!contextmenu.visible)
                    view.currentIndex = index

                if(!tooltipSetup) {

                    var fmodi = PQCScriptsFilesPaths.getFileModified(deleg.currentPath)
                    var ftype = PQCScriptsFilesPaths.getFileType(deleg.currentPath)

                    var str = ""

                    if(index < PQCFileFolderModel.countFoldersFileDialog) {

//                        if(PQCSettings.filedialogFolderContentThumbnails)
//                            str += "<img src=\"image://folderthumb/" + filefoldermodel.entriesFileDialog[index] + ":://::" + folderthumbs.curnum + "\"><br><br>"

                        str += "<span style='font-size: " + PQCLook.fontSizeL + "pt; font-weight: bold'>" + deleg.currentFile + "</span><br><br>" +
                               (deleg.numberFilesInsideFolder==0 ? "" : (qsTranslate("filedialog", "# images")+": <b>" + deleg.numberFilesInsideFolder + "</b><br>")) +
                                qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString() + "</b>"

                        text = str
                        tooltipSetup = true

                    } else {

                        str = "<table><tr>"

                        // if we do not cache this directory, we do not show a thumbnail image
                        if(filethumb.status == Image.Ready)
                            str += "<td valign=middle><img width=256 src=\"image://tooltipthumb/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.currentPath) + "\"></td>"

                        str += "<td>&nbsp;</td>"

                        // add details
                        str += "<td valign=middle><span style='font-size: " + PQCLook.fontSizeL + "pt; font-weight: bold'>" + deleg.currentFile + "</span>" + "<br><br>" +
                                  qsTranslate("filedialog", "File size:")+" <b>" + fileinfo.text + "</b><br>" +
                                  qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                                  qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                  qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b></td></tr></table>"

                        text = str

                        // if the thumbnail is not yet loaded and a temp icon is shown, we want to check again for the thumbnail the next time the tooltip is shown
//                        if(currentFolderExcluded || (!currentFolderExcluded && fileicon.source == ""))
                            tooltipSetup = true

                    }

                }

//                if(!currentIndexChangedUsingKeyIgnoreMouse)
//                    files_grid.currentIndex = index

            }

            onExited: {
                if(!contextmenu.visible) {
                    resetCurrentIndex.oldIndex = index
                    resetCurrentIndex.restart()
                }
            }

            onClicked: (mouse) => {
                if(mouse.button === Qt.RightButton) {
                    contextmenu.path = deleg.currentPath
                    contextmenu.popup()
                    return
                }

                if(mouse.modifiers & Qt.ControlModifier) {
                    if(view.currentSelection.indexOf(index) != -1) {
                        view.currentSelection = view.currentSelection.filter(item => item!==index)
                    } else {
                        view.currentSelection.push(index)
                        view.currentSelectionChanged()
                    }
                } else {
                    if(index < PQCFileFolderModel.countFoldersFileDialog)
                        filedialog_top.loadNewPath(deleg.currentPath)

                    view.currentSelection = []
                }
            }

        }

        // mouse area to drag entries to user places
        // this is only enabled for list view
        PQMouseArea {

            id: dragArea

            width: fileicon.width
            height: deleg.height

            drag.target: deleg

            hoverEnabled: true
            text: qsTranslate("filedialog", "Click and drag to favorites")

            cursorShape: Qt.OpenHandCursor

            onPressed:
                cursorShape = Qt.ClosedHandCursor
            onReleased:
                cursorShape = Qt.OpenHandCursor

            drag.onActiveChanged: {
                if (dragArea.drag.active) {
                    dragArea.cursorShape = Qt.ClosedHandCursor
                    // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                    fd_places.dragItemIndex = index
                    fd_places.dragReordering = false
                    fd_places.dragItemId = deleg.currentPath
                }
                deleg.Drag.drop();
                if(!dragArea.drag.active) {
                    dragArea.cursorShape = Qt.OpenHandCursor
                    // reset variables used for drag/drop
                    fd_places.dragItemIndex = -1
                    fd_places.dragItemId = ""
                }
            }
        }

        Drag.active: dragArea.drag.active
        Drag.hotSpot.x: fileicon.width/2
        Drag.hotSpot.y: fileicon.height/2

        states: [
            State {
                // when drag starts, reparent entry to splitview
                when: deleg.Drag.active
                ParentChange {
                    target: deleg
                    parent: filedialog_top
                }
                // (temporarily) remove anchors
                AnchorChanges {
                    target: deleg
                    anchors.horizontalCenter: undefined
                    anchors.verticalCenter: undefined
                }
            }
        ]

        Connections {
            target: view
            function onCurrentCutsChanged() {
                console.log(view.currentCuts, deleg.currentPath)
                deleg.currentFileCut = (view.currentCuts.indexOf(deleg.currentPath)!==-1)
            }
        }

    }

    PQMenu {

        id: contextmenu

        property bool isFolder: false
        property bool isFile: false
        property string path: ""
        onPathChanged: {
            isFolder = PQCScriptsFilesPaths.isFolder(path)
            isFile = !isFolder
        }

        PQMenuItem {
            enabled: contextmenu.isFile || contextmenu.isFolder
            text: (contextmenu.isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file"))
            onTriggered: {
                if(isFolder)
                    filedialog_top.loadNewPath(contextmenu.path)
                else {
                    PQCFileFolderModel.setFileNameOnceReloaded = contextmenu.path
                    PQCFileFolderModel.fileInFolderMainView = contextmenu.path
                    filedialog_top.hide()
                }
            }
        }
        PQMenuItem {
            enabled: contextmenu.isFolder && PQCScriptsConfig.isPugixmlSupportEnabled()
            text: qsTranslate("filedialog", "Add to Favorites")
            onTriggered:
                PQCScriptsFileDialog.addPlacesEntry(contextmenu.path, fd_places.entries_favorites.length-1)
        }
        PQMenuSeparator { visible: contextmenu.isFile || contextmenu.isFolder }
        PQMenuItem {
            enabled: contextmenu.isFile || contextmenu.isFolder
            text: currentFileSelected ? qsTranslate("filedialog", "Remove file selection") : qsTranslate("filedialog", "Select file")
            onTriggered: {
                if(currentFileSelected) {
                    view.currentSelection = view.currentSelection.filter(item => item!==view.currentIndex)
                } else {
                    view.currentSelection.push(view.currentIndex)
                    view.currentSelectionChanged()
                }
            }
        }
        PQMenuItem {
            text: currentFileSelected ? qsTranslate("filedialog", "Remove all file selection") : qsTranslate("filedialog", "Select all files")
            onTriggered: {
                selectAll(!currentFileSelected)
            }
        }
        PQMenuSeparator { }
        PQMenuItem {
            enabled: !PQCScriptsConfig.amIOnWindows() && (contextmenu.isFile || contextmenu.isFolder || currentSelection.length)
            text: (currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder && currentSelection.length))
                        ? qsTranslate("filedialog", "Delete selection")
                        : (contextmenu.isFile ? qsTranslate("filedialog", "Delete file")
                                              : (contextmenu.isFolder ? qsTranslate("filedialog", "Delete folder")
                                                                      : qsTranslate("filedialog", "Delete file/folder")))
            onTriggered:
                deleteFiles()
        }
        PQMenuItem {
            enabled: (contextmenu.isFile || contextmenu.isFolder || currentSelection.length)
            text: (currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder && currentSelection.length))
                        ? qsTranslate("filedialog", "Cut selection")
                        : (contextmenu.isFile ? qsTranslate("filedialog", "Cut file")
                                              : (contextmenu.isFolder ? qsTranslate("filedialog", "Cut folder")
                                                                      : qsTranslate("filedialog", "Cut file/folder")))
            onTriggered:
                cutFiles()
        }
        PQMenuItem {
            enabled: (contextmenu.isFile || contextmenu.isFolder || currentSelection.length)
            text: (currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder && currentSelection.length))
                        ? qsTranslate("filedialog", "Copy selection")
                        : (contextmenu.isFile ? qsTranslate("filedialog", "Copy file")
                                              : (contextmenu.isFolder ? qsTranslate("filedialog", "Copy folder")
                                                                      : qsTranslate("filedialog", "Copy file/folder")))
            onTriggered:
                copyFiles()
        }
        PQMenuItem {
            id: menuitem_paste
            text: qsTranslate("filedialog", "Paste files from clipboard")
            onTriggered:
                pasteFiles()

            Component.onCompleted: {
                enabled = PQCScriptsClipboard.areFilesInClipboard()
            }
            Connections {
                target: PQCScriptsClipboard
                function onClipboardUpdated() {
                    menuitem_paste.enabled = PQCScriptsClipboard.areFilesInClipboard()
                }
            }
        }

        PQMenuSeparator { }

        PQMenuItem {
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders
            text: qsTranslate("filedialog", "Show hidden files")
            onTriggered:
                PQCSettings.filedialogShowHiddenFilesFolders = !PQCSettings.filedialogShowHiddenFilesFolders
        }
        PQMenuItem {
            checkable: true
            checked: PQCSettings.filedialogDetailsTooltip
            text: qsTranslate("filedialog", "Show tooltip with image details")
            onTriggered:
                PQCSettings.filedialogDetailsTooltip = !PQCSettings.filedialogDetailsTooltip
        }


    }

    function selectAll(select) {
        if(!select) {
            currentSelection = []
            return
        }
        currentSelection = [...Array(model).keys()]
    }

    function copyFiles() {
        currentCuts = []
        if(currentFileSelected || (currentIndex===-1 && currentSelection.length)) {
            var urls = []
            for(var key in currentSelection)
                urls.push(PQCFileFolderModel.entriesFileDialog[currentSelection[key]])
            PQCScriptsClipboard.copyFilesToClipboard(urls)
        } else {
            PQCScriptsClipboard.copyFilesToClipboard([PQCFileFolderModel.entriesFileDialog[currentIndex]])
        }
        currentSelection = []
    }

    function cutFiles() {

        var urls = []

        if(currentFileSelected || (currentIndex===-1 && currentSelection.length)) {
            for(var key in currentSelection)
                urls.push(PQCFileFolderModel.entriesFileDialog[currentSelection[key]])
        } else
            urls = [PQCFileFolderModel.entriesFileDialog[currentIndex]]
        PQCScriptsClipboard.copyFilesToClipboard(urls)
        currentCuts = urls

        currentSelection = []

    }

    function pasteFiles() {

        currentSelection = []

        var lst = PQCScriptsClipboard.getListOfFilesInClipboard()

        var nonexisting = []
        var existing = []

        for(var l in lst) {
            if(PQCScriptsFilesPaths.doesItExist(PQCFileFolderModel.folderFileDialog + "/" + PQCScriptsFilesPaths.getFilename(lst[l])))
                existing.push(lst[l])
            else
                nonexisting.push(lst[l])
        }

        if(existing.length > 0)
            pasteExisting.pasteExistingFiles(existing)

        if(nonexisting.length > 0) {
            for(var f in nonexisting) {
                var fln = nonexisting[f]
                if(PQCScriptsFileManagement.copyFileToHere(fln, PQCFileFolderModel.folderFileDialog)) {
                    if(cutFiles.indexOf(fln) !== -1)
                        PQCScriptsFileManagement.deletePermanent(fln)
                }
            }
            if(existing.length == 0)
                cutFiles = []
        }

        if(existing.length == 0 && nonexisting.length == 0)
            PQCScriptsOther.inform("Nothing found", "There are no files/folders in the clipboard.")

    }

    function deleteFiles() {

        if(!PQCScriptsOther.confirm("Move to Trash?", "Are you sure you want to move all selected files/folders to the trash?"))
            return

        if(currentFileSelected || (currentIndex===-1 && currentSelection.length)) {
            for(var key in currentSelection)
                PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.entriesFileDialog[currentSelection[key]])
        } else
            PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.entriesFileDialog[currentIndex])

    }

}
