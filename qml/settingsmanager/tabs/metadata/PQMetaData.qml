/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_metadata", "meta information")
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "Which meta information to extract and display.")

    //: Part of the meta information about the current image.
    property var meta: [["Filename", em.pty+qsTranslate("settingsmanager_metadata", "file name")],
                        //: Part of the meta information about the current image.
                        ["FileType", em.pty+qsTranslate("settingsmanager_metadata", "file type")],
                        //: Part of the meta information about the current image.
                        ["FileSize", em.pty+qsTranslate("settingsmanager_metadata", "file size")],
                        //: Part of the meta information about the current image.
                        ["ImageNumber", em.pty+qsTranslate("settingsmanager_metadata", "image #/#")],
                        //: Part of the meta information about the current image.
                        ["Dimensions", em.pty+qsTranslate("settingsmanager_metadata", "dimensions")],
                        //: Part of the meta information about the current image.
                        ["Copyright", em.pty+qsTranslate("settingsmanager_metadata", "copyright")],
                        //: Part of the meta information about the current image.
                        ["ExposureTime", em.pty+qsTranslate("settingsmanager_metadata", "exposure time")],
                        //: Part of the meta information about the current image.
                        ["Flash", em.pty+qsTranslate("settingsmanager_metadata", "flash")],
                        //: Part of the meta information about the current image.
                        ["FLength", em.pty+qsTranslate("settingsmanager_metadata", "focal length")],
                        //: Part of the meta information about the current image.
                        ["FNumber", em.pty+qsTranslate("settingsmanager_metadata", "f-number")],
                        //: Part of the meta information about the current image.
                        ["Gps", em.pty+qsTranslate("settingsmanager_metadata", "GPS position")],
                        ["Iso", "ISO"],
                        //: Part of the meta information about the current image.
                        ["Keywords", em.pty+qsTranslate("settingsmanager_metadata", "keywords")],
                        //: Part of the meta information about the current image.
                        ["LightSource", em.pty+qsTranslate("settingsmanager_metadata", "light source")],
                        //: Part of the meta information about the current image.
                        ["Location", em.pty+qsTranslate("settingsmanager_metadata", "location")],
                        //: Part of the meta information about the current image.
                        ["Make", em.pty+qsTranslate("settingsmanager_metadata", "make")],
                        //: Part of the meta information about the current image.
                        ["Model", em.pty+qsTranslate("settingsmanager_metadata", "model")],
                        //: Part of the meta information about the current image.
                        ["SceneType", em.pty+qsTranslate("settingsmanager_metadata", "scene type")],
                        //: Part of the meta information about the current image.
                        ["Software", em.pty+qsTranslate("settingsmanager_metadata", "software")],
                        //: Part of the meta information about the current image.
                        ["Time", em.pty+qsTranslate("settingsmanager_metadata", "time photo was taken")]]

    content: [

        Flow {

            spacing: 5
            width: set.contwidth

            Repeater {
                id: rpt
                model: meta.length
                PQTile {
                    text: meta[index][1]
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
            for(var i = 0; i < meta.length; ++i)
                PQSettings["metadata"+meta[i][0]] = rpt.itemAt(i).checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        for(var i = 0; i < meta.length; ++i)
            rpt.itemAt(i).checked = PQSettings["metadata"+meta[i][0]]
    }

}
