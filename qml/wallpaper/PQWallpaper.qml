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
import QtQuick.Controls 2.2
import "../templates"
import "../elements"
import "ele"

PQTemplateFullscreen {

    id: wallpaper_top

    popout: PQSettings.interfacePopoutWallpaper
    shortcut: "__wallpaper"
    title: em.pty+qsTranslate("wallpaper", "Set as Wallpaper")

    button1.text: em.pty+qsTranslate("wallpaper", "Set as Wallpaper")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutWallpaper = popout

    button1.onClicked:
        setWallpaper()

    button2.onClicked:
        closeElement()

    property bool onWindows: handlingGeneral.amIOnWindows()

    property string curCat: onWindows ? "windows" : "plasma"
    property int numDesktops: 3

    content: [

        Item {

            x: (parent.width-width)/2
            width: 800
            height: 400

            Item {
                id: category
                x: 0
                y: 0
                width: visible ? 300 : 0
                height: parent.height

                visible: !onWindows

                Item {
                    width: parent.width
                    height: childrenRect.height
                    anchors.centerIn: parent
                    Column {
                        spacing: 20
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="plasma" ? "white" : "#666666"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.weight: baselook.boldweight
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
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="gnome" ? "white" : "#666666"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.weight: baselook.boldweight
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
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="xfce" ? "white" : "#666666"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.weight: baselook.boldweight
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
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="enlightenment" ? "white" : "#666666"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.weight: baselook.boldweight
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
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat=="other" ? "white" : "#666666"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.weight: baselook.boldweight
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

            Flickable {

                x: category.width
                y: (onWindows ? -20 : 0)
                width: parent.width-category.width-10
                height: (parent.height + (onWindows ? 10 : -10))

                ScrollBar.vertical: PQScrollBar { }

                contentHeight: (curCat=="plasma"
                                    ? plasma.height
                                    : (curCat=="gnome"
                                            ? gnome.height
                                            : (curCat=="xfce"
                                                    ? xfce.height
                                                    : (curCat=="enlightenment"
                                                            ? enlightenment.height
                                                            : (curCat == "windows"
                                                                    ? windows.height
                                                                    : other.height)))))

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

                PQWindows {
                    id: windows
                    visible: curCat=="windows"
                }

            }

        }

    ]

    Connections {
        target: loader
        onWallpaperPassOn: {
            if(what == "show") {
                if(filefoldermodel.current == -1)
                    return
                opacity = 1
                variables.visibleItem = "wallpaper"
            } else if(what == "hide") {
                closeElement()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    closeElement()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    setWallpaper()
                else if(param[0] == Qt.Key_Tab) {

                    if(onWindows) return

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

    Component.onCompleted: {
        if(onWindows) return
        curCat = handlingWallpaper.detectWM()
    }

    function setWallpaper() {

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

        } else if(curCat == "windows") {

            args["WallpaperStyle"] = windows.checkedOption

        }

        handlingWallpaper.setWallpaper(curCat, filefoldermodel.currentFilePath, args)

        closeElement()

    }

    function closeElement() {
        wallpaper_top.opacity = 0
        variables.visibleItem = ""
    }

}
