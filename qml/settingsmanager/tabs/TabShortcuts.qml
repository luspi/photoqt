import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../elements"
import "shortcuts"


Rectangle {

    id: tab_top

    property int titlewidth: 100

    color: "#00000000"

    anchors {
        fill: parent
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height+20
        contentWidth: maincol.width

        Column {

            id: maincol

            Rectangle { color: "transparent"; width: 1; height: 10; }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 20
                font.bold: true
                text: em.pty+qsTr("Shortcuts")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            SettingsText {
                width: flickable.width-20
                x: 10
                text: em.pty+qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key/mouse combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available functions simply click on it. This will automatically open another element where you can set the desired shortcut.")
            }

            Rectangle { color: "transparent"; width: 1; height: 30; }

            Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            Item {

                height: 50
                width: tab_top.width

                Item {
                    id: leftClickText
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width/2 -20
                    height: childrenRect.height
                    SettingsText {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        text: em.pty+qsTr("Pressing the left button of the mouse and moving it around can be used for moving an image around. If you put it to use for this purpose then any shortcut involving the left mouse button will have no effect! Note that it is not recommended to disable this if you do not have any other means to move an image around (e.g., touchscreen)!")
                    }
                }

                Item {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: parent.width/2 -20
                    height: Math.max(childrenRect.height, leftClickText.height)
                    CustomCheckBox {
                        id: mouseleftbutton
                        y: (Math.max(height,leftClickText.height)-height)/2
                        text: em.pty+qsTr("Mouse: Left button click-and-move")
                    }
                }

            }

            Rectangle { color: "transparent"; width: 1; height: 30; }

            CustomButton {
                x: (parent.width-width)/2
                text: em.pty+qsTr("Set default shortcuts")
                onClickedButton: confirmdefaultshortcuts.show()
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            ShortcutsContainer {
                id: navigation
                //: A shortcuts category: navigating images
                category: em.pty+qsTr("Navigation")
                allAvailableItems: [["__open",em.pty+qsTr("Open New File")],
                                    ["__filterImages",em.pty+qsTr("Filter Images in Folder")],
                                    ["__next",em.pty+qsTr("Next Image")],
                                    ["__prev",em.pty+qsTr("Previous Image")],
                                    ["__gotoFirstThb",em.pty+qsTr("Go to first Image")],
                                    ["__gotoLastThb",em.pty+qsTr("Go to last Image")],
                                    ["__close",em.pty+qsTr("Hide to System Tray (if enabled)")],
                                    ["__quit",em.pty+qsTr("Quit PhotoQt")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: image
                //: A shortcuts category: image manipulation
                category: em.pty+qsTr("Image")
                allAvailableItems: [["__zoomIn", em.pty+qsTr("Zoom In")],
                                    ["__zoomOut", em.pty+qsTr("Zoom Out")],
                                    ["__zoomActual", em.pty+qsTr("Zoom to Actual Size")],
                                    ["__zoomReset", em.pty+qsTr("Reset Zoom")],
                                    ["__rotateR", em.pty+qsTr("Rotate Right")],
                                    ["__rotateL", em.pty+qsTr("Rotate Left")],
                                    ["__rotate0", em.pty+qsTr("Reset Rotation")],
                                    ["__flipH", em.pty+qsTr("Flip Horizontally")],
                                    ["__flipV", em.pty+qsTr("Flip Vertically")],
                                    ["__scale", em.pty+qsTr("Scale Image")],
                                    ["__playPauseAni", em.pty+qsTr("Play/Pause image animation")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: file
                //: A shortcuts category: file management
                category: em.pty+qsTr("File")
                allAvailableItems: [["__rename", em.pty+qsTr("Rename File")],
                                    ["__delete", em.pty+qsTr("Delete File")],
                                    ["__deletePermanent", em.pty+qsTr("Delete File (without confirmation)")],
                                    ["__copy", em.pty+qsTr("Copy File to a New Location")],
                                    ["__move", em.pty+qsTr("Move File to a New Location")],
                                    ["__clipboard", em.pty+qsTr("Copy Image to Clipboard")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: other
                //: A shortcuts category: other functions
                category: em.pty+qsTr("Other")
                allAvailableItems: [["__hideMeta", em.pty+qsTr("Hide/Show Exif Info")],
                                    ["__settings", em.pty+qsTr("Show Settings")],
                                    ["__slideshow", em.pty+qsTr("Start Slideshow")],
                                    ["__slideshowQuick", em.pty+qsTr("Start Slideshow (Quickstart)")],
                                    ["__about", em.pty+qsTr("About PhotoQt")],
                                    ["__wallpaper", em.pty+qsTr("Set as Wallpaper")],
                                    ["__imgurAnonym", em.pty+qsTr("Upload to imgur.com (anonymously)")],
                                    ["__imgur", em.pty+qsTr("Upload to imgur.com user account")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: external
                //: A shortcuts category: external commands
                category: em.pty+qsTr("External")
                external: true
                allAvailableItems: [["", em.pty+qsTr("")]]
            }

        }

    }

    function setData() {

        verboseMessage("SettingsManager/TabShortcuts", "setData()")

        var dat = shortcutshandler.load()

        navigation.setData(dat)
        image.setData(dat)
        file.setData(dat)
        other.setData(dat)
        external.setData(dat)

        mouseleftbutton.checkedButton = settings.leftButtonMouseClickAndMove

    }

    function loadDefault() {

        verboseMessage("SettingsManager/TabShortcuts", "loadDefault()")

        var dat = shortcutshandler.loadDefaults()

        navigation.setData(dat)
        image.setData(dat)
        file.setData(dat)
        other.setData(dat)
        external.setData(dat)

    }

    function saveData() {

        verboseMessage("SettingsManager/TabShortcuts", "saveData()")

        var dat = []

        dat = dat.concat(navigation.saveData())
        dat = dat.concat(image.saveData())
        dat = dat.concat(file.saveData())
        dat = dat.concat(other.saveData())
        dat = dat.concat(external.saveData())

        shortcutshandler.saveShortcuts(dat)

        settings.leftButtonMouseClickAndMove = mouseleftbutton.checkedButton

    }

    function merge_options(obj1,obj2){
        var obj3 = {};
        for (var attrname in obj1)
            obj3[attrname] = obj1[attrname];
        for (attrname in obj2)
            obj3[attrname] = obj2[attrname];
        return obj3;
    }

}
