/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
