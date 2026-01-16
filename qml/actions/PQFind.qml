/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

import QtQuick
import PhotoQt

PQTemplate {

    id: find_top

    title: qsTranslate("find", "Find in current directory")
    elementId: "Find"
    letMeHandleClosing: true

    Component.onCompleted: {

        //: Written on a clickable button - please keep short
        button1.text = qsTranslate("find", "Find")

        button2.visible = true
        button2.fontWeight = PQCLook.fontWeightNormal
        button2.text = qsTranslate("find", "Cancel")

    }

    Connections {
        target: button1
        function onClicked() {
            PQCFileFolderModel.loadNextMatchOfSearch(searchbox.text)
            find_top.hide()
        }
    }

    Connections {
        target: button2
        function onClicked() {
            find_top.hide()
        }
    }

    content: [

        Column {

            x: (find_top.width-width)/2
            y: (find_top.availableHeight-height)/2

            spacing: 35

            PQTextL {

                id: introtxt

                width: Math.min(find_top.width*0.8, 800)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                property list<string> shs: PQCShortcuts.getShortcutsForCommand("__findNext")
                text: qsTranslate("find", "Enter here a term you want to search for. You can keep jumping to the next match (if any) by activating the shortcut for that action:") + " " + (shs.length > 0 ? ("<i>" + shs.join("</i> / <i>") + "</i>") : "<i>(no shortcut set)</i>")

            }

            PQLineEdit {
                id: searchbox
                x: 0.05*introtxt.width
                width: 0.9*introtxt.width
                height: 50
                placeholderText: qsTranslate("find", "Enter here your search term")
            }

            PQText {

                id: aftertxt

                width: introtxt.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: qsTranslate("find", "You can start your search through the button below or by pressing the Enter or Return key. Pressing the Esc key will clear the current search string or, if nothing is entered, hide the search.")

            }

        }

    ]

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(find_top.visible) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape) {

                        if(searchbox.text === "")
                            find_top.hide()
                        else {
                            searchbox.text = ""
                            // this is necessary as otherwise the id might be reset to empty
                            // even though this element is still open.
                            PQCConstants.idOfVisibleItem = find_top.elementId
                        }

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {
                        find_top.button1.clicked()

                    }

                }
            }
        }
    }

    function showing() {

        if((PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0)) {
            return false
        }

        searchbox.enabled = true
        searchbox.text = PQCConstants.searchText
        searchbox.setFocus()

    }

    function hiding() {
        PQCConstants.searchText = searchbox.text
        searchbox.enabled = false
    }

}
