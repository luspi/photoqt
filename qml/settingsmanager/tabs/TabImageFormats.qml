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

import "./imageformats"
import "../../elements"


Item {

    id: tab_top

    property int titlewidth: 100

    anchors {
        fill: parent
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height+20
        contentWidth: maincol.width

        Column {

            id: maincol

            Item { width: 1; height: 10 }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 20
                font.bold: true
                text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Image formats")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20 }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 9
                text: em.pty+qsTranslate("SettingsManager", "Move your mouse cursor over (or click on) the different settings titles to see more information.")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20 }

            Text {
                color: "white"
                width: flickable.width-20
                x: 10
                wrapMode: Text.WordWrap
                //: Introduction text of metadata tab in settings manager
                text: em.pty+qsTranslate("SettingsManager/ImageFormats", "PhotoQt can make use of a variety of image libraries. Which ones exactly are available depends on your system and your installation of PhotoQt. Some formats can be loaded by more than just one of the libraries. For each image PhotoQt will check each library in the same order as they are shown here and will use the first one for which the image type is enabled. There are two ways PhotoQt can find the right image library to be used: Either by the file ending, or by the mime type of the file itself (if one is available). So in order to disable a format from a library, make sure that neither the respective file ending nor the mime type is enabled.")
            }

            Item { width: 1; height: 30 }

            Rectangle { color: "#88ffffff"; width: tab_top.width; height: 1; }

            Item { width: 1; height: 20 }

            ImageFormatsQt { id: imageformatsqt }
            ImageFormatsPoppler { id: imageformatspoppler }
            ImageFormatsXCFTools { id: imageformatsxcftools }
            ImageFormatsArchive { id: imageformatsarchive }
            ImageFormatsRAW { id: imageformatsraw }
            ImageFormatsGm { id: imageformatsgm }
            ImageFormatsGmGhostscript { id: imageformatsgmghostscript }
            ImageFormatsDevil { id: imageformatsdevil }
            ImageFormatsFreeImage { id: imageformatsfreeimage }

        }

    }

    function setData() {

        verboseMessage("SettingsManager/TabFileFormats", "setData()")

        imageformatsqt.setData()
        imageformatsxcftools.setData()
        imageformatspoppler.setData()
        imageformatsgm.setData()
        imageformatsgmghostscript.setData()
        imageformatsraw.setData()
        imageformatsarchive.setData()
        imageformatsdevil.setData()
        imageformatsfreeimage.setData()

    }

    function saveData() {

        verboseMessage("SettingsManager/TabFileFormats", "saveData()")

        imageformatsqt.saveData()
        imageformatsxcftools.saveData()
        imageformatspoppler.saveData()
        imageformatsgm.saveData()
        imageformatsgmghostscript.saveData()
        imageformatsraw.saveData()
        imageformatsarchive.saveData()
        imageformatsdevil.saveData()
        imageformatsfreeimage.saveData()

    }

}
