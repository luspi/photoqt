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
            title: em.pty+qsTr("File Formats") + ":<br>&gt; "
                     //: As in 'Untested file formats'
                   + em.pty+qsTr("Untested")
                     //: As in 'disabled category'
                   + (helptext_warning ? "<br><br><font color=\"red\"><i>&gt; " + em.pty+qsTr("disabled") + "!</i></font>" : "")
            helptext: entry.enabled
                       ? em.pty+qsTr("These are some file types that are supported by GraphicMagick, but have not been tested in PhotoQt. They might work, but no guarantee can be given!")
                       : "<div color='red'>" + em.pty+qsTr("PhotoQt was built without GraphicsMagick support!") + "</div>"

            helptext_warning: !entry.enabled

        }

        EntrySetting {

            id: entry

            enabled: getanddostuff.isGraphicsMagickSupportEnabled()

            // the model array
            property var types_untested: [["", "", true]]
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

                model: entry.types_untested.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_untested[index][0]
                    fileEnding: entry.types_untested[index][1]
                    checked: entry.types_untested[index][2]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing

                    // Store updates
                    Component.onCompleted:
                        entry.modeldata[entry.types_untested[index][1]] = tile.checked
                    onCheckedChanged:
                        entry.modeldata[entry.types_untested[index][1]] = tile.checked
                }

            }

        }

    }

    function setData() {

        // storing intermediate results
        var tmp_types_untested = []

        // Get current settings
        var setformats = fileformats.formats_untested

        // Valid fileformats
        var untested = [["HP-GL plotter language","*.hp", "*.hpgl"],
                ["Joint Bi-level Image experts Group file interchange format","*.jbig", "*.jbg"],
                ["Seattle File Works multi-image file","*.pwp"],
                ["Sun Raster Image","*.rast"],
                ["Alias/Wavefront image","*.rla"],
                ["Utah Run length encoded image","*.rle"],
                ["Scitex Continuous Tone Picture","*.sct"],
                ["PSX TIM file","*.tim"]]

        for(var i = 0; i < untested.length; ++i) {

            // the current file ending
            var cur = untested[i]
            // if it has been found
            var found = true
            // And the file endings composed in string
            var composed = ""

            for(var j = 1; j < cur.length; ++j) {

                // If found, then the current file format is ENabled, if not then it is DISabled
                if(setformats.indexOf(cur[j]) === -1)
                    found = false

                // The space aftet eh comma is very important! It is needed when saving data
                if(composed != "") composed += ", "
                composed += cur[j]
            }

            // Add to temporary array
            tmp_types_untested = tmp_types_untested.concat([[cur[0],composed,found]])

        }

        // Set new data
        entry.types_untested = tmp_types_untested

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
        fileformats.formats_untested = tobesaved.filter(function(n){ return n !== ""; })

    }

}
