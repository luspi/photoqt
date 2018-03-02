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
            title: em.pty+qsTr("File Formats") + ":<br>&gt; GraphicsMagick"
                      //: Used as in 'disabled category'
                   + (helptext_warning ? "<br><br><font color=\"red\"><i>&gt; " + em.pty+qsTr("disabled") + "!</i></font>" : "")
            helptext: entry.enabled
                        ? em.pty+qsTr("PhotoQt makes use of GraphicsMagick for support of many different image formats. The list below are all those formats, that were successfully displayed using test images. There are a few formats, that were not tested in PhotoQt (due to lack of a test image). You can find those in the 'Untested' category below.")
                        : "<div color='red'>" + em.pty+qsTr("PhotoQt was built without GraphicsMagick support!") + "</div>"

            helptext_warning: !entry.enabled

        }

        EntrySetting {

            id: entry

            // the model array
            property var types_gm: [["", "", true, ""]]
            // which item is checked
            property var modeldata: {"" : ""}

            enabled: getanddostuff.isGraphicsMagickSupportEnabled()

            GridView {

                id: grid
                width: item_top.width-title.x-title.width
                height: childrenRect.height
                cellWidth: 300
                cellHeight: 30+spacing*2
                property int spacing: 3

                interactive: false

                model: entry.types_gm.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_gm[index][0]
                    fileEnding: entry.types_gm[index][1]
                    displayFileEnding: entry.types_gm[index][3]
                    checked: entry.types_gm[index][2]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing

                    // Store updates
                    Component.onCompleted:
                        entry.modeldata[entry.types_gm[index][1]] = tile.checked
                    onCheckedChanged:
                        entry.modeldata[entry.types_gm[index][1]] = tile.checked
                }

            }

        }

    }

    function setData() {

        // storing intermediate results
        var tmp_types_gm = []

        // Get current settings
        var setformats = fileformats.formats_gm

        // Valid fileformats
        var gm = [["AVS X image", "*.avs", "*.x"],
            ["Continuous Acquisition and Life-cycle Support Type 1", "*.cals", "*.cal", "*.dcl"],
            ["Kodak Cineon", "*.cin"],
            ["Dr Halo", "*.cut"],
            ["Digital Imaging and Communications in Medicine (DICOM)", "*.dcm", "*.dicom", "*.dic", "*.acr"],
            ["ZSoft IBM PC multi-page Paintbrush image", "*.dcx"],
            ["Microsoft Windows Device Independent Bitmap", "*.dib"],
            ["Digital Moving Picture Exchange", "*.dpx"],
            ["Encapsulated PDF", "*.epdf"],
            ["Group 3 FAX", "*.fax"],
            ["Flexible Image Transport System", "*.fits", "*.fts", "*.fit"],
            ["FlashPix Format", "*.fpx"],
            ["JPEG Network Graphics", "*.jng"],
            ["Joint Photographic Experts Group (JPEG)", "*.jpg", "*.jpeg", "*.jpe"],
            ["MATLAB image format", "*.mat"],
            ["Magick image file format", "*.miff"],
            ["Bi-level bitmap in least-significant-byte first order", "*.mono"],
            ["MTV Raytracing image format", "*.mtv"],
            ["On-the-air Bitmap", "*.otb"],
            ["Xv's Visual Schnauzer thumbnail format", "*.p7"],
            ["Palm pixmap", "*.palm"],
            ["Portable Arbitrary Map", "*.pam"],
            ["Photo CD", "*.pcd", "*.pcds"],
            ["ZSoft IBM PC Paintbrush file", "*.pcx"],
            ["Palm Database ImageViewer Format", "*.pdb"],
            ["Apple Macintosh QuickDraw/PICT file", "*.pict", "*.pct", "*.pic"],
            ["Alias/Wavefront RLE image format", "*.pix", "*.pal"],
            ["Portable anymap", "*.pnm"],
            ["Adobe Photoshop bitmap file", "*.psd"],
            ["Pyramid encoded TIFF", "*.ptif", "*.ptiff"],
            ["Seattle File Works image", "*.sfw"],
            ["Irix RGB image", "*.sgi"],
            ["SUN Rasterfile", "*.sun"],
            ["Truevision Targa image", "*.tga"],
            ["VICAR rasterfile format", "*.vicar"],
            ["Khoros Visualization Image File Format", "*.viff"],
            ["Word Perfect Graphics File", "*.wpg"],
            ["X Windows system window dump", "*.xwd"]]

        for(var i = 0; i < gm.length; ++i) {

            // the current file ending
            var cur = gm[i]
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
            tmp_types_gm = tmp_types_gm.concat([[cur[0],composed,found, composedDisplayed]])

        }

        // Set new data
        entry.types_gm = tmp_types_gm

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
        fileformats.formats_gm = tobesaved.filter(function(n){ return n !== ""; })

    }

}
