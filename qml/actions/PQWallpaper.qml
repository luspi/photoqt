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
import QtQuick.Controls

import PQCScriptsConfig
import PQCFileFolderModel
import PQCScriptsWallpaper
import PQCWindowGeometry

import "../elements"
import "./wallpaperparts"

PQTemplateFullscreen {

    id: wallpaper_top

    thisis: "wallpaper"
    popout: PQCSettings.interfacePopoutWallpaper
    forcePopout: PQCWindowGeometry.wallpaperForcePopout
    shortcut: "__wallpaper"

    title: qsTranslate("wallpaper", "Wallpaper")

    onPopoutChanged:
        PQCSettings.interfacePopoutWallpaper = popout

    button1.text: qsTranslate("wallpaper", "Set as Wallpaper")

    button2.visible: true
    button2.text: genericStringCancel

    button1.onClicked:
        setWallpaper()

    button2.onClicked:
        hide()

    property bool onWindows: PQCScriptsConfig.amIOnWindows()

    property var categories: ["plasma", "gnome", "xfce", "enlightenment", "other"]
    property int curCat: onWindows ? categories.length : 0
    property int numDesktops: 0

    content: [

        Item {

            x: (parent.width-width)/2
            width: Math.min(wallpaper_top.width, 800)
            height: 400

            Item {
                id: category
                x: 0
                y: 0
                width: visible ? parent.width*0.375 : 0
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
                            color: curCat==0 ? PQCLook.textColor : PQCLook.textColorDisabled
                            font.weight: PQCLook.fontWeightBold
                            text: "Plasma 5"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("Plasma 5")
                                onClicked:
                                    curCat = 0
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat==1 ? PQCLook.textColor : PQCLook.textColorDisabled
                            font.weight: PQCLook.fontWeightBold
                            text: "Gnome<br>Unity<br>Cinnamon"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("Gnome/Unity/Cinnamon")
                                onClicked:
                                    curCat = 1
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat==2 ? PQCLook.textColor : PQCLook.textColorDisabled
                            font.weight: PQCLook.fontWeightBold
                            text: "XFCE4"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("XFCE4")
                                onClicked:
                                    curCat = 2
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat==3 ? PQCLook.textColor : PQCLook.textColorDisabled
                            font.weight: PQCLook.fontWeightBold
                            text: "Enlightenment"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("Enlightenment")
                                onClicked:
                                    curCat = 3
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: curCat==4 ? PQCLook.textColor : PQCLook.textColorDisabled
                            font.weight: PQCLook.fontWeightBold
                            text: "Other"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1")
                                        //: Used as in: Other Desktop Environment
                                        .arg(qsTranslate("wallpaper", "Other"))
                                onClicked:
                                    curCat = 4
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

                ScrollBar.vertical: PQVerticalScrollBar { }

                contentHeight: (curCat==0 ?
                                    plasma.height :
                                    (curCat==1 ?
                                         gnome.height :
                                         (curCat==2 ?
                                              xfce.height :
                                              (curCat==3 ?
                                                   enlightenment.height :
                                                   (curCat==4 ?
                                                        other.height :
                                                        windows.height)))))

                clip: true

                PQPlasma {
                    id: plasma
                    visible: curCat==0
                }

                PQGnome {
                    id: gnome
                    visible: curCat==1
                }

                PQXfce {
                    id: xfce
                    visible: curCat==2
                }

                PQEnlightenment {
                    id: enlightenment
                    visible: curCat==3
                }

                PQOther {
                    id: other
                    visible: curCat==4
                }

                PQWindows {
                    id: windows
                    visible: curCat==5
                }

            }

        }

    ]

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(wallpaper_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape)
                        hide()

                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        setWallpaper()

                    else if(param[0] === Qt.Key_Tab) {

                        if(onWindows) return

                        curCat = (curCat+1)%categories.length

                    } else if(param[0] === Qt.Key_Right || param[0] === Qt.Key_Left) {

                        if(categories[curCat] === "other")
                            other.changeTool()

                    }

                }

            }

        }

    }

    function show() {
        opacity = 1
        if(popout)
            wallpaper_popout.show()
    }

    function hide() {
        wallpaper_top.opacity = 0
        loader.elementClosed(thisis)
    }

    function setWallpaper() {

        var args = {}

        if(curCat == 0) {

            if(plasma.checkedScreens.length == 0)
                return

            args["screens"] = plasma.checkedScreens

        } else if(curCat == 1) {

            args["option"] = gnome.checkedOption

        } else if(curCat == 2) {

            if(xfce.checkedScreens.length == 0)
                return

            args["screens"] = xfce.checkedScreens
            args["option"] = xfce.checkedOption

        } else if(curCat == 3) {

            if(enlightenment.checkedScreens.length == 0 || enlightenment.checkedWorkspaces.length == 0)
                return

            args["screens"] = enlightenment.checkedScreens
            args["workspaces"] = enlightenment.checkedWorkspaces

        } else if(curCat == 4) {

            args["app"] = other.checkedTool
            args["option"] = other.checkedOption

        } else if(curCat == 5) {

            args["WallpaperStyle"] = windows.checkedOption

        }

        PQCScriptsWallpaper.setWallpaper(categories[curCat], PQCFileFolderModel.currentFile, args)

        hide()
    }

}
