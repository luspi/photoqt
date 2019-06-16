import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: mainmenu_window

    width: PQSettings.mainMenuWindowWidth
    height: 768

    minimumWidth: 100
    minimumHeight: 600

    modality: Qt.NonModal

    onClosing: {
        close.accepted = false
    }

    visible: PQSettings.mainMenuPopoutElement

    color: "#88000000"

    Loader {
        source: "PQMainMenu.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return mainmenu_window.width })
                item.parentHeight = Qt.binding(function() { return mainmenu_window.height })
            }
    }

}
