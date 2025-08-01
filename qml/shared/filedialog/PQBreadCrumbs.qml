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
import PhotoQt.Shared

Item {

    id: breadcrumbs_top

    width: parent.width
    height: 50

    SystemPalette { id: pqtPalette }

    property bool otherContextMenuOpen: false
    signal closeMenus()

    property string folderListCurrentMenuSubDir: ""

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton|Qt.LeftButton
    }

    Row {

        Item {

            id: leftitem

            width: Math.max(filedialog_top.placesWidth, leftrow.width+10)
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
                    source: "image://svg/:/" + PQCLook.iconShade + "/backwards.svg"
                    enabled: PQCConstants.filedialogHistoryIndex>0
                    enableContextMenu: false
                    onClicked:
                        PQCNotify.filedialogGoBackInHistory
                    onRightClicked:
                        PQCNotify.showFileDialogContextMenu(true, ["FileDialogBreadCrumbsNavigation", mapToGlobal(0, height)])
                }
                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/upwards.svg"
                    enableContextMenu: false
                    onClicked:
                        PQCNotify.filedialogLoadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
                    onRightClicked:
                        PQCNotify.showFileDialogContextMenu(true, ["FileDialogBreadCrumbsNavigation", mapToGlobal(0, height)])
                }
                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg"
                    enabled: PQCConstants.filedialogHistoryIndex<PQCConstants.filedialogHistory.length-1
                    enableContextMenu: false
                    onClicked:
                        PQCNotify.filedialogGoForwardsInHistory()
                    onRightClicked:
                        PQCNotify.showFileDialogContextMenu(true, ["FileDialogBreadCrumbsNavigation", mapToGlobal(0, height)])
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseBorder
                    }

                }

                PQButtonIcon {
                    id: iconview
                    checkable: true
                    checked: PQCSettings.filedialogLayout==="grid"
                    source: "image://svg/:/" + PQCLook.iconShade + "/iconview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as grid")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
                        if(checked) PQCSettings.filedialogLayout = "grid"
                        checked = Qt.binding(function() { return PQCSettings.filedialogLayout==="grid" })
                    }
                }

                PQButtonIcon {
                    id: listview
                    checkable: true
                    checked: PQCSettings.filedialogLayout!=="grid"&&PQCSettings.filedialogLayout!=="masonry"
                    source: "image://svg/:/" + PQCLook.iconShade + "/listview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as list")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
                        if(checked) PQCSettings.filedialogLayout = "list"
                        checked = Qt.binding(function() { return PQCSettings.filedialogLayout==="list" })
                    }
                }

                PQButtonIcon {
                    id: masonview
                    checkable: true
                    checked: PQCSettings.filedialogLayout==="masonry"
                    source: "image://svg/:/" + PQCLook.iconShade + "/masonryview.svg"
                    tooltip: qsTranslate("filedialog", "Show files in masonry layout")
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
                        if(checked) PQCSettings.filedialogLayout = "masonry"
                        checked = Qt.binding(function() { return PQCSettings.filedialogLayout==="masonry" })
                    }
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseBorder
                    }

                }

                PQButtonIcon {
                    id: settings
                    checkable: true
                    source: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
                    tooltip: qsTranslate("filedialog", "Settings")
                    enableContextMenu: false
                    onCheckedChanged: {
                        fd_breadcrumbs.disableAddressEdit()
                        if(checked)
                            PQCNotify.showFileDialogContextMenu(true, ["filedialogsettingsmenu", settings.mapToGlobal(0, height)])
                    }
                    onRightClicked: {
                        checked = !checked
                    }

                    Connections {
                        target: PQCConstants
                        function onWhichContextMenusOpenChanged() {
                            console.warn(">>> menu:", PQCConstants.isContextmenuOpen("filedialogsettingsmenu"))
                            if(!PQCConstants.isContextmenuOpen("filedialogsettingsmenu"))
                                settings.checked = false
                        }
                    }

                }


            }

        }

        Rectangle {
            width: 8
            height: breadcrumbs_top.height
            color: PQCLook.baseBorder
        }

        Item {

            id: rightitem

            width: Math.min(filedialog_top.fileviewWidth, breadcrumbs_top.width-leftitem.width-8)
            height: breadcrumbs_top.height

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                enabled: !addressedit.visible
                visible: !addressedit.visible
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        addressedit.show()
                    else
                        PQCNotify.showFileDialogContextMenu(true, ["FileDialogBreadCrumbsAddressEdit"])
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

                ScrollBar.horizontal: ScrollBar {}

                clip: true

                Row {

                    id: crumbs

                    y: (parent.height-height)/2

                    property bool windows: PQCScriptsConfig.amIOnWindows()
                    property bool isNetwork: PQCScriptsFilesPaths.isOnNetwork(PQCFileFolderModel.folderFileDialog)

                    property list<string> parts: !windows&&PQCFileFolderModel.folderFileDialog==="/" ? ["/"] : ((isNetwork&&windows) ? PQCFileFolderModel.folderFileDialog.substr(1).split("/") : PQCFileFolderModel.folderFileDialog.split("/"))

                    Item { width: 15; height: 1 }
                    Image {
                        id: rooticon
                        y: (parent.height-height)/2
                        height: parent.height/2
                        width: height
                        source: ("image://svg/:/" + PQCLook.iconShade + "/computer.svg")
                        sourceSize: Qt.size(width, height)
                        PQGenericMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            tooltip: (crumbs.parts.length > 0 ? (crumbs.windows ? crumbs.parts[0] : "/") : "")
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                if(crumbs.parts.length > 0) {
                                    if(crumbs.windows)
                                        filedialog_top.loadNewPath(crumbs.parts[0])
                                    else
                                        filedialog_top.loadNewPath("/")
                                }
                            }
                        }
                    }
                    Item { width: 10; height: 1 }

                    Repeater {

                        model: crumbs.parts[crumbs.parts.length-1] !== "" ? crumbs.parts.length : crumbs.parts.length-1

                        Row {

                            id: deleg

                            required property int modelData

                            property bool subdirIsNetwork: PQCScriptsFilesPaths.isOnNetwork(deleg.subdir)

                            property string subdir: {
                                var p = ""
                                if(crumbs.windows) {
                                    for(var i = 0; i <= modelData; ++i) {
                                        if(p != "") p += "/"
                                        p += crumbs.parts[i]
                                    }
                                    if(PQCFileFolderModel.folderFileDialog.startsWith("//") && !p.startsWith("/"))
                                        p = "//"+p
                                    return p
                                } else {
                                    if(modelData === 0)
                                        return "/"
                                    p = ""
                                    for(var j = 1; j <= modelData; ++j) {
                                        p += "/"+crumbs.parts[j]
                                    }
                                    return p
                                }
                            }

                            Item {
                                height: breadcrumbs_top.height
                                width: folder.text==="" ? 0 : (folder.width+foldertypeicon.width+20)
                                Rectangle {
                                    anchors.fill: parent
                                    color: mousearea2.containsPress ? PQCLook.baseBorder : (mousearea2.containsMouse ? pqtPalette.alternateBase : pqtPalette.base)
                                }
                                Image {
                                    id: foldertypeicon
                                    x: 5
                                    y: (parent.height-height)/2
                                    height: deleg.subdirIsNetwork ? parent.height/3 : 0
                                    width: height
                                    source: deleg.subdirIsNetwork ? ("image://svg/:/" + PQCLook.iconShade + "/network.svg") : ""
                                }
                                Text {
                                    id: folder
                                    x: foldertypeicon.width+10
                                    y: (parent.height-height)/2
                                    font.weight: PQCLook.fontWeightBold
                                    font.pointSize: PQCLook.fontSize
                                    text: deleg.modelData>0 ? crumbs.parts[deleg.modelData] : ""
                                    color: pqtPalette.text
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                PQGenericMouseArea {
                                    id: mousearea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    tooltip: deleg.subdir
                                    onClicked: (mouse) => {
                                        if(mouse.button === Qt.LeftButton)
                                            filedialog_top.loadNewPath(deleg.subdir)
                                        else
                                            PQCNotify.showFileDialogContextMenu(true, ["FileDialogBreadCrumbsPathMenu", deleg.subdir])
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                                }

                            }

                            Rectangle {

                                id: crumbrect

                                height: breadcrumbs_top.height
                                width: height*2/3

                                property bool down: false
                                Connections {
                                    target: PQCConstants
                                    function onWhichContextMenusOpenChanged() {
                                        crumbrect.down = PQCConstants.isContextmenuOpen("FileDialogBreadCrumbsFolderList") && breadcrumbs_top.folderListCurrentMenuSubDir===deleg.subdir
                                    }
                                }

                                color: (down||mousearea.containsPress ? PQCLook.baseBorder : (mousearea.containsMouse ? pqtPalette.alternateBase : pqtPalette.base))

                                Image {
                                    property real fact: 3
                                    x: (parent.width-width)/2
                                    y: (parent.height-height)/2
                                    height: parent.height*(1/fact)
                                    width: height
                                    smooth: false
                                    fillMode: Image.PreserveAspectFit
                                    source: "image://svg/:/" + PQCLook.iconShade + "/breadcrumb.svg"
                                    sourceSize: Qt.size(width, height)
                                }
                                MouseArea {
                                    id: mousearea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton|Qt.RightButton
                                    onClicked: (pos) => {
                                        breadcrumbs_top.folderListCurrentMenuSubDir = deleg.subdir
                                        PQCNotify.showFileDialogContextMenu(!crumbrect.down, ["FileDialogBreadCrumbsFolderList", deleg.subdir, crumbrect.mapToGlobal(0, height)])
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

                    Connections {
                        target: PQCNotify
                        function onFiledialogAddressEdit(action : string) {
                            if(action === "show")
                                addressedit.show()
                            else if(action === "undo")
                                addressedit.lineedit.undo()
                            else if(action === "redo")
                                addressedit.lineedit.redo()
                            else if(action === "cut")
                                addressedit.actionCut()
                            else if(action === "copy")
                                addressedit.actionCopy()
                            else if(action === "paste")
                                addressedit.actionPaste()
                            else if(action === "delete")
                                addressedit.actionDelete()
                            else if(action === "clear")
                                addressedit.lineedit.remove(0,addressedit.text.length)
                            else if(action === "selectall")
                                addressedit.setFocus()
                        }
                    }

                    function show() {
                        if(addressedit.visible)
                            return
                        completedPath = ""
                        text = PQCScriptsFilesPaths.pathWithNativeSeparators(PQCFileFolderModel.folderFileDialog)
                        breadcrumbs_top.checkValidEditPath()
                        crumbs.visible = false
                        visible = true
                        setFocus()
                    }

                    function hide() {
                        if(crumbs.visible)
                            return
                        crumbs.visible = true
                        visible = false
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
                        breadcrumbs_top.checkValidEditPath()

                    onRightClicked: {
                        PQCNotify.showFileDialogContextMenu(true, ["FileDialogBreadCrumbsAddressEditContextMenu",
                                                            {"canUndo" : addressedit.lineedit.canUndo,
                                                             "canRedo" : addressedit.lineedit.canRedo,
                                                             "canCut"  : addressedit.lineedit.selectedText.length>0,
                                                             "canCopy" : addressedit.lineedit.selectedText.length>0,
                                                             "canPaste" : addressedit.lineedit.canPaste}])
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
                    //: The location here is a folder path
                    tooltip: qsTranslate("filedialog", "Click to edit location")
                    source: addressedit.visible ? ("image://svg/:/" + PQCLook.iconShade + "/checkmark.svg") : ("image://svg/:/" + PQCLook.iconShade + "/editpath.svg")
                    onClicked: {
                        if(!addressedit.visible)
                            addressedit.show()
                        else {
                            if(!addressedit.warning)
                                breadcrumbs_top.loadEditPath()
                            addressedit.hide()
                        }
                    }
                    Connections {
                        target: breadcrumbs_top
                        function onCloseMenus() {
                            PQCNotify.showFileDialogContextMenu(false, ["FileDialogBreadCrumbsAddressEditContextMenu"])
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
        color: PQCLook.baseBorder
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

        if(PQCScriptsFilesPaths.getFilename(path) === path)
            path = PQCFileFolderModel.folderFileDialog + "/" + path

        if(PQCScriptsFilesPaths.isFolder(path))
            filedialog_top.loadNewPath(path)
        else {
            filedialog_top.loadNewPath(PQCScriptsFilesPaths.getDir(path))
            PQCFileFolderModel.extraFoldersToLoad = []
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
