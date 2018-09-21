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
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

Entry {

    title: em.pty+qsTr("Sort Images")

    helptext: em.pty+qsTr("Images in the current folder can be sorted in varios ways. They can be sorted by filename, natural name\
 (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), filesize, and date, all of that both ascending or descending.")


    content: [

        // Wrapping this into an item makes them act as one unit in the flow
        Item {

            width: sortimages_checkbox_text.width+sortimages_checkbox.width+10
            height: childrenRect.height

            // Label
            Text {
                id: sortimages_checkbox_text
                height: sortimages_checkbox.height
                verticalAlignment: Text.AlignVCenter
                color: colour.text
                //: As in "Sort the images by some criteria"
                text: em.pty+qsTr("Sort by:")
                font.pointSize: 10
            }
            // Choose Criteria
            CustomComboBox {
                id: sortimages_checkbox
                x: sortimages_checkbox_text.width+10
                width: 200
                //: Refers to the filename
                model: [em.pty+qsTr("Name"),
                        //: Sorting by natural name means file10.jpg comes after file9.jpg and not after file1.jpg
                        em.pty+qsTr("Natural Name"),
                        //: The date the file was created
                        em.pty+qsTr("Date (file creation)"),
                        em.pty+qsTr("Date (file last modified)"),
                        em.pty+qsTr("Date (EXIF timestamp) - SLOW!"),
                        em.pty+qsTr("Filesize")]
            }

        },

        // Wrapping this into an item makes them act as one unit in the flow
        Item {

            // Ascending or Descending
            ExclusiveGroup { id: radiobuttons_sorting }

            width: sortimages_ascending.width+sortimages_descending.width+10
            height: sortimages_checkbox.height

            CustomRadioButton {
                id: sortimages_ascending
                height: parent.height
                text: em.pty+qsTr("Ascending")
                icon: "qrc:/img/settings/sortascending.png"
                exclusiveGroup: radiobuttons_sorting
                checked: true
            }
            CustomRadioButton {
                id: sortimages_descending
                x: sortimages_ascending.width+10
                height: parent.height
                text: em.pty+qsTr("Descending")
                icon: "qrc:/img/settings/sortdescending.png"
                exclusiveGroup: radiobuttons_sorting
            }

        }

    ]

    Timer {
        id: somedelay
        interval: 100
        repeat: false
        onTriggered:
            sortimages_checkbox.setIndexEnabled(4, getanddostuff.isExivSupportEnabled())
    }

    function setData() {

        somedelay.start()

        if(settings.sortby === "name")
            sortimages_checkbox.currentIndex = 0
        else if(settings.sortby === "date")
            sortimages_checkbox.currentIndex = 2
        else if(settings.sortby === "datemodified")
            sortimages_checkbox.currentIndex = 3
        else if(settings.sortby === "dateexif")
            sortimages_checkbox.currentIndex = 4
        else if(settings.sortby === "size")
            sortimages_checkbox.currentIndex = 5
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
            settings.sortby = "datemodified"
        else if(sortimages_checkbox.currentIndex == 4)
            settings.sortby = "dateexif"
        else if(sortimages_checkbox.currentIndex == 5)
            settings.sortby = "size"
        settings.sortbyAscending = sortimages_ascending.checked
    }

}
