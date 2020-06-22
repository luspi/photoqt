import QtQuick 2.9

import "../../../elements"

PQFileTypeTile {

    title: "libarchive"

    available: PQImageFormats.getAvailableEndingsWithDescriptionArchive()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsArchive()
    currentlyEnabled: PQImageFormats.enabledFileformatsArchive
    projectWebpage: ["libarchive.org", "https://libarchive.org"]
    description: "PhotoQt takes advantage of tools such as 'libarchive' to load packed files (zip, rar, tar, 7z). It can either load them together with the rest of the images (each (supported) file as one image) or it can ignore such files except when asked to open one, then it wont load any other images (like a document viewer).<br><br>Note regarding RAR archives: 'libarchive' supports RAR archives only partially and might fail to read certain archives. If installed, PhotoQt can use the external tool 'unrar' instead of 'libarchive' for proper support of RAR archives."

    additionalSetting: [
        Row {
            x: (parent.width-width)/2
            y: 10
            spacing: 10
            PQCheckbox {
                id: ext_unrar
                text: "use external 'unrar'"
            }
            PQCheckbox {
                id: isolate
                text: "isolate archives"
            }
        }
    ]
    additionalSettingShow: true

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
            ext_unrar.checked = PQSettings.archiveUseExternalUnrar
            isolate.checked = PQSettings.archiveSingleFile
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsArchive = c
            PQSettings.archiveUseExternalUnrar = ext_unrar.checked
            PQSettings.archiveSingleFile = isolate.checked
        }

    }

}
