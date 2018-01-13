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
                text: qsTr("Shortcuts")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            SettingsText {
                width: flickable.width-20
                x: 10
                text: qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key/mouse combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available functions simply click on it. This will automatically open another element where you can set the desired shortcut.")
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
                        text: qsTr("Pressing the left button of the mouse and moving it around can be used for moving an image around. If you put them to use for this purpose, then any mouse shortcut set to a button/gesture will have no effect! Note that this is not recommended if you do not have any other means to move an image around (e.g., touchscreen)!")
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
                        text: qsTr("Mouse: Left button click-and-move")
                    }
                }

            }

            Rectangle { color: "transparent"; width: 1; height: 30; }

            CustomButton {
                x: (parent.width-width)/2
                text: qsTr("Set default shortcuts")
                onClickedButton: confirmdefaultshortcuts.show()
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            ShortcutsContainer {
                id: navigation
                //: A shortcuts category: navigating images
                category: qsTr("Navigation")
                allAvailableItems: [["__open",qsTr("Open New File")],
                                    ["__filterImages",qsTr("Filter Images in Folder")],
                                    ["__next",qsTr("Next Image")],
                                    ["__prev",qsTr("Previous Image")],
                                    ["__gotoFirstThb",qsTr("Go to first Image")],
                                    ["__gotoLastThb",qsTr("Go to last Image")],
                                    ["__hide",qsTr("Hide to System Tray")],
                                    ["__close",qsTr("Quit PhotoQt")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: image
                //: A shortcuts category: image manipulation
                category: qsTr("Image")
                allAvailableItems: [["__zoomIn", qsTr("Zoom In")],
                                    ["__zoomOut", qsTr("Zoom Out")],
                                    ["__zoomActual", qsTr("Zoom to Actual Size")],
                                    ["__zoomReset", qsTr("Reset Zoom")],
                                    ["__rotateR", qsTr("Rotate Right")],
                                    ["__rotateL", qsTr("Rotate Left")],
                                    ["__rotate0", qsTr("Reset Rotation")],
                                    ["__flipH", qsTr("Flip Horizontally")],
                                    ["__flipV", qsTr("Flip Vertically")],
                                    ["__scale", qsTr("Scale Image")],
                                    ["__playPauseAni", qsTr("Play/Pause image animation")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: file
                //: A shortcuts category: file management
                category: qsTr("File")
                allAvailableItems: [["__rename", qsTr("Rename File")],
                                    ["__delete", qsTr("Delete File")],
                                    ["__deletePermanent", qsTr("Delete File (without confirmation)")],
                                    ["__copy", qsTr("Copy File to a New Location")],
                                    ["__move", qsTr("Move File to a New Location")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: other
                //: A shortcuts category: other functions
                category: qsTr("Other")
                allAvailableItems: [["__stopThb", qsTr("Interrupt Thumbnail Creation")],
                                    ["__reloadThb", qsTr("Reload Thumbnails")],
                                    ["__hideMeta", qsTr("Hide/Show Exif Info")],
                                    ["__settings", qsTr("Show Settings")],
                                    ["__slideshow", qsTr("Start Slideshow")],
                                    ["__slideshowQuick", qsTr("Start Slideshow (Quickstart)")],
                                    ["__about", qsTr("About PhotoQt")],
                                    ["__wallpaper", qsTr("Set as Wallpaper")],
                                    ["__imgurAnonym", qsTr("Upload to imgur.com (anonymously)")],
                                    ["__imgur", qsTr("Upload to imgur.com user account")]]
            }

            Item { width: 1; height: 10 }

            ShortcutsContainer {
                id: external
                //: A shortcuts category: external commands
                category: qsTr("External")
                external: true
                allAvailableItems: [["", qsTr("")]]
            }

        }

    }

    function setData() {

        var dat = shortcutshandler.load()

        navigation.setData(dat)
        image.setData(dat)
        file.setData(dat)
        other.setData(dat)
        external.setData(dat)

        mouseleftbutton.checkedButton = settings.leftButtonMouseClickAndMove

    }

    function loadDefault() {

        var dat = shortcutshandler.loadDefaults()

        navigation.setData(dat)
        image.setData(dat)
        file.setData(dat)
        other.setData(dat)
        external.setData(dat)

    }

    function saveData() {

        var dat = [[]]

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
