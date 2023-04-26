import QtQuick.Dialogs 1.3

FileDialog {
     id: top
     title: "Please select a target folder"
     folder: shortcuts.home
     selectExisting: true
     selectFolder: true
     onAccepted: {
         console.log("You chose: " + top.fileUrls)
     }
     onRejected: {
         console.log("Canceled")
     }
 }
