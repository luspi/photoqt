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

import "./filetypes"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Column {

            id: col

            x: 10
            y: 0

            spacing: 15

            Item {
                width: 1
                height: 1
            }

            Text {
                id: title
                width: cont.width-20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Filetype settings")
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "These settings govern which file types PhotoQt should recognize and open.") + " " + em.pty+qsTranslate("settingsmanager", "Not all file types might be available, depending on your setup and what library support was enabled at compile time")
            }

            PQPoppler { id: pop }
                PQHorizontalLine { expertModeOnly: pop.expertmodeonly; available: pop.available }
            PQLibArchive { id: arc }
                PQHorizontalLine { expertModeOnly: arc.expertmodeonly; available: arc.available }
            PQVideo { id: vid }
                PQHorizontalLine { expertModeOnly: vid.expertmodeonly; available: vid.available }
            PQFileTypes { id: fty }

        }

    }

}
