/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "sort images by")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Sort all images in a folder by the set property.")
    content: [

        Flow  {

            spacing: 10
            width: set.contwidth

            PQComboBox {
                id: sort_combo
                //: A criteria for sorting images
                model: [em.pty+qsTranslate("settingsmanager_imageview", "natural name"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager_imageview", "name"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager_imageview", "time"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager_imageview", "size"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager_imageview", "type")]
            }

            PQRadioButton {
                id: sort_asc
                height: sort_combo.height
                //: Sort images in ascending order
                text: em.pty+qsTranslate("settingsmanager_imageview", "ascending")
            }

            PQRadioButton {
                id: sort_desc
                height: sort_combo.height
                //: Sort images in descending order
                text: em.pty+qsTranslate("settingsmanager_imageview", "descending")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            if(sort_combo.currentIndex == 0)
                PQSettings.SortImagesBy = "naturalname"
            else if(sort_combo.currentIndex == 1)
                PQSettings.SortImagesBy = "name"
            else if(sort_combo.currentIndex == 2)
                PQSettings.SortImagesBy = "time"
            else if(sort_combo.currentIndex == 3)
                PQSettings.SortImagesBy = "size"
            else
                PQSettings.SortImagesBy = "type"

            PQSettings.SortImagesAscending = sort_asc.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        if(PQSettings.SortImagesBy == "name")
            sort_combo.currentIndex = 1
        else if(PQSettings.SortImagesBy == "time")
            sort_combo.currentIndex = 2
        else if(PQSettings.SortImagesBy == "size")
            sort_combo.currentIndex = 3
        else if(PQSettings.SortImagesBy == "type")
            sort_combo.currentIndex = 4
        else
            sort_combo.currentIndex = 0

        sort_asc.checked = PQSettings.SortImagesAscending
        sort_desc.checked = !PQSettings.SortImagesAscending
    }

}
