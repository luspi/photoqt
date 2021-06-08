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
import QtQuick.Controls 2.2

import "./shortcuts"
import "../../elements"

Item {

    id: tab_shortcuts

    property var shortcutsIncludingUnsavedChanges: ({})


    Flickable {

        id: cont

        contentHeight: col.height
        onContentHeightChanged: {
            if(visible)
                settingsmanager_top.scrollBarVisible = scroll.visible
        }

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Column {

            id: col

            x: 10

            spacing: 15

            Item {
                width: 1
                height: 1
            }

            Text {
                id: title
                width: cont.width-30
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Shortcuts")
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-30
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "Here the shortcuts can be adjusted, new ones added and existing ones removed. Any key combination or mouse gesture can be used.") + "\n" + em.pty+qsTranslate("settingsmanager", "Below the shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. A click on any available command starts the process of adding a new shortcut.")
            }

            PQContainer {
                id: sh_nav
                //: A shortcuts category: navigation
                category: em.pty+qsTranslate("settingsmanager", "Navigation")
                            //: Name of shortcut action
                available: [["__open", em.pty+qsTranslate("settingsmanager", "Open new file")],
                            //: Name of shortcut action
                            ["__filterImages", em.pty+qsTranslate("settingsmanager", "Filter images in folder")],
                            //: Name of shortcut action
                            ["__next", em.pty+qsTranslate("settingsmanager", "Next image")],
                            //: Name of shortcut action
                            ["__prev", em.pty+qsTranslate("settingsmanager", "Previous image")],
                            //: Name of shortcut action
                            ["__goToFirst", em.pty+qsTranslate("settingsmanager", "Go to first image")],
                            //: Name of shortcut action
                            ["__goToLast", em.pty+qsTranslate("settingsmanager", "Go to last image")],
                            //: Name of shortcut action
                            ["__viewerMode", em.pty+qsTranslate("settingsmanager", "Enter viewer mode")],
                            //: Name of shortcut action
                            ["__quickNavigation", em.pty+qsTranslate("settingsmanager", "Show quick navigation buttons")],
                            //: Name of shortcut action
                            ["__close", em.pty+qsTranslate("settingsmanager", "Close window (hides to system tray if enabled)")],
                            //: Name of shortcut action
                            ["__quit", em.pty+qsTranslate("settingsmanager", "Quit PhotoQt")]]
            }

            PQContainer {
                id: sh_img
                //: A shortcuts category: image manipulation
                category: em.pty+qsTranslate("settingsmanager", "Image")
                            //: Name of shortcut action
                available: [["__zoomIn", em.pty+qsTranslate("settingsmanager", "Zoom In")],
                            //: Name of shortcut action
                            ["__zoomOut", em.pty+qsTranslate("settingsmanager", "Zoom Out")],
                            //: Name of shortcut action
                            ["__zoomActual", em.pty+qsTranslate("settingsmanager", "Zoom to Actual Size")],
                            //: Name of shortcut action
                            ["__zoomReset", em.pty+qsTranslate("settingsmanager", "Reset Zoom")],
                            //: Name of shortcut action
                            ["__rotateR", em.pty+qsTranslate("settingsmanager", "Rotate Right")],
                            //: Name of shortcut action
                            ["__rotateL", em.pty+qsTranslate("settingsmanager", "Rotate Left")],
                            //: Name of shortcut action
                            ["__rotate0", em.pty+qsTranslate("settingsmanager", "Reset Rotation")],
                            //: Name of shortcut action
                            ["__flipH", em.pty+qsTranslate("settingsmanager", "Flip Horizontally")],
                            //: Name of shortcut action
                            ["__flipV", em.pty+qsTranslate("settingsmanager", "Flip Vertically")],
                            //: Name of shortcut action
                            ["__scale", em.pty+qsTranslate("settingsmanager", "Scale Image")],
                            //: Name of shortcut action
                            ["__playPauseAni", em.pty+qsTranslate("settingsmanager", "Play/Pause animation/video")],
                            //: Name of shortcut action
                            ["__showFaceTags", em.pty+qsTranslate("settingsmanager", "Hide/Show face tags (stored in metadata)")],
                            //: Name of shortcut action
                            ["__tagFaces", em.pty+qsTranslate("settingsmanager", "Tag faces (stored in metadata)")]]
            }

            PQContainer {
                id: sh_fil
                //: A shortcuts category: file management
                category: em.pty+qsTranslate("settingsmanager", "File")
                            //: Name of shortcut action
                available: [["__rename", em.pty+qsTranslate("settingsmanager", "Rename File")],
                            //: Name of shortcut action
                            ["__delete", em.pty+qsTranslate("settingsmanager", "Delete File")],
                            //: Name of shortcut action
                            ["__deletePermanent", em.pty+qsTranslate("settingsmanager", "Delete File (without confirmation)")],
                            //: Name of shortcut action
                            ["__copy", em.pty+qsTranslate("settingsmanager", "Copy File to a New Location")],
                            //: Name of shortcut action
                            ["__move", em.pty+qsTranslate("settingsmanager", "Move File to a New Location")],
                            //: Name of shortcut action
                            ["__clipboard", em.pty+qsTranslate("settingsmanager", "Copy Image to Clipboard")],
                            ["__saveAs", "Save image in another format"]]
            }

            PQContainer {
                id: sh_oth
                //: A shortcuts category: other functions
                category: em.pty+qsTranslate("settingsmanager", "Other")
                            //: Name of shortcut action
                available: [["__showMainMenu", em.pty+qsTranslate("settingsmanager", "Hide/Show main menu")],
                            //: Name of shortcut action
                            ["__showMetaData", em.pty+qsTranslate("settingsmanager", "Hide/Show metadata")],
                            //: Name of shortcut action
                            ["__showThumbnails", em.pty+qsTranslate("settingsmanager", "Hide/Show thumbnails")],
                            //: Name of shortcut action
                            ["__settings", em.pty+qsTranslate("settingsmanager", "Show Settings")],
                            //: Name of shortcut action
                            ["__slideshow", em.pty+qsTranslate("settingsmanager", "Start Slideshow")],
                            //: Name of shortcut action
                            ["__slideshowQuick", em.pty+qsTranslate("settingsmanager", "Start Slideshow (Quickstart)")],
                            //: Name of shortcut action
                            ["__about", em.pty+qsTranslate("settingsmanager", "About PhotoQt")],
                            //: Name of shortcut action
                            ["__wallpaper", em.pty+qsTranslate("settingsmanager", "Set as Wallpaper")],
                            //: Name of shortcut action
                            ["__histogram", em.pty+qsTranslate("settingsmanager", "Show Histogram")],
                            //: Name of shortcut action
                            ["__imgurAnonym", em.pty+qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)")],
                            //: Name of shortcut action
                            ["__imgur", em.pty+qsTranslate("settingsmanager", "Upload to imgur.com user account")]]
            }

            PQContainer {
                id: sh_ext
                //: A shortcuts category: external shortcuts
                category: em.pty+qsTranslate("settingsmanager", "External")
                //: Please leave the three placeholders (%f, %u, %d) as is.
                subtitle: em.pty+qsTranslate("settingsmanager", "%f = filename including path, %u = filename without path, %d = directory containing file")
                thisIsAnExternalCategory: true
            }

            Item { width: 1; height: 50 }

        }

        Connections {
            target: settingsmanager_top
            onIsScrollBarVisible: {
                if(visible)
                    settingsmanager_top.scrollBarVisible = scroll.visible
            }
        }

    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            var allsh = [];
            allsh = allsh.concat(sh_nav.getActiveShortcuts())
            allsh = allsh.concat(sh_img.getActiveShortcuts())
            allsh = allsh.concat(sh_fil.getActiveShortcuts())
            allsh = allsh.concat(sh_oth.getActiveShortcuts())
            allsh = allsh.concat(sh_ext.getActiveShortcuts())
            handlingShortcuts.saveToFile(allsh)
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        var sh = handlingShortcuts.loadFromFile()

        // filter out all shortcuts
        var tmp = ({})
        for(var s in sh) {
            var key = sh[s][1]
            if(key in tmp)
                tmp[key] += 1
            else
                tmp[key] = 1
        }
        shortcutsIncludingUnsavedChanges = tmp

        sh_nav.active = filterOutTheRightOnes(sh, sh_nav.available)
        sh_img.active = filterOutTheRightOnes(sh, sh_img.available)
        sh_fil.active = filterOutTheRightOnes(sh, sh_fil.available)
        sh_oth.active = filterOutTheRightOnes(sh, sh_oth.available)
        sh_ext.active = filterOutExternalShortcuts(sh)

        sh_nav.loadTiles()
        sh_img.loadTiles()
        sh_fil.loadTiles()
        sh_oth.loadTiles()
        sh_ext.loadTiles()
    }

    function filterOutTheRightOnes(allsh, takethese) {
        var ret = []
        for(var i = 0; i < allsh.length; ++i) {
            for(var j = 0; j < takethese.length; ++j) {
                if(takethese[j][0] == allsh[i][2]) {
                    ret.push(allsh[i])
                    break
                }
            }
        }
        return ret
    }

    function filterOutExternalShortcuts(allsh) {
        var ret = []
        for(var i = 0; i < allsh.length; ++i) {
            var found = false
            for(var j = 0; j < sh_nav.available.length; ++j) {
                if(sh_nav.available[j][0] == allsh[i][2]) {
                    found = true
                    break
                }
            }
            if(!found) {
                for(var j = 0; j < sh_img.available.length; ++j) {
                    if(sh_img.available[j][0] == allsh[i][2]) {
                        found = true
                        break
                    }
                }
            }
            if(!found) {
                for(var j = 0; j < sh_fil.available.length; ++j) {
                    if(sh_fil.available[j][0] == allsh[i][2]) {
                        found = true
                        break
                    }
                }
            }
            if(!found) {
                for(var j = 0; j < sh_oth.available.length; ++j) {
                    if(sh_oth.available[j][0] == allsh[i][2]) {
                        found = true
                        break
                    }
                }
            }
            if(!found)
                ret.push(allsh[i])
        }
        return ret
    }

}
