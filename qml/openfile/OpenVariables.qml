import QtQuick 2.6
import "handlestuff.js" as Handle

Item {

    property string currentDirectory: settings.openKeepLastLocation ? getanddostuff.getOpenFileLastLocation() : getanddostuff.getHomeDir()
    onCurrentDirectoryChanged: Handle.loadDirectory()

    property string currentFocusOn: "folders"

    property int historypos: -1
    property var history: []
    property bool loadedFromHistory: false

}
