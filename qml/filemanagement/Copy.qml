import QtQuick 2.6
import QtQuick.Dialogs 1.3
import PFileDialog 1.0
import "../loadfile.js" as Load

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
        onItemShown:
            filedialog.getFilename("Copy Image to...", variables.currentDir + "/" +  variables.currentFile)
        onItemHidden:
            filedialog.close()
    }

    PFileDialog {
        id: filedialog
        onAccepted: {
            getanddostuff.copyImage(variables.currentDir + "/" + variables.currentFile, file)
            if(getanddostuff.removeFilenameFromPath(file) == variables.currentDir) {
                Load.loadFile(file, variables.filter, true)
            }
            call.hide("filemanagement")
        }
        onRejected:
            call.hide("filemanagement")
    }

}
