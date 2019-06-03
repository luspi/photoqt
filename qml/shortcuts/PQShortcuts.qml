import QtQuick 2.9
import QtQml 2.9

Item {

    anchors.fill: parent

    focus: true

    Keys.onPressed: {

        if(filedialog.visible)

            filedialog.keyEvent(event.key, event.modifiers)

    }

    Timer {

        interval: 500
        running: true
        repeat: true
        onTriggered:
            parent.focus = true

    }

}
