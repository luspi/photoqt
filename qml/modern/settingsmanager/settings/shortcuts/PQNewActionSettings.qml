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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import PQCExtensionsHandler
import PhotoQt.Modern

Item {

    id: newaction_top

    anchors.fill: parent

    SystemPalette { id: pqtPalette }

    Rectangle {
        anchors.fill: parent
        color: pqtPalette.base
        opacity: 0.8
    }

    opacity: 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property var actions

    signal addAction(var idx, var act)
    signal updateAction(var idx, var subidx, var act)

    property list<string> categories: [
        "viewingimages",
        "currentimage",
        "currentfolder",
        "interface",
        "extensions",
        "other",
        "external"
    ]

    property var categoriesToIndex: {
        "viewingimages" : 0,
        "currentimage" : 1,
        "currentfolder" : 2,
        "interface" : 3,
        "extensions" : 4,
        "other" : 5,
        "external" : 6
    }

    property var categoryTitles: {
                          //: This is a shortcut category
        "viewingimages" : qsTranslate("settingsmanager", "Viewing images"),
                          //: This is a shortcut category
        "currentimage"  : qsTranslate("settingsmanager", "Current image"),
                          //: This is a shortcut category
        "currentfolder" : qsTranslate("settingsmanager", "Current folder"),
                          //: This is a shortcut category
        "interface"     : qsTranslate("settingsmanager", "Interface"),
                          //: This is a shortcut category
        "extensions"    : qsTranslate("settingsmanager", "Extensions"),
                          //: This is a shortcut category
        "other"         : qsTranslate("settingsmanager", "Other"),
                          //: This is a shortcut category
        "external"      : qsTranslate("settingsmanager", "External")
    }

    property list<string> descriptions: [
        qsTranslate("settingsmanager", "These actions affect the behavior of PhotoQt when viewing images. They include actions for navigating between images and manipulating the current image (zoom, flip, rotation) amongst others."),
        qsTranslate("settingsmanager", "These actions are certain things that can be done with the currently viewed image. They typically do not affect any of the other images."),
        qsTranslate("settingsmanager", "These actions affect the currently loaded folder as a whole and not just single images."),
        qsTranslate("settingsmanager", "These actions affect the status and behavior of various interface elements regardless of the status of any possibly loaded image."),
        qsTranslate("settingsmanager", "These actions belong to various parts of the application that are not strictly necessary for a simple image viewer. This section will be worked out more over the next releases."),
        qsTranslate("settingsmanager", "These actions do not fit into any other category."),
        qsTranslate("settingsmanager", "Here any external executable can be set as shortcut action. The button with the three dots can be used to select an executable with a file dialog.")
    ]

    property list<var> actionsByCategory: [[], [], [], [], [], [], []]

    property int selectedCategory: 0

    property int currentShortcutIndex: -1
    property int currentShortcutSubIndex: -1
    property string currentShortcutAction: ""

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
            newaction_top.hide()
    }

    PQTextXL {
        id: titletxt
        y: insidecont.y-2*height
        width: parent.width
        font.weight: PQCLook.fontWeightBold 
        horizontalAlignment: Text.AlignHCenter
        text: qsTranslate("settingsmanager", "Shortcut actions")
    }

    Rectangle {

        id: insidecont

        x: (parent.width-width)/2
        y: (parent.height-height)/2-10
        width: Math.min(800, parent.width)
        height: Math.min(600, parent.height-2*titletxt.height-2*butcont.height-40)

        color: pqtPalette.base

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
        }

        ListView {

            id: cattabs

            orientation: ListView.Vertical
            interactive: false

            y: (parent.height-height)/2

            width: 200
            height: insidecont.height

            model: 7

            delegate:
                Rectangle {

                    id: deleg

                    required property int modelData

                    width: cattabs.width
                    height: insidecont.height/7

                    border {
                        width: 1
                        color: pqtPalette.alternateBase
                    }

                    color: newaction_top.selectedCategory===modelData
                                ? pqtPalette.text
                                : (mouse.containsPress||mouse.containsMouse)
                                   ? pqtPalette.alternateBase
                                   : pqtPalette.base
                    Behavior on color { ColorAnimation { duration: 200 } }

                    PQText {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: PQCLook.fontWeightBold 
                        text: newaction_top.categoryTitles[newaction_top.categories[deleg.modelData]]
                        color: newaction_top.selectedCategory===modelData ? pqtPalette.base : pqtPalette.text
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    PQMouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            newaction_top.selectedCategory = deleg.modelData
                        }
                    }
                }
        }

        Rectangle {

            x: cattabs.width
            width: parent.width-cattabs.width
            height: parent.height

            color: pqtPalette.alternateBase
            border.width: 1
            border.color: PQCLook.baseBorder

            PQText {
                id: desclabel
                x: 10
                y: 10
                width: parent.width-20
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: newaction_top.descriptions[newaction_top.selectedCategory]
            }

            // these are categories 1-6, all except external shortcuts
            ListView {
                id: actionsview
                y: desclabel.height+20
                width: parent.width
                height: parent.height-desclabel.height-25
                visible: newaction_top.selectedCategory<6
                orientation: ListView.Vertical
                property list<string> modeldata: newaction_top.actionsByCategory[newaction_top.selectedCategory]
                model: modeldata.length
                spacing: 4
                clip: true
                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }
                delegate:
                    Rectangle {

                        id: actionsdeleg

                        required property int modelData

                        x: 5
                        width: actionsview.width-10-(scroll.visible ? scroll.width : 0)
                        height: dsclabel.height+10
                        radius: 5
                        opacity: (actionmouse.containsMouse||newaction_top.currentShortcutAction===newaction_top.actionsByCategory[newaction_top.selectedCategory][actionsdeleg.modelData][0]) ? 1 : 0.5
                        color: actionmouse.containsMouse ? PQCLook.baseBorder : pqtPalette.base
                        Behavior on color { ColorAnimation { duration: 200 } }
                        PQText {
                            id: dsclabel
                            x: 5
                            y: 5
                            width: parent.width-10
                            text: newaction_top.actionsByCategory[newaction_top.selectedCategory][actionsdeleg.modelData][1]
                            color: pqtPalette.text
                        }
                        PQMouseArea {
                            id: actionmouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if(newaction_top.currentShortcutSubIndex == -1)
                                    newaction_top.addAction(newaction_top.currentShortcutIndex, newaction_top.actionsByCategory[newaction_top.selectedCategory][actionsdeleg.modelData][0])
                                else
                                    newaction_top.updateAction(newaction_top.currentShortcutIndex, newaction_top.currentShortcutSubIndex, newaction_top.actionsByCategory[newaction_top.selectedCategory][actionsdeleg.modelData][0])
                                newaction_top.hide()
                            }
                        }
                    }
            }

            // This is category 6, external shortcuts
            Flickable {

                id: externalview
                y: desclabel.height+20
                width: parent.width - (extscroll.visible ? extscroll.width : 0)
                height: parent.height-desclabel.height-20
                contentHeight: extcol.height
                clip: true
                visible: newaction_top.selectedCategory==5
                ScrollBar.vertical: PQVerticalScrollBar { id: extscroll }

                Column {

                    id: extcol

                    x: 20
                    width: parent.width-40

                    spacing: 10

                    Item {
                        width: 1
                        height: 1
                    }


                    PQText {
                        text: qsTranslate("settingsmanager", "Select an executable")
                        font.weight: PQCLook.fontWeightBold 
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Row {

                        spacing: 5

                        PQLineEdit {
                            id: ext_exe
                            width: 300
                            placeholderText: qsTranslate("settingsmanager", "executable")
                        }

                        PQButton {
                            id: exebut
                            text: "..."
                            tooltip: qsTranslate("settingsmanager", "Click here to select an executable.")
                            onClicked: {

                                var p = "/usr/bin/"
                                if(PQCScriptsConfig.amIOnWindows()) 
                                    p = PQCScriptsFilesPaths.getHomeDir()
                                else if(ext_exe.text.slice(0,1) === "/")
                                    p = PQCScriptsFilesPaths.getDir(ext_exe.text)

                                //: written on button in file picker to select an existing executable file
                                var file = PQCScriptsFilesPaths.openFileFromDialog(qsTranslate("settingsmanager", "Select"), p, [])

                                if(file === "")
                                    return

                                var fname = PQCScriptsFilesPaths.getFilename(file)

                                if(StandardPaths.findExecutable(fname) === file)
                                    ext_exe.text = fname
                                else
                                    ext_exe.text = PQCScriptsFilesPaths.cleanPath(selectExec.file)

                            }
                        }

                    }

                    Item {
                        width: 1
                        height: 1
                    }

                    PQText {
                        width: parent.width
                        text: qsTranslate("settingsmanager", "Additional flags and options to pass on:")
                        font.weight: PQCLook.fontWeightBold 
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }


                    PQLineEdit {
                        id: ext_flags
                        width: 300
                        //: the flags here are parameters specified on the command line
                        placeholderText: qsTranslate("settingsmanager", "additional flags")
                    }

                    PQText {
                        width: parent.width
                        text: qsTranslate("settingsmanager", "Note that relative file paths are not supported, however, you can use the following placeholders:") + "\n" +
                              "%f = " + qsTranslate("settingsmanager", "filename including path") + "\n" +
                              "%u = " + qsTranslate("settingsmanager", "filename without path") + "\n" +
                              "%d = " + qsTranslate("settingsmanager", "directory containing file") + "\n\n" +
                              qsTranslate("settingsmanager", "If you type out a path, make sure to escape spaces accordingly by prepending a backslash:") + " '\\ '"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    PQCheckBox {
                        id: ext_quit
                        text: qsTranslate("settingsmanager", "quit after calling executable")
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    PQButton {
                        id: saveext
                        text: qsTranslate("settingsmanager", "Save external action")
                        onClicked: {
                            var act = ext_exe.text + ":/:/:" + ext_flags.text + ":/:/:" + (ext_quit.checked ? 1 : 0)
                            if(newaction_top.currentShortcutSubIndex == -1)
                                newaction_top.addAction(newaction_top.currentShortcutIndex, act)
                            else
                                newaction_top.updateAction(newaction_top.currentShortcutIndex, newaction_top.currentShortcutSubIndex, act)
                            newaction_top.hide()
                        }
                    }

                }

            }

        }

    }


    Item {

        id: butcont
        x: (parent.width-width)/2
        y: insidecont.y+insidecont.height+height
        width: row.width
        height: row.height

        Row {
            id: row
            spacing: 10
            PQButton {
                id: savebut
                text: genericStringCancel
                onClicked: {
                    newaction_top.hide()
                }
            }
        }

    }

    Connections {

        target: settingsmanager_top 

        function onPassOnShortcuts(mods: string, keys: int) {

            if(!newaction_top.visible) return

            if(exebut.contextmenu.visible) {
                exebut.contextmenu.close()
                return
            } else if(saveext.contextmenu.visible) {
                saveext.contextmenu.close()
                return
            }

            if(keys === Qt.Key_Escape)
                newaction_top.hide()

        }

    }

    Component.onCompleted: {
        // A shortcuts category: actions with current folder

        for(var cmd in newaction_top.actions) {

            var cat = newaction_top.actions[cmd][1]
            var idx = categoriesToIndex[cat]
            var dsc = newaction_top.actions[cmd][0]

            actionsByCategory[idx].push([cmd,dsc])

        }

        var allext = PQCExtensionsHandler.getExtensions()
        for(var i in allext) {

            var ext = allext[i]

            var fullsh = PQCExtensionsHandler.getExtensionShortcutsActions(ext)
            var allsh = PQCExtensionsHandler.getExtensionShortcuts(ext)

            for(var iSh in allsh) {
                var sh = fullsh[iSh]
                actionsByCategory[categoriesToIndex["extensions"]].push([sh[0],sh[1]])
            }


        }

        actionsByCategoryChanged()

    }

    function change(index: int, subindex: int, uniqueid: string) {

        var cur = setting_top.currentEntries[setting_top.idToEntr[uniqueid]][1][subindex]

        if(cur.startsWith("__")) {

            if(cur in setting_top.actions) {
                var cat = categoriesToIndex[setting_top.actions[cur][1]]
                selectedCategory = cat
            } else {
                for(var i in setting_top.extensions) {
                    var ext = setting_top.extensions[i]
                    if(cur in PQCExtensionsHandler.getExtensionShortcuts(ext)) {
                        selectedCategory = "extensions"
                        break;
                    }
                }
            }

        } else {

            selectedCategory = 6

            var parts = cur.split(":/:/:")
            ext_exe.text = parts[0]
            ext_flags.text = parts[1]
            ext_quit.checked = (parts[2]*1==1)

        }

        newaction_top.opacity = 1
        newaction_top.currentShortcutIndex = index
        newaction_top.currentShortcutSubIndex = subindex
        newaction_top.currentShortcutAction = cur

        settingsmanager_top.passShortcutsToDetector = true

    }

    function show(index: int) {

        newaction_top.opacity = 1
        newaction_top.currentShortcutIndex = index
        newaction_top.currentShortcutSubIndex = -1
        newaction_top.currentShortcutAction = ""
        ext_exe.text = ""
        ext_flags.text = ""
        ext_quit.checked = false

        settingsmanager_top.passShortcutsToDetector = true

    }

    function hide() {

        settingsmanager_top.passShortcutsToDetector = false

        newaction_top.opacity = 0

    }

}
