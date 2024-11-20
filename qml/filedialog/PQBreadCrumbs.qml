pragma ComponentBehavior: Bound
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

import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCNotify
import PQCScriptsClipboard

import "../elements"

Item {

    id: breadcrumbs_top

    width: parent.width
    height: 50

    property alias topSettingsMenu: settingsmenu

    property bool folderListMenuOpen: false
    signal closeFolderListMenu()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton|Qt.LeftButton
    }

    Row {

        Item {

            id: leftitem

            width: Math.max(filedialog_top.placesWidth, leftrow.width+10) // qmllint disable unqualified
            height: breadcrumbs_top.height

            Row {

                id: leftrow

                x: 5

                y: (parent.height-height)/2
                spacing: 5

                // spacer item for popout icon
                Item {
                    width: 15
                    height: 1
                }

                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/backwards.svg" // qmllint disable unqualified
                    enabled: filedialog_top.historyIndex>0 // qmllint disable unqualified
                    onClicked:
                        filedialog_top.goBackInHistory() // qmllint disable unqualified
                }
                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/upwards.svg" // qmllint disable unqualified
                    onClicked:
                        filedialog_top.loadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog)) // qmllint disable unqualified
                }
                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg" // qmllint disable unqualified
                    enabled: filedialog_top.historyIndex<filedialog_top.history.length-1 // qmllint disable unqualified
                    onClicked:
                        filedialog_top.goForwardsInHistory() // qmllint disable unqualified
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseColorActive // qmllint disable unqualified
                    }

                }

                PQButtonIcon {
                    id: iconview
                    checkable: true
                    checked: PQCSettings.filedialogLayout==="icons" // qmllint disable unqualified
                    source: "image://svg/:/" + PQCLook.iconShade + "/iconview.svg" // qmllint disable unqualified
                    tooltip: qsTranslate("filedialog", "Show files as icons")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified
                        PQCSettings.filedialogLayout = (checked ? "icons" : "list")
                        checked = Qt.binding(function() { return PQCSettings.filedialogLayout==="icons" })
                    }
                }

                PQButtonIcon {
                    id: listview
                    checkable: true
                    checked: PQCSettings.filedialogLayout!=="icons" // qmllint disable unqualified
                    source: "image://svg/:/" + PQCLook.iconShade + "/listview.svg" // qmllint disable unqualified
                    tooltip: qsTranslate("filedialog", "Show files as list")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified
                        PQCSettings.filedialogLayout = (checked ? "list" : "icons")
                        checked = Qt.binding(function() { return PQCSettings.filedialogLayout==="list" })
                    }
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseColorActive // qmllint disable unqualified
                    }

                }

                PQButtonIcon {
                    id: settings
                    checkable: true
                    source: "image://svg/:/" + PQCLook.iconShade + "/settings.svg" // qmllint disable unqualified
                    tooltip: qsTranslate("filedialog", "Settings")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified
                        if(checked)
                            settingsmenu.popup(0, height)
                    }

                    PQSettingsMenu {
                        id: settingsmenu
                    }

                }


            }

        }

        Rectangle {
            width: 8
            height: breadcrumbs_top.height
            color: PQCLook.baseColorAccent // qmllint disable unqualified
        }

        Item {

            id: rightitem

            width: Math.min(filedialog_top.fileviewWidth, breadcrumbs_top.width-leftitem.width-8) // qmllint disable unqualified
            height: breadcrumbs_top.height

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                enabled: !addressedit.visible
                visible: !addressedit.visible
                onClicked: {
                    addressedit.show()
                }
            }

            Flickable {

                height: parent.height
                width: Math.min(contentWidth, parent.width-editbutton.width-10)
                contentWidth: crumbs.width
                onWidthChanged: {
                    if(contentWidth > width)
                        contentX = (contentWidth-width)
                }

                ScrollBar.horizontal: PQHorizontalScrollBar {}

                clip: true

                Row {

                    id: crumbs

                    y: (parent.height-height)/2

                    property bool windows: PQCScriptsConfig.amIOnWindows() // qmllint disable unqualified
                    property bool isNetwork: windows && PQCFileFolderModel.folderFileDialog.startsWith("//") // qmllint disable unqualified

                    property list<string> parts: !windows&&PQCFileFolderModel.folderFileDialog==="/" ? ["/"] : (isNetwork ? PQCFileFolderModel.folderFileDialog.substr(1).split("/") : PQCFileFolderModel.folderFileDialog.split("/")) // qmllint disable unqualified

                    Repeater {

                        model: crumbs.parts[crumbs.parts.length-1] !== "" ? crumbs.parts.length : crumbs.parts.length-1

                        Row {

                            id: deleg

                            required property int modelData

                            property string subdir: {
                                var p = ""
                                if(crumbs.windows) {
                                    for(var i = 0; i <= modelData; ++i) {
                                        if(p != "") p += "/"
                                        p += crumbs.parts[i]
                                    }
                                    if(PQCFileFolderModel.folderFileDialog.startsWith("//") && !p.startsWith("/")) // qmllint disable unqualified
                                        p = "//"+p
                                    return p
                                } else {
                                    if(modelData === 0)
                                        return "/"
                                    p = ""
                                    for(var j = 1; j <= modelData; ++j)
                                        p += "/"+crumbs.parts[j]
                                    return p
                                }
                            }

                            Rectangle {
                                height: breadcrumbs_top.height
                                width: folder.text==="" ? 0 : (folder.width+20)
                                color: (mousearea2.containsPress ? PQCLook.baseColorActive : (mousearea2.containsMouse ? PQCLook.baseColorHighlight : PQCLook.baseColor)) // qmllint disable unqualified
                                Behavior on color { ColorAnimation { duration: 200 } }
                                PQText {
                                    id: folder
                                    x: 10
                                    y: (parent.height-height)/2
                                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                    text: deleg.modelData===0&&!crumbs.windows ? "/" : crumbs.parts[deleg.modelData]
                                }
                                PQMouseArea {
                                    id: mousearea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: filedialog_top.loadNewPath(deleg.subdir) // qmllint disable unqualified
                                    enabled: (deleg.modelData<2 && crumbs.isNetwork) ? false : true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                }
                            }

                            Rectangle {
                                height: breadcrumbs_top.height
                                width: height*2/3
                                property bool down: folderlist.visible
                                color: (down ? PQCLook.baseColorActive : (mousearea.containsMouse ? PQCLook.baseColorHighlight : PQCLook.baseColor)) // qmllint disable unqualified
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Image {
                                    property real fact: (deleg.modelData===0 && crumbs.isNetwork) ? 1.5 : 3
                                    x: (parent.width-width)/2
                                    y: (parent.height-height)/2
                                    width: parent.width*(1/fact)
                                    height: parent.height*(1/fact)
                                    smooth: false
                                    fillMode: Image.PreserveAspectFit
                                    source: (deleg.modelData===0 && crumbs.isNetwork) ? ("image://svg/:/" + PQCLook.iconShade + "/network.svg") : ("image://svg/:/" + PQCLook.iconShade + "/breadcrumb.svg") // qmllint disable unqualified
                                    sourceSize: Qt.size(width, height)
                                }
                                PQMouseArea {
                                    id: mousearea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: (deleg.modelData<2 && crumbs.isNetwork) ? false : true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: (pos) => {
                                        folderlist.popup(0,height)
                                    }
                                }

                                PQMenu {
                                    id: folderlist
                                    property var subfolders: []
                                    PQMenuItem {
                                        text: qsTranslate("filedialog", "no subfolders found")
                                        font.italic: true
                                        enabled: false
                                        visible: folderlist.subfolders.length==0
                                        height: visible ? 40 : 0
                                    }

                                    Instantiator {
                                        id: inst
                                        property string currentParentFolder: ""
                                        delegate: PQMenuItem {
                                            id: menuItem
                                            required property string modelData
                                            text: modelData
                                            onTriggered: filedialog_top.loadNewPath(PQCScriptsFilesPaths.cleanPath(deleg.subdir+"/"+text)) // qmllint disable unqualified
                                        }

                                        onObjectAdded: (index, object) => folderlist.insertItem(index, object)
                                        onObjectRemoved: (index, object) => folderlist.removeItem(object)

                                    }
                                    onAboutToShow: {
                                        if(inst.model === 0 || inst.currentParentFolder != deleg.subdir) {
                                            subfolders = PQCScriptsFilesPaths.getFoldersIn(deleg.subdir) // qmllint disable unqualified
                                            inst.model = subfolders
                                            inst.currentParentFolder = deleg.subdir
                                        }
                                        folderListMenuOpen = true
                                    }
                                    onAboutToHide:
                                        breadcrumbs_top.folderListMenuOpen = false
                                    Connections {
                                        target: filedialog_top // qmllint disable unqualified
                                        function onOpacityChanged() {
                                            if(filedialog_top.opacity<1) // qmllint disable unqualified
                                                folderlist.close()
                                        }
                                    }
                                    Connections {
                                        target: breadcrumbs_top
                                        function onCloseFolderListMenu() {
                                            folderlist.close()
                                        }
                                    }
                                }
                            }

                        }

                    }

                }
            }

            Row {

                x: 5
                spacing: 5

                PQLineEdit {
                    id: addressedit
                    y: 5
                    width: rightitem.width-10 - editbutton.width-5
                    height: rightitem.height-10
                    radius: 5
                    visible: false
                    highlightBG: true
                    fontBold: true
                    keepPlaceholderTextVisible: true
                    placeholderText: completedPath

                    property string completedPath: ""

                    function show() {
                        if(addressedit.visible)
                            return
                        completedPath = ""
                        text = PQCScriptsFilesPaths.pathWithNativeSeparators(PQCFileFolderModel.folderFileDialog) // qmllint disable unqualified
                        breadcrumbs_top.checkValidEditPath()
                        crumbs.visible = false
                        visible = true
                        setFocus()
                        PQCNotify.ignoreKeysExceptEnterEsc = true // qmllint disable unqualified
                    }

                    function hide() {
                        if(crumbs.visible)
                            return
                        crumbs.visible = true
                        visible = false
                        PQCNotify.ignoreKeysExceptEnterEsc = false // qmllint disable unqualified
                    }

                    onRightPressed: {
                        if(completedPath !== "" && isCursorAtEnd()) {
                            var txt = text
                            var missing = PQCScriptsFilesPaths.pathWithNativeSeparators(completedPath.substring(txt.length)) // qmllint disable unqualified
                            lineedit.insert(text.length, missing[0])
                        }
                    }

                    onEndPressed: {
                        if(completedPath !== "" && isCursorAtEnd())
                            lineedit.insert(text.length, PQCScriptsFilesPaths.pathWithNativeSeparators(completedPath).replace(text, "")) // qmllint disable unqualified
                    }

                    onTextChanged:
                        breadcrumbs_top.checkValidEditPath()

                    onRightClicked: {
                        contextmenu.popup()
                    }

                }

                PQMenu {

                    id: contextmenu

                    Connections {
                        target: filedialog_top // qmllint disable unqualified
                        function onOpacityChanged() {
                            if(filedialog_top.opacity<1) // qmllint disable unqualified
                                contextmenu.close()
                        }
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateleft.svg" // qmllint disable unqualified
                        text: "Undo"
                        enabled: addressedit.lineedit.canUndo
                        onTriggered:
                            addressedit.lineedit.undo()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateright.svg" // qmllint disable unqualified
                        text: "Redo"
                        enabled: addressedit.lineedit.canRedo
                        onTriggered:
                            addressedit.lineedit.redo()
                    }

                    PQMenuSeparator {}

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/cut.svg" // qmllint disable unqualified
                        text: "Cut"
                        enabled: addressedit.lineedit.selectedText.length>0
                        onTriggered:
                            addressedit.actionCut()

                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
                        text: "Copy"
                        enabled: addressedit.lineedit.selectedText.length>0
                        onTriggered:
                            addressedit.actionCopy()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg" // qmllint disable unqualified
                        text: "Paste"
                        enabled: addressedit.lineedit.canPaste
                        onTriggered:
                            addressedit.actionPaste()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg" // qmllint disable unqualified
                        text: "Delete"
                        onTriggered:
                            addressedit.actionDelete()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/quit.svg" // qmllint disable unqualified
                        text: "Clear"
                        onTriggered:
                            addressedit.lineedit.remove(0,addressedit.text.length)
                    }

                    PQMenuSeparator {}

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/leftrightarrow.svg" // qmllint disable unqualified
                        text: "Select all"
                        onTriggered:
                            addressedit.setFocus()
                    }

                }

                Item {
                    width: addressedit.width
                    height: addressedit.height
                    visible: !addressedit.visible
                }

                PQButtonIcon {
                    id: editbutton
                    y: 10
                    width: rightitem.height-20
                    height: rightitem.height-20
                    source: addressedit.visible ? ("image://svg/:/" + PQCLook.iconShade + "/checkmark.svg") : ("image://svg/:/" + PQCLook.iconShade + "/editpath.svg") // qmllint disable unqualified
                    onClicked: {
                        if(!addressedit.visible)
                            addressedit.show()
                        else {
                            if(!addressedit.warning)
                                breadcrumbs_top.loadEditPath()
                            addressedit.hide()
                        }
                    }
                }

            }

        }

    }

    Rectangle {
        y: parent.height-1
        width: parent.width
        height: 1
        color: PQCLook.baseColorActive // qmllint disable unqualified
    }

    function checkValidEditPath() {

        var completeWithoutFolder = false

        var path = PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.pathFromNativeSeparators(addressedit.text)) // qmllint disable unqualified
        if(PQCScriptsFilesPaths.getFilename(path) === path) {
            completeWithoutFolder = true
            path = PQCFileFolderModel.folderFileDialog + "/" + path
        }

        if(PQCScriptsFilesPaths.doesItExist(path)) {
            if(addressedit.completedPath === addressedit.text)
                addressedit.completedPath = ""
            addressedit.warning = false
            return
        }

        var firstmatch = PQCFileFolderModel.getFirstMatchFileDialog(PQCScriptsFilesPaths.pathFromNativeSeparators(path))

        if(firstmatch !== "") {
            addressedit.warning = false
            if(completeWithoutFolder)
                addressedit.completedPath = PQCScriptsFilesPaths.pathWithNativeSeparators(firstmatch.replace(PQCFileFolderModel.folderFileDialog+"/", ""))
            else
                addressedit.completedPath = PQCScriptsFilesPaths.pathWithNativeSeparators(firstmatch)
            return
        }

        addressedit.warning = true
        addressedit.completedPath = ""

    }

    function loadEditPath() {

        var path = ""
        if(addressedit.completedPath !== "")
            path = PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.pathFromNativeSeparators(addressedit.completedPath)) // qmllint disable unqualified
        else
            path = PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.pathFromNativeSeparators(addressedit.text))

        if(path.endsWith("/"))
            path = path.substring(0, path.length-1)

        if(PQCScriptsFilesPaths.getFilename(path) === path)
            path = PQCFileFolderModel.folderFileDialog + "/" + path

        if(PQCScriptsFilesPaths.isFolder(path))
            filedialog_top.loadNewPath(path)
        else {
            filedialog_top.loadNewPath(PQCScriptsFilesPaths.getDir(path))
            PQCFileFolderModel.fileInFolderMainView = path
            filedialog_top.hideFileDialog()
        }
    }

    function handleKeyEvent(key : int, mod : int) {

        // load new path
        if(key === Qt.Key_Enter || key === Qt.Key_Return) {
            if(addressedit.warning)
                return
            loadEditPath()
            addressedit.hide()

        // handle text events
        } else
            addressedit.handleKeyEvents(key, mod)

    }

    function isEditVisible() : bool {
        return addressedit.visible
    }

    function disableAddressEdit() {
        addressedit.hide()
    }

    function enableAddressEdit() {
        addressedit.show()
    }

}
