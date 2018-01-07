import QtQuick 2.6
import "handlestuff.js" as Handle

Item {

    property string currentDirectory: settings.openKeepLastLocation ? getanddostuff.getOpenFileLastLocation() : getanddostuff.getHomeDir()
    onCurrentDirectoryChanged: {
        Handle.loadDirectory()
        watcher.setCurrentDirectoryForChecking(currentDirectory)
    }

    property string currentFocusOn: "folders"

    property int historypos: -1
    property var history: []
    property bool loadedFromHistory: false

    property var currentDirectoryFolders: []
    property var currentDirectoryFiles: []

    property int filesFileTypeSelection: 0
    onFilesFileTypeSelectionChanged:
        Handle.loadDirectoryFiles()

    property bool highlightingFromUserInput: false
    property bool textEditedFromHighlighting: false

}
