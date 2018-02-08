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

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Re-open last used image at startup")
            helptext: em.pty+qsTr("At startup, you can set PhotoQt to re-open the last used image and directory. This doesn't keep any zooming/scaling/mirroring from before. If you pass an image to PhotoQt on the command line, it will always favor the passed-on image.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: reopen_box
                    text: em.pty+qsTr("Re-open last used image")
                }

            }

        }

    }

    function setData() {
        reopen_box.checkedButton = settings.startupLoadLastLoadedImage
    }

    function saveData() {
        settings.startupLoadLastLoadedImage = reopen_box.checkedButton
    }

}
