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
import QtQuick.Window 2.2
import "../elements"

Item {

    x: parent.width-width-PQSettings.imageviewMargin
    y: PQSettings.imageviewMargin

    width: row.width
    height: row.height

    visible: (!(variables.slideShowActive&&PQSettings.slideshowHideLabels) && !PQSettings.interfaceLabelsHideWindowButtons && opacity==1)

    property bool visibleAlways: false

    z: (visibleAlways&&!variables.mainMenuVisible&&variables.visibleItem!="filedialog") ? 999 : 0

    // clicks between buttons has no effect anywhere
    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Row {

        id: row

        spacing: 0

        Image {
            width: 3*PQSettings.interfaceLabelsWindowButtonsSize
            height: 3*PQSettings.interfaceLabelsWindowButtonsSize
            source: "/mainwindow/leftarrow.png"
            enabled: filefoldermodel.countMainView>0
            opacity: visibleAlways ? 0 : (enabled ? (left_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
            visible: PQSettings.interfaceNavigationTopRight && opacity > 0 && !variables.slideShowActive
            PQMouseArea {
                id: left_mouse
                anchors.fill: parent
                enabled: parent.enabled&&parent.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                tooltip: em.pty+qsTranslate("navigate", "Navigate to previous image in folder")
                onClicked:
                    imageitem.loadPrevImage()
            }
        }

        Image {
            width: 3*PQSettings.interfaceLabelsWindowButtonsSize
            height: 3*PQSettings.interfaceLabelsWindowButtonsSize
            source: "/mainwindow/rightarrow.png"
            enabled: filefoldermodel.countMainView>0
            opacity: visibleAlways||variables.slideShowActive ? 0 : (enabled ? (right_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
            visible: PQSettings.interfaceNavigationTopRight && opacity > 0
            PQMouseArea {
                id: right_mouse
                anchors.fill: parent
                enabled: parent.enabled&&parent.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                tooltip: em.pty+qsTranslate("navigate", "Navigate to next image in folder")
                onClicked:
                    imageitem.loadNextImage()
            }
        }

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 3*PQSettings.interfaceLabelsWindowButtonsSize
            height: 3*PQSettings.interfaceLabelsWindowButtonsSize
            source: "/mainwindow/menu.png"

            opacity: visibleAlways||variables.slideShowActive ? 0 : (mainmenu_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            visible: PQSettings.interfaceNavigationTopRight && opacity > 0

            PQMouseArea {
                id: mainmenu_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Click here to show main menu")
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: {
                    if(mouse.button == Qt.LeftButton)
                        loader.passOn("mainmenu", "toggle", undefined)
                    else {
                        var pos = parent.mapFromItem(parent.parent, mouse.x, mouse.y)
                        rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
                    }
                }
            }
        }

        Image {
            width: 3*PQSettings.interfaceLabelsWindowButtonsSize
            height: 3*PQSettings.interfaceLabelsWindowButtonsSize
            source: PQSettings.interfaceWindowMode ? "/mainwindow/fullscreen_on.png" : "/mainwindow/fullscreen_off.png"

            opacity: !visibleAlways ? 0 : (fullscreen_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            PQMouseArea {
                id: fullscreen_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: (PQSettings.interfaceWindowMode ? em.pty+qsTranslate("quickinfo", "Click here to enter fullscreen mode")
                                                : em.pty+qsTranslate("quickinfo", "Click here to exit fullscreen mode"))
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: {
                    if(mouse.button == Qt.LeftButton)
                        PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
                    else {
                        var pos = parent.mapFromItem(parent.parent, mouse.x, mouse.y)
                        rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
                    }
                }
            }
        }

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 3*PQSettings.interfaceLabelsWindowButtonsSize
            height: 3*PQSettings.interfaceLabelsWindowButtonsSize
            source: "/mainwindow/close.png"

            opacity: visibleAlways ? 1 : 0

            visible: (toplevel.visibility==Window.FullScreen) || (!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceLabelsAlwaysShowX

            PQMouseArea {
                anchors.fill: parent
                anchors.topMargin: -PQSettings.imageviewMargin
                anchors.rightMargin: -PQSettings.imageviewMargin
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

        model: [(PQSettings.interfaceLabelsHideCounter ?
                     em.pty+qsTranslate("quickinfo", "Show counter") :
                     em.pty+qsTranslate("quickinfo", "Hide counter")),
            (PQSettings.interfaceLabelsHideFilepath ?
                 em.pty+qsTranslate("quickinfo", "Show file path") :
                 em.pty+qsTranslate("quickinfo", "Hide file path")),
            (PQSettings.interfaceLabelsHideFilename ?
                 em.pty+qsTranslate("quickinfo", "Show file name") :
                 em.pty+qsTranslate("quickinfo", "Hide file name")),
            (PQSettings.interfaceLabelsHideZoomLevel ?
                 em.pty+qsTranslate("quickinfo", "Show zoom level") :
                 em.pty+qsTranslate("quickinfo", "Hide zoom level")),
            (PQSettings.interfaceLabelsHideWindowButtons ?
                 em.pty+qsTranslate("quickinfo", "Show window buttons") :
                 em.pty+qsTranslate("quickinfo", "Hide window buttons"))
        ]

        onTriggered: {
            if(index == 0)
                PQSettings.interfaceLabelsHideCounter = !PQSettings.interfaceLabelsHideCounter
            else if(index == 1)
                PQSettings.interfaceLabelsHideFilepath = !PQSettings.interfaceLabelsHideFilepath
            else if(index == 2)
                PQSettings.interfaceLabelsHideFilename = !PQSettings.interfaceLabelsHideFilename
             else if(index == 3)
                PQSettings.interfaceLabelsHideZoomLevel = !PQSettings.interfaceLabelsHideZoomLevel
            else if(index == 4)
                PQSettings.interfaceLabelsHideWindowButtons = !PQSettings.interfaceLabelsHideWindowButtons
        }

    }

}
