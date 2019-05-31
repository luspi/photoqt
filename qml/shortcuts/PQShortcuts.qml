import QtQuick 2.9
import QtQml 2.9

Item {

    anchors.fill: parent

    focus: true

    Keys.onPressed: {

        var m = []

        if(event.modifiers & Qt.ShiftModifier)
            m[m.length] = Qt.ShiftModifier
        if(event.modifiers & Qt.ControlModifier)
            m[m.length] = Qt.ControlModifier
        if(event.modifiers & Qt.AltModifier)
            m[m.length] = Qt.AltModifier
        if(event.modifiers & Qt.MetaModifier)
            m[m.length] = Qt.MetaModifier
        if(event.modifiers & Qt.KeypadModifier)
            m[m.length] = Qt.KeypadModifier
        if(event.modifiers & Qt.GroupSwitchModifier)
            m[m.length] = Qt.GroupSwitchModifier

        handleShortcuts(event.key, m)

    }

    function handleShortcuts(key, modifiers) {

        if(filedialog.visible)

            filedialog.keyEvent(key, modifiers)

    }

    Timer {

        interval: 500
        running: true
        repeat: true
        onTriggered:
            parent.focus = true

    }

}
