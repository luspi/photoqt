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

    property var languageitems: []

    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "language")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Change the language of the application.")
    content: [
        PQComboBox {
            id: lang
        }
    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            loadLang()
        }

        onSaveAllSettings: {
            PQSettings.interfaceLanguage = languageitems[lang.currentIndex]
        }

    }

    function loadLang() {

        // LOAD AVAILABLE LANGUAGES

        var languages = {"en" : "English",
                         "ar" : "عربي ,عربى",
                         "cs" : "Čeština",
                         "de" : "Deutsch", "de_DE" : "Deutsch",
                         "el" : "Ελληνικά",
                         "es" : "Español", "es_ES" : "Español",
                         "es_CR" : "Español (Costa Rica)",
                         "fi" : "Suomen kieli",
                         "fr" : "Français",
                         "he" : "עברית",
                         "it" : "Italiano",
                         "ja" : "日本語",
                         "lt" : "lietuvių kalba", "lt_LT" : "lietuvių kalba",
                         "pl" : "Polski", "pl_PL" : "Polski",
                         "pt" : "Português (Portugal)", "pt_PT" : "Português (Portugal)",
                         "pt_BR" : "Português (Brasil)",
                         "ru" : "русский язык",
                         "sk" : "Slovenčina",
                         "tr" : "Türkçe",
                         "uk" : "Українська",
                         "zh" : "Chinese",
                         "zh_TW" : "Chinese (traditional)"}

        var tmp = []

        var trans = handlingGeneral.getAvailableTranslations()
        for(var i in trans) {

            var cur = trans[i]

            // if the current one is in the dict, done
            if(cur in languages) {
                tmp.push(languages[cur])
                languageitems.push(cur)
            } else {
                if(cur.includes("_")) {
                    var cur2 = cur.split("_")[0]
                    if(cur2 in languages) {
                        tmp.push(languages[cur2])
                        languageitems.push(cur2)
                    } else {
                        tmp.push(cur)
                        languageitems.push(cur)
                    }
                }
            }

        }

        lang.model = tmp


        // FIND SELECTED LANGUAGE

        var foundIndex = 0
        var l = PQSettings.interfaceLanguage.split("/")[0]

        if(languageitems.indexOf(l) != -1)
            foundIndex = languageitems.indexOf(l)
        else if(l.includes("_")) {
            l = l.split("_")[0]
            if(languageitems.indexOf(l) != -1)
                foundIndex = languageitems.indexOf(l)
        }

        if(foundIndex == 0) {
            var langtmp = []
            for(var i in languageitems)
                langtmp.push(languageitems[i].split("_")[0])
            if(langtmp.indexOf(l) != -1)
                foundIndex = langtmp.indexOf(l)
        }

        lang.currentIndex = foundIndex

    }

}
