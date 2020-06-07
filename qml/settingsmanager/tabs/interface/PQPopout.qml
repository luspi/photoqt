import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Popout Elements"
    helptext: "Here you can choose for most elements whether they are to be shown integrated into the main window or in their own, separate window."
    expertmodeonly: true
    content: [

        Flow {
            spacing: 10
            width: 500
            PQCheckbox {
                text: "Main Menu"
            }
            PQCheckbox {
                text: "Metadata"
            }
            PQCheckbox {
                text: "Histogram"
            }
            PQCheckbox {
                text: "Scale"
            }
            PQCheckbox {
                text: "File dialog"
            }
            PQCheckbox {
                text: "File dialog (keep open)"
            }
            PQCheckbox {
                text: "Slide show settings"
            }
            PQCheckbox {
                text: "Slide show controls"
            }
            PQCheckbox {
                text: "Rename file"
            }
            PQCheckbox {
                text: "Delete file"
            }
            PQCheckbox {
                text: "About"
            }
            PQCheckbox {
                text: "Imgur"
            }
            PQCheckbox {
                text: "Wallpaper"
            }
            PQCheckbox {
                text: "Filter"
            }
        }

    ]
}
