import QtQuick 2.5

Item {

    // Element radius is the radius of "windows" (e.g., About or Quicksettings)
    // Item radius is the radius of smaller items (e.g., spinbox)
    readonly property int global_element_radius: 10
    readonly property int global_item_radius: 5

    property bool guiBlocked: false

    property bool imageItemBlocked: false

    property bool slideshowRunning: false

    property int totalNumberImagesCurrentFolder: 0
    property int currentFilePos: allFilesCurrentDir.indexOf(getanddostuff.removePathFromFilename(currentFile))>=0
                                    ? allFilesCurrentDir.indexOf(getanddostuff.removePathFromFilename(currentFile))
                                    : -1
    property string currentFile: ""
    property string filter: ""
    property string currentDir: ""
    property var allFilesCurrentDir: []

    property bool deleteNothingLeft: false
    property bool filterNoMatch: false

    property string filemanagementCurrentCategory: ""

    property int startupUpdateStatus: 0
    property string startupFilenameAfter: ""

    property var shortcutsMouseGesture: []
    property point shorcutsMouseGesturePointIntermediate: Qt.point(-1,-1)

    property int thumbnailsheight: 0

    property point windowXY: Qt.point(-1,-1)

}
