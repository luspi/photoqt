/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "exclude folders")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Exclude the specified folders and all of its subfolders from any sort of caching and preloading.")
    content: [

        Column {

            spacing: 5

            PQCheckbox {
                id: drpbx
                property string folder: ""
                visible: folder!=""
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "Exclude DropBox folder:") + " " + folder
            }

            Item {
                visible: drpbx.visible
                width: 1
                height: 1
            }

            Text {
                color: "white"
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "Currently excluded folders:")
            }

            PQTextArea {
                id: curexl
                width: 400
                text: ""
                placeholderText: em.pty+qsTranslate("settingsmanager_thumbnails", "One folder per line")
            }

            PQButton {
                //: Written on a button
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "Add folder")
                leftRightTextSpacing: 5
                height: 30
                onClicked: {
                    var newdir = handlingFileDir.getExistingDirectory()
                    if(newdir != "") {
                        if(curexl.text == "")
                            curexl.text = newdir+"\n"
                        else {
                            if(curexl.text.endsWith("\n"))
                                curexl.text += newdir+"\n"
                            else
                                curexl.text += "\n"+newdir+"\n"
                        }
                        curexl.cursorPosition = curexl.text.length
                    }
                }
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {

            PQSettings.excludeCacheDropBox = (drpbx.checked ? drpbx.folder : "")

            // split by linebreak and remove empty entries
            var parts = curexl.text.split("\n").filter(function(el) { return el.length != 0});
            // trim each entry
            for(var p = 0; p < parts.length; ++p) parts[p] = parts[p].trim()
            PQSettings.excludeCacheFolders = parts
        }

    }

    function addDirectory() {

    }

    Component.onCompleted: {
        load()
    }

    function load() {

        if(PQSettings.excludeCacheDropBox != "") {
            drpbx.folder = PQSettings.excludeCacheDropBox
            drpbx.checked = true
        } else {
            drpbx.folder = handlingExternal.findDropBoxFolder()
            drpbx.checked = false
        }

        curexl.text = PQSettings.excludeCacheFolders.join("\n")
        if(!curexl.text.endsWith("\n") && curexl.text.length > 0)
            curexl.text += "\n"
        curexl.cursorPosition = curexl.text.length
    }

}
