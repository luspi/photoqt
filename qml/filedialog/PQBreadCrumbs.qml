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
                    source: "/white/backwards.svg"
                    enabled: filedialog_top.historyIndex>0
                    onClicked:
                        filedialog_top.goBackInHistory()
                }
                PQButtonIcon {
                    source: "/white/upwards.svg"
                    onClicked:
                        filedialog_top.loadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
                }
                PQButtonIcon {
                    source: "/white/forwards.svg"
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
                    source: "/white/iconview.svg"
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
                    source: "/white/listview.svg"
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
                    source: "/white/remember.svg"
                    onClicked:
                        fd_breadcrumbs.disableAddressEdit()
                    onCheckedChanged:
                        PQCSettings.filedialogKeepLastLocation = checked
                }

                PQButtonIcon {
                    id: settings
                    checkable: true
                    source: "/white/settings.svg"
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

                    property var parts: !windows&&PQCFileFolderModel.folderFileDialog==="/" ? ["/"] : PQCFileFolderModel.folderFileDialog.split("/")

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
                                width: folder.width+20
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
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: filedialog_top.loadNewPath(deleg.subdir)
                                }
                            }

                            Rectangle {
                                height: breadcrumbs_top.height
                                width: height*2/3
                                property bool down: folderlist.visible
                                color: (down ? PQCLook.baseColorActive : (mousearea.containsMouse ? PQCLook.baseColorHighlight : PQCLook.baseColor))
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Image {
                                    anchors.fill: parent
                                    anchors.leftMargin: parent.width/3
                                    anchors.rightMargin: parent.width/3
                                    anchors.topMargin: parent.height/3
                                    anchors.bottomMargin: parent.height/3
                                    fillMode: Image.PreserveAspectFit
                                    source: "/white/breadcrumb.svg"
                                }
                                PQMouseArea {
                                    id: mousearea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
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
                        addressedit.text = PQCFileFolderModel.folderFileDialog
                        checkValidEditPath()
                        crumbs.visible = false
                        addressedit.visible = true
                        addressedit.setFocus()
                        PQCNotify.ignoreKeysExceptEnterEsc = true
                    }

                    function hide() {
                        if(crumbs.visible)
                            return
                        crumbs.visible = true
                        addressedit.visible = false
                        PQCNotify.ignoreKeysExceptEnterEsc = false
                    }

                    onTextChanged:
                        checkValidEditPath()

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
                    source: addressedit.visible ? "/white/checkmark.svg" : "/white/editpath.svg"
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
        var path = PQCScriptsFilesPaths.cleanPath(addressedit.text)
        if(PQCScriptsFilesPaths.getFilename(path) === path)
            path = PQCFileFolderModel.folderFileDialog + "/" + path

        if(PQCScriptsFilesPaths.doesItExist(path)) {
            addressedit.warning = false
            addressedit.completedPath = ""
            return
        }

        var firstmatch = PQCFileFolderModel.getFirstMatchFileDialog(addressedit.text)
        console.warn("*** firstmatch =", firstmatch)

        if(firstmatch !== "") {
            addressedit.warning = false
            addressedit.completedPath = firstmatch
            return
        }

        addressedit.warning = true
        addressedit.completedPath = ""

    }

    function loadEditPath() {

        var path = ""
        if(addressedit.completedPath !== "")
            path = PQCScriptsFilesPaths.cleanPath(addressedit.completedPath)
        else
            path = PQCScriptsFilesPaths.cleanPath(addressedit.text)

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
