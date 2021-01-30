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
    //: A settings title. The filename label here is the one that is written on thumbnails.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "filename label")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Show the filename on a small label on the thumbnail image.")
    content: [

        Column {

            spacing: 15

            Row {

                spacing: 10

                PQCheckbox {
                    id: fnamelabel_chk
                    y: (parent.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager_thumbnails", "enable")
                }

            }

            Row {

                spacing: 10

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: em.pty+qsTranslate("settingsmanager_thumbnails", "font size:")
                }

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: "5 pt"
                }

                PQSlider {
                    id: fnamelabel_fsize
                    y: (parent.height-height)/2
                    enabled: fnamelabel_chk.checked
                    from: 5
                    to: 20
                }

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: "20 pt"
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
            PQSettings.thumbnailWriteFilename = fnamelabel_chk.checked
            PQSettings.thumbnailFontSize = fnamelabel_fsize.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        fnamelabel_chk.checked = PQSettings.thumbnailWriteFilename
        fnamelabel_fsize.value = PQSettings.thumbnailFontSize
    }

}
