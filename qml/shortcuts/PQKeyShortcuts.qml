import QtQuick 2.9
import QtQml 2.9

import "./handleshortcuts.js" as HandleShortcuts

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    Keys.onPressed: {

        if(variables.visibleItem == "filedialog")

            loader.passKeyEvent("filedialog", event.key, event.modifiers)

        else if(variables.visibleItem == "slideshowsettings")

            loader.passKeyEvent("slideshowsettings", event.key, event.modifiers)

        else if(variables.visibleItem == "slideshowcontrols")

            loader.passKeyEvent("slideshowcontrols", event.key, event.modifiers)

        else if(variables.visibleItem == "filerename")

            loader.passKeyEvent("filerename", event.key, event.modifiers)

        else if(variables.visibleItem == "filedelete")

            loader.passKeyEvent("filedelete", event.key, event.modifiers)

        else if(variables.visibleItem == "scale")

            loader.passKeyEvent("scale", event.key, event.modifiers)

        else if(variables.visibleItem == "about")

            loader.passKeyEvent("about", event.key, event.modifiers)

        else if(variables.visibleItem == "imgur")

            loader.passKeyEvent("imgur", event.key, event.modifiers)

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
        onTriggered: {
            if(!variables.textEditFocused) {
                keyshortcuts_top.forceActiveFocus()
                keyshortcuts_top.focus = true
                keyshortcuts_top.forceActiveFocus()
            }
        }

    }

    Component.onCompleted:
        variables.shortcuts = handlingShortcuts.loadFromFile()


}
