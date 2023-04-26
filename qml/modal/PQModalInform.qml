import QtQuick.Dialogs 1.3

MessageDialog {

    id: top

    title: ""
    text: ""
    standardButtons: StandardButton.Ok

    modality: Qt.WindowModal

    function informUser(title, text) {
        top.title = title
        top.text = text
        top.open()
    }

}
