/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
    //: A settings title. This refers to using only the filename as thumbnail and no actual image.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "filename-only")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Show only the filename as thumbnail, no actual image.")
    expertmodeonly: true
    content: [

        Column {

            spacing: 10

            Row {

                spacing: 10

                PQCheckbox {
                    id: fname_chk
                    y: (parent.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager_thumbnails", "enable")
                }

            }

            Row {

                spacing: 10

                Text {
                    y: (parent.height-height)/2
                    color: fname_chk.checked ? "white" : "#cccccc"
                    text: em.pty+qsTranslate("settingsmanager_thumbnails", "font size:")
                }

                Text {
                    y: (parent.height-height)/2
                    color: fname_chk.checked ? "white" : "#cccccc"
                    text: "5 pt"
                }

                PQSlider {
                    id: fname_fsize
                    y: (parent.height-height)/2
                    enabled: fname_chk.checked
                    from: 5
                    to: 5
                }

                Text {
                    y: (parent.height-height)/2
                    color: fname_chk.checked ? "white" : "#cccccc"
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
            PQSettings.thumbnailFilenameInstead = fname_chk.checked
            PQSettings.thumbnailFilenameInsteadFontSize = fname_fsize.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        fname_chk.checked = PQSettings.thumbnailFilenameInstead
        fname_fsize.value = PQSettings.thumbnailFilenameInsteadFontSize
    }

}
