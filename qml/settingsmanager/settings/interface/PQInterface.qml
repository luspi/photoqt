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

    ScrollBar.vertical: PQVerticalScrollBar {}

    property list<string> availableLanguages: PQCScriptsConfig.getAvailableTranslations() // qmllint disable unqualified

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

                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified

                    onCurrentIndexChanged: setting_top.checkDefault()

                },

                PQText {
                    width: set_lang.rightcol
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: PQCSettings.generalCompactSettings // qmllint disable unqualified
                    // font.weight: PQCLook.fontWeightBold
                    text: qsTranslate("settingsmanager", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!")
                }

            ]
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_windowmode

            helptext: qsTranslate("settingsmanager", "There are two main states that the application window can be in. It can either be in fullscreen mode or in window mode. In fullscreen mode, PhotoQt will act more like a floating layer that allows you to quickly look at images. In window mode, PhotoQt can be used in combination with other applications. When in window mode, it can also be set to always be above any other windows, and to remember the window geometry in between sessions.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Fullscreen or window mode")

            content: [

                Flow {
                    width: set_windowmode.rightcol
                    PQRadioButton {
                        id: fsmode
                        text: qsTranslate("settingsmanager", "fullscreen mode")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                    PQRadioButton {
                        id: wmmode
                        text: qsTranslate("settingsmanager", "window mode")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                },

                Column {

                    spacing: 15
                    width: set_windowmode.rightcol
                    clip: true

                    enabled: wmmode.checked
                    height: enabled ? (keeptop.height+rememgeo.height+wmdeco_show.height+2*15) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }


                    PQCheckBox {
                        id: keeptop
                        enforceMaxWidth: set_windowmode.rightcol
                        text: qsTranslate("settingsmanager", "keep above other windows")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQCheckBox {
                        id: rememgeo
                        enforceMaxWidth: set_windowmode.rightcol
                        //: remember the geometry of PhotoQts window between sessions
                        text: qsTranslate("settingsmanager", "remember its geometry ")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQCheckBox {
                        id: wmdeco_show
                        enforceMaxWidth: set_windowmode.rightcol
                        text: qsTranslate("settingsmanager", "enable window decoration")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_winbut

            helptext: qsTranslate("settingsmanager",  "PhotoQt can show some integrated window buttons for basic window managements both when shown in fullscreen and when in window mode. In window mode with window decoration enabled it can either hide or show buttons from its integrated set that are duplicates of buttons in the window decoration. For help with navigating through a folder, small left/right arrows for navigation and a menu button can also be added next to the window buttons. There are also various visibility tweaks that can be adjusted.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Window buttons")

            content: [

                PQCheckBox {
                    id: integbut_show
                    enforceMaxWidth: set_winbut.rightcol
                    text: qsTranslate("settingsmanager", "show integrated window buttons")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Item {

                    width: parent.width

                    enabled: integbut_show.checked
                    height: enabled ? (winbutcol.height) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    clip: true

                    Column {

                        id: winbutcol

                        width: parent.width
                        spacing: set_winbut.contentSpacing

                        PQCheckBox {
                            id: integbut_dup
                            enforceMaxWidth: set_winbut.rightcol
                            text: qsTranslate("settingsmanager", "duplicate buttons from window decoration")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQCheckBox {
                            id: integbut_nav
                            enforceMaxWidth: set_winbut.rightcol
                            text: qsTranslate("settingsmanager", "add navigation buttons")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQSliderSpinBox {
                            id: butsize
                            width: set_winbut.rightcol
                            minval: 5
                            maxval: 50
                            title: qsTranslate("settingsmanager", "Size:")
                            suffix: " px"
                            onValueChanged:
                                setting_top.checkDefault()
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        PQRadioButton {
                            id: autohide_always
                            enforceMaxWidth: set_winbut.rightcol
                            //: visibility status of the window buttons
                            text: qsTranslate("settingsmanager", "keep always visible")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQRadioButton {
                            id: autohide_anymove
                            enforceMaxWidth: set_winbut.rightcol
                            //: visibility status of the window buttons
                            text: qsTranslate("settingsmanager", "only show with any cursor move")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQRadioButton {
                            id: autohide_topedge
                            enforceMaxWidth: set_winbut.rightcol
                            //: visibility status of the window buttons
                            text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQSliderSpinBox {
                            id: autohide_timeout
                            width: set_winbut.rightcol
                            minval: 0
                            maxval: 10
                            title: qsTranslate("settingsmanager", "hide again after timeout:")
                            suffix: " s"
                            enabled: !autohide_always.checked
                            animateHeight: true
                            onValueChanged:
                                setting_top.checkDefault()
                        }

                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            helptext: qsTranslate("settingsmanager",  "Here an accent color of PhotoQt can be selected, with the whole interface colored with shades of it.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Accent color")

            content: [

                PQComboBox {
                    id: accentcolor
                    property list<string> options: PQCLook.getColorNames() // qmllint disable unqualified
                    model: options
                    onCurrentIndexChanged:
                        setting_top.checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_notif

            helptext: qsTranslate("settingsmanager", "For certain actions a notification is shown. On Linux this notification can be shown as native notification. Alternatively it can also be shown integrated into the main interface.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Notification")

            content: [

                Column {

                    id: notif_grid

                    property string loc: "center"
                    property string default_loc: "center"

                    spacing: 20

                    Row {
                        spacing: 5

                        Column {
                            spacing: 5

                            PQText {
                                text: " "
                            }

                            PQText {
                                x: (parent.width-width)
                                height: 50
                                verticalAlignment: Text.AlignVCenter
                                //: Vertical position of the integrated notification popup. Please keep short!
                                text: qsTranslate("settingsmanager", "top")
                            }

                            PQText {
                                x: (parent.width-width)
                                height: 50
                                verticalAlignment: Text.AlignVCenter
                                //: Vertical position of the integrated notification popup. Please keep short!
                                text: qsTranslate("settingsmanager", "center")
                            }

                            PQText {
                                x: (parent.width-width)
                                height: 50
                                verticalAlignment: Text.AlignVCenter
                                //: Vertical position of the integrated notification popup. Please keep short!
                                text: qsTranslate("settingsmanager", "bottom")
                            }
                        }

                        Column {
                            spacing: 5
                            Row {
                                spacing: 5
                                PQText {
                                    width: 100
                                    horizontalAlignment: Text.AlignHCenter
                                    //: Horizontal position of the integrated notification popup. Please keep short!
                                    text: qsTranslate("settingsmanager", "left")
                                }
                                PQText {
                                    width: 100
                                    horizontalAlignment: Text.AlignHCenter
                                    //: Horizontal position of the integrated notification popup. Please keep short!
                                    text: qsTranslate("settingsmanager", "center")
                                }
                                PQText {
                                    width: 100
                                    horizontalAlignment: Text.AlignHCenter
                                    //: Horizontal position of the integrated notification popup. Please keep short!
                                    text: qsTranslate("settingsmanager", "right")
                                }
                            }

                            Row {
                                spacing: 5
                                Rectangle {
                                    color: notif_grid.loc==="topleft" ? PQCLook.baseColorActive                     // qmllint disable unqualified
                                                                     : mouse_tl.containsMouse ? PQCLook.baseColorHighlight
                                                                                              : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_tl
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "topleft"
                                        }
                                    }
                                }
                                Rectangle {
                                    color: notif_grid.loc==="top" ? PQCLook.baseColorActive                     // qmllint disable unqualified
                                                                 : mouse_t.containsMouse ? PQCLook.baseColorHighlight
                                                                                         : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_t
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "top"
                                        }
                                    }
                                }
                                Rectangle {
                                    color: notif_grid.loc==="topright" ? PQCLook.baseColorActive                    // qmllint disable unqualified
                                                                      : mouse_tr.containsMouse ? PQCLook.baseColorHighlight
                                                                                               : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_tr
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "topright"
                                        }
                                    }
                                }
                            }
                            Row {
                                spacing: 5
                                Rectangle {
                                    color: notif_grid.loc==="centerleft" ? PQCLook.baseColorActive                      // qmllint disable unqualified
                                                                        : mouse_ml.containsMouse ? PQCLook.baseColorHighlight
                                                                                                 : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_ml
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "centerleft"
                                        }
                                    }
                                }
                                Rectangle {
                                    color: notif_grid.loc==="center" ? PQCLook.baseColorActive                      // qmllint disable unqualified
                                                                    : mouse_m.containsMouse ? PQCLook.baseColorHighlight
                                                                                            : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_m
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "center"
                                        }
                                    }
                                }
                                Rectangle {
                                    color: notif_grid.loc==="centerright" ? PQCLook.baseColorActive                     // qmllint disable unqualified
                                                                         : mouse_mr.containsMouse ? PQCLook.baseColorHighlight
                                                                                                  : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_mr
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "centerright"
                                        }
                                    }
                                }
                            }
                            Row {
                                spacing: 5
                                Rectangle {
                                    color: notif_grid.loc==="bottomleft" ? PQCLook.baseColorActive                      // qmllint disable unqualified
                                                                        : mouse_bl.containsMouse ? PQCLook.baseColorHighlight
                                                                                                 : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_bl
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "bottomleft"
                                        }
                                    }
                                }
                                Rectangle {
                                    color: notif_grid.loc==="bottom" ? PQCLook.baseColorActive                      // qmllint disable unqualified
                                                                    : mouse_b.containsMouse ? PQCLook.baseColorHighlight
                                                                                            : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_b
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "bottom"
                                        }
                                    }
                                }
                                Rectangle {
                                    color: notif_grid.loc==="bottomright" ? PQCLook.baseColorActive                         // qmllint disable unqualified
                                                                         : mouse_br.containsMouse ? PQCLook.baseColorHighlight
                                                                                                  : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight // qmllint disable unqualified
                                    PQMouseArea {
                                        id: mouse_br
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        text: qsTranslate("settingsmanager", "Show notification at this position")
                                        onClicked: {
                                            notif_grid.loc = "bottomright"
                                        }
                                    }
                                }
                            }
                        }
                    }
                },

                PQSliderSpinBox {
                    id: notif_dist
                    width: set_notif.rightcol
                    minval: 0
                    maxval: 200
                    title: qsTranslate("settingsmanager", "Distance from edge:")
                    suffix: " px"
                    onValueChanged:
                        setting_top.checkDefault()
                },

                PQCheckBox {
                    id: notif_external
                    visible: !PQCScriptsConfig.amIOnWindows() // qmllint disable unqualified
                    text: qsTranslate("settingsmanager", "try to show native notification")
                },

                Item {
                    width: 10
                    height: 50
                }

            ]

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
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

        if(notif_grid.default_loc !== notif_grid.loc || notif_external.hasChanged() || notif_dist.hasChanged()) {
            settingChanged = true;
            return
        }

        settingChanged = accentcolor.hasChanged()

    }

    function load() {

        var m = []
        for(var i in availableLanguages) {
            m.push(getLanguageName(availableLanguages[i]))
        }
        langcombo.model = m

        var code = PQCSettings.interfaceLanguage // qmllint disable unqualified

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

        var index = accentcolor.options.indexOf(PQCSettings.interfaceAccentColor)
        if(index === -1) index = 0
        accentcolor.loadAndSetDefault(index)

        notif_grid.loc = PQCSettings.interfaceNotificationLocation
        notif_grid.default_loc = PQCSettings.interfaceNotificationLocation
        notif_external.loadAndSetDefault(PQCSettings.interfaceNotificationTryNative)
        notif_dist.loadAndSetDefault(PQCSettings.interfaceNotificationDistanceFromEdge)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {
        if(langcombo.currentIndex == -1 || langcombo.currentIndex >= availableLanguages.length)
            PQCSettings.interfaceLanguage = "en" // qmllint disable unqualified
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
        PQCSettings.interfaceWindowButtonsAutoHideTimeout = autohide_timeout.value*1000

        PQCSettings.interfaceAccentColor = accentcolor.options[accentcolor.currentIndex]

        PQCSettings.interfaceNotificationLocation = notif_grid.loc
        PQCSettings.interfaceNotificationTryNative = notif_external.checked
        PQCSettings.interfaceNotificationDistanceFromEdge = notif_dist.value

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

        accentcolor.saveDefault()

        notif_grid.default_loc = notif_grid.loc
        notif_external.saveDefault()
        notif_dist.saveDefault()

        setting_top.settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
