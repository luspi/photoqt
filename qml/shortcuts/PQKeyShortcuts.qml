/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.9
import QtQml 2.0

import "./handleshortcuts.js" as HandleShortcuts

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    Connections {

        target: PQKeyPressMouseChecker

        onReceivedKeyPress: {

            contextmenu.hideMenu()

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

}
