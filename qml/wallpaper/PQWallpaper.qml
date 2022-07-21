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
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../elements"
import "ele"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: wallpaper_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    property string curCat: "plasma"
    property int numDesktops: 3

    Rectangle {

        anchors.fill: parent
        color: "#dd000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.interfacePopoutWallpaper
            onClicked:
                button_cancel.clicked()
        }

        PQMouseArea {
            anchors.fill: insidecont
            anchors.margins: -50
            hoverEnabled: true
        }

        Item {

            id: insidecont
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: Math.min(parent.width, Math.max(parent.width/2, 800))
            height: Math.min(parent.height, Math.max(parent.height/2, 600))

            Item {
                id: category
                x: 0
                y: 0
                width: 300
                height: parent.height

                Item {
                    width: parent.width
                    height: childrenRect.height
                    anchors.centerIn: parent
                    Column {
                        spacing: 20
                        Text {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="plasma" ? "#ffffff" : "#aaaaaa"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.pointSize: 15
                            font.bold: true
                            text: "Plasma 5"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                tooltip: em.pty+qsTranslate("wallpaper", "Click to choose %1").arg("Plasma 5")
                                onClicked:
                                    curCat = "plasma"
                            }
                        }
                        Text {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="gnome" ? "#ffffff" : "#aaaaaa"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.pointSize: 15
                            font.bold: true
                            text: "Gnome<br>Unity<br>Cinnamon"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                tooltip: em.pty+qsTranslate("wallpaper", "Click to choose %1").arg("Gnome/Unity/Cinnamon")
                                onClicked:
                                    curCat = "gnome"
                            }
                        }
                        Text {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="xfce" ? "#ffffff" : "#aaaaaa"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.pointSize: 15
                            font.bold: true
                            text: "XFCE4"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                tooltip: em.pty+qsTranslate("wallpaper", "Click to choose %1").arg("XFCE4")
                                onClicked:
                                    curCat = "xfce"
                            }
                        }
                        Text {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="enlightenment" ? "#ffffff" : "#aaaaaa"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.pointSize: 15
                            font.bold: true
                            text: "Enlightenment"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                tooltip: em.pty+qsTranslate("wallpaper", "Click to choose %1").arg("Enlightenment")
                                onClicked:
                                    curCat = "enlightenment"
                            }
                        }
                        Text {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="other" ? "#ffffff" : "#aaaaaa"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.pointSize: 15
                            font.bold: true
                            text: "Other"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                tooltip: em.pty+qsTranslate("wallpaper", "Click to choose %1")
                                            //: Used as in: Other Desktop Environment
                                            .arg(em.pty+qsTranslate("wallpaper", "Other"))
                                onClicked:
                                    curCat = "other"
                            }
                        }
                    }
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }
                    width: 1
                    color: "#cccccc"
                }

            }

            Text {
                id: heading
                x: category.width
                y: 0
                width: parent.width-x
                height: 100
                //: Heading of wallpaper element
                text: em.pty+qsTranslate("wallpaper", "Set as Wallpaper")
                color: "white"
                font.pointSize: 20
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                id: buttons
                x: (parent.width-width)/2 + category.width/2
                y: parent.height-height
                width: childrenRect.width
                spacing: 10
                height: 50
                PQButton {
                    y: (parent.height-height)/2
                    id: button_ok
                    //: Written on clickable button
                    text: em.pty+qsTranslate("wallpaper", "Set as Wallpaper")
                    onClicked: {

                        var args = {}

                        if(curCat == "plasma") {

                            if(plasma.checkedScreens.length == 0)
                                return

                            args["screens"] = plasma.checkedScreens

                        } else if(curCat == "gnome") {

                            args["option"] = gnome.checkedOption

                        } else if(curCat == "xfce") {

                            if(xfce.checkedScreens.length == 0)
                                return

                            args["screens"] = xfce.checkedScreens
                            args["option"] = xfce.checkedOption

                        } else if(curCat == "enlightenment") {

                            if(enlightenment.checkedScreens.length == 0 || enlightenment.checkedWorkspaces.length == 0)
                                return

                            args["screens"] = enlightenment.checkedScreens
                            args["workspaces"] = enlightenment.checkedWorkspaces

                        } else if(curCat == "other") {

                            args["app"] = other.checkedTool
                            args["option"] = other.checkedOption

                        }

                        handlingWallpaper.setWallpaper(curCat, filefoldermodel.currentFilePath, args)

                        wallpaper_top.opacity = 0
                        variables.visibleItem = ""
                    }
                }
                PQButton {
                    y: (parent.height-height)/2
                    id: button_cancel
                    text: genericStringCancel
                    onClicked: {
                        wallpaper_top.opacity = 0
                        variables.visibleItem = ""
                    }
                }
            }

            Flickable {

                anchors {
                    left: category.right
                    top: heading.bottom
                    bottom: buttons.top
                    right: parent.right
                    rightMargin: 10
                    bottomMargin: 10
                }

                ScrollBar.vertical: PQScrollBar { }

                contentHeight: (curCat=="plasma" ? plasma.height
                                                 : (curCat=="gnome" ? gnome.height
                                                                    : (curCat=="xfce" ? xfce.height
                                                                                      : (curCat=="enlightenment" ? enlightenment.height
                                                                                                                 : other.height))))

                clip: true

                PQPlasma {
                    id: plasma
                    visible: curCat=="plasma"
                }

                PQGnome {
                    id: gnome
                    visible: curCat=="gnome"
                }

                PQXfce {
                    id: xfce
                    visible: curCat=="xfce"
                }

                PQEnlightenment {
                    id: enlightenment
                    visible: curCat=="enlightenment"
                }

                PQOther {
                    id: other
                    visible: curCat=="other"
                }

            }

        }

        Connections {
            target: loader
            onWallpaperPassOn: {
                if(what == "show") {
                    if(filefoldermodel.current == -1)
                        return
                    opacity = 1
                    variables.visibleItem = "wallpaper"
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_ok.clicked()
                    else if(param[0] == Qt.Key_Tab) {
                        var avail = ["plasma", "gnome", "xfce", "enlightenment", "other"]
                        var cur = avail.indexOf(curCat)+1
                        if(cur == avail.length)
                            cur = 0
                        curCat = avail[cur]
                    } else if(param[0] == Qt.Key_Right || param[0] == Qt.Key_Left) {
                        if(curCat == "other")
                            other.changeTool()
                    }
                }
            }
        }

        Component.onCompleted:
            curCat = handlingWallpaper.detectWM()

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        source: "/popin.png"
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutWallpaper ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutWallpaper)
                    wallpaper_window.storeGeometry()
                button_cancel.clicked()
                PQSettings.interfacePopoutWallpaper = !PQSettings.interfacePopoutWallpaper
                HandleShortcuts.executeInternalFunction("__wallpaper")
            }
        }
    }

}
