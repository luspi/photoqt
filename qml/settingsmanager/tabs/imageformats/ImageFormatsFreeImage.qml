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

            enabled: getanddostuff.isFreeImageSupportEnabled()

            id: titletext
            title: em.pty+qsTr("FreeImage image library")
            helptext: em.pty+qsTr("FreeImage is an open source image library supporting a number of image formats, many of which have been successfully tested in PhotoQt.") +
                      "<br><br>" +
                      em.pty+qsTr("Use left click to check/uncheck an individual entry, and right click to check/uncheck all endings related to the same image type.")
            imageSource: "qrc:/img/settings/imageformats/freeimage.jpg"
            fontcolor: enabled ? colour.text : colour.text_disabled

        }

        EntrySetting {

            enabled: getanddostuff.isFreeImageSupportEnabled()

            Row {

                id: entryrow
                y: height/2

                spacing: 10

                CustomButton {
                    //: Used as in 'Use set of default file endings'
                    text: em.pty+qsTr("Use default formats")
                    onClickedButton: formatsPopup.setDefault()
                }
                CustomButton {
                    //: Used as in 'Use none of the available file endings'
                    text: em.pty+qsTr("Use none")
                    onClickedButton: formatsPopup.setNone()
                }
                CustomButton {
                    //: 'fine tuning' refers to selecting the individual file endings recognised by PhotoQt
                    text: em.pty+qsTr("Advanced fine tuning")
                    onClickedButton: formatsPopup.show()
                }

                SettingsText {
                    y: (parent.height-height)/2
                    text: em.pty+qsTr("There are currently %1 file endings selected").arg("<b>"+formatsPopup.numItemsChecked+"</b>")
                }

            }

            Text {
                width: entryrow.width
                height: entryrow.height*2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 20
                font.bold: true
                visible: !getanddostuff.isFreeImageSupportEnabled()
                color: "white"
                text: em.pty+qsTr("UNAVAILABLE")
            }

        }

    }

    Popup {

        id: formatsPopup
        title: titletext.title
        availableFormats: imageformats.getAvailableEndingsWithDescriptionFreeImage()
        enabledFormats: imageformats.enabledFileformatsFreeImage
        defaultFormats: imageformats.getDefaultEnabledEndingsFreeImage()

        Connections {
            target: imageformats
            onEnabledFileformatsChanged:
                formatsPopup.enabledFormats = imageformats.enabledFileformatsFreeImage
        }

        onVisibleChanged: settings_top.imageFormatsAdvancedTuningPopupVisible = visible

    }

    function setData() {
        formatsPopup.setCurrentlySet()
    }

    function saveData() {
        imageformats.enabledFileformatsFreeImage = formatsPopup.getEnabledFormats()
    }

}
