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

            id: title
            title: em.pty+qsTr("Language")
            helptext: em.pty+qsTr("There are a good few different languages available. Thanks to everybody who took the time to translate PhotoQt!")

        }

        EntrySetting {

            id: entry

            ExclusiveGroup { id: languagegroup; }

            GridView {

                property var languageitems: [["en/en_IE/en_US/en_CA","English",""],
                                            ["ar","عربي ,عربى",""],
                                            ["cs","Čeština",""],
                                            ["de/de_DE/de_CH/de_AT","Deutsch",""],
                                            ["el","Ελληνικά",""],
                                            ["es/es_ES","Español (España)",""],
                                            ["es_CR","Español (Costa Rica)",""],
                                            ["fi","Suomen kieli",""],
                                            ["fr/fr_FR","Français",""],
                                            ["he","עברית",""],
                                            ["it","Italiano",""],
                                            ["ja","日本語",""],
                                            ["lt","lietuvių kalba",""],
                                            ["pl","Polski",""],
                                            ["pt_BR","Português (Brasil)",""],
                                            ["pt/pt_PT","Português (Portugal)",""],
                                            ["ru/ru_RU","русский язык",""],
                                            ["sk","Slovenčina",""],
                                            ["tr","Türkçe",""],
                                            ["uk/uk_UA","Українська",""],
                                            ["zh/zh_CN","Chinese",""],
                                            ["zh_TW","Chinese (traditional)",""]]

                property string currentlySelected: ""

                interactive: false

                id: grid
                width: Math.floor((item_top.width-title.width-title.x-parent.parent.spacing-5)/(cellWidth)) * (cellWidth)
                height: childrenRect.height
                cellWidth: 200
                cellHeight: 30 + 2*spacing
                property int spacing: 3

                model: languageitems.length
                delegate: LanguageTile {
                    id: tile
                    objectName: grid.languageitems[index][0]
                    text: grid.languageitems[index][1]
                    author: grid.languageitems[index][2]
                    checked: objectName.split("/").indexOf(grid.currentlySelected)>-1
                    exclusiveGroup: languagegroup
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing
                }


            }

        }

    }

    function setData() {
        grid.currentlySelected = settings.language
    }

    function saveData() {
        if(languagegroup.current != null)
            settings.language = languagegroup.current.objectName
    }

}
