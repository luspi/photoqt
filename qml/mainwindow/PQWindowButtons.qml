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

    x: parent.width-width-5
    y: 5

    width: row.width
    height: row.height

    // these are always visible on top of everything, according to the conditions below
    z: 999

    visible: !(variables.slideShowActive&&PQSettings.slideShowHideQuickInfo) && !PQSettings.quickInfoHideWindowButtons && opacity==1

    opacity: variables.visibleItem=="filedialog" ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    // clicks between buttons has no effect anywhere
    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Row {

        id: row

        spacing: 10

        Image {
            width: 3*PQSettings.quickInfoWindowButtonsSize
            height: 3*PQSettings.quickInfoWindowButtonsSize
            source: PQSettings.windowMode ? "/mainwindow/fullscreen_on.png" : "/mainwindow/fullscreen_off.png"

            opacity: fullscreen_mouse.containsMouse ? 0.8 : 0.2
            Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }

            PQMouseArea {
                id: fullscreen_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: (PQSettings.windowMode ? em.pty+qsTranslate("quickinfo", "Click here to enter fullscreen mode")
                                                : em.pty+qsTranslate("quickinfo", "Click here to exit fullscreen mode"))
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: {
                    if(mouse.button == Qt.LeftButton)
                        PQSettings.windowMode = !PQSettings.windowMode
                    else {
                        var pos = parent.mapFromItem(parent.parent, mouse.x, mouse.y)
                        rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
                    }
                }
            }
        }

        Image {
            width: 3*PQSettings.quickInfoWindowButtonsSize
            height: 3*PQSettings.quickInfoWindowButtonsSize
            source: "/mainwindow/close.png"

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
                        rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
                    }
                }
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
            (PQSettings.quickInfoHideWindowButtons ?
                 em.pty+qsTranslate("quickinfo", "Show window buttons") :
                 em.pty+qsTranslate("quickinfo", "Hide window buttons"))
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
                PQSettings.quickInfoHideWindowButtons = !PQSettings.quickInfoHideWindowButtons
        }

    }

}
