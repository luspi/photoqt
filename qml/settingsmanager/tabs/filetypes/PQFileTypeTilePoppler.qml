import QtQuick 2.9

import "../../../elements"

PQFileTypeTile {

    title: "Poppler"

    visible: handlingGeneral.isPopplerSupportEnabled()

    available: PQImageFormats.getAvailableEndingsWithDescriptionPoppler()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsPoppler()
    currentlyEnabled: PQImageFormats.enabledFileformatsPoppler
    projectWebpage: ["poppler.freedesktop.org", "https://poppler.freedesktop.org"]

    additionalSetting: [
        Row {
            x: (parent.width-width)/2
            y: 10
            spacing: 10
            PQCheckbox {
                id: docviewer
                text: "document viewer"
            }
            PQSlider {
                id: qual_slider
                y: (docviewer.height-height)/2
                enabled: docviewer.checked
                from: 75
                to: 350
                stepSize: 5
                wheelStepSize: 5
                toolTipSuffix: " dpi"
                toolTipPrefix: "Quality: "
            }
        }
    ]
    additionalSettingShow: true


    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
            docviewer.checked = PQSettings.pdfSingleDocument

            // We always take the PDF quality in steps of 5!
            var q = PQSettings.pdfQuality
            var qp5 = q%5
            if(qp5 != 0) {
                if(qp5 < 3)
                    q -= qp5
                else
                    q += (5-qp5)
            }
            qual_slider.value = q
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsPoppler = c

            PQSettings.pdfSingleDocument = docviewer.checked
            PQSettings.pdfQuality = qual_slider.value
        }

    }

}
