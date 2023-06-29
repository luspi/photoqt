import QtQuick

Item {
    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height

    GridView {

        id: view

        anchors.fill: parent
        anchors.margins: 1

        model: PQCFileFolderModel.countFoldersFileDialog + PQCFileFolderModel.countFilesFileDialog

        cellWidth: 200
        cellHeight: 200

        delegate: Item {

            width: view.cellWidth
            height: view.cellHeight

            Item {

                anchors.fill: parent

                Image {

                    id: fileicon

                    x: 1
                    y: 1
                    width: view.cellHeight-2
                    height: view.cellHeight-2
                    sourceSize: Qt.size(width,height)

                    source: ("image://icon/"+(index < PQCFileFolderModel.countFoldersFileDialog
                                ? "folder"
                                : PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.entriesFileDialog[index])))

                }

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

                    source: visible ? ("image://thumb/" + PQCFileFolderModel.entriesFileDialog[index]) : ""

                    onStatusChanged: {
                        if(status == Image.Ready) {
                            fileicon.source = ""
                        }
                    }

                }

            }

        }

    }
}
