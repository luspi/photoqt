/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../"
import "../../elements"
import "shortcuts"


Item {

    id: tab_top

    property int titlewidth: 100

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

            Item { width: 1; height: 10 }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 20
                font.bold: true
                text: em.pty+qsTr("Shortcuts")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20 }

            SettingsText {
                width: flickable.width-20
                x: 10
                text: em.pty+qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key/mouse combination. The\
 shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain\
 all the possible commands. To add a shortcut for one of the available functions simply click on it. This will automatically open another element\
 where you can set the desired shortcut.")
            }

            Item { width: 1; height: 30 }

            Rectangle { color: "#88ffffff"; width: tab_top.width; height: 1; }

            Item { width: 1; height: 20 }

            CustomButton {
                x: (tab_top.width-width)/2
                text: em.pty+qsTr("Set default shortcuts")
                onClickedButton: confirmdefaultshortcuts.show()
            }

            Item { width: 1; height: 20 }

            Rectangle { color: "#22ffffff"; width: tab_top.width; height: 1 }

            Item { width: 1; height: 10 }

            Entry {

                title: em.pty+qsTr("Mouse: Left Button")
                helptext: em.pty+qsTr("Pressing the left button of the mouse and moving it around can be used for moving an image around. If you put it to use\
 for this purpose then any shortcut involving the left mouse button will have no effect! Note that it is not recommended to disable this if you do\
 not have any other means to move an image around (e.g., touchscreen)!")

                content: [
                    CustomCheckBox {
                        id: mouseleftbutton
                        text: em.pty+qsTr("Mouse: Left button click-and-move")
                    }
                ]

            }

            Item { width: 1; height: 20 }

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
                                    ["__playPauseAni", em.pty+qsTr("Play/Pause image animation")],
                                    ["__tagFaces", em.pty+qsTr("Tag faces (stored in metadata)")]]
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
                                    ["__histogram", em.pty+qsTr("Show Histogram")],
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
