import QtQuick
import "../elements"

Item {

    id: previewtop

    anchors.fill: parent

    // the background preview
    Image {

        id: preview

        anchors.fill: parent

        sourceSize: PQCSettings.filedialogPreviewHigherResolution ? Qt.size(width, height) : Qt.size(256,256)
        asynchronous: false
        fillMode: PQCSettings.filedialogPreviewCropToFit ? Image.PreserveAspectCrop : Image.PreserveAspectFit
        opacity: PQCSettings.filedialogPreviewMuted ? 0.5 : 1

        Timer {
            id: setBG
            interval: 250
            onTriggered:
                parent.setCurrentBG()
        }

        Connections {
            target: view
            function onCurrentIndexChanged(currentIndex) {
                setBG.restart()
            }
            function onCurrentFolderThumbnailIndexChanged(currentFolderThumbnailIndex) {
                setBG.restart()
            }
        }

        function setCurrentBG() {
            if(view.currentIndex === -1 || !PQCSettings.filedialogPreview || (view.currentIndex < PQCFileFolderModel.countFoldersFileDialog && view.currentFolderThumbnailIndex == -1)) {
                preview.source = ""
                return
            }
            if(view.currentIndex < PQCFileFolderModel.countFoldersFileDialog) {
                if(PQCSettings.filedialogFolderContentThumbnails)
                    preview.source = "image://folderthumb/" + PQCFileFolderModel.entriesFileDialog[view.currentIndex] + ":://::" + view.currentFolderThumbnailIndex
                else
                    preview.source = ""
            } else {
                if(PQCSettings.filedialogThumbnails)
                    preview.source = "image://thumb/" + PQCFileFolderModel.entriesFileDialog[view.currentIndex]
                else
                    preview.source = "image://icon/"+PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.entriesFileDialog[view.currentIndex])
            }
        }

    }
    // Starting with Qt 6.4 we use the MultiEffect module to set blur and/or saturation
    Loader {
        id: effectloader
        active: PQCScriptsConfig.isQtAtLeast6_4()
        sourceComponent:
            PQMultiEffect {
                parent: previewtop
                source: preview
                blurEnabled: true
                blurMax: 32
                blur: PQCSettings.filedialogPreviewBlur ? 1.0 : 0.0
                autoPaddingEnabled: false
                saturation: -1 + 0.1*PQCSettings.filedialogPreviewColorIntensity
                opacity: PQCSettings.filedialogPreviewMuted ? 0.5 : 1
            }
    }
    // pre Qt 6.4 the MultiEffect is not available yet
    Rectangle {
        visible: !effectloader.active
        anchors.fill: preview
        color: "#000000"
        opacity: 0.3+0.05*(10-PQCSettings.filedialogPreviewColorIntensity)
    }
}
