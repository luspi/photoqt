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

Entry {

    title: "xcftools: XCF (Gimp)"
    helptext: em.pty+qsTranslate("SettingsManager/ImageFormats", "PhotoQt can take advantage of xcftools to display Gimp's XCF file format. It can only be enabled if xcftools is installed!")
//    imageSource: "qrc:/img/settings/imageformats/empty.png"

    content: [
        CustomCheckBox {
            id: xcftoolsEnding
            text: qsTranslate("SettingsManager/ImageFormats", "File endings:") + " *.xcf"
        },
        CustomCheckBox {
            id: xcftoolsMime
            text: qsTranslate("SettingsManager/ImageFormats", "Mime types:") + " image/x-xcf"
        }

    ]

    function setData() {
        xcftoolsEnding.checkedButton = (imageformats.enabledFileformatsXCFTools.indexOf("*.xcf") != -1)
        xcftoolsMime.checkedButton = (mimetypes.enabledMimeTypesXCFTools.indexOf("image/x-xcf") != -1)
    }

    function saveData() {
        imageformats.enabledFileformatsXCFTools = (xcftoolsEnding.checkedButton ? ["*.xcf"] : [])
        mimetypes.enabledMimeTypesXCFTools = (xcftoolsMime.checkedButton ? ["image/x-xcf"] : [])
    }

}
