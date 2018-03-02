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
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: title
            title: em.pty+qsTr("File Formats") + ":<br>&gt; " +
                   //: These are extra (special) file formats
                   em.pty+qsTr("Extras")
            helptext: em.pty+qsTr("The following filetypes are supported by means of other third party tools. You first need to install them before you can use them.") + "<br><br><b>"
                      + em.pty+qsTr("Please note that if an image format is also provided by GraphicsMagick/Qt, then PhotoQt first chooses the external tool (if enabled).") + "</b>"

        }

        EntrySetting {

            id: entry

            // the model array
            property var types_extras: [["", "", "", true, ""]]
            // which item is checked
            property var modeldata: {"" : ""}

            GridView {

                id: grid
                width: item_top.width-title.x-title.width
                height: childrenRect.height
                cellWidth: 300
                cellHeight: 30+spacing*2
                property int spacing: 3

                interactive: false

                model: entry.types_extras.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_extras[index][0]
                    fileEnding: entry.types_extras[index][1]
                    displayFileEnding: entry.types_extras[index][4]
                    description: entry.types_extras[index][2]
                    checked: entry.types_extras[index][3]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing

                    // Store updates
                    Component.onCompleted:
                        entry.modeldata[entry.types_extras[index][1]] = tile.checked
                    onCheckedChanged:
                        entry.modeldata[entry.types_extras[index][1]] = tile.checked
                }

            }

        }

    }

    function setData() {

        // storing intermediate results
        var tmp_types_extras = []

        // Get current settings
        var setformats = fileformats.formats_extras

        //: Used as in 'Makes use of tool abc'
        var extras = [["xcftools: Gimp XCF","*.xcf",em.pty+qsTr("Makes use of") + " 'xcftools'"],
                      //: Used as in 'Makes use of tool abc'
                      ["libqpsd: Adobe Photoshop PSD/PSB","*.psb", "*.psd",em.pty+qsTr("Makes use of") + " 'libqpsd'"]]

        for(var i = 0; i < extras.length; ++i) {

            // the current file ending
            var cur = extras[i]
            // if it has been found
            var found = true
            // And the file endings composed in string
            var composed = ""
            // This string will be written on the tiles, without "*." and all upper case
            var composedDisplayed = ""

            for(var j = 1; j < cur.length-1; ++j) {

                // If found, then the current file format is ENabled, if not then it is DISabled
                if(setformats.indexOf(cur[j]) === -1)
                    found = false

                // The space aftet eh comma is very important! It is needed when saving data
                if(composed != "") composed += ", "
                if(composedDisplayed != "") composedDisplayed += ", "
                composed += cur[j]
                composedDisplayed += cur[j].substr(2,cur[j].length).toUpperCase()
            }

            // Add to temporary array
            tmp_types_extras = tmp_types_extras.concat([[cur[0],composed,cur[cur.length-1],found, composedDisplayed]])

        }

        // Set new data
        entry.types_extras = tmp_types_extras

    }

    function saveData() {

        // Storing valid elements
        var tobesaved = []

        // Loop over all data and store checked elements
        for(var ele1 in entry.modeldata)
            if(entry.modeldata[ele1])
                tobesaved = tobesaved.concat(ele1.split(", "))

        var tmp = []
        for(var ele2 in tobesaved)
            tmp[tmp.length] = tobesaved[ele2]
        tobesaved = tmp

        // Update data
        fileformats.formats_extras = tobesaved.filter(function(n){ return n !== ""; })

    }

}
