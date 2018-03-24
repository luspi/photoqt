/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    visible: getanddostuff.isPopplerSupportEnabled()

    Row {

        spacing: 20

        EntryTitle {

            id: titletext
            title: "poppler: Adobe PDF"
            helptext: em.pty+qsTr("PhotoQt can take advantage of poppler to load PDF documents. It can either load them together with the rest of the images (each page as one image) or it can ignore such documents except when asked to open one, then it wont load any other images (like a document viewer).")
            imageSource: "qrc:/img/settings/imageformats/poppler.jpg"
            fontcolor: enabled ? colour.text : colour.text_disabled

        }

        EntrySetting {

            Row {

                id: entryrow

                spacing: 10

                CustomCheckBox {
                    id: popplerEnding
                    text: "File ending: *.pdf, *.epdf"
                }
                CustomCheckBox {
                    id: popplerMime
                    text: "Mime type: application/pdf"
                }
                Item { height: 2; width: 5 }
                CustomCheckBox {
                    id: singledocument
                    text: em.pty+qsTr("Document viewer mode")
                    tooltip: em.pty+qsTr("When loading a PDF, only that PDF is loaded, nothing else in the folder")
                }
                Item { height: 2; width: 5 }
                SettingsText {
                    id: qualitytextleft
                    text: "Low quality"
                }
                CustomSlider {
                    id: qualityslider
                    y: (qualitytextleft.height-height)/2
                    minimumValue: 75
                    maximumValue: 300
                    value: 150
                    stepSize: 5
                    scrollStep: 5
                    tooltip: value+"dpi"
                }
                SettingsText {
                    id: qualitytextright
                    text: "High quality"
                }

            }

        }

    }

    function setData() {
        popplerEnding.checkedButton = (imageformats.enabledFileformatsPoppler.indexOf("*.pdf") != -1)
        popplerMime.checkedButton = (mimetypes.enabledMimeTypesPoppler.indexOf("application/pdf") != -1)
        singledocument.checkedButton = settings.pdfSingleDocument

        // We always take the PDF quality in steps of 5!
        var q = settings.pdfQuality
        var qp5 = q%5
        if(qp5 != 0) {
            if(qp5 < 3)
                q -= qp5
            else
                q += (5-qp5)
        }
        qualityslider.value = q
    }

    function saveData() {
        imageformats.enabledFileformatsPoppler = (popplerEnding.checkedButton ? ["*.pdf", "*.epdf"] : [])
        mimetypes.enabledMimeTypesPoppler = (popplerMime.checkedButton ? ["application/pdf"] : [])
        settings.pdfSingleDocument = singledocument.checkedButton
        settings.pdfQuality = qualityslider.value
    }

}
