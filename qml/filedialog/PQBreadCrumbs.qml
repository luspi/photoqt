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
import "../elements"

import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCNotify
import PQCScriptsClipboard

Item {

    id: breadcrumbs_top

    width: parent.width
    height: 50

    property alias topSettingsMenu: settingsmenu

    property bool folderListMenuOpen: false
    signal closeFolderListMenu()

    Row {

        Item {

            id: leftitem

            width: Math.max(placesWidth, leftrow.width+10)
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
                    source: "image://svg/:/white/backwards.svg"
                    enabled: filedialog_top.historyIndex>0
                    onClicked:
                        filedialog_top.goBackInHistory()
                }
                PQButtonIcon {
                    source: "image://svg/:/white/upwards.svg"
                    onClicked:
                        filedialog_top.loadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
                }
                PQButtonIcon {
                    source: "image://svg/:/white/forwards.svg"
                    enabled: filedialog_top.historyIndex<filedialog_top.history.length-1
                    onClicked:
                        filedialog_top.goForwardsInHistory()
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseColorActive
                    }

                }

                PQButtonIcon {
                    id: iconview
                    checkable: true
                    checked: PQCSettings.filedialogLayout==="icons"
                    source: "image://svg/:/white/iconview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as icons")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
                        PQCSettings.filedialogLayout = (checked ? "icons" : "list")
                        checked = Qt.binding(function() { return PQCSettings.filedialogLayout==="icons" })
                    }
                }

                PQButtonIcon {
                    id: listview
                    checkable: true
                    checked: PQCSettings.filedialogLayout!=="icons"
                    source: "image://svg/:/white/listview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as list")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
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
                        color: PQCLook.baseColorActive
                    }

                }

                PQButtonIcon {
                    id: remember
                    checkable: true
                    checked: PQCSettings.filedialogKeepLastLocation
                    source: "image://svg/:/white/remember.svg"
                    onClicked:
                        fd_breadcrumbs.disableAddressEdit()
                    onCheckedChanged:
                        PQCSettings.filedialogKeepLastLocation = checked
                }

                PQButtonIcon {
                    id: settings
                    checkable: true
                    source: "image://svg/:/white/settings.svg"
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
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
            color: PQCLook.baseColorAccent
        }

        Item {

            id: rightitem

            width: Math.min(fileviewWidth, breadcrumbs_top.width-leftitem.width-8)
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

                    property bool windows: PQCScriptsConfig.amIOnWindows()
                    property bool isNetwork: windows && PQCFileFolderModel.folderFileDialog.startsWith("//")

                    property var parts: !windows&&PQCFileFolderModel.folderFileDialog==="/" ? ["/"] : (isNetwork ? PQCFileFolderModel.folderFileDialog.substr(1).split("/") : PQCFileFolderModel.folderFileDialog.split("/"))

                    Repeater {

                        model: crumbs.parts.length

                        Row {

                            id: deleg
                            property string subdir: {
                                var p = ""
                                if(crumbs.windows) {
                                    for(var i = 0; i <= index; ++i) {
                                        if(p != "") p += "/"
                                        p += crumbs.parts[i]
                                    }
                                    if(PQCFileFolderModel.folderFileDialog.startsWith("//") && !p.startsWith("/"))
                                        p = "//"+p
                                    return p
                                } else {
                                    if(index === 0)
                                        return "/"
                                    p = ""
                                    for(var j = 1; j <= index; ++j)
                                        p += "/"+crumbs.parts[j]
                                    return p
                                }
                            }

                            Rectangle {
                                height: breadcrumbs_top.height
                                width: folder.text==="" ? 0 : (folder.width+20)
                                color: (mousearea2.containsPress ? PQCLook.baseColorActive : (mousearea2.containsMouse ? PQCLook.baseColorHighlight : PQCLook.baseColor))
                                Behavior on color { ColorAnimation { duration: 200 } }
                                PQText {
                                    id: folder
                                    x: 10
                                    y: (parent.height-height)/2
                                    font.weight: PQCLook.fontWeightBold
                                    text: index===0&&!crumbs.windows ? "/" : crumbs.parts[index]
                                }
                                PQMouseArea {
                                    id: mousearea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: filedialog_top.loadNewPath(deleg.subdir)
                                    enabled: (index<2 && crumbs.isNetwork) ? false : true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                }
                            }

                            Rectangle {
                                height: breadcrumbs_top.height
                                width: height*2/3
                                property bool down: folderlist.visible
                                color: (down ? PQCLook.baseColorActive : (mousearea.containsMouse ? PQCLook.baseColorHighlight : PQCLook.baseColor))
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Image {
                                    property real fact: (index===0 && crumbs.isNetwork) ? 1.5 : 3
                                    x: (parent.width-width)/2
                                    y: (parent.height-height)/2
                                    width: parent.width*(1/fact)
                                    height: parent.height*(1/fact)
                                    smooth: false
                                    fillMode: Image.PreserveAspectFit
                                    source: (index===0 && crumbs.isNetwork) ? "image://svg/:/white/network.svg" : "image://svg/:/white/breadcrumb.svg"
                                    sourceSize: Qt.size(width, height)
                                }
                                PQMouseArea {
                                    id: mousearea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: (index<2 && crumbs.isNetwork) ? false : true
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
                                        model: 0
                                        delegate: PQMenuItem {
                                            id: menuItem
                                            text: folderlist.subfolders[modelData]
                                            onTriggered: filedialog_top.loadNewPath(PQCScriptsFilesPaths.cleanPath(deleg.subdir+"/"+text))
                                        }

                                        onObjectAdded: (index, object) => folderlist.insertItem(index, object)
                                        onObjectRemoved: (index, object) => folderlist.removeItem(object)

                                    }
                                    onAboutToShow: {
                                        subfolders = PQCScriptsFilesPaths.getFoldersIn(deleg.subdir)
                                        inst.model = 0
                                        inst.model = subfolders.length
                                        folderListMenuOpen = true
                                    }
                                    onAboutToHide:
                                        folderListMenuOpen = false
                                    Connections {
                                        target: filedialog_top
                                        function onOpacityChanged() {
                                            if(filedialog_top.opacity<1)
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
                        text = PQCScriptsFilesPaths.pathWithNativeSeparators(PQCFileFolderModel.folderFileDialog)
                        checkValidEditPath()
                        crumbs.visible = false
                        visible = true
                        setFocus()
                        PQCNotify.ignoreKeysExceptEnterEsc = true
                    }

                    function hide() {
                        if(crumbs.visible)
                            return
                        crumbs.visible = true
                        visible = false
                        PQCNotify.ignoreKeysExceptEnterEsc = false
                    }

                    onRightPressed: {
                        if(completedPath !== "" && isCursorAtEnd()) {
                            var txt = text
                            var missing = PQCScriptsFilesPaths.pathWithNativeSeparators(completedPath.substring(txt.length))
                            lineedit.insert(text.length, missing[0])
                        }
                    }

                    onEndPressed: {
                        if(completedPath !== "" && isCursorAtEnd())
                            lineedit.insert(text.length, PQCScriptsFilesPaths.pathWithNativeSeparators(completedPath).replace(text, ""))
                    }

                    onTextChanged:
                        checkValidEditPath()

                    onRightClicked: {
                        contextmenu.popup()
                    }

                }

                PQMenu {

                    id: contextmenu

                    Connections {
                        target: filedialog_top
                        function onOpacityChanged() {
                            if(filedialog_top.opacity<1)
                                contextmenu.close()
                        }
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/white/rotateleft.svg"
                        text: "Undo"
                        enabled: addressedit.lineedit.canUndo
                        onClicked:
                            addressedit.lineedit.undo()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/white/rotateright.svg"
                        text: "Redo"
                        enabled: addressedit.lineedit.canRedo
                        onClicked:
                            addressedit.lineedit.redo()
                    }

                    PQMenuSeparator {}

                    PQMenuItem {
                        iconSource: "image://svg/:/white/cut.svg"
                        text: "Cut"
                        enabled: addressedit.lineedit.selectedText.length>0
                        onClicked:
                            addressedit.actionCut()

                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/white/copy.svg"
                        text: "Copy"
                        enabled: addressedit.lineedit.selectedText.length>0
                        onClicked:
                            addressedit.actionCopy()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/white/clipboard.svg"
                        text: "Paste"
                        enabled: addressedit.lineedit.canPaste
                        onClicked:
                            addressedit.actionPaste()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/white/delete.svg"
                        text: "Delete"
                        onClicked:
                            addressedit.actionDelete()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/white/quit.svg"
                        text: "Clear"
                        onClicked:
                            addressedit.lineedit.remove(0,addressedit.text.length)
                    }

                    PQMenuSeparator {}

                    PQMenuItem {
                        iconSource: "image://svg/:/white/leftrightarrow.svg"
                        text: "Select all"
                        onClicked:
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
                    source: addressedit.visible ? "image://svg/:/white/checkmark.svg" : "image://svg/:/white/editpath.svg"
                    onClicked: {
                        if(!addressedit.visible)
                            addressedit.show()
                        else {
                            if(!addressedit.warning)
                                loadEditPath()
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
        color: PQCLook.baseColorActive
    }

    function checkValidEditPath() {

        var completeWithoutFolder = false

        var path = PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.pathFromNativeSeparators(addressedit.text))
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
            path = PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.pathFromNativeSeparators(addressedit.completedPath))
        else
            path = PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.pathFromNativeSeparators(addressedit.text))

        if(path.endsWith("/"))
            path = path.substring(0, path.length-1)

        if(PQCScriptsFilesPaths.isFolder(path))
            filedialog_top.loadNewPath(path)
        else {
            if(PQCScriptsFilesPaths.getFilename(path) === path)
                path = PQCFileFolderModel.folderFileDialog + "/" + path
            filedialog_top.loadNewPath(PQCScriptsFilesPaths.getDir(path))
            PQCFileFolderModel.fileInFolderMainView = path
            filedialog_top.hideFileDialog()
        }
    }

    function handleKeyEvent(key, mod) {

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

    function isEditVisible() {
        return addressedit.visible
    }

    function disableAddressEdit() {
        addressedit.hide()
    }

    function enableAddressEdit() {
        addressedit.show()
    }

}
