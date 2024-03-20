/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCScriptsConfig
import PQCScriptsClipboard
import PQCNotify

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
    property bool settingsLoaded: false

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

        x: 5

        PQSetting {

            id: set_lang

            helptext: qsTranslate("settingsmanager",  "PhotoQt has been translated into a number of different languages. Not all of the languages have a complete translation yet, and new translators are always needed. If you are willing and able to help, that would be greatly appreciated.") + "<br><br>" +
                      "<b>" + qsTranslate("settingsmanager", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!") + "</b><br><br>" +
                      qsTranslate("settingsmanager", "If you want to help with the translations, either by translating or by reviewing existing translations, head over to the translation page on Crowdin:") + "<b>https://translate.photoqt.org</b>"

            //: A settings title
            title: qsTranslate("settingsmanager", "Language")

            content: [

                PQComboBox {

                    id: langcombo

                    model: []

                    font.weight: PQCLook.fontWeightBold

                    onCurrentIndexChanged: checkDefault()

                },

                PQText {
                    width: set_lang.rightcol.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: !PQCSettings.generalHelpTextSettings
                    // font.weight: PQCLook.fontWeightBold
                    text: qsTranslate("settingsmanager", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!")
                }

            ]
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            helptext: qsTranslate("settingsmanager", "There are two main states that the application window can be in. It can either be in fullscreen mode or in window mode. In fullscreen mode, PhotoQt will act more like a floating layer that allows you to quickly look at images. In window mode, PhotoQt can be used in combination with other applications. When in window mode, it can also be set to always be above any other windows, and to remember the window geometry in between sessions.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Fullscreen or window mode")

            content: [

                Row {
                    PQRadioButton {
                        id: fsmode
                        text: qsTranslate("settingsmanager", "fullscreen mode")
                        onCheckedChanged: checkDefault()
                    }

                    PQRadioButton {
                        id: wmmode
                        text: qsTranslate("settingsmanager", "window mode")
                        onCheckedChanged: checkDefault()
                    }
                },

                Column {

                    spacing: 15
                    width: parent.width
                    clip: true

                    enabled: wmmode.checked
                    height: enabled ? (keeprow.height+wmdeco_show.height+15) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Row {

                        id: keeprow

                        PQCheckBox {
                            id: keeptop
                            text: qsTranslate("settingsmanager", "keep above other windows")
                            onCheckedChanged: checkDefault()
                        }
                        PQCheckBox {
                            id: rememgeo
                            //: remember the geometry of PhotoQts window between sessions
                            text: qsTranslate("settingsmanager", "remember its geometry")
                            onCheckedChanged: checkDefault()
                        }
                    }

                    PQCheckBox {
                        id: wmdeco_show
                        text: qsTranslate("settingsmanager", "enable window decoration")
                        onCheckedChanged: checkDefault()
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            helptext: qsTranslate("settingsmanager",  "PhotoQt can show some integrated window buttons for basic window managements both when shown in fullscreen and when in window mode. In window mode with window decoration enabled it can either hide or show buttons from its integrated set that are duplicates of buttons in the window decoration. For help with navigating through a folder, small left/right arrows for navigation and a menu button can also be added next to the window buttons.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Window buttons")

            content: [

                PQCheckBox {
                    id: integbut_show
                    text: qsTranslate("settingsmanager", "show integrated window buttons")
                    onCheckedChanged: checkDefault()
                },

                Column {

                    width: parent.width
                    spacing: parent.spacing
                    clip: true

                    enabled: integbut_show.checked
                    height: enabled ? (integbut_dup.height+integbut_nav.height+sizerow.height+2*spacing) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQCheckBox {
                        id: integbut_dup
                        text: qsTranslate("settingsmanager", "duplicate buttons from window decoration")
                        onCheckedChanged: checkDefault()
                    }

                    PQCheckBox {
                        id: integbut_nav
                        text: qsTranslate("settingsmanager", "add navigation buttons")
                        onCheckedChanged: checkDefault()
                    }

                    Row {

                        id: sizerow

                        spacing: 10

                        PQText {
                            y: (parent.height-height)/2
                            //: This is the size of the integrated window buttons.
                            text: qsTranslate("settingsmanager", "Size:")
                        }

                        Rectangle {

                            width: butsize.width
                            height: butsize.height
                            color: PQCLook.baseColorHighlight

                            PQSpinBox {
                                id: butsize
                                from: 5
                                to: 100
                                width: 120
                                onValueChanged: checkDefault()
                                visible: !butsize_val.visible && enabled
                                Component.onDestruction:
                                    PQCNotify.spinBoxPassKeyEvents = false
                            }

                            PQText {
                                id: butsize_val
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: butsize.value + " px"
                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    //: Tooltip, used as in: Click to edit this value
                                    text: qsTranslate("settingsmanager", "Click to edit")
                                    onClicked: {
                                        PQCNotify.spinBoxPassKeyEvents = true
                                        butsize_val.visible = false
                                    }
                                }
                            }

                        }

                        PQButton {
                            id: acceptbut
                            //: Written on button, the value is whatever was entered in a spin box
                            text: qsTranslate("settingsmanager", "Accept value")
                            font.pointSize: PQCLook.fontSize
                            font.weight: PQCLook.fontWeightNormal
                            height: 35
                            visible: !butsize_val.visible && enabled
                            onClicked: {
                                PQCNotify.spinBoxPassKeyEvents = false
                                butsize_val.visible = true
                            }
                        }

                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            helptext: qsTranslate("settingsmanager",  "The window buttons can either be shown at all times, or they can be hidden automatically based on different criteria. They can either be hidden unless the mouse cursor is near the top edge of the screen or until the mouse cursor is moved anywhere. After a specified timeout they will then hide again.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Hide automatically")

            content: [

                PQRadioButton {
                    id: autohide_always
                    //: visibility status of the window buttons
                    text: qsTranslate("settingsmanager", "keep always visible")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: autohide_anymove
                    //: visibility status of the window buttons
                    text: qsTranslate("settingsmanager", "only show with any cursor move")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: autohide_topedge
                    //: visibility status of the window buttons
                    text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                    onCheckedChanged: checkDefault()
                },

                Row {

                    spacing: 10

                    clip: true
                    enabled: !autohide_always.checked
                    height: enabled ? autohide_timeout.height : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQText {
                        y: (parent.height-height)/2
                        text: qsTranslate("settingsmanager", "hide again after timeout:")
                    }

                    Rectangle {

                        width: autohide_timeout.width
                        height: autohide_timeout.height
                        color: PQCLook.baseColorHighlight

                        PQSpinBox {
                            id: autohide_timeout
                            from: 0
                            to: 5
                            width: 120
                            onValueChanged: checkDefault()
                            visible: !autohide_timeouttxt.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: autohide_timeouttxt
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: autohide_timeout.value + " px"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    autohide_timeouttxt.visible = false
                                }
                            }
                        }

                    }

                    PQButton {
                        //: Written on button, the value is whatever was entered in a spin box
                        text: qsTranslate("settingsmanager", "Accept value")
                        font.pointSize: PQCLook.fontSize
                        font.weight: PQCLook.fontWeightNormal
                        height: 35
                        visible: !autohide_timeouttxt.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            autohide_timeouttxt.visible = true
                        }
                    }

                }

            ]

        }

    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(settingsmanager_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(!butsize_val.visible && (param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)) {

                        butsize_val.visible = true
                        PQCNotify.spinBoxPassKeyEvents = false

                    }

                }

            }

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        if(setting_top.origIndex !== langcombo.currentIndex) {
            setting_top.settingChanged = true
            return
        }

        if(wmmode.hasChanged() || keeptop.hasChanged() || rememgeo.hasChanged() || wmdeco_show.hasChanged()) {
            settingChanged = true
            return
        }

        if(integbut_show.hasChanged() || integbut_dup.hasChanged() || integbut_nav.hasChanged() || butsize.hasChanged()) {
            settingChanged = true
            return
        }

        if(autohide_topedge.hasChanged() || autohide_anymove.hasChanged() || autohide_always.hasChanged() || autohide_timeout.hasChanged()) {
            settingChanged = true
            return
        }

    }

    function load() {

        var m = []
        for(var i in availableLanguages) {
            m.push(getLanguageName(availableLanguages[i]))
        }
        langcombo.model = m

        var code = PQCSettings.interfaceLanguage

        var setindex = availableLanguages.indexOf("en")

        if(availableLanguages.indexOf(code) !== -1)
            setindex = availableLanguages.indexOf(code)

        var c = code + "_" + code.toUpperCase()
        if(availableLanguages.indexOf(c) !== -1)
            setindex = availableLanguages.indexOf(c)

        origIndex = setindex
        langcombo.currentIndex = setindex

        /******/

        fsmode.loadAndSetDefault(!PQCSettings.interfaceWindowMode)
        wmmode.loadAndSetDefault(!fsmode.checked)

        keeptop.loadAndSetDefault(PQCSettings.interfaceKeepWindowOnTop)
        rememgeo.loadAndSetDefault(PQCSettings.interfaceSaveWindowGeometry)

        wmdeco_show.loadAndSetDefault(PQCSettings.interfaceWindowDecoration)

        integbut_show.loadAndSetDefault(PQCSettings.interfaceWindowButtonsShow)
        integbut_dup.loadAndSetDefault(PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons)
        integbut_nav.loadAndSetDefault(PQCSettings.interfaceNavigationTopRight)
        butsize.loadAndSetDefault(PQCSettings.interfaceWindowButtonsSize)

        autohide_always.loadAndSetDefault(!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_anymove.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_topedge.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_timeout.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTimeout/1000)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {
        if(langcombo.currentIndex == -1 || langcombo.currentIndex >= availableLanguages.length)
            PQCSettings.interfaceLanguage = "en"
        else
            PQCSettings.interfaceLanguage = availableLanguages[langcombo.currentIndex]
        origIndex = langcombo.currentIndex
        PQCScriptsConfig.updateTranslation()


        PQCSettings.interfaceWindowMode = wmmode.checked

        PQCSettings.interfaceKeepWindowOnTop = keeptop.checked
        PQCSettings.interfaceSaveWindowGeometry = rememgeo.checked

        PQCSettings.interfaceWindowDecoration = wmdeco_show.checked

        PQCSettings.interfaceWindowButtonsShow = integbut_show.checked
        PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons = integbut_dup.checked
        PQCSettings.interfaceNavigationTopRight = integbut_nav.checked
        PQCSettings.interfaceWindowButtonsSize = butsize.value

        PQCSettings.interfaceWindowButtonsAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
        PQCSettings.interfaceWindowButtonsAutoHideTopEdge = autohide_topedge.checked
        PQCSettings.interfaceWindowButtonsAutoHideTimeout = autohide_timeout.value.toFixed(1)*1000

        fsmode.saveDefault()
        wmmode.saveDefault()

        keeptop.saveDefault()
        rememgeo.saveDefault()

        wmdeco_show.saveDefault()

        integbut_show.saveDefault()
        integbut_dup.saveDefault()
        integbut_nav.saveDefault()
        butsize.saveDefault()

        autohide_always.saveDefault()
        autohide_anymove.saveDefault()
        autohide_topedge.saveDefault()
        autohide_timeout.saveDefault()

        setting_top.settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
