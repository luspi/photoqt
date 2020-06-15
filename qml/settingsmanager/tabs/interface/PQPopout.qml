import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "Popout Elements"
    helptext: "Here you can choose for most elements whether they are to be shown integrated into the main window or in their own, separate window."

    property var pops: [["mainMenuPopoutElement", "Main Menu"],
                        ["metadataPopoutElement", "Metadata"],
                        ["histogramPopoutElement", "Histogram"],
                        ["scalePopoutElement", "Scale"],
                        ["openPopoutElement", "File dialog", "openPopoutElementKeepOpen", "keep open"],
                        ["slideShowSettingsPopoutElement", "Slide show settings"],
                        ["slideShowControlsPopoutElement", "Slide show controls"],
                        ["fileRenamePopoutElement", "Rename file"],
                        ["fileDeletePopoutElement", "Delete file"],
                        ["aboutPopoutElement", "About"],
                        ["imgurPopoutElement", "Imgur"],
                        ["wallpaperPopoutElement", "Wallpaper"],
                        ["filterPopoutElement", "Filter"]]

    content: [

        Flow {
            spacing: 5
            width: set.contwidth

             Repeater {
                 id: rpt
                 model: pops.length
                 PQTile {
                     text: pops[index][1]
                     secondText: pops[index].length==4 ? pops[index][3] : ""
                 }
             }
         }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {

            for(var i = 0; i < pops.length; ++i) {
                rpt.itemAt(i).checked = PQSettings[pops[i][0]]
                if(pops[i].length == 4)
                    rpt.itemAt(i).secondChecked = PQSettings[pops[i][2]]

            }
        }

        onSaveAllSettings: {
            for(var i = 0; i < pops.length; ++i) {
                PQSettings[pops[i][0]] = rpt.itemAt(i).checked
                if(pops[i].length == 4)
                    PQSettings[pops[i][2]] = rpt.itemAt(i).secondChecked
            }
        }

    }

}
