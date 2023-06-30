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
                x: deleg.width-width-10
                height: deleg.height
                verticalAlignment: Text.AlignVCenter
                text: ""
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

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            property bool tooltipSetup: false
            tooltipReference: fd_splitview

            onEntered: {
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
                            str += "<td><img width=256 src=\"image://tooltipthumb/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.currentPath) + "\"></td>"

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
                resetCurrentIndex.oldIndex = index
                resetCurrentIndex.restart()
            }

            onClicked: (mouse) => {
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

    }

}
