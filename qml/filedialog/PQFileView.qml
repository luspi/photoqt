import QtQuick
import QtQuick.Controls
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
            currentFolderExcluded = PQCScriptsFilesPaths.isExcludeDirFromCaching(PQCFileFolderModel.folderFileDialog)
            view.model = PQCFileFolderModel.countAllFileDialog
            // to have no item pre-selected when a new folder is loaded we need to set the currentIndex to -1 AFTER the model is set
            // (re-)setting the model will always reset the currentIndex to 0
            currentIndex = -1
        }
    }
    Component.onCompleted:
        model = PQCFileFolderModel.countAllFileDialog

    property var currentSelection: []
    onCurrentSelectionChanged:
        currentFileSelected = (currentSelection.indexOf(currentIndex)!==-1)

    property var currentCuts: []

    property bool currentFileSelected: false

    property alias fileviewContextMenu: contextmenu

    property bool showGrid: PQCSettings.filedialogLayout==="icons"

    property bool currentFolderExcluded: false

    property int currentFolderThumbnailIndex: -1

    cellWidth: showGrid ? 50 + PQCSettings.filedialogZoom*3 : width
    cellHeight: showGrid ? 50 + PQCSettings.filedialogZoom*3 : 15 + PQCSettings.filedialogZoom
    clip: true

    // reset index to -1 if no other item has been hovered in the meantime
    Timer {
        id: resetCurrentIndex
        property int oldIndex
        interval: 100
        onTriggered: {
            if(!contextmenu.visible) {
                if(oldIndex === view.currentIndex)
                    view.currentIndex = -1
            } else {
                if(oldIndex === contextmenu.setCurrentIndexToThisAfterClose)
                    contextmenu.setCurrentIndexToThisAfterClose = -1
            }
        }
    }

    PQPreview {
        z: -1
    }

    PQTextL {
        anchors.fill: parent
        anchors.margins: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        enabled: false
        visible: PQCFileFolderModel.countAllFileDialog===0
        text: "no supported files/folders found"
    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton|Qt.LeftButton

        // this allows us to catch any right click no matter where it happens
        // AND still react to onEntered/Exited events for each individual delegate
        enabled: view.currentIndex===-1
        visible: view.currentIndex===-1

        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton) {
                contextmenu.path = ""
                contextmenu.popup()
            } else {
                view.currentSelection = []
            }
        }
        onPositionChanged: {
            if(fd_breadcrumbs.topSettingsMenu.visible)
                return
            var ind = view.indexAt(mouseX, view.contentY+mouseY)
            if(contextmenu.visible)
                contextmenu.setCurrentIndexToThisAfterClose = ind
            else
                view.currentIndex = ind
        }
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
        property int padding: PQCSettings.filedialogElementPadding

        Item {

            anchors.fill: parent

            /************************************************************/
            // ICONS/THUMBNAILS

            Item {
                id: dragHandler
                x: deleg.padding
                y: deleg.padding
                width: view.cellHeight-2*deleg.padding
                height: view.cellHeight-2*deleg.padding
            }

            // the file type icon
            Image {

                id: fileicon

                x: deleg.padding
                y: deleg.padding
                width: view.cellHeight-2*deleg.padding
                height: view.cellHeight-2*deleg.padding
                sourceSize: Qt.size(width,height)

                smooth: true
                mipmap: false

                opacity: deleg.currentFileCut ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                property string sourceString: ("image://icon/"+(index < PQCFileFolderModel.countFoldersFileDialog
                                                    ? (view.showGrid ? "folder" : "folder_listicon")
                                                    : PQCScriptsFilesPaths.getSuffix(deleg.currentPath)))

                source: sourceString

            }

            // the file thumbnail
            Image {

                id: filethumb

                x: deleg.padding
                y: deleg.padding
                width: view.cellHeight-2*deleg.padding
                height: view.cellHeight-2*deleg.padding

                visible: index >= PQCFileFolderModel.countFoldersFileDialog && PQCSettings.filedialogThumbnails && !currentFolderExcluded

                opacity: deleg.currentFileCut ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                smooth: true
                mipmap: false
                asynchronous: true
                cache: false
                sourceSize: Qt.size(width,height)

                fillMode: PQCSettings.filedialogThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit

                source: visible ? ("image://thumb/" + deleg.currentPath) : ""
                onSourceChanged: {
                    if(!visible)
                        fileicon.source = fileicon.sourceString
                }

                onStatusChanged: {
                    if(status == Image.Ready) {
                        fileicon.source = ""
                    }
                }

            }

            // the folder thumbnails
            Item {

                id: folderthumb

                x: deleg.padding
                y: deleg.padding
                width: view.cellHeight-2*deleg.padding
                height: view.cellHeight-2*deleg.padding

                visible: PQCSettings.filedialogFolderContentThumbnails

                property int curnum: 0
                onCurnumChanged: {
                    if(index === view.currentIndex)
                        currentFolderThumbnailIndex = folderthumb.curnum
                }

                signal hideExcept(var n)

                Repeater {
                    model: ListModel { id: folderthumb_model }
                    delegate: Image {
                        id: folderdeleg
                        anchors.fill: folderthumb
                        source: "image://folderthumb/" + folder + ":://::" + num
                        smooth: true
                        mipmap: false
                        fillMode: PQCSettings.filedialogFolderContentThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                        onStatusChanged: {
                            if(status == Image.Ready) {
                                if((curindex === view.currentIndex || PQCSettings.filedialogFolderContentThumbnailsAutoload) && !mousearea.drag.active)
                                    folderthumb_next.restart()
                                folderthumb.hideExcept(num)
                            }
                        }
                        Connections {
                            target: folderthumb
                            function onHideExcept(n) {
                                if(n !== num) {
                                    folderdeleg.source = ""
                                }
                            }
                        }
                    }
                }

                Timer {
                    id: folderthumb_next
                    interval: PQCSettings.filedialogFolderContentThumbnailsSpeed===1
                                    ? 2000
                                    : (PQCSettings.filedialogFolderContentThumbnailsSpeed===2
                                            ? 1000
                                            : 500)
                    running: false||PQCSettings.filedialogFolderContentThumbnailsAutoload
                    onTriggered: {
                        if(!PQCSettings.filedialogFolderContentThumbnails)
                            return
                        if(index >= PQCFileFolderModel.countFoldersFileDialog)// || handlingFileDir.isExcludeDirFromCaching(filefoldermodel.entriesFileDialog[index]))
                            return
                        if(deleg.numberFilesInsideFolder == 0)
                            return
                        if((view.currentIndex===index || PQCSettings.filedialogFolderContentThumbnailsAutoload) && (PQCSettings.filedialogFolderContentThumbnailsLoop || folderthumb.curnum == 0)) {
                            folderthumb.curnum = folderthumb.curnum%deleg.numberFilesInsideFolder +1
                            folderthumb_model.append({"folder": PQCFileFolderModel.entriesFileDialog[index], "num": folderthumb.curnum, "curindex": index})
                        }
                    }
                }
                Connections {
                    target: view
                    function onCurrentIndexChanged() {
                        if(view.currentIndex===index && !PQCSettings.filedialogFolderContentThumbnailsAutoload)
                            folderthumb_next.restart()
                    }
                }

            }

            /************************************************************/
            // meta information

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
                visible: view.showGrid && numberOfFilesInsideFolder.text !== "" && numberOfFilesInsideFolder.text !== "0"

                PQText {
                    id: numberOfFilesInsideFolder
                    x: 10
                    y: (parent.height-height)/2-2
                    font.weight: PQCLook.fontWeightBold
                    elide: Text.ElideMiddle
                    text: deleg.numberFilesInsideFolder
                }
            }

            // which # thumbnail inside folder
            Rectangle {
                id: numberThumbInsideFolderCont
                x: (deleg.width-width)/2
                y: 10
                width: numberThumbInsideFolder.width + 10
                height: 20
                radius: 3
                color: "#000000"
                opacity: 0.6
                visible: view.showGrid && folderthumb.curnum>0 && folderthumb.visible

                PQTextS {
                    id: numberThumbInsideFolder
                    x: 5
                    y: (parent.height-height)/2-2
                    font.weight: PQCLook.fontWeightBold
                    elide: Text.ElideMiddle
                    text: "#"+folderthumb.curnum
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


            /************************************************************/
            // FILE NAME/SIZE


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

                Image {
                    x: (parent.width-width-2)
                    y: (parent.height-height-2)
                    source: "/white/folder.svg"
                    height: 10
                    mipmap: true
                    width: height
                    opacity: 0.75
                    visible: index < PQCFileFolderModel.countFoldersFileDialog && folderthumb.curnum>0
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

            /************************************************************/
            // HIGHLIGHT/SELECT

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

            /************************************************************/

            // mouse area handling mouse events
            PQMouseArea {

                id: mousearea

                anchors.fill: parent
                anchors.leftMargin: view.showGrid ? 0 : fileicon.width

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                tooltipReference: fd_splitview

                acceptedButtons: Qt.LeftButton|Qt.RightButton

                drag.target: PQCSettings.filedialogDragDropFileview ? dragHandler : undefined

                drag.onActiveChanged: {
                    if(mousearea.drag.active) {
                        // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                        fd_places.dragItemIndex = index
                        fd_places.dragReordering = false
                        fd_places.dragItemId = deleg.currentPath
                    }
                    deleg.Drag.drop();
                    if(!mousearea.drag.active) {
                        // reset variables used for drag/drop
                        fd_places.dragItemIndex = -1
                        fd_places.dragItemId = ""
                    }
                }

                onEntered: {
                    if(fd_breadcrumbs.topSettingsMenu.visible)
                        return

                    if(!contextmenu.visible)
                        view.currentIndex = index
                    else
                        contextmenu.setCurrentIndexToThisAfterClose = index

                    // we reset the tooltip everytime it is requested as some info/thumbnails might have changed/updated since last time

                    if(PQCSettings.filedialogDetailsTooltip) {

                        var fmodi = PQCScriptsFilesPaths.getFileModified(deleg.currentPath)
                        var ftype = PQCScriptsFilesPaths.getFileType(deleg.currentPath)

                        var str = ""

                        if(index < PQCFileFolderModel.countFoldersFileDialog) {

                            if(!currentFolderExcluded && PQCSettings.filedialogFolderContentThumbnails && deleg.numberFilesInsideFolder>0) {
                                // when a folder is hovered before a thumbnail inside is loaded, this will result in an empty image
                                var n = folderthumb.curnum
                                if(n == 0 && deleg.numberFilesInsideFolder > 0)
                                    n = 1
                                str += "<img width=256 src=\"image://folderthumb/" + deleg.currentPath + ":://::" + n + "\"><br><br>"
                            }

                            str += "<span style='font-size: " + PQCLook.fontSizeL + "pt; font-weight: bold'>" + deleg.currentFile + "</span><br><br>" +
                                   (deleg.numberFilesInsideFolder==0 ? "" : (qsTranslate("filedialog", "# images")+": <b>" + deleg.numberFilesInsideFolder + "</b><br>")) +
                                    qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                    qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString() + "</b>"

                            text = str

                        } else {

                            str = "<table><tr>"

                            // if we do not cache this directory, we do not show a thumbnail image
                            if(!currentFolderExcluded && filethumb.status == Image.Ready && PQCSettings.filedialogThumbnails) {
                                str += "<td valign=middle><img width=256 src=\"image://tooltipthumb/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.currentPath) + "\"></td>"
                                str += "<td>&nbsp;</td>"
                            }

                            // This breaks the filename into multiple lines if it is too long
                            var usefilename = [deleg.currentFile]
                            var lim = 35
                            if(deleg.currentFile.length > lim) {
                                // this helps to avoid having one very long line and one line with almost nothing
                                if(deleg.currentFile.length%lim < 5)
                                    lim -= 2
                                usefilename = []
                                for(var i = 0; i <= deleg.currentFile.length; i += lim)
                                    usefilename.push(deleg.currentFile.substring(i, i+lim))
                            }

                            // add details
                            str += "<td valign=middle>";
                            for(var f in usefilename) {
                                str += "<div style='font-size: " + PQCLook.fontSizeL + "pt; font-weight: bold'>" + usefilename[f] + "</div>"
                            }
                            str += "<br><br>" +
                                      qsTranslate("filedialog", "File size:")+" <b>" + fileinfo.text + "</b><br>" +
                                      qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                                      qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                      qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b></td></tr></table>"

                            text = str

                            // if the thumbnail is not yet loaded and a temp icon is shown, we want to check again for the thumbnail the next time the tooltip is shown

                        }

                    } else if(!PQCSettings.filedialogDetailsTooltip) {

                        text = ""

                    }

    //                if(!currentIndexChangedUsingKeyIgnoreMouse)
    //                    files_grid.currentIndex = index

                }

                onExited: {
                    resetCurrentIndex.oldIndex = index
                    resetCurrentIndex.restart()
                }

                onClicked: (mouse) => {
                    if(mouse.button === Qt.RightButton) {
                        contextmenu.path = deleg.currentPath
                        contextmenu.setCurrentIndexToThisAfterClose = index
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

            Drag.active: mousearea.drag.active
            Drag.mimeData: {
                "text/uri-list": "file://"+deleg.currentPath
            }
            Drag.dragType: Drag.Automatic
            Drag.imageSource: "image://dragthumb/" + deleg.currentPath

            Drag.onDragFinished: {
                console.log(x, y, parent.x, parent.y)
            }

            Connections {
                target: view
                function onCurrentCutsChanged() {
                    deleg.currentFileCut = (view.currentCuts.indexOf(deleg.currentPath)!==-1)
                }
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

        property int setCurrentIndexToThisAfterClose: -1
        onVisibleChanged: {
            if(!visible && setCurrentIndexToThisAfterClose != -2) {
                view.currentIndex = setCurrentIndexToThisAfterClose
                setCurrentIndexToThisAfterClose = -2
            }
        }

        Connections {
            target: filedialog_top
            function onOpacityChanged() {
                if(filedialog_top.opacity !== 1)
                    contextmenu.close()
            }
        }

        PQMenuItem {
            enabled: contextmenu.isFile || contextmenu.isFolder
            text: (contextmenu.isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file"))
            onTriggered: {
                if(contextmenu.isFolder)
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
            onTriggered: {
                PQCScriptsFileDialog.addPlacesEntry(contextmenu.path, fd_places.entries_favorites.length)
                fd_places.loadPlaces()
            }
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
