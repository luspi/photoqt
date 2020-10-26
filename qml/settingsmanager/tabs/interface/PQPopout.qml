import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title. The popping out that is talked about here refers to the possibility of showing any element in its own window (i.e., popped out).
    title: em.pty+qsTranslate("settingsmanager_interface", "pop out elements")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Here you can choose for most elements whether they are to be shown integrated into the main window or in their own, separate window.")

    //: Used as identifying name for one of the elements in the interface
    property var pops: [["openPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "File dialog"), "openPopoutElementKeepOpen", em.pty+qsTranslate("settingsmanager_interface", "keep open")],
                        //: Used as identifying name for one of the elements in the interface
                        ["settingsManagerPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Settings Manager")],
                        //: Used as identifying name for one of the elements in the interface
                        ["mainMenuPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Main Menu")],
                        //: Used as identifying name for one of the elements in the interface
                        ["metadataPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Metadata")],
                        //: Used as identifying name for one of the elements in the interface
                        ["histogramPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Histogram")],
                        //: Used as identifying name for one of the elements in the interface
                        ["scalePopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Scale")],
                        //: Used as identifying name for one of the elements in the interface
                        ["slideShowSettingsPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Slideshow Settings")],
                        //: Used as identifying name for one of the elements in the interface
                        ["slideShowControlsPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Slideshow Controls")],
                        //: Used as identifying name for one of the elements in the interface
                        ["fileRenamePopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Rename File")],
                        //: Used as identifying name for one of the elements in the interface
                        ["fileDeletePopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Delete File")],
                        //: Used as identifying name for one of the elements in the interface
                        ["aboutPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "About")],
                        //: Used as identifying name for one of the elements in the interface
                        ["imgurPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Imgur")],
                        //: Used as identifying name for one of the elements in the interface
                        ["wallpaperPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Wallpaper")],
                        //: Noun, not a verb. Used as identifying name for one of the elements in the interface
                        ["filterPopoutElement", em.pty+qsTranslate("settingsmanager_interface", "Filter")]]

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
