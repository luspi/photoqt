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

import "./imageview"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Rectangle {

            x: 278
            y: title.height+desc.height+30
            width: 2
            height: cont.contentHeight-y
            color: "#88444444"

        }

        Column {

            id: col

            x: 10
            spacing: 15

            Text {
                id: title
                width: cont.width-20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Image view settings")
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "These settings affect the viewing of images, how they are shown, in what order, how large a cache to use, etc.") + "\n" + em.pty+qsTranslate("settingsmanager", "Some settings are only shown in expert mode.")
            }

            PQSort { id: srt }
                PQHorizontalLine { expertModeOnly: srt.expertmodeonly }
            PQTransparencyMarker { id: trn }
                PQHorizontalLine { expertModeOnly: trn.expertmodeonly }
            PQFitInWindow { id: fiw }
                PQHorizontalLine { expertModeOnly: fiw.expertmodeonly }
            PQLoop { id: loo }
                PQHorizontalLine { expertModeOnly: loo.expertmodeonly }
            PQLeftButton { id: lfb }
                PQHorizontalLine { expertModeOnly: lfb.expertmodeonly }
            PQMargin { id: mrg }
                PQHorizontalLine { expertModeOnly: mrg.expertmodeonly }
            PQPixmapCache { id: pix }
                PQHorizontalLine { expertModeOnly: pix.expertmodeonly }
            PQAnimation { id: ani }
                PQHorizontalLine { expertModeOnly: ani.expertmodeonly }
            PQInterpolation { id: itp }
                PQHorizontalLine { expertModeOnly: itp.expertmodeonly }
            PQKeep { id: kee }
                PQHorizontalLine { expertModeOnly: kee.expertmodeonly }
            PQZoomSpeed { id: zos }

            // add some spacing at the bottom
            Item { width: 1; height: 25 }

        }

    }

}
