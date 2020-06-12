import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Popout Elements"
    helptext: "Here you can choose for most elements whether they are to be shown integrated into the main window or in their own, separate window."
    content: [

        Flow {
            spacing: 10
            width: 500
            PQCheckbox {
                id: pop_mainmenu
                text: "Main Menu"
            }
            PQCheckbox {
                id: pop_metadata
                text: "Metadata"
            }
            PQCheckbox {
                id: pop_histogram
                text: "Histogram"
            }
            PQCheckbox {
                id: pop_scale
                text: "Scale"
            }
            PQCheckbox {
                id: pop_filedialog
                text: "File dialog"
            }
            PQCheckbox {
                id: pop_filedialog_keepopen
                text: "File dialog (keep open)"
            }
            PQCheckbox {
                id: pop_slide_settings
                text: "Slide show settings"
            }
            PQCheckbox {
                id: pop_slide_controls
                text: "Slide show controls"
            }
            PQCheckbox {
                id: pop_rename
                text: "Rename file"
            }
            PQCheckbox {
                id: pop_delete
                text: "Delete file"
            }
            PQCheckbox {
                id: pop_about
                text: "About"
            }
            PQCheckbox {
                id: pop_imgur
                text: "Imgur"
            }
            PQCheckbox {
                id: pop_wallpaper
                text: "Wallpaper"
            }
            PQCheckbox {
                id: pop_filter
                text: "Filter"
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            pop_mainmenu.checked = PQSettings.mainMenuPopoutElement
            pop_metadata.checked = PQSettings.metadataPopoutElement
            pop_histogram.checked = PQSettings.histogramPopoutElement
            pop_scale.checked = PQSettings.scalePopoutElement
            pop_filedialog.checked = PQSettings.openPopoutElement
            pop_filedialog_keepopen.checked = PQSettings.openPopoutElementKeepOpen
            pop_slide_settings.checked = PQSettings.slideShowSettingsPopoutElement
            pop_slide_controls.checked = PQSettings.slideShowControlsPopoutElement
            pop_rename.checked = PQSettings.fileRenamePopoutElement
            pop_delete.checked = PQSettings.fileDeletePopoutElement
            pop_about.checked = PQSettings.aboutPopoutElement
            pop_imgur.checked = PQSettings.imgurPopoutElement
            pop_wallpaper.checked = PQSettings.wallpaperPopoutElement
            pop_filter.checked = PQSettings.filterPopoutElement
        }

        onSaveAllSettings: {
            PQSettings.mainMenuPopoutElement = pop_mainmenu.checked
            PQSettings.metadataPopoutElement = pop_metadata.checked
            PQSettings.histogramPopoutElement = pop_histogram.checked
            PQSettings.scalePopoutElement = pop_scale.checked
            PQSettings.openPopoutElement = pop_filedialog.checked
            PQSettings.openPopoutElementKeepOpen = pop_filedialog_keepopen.checked
            PQSettings.slideShowSettingsPopoutElement = pop_slide_settings.checked
            PQSettings.slideShowControlsPopoutElement = pop_slide_controls.checked
            PQSettings.fileRenamePopoutElement = pop_rename.checked
            PQSettings.fileDeletePopoutElement = pop_delete.checked
            PQSettings.aboutPopoutElement = pop_about.checked
            PQSettings.imgurPopoutElement = pop_imgur.checked
            PQSettings.wallpaperPopoutElement = pop_wallpaper.checked
            PQSettings.filterPopoutElement = pop_filter.checked
        }

    }

}
