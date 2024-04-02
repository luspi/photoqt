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
import PQCScriptsClipboard

Column {

    id: entry

    property alias whichtxt: which.text
    property string valtxt: ""

    property bool fadeout: valtxt==""

    property bool signalClicks: false
    property string tooltip: qsTranslate("metadata", "Copy value to clipboard")
    clip: true

    property bool prop: true

    height: prop ? childrenRect.height : 0
    opacity: prop ? 1 : 0

    Behavior on height { NumberAnimation { duration: 200 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    signal clicked(var mouse)

    PQText {
        id: which
        font.weight: PQCLook.fontWeightBold
        opacity: fadeout ? 0.4 : 1
        visible: PQCFileFolderModel.countMainView>0
    }

    Row {

        spacing: 5

        PQText {
            id: val
            text: "  " + (valtxt=="" ? "--" : valtxt)
            opacity: fadeout ? 0.4 : 1
            visible: PQCFileFolderModel.countMainView>0

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                enabled: !fadeout
                text: enabled ? tooltip : ""
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: (mouse) => {
                    if(signalClicks)
                        entry.clicked(mouse)
                    else
                        PQCScriptsClipboard.copyTextToClipboard(valtxt)
                }
            }
        }

    }

}

