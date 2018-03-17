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

    Row {

        spacing: 20

        EntryTitle {

            enabled: getanddostuff.isPopplerSupportEnabled()

            id: titletext
            title: "poppler: PDF"
            helptext: em.pty+qsTr("PhotoQt can take advantage of poppler to load PDF documents. It can either load them together with the rest of the picture (each page as one picture) or it can ignore such documents except when asked to open one, it wont load any other picture (like a document viewer).")
            imageSource: "qrc:/img/settings/imageformats/poppler.png"
            fontcolor: enabled ? colour.text : colour.text_disabled

        }

        EntrySetting {

            enabled: getanddostuff.isPopplerSupportEnabled()

            Row {

                id: entryrow
                y: height/2

                spacing: 10

                CustomCheckBox {
                    id: poppler
                    text: "poppler (*.pdf, *.epdf)"
                }
                CustomCheckBox {
                    id: singledocument
                    text: em.pty+qsTr("Load single document (like document viewer)")
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

            Text {
                width: entryrow.width
                height: entryrow.height*2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 20
                font.bold: true
                visible: !getanddostuff.isPopplerSupportEnabled()
                color: "white"
                text: "DISABLED"
            }

        }

    }

    function setData() {
        poppler.checkedButton = (imageformats.enabledFileformatsPoppler.indexOf("*.pdf") != -1)
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
        imageformats.enabledFileformatsPoppler = (poppler.checkedButton ? ["*.pdf", "*.epdf"] : [])
        settings.pdfSingleDocument = singledocument.checkedButton
        settings.pdfQuality = qualityslider.value
    }

}
