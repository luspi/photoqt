import QtQuick 2.9

PQFileTypeTile {

    title: "XCFTools"

    available: PQImageFormats.getAvailableEndingsWithDescriptionXCF()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsXCF()
    currentlyEnabled: PQImageFormats.enabledFileformatsXCF
    projectWebpage: ["henning.makholm.net", "http://henning.makholm.net/software"]
    description: em.pty+qsTranslate("settingsmanager_filetypes", "PhotoQt can take advantage of xcftools to display Gimp's XCF file format. It can only be enabled if xcftools is installed!")

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsXCF = c
        }

    }

    Component.onCompleted: {
        resetChecked()
    }

}
