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
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Sort Images")

            helptext: em.pty+qsTr("Images in the current folder can be sorted in varios ways. They can be sorted by filename, natural name (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), filesize, and date, all of that both ascending or descending.")

        }

        EntrySetting {

            Row {

                spacing: 10

                // Label
                Text {
                    y: (parent.height-height)/2
                    color: colour.text
                    //: As in "Sort the images by some criteria"
                    text: em.pty+qsTr("Sort by:")
                    font.pointSize: 10
                }
                // Choose Criteria
                CustomComboBox {
                    id: sortimages_checkbox
                    y: (parent.height-height)/2
                    width: 150
                    //: Refers to the filename
                    model: [em.pty+qsTr("Name"),
                            //: Sorting by natural name means file10.jpg comes after file9.jpg and not after file1.jpg
                            em.pty+qsTr("Natural Name"),
                            //: The date the file was created
                            em.pty+qsTr("Date"),
                            em.pty+qsTr("Filesize")]
                }

                // Ascending or Descending
                ExclusiveGroup { id: radiobuttons_sorting }

                CustomRadioButton {
                    id: sortimages_ascending
                    y: (parent.height-height)/2
                    text: em.pty+qsTr("Ascending")
                    icon: "qrc:/img/settings/sortascending.png"
                    exclusiveGroup: radiobuttons_sorting
                    checked: true
                }
                CustomRadioButton {
                    id: sortimages_descending
                    y: (parent.height-height)/2
                    text: em.pty+qsTr("Descending")
                    icon: "qrc:/img/settings/sortdescending.png"
                    exclusiveGroup: radiobuttons_sorting
                }

            }

        }

    }

    function setData() {
        if(settings.sortby === "name")
            sortimages_checkbox.currentIndex = 0
        else if(settings.sortby === "date")
            sortimages_checkbox.currentIndex = 2
        else if(settings.sortby === "size")
            sortimages_checkbox.currentIndex = 3
        else // default to naturalname
            sortimages_checkbox.currentIndex = 1
        sortimages_ascending.checked = settings.sortbyAscending
        sortimages_descending.checked = !settings.sortbyAscending
    }

    function saveData() {
        if(sortimages_checkbox.currentIndex == 0)
            settings.sortby = "name"
        else if(sortimages_checkbox.currentIndex == 1)
            settings.sortby = "naturalname"
        else if(sortimages_checkbox.currentIndex == 2)
            settings.sortby = "date"
        else if(sortimages_checkbox.currentIndex == 3)
            settings.sortby = "size"
        settings.sortbyAscending = sortimages_ascending.checked
    }

}
