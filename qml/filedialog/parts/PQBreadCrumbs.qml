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
import PhotoQt

Item {

    id: breadcrumbs_top

    width: parent.width
    height: 50

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

            width: Math.max(PQCConstants.filedialogPlacesWidth, leftrow.width+10)
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
                    onClicked:
                        PQCNotify.filedialogGoBackInHistory()
                    onRightClicked:
                        navmenu.popup()
                }
                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/upwards.svg"
                    onClicked:
                        PQCNotify.filedialogLoadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
                    onRightClicked:
                        navmenu.popup()
                }
                PQButtonIcon {
                    source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg"
                    enabled: PQCConstants.filedialogHistoryIndex<PQCConstants.filedialogHistory.length-1
                    onClicked:
                        PQCNotify.filedialogGoForwardsInHistory()
                    onRightClicked:
                        navmenu.popup()
                }

                PQMenu {
                    id: navmenu
                    PQMenuItem {
                        text: qsTranslate("filedialog", "Go backwards in history")
                        enabled: PQCConstants.filedialogHistoryIndex>0
                        onTriggered:
                            PQCNotify.filedialogGoBackInHistory()
                    }
                    PQMenuItem {
                        text: qsTranslate("filedialog", "Go forwards in history")
                        enabled: PQCConstants.filedialogHistoryIndex<PQCConstants.filedialogHistory.length-1
                        onTriggered:
                            PQCNotify.filedialogGoForwardsInHistory()
                    }
                    PQMenuItem {
                        text: qsTranslate("filedialog", "Go up a level")
                        onTriggered:
                            PQCNotify.filedialogLoadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
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
                    id: iconview
                    checkable: true
                    checked: PQCSettings.filedialogLayout==="grid"
                    source: "image://svg/:/" + PQCLook.iconShade + "/iconview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as grid")
                    onCheckedChanged: {
                        breadcrumbs_top.disableAddressEdit()
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
                        breadcrumbs_top.disableAddressEdit()
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
                        breadcrumbs_top.disableAddressEdit()
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
                    onCheckedChanged: {
                        breadcrumbs_top.disableAddressEdit()
                        if(checked)
                            settingsmenu.popup(0, height)
                    }
                    onRightClicked: {
                        checked = !checked
                    }

                    PQFileDialogSettingsMenu {
                        id: settingsmenu
                        onAboutToHide:
                            settings.checked = false
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

            width: Math.min(PQCConstants.filedialogFileviewWidth, breadcrumbs_top.width-leftitem.width-8)
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
                        editmenu.popup()
                }
            }

            PQMenu {
                id: editmenu
                PQMenuItem {
                    enabled: false
                    font.italic: true
                    text: PQCFileFolderModel.folderFileDialog
                }

                PQMenuItem {
                    //: The location here is a folder path
                    text: qsTranslate("filedialog", "Edit location")
                    onTriggered:
                        addressedit.show()
                }
            }

            Row {
                x: 10
                height: parent.height
                spacing: 10
                visible: PQCFileFolderModel.loadVirtualFolderFileDialog

                Image {
                    y: (parent.height-height)/2
                    height: parent.height/2
                    width: height
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/virtualfolder.svg"
                }

                PQTextL {
                    height: parent.height
                    text: qsTranslate("filedialog", "virtual folder")
                    font.italic: true
                    font.weight: PQCLook.fontWeightBold
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Flickable {

                height: parent.height
                width: Math.min(contentWidth, parent.width-editbutton.width-10)
                visible: !PQCFileFolderModel.loadVirtualFolderFileDialog
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
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            tooltip: (crumbs.parts.length > 0 ? (crumbs.windows ? crumbs.parts[0] : "/") : "")
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                if(crumbs.parts.length > 0) {
                                    if(crumbs.windows)
                                    PQCNotify.filedialogLoadNewPath(crumbs.parts[0])
                                    else
                                        PQCNotify.filedialogLoadNewPath("/")
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
                                    color: mousearea2.containsPress ? PQCLook.baseBorder : (mousearea2.containsMouse ? palette.alternateBase : palette.base)
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
                                    color: palette.text
                                    Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                                }
                                PQMouseArea {
                                    id: mousearea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    text: deleg.subdir
                                    onClicked: (mouse) => {
                                        if(mouse.button === Qt.LeftButton)
                                            PQCNotify.filedialogLoadNewPath(deleg.subdir)
                                        else
                                            pathmenu.popup()
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                                }

                                PQMenu {

                                    id: pathmenu

                                    PQMenuItem {
                                        enabled: false
                                        text: deleg.subdir
                                        font.italic: true
                                    }
                                    PQMenuItem {
                                        //: The location here is a folder path
                                        text: qsTranslate("filedialog", "Navigate to this location")
                                        onTriggered: {
                                            PQCNotify.filedialogLoadNewPath(deleg.subdir)
                                        }
                                    }
                                    onAboutToShow: {
                                        PQCConstants.addToWhichContextMenusOpen("FileDialogBreadCrumbsPath")
                                    }
                                    onAboutToHide:
                                        PQCConstants.removeFromWhichContextMenusOpen("FileDialogBreadCrumbsPath")

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

                                color: (down||mousearea.containsPress ? PQCLook.baseBorder : (mousearea.containsMouse ? palette.alternateBase : palette.base))

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
                                        folderlist.popup(0, height)
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

                                    Repeater {
                                        id: inst
                                        property string currentParentFolder: ""
                                        delegate: PQMenuItem {
                                            required property string modelData
                                            text: modelData
                                            onTriggered: PQCNotify.filedialogLoadNewPath(PQCScriptsFilesPaths.cleanPath(deleg.subdir+"/"+text))
                                        }
                                    }
                                    onAboutToShow: {
                                        if(inst.currentParentFolder !== deleg.subdir) {
                                            subfolders = PQCScriptsFilesPaths.getFoldersIn(deleg.subdir)
                                            inst.currentParentFolder = deleg.subdir
                                            inst.model = subfolders
                                        }
                                        PQCConstants.addToWhichContextMenusOpen("FileDialogBreadCrumbsFolderList")
                                    }
                                    onAboutToHide: {
                                        PQCConstants.removeFromWhichContextMenusOpen("FileDialogBreadCrumbsFolderList")
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

                        function onFiledialogShowAddressEdit(edit : bool) {
                            if(edit)
                                addressedit.show()
                            else
                                addressedit.hide()
                        }

                    }

                    function show() {
                        PQCConstants.filedialogAddressEditVisible = true
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
                        PQCConstants.filedialogAddressEditVisible = false
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
                        editcontextmenu.popup()
                    }

                }

                PQMenu {

                    id: editcontextmenu

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateleft.svg"
                        text: "Undo"
                        enabled: addressedit.lineedit.canUndo
                        onTriggered:
                            addressedit.lineedit.undo()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateright.svg"
                        text: "Redo"
                        enabled: addressedit.lineedit.canRedo
                        onTriggered:
                            addressedit.lineedit.redo()
                    }

                    PQMenuSeparator {}

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/cut.svg"
                        text: "Cut"
                        enabled: addressedit.lineedit.selectedText.length>0
                        onTriggered:
                            addressedit.actionCut()

                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
                        text: "Copy"
                        enabled: addressedit.lineedit.selectedText.length>0
                        onTriggered:
                            addressedit.actionCopy()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg"
                        text: "Paste"
                        enabled: addressedit.lineedit.canPaste
                        onTriggered:
                            addressedit.actionPaste()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg"
                        text: "Delete"
                        onTriggered:
                            addressedit.actionDelete()
                    }

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/quit.svg"
                        text: "Clear"
                        onTriggered:
                            addressedit.lineedit.remove(0,addressedit.text.length)
                    }

                    PQMenuSeparator {}

                    PQMenuItem {
                        iconSource: "image://svg/:/" + PQCLook.iconShade + "/leftrightarrow.svg"
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
                            editcontextmenu.close()
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
            PQCNotify.filedialogLoadNewPath(path)
        else {
            PQCNotify.filedialogLoadNewPath(PQCScriptsFilesPaths.getDir(path))
            PQCFileFolderModel.fileInFolderMainView = path
            PQCNotify.filedialogClose()
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

}
