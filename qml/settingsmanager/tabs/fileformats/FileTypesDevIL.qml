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
            title: em.pty+qsTr("File Formats") + ":<br>&gt; DevIL"
            helptext: entry.enabled
                        ? em.pty+qsTr("These are the file types supported by the Developer's Image Library (DevIL). PhotoQt needs to be compiled with DevIL support in order for PhotoQt to be able to take advantage of them. Not all of these image formats have been tested, as for several no appropriate test images were available.")
                        : "<div color='red'>" + em.pty+qsTr("PhotoQt was built without DevIL support!") + "</div>"

            helptext_warning: !entry.enabled

        }

        EntrySetting {

            id: entry

            // the model array
            property var types_devil: [["", "", true, ""]]
            // which item is checked
            property var modeldata: {"" : ""}

            enabled: getanddostuff.isDevILSupportEnabled()

            GridView {

                id: grid
                width: item_top.width-title.x-title.width
                height: childrenRect.height
                cellWidth: 300
                cellHeight: 30+spacing*2
                property int spacing: 3

                interactive: false

                model: entry.types_devil.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_devil[index][0]
                    fileEnding: entry.types_devil[index][1]
                    displayFileEnding: entry.types_devil[index][3]
                    checked: entry.types_devil[index][2]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing

                    // Store updates
                    Component.onCompleted:
                        entry.modeldata[entry.types_devil[index][1]] = checked
                    onCheckedChanged:
                        entry.modeldata[entry.types_devil[index][1]] = checked
                }

            }

        }

    }

    function setData() {

        verboseMessage("Settings::TabFiletypes::setData()","")

        // Remove data
        entry.types_devil = []

        // storing intermediate results
        var tmp_types_devil = []

        // Get current settings
        var setformats = fileformats.formats_devil

        // Valid fileformats
        var devil = [["DR Halo", "*.cut"],
                ["DirectDraw Surface","*.dds"],
                ["Interlaced Bitmap","*.lbm"],
                ["Homeworld File","*.lif"],
                ["Doom Walls / Flats","*.lmp"],
                ["Half-Life Model","*.mdl"],
                ["PhotoCD","*.pcd"],
                ["ZSoft PCX","*.pcx"],
                ["Apple Macintosh QuickDraw/PICT file","*.pic"],
                ["Adobe PhotoShop","*.psd"],
                ["Silicon Graphics","*.bw","*.rgb","*.rgba","*.sgi"],
                ["Truevision Targa Graphic","*.tga"],
                ["Quake2 Texture","*.wal"]]

        for(var i = 0; i < devil.length; ++i) {

            // the current file ending
            var cur = devil[i]
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
            tmp_types_devil = tmp_types_devil.concat([[cur[0],composed,found, composedDisplayed]])

        }

        // Set new data
        entry.types_devil = tmp_types_devil

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
        fileformats.formats_devil = tobesaved.filter(function(n){ return n !== ""; })

    }

}
