import QtQuick
import QtQuick.Controls

import PQCScriptsConfig
import PQCScriptsClipboard

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfaceLanguage

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    property var languages: {
        "en" : "English",
        "ar" : "عربي ,عربى",
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
        "pl" : "Polski",
        "pt" : "Português (Portugal)",
        "pt_BR" : "Português (Brasil)",
        "ru" : "русский язык",
        "sk" : "Slovenčina",
        "tr" : "Türkçe",
        "uk" : "Українська",
        "zh" : "Chinese",
        "zh_TW" : "Chinese (traditional)"
    }

    property int origIndex

    property var langkeys: Object.keys(languages)

    function getLanguageName(code) {

        if(langkeys.indexOf(code) != -1) {

            return languages[code]

        } else {

            var c = code.split("_")[0]

            if(langkeys.indexOf(c) != -1)
                return languages[c]

        }

        return code

    }

    ScrollBar.vertical: PQVerticalScrollBar {}

    property var availableLanguages: PQCScriptsConfig.getAvailableTranslations()

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: A settings title
            text: qsTranslate("settingsmanager_interface", "Language")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_interface",  "PhotoQt has been translated into a number of different languages. Not all of the languages have a complete translation yet, and new translators are always needed. If you are willing and able to help, that would be greatly appreciated.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 10
        }

        property int currentIndex: -1
        onCurrentIndexChanged:
            setting_top.settingChanged = (setting_top.origIndex!==contcol.currentIndex)

        Repeater {

            model: availableLanguages.length

            Rectangle {

                x: (parent.width-width)/2

                width: Math.min(setting_top.width, 600)
                height: 35

                radius: 5
                color: (hovered || contcol.currentIndex===index) ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
                Behavior on color { ColorAnimation { duration: 200 } }

                property bool hovered: false

                PQText {
                    id: langtxt
                    anchors.centerIn: parent
                    text: getLanguageName(availableLanguages[index])
                    color: (hovered || contcol.currentIndex===index) ? PQCLook.textColorActive : PQCLook.textColor
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: contcol.currentIndex = index
                    text: langtxt.text + " (" + availableLanguages[index] + ")"
                }

            }

        }

        Item {
            width: 1
            height: 10
        }

        PQTextL {
            width: setting_top.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.weight: PQCLook.fontWeightBold
            horizontalAlignment: Text.AlignHCenter
            text: qsTranslate("settingsmanager_interface", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!")
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQText {
            width: setting_top.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager_interface", "If you want to help with the translations, either by translating or by reviewing existing translations, head over to the translation page on Crowdin:")
        }

        Item {
            width: 1
            height: 10
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQTextXL {
                id: urltxt
                text: "https://translate.photoqt.org"
                font.weight: PQCLook.fontWeightBold
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("settingsmanager_interface", "Open in browser")
                    onClicked:
                        Qt.openUrlExternally("https://translate.photoqt.org")
                }
            }
            PQButtonIcon {
                width: urltxt.height
                height: width
                source: "/white/copy.svg"
                tooltip: qsTranslate("settingsmanager_interface", "Copy to clipboard")
                onClicked:
                    PQCScriptsClipboard.copyTextToClipboard("https://translate.photoqt.org")
            }
        }

    }

    Component.onCompleted:
        load()

    function applyChanges() {
        if(contcol.currentIndex == -1 || contcol.currentIndex >= availableLanguages.length)
            PQCSettings.interfaceLanguage = "en"
        else
            PQCSettings.interfaceLanguage = availableLanguages[contcol.currentIndex]
        origIndex = contcol.currentIndex
        setting_top.settingChanged = false
        PQCScriptsConfig.updateTranslation()
    }

    function revertChanges() {
        load()
    }

    function load() {

        var code = PQCSettings.interfaceLanguage

        var setindex = availableLanguages.indexOf("en")

        if(availableLanguages.indexOf(code) !== -1)
            setindex = availableLanguages.indexOf(code)

        var c = code + "_" + code.toUpperCase()
        if(availableLanguages.indexOf(c) !== -1)
            setindex = availableLanguages.indexOf(c)

        origIndex = setindex
        contcol.currentIndex = setindex

    }

}
