import QtQuick

import PQCFileFolderModel
import PQCScriptsChromeCast

Item {

    id: chromecast_top

    Connections {

        target: PQCFileFolderModel

        function onCurrentFileChanged() {
            if(PQCScriptsChromeCast.connected)
                castCurrent.restart()

        }

    }

    Timer {
        id: castCurrent
        interval: 0
        onTriggered:
            PQCScriptsChromeCast.castImage(PQCFileFolderModel.currentFile)
    }

    Component.onDestruction: {
        PQCScriptsChromeCast.disconnect()
    }

}
