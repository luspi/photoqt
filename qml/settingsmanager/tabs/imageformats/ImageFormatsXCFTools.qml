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

            id: titletext
            title: "xcftools: XCF (Gimp)"
            helptext: em.pty+qsTr("PhotoQt can take advantage of xcftools to display Gimp's XCF file format. It can only be enabled if xcftools is installed!")
            imageSource: "qrc:/img/settings/imageformats/empty.png"

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: xcftools
                    text: em.pty+qsTr("Use xcftools")
                }

            }

        }

    }

    function setData() {
        xcftools.checkedButton = (imageformats.enabledFileformatsXCFTools.indexOf("*.xcf") != -1)
    }

    function saveData() {
        imageformats.enabledFileformatsXCFTools = (xcftools.checkedButton ? ["*.xcf"] : [])
    }

}
