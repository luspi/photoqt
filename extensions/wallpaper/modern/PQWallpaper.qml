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
import QtQuick.Controls

import PQCScriptsConfig
import PQCFileFolderModel

import org.photoqt.qml

PQTemplateFullscreen {

    id: wallpaper_top

    thisis: "wallpaper"
    popout: PQCSettingsExtensions.WallpaperPopout // qmllint disable unqualified
    forcePopout: PQCWindowGeometry.wallpaperForcePopout // qmllint disable unqualified
    shortcut: "__wallpaper"

    title: qsTranslate("wallpaper", "Wallpaper")

    onPopoutChanged:
        PQCSettingsExtensions.WallpaperPopout = popout // qmllint disable unqualified

    button1.text: qsTranslate("wallpaper", "Set as Wallpaper")

    button2.visible: true
    button2.text: genericStringCancel

    button1.onClicked:
        setWallpaper()

    button2.onClicked:
        hide()

    property bool onWindows: PQCScriptsConfig.amIOnWindows() // qmllint disable unqualified

    property list<string> categories: ["plasma", "gnome", "xfce", "enlightenment", "other"]
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

                visible: !wallpaper_top.onWindows

                Item {
                    width: parent.width
                    height: childrenRect.height
                    anchors.centerIn: parent
                    Column {
                        spacing: 20
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: wallpaper_top.curCat==0 ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            text: "Plasma"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("Plasma")
                                onClicked:
                                    wallpaper_top.curCat = 0
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: wallpaper_top.curCat==1 ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            text: "Gnome<br>Unity<br>Cinnamon"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("Gnome/Unity/Cinnamon")
                                onClicked:
                                    wallpaper_top.curCat = 1
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: wallpaper_top.curCat==2 ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            text: "XFCE4"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("XFCE4")
                                onClicked:
                                    wallpaper_top.curCat = 2
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: wallpaper_top.curCat==3 ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            text: "Enlightenment"
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                text: qsTranslate("wallpaper", "Click to choose %1").arg("Enlightenment")
                                onClicked:
                                    wallpaper_top.curCat = 3
                            }
                        }
                        PQTextL {
                            width: category.width
                            horizontalAlignment: Text.AlignHCenter
                            color: wallpaper_top.curCat==4 ? PQCLook.textColor : PQCLook.textColorDisabled // qmllint disable unqualified
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
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
                                    wallpaper_top.curCat = 4
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
                y: (wallpaper_top.onWindows ? -20 : 0)
                width: parent.width-category.width-10
                height: (parent.height + (wallpaper_top.onWindows ? 10 : -10))

                ScrollBar.vertical: PQVerticalScrollBar { }

                contentHeight: (wallpaper_top.curCat==0 ?
                                    plasma.height :
                                    (wallpaper_top.curCat==1 ?
                                         gnome.height :
                                         (wallpaper_top.curCat==2 ?
                                              xfce.height :
                                              (wallpaper_top.curCat==3 ?
                                                   enlightenment.height :
                                                   (wallpaper_top.curCat==4 ?
                                                        other.height :
                                                        windows.height)))))

                clip: true

                PQPlasma {
                    id: plasma
                    visible: wallpaper_top.curCat==0
                }

                PQGnome {
                    id: gnome
                    visible: wallpaper_top.curCat==1
                }

                PQXfce {
                    id: xfce
                    visible: wallpaper_top.curCat==2
                }

                PQEnlightenment {
                    id: enlightenment
                    visible: wallpaper_top.curCat==3
                }

                PQOther {
                    id: other
                    visible: wallpaper_top.curCat==4
                }

                PQWindows {
                    id: windows
                    visible: wallpaper_top.curCat==5
                }

            }

        }

    ]

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onLoaderPassOn(what : string, param : list<var>) {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(what === "show") {

                if(param[0] === wallpaper_top.thisis)
                    wallpaper_top.show()

            } else if(what === "hide") {

                if(param[0] === wallpaper_top.thisis)
                    wallpaper_top.hide()

            } else if(wallpaper_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(wallpaper_top.contextMenuOpen) {
                        wallpaper_top.closeContextMenus()
                        return
                    }

                    if(param[0] === Qt.Key_Escape) {

                        if(xfce.combobox.popup.visible)
                            xfce.combobox.popup.close()
                        else
                            wallpaper_top.hide()

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        wallpaper_top.setWallpaper()

                    else if(param[0] === Qt.Key_Tab) {

                        if(wallpaper_top.onWindows) return

                        wallpaper_top.curCat = (wallpaper_top.curCat+1)%wallpaper_top.categories.length

                    } else if(param[0] === Qt.Key_Right || param[0] === Qt.Key_Left) {

                        if(wallpaper_top.categories[wallpaper_top.curCat] === "other")
                            other.changeTool()

                    }

                }

            }

        }

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) { // qmllint disable unqualified
            hide()
            return
        }

        opacity = 1
        if(popoutWindowUsed)
            wallpaper_popout.visible = true // qmllint disable unqualified
    }

    function hide() {
        if(wallpaper_top.contextMenuOpen)
            wallpaper_top.closeContextMenus()
        xfce.combobox.popup.close()
        wallpaper_top.opacity = 0
        if(popoutWindowUsed && wallpaper_popout.visible)
            wallpaper_popout.visible = false // qmllint disable unqualified
        else
            PQCNotify.loaderRegisterClose(thisis)
    }

    function setWallpaper() {

        var args = {}

        if(curCat == 0) {

            if(plasma.checkedScreens.length === 0)
                return

            args["screens"] = plasma.checkedScreens

        } else if(curCat == 1) {

            args["option"] = gnome.checkedOption

        } else if(curCat == 2) {

            if(xfce.checkedScreens.length === 0)
                return

            args["screens"] = xfce.checkedScreens
            args["option"] = xfce.checkedOption

        } else if(curCat == 3) {

            if(enlightenment.checkedScreens.length === 0 || enlightenment.checkedWorkspaces.length === 0)
                return

            args["screens"] = enlightenment.checkedScreens
            args["workspaces"] = enlightenment.checkedWorkspaces

        } else if(curCat == 4) {

            args["app"] = other.checkedTool
            args["option"] = other.checkedOption

        } else if(curCat == 5) {

            args["WallpaperStyle"] = windows.checkedOption

        }

        PQCScriptsWallpaper.setWallpaper(categories[curCat], PQCFileFolderModel.currentFile, args) // qmllint disable unqualified

        hide()
    }

}
