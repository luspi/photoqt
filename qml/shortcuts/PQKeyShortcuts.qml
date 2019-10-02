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

            if(variables.visibleItem == "filedialog")

                loader.passKeyEvent("filedialog", key, modifiers)

            else if(variables.visibleItem == "slideshowsettings")

                loader.passKeyEvent("slideshowsettings", key, modifiers)

            else if(variables.visibleItem == "slideshowcontrols")

                loader.passKeyEvent("slideshowcontrols", key, modifiers)

            else if(variables.visibleItem == "filerename")

                loader.passKeyEvent("filerename", key, modifiers)

            else if(variables.visibleItem == "filedelete")

                loader.passKeyEvent("filedelete", key, modifiers)

            else if(variables.visibleItem == "scale")

                loader.passKeyEvent("scale", key, modifiers)

            else if(variables.visibleItem == "about")

                loader.passKeyEvent("about", key, modifiers)

            else if(variables.visibleItem == "imgur")

                loader.passKeyEvent("imgur", key, modifiers)

            else if(variables.visibleItem == "wallpaper")

                loader.passKeyEvent("wallpaper", key, modifiers)

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
