import QtQuick.Dialogs 1.3

MessageDialog {

    id: top

    title: ""
    text: ""
    standardButtons: StandardButton.Yes|StandardButton.No

    modality: Qt.WindowModal

    property bool confirmed: false

    onYes: {
        confirmed = true
    }
    onNo: {
        confirmed = false
    }

    function askForConfirmation(text, informativeText) {
        top.text = text
        top.informativeText = informativeText
        top.open()
    }

}
