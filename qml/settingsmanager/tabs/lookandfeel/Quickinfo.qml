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

            title: em.pty+qsTr("Show Quickinfo (Text Labels)")
            helptext: em.pty+qsTr("PhotoQt shows certain information about the current image and the folder in the top left corner of the screen. You can choose which information in particular to show there. This also includes the 'x' for closing PhotoQt in the top right corner.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: quickinfo_counter
                    //: The counter shows the current image position in the folder
                    text: em.pty+qsTr("Counter")
                }

                CustomCheckBox {
                    id: quickinfo_filepath
                    text: em.pty+qsTr("Filepath")
                }

                CustomCheckBox {
                    id: quickinfo_filename
                    text: em.pty+qsTr("Filename")
                }

                CustomCheckBox {
                    id: quickinfo_closingx
                    text: em.pty+qsTr("Exit button ('x' in top right corner)")
                }

            }

        }

    }

    function saveData() {
        settings.quickInfoHideCounter = !quickinfo_counter.checkedButton
        settings.quickInfoHideFilepath = !quickinfo_filepath.checkedButton
        settings.quickInfoHideFilename = !quickinfo_filename.checkedButton
        settings.quickInfoHideX = !quickinfo_closingx.checkedButton
    }

    function setData() {
        quickinfo_counter.checkedButton = !settings.quickInfoHideCounter
        quickinfo_filepath.checkedButton = !settings.quickInfoHideFilepath
        quickinfo_filename.checkedButton = !settings.quickInfoHideFilename
        quickinfo_closingx.checkedButton = !settings.quickInfoHideX
    }

}
