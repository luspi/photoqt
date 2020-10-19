import QtQuick 2.9

import "../../../elements"

PQFileTypeTile {

    title: "Poppler"

    visible: handlingGeneral.isPopplerSupportEnabled()

    available: PQImageFormats.getAvailableEndingsWithDescriptionPoppler()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsPoppler()
    currentlyEnabled: PQImageFormats.enabledFileformatsPoppler
    projectWebpage: ["poppler.freedesktop.org", "https://poppler.freedesktop.org"]
    description: em.pty+qsTranslate("settingsmanager_filetypes", "PhotoQt can take advantage of poppler to load PDF documents. It can either load them together with the rest of the images (each page as one image) or it can ignore such documents except when asked to open one, then it wont load any other images (like a document viewer).")

    additionalSetting: [
        Row {
            x: (parent.width-width)/2
            y: 10
            spacing: 10
            PQCheckbox {
                id: docviewer
                //: this is a display mode for PDF files
                text: em.pty+qsTranslate("settingsmanager_filetypes", "document viewer")
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
                //: the quality setting to be used when loading PDFs
                toolTipPrefix: em.pty+qsTranslate("settingsmanager_filetypes", "Quality: ")
            }
        }
    ]
    additionalSettingShow: true


    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
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

    Component.onCompleted: {
        load()
    }

    function load() {
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

}
