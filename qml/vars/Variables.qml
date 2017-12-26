import QtQuick 2.6

Item {

    // Element radius is the radius of "windows" (e.g., About or Quicksettings)
    // Item radius is the radius of smaller items (e.g., spinbox)
    readonly property int global_element_radius: 10
    readonly property int global_item_radius: 5

    property bool guiBlocked: false

    property bool slideshowRunning: false

    property bool textEntryRequired: false

    property int totalNumberImagesCurrentFolder: 0
    property int currentFilePos: -1
    property string currentFile: ""
    onCurrentFileChanged: updateCurrentFilePos()

    property string filter: ""
    property string currentDir: ""
    property var allFilesCurrentDir: []
    onAllFilesCurrentDirChanged: updateCurrentFilePos()

    property bool deleteNothingLeft: false
    property bool filterNoMatch: false

    property string filemanagementCurrentCategory: ""

    property int startupUpdateStatus: 0
    property string startupFilenameAfter: ""

    function updateCurrentFilePos() {
        var onlyfile = getanddostuff.removePathFromFilename(currentFile)
        if(allFilesCurrentDir.indexOf(onlyfile) >= 0)
            currentFilePos = allFilesCurrentDir.indexOf(onlyfile)
    }

}
