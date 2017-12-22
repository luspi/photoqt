import QtQuick 2.6
import QtQuick.Dialogs 1.3

Item {

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: container.height

    Text {
        width: parent.width
        height: parent.height
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("Use the file dialog to select a destination location.")
        color: colour.bg_label
        font.bold: true
        font.pointSize: 20
    }

    Connections {
        target: container
        onItemShown: {
            if(!filedialog.visible) {
                filedialog.folder = "file://" + variables.currentDir
                filedialog.open()
            }
        }
        onItemHidden:
            filedialog.close()
    }

    FileDialog {
        id: filedialog
        title: qsTr("Select destination")
        nameFilters: [ "Image (*." + getanddostuff.getImageSuffix(variables.currentPath + "/" + variables.currentFile) + ")" ]
        modality: Qt.NonModal
        onAccepted: {
            getanddostuff.copyImage(variables.currentDir + "/" + variables.currentFile, filedialog.fileUrl)
        }
        onRejected: {
            call.hide("filemanagement")
        }
    }

}
