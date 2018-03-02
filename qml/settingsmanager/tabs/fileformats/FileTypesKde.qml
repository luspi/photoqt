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
            title: em.pty+qsTr("File Formats") + ":<br>&gt; KDE"
            helptext: em.pty+qsTr("These are the file types supported by KDE. If the KDE image formats are installed, they are registered as normal Qt image plugins and can lead the respective image formats very efficiently.")

        }

        EntrySetting {

            id: entry

            // the model array
            property var types_kde: [["", "", true, ""]]
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

                model: entry.types_kde.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_kde[index][0]
                    fileEnding: entry.types_kde[index][1]
                    displayFileEnding: entry.types_kde[index][3]
                    checked: entry.types_kde[index][2]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing

                    // Store updates
                    Component.onCompleted:
                        entry.modeldata[entry.types_kde[index][1]] = checked
                    onCheckedChanged:
                        entry.modeldata[entry.types_kde[index][1]] = checked
                }

            }

        }

    }

    function setData() {

        verboseMessage("Settings::TabFiletypes::setData()","")

        // Remove data
        entry.types_kde = []

        // storing intermediate results
        var tmp_types_kde = []

        // Get current settings
        var setformats = fileformats.formats_kde

        // Valid fileformats
        var kde = [["Adobe Encapsulated PostScript", "*.eps", "*.epsf", "*.epsi"],
                  ["OpenEXR", "*.exr"],
                  ["Krita Document", "*.kra"],
                  ["Open Raster Image File", "*.ora"],
                  ["PC Paintbrush", "*.pcx"],
                  ["Apple Macintosh QuickDraw/PICT file", "*.pic"],
                  ["Adobe PhotoShop", "*.psd"],
                  ["Sun Graphics", "*.ras"],
                  ["Silicon Graphics", "*.bw", "*.rgb", "*.rgba", "*.sgi"],
                  ["Truevision Targa Graphic", "*.tga"],
                  ["Gimp XCF", "*.xcf"]]

        for(var i = 0; i < kde.length; ++i) {

            // the current file ending
            var cur = kde[i]
            // if it has been found
            var found = true
            // And the file endings composed in string
            var composed = ""
            // This string will be written on the tiles, without "*." and all upper case
            var composedDisplayed = ""

            for(var j = 1; j < cur.length; ++j) {

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
            tmp_types_kde = tmp_types_kde.concat([[cur[0],composed,found, composedDisplayed]])

        }

        // Set new data
        entry.types_kde = tmp_types_kde

    }

    function saveData() {

        // Storing valid elements
        var tobesaved = []

        // Loop over all data and store checked elements
        for(var ele in entry.modeldata) {
            if(entry.modeldata[ele])
                tobesaved = tobesaved.concat(ele.split(", "))
        }

        // Update data
        fileformats.formats_kde = tobesaved.filter(function(n){ return n !== ""; })

    }

}
