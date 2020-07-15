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
                text: "Shortcuts"
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-30
                wrapMode: Text.WordWrap
                text: "Here the shortcuts can be adjusted, new ones added and existing ones removed. Any key combination or mouse gesture can be used.\nBelow the shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. A click on any available command starts the process of adding a new shortcut."
            }

            PQContainer {
                id: sh_nav
                category: "Navigation"
                available: [["__open", "Open new file"],
                            ["__filterImages", "Filter images in folder", "__filterImages"],
                            ["__next", "Next image", "__next"],
                            ["__prev", "Previous image", "__prev"],
                            ["__gotoFirstThb", "Go to first image", "__gotoFirstThb"],
                            ["__gotoLastThb", "Go to last image", "__gotoLastThb"],
                            ["__close", "Hide to system tray (if enabled)", "__close"],
                            ["__quit", "Quit PhotoQt", "__quit"]]
            }

            PQContainer {
                id: sh_img
                //: A shortcuts category: image manipulation
                category: "Image"
                available: [["__zoomIn", "Zoom In"],
                            ["__zoomOut", "Zoom Out"],
                            ["__zoomActual", "Zoom to Actual Size"],
                            ["__zoomReset", "Reset Zoom"],
                            ["__rotateR", "Rotate Right"],
                            ["__rotateL", "Rotate Left"],
                            ["__rotate0", "Reset Rotation"],
                            ["__flipH", "Flip Horizontally"],
                            ["__flipV", "Flip Vertically"],
                            ["__scale", "Scale Image"],
                            ["__playPauseAni", "Play/Pause image animation"],
                            ["__tagFaces", "Tag faces (stored in metadata)"]]
            }

            PQContainer {
                id: sh_fil
                //: A shortcuts category: file management
                category: "File"
                available: [["__rename", "Rename File"],
                            ["__delete", "Delete File"],
                            ["__deletePermanent", "Delete File (without confirmation)"],
                            ["__copy", "Copy File to a New Location"],
                            ["__move", "Move File to a New Location"],
                            ["__clipboard", "Copy Image to Clipboard"]]
            }

            PQContainer {
                id: sh_oth
                //: A shortcuts category: other functions
                category: "Other"
                available: [["__hideMeta", "Hide/Show Exif Info"],
                            ["__settings", "Show Settings"],
                            ["__slideshow", "Start Slideshow"],
                            ["__slideshowQuick", "Start Slideshow (Quickstart)"],
                            ["__about", "About PhotoQt"],
                            ["__wallpaper", "Set as Wallpaper"],
                            ["__histogram", "Show Histogram"],
                            ["__imgurAnonym", "Upload to imgur.com (anonymously)"],
                            ["__imgur", "Upload to imgur.com user account"]]
            }

            PQContainer {
                id: sh_ext
                //: A shortcuts category: external shortcuts
                category: "External"
                subtitle: "%f = filename including path, %u = filename without path, %d = directory containing file"
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
