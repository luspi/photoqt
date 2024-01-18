/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCFileFolderModel

Column {

    id: entry

    property alias whichtxt: which.text
    property string valtxt: ""

    property bool fadeout: valtxt==""

    property bool enableMouse: false
    property string tooltip: ""

    signal clicked()

    PQText {
        id: which
        font.weight: PQCLook.fontWeightBold
        opacity: fadeout ? 0.4 : 1
        visible: PQCFileFolderModel.countMainView>0
    }

    PQText {
        id: val
        text: "  " + (valtxt=="" ? "--" : valtxt)
        opacity: fadeout ? 0.4 : 1
        visible: PQCFileFolderModel.countMainView>0

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: enableMouse
            text: tooltip
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked:
                entry.clicked()
        }
    }

}

