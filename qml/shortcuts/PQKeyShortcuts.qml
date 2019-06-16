import QtQuick 2.9
import QtQml 2.9

import "./handleshortcuts.js" as HandleShortcuts

Item {

    anchors.fill: parent

    focus: true

    Keys.onPressed: {

        if(variables.visibleItem == "filedialog")

            loader.passKeyEvent("filedialog", event.key, event.modifiers)

        else {

            var combo = ""

            if(event.modifiers & Qt.ControlModifier)
                combo += "Ctrl+";
            if(event.modifiers & Qt.AltModifier)
                combo += "Alt+";
            if(event.modifiers & Qt.ShiftModifier)
                combo += "Shift+";
            if(event.modifiers & Qt.MetaModifier)
                combo += "Meta+";
            if(event.modifiers & Qt.KeypadModifier)
                combo += "Keypad+";

            // this seems to be the id when a modifier but no key is pressed... ignore key in that case
            if(event.key != 16777249)
                combo += handlingShortcuts.convertKeyCodeToText(event.key)

            HandleShortcuts.checkComboForShortcut(combo)

        }

    }

    Timer {

        interval: 500
        running: true
        repeat: true
        onTriggered:
            parent.focus = true

    }

    Component.onCompleted:
        variables.shortcuts = handlingShortcuts.loadFromFile()


}
