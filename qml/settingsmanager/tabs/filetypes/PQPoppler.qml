/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title
    title: "Poppler"
    helptext: em.pty+qsTranslate("settingsmanager_filetypes", "These are some additional settings for showing PDFs.")
    expertmodeonly: true
    available: handlingGeneral.isPopplerSupportEnabled()
    content: [

        Row {

            spacing: 10

            Text {
                id: docviewer
                color: "white"
                text: em.pty+qsTranslate("settingsmanager_filetypes", "Quality:")
            }
            PQSlider {
                id: qual_slider
                y: (docviewer.height-height)/2
                from: 50
                to: 500
                stepSize: 5
                wheelStepSize: 5
                toolTipSuffix: " dpi"
                //: the quality setting to be used when loading PDFs
                toolTipPrefix: em.pty+qsTranslate("settingsmanager_filetypes", "Quality:") + " "
            }

            Text {
                color: "white"
                text: qual_slider.value + " dpi"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.filetypesPDFQuality = qual_slider.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {

        // We always take the PDF quality in steps of 5!
        var q = PQSettings.filetypesPDFQuality
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
