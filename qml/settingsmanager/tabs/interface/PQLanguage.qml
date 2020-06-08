import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {

    property var languageitems: [["en/en_IE/en_US/en_CA","English"],
                                 ["ar","عربي ,عربى"],
                                 ["cs","Čeština"],
                                 ["de/de_DE/de_CH/de_AT","Deutsch"],
                                 ["el","Ελληνικά"],
                                 ["es/es_ES","Español (España)"],
                                 ["es_CR","Español (Costa Rica)"],
                                 ["fi","Suomen kieli"],
                                 ["fr/fr_FR","Français"],
                                 ["he","עברית"],
                                 ["it","Italiano"],
                                 ["ja","日本語"],
                                 ["lt","lietuvių kalba"],
                                 ["pl","Polski"],
                                 ["pt_BR","Português (Brasil)"],
                                 ["pt/pt_PT","Português (Portugal)"],
                                 ["ru/ru_RU","русский язык"],
                                 ["sk","Slovenčina"],
                                 ["tr","Türkçe"],
                                 ["uk/uk_UA","Українська"],
                                 ["zh/zh_CN","Chinese"],
                                 ["zh_TW","Chinese (traditional)"]]

    title: "Language"
    helptext: "Change the language of the application."
    content: [
        PQComboBox {
            id: lang
            y: (parent.height-height)/2
        }
    ]

    Component.onCompleted: {
        var mod = []
        for(var i = 0; i < languageitems.length; ++i)
            mod.push(languageitems[i][1])
        lang.model = mod
        loadLang()
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            loadLang()
        }

        onSaveAllSettings: {
            PQSettings.language = languageitems[lang.currentIndex][0]
        }

    }

    function loadLang() {
        var foundIndex = -1
        var settingsLanguage = PQSettings.language.split("/")[0]

        for(var i = 0; i < languageitems.length; ++i) {
            var l = languageitems[i][0].split("/")
            for(var j = 0; j < l.length; ++j) {
                if(l[j] == settingsLanguage) {
                    foundIndex = i
                    break
                }
            }
            if(foundIndex != -1)
                break;
        }
        if(foundIndex == -1)
            foundIndex = 0
        lang.currentIndex = foundIndex
    }

}
