import QtQuick 2.9

import "../../../elements"

PQFileTypeTile {

    title: "libarchive"

    available: PQImageFormats.getAvailableEndingsWithDescriptionArchive()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsArchive()
    currentlyEnabled: PQImageFormats.enabledFileformatsArchive
    projectWebpage: ["libarchive.org", "https://libarchive.org"]

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
