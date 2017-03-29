import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: title
            title: qsTr("File Formats") + ":<br>&gt; " +
                   //: These are extra (special) file formats
                   qsTr("Extras")
            helptext: qsTr("The following filetypes are supported by means of other third party tools. You first need to install them before you can use them.") + "<br><br><b>" + qsTr("Please note") + "</b>: " + qsTr("If an image format is also provided by GraphicsMagick/Qt, then PhotoQt first chooses the external tool (if enabled).")

        }

        EntrySetting {

            id: entry

            // the model array
            property var types_extras: [["", "", "", true]]
            // which item is checked
            property var modeldata: {"" : ""}

            GridView {

                id: grid
                width: item_top.width-title.x-title.width
                height: childrenRect.height
                cellWidth: 300
                cellHeight: 30+spacing*2
                property int spacing: 3

                model: entry.types_extras.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_extras[index][0]
                    fileEnding: entry.types_extras[index][1]
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

        //: Settings: This is used as in 'Makes use of some other tool'
        var extras = [["Gimp XCF","*.xcf",qsTr("Makes use of") + " 'xcftools'"],
                      //: Settings: This is used as in 'Makes use of some other tool'
                      ["Adobe Photoshop PSD/PSB","*.psb", "*.psd",qsTr("Makes use of") + " 'libqpsd'"]]

        for(var i = 0; i < extras.length; ++i) {

            // the current file ending
            var cur = extras[i]
            // if it has been found
            var found = true
            // And the file endings composed in string
            var composed = ""

            for(var j = 1; j < cur.length-1; ++j) {

                // If found, then the current file format is ENabled, if not then it is DISabled
                if(setformats.indexOf("*" + cur[j]) === -1)
                    found = false

                // The space aftet eh comma is very important! It is needed when saving data
                if(composed != "") composed += ", "
                composed += cur[j]
            }

            // Add to temporary array
            tmp_types_extras = tmp_types_extras.concat([[cur[0],composed,cur[cur.length-1],found]])

        }

        // Set new data
        entry.types_extras = tmp_types_extras

    }

    function saveData() {

        // Storing valid elements
        var tobesaved = []

        // Loop over all data and store checked elements
        for(var ele in entry.modeldata)
            if(entry.modeldata[ele])
                tobesaved = tobesaved.concat(ele.split(", "))

        var tmp = []
        for(var ele in tobesaved)
            tmp[tmp.length] = "*" + tobesaved[ele]
        tobesaved = tmp

        // Update data
        fileformats.formats_extras = tobesaved.filter(function(n){ return n !== ""; })

    }

}
