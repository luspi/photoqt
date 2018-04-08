/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5

import "../../../elements"
import "../../"

Entry {

    title: em.pty+qsTr("Visibility")
    helptext: em.pty+qsTr("The thumbnails normally fade out when not needed, however, they can be set to stay visible. The main image is shrunk to fit into the free space. When it is zoomed in the thumbnails can be set to fade out automatically.")

    content: [

        CustomCheckBox {

            id: keepvisible

            // Checkbox in settings manager, thumbnails tab
            text: em.pty+qsTr("Keep thumbnails visible, don't hide them past screen edge")

            onCheckedButtonChanged: {
                if(checkedButton)
                    keepvisiblewhennotzoomedin.checkedButton = false
            }

        },

        CustomCheckBox {

            id: keepvisiblewhennotzoomedin

            // Checkbox in settings manager, thumbnails tab
            text: em.pty+qsTr("Keep thumbnails visible as long as the main image is not zoomed in")

            onCheckedButtonChanged: {
                if(checkedButton)
                    keepvisible.checkedButton = false
            }

        }

    ]

    function setData() {
        keepvisible.checkedButton = settings.thumbnailKeepVisible
        keepvisiblewhennotzoomedin.checkedButton = settings.thumbnailKeepVisibleWhenNotZoomedIn
    }

    function saveData() {
        settings.thumbnailKeepVisible = keepvisible.checkedButton
        settings.thumbnailKeepVisibleWhenNotZoomedIn = keepvisiblewhennotzoomedin.checkedButton
    }

}
