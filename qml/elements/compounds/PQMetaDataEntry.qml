/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

Row {

    id: entry

    property string whichtxt: ""
    property string valtxt: ""

    property bool fadeout: valtxt==""

    property bool signalClicks: false
    property string tooltip: qsTranslate("metadata", "Copy value to clipboard")
    clip: true

    property bool prop: true

    property bool isModern: PQCSettings.generalInterfaceVariant==="modern"

    height: prop ? childrenRect.height : 0
    opacity: prop ? 1 : 0

    signal clicked(var mouse)

    spacing: 10

    property int useWidth: (entry.isModern ? PQCSettings.metadataElementSize.width : PQCSettings.metadataSideBarWidth)

    PQText {
        id: which
        text: entry.whichtxt+":"
        font.weight: PQCLook.fontWeightBold
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        width: Math.max(100, Math.min(300, entry.useWidth*0.3))
        enabled: !entry.fadeout
        visible: PQCFileFolderModel.countMainView>0
    }

    PQText {
        id: val
        text: (entry.valtxt=="" ? "--" : entry.valtxt)
        enabled: !entry.fadeout
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        visible: PQCFileFolderModel.countMainView>0
        width: entry.useWidth-which.width-5 - 20 // the 20 comes from the content margin

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !entry.fadeout
            text: enabled ? entry.tooltip : ""
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: (mouse) => {
                if(entry.signalClicks)
                    entry.clicked(mouse)
                else
                    PQCScriptsClipboard.copyTextToClipboard(valtxt)
            }
        }
    }

    Component.onCompleted: {
        isModern = isModern
    }

}

