import QtQuick 2.9
import QtQuick.Controls 2.2

import "./shortcuts"
import "../../elements"

Item {

    property bool activeShortcutsLoaded: false

    Flickable {

        id: cont

        contentHeight: col.height

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Column {

            id: col

            x: 10

            spacing: 15

            Text {
                id: title
                width: cont.width-30
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Shortcuts")
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-30
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "Here the shortcuts can be adjusted, new ones added and existing ones removed. Any key combination or mouse gesture can be used.\nBelow the shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. A click on any available command starts the process of adding a new shortcut.")
            }

            PQContainer {
                id: sh_nav
                category: em.pty+qsTranslate("settingsmanager", "Navigation")
                available: [["__open", em.pty+qsTranslate("settingsmanager", "Open new file")],
                            ["__filterImages", em.pty+qsTranslate("settingsmanager", "Filter images in folder"), "__filterImages"],
                            ["__next", em.pty+qsTranslate("settingsmanager", "Next image"), "__next"],
                            ["__prev", em.pty+qsTranslate("settingsmanager", "Previous image"), "__prev"],
                            ["__gotoFirstThb", em.pty+qsTranslate("settingsmanager", "Go to first image"), "__gotoFirstThb"],
                            ["__gotoLastThb", em.pty+qsTranslate("settingsmanager", "Go to last image"), "__gotoLastThb"],
                            ["__close", em.pty+qsTranslate("settingsmanager", "Hide to system tray (if enabled)"), "__close"],
                            ["__quit", em.pty+qsTranslate("settingsmanager", "Quit PhotoQt"), "__quit"]]
            }

            PQContainer {
                id: sh_img
                //: A shortcuts category: image manipulation
                category: em.pty+qsTranslate("settingsmanager", "Image")
                available: [["__zoomIn", em.pty+qsTranslate("settingsmanager", "Zoom In")],
                            ["__zoomOut", em.pty+qsTranslate("settingsmanager", "Zoom Out")],
                            ["__zoomActual", em.pty+qsTranslate("settingsmanager", "Zoom to Actual Size")],
                            ["__zoomReset", em.pty+qsTranslate("settingsmanager", "Reset Zoom")],
                            ["__rotateR", em.pty+qsTranslate("settingsmanager", "Rotate Right")],
                            ["__rotateL", em.pty+qsTranslate("settingsmanager", "Rotate Left")],
                            ["__rotate0", em.pty+qsTranslate("settingsmanager", "Reset Rotation")],
                            ["__flipH", em.pty+qsTranslate("settingsmanager", "Flip Horizontally")],
                            ["__flipV", em.pty+qsTranslate("settingsmanager", "Flip Vertically")],
                            ["__scale", em.pty+qsTranslate("settingsmanager", "Scale Image")],
                            ["__playPauseAni", em.pty+qsTranslate("settingsmanager", "Play/Pause animation/video")],
                            ["__tagFaces", em.pty+qsTranslate("settingsmanager", "Tag faces (stored in metadata)")]]
            }

            PQContainer {
                id: sh_fil
                //: A shortcuts category: file management
                category: em.pty+qsTranslate("settingsmanager", "File")
                available: [["__rename", em.pty+qsTranslate("settingsmanager", "Rename File")],
                            ["__delete", em.pty+qsTranslate("settingsmanager", "Delete File")],
                            ["__deletePermanent", em.pty+qsTranslate("settingsmanager", "Delete File (without confirmation)")],
                            ["__copy", em.pty+qsTranslate("settingsmanager", "Copy File to a New Location")],
                            ["__move", em.pty+qsTranslate("settingsmanager", "Move File to a New Location")],
                            ["__clipboard", em.pty+qsTranslate("settingsmanager", "Copy Image to Clipboard")]]
            }

            PQContainer {
                id: sh_oth
                //: A shortcuts category: other functions
                category: em.pty+qsTranslate("settingsmanager", "Other")
                available: [["__hideMeta", em.pty+qsTranslate("settingsmanager", "Hide/Show Exif Info")],
                            ["__settings", em.pty+qsTranslate("settingsmanager", "Show Settings")],
                            ["__slideshow", em.pty+qsTranslate("settingsmanager", "Start Slideshow")],
                            ["__slideshowQuick", em.pty+qsTranslate("settingsmanager", "Start Slideshow (Quickstart)")],
                            ["__about", em.pty+qsTranslate("settingsmanager", "About PhotoQt")],
                            ["__wallpaper", em.pty+qsTranslate("settingsmanager", "Set as Wallpaper")],
                            ["__histogram", em.pty+qsTranslate("settingsmanager", "Show Histogram")],
                            ["__imgurAnonym", em.pty+qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)")],
                            ["__imgur", em.pty+qsTranslate("settingsmanager", "Upload to imgur.com user account")]]
            }

            PQContainer {
                id: sh_ext
                //: A shortcuts category: external shortcuts
                category: em.pty+qsTranslate("settingsmanager", "External")
                subtitle: em.pty+qsTranslate("settingsmanager", "%f = filename including path, %u = filename without path, %d = directory containing file")
                thisIsAnExternalCategory: true
            }

            Item { width: 1; height: 50 }

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
