import QtQuick 2.9
import QtQuick.Controls 2.2

import "./shortcuts"

Item {

    property bool activeShortcutsLoaded: false

    Flickable {

        id: cont

        contentHeight: col.height

        anchors.fill: parent
        anchors.margins: 10

        Column {

            id: col

            spacing: 15

            Text {
                id: title
                width: cont.width
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
                width: cont.width
                wrapMode: Text.WordWrap
                text: "All the shortcuts."
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

            Item { width: 1; height: 10 }

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

            Item { width: 1; height: 10 }

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

        }

    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {

            if(!activeShortcutsLoaded) {

                var sh = handlingShortcuts.loadFromFile()

                sh_nav.active = filterOutTheRightOnes(sh, sh_nav.available)
                sh_img.active = filterOutTheRightOnes(sh, sh_img.available)
                sh_fil.active = filterOutTheRightOnes(sh, sh_fil.available)
                sh_oth.active = filterOutTheRightOnes(sh, sh_oth.available)

                activeShortcutsLoaded = true

            }

            sh_nav.loadTiles()
            sh_img.loadTiles()
            sh_fil.loadTiles()
            sh_oth.loadTiles()

        }

        onSaveAllSettings: {
        }

    }

    function filterOutTheRightOnes(allsh, takethese) {
        var ret = []
        for(var i = 0; i < allsh.length; ++i) {
            var found = false
            for(var j = 0; j < takethese.length; ++j) {
                if(takethese[j][0] == allsh[i][2]) {
                    ret.push(allsh[i])
                    break
                }
            }
        }
        return ret
    }

}
