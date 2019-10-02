import QtQuick 2.9
import QtQml 2.0

import "./handleshortcuts.js" as HandleShortcuts

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    Connections {

        target: PQKeyPressChecker

        onReceivedKeyPress: {

            if(variables.visibleItem != "")

                loader.passKeyEvent(variables.visibleItem, key, modifiers)

            else {

                var combo = ""

                if(modifiers & Qt.ControlModifier)
                    combo += "Ctrl+";
                if(modifiers & Qt.AltModifier)
                    combo += "Alt+";
                if(modifiers & Qt.ShiftModifier)
                    combo += "Shift+";
                if(modifiers & Qt.MetaModifier)
                    combo += "Meta+";
                if(modifiers & Qt.KeypadModifier)
                    combo += "Keypad+";

                // this seems to be the id when a modifier but no key is pressed... ignore key in that case
                if(key != 16777249)
                    combo += handlingShortcuts.convertKeyCodeToText(key)

                HandleShortcuts.checkComboForShortcut(combo)

            }

        }

    }

    Component.onCompleted:
        variables.shortcuts = handlingShortcuts.loadFromFile()


}
