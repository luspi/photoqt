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

import QtQuick
import PhotoQt.Modern
import PhotoQt.Shared
import PQCImageFormats

Item {

    id: context_top

    property int filetypesVisibleItems: 0

    Connections {

        target: PQCNotify

        function onShowFileDialogContextMenu(vis : bool, opts : var) {

            console.warn(">>>", vis, opts)

            if(opts[0] === "FileDialogBreadCrumbsPathMenu") {

                if(vis) {
                    pathmenu = opts[1]
                    pathmenu.popup()
                } else
                    pathmenu.close()

            } else if(opts[0] === "FileDialogBreadCrumbsFolderList") {

                if(vis && !folderlist.recentlyOpened) {
                    folderlist.subdir = opts[1]
                    var pos = context_top.mapToItem(fullscreenitem, context_top.mapFromGlobal(opts[2]))
                    folderlist.popup(pos)
                } else
                    folderlist.close()

            } else if(opts[0] === "FileDialogBreadCrumbsAddressEdit") {

                if(vis) {
                    editmenu.popup()
                } else
                    editmenu.close()

            } else if(opts[0] === "FileDialogBreadCrumbsAddressEditContextMenu") {

                if(vis) {
                    editcontextmenu.actionStates = opts[1]
                    editcontextmenu.popup()
                } else
                    editcontextmenu.close()

            } else if(opts[0] === "FileDialogBreadCrumbsNavigation") {

                if(vis)
                    navmenu.popup()
                else
                    navmenu.close()

            }

        }

    }

    /**************************************************/
    /**************************************************/

    PQMenu {

        id: pathmenu

        property string subdir

        PQMenuItem {
            enabled: false
            text: pathmenu.subdir
            font.italic: true
            elide: Text.ElideLeft
        }
        PQMenuItem {
            //: The location here is a folder path
            text: qsTranslate("filedialog", "Navigate to this location")
            onTriggered: {
                PQCNotify.filedialogLoadNewPath(pathmenu.subdir)
            }
        }
        onAboutToShow: {
            PQCConstants.addToWhichContextMenusOpen("FileDialogBreadCrumbsPath")
        }
        onAboutToHide:
            PQCConstants.removeFromWhichContextMenusOpen("FileDialogBreadCrumbsPath")

    }

    /**************************************************/
    /**************************************************/

    PQMenu {

        id: folderlist

        property string subdir
        property var subfolders: []

        property bool recentlyOpened: false

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
                onTriggered: PQCNotify.filedialogLoadNewPath(PQCScriptsFilesPaths.cleanPath(folderlist.subdir+"/"+text))
            }
        }
        onAboutToShow: {
            if(inst.currentParentFolder !== folderlist.subdir) {
                subfolders = PQCScriptsFilesPaths.getFoldersIn(folderlist.subdir)
                inst.currentParentFolder = folderlist.subdir
                inst.model = subfolders
            }
            PQCConstants.addToWhichContextMenusOpen("FileDialogBreadCrumbsFolderList")
            recentlyOpened = true
        }
        onAboutToHide: {
            PQCConstants.removeFromWhichContextMenusOpen("FileDialogBreadCrumbsFolderList")
            resetFolderList.restart()
        }
        Timer {
            id: resetFolderList
            interval: 300
            onTriggered: {
                folderlist.recentlyOpened = false
            }
        }
    }

    /**************************************************/
    /**************************************************/

    PQMenu {
        id: editmenu
        PQMenuItem {
            enabled: false
            font.italic: true
            elide: Text.ElideLeft
            text: PQCFileFolderModel.folderFileDialog
        }

        PQMenuItem {
            //: The location here is a folder path
            text: qsTranslate("filedialog", "Edit location")
            onTriggered:
                PQCNotify.filedialogAddressEdit("show")
        }
    }

    /**************************************************/
    /**************************************************/

    PQMenu {

        id: editcontextmenu

        property var actionStates: {
            "canUndo" : false,
            "canRedo" : false,
            "canCut"  : false,
            "canCopy" : false,
            "canPaste" : false
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateleft.svg"
            text: "Undo"
            enabled: editcontextmenu.actionStates["canUndo"]
            onTriggered:
                PQCNotify.filedialogAddressEdit("undo")
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateright.svg"
            text: "Redo"
            enabled: editcontextmenu.actionStates["canRedo"]
            onTriggered:
                PQCNotify.filedialogAddressEdit("redo")
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/cut.svg"
            text: "Cut"
            enabled: editcontextmenu.actionStates["canCut"]
            onTriggered:
                PQCNotify.filedialogAddressEdit("cut")

        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
            text: "Copy"
            enabled: editcontextmenu.actionStates["canCopy"]
            onTriggered:
                PQCNotify.filedialogAddressEdit("copy")
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg"
            text: "Paste"
            enabled: editcontextmenu.actionStates["canPaste"]
            onTriggered:
                PQCNotify.filedialogAddressEdit("paste")
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg"
            text: "Delete"
            onTriggered:
                PQCNotify.filedialogAddressEdit("delete")
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/quit.svg"
            text: "Clear"
            onTriggered:
                PQCNotify.filedialogAddressEdit("clear")
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/leftrightarrow.svg"
            text: "Select all"
            onTriggered:
                PQCNotify.filedialogAddressEdit("selectall")
        }

    }

    /**************************************************/
    /**************************************************/

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

}
