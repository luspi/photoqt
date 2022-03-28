/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title. The popping out that is talked about here refers to the possibility of showing any element in its own window (i.e., popped out).
    title: em.pty+qsTranslate("settingsmanager_interface", "pop out elements")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Here you can choose for most elements whether they are to be shown integrated into the main window or in their own, separate window.")

    //: Used as identifying name for one of the elements in the interface
    property var pops: [["interfacePopoutOpenFile", em.pty+qsTranslate("settingsmanager_interface", "File dialog"), "interfacePopoutOpenFileKeepOpen", em.pty+qsTranslate("settingsmanager_interface", "keep open")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSettingsManager", em.pty+qsTranslate("settingsmanager_interface", "Settings Manager")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMainMenu", em.pty+qsTranslate("settingsmanager_interface", "Main Menu")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMetadata", em.pty+qsTranslate("settingsmanager_interface", "Metadata")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutHistogram", em.pty+qsTranslate("settingsmanager_interface", "Histogram")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutScale", em.pty+qsTranslate("settingsmanager_interface", "Scale")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSlideShowSettings", em.pty+qsTranslate("settingsmanager_interface", "Slideshow Settings")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSlideShowControls", em.pty+qsTranslate("settingsmanager_interface", "Slideshow Controls")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileRename", em.pty+qsTranslate("settingsmanager_interface", "Rename File")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileDelete", em.pty+qsTranslate("settingsmanager_interface", "Delete File")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileSaveAs", em.pty+qsTranslate("settingsmanager_interface", "Save File As")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutAbout", em.pty+qsTranslate("settingsmanager_interface", "About")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutImgur", em.pty+qsTranslate("settingsmanager_interface", "Imgur")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutWallpaper", em.pty+qsTranslate("settingsmanager_interface", "Wallpaper")],
                        //: Noun, not a verb. Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFilter", em.pty+qsTranslate("settingsmanager_interface", "Filter")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutAdvancedSort", em.pty+qsTranslate("settingsmanager_interface", "Advanced Image Sort")]]

    content: [

        Flow {
            spacing: 5
            width: set.contwidth

             Repeater {
                 id: rpt
                 model: pops.length
                 PQTile {
                     text: pops[index][1]
                     secondText: pops[index].length==4 ? pops[index][3] : ""
                 }
             }
         }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {

            for(var i = 0; i < pops.length; ++i) {
                rpt.itemAt(i).checked = PQSettings[pops[i][0]]
                if(pops[i].length == 4)
                    rpt.itemAt(i).secondChecked = PQSettings[pops[i][2]]

            }
        }

        onSaveAllSettings: {
            for(var i = 0; i < pops.length; ++i) {
                PQSettings[pops[i][0]] = rpt.itemAt(i).checked
                if(pops[i].length == 4)
                    PQSettings[pops[i][2]] = rpt.itemAt(i).secondChecked
            }
        }

    }

}
