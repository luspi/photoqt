/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import Qt.labs.platform 1.0

Menu {

    id: control

    property var entries: []
    property var hideIndices: []
    property var lineBelowIndices: []

    signal triggered(var index)

    property bool isOpen: false

    onAboutToShow:
        isOpen = true
    onAboutToHide:
        isOpen = false

    Instantiator {
        id: rpt
        model: control.entries
        delegate: MenuItem {
            text: modelData
            onTriggered: control.triggered(index)
        }
        onObjectAdded: control.insertItem(index, object)
        onObjectRemoved: control.removeItem(object)
    }

    function popup(pos) {
        control.open(pos)
    }

    Connections {
        target: PQKeyPressMouseChecker
        onReceivedMouseButtonPress:
            control.close()
    }

}
