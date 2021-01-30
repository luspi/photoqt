/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
import "../elements"

Item {

    x: parent.width-width
    y: 0

    width: 3*PQSettings.quickInfoCloseXSize
    height: 3*PQSettings.quickInfoCloseXSize

    visible: !(variables.slideShowActive&&PQSettings.slideShowHideQuickInfo) && !PQSettings.quickInfoHideX

    Image {
        anchors.fill: parent
        anchors.margins: 5
        source: "/mainwindow/close.png"
    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: em.pty+qsTranslate("quickinfo", "Click here to close PhotoQt")
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.LeftButton)
                toplevel.close()
            else {
                var pos = parent.mapFromItem(parent.parent, mouse.x, mouse.y)
                console.log("opoup")
                rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
            }
        }
    }

    PQMenu {

        id: rightclickmenu

        model: [(PQSettings.quickInfoHideCounter ?
                     em.pty+qsTranslate("quickinfo", "Show counter") :
                     em.pty+qsTranslate("quickinfo", "Hide counter")),
            (PQSettings.quickInfoHideFilepath ?
                 em.pty+qsTranslate("quickinfo", "Show file path") :
                 em.pty+qsTranslate("quickinfo", "Hide file path")),
            (PQSettings.quickInfoHideFilename ?
                 em.pty+qsTranslate("quickinfo", "Show file name") :
                 em.pty+qsTranslate("quickinfo", "Hide file name")),
            (PQSettings.quickInfoHideZoomLevel ?
                 em.pty+qsTranslate("quickinfo", "Show zoom level") :
                 em.pty+qsTranslate("quickinfo", "Hide zoom level")),
            (PQSettings.quickInfoHideX ?
                 em.pty+qsTranslate("quickinfo", "Show button for closing PhotoQt") :
                 em.pty+qsTranslate("quickinfo", "Hide button for closing PhotoQt"))
        ]

        onTriggered: {
            if(index == 0)
                PQSettings.quickInfoHideCounter = !PQSettings.quickInfoHideCounter
            else if(index == 1)
                PQSettings.quickInfoHideFilepath = !PQSettings.quickInfoHideFilepath
            else if(index == 2)
                PQSettings.quickInfoHideFilename = !PQSettings.quickInfoHideFilename
             else if(index == 3)
                PQSettings.quickInfoHideZoomLevel = !PQSettings.quickInfoHideZoomLevel
            else if(index == 4)
                PQSettings.quickInfoHideX = !PQSettings.quickInfoHideX
        }

    }

}
