/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_lang

    SystemPalette { id: pqtPalette }

    property int origIndex

    property var languages: {
        "en" : "English",
        "ar" : "عربي ,عربى",
        "ca_ES" : "Català",
        "cs" : "Čeština",
        "de" : "Deutsch",
        "el" : "Ελληνικά",
        "es" : "Español",
        "es_CR" : "Español (Costa Rica)",
        "fi" : "Suomen kieli",
        "fr" : "Français",
        "he" : "עברית",
        "it" : "Italiano",
        "lt" : "lietuvių kalba",
        "nl" : "Nederlands",
        "pl" : "Polski",
        "pt" : "Português (Portugal)",
        "pt_BR" : "Português (Brasil)",
        "ru" : "Русский",
        "sk" : "Slovenčina",
        "tr" : "Türkçe",
        "uk" : "Українська",
        "zh" : "Chinese (simplified)",
        "zh_TW" : "Chinese (traditional)"
    }

    property list<string> availableLanguages: PQCScriptsConfig.getAvailableTranslations()

    property list<string> langkeys: Object.keys(languages)

    function getLanguageName(code: string) : string {

        if(langkeys.indexOf(code) != -1) {

            return languages[code]

        } else {

            var c = code.split("_")[0]

            if(langkeys.indexOf(c) != -1)
                return languages[c]

        }

        return code

    }

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Language")

            helptext: qsTranslate("settingsmanager",  "PhotoQt has been translated into a number of different languages. Not all of the languages have a complete translation yet, and new translators are always needed. If you are willing and able to help, that would be greatly appreciated.") + "<br><br>" +
                      "<b>" + qsTranslate("settingsmanager", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!") + "</b><br><br>" +
                      qsTranslate("settingsmanager", "If you want to help with the translations, either by translating or by reviewing existing translations, head over to the translation page on Crowdin:") + "<b>https://translate.photoqt.org</b>"

            showLineAbove: false

        },

        PQComboBox {

            id: langcombo
            extrawide: true

            font.weight: PQCLook.fontWeightBold

            onCurrentIndexChanged: set_lang.checkForChanges()


        },

        PQText {
            x: -set_lang.indentWidth
            width: set_lang.rightcol
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            visible: PQCSettings.generalCompactSettings
            // font.weight: PQCLook.fontWeightBold
            text: qsTranslate("settingsmanager", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!")
        },

        /***********************************/

        PQSettingSubtitle {

            title: qsTranslate("settingsmanager", "Interface variant")

            helptext: qsTranslate("settingsmanager", "PhotoQt provides two slightly different variants to its interface. The first one is a highly customized and customizable interface that has been part of PhotoQt since its beginning. The second one is an interface variant that is a little less customizable but instead integrated much better into the desktop environment. Both share a lot of underlying code and support most of the same features and the same support for file types. Which one to choose is mostly a matter of personal preference.")

        },

        PQText {
            x: -set_lang.indentWidth
            width: set_lang.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.weight: PQCLook.fontWeightBold
            text: qsTranslate("settingsmanager", "Note: A change to this setting requires a restart of PhotoQt!")
        },

        Rectangle {
            x: (set_lang.contentWidth-width)/2
            width: Math.min(set_lang.contentWidth, 400)
            height: Math.max(modern_txt.height, integ_txt.height)+20
            border.width: 1
            border.color: modern_mouse.containsMouse ? pqtPalette.highlight : PQCLook.baseBorder
            radius: 2
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                opacity: 0.5
                color: modern_mouse.containsPress ? pqtPalette.highlight : pqtPalette.button
                radius: 2
            }
            PQText {
                id: modern_txt
                x: 10
                y: (parent.height-height)/2
                width: parent.width-20
                enabled: PQCSettings.generalInterfaceVariant==="integrated"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "Switch to modern, more customizable interface")
            }
            PQMouseArea {
                id: modern_mouse
                enabled: PQCSettings.generalInterfaceVariant==="integrated"
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if(PQCScriptsConfig.askForConfirmation("Switch interface variant?", "Switching the interface variant requires a restart of PhotoQt.", "Continue?")) {
                        PQCSettings.generalInterfaceVariant = "modern"
                        reloadMainQMLTimer.restart()
                    }
                }
            }
            Rectangle {
                x: (parent.width-width)
                y: (parent.height-height)
                width: 25
                height: 25
                opacity: 0.4
                visible: !modern_mouse.enabled
                color: pqtPalette.base
                border.width: 2
                border.color: pqtPalette.text
                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/checkmark.svg"
                }
            }
        },

        Rectangle {
            x: (set_lang.contentWidth-width)/2
            width: Math.min(set_lang.contentWidth, 400)
            height: Math.max(modern_txt.height, integ_txt.height)+20
            border.width: 1
            border.color: integ_mouse.containsMouse ? pqtPalette.highlight : PQCLook.baseBorder
            radius: 2
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                opacity: 0.5
                color: integ_mouse.containsPress ? pqtPalette.highlight : pqtPalette.button
                radius: 2
            }
            PQText {
                id: integ_txt
                x: 10
                y: (parent.height-height)/2
                width: parent.width-20
                enabled: PQCSettings.generalInterfaceVariant==="modern"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "Switch to interface that integrates better into your desktop environment")
            }
            PQMouseArea {
                id: integ_mouse
                enabled: PQCSettings.generalInterfaceVariant==="modern"
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if(PQCScriptsConfig.askForConfirmation("Switch interface variant?", "Switching the interface variant requires a restart of PhotoQt.", "Continue?")) {
                        PQCSettings.generalInterfaceVariant = "integrated"
                        reloadMainQMLTimer.restart()
                    }
                }
            }
            Rectangle {
                x: (parent.width-width)
                y: (parent.height-height)
                width: 25
                height: 25
                opacity: 0.4
                visible: !integ_mouse.enabled
                color: pqtPalette.base
                border.width: 2
                border.color: pqtPalette.text
                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/checkmark.svg"
                }
            }
        }

    ]

    Timer {
        id: reloadMainQMLTimer
        interval: 500
        onTriggered: {
            PQCNotify.reloadMainQMLFile(PQCSettings.generalInterfaceVariant)
        }
    }

    onResetToDefaults: {

        var val = PQCSettings.getDefaultForInterfaceLanguage()

        var setindex = availableLanguages.indexOf("en")
        if(availableLanguages.indexOf(val) !== -1)
            setindex = availableLanguages.indexOf(val)
        else {
            var c = val + "_" + val.toUpperCase()
            if(availableLanguages.indexOf(c) !== -1)
                setindex = availableLanguages.indexOf(c)
        }
        langcombo.currentIndex = setindex

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {
        if(!settingsLoaded) return
        PQCConstants.settingsManagerSettingChanged = (origIndex !== langcombo.currentIndex)
    }

    function load() {

        settingsLoaded = false

        var m = []
        for(var i in availableLanguages) {
            m.push(getLanguageName(availableLanguages[i]))
        }
        console.warn(">>> m =", m)
        langcombo.model = m

        var code = PQCSettings.interfaceLanguage

        var setindex = availableLanguages.indexOf("en")

        if(availableLanguages.indexOf(code) !== -1)
            setindex = availableLanguages.indexOf(code)
        else {
            var c = code + "_" + code.toUpperCase()
            if(availableLanguages.indexOf(c) !== -1)
                setindex = availableLanguages.indexOf(c)
        }

        origIndex = setindex
        langcombo.currentIndex = setindex

        PQCConstants.settingsManagerSettingChanged = false

        settingsLoaded = true

    }

    function applyChanges() {

        if(langcombo.currentIndex === -1 || langcombo.currentIndex >= availableLanguages.length)
            PQCSettings.interfaceLanguage = "en"
        else
            PQCSettings.interfaceLanguage = availableLanguages[langcombo.currentIndex]
        origIndex = langcombo.currentIndex

        PQCScriptsConfig.updateTranslation(PQCSettings.interfaceLanguage)

        PQCConstants.settingsManagerSettingChanged = false

    }

}
