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

    id: entrytop

    visible: getanddostuff.isLibRawSupportEnabled()

    title: "libraw: RAW"
    helptext: em.pty+qsTranslate("SettingsManager/ImageFormats", "With the help of libraw PhotoQt can display almost any raw image that exists.") +
              "<br><br>" +
              em.pty+qsTranslate("SettingsManager/ImageFormats", "Use left click to check/uncheck an individual entry, and right click to\
 check/uncheck all endings related to the same image type.")
    imageSource: "qrc:/img/settings/imageformats/empty.png"

    content: [

        SettingsText {
            id: txt1
            height: but1.height
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            //: File endings are the suffices (e.g., 'jpg' for 'image.jpg')
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "File endings:")
        },
        CustomButton {
            id: but1
            //: Used as in 'Use set of default file endings'
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Use default")
            onClickedButton: formatsPopupEndings.setDefault()
        },
        CustomButton {
            //: Used as in 'Use none of the available file endings'
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Use none")
            onClickedButton: formatsPopupEndings.setNone()
        },
        CustomButton {
            //: 'fine tuning' refers to selecting the individual file endings recognised by PhotoQt
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Advanced fine tuning")
            onClickedButton: formatsPopupEndings.show()
        },
        SettingsText {
            height: but1.height
            verticalAlignment: Text.AlignVCenter
            //: Please do not forget the '%1'!
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "There are currently %1 file endings selected.")
                                .arg("<b>"+formatsPopupEndings.numItemsChecked+"</b>")
        }

    ]

    content2: [

        SettingsText {
            id: txt2
            height: but2.height
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            //: Mime types are identifiers for file types.
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Mime types:")
        },
        CustomButton {
            id: but2
            //: Used as in 'Use set of default file endings'
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Use default")
            onClickedButton: formatsPopupMimetypes.setDefault()
        },
        CustomButton {
            //: Used as in 'Use none of the available file endings'
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Use none")
            onClickedButton: formatsPopupMimetypes.setNone()
        },
        CustomButton {
            //: 'fine tuning' refers to selecting the individual file endings recognised by PhotoQt
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "Advanced fine tuning")
            onClickedButton: formatsPopupMimetypes.show()
        },
        SettingsText {
            height: but2.height
            verticalAlignment: Text.AlignVCenter
            //: Please do not forget the '%1'!
            text: em.pty+qsTranslate("SettingsManager/ImageFormats", "There are currently %1 mime types selected.")
                                .arg("<b>"+formatsPopupMimetypes.numItemsChecked+"</b>")
        }

    ]

    Component.onCompleted: {
        but1.width = Math.max(but1.width, but2.width)
        but2.width = Math.max(but1.width, but2.width)
        txt1.width = Math.max(txt1.width, txt2.width)
        txt2.width = Math.max(txt1.width, txt2.width)
    }

    PopupImageFormats {

        id: formatsPopupEndings
        title: entrytop.title
        availableFormats: imageformats.getAvailableEndingsWithDescriptionRAW()
        enabledFormats: imageformats.enabledFileformatsRAW
        defaultFormats: imageformats.getDefaultEnabledEndingsRAW()

        Connections {
            target: imageformats
            onEnabledFileformatsChanged:
                formatsPopupEndings.enabledFormats = imageformats.enabledFileformatsRAW
        }

        onVisibleChanged: settings_top.imageFormatsAdvancedTuningPopupVisible = visible

    }

    PopupMimeTypes {

        id: formatsPopupMimetypes
        title: entrytop.title
        availableFormats: mimetypes.getAvailableMimeTypesWithDescriptionRAW()
        enabledFormats: mimetypes.enabledMimeTypesRAW
        defaultFormats: mimetypes.getDefaultEnabledMimeTypesRAW()

        Connections {
            target: mimetypes
            onEnabledMimeTypesChanged:
                formatsPopupMimetypes.enabledFormats = mimetypes.enabledMimeTypesRAW
        }

        onVisibleChanged: settings_top.imageFormatsAdvancedTuningPopupVisible = visible

    }

    function setData() {
        formatsPopupEndings.setCurrentlySet()
        formatsPopupMimetypes.setCurrentlySet()
    }

    function saveData() {
        imageformats.enabledFileformatsRAW = formatsPopupEndings.getEnabledFormats()
        mimetypes.enabledMimeTypesRAW = formatsPopupMimetypes.getEnabledFormats()
    }

}
