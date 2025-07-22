/**************************************************************************
 **                                                                      **
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
import Qt.labs.platform
import PhotoQt

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - interfaceLanguage

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: testbut.contextmenu.visible || langcombo.popup.visible || accentcolor.popup.visible ||
                               butsize.contextMenuOpen || butsize.editMode || autohide_timeout.contextMenuOpen ||
                               autohide_timeout.editMode || notif_dist.contextMenuOpen || notif_dist.editMode ||
                               combo_add.popup.visible || set_winbut.itemmenuopened>0

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

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

                PQComboBox {

                    id: langcombo

                    model: []

                    font.weight: PQCLook.fontWeightBold 

                    onCurrentIndexChanged: setting_top.checkDefault()

                },

                PQText {
                    width: set_lang.rightcol
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: PQCSettings.generalCompactSettings 
                    // font.weight: PQCLook.fontWeightBold
                    text: qsTranslate("settingsmanager", "Thank you to all who volunteered their time to help translate PhotoQt into other languages!")
                }

            ]

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
            }

            function handleEscape() {
                langcombo.popup.close()
            }

            function hasChanged() {
                return (origIndex !== langcombo.currentIndex)
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
                else {
                    var c = code + "_" + code.toUpperCase()
                    if(availableLanguages.indexOf(c) !== -1)
                        setindex = availableLanguages.indexOf(c)
                }

                origIndex = setindex
                langcombo.currentIndex = setindex

            }

            function applyChanges() {

                if(langcombo.currentIndex === -1 || langcombo.currentIndex >= availableLanguages.length)
                    PQCSettings.interfaceLanguage = "en" 
                else
                    PQCSettings.interfaceLanguage = availableLanguages[langcombo.currentIndex]
                origIndex = langcombo.currentIndex

                // DO NOT REFRESH THE INTERFACE WITH THE NEW TRANSLATIONS HERE
                // updating the interface will reset the currentIndex of that popup
                // thus, we refresh the update from that group!

            }

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

            onResetToDefaults: {

                var wmmode_val = PQCSettings.getDefaultForInterfaceWindowMode()
                var keeptop_val = PQCSettings.getDefaultForInterfaceKeepWindowOnTop()
                var rememgeo_val = PQCSettings.getDefaultForInterfaceSaveWindowGeometry()
                var wmdeco_val = PQCSettings.getDefaultForInterfaceWindowDecoration()

                fsmode.checked = (wmmode_val===0)
                wmmode.checked = (wmmode_val===1)

                keeptop.checked = (keeptop_val===1)
                rememgeo.checked = (rememgeo_val===1)
                wmdeco_show.checked = (wmdeco_val===1)

            }

            function handleEscape() {
            }

            function hasChanged() {
                return (wmmode.hasChanged() || keeptop.hasChanged() || rememgeo.hasChanged() || wmdeco_show.hasChanged())
            }

            function load() {

                fsmode.loadAndSetDefault(!PQCSettings.interfaceWindowMode)
                wmmode.loadAndSetDefault(!fsmode.checked)

                keeptop.loadAndSetDefault(PQCSettings.interfaceKeepWindowOnTop)
                rememgeo.loadAndSetDefault(PQCSettings.interfaceSaveWindowGeometry)

                wmdeco_show.loadAndSetDefault(PQCSettings.interfaceWindowDecoration)

            }

            function applyChanges() {

                PQCSettings.interfaceWindowMode = wmmode.checked

                PQCSettings.interfaceKeepWindowOnTop = keeptop.checked
                PQCSettings.interfaceSaveWindowGeometry = rememgeo.checked

                PQCSettings.interfaceWindowDecoration = wmdeco_show.checked

                fsmode.saveDefault()
                wmmode.saveDefault()

                keeptop.saveDefault()
                rememgeo.saveDefault()

                wmdeco_show.saveDefault()

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_winbut

            property list<string> curEntries: []
            property list<string> defaultEntries: []

            helptext: qsTranslate("settingsmanager", "PhotoQt can show various integrated window buttons in the top right corner of the window. In addition to all standard window buttons several custom buttons are available, for instance navigation buttons for the current folder. Here the buttons can be arranged in any order. A context menu for each entry offers options to only show a button in fullscreen or when windowed, or to keep it above any other window.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Window buttons")

            property int itemmenuopened: 0
            signal closeItemMenu()

            content: [

                PQCheckBox {
                    id: integbut_show
                    enforceMaxWidth: set_winbut.rightcol
                    text: qsTranslate("settingsmanager", "enable integrated window buttons")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Rectangle {
                    enabled: integbut_show.checked
                    width: parent.width-5
                    radius: 5
                    clip: true

                    height: enabled ? (60+(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    color: PQCLook.baseColorHighlight 
                    ListView {

                        id: avail

                        x: 5
                        y: 5

                        width: parent.width-10
                        height: parent.height-10

                        clip: true
                        orientation: ListView.Horizontal
                        spacing: 5

                        ScrollBar.horizontal: PQHorizontalScrollBar { id: scrollbar }

                        property int dragItemIndex: -1

                        property list<int> widths: []

                        property var disp: {
                            "left" : "leftarrow",
                            "right" : "rightarrow",
                            "menu" : "menu",
                            "ontop" : "keepforeground",
                            "fullscreen" : "fullscreen_on",
                            "minimize" : (PQCScriptsConfig.amIOnWindows() ? "windows-minimize" : "minimize"),
                            "maximize" : (PQCScriptsConfig.amIOnWindows() ? "windows-maximize" : "maximize"),
                            "close" : "close"
                        }

                        model: ListModel {
                            id: model
                        }

                        delegate: Item {

                            id: deleg

                            width: Math.max.apply(Math, avail.widths)
                            height: avail.height-(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)

                            required property int index
                            required property string component
                            required property bool fullscreenonly
                            required property bool windowedonly
                            required property bool alwaysontop

                            property bool hasBeenSetup: false
                            Timer {
                                interval: 500
                                running: true
                                onTriggered:
                                    deleg.hasBeenSetup = true
                            }

                            onFullscreenonlyChanged: {
                                if(!hasBeenSetup) return
                                var entry = set_winbut.curEntries[index]
                                var parts = entry.split("_")[1].split("|")
                                var newfs = (fullscreenonly ? "1" : "0")
                                if(newfs === parts[0]) return
                                set_winbut.curEntries[index] = entry.split("_")[0] + "_" + newfs + "|" + parts[1] + "|" + parts[2]
                                set_winbut.populateModel()
                                setting_top.checkDefault()
                            }
                            onWindowedonlyChanged: {
                                if(!hasBeenSetup) return
                                var entry = set_winbut.curEntries[index]
                                var parts = entry.split("_")[1].split("|")
                                var newwm = (windowedonly ? "1" : "0")
                                if(newwm === parts[1]) return
                                set_winbut.curEntries[index] = entry.split("_")[0] + "_" + parts[0] + "|" + newwm + "|" + parts[2]
                                set_winbut.populateModel()
                                setting_top.checkDefault()
                            }
                            onAlwaysontopChanged: {
                                if(!hasBeenSetup) return
                                var entry = set_winbut.curEntries[index]
                                var parts = entry.split("_")[1].split("|")
                                var newot = (alwaysontop ? "1" : "0")
                                if(newot === parts[2]) return
                                set_winbut.curEntries[index] = entry.split("_")[0] + "_" + parts[0] + "|" + parts[1] + "|" + newot
                                set_winbut.populateModel()
                                setting_top.checkDefault()
                            }

                            Rectangle {
                                id: dragRect
                                width: deleg.width
                                height: deleg.height
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: PQCLook.baseColorActive 
                                radius: 5
                                Image {
                                    id: txt
                                    x: (deleg.width-width)/2
                                    y: deleg.height*0.1
                                    width: deleg.height*0.75
                                    height: deleg.height*0.75
                                    source: "image://svg/:/" + PQCLook.iconShade + "/" + avail.disp[deleg.component] + ".svg"
                                    sourceSize: Qt.size(width, height)
                                    onWidthChanged: {
                                        avail.widths.push(width+20)
                                        avail.widthsChanged()
                                    }
                                }
                                Image {
                                    x: parent.width-width-3
                                    y: parent.height-height-3
                                    visible: deleg.fullscreenonly||deleg.windowedonly
                                    width: deleg.height*0.2
                                    height: deleg.height*0.2
                                    source: "image://svg/:/" + PQCLook.iconShade + (deleg.fullscreenonly ? "/fullscreen_on.svg" : "/computer.svg")
                                    sourceSize: Qt.size(width, height)
                                }
                                Image {
                                    x: 3
                                    y: parent.height-height-3
                                    width: deleg.height*0.2
                                    height: deleg.height*0.2
                                    visible: deleg.alwaysontop
                                    source: "image://svg/:/" + PQCLook.iconShade + "/thumbnail.svg"
                                    sourceSize: Qt.size(width, height)
                                }
                                PQMenu {
                                    id: itemmenu
                                    PQMenuItem {
                                        id: chk_fs
                                        checkable: true
                                        //: context menu entry, please keep short!
                                        text: qsTranslate("settingsmanager", "only in fullscreen")
                                        onCheckedChanged: {
                                            if(checked)
                                                chk_wm.checked = false
                                            if(deleg.fullscreenonly !== checked)
                                                deleg.fullscreenonly = checked
                                            setting_top.checkDefault()
                                        }
                                    }
                                    PQMenuItem {
                                        id: chk_wm
                                        checkable: true
                                        //: context menu entry, please keep short! Windowed here is used as the opposite to fullscreen.
                                        text: qsTranslate("settingsmanager", "only when windowed")
                                        onCheckedChanged: {
                                            if(checked)
                                                chk_fs.checked = false
                                            if(deleg.windowedonly !== checked)
                                                deleg.windowedonly = checked
                                            setting_top.checkDefault()
                                        }
                                    }

                                    PQMenuSeparator {}

                                    PQMenuItem {
                                        id: chk_ot
                                        checkable: true
                                        //: context menu entry, please keep short!
                                        text: qsTranslate("settingsmanager", "above everything else")
                                        onCheckedChanged: {
                                            if(deleg.alwaysontop !== checked)
                                                deleg.alwaysontop = checked
                                            setting_top.checkDefault()
                                        }
                                    }

                                    onAboutToHide: {
                                        set_winbut.itemmenuopened -= 1
                                        recordAsClosed.restart()
                                    }
                                    onAboutToShow: {
                                        set_winbut.itemmenuopened += 1
                                        chk_fs.checked = deleg.fullscreenonly
                                        chk_wm.checked = deleg.windowedonly
                                        chk_ot.checked = deleg.alwaysontop
                                        PQCConstants.addToWhichContextMenusOpen("settings_windowbuttons"+index) 
                                    }

                                    Connections {
                                        target: set_winbut
                                        function onCloseItemMenu() {
                                            itemmenu.close()
                                        }
                                    }

                                    Timer {
                                        id: recordAsClosed
                                        interval: 200
                                        onTriggered: {
                                            if(!itemmenu.opened)
                                                PQCConstants.removeFromWhichContextMenusOpen("settings_windowbuttons"+index) 
                                        }
                                    }

                                }

                                PQMouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                                    text: combo_add.statusdata_vals[combo_add.statusdata_keys.indexOf(deleg.component)]
                                    drag.target: parent
                                    drag.axis: Drag.XAxis
                                    drag.onActiveChanged: {
                                        if (mouseArea.drag.active) {
                                            avail.dragItemIndex = deleg.index;
                                        }
                                        dragRect.Drag.drop();
                                        if(!mouseArea.drag.active) {
                                            set_winbut.populateModel()
                                        }
                                    }
                                    cursorShape: Qt.OpenHandCursor
                                    onPressed: (mouse) => {
                                        if(mouse.button === Qt.LeftButton)
                                            cursorShape = Qt.ClosedHandCursor
                                    }
                                    onReleased: (mouse) => {
                                        if(mouse.button === Qt.LeftButton)
                                            cursorShape = Qt.OpenHandCursor
                                    }
                                    onClicked: (mouse) => {
                                        if(mouse.button === Qt.RightButton) {
                                            itemmenu.popup(0, deleg.height)
                                        }
                                    }
                                }
                                states: [
                                    State {
                                        when: dragRect.Drag.active
                                        ParentChange {
                                            target: dragRect
                                            parent: setting_top
                                        }

                                        AnchorChanges {
                                            target: dragRect
                                            anchors.horizontalCenter: undefined
                                            anchors.verticalCenter: undefined
                                        }
                                    }
                                ]

                                Drag.active: mouseArea.drag.active
                                Drag.hotSpot.x: 0
                                Drag.hotSpot.y: 0

                                Image {

                                    x: parent.width-width
                                    y: 0
                                    width: 20
                                    height: 20

                                    source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" 
                                    sourceSize: Qt.size(width, height)

                                    opacity: closemouse.containsMouse ? 0.8 : 0.2
                                    Behavior on opacity { NumberAnimation { duration: 150 } }

                                    PQMouseArea {
                                        id: closemouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: {
                                            set_winbut.curEntries.splice(deleg.index, 1)
                                            set_winbut.populateModel()
                                            setting_top.checkDefault()
                                        }
                                    }

                                }

                            }

                        }
                    }

                    DropArea {
                        id: dropArea
                        anchors.fill: parent
                        onPositionChanged: (drag) => {
                            var newindex = avail.indexAt(drag.x, drag.y)
                            if(newindex !== -1 && newindex !== avail.dragItemIndex) {

                                // we move the entry around in the list for the populate call later
                                var element = set_winbut.curEntries[avail.dragItemIndex];
                                set_winbut.curEntries.splice(avail.dragItemIndex, 1);
                                set_winbut.curEntries.splice(newindex, 0, element);

                                avail.model.move(avail.dragItemIndex, newindex, 1)
                                avail.dragItemIndex = newindex
                                setting_top.checkDefault()
                            }
                        }
                    }
                },

                Item {

                    enabled: integbut_show.checked
                    clip: true
                    width: helpmsg.width
                    height: enabled ? helpmsg.height+5 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQText {
                        id: helpmsg
                        text: qsTranslate("settingsmanager", "(a right click on an entry shows more options)")
                    }

                },

                Row {
                    enabled: integbut_show.checked
                    spacing: 10

                    height: enabled ? combo_add.height : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQComboBox {
                        id: combo_add
                        y: (but_add.height-height)/2
                        property list<string> statusdata_keys: [
                            "left",
                            "right",
                            "menu",
                            "ontop",
                            "fullscreen",
                            "minimize",
                            "maximize",
                            "close"
                        ]
                        property list<string> statusdata_vals: [
                            //: Please keep short!
                            qsTranslate("settingsmanager", "previous image"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "next image"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "main menu"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "keep window on top"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "toggle fullscreen"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "minimize window"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "maximize window"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "close window")
                        ]
                        model: statusdata_vals
                    }
                    PQButton {
                        id: but_add
                        //: This is written on a button that is used to add a selected block to the status info section.
                        text: qsTranslate("settingsmanager", "add")
                        smallerVersion: true
                        onClicked: {
                            set_winbut.curEntries.push(combo_add.statusdata_keys[combo_add.currentIndex]+"_0|0|1")
                            set_winbut.populateModel()
                            setting_top.checkDefault()
                        }
                    }
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

                        PQCheckBox {
                            id: wb_followaccent
                            //: These buttons are the WINDOW BUTTONS specifically!
                            text: qsTranslate("settingsmanager", "Color scheme of buttons follows accent color")
                            onCheckedChanged:
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

            onResetToDefaults: {

                integbut_show.checked = PQCSettings.getDefaultForInterfaceWindowButtonsShow()
                butsize.setValue(PQCSettings.getDefaultForInterfaceWindowButtonsSize())
                set_winbut.curEntries = PQCSettings.getDefaultForInterfaceWindowButtonsItems()
                populateModel()

                wb_followaccent.checked = PQCSettings.getDefaultForInterfaceWindowButtonsFollowAccentColor()

                var valAutoHide = PQCSettings.getDefaultForInterfaceWindowButtonsAutoHide()
                var valAutoHideTop = PQCSettings.getDefaultForInterfaceWindowButtonsAutoHideTopEdge()
                var valAutoHideTimeout = PQCSettings.getDefaultForInterfaceWindowButtonsAutoHideTimeout()
                autohide_always.checked = (valAutoHide===0 && valAutoHideTop===0)
                autohide_anymove.checked = (valAutoHide===1 && valAutoHideTop===0)
                autohide_topedge.checked = (valAutoHideTop===1)
                autohide_timeout.setValue(valAutoHideTimeout/1000)

            }

            function handleEscape() {
                butsize.closeContextMenus()
                butsize.acceptValue()
                autohide_timeout.closeContextMenus()
                autohide_timeout.acceptValue()
                combo_add.popup.close()
                set_winbut.closeItemMenu()
                set_winbut.itemmenuopened = 0
            }

            function hasChanged() {
                return (integbut_show.hasChanged() || butsize.hasChanged() ||
                        !setting_top.areTwoListsEqual(set_winbut.curEntries, PQCSettings.interfaceWindowButtonsItems) ||
                        autohide_topedge.hasChanged() || autohide_anymove.hasChanged() || autohide_always.hasChanged() ||
                        autohide_timeout.hasChanged() || wb_followaccent.hasChanged())
            }

            function load() {

                integbut_show.loadAndSetDefault(PQCSettings.interfaceWindowButtonsShow)
                butsize.loadAndSetDefault(PQCSettings.interfaceWindowButtonsSize)
                set_winbut.curEntries = PQCSettings.interfaceWindowButtonsItems
                populateModel()

                wb_followaccent.loadAndSetDefault(PQCSettings.interfaceWindowButtonsFollowAccentColor)

                autohide_always.loadAndSetDefault(!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                autohide_anymove.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                autohide_topedge.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                autohide_timeout.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTimeout/1000)

            }

            function applyChanges() {

                PQCSettings.interfaceWindowButtonsShow = integbut_show.checked
                PQCSettings.interfaceWindowButtonsItems = set_winbut.curEntries
                PQCSettings.interfaceWindowButtonsSize = butsize.value

                PQCSettings.interfaceWindowButtonsFollowAccentColor = wb_followaccent.checked

                PQCSettings.interfaceWindowButtonsAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
                PQCSettings.interfaceWindowButtonsAutoHideTopEdge = autohide_topedge.checked
                PQCSettings.interfaceWindowButtonsAutoHideTimeout = autohide_timeout.value*1000

                integbut_show.saveDefault()
                butsize.saveDefault()

                wb_followaccent.saveDefault()

                autohide_always.saveDefault()
                autohide_anymove.saveDefault()
                autohide_topedge.saveDefault()
                autohide_timeout.saveDefault()

            }

            function populateModel() {
                model.clear()
                for(var j = 0; j < set_winbut.curEntries.length; ++j) {
                    var val = set_winbut.curEntries[j]
                    var comp = val.split("_")[0]
                    var parts = val.split("_")[1].split("|")
                    var fs = (parts[0]==="1")
                    var wm = (parts[1]==="1")
                    var ot = (parts[2]==="1")
                    model.append({"component": comp, "index": j, "fullscreenonly" : fs, "windowedonly" : wm, "alwaysontop" : ot})
                }
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_accent

            helptext: qsTranslate("settingsmanager",  "Here an accent color of PhotoQt can be selected, with the whole interface colored with shades of it. After selecting a new color it is recommended to first test the color using the provided button to make sure that the interface is readable with the new color.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Accent color")

            content: [

                PQComboBox {
                    id: accentcolor
                    property list<string> hexes: PQCLook.getColorHexes() 
                    property list<string> options: PQCLook.getColorNames().concat(qsTranslate("settingsmanager", "custom color")) 
                    model: options
                    onCurrentIndexChanged: {
                        setting_top.checkDefault()
                    }
                },

                Item {

                    width: accentcustom.width
                    height: accentcolor.currentIndex<accentcolor.options.length-1 ? 0 : accentcustom.height
                    Behavior on height { NumberAnimation { duration: 200 } }

                    clip: true

                    Rectangle {
                        id: accentcustom
                        width: 200
                        height: 50
                        clip: true
                        color: PQCSettings.interfaceAccentColor 
                        border.width: 1
                        border.color: PQCLook.inverseColor 
                        Rectangle {
                            x: (parent.width-width)/2
                            y: (parent.height-height)/2
                            width: accent_coltxt.width+20
                            height: accent_coltxt.height+10
                            radius: 5
                            color: PQCLook.transInverseColor 
                            PQText {
                                id: accent_coltxt
                                color: PQCLook.textInverseColor 
                                x: 10
                                y: 5
                                text: PQCScriptsOther.convertRgbToHex([255*accentcustom.color.r, 255*accentcustom.color.g, 255*accentcustom.color.b]) 
                            }
                        }

                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                coldiag.section = "accent"
                                coldiag.currentColor = accentcustom.color
                                coldiag.open()
                            }
                        }
                    }

                },

                PQButton {
                    id: testbut
                    property int secs: 3
                    text: qsTranslate("settingsmanager", "Test color for %1 seconds").arg(secs)
                    property string backupcolor: ""
                    smallerVersion: true
                    onClicked: {
                        backupcolor = PQCSettings.interfaceAccentColor 

                        if(accentcolor.currentIndex < accentcolor.hexes.length)
                            PQCSettings.interfaceAccentColor = accentcolor.hexes[accentcolor.currentIndex]
                        else
                            PQCSettings.interfaceAccentColor = accent_coltxt.text

                        testtimer.restart()
                        testbut.enabled = false
                    }

                    Component.onDestruction: {
                        if(!testbut.enabled && settingsmanager_top.opacity > 0) { 
                            PQCSettings.interfaceAccentColor = testbut.backupcolor
                        }
                    }

                    Timer {
                        id: testtimer
                        interval: 1000
                        onTriggered: {
                            testbut.secs -= 1
                            if(testbut.secs == 0) {
                                testtimer.stop()
                                testbut.secs = 3
                                testbut.enabled = true
                                PQCSettings.interfaceAccentColor = testbut.backupcolor 
                            } else {
                                testtimer.restart()
                            }
                        }
                    }

                },

                Flow {
                    width: set_accent.rightcol
                    PQRadioButton {
                        id: bgaccentusecheck
                        text: qsTranslate("settingsmanager", "use accent color for background")
                        checked: !PQCSettings.interfaceBackgroundCustomOverlay 
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: bgcustomusecheck
                        text: qsTranslate("settingsmanager", "use custom color for background")
                        checked: PQCSettings.interfaceBackgroundCustomOverlay 
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    Rectangle {
                        id: bgcustomuse
                        height: bgcustomusecheck.height
                        width: bgcustomusecheck.checked ? 200 : 0
                        Behavior on width { NumberAnimation { duration: 200 } }
                        opacity: bgcustomusecheck.checked ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        clip: true
                        color: PQCSettings.interfaceBackgroundCustomOverlayColor=="" ? PQCLook.baseColor : PQCSettings.interfaceBackgroundCustomOverlayColor 
                        onColorChanged: setting_top.checkDefault()
                        Rectangle {
                            x: (parent.width-width)/2
                            y: (parent.height-height)/2
                            width: bgcustomusetxt.width+20
                            height: bgcustomusetxt.height+10
                            radius: 5
                            color: "#88000000"
                            PQText {
                                id: bgcustomusetxt
                                x: 10
                                y: 5
                                text: PQCScriptsOther.convertRgbToHex([255*bgcustomuse.color.r, 255*bgcustomuse.color.g, 255*bgcustomuse.color.b]) 
                            }
                        }

                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("settingsmanager", "Click to change color")
                            onClicked: {
                                coldiag.section = "bgcustom"
                                coldiag.currentColor = bgcustomuse.color
                                coldiag.open()
                            }
                        }

                    }

                }

            ]

            onResetToDefaults: {

                var valCol = PQCSettings.getDefaultForInterfaceAccentColor()

                accentcustom.color = valCol
                var index = accentcolor.hexes.indexOf(valCol)
                if(index === -1) index = accentcolor.options.length-1
                accentcolor.currentIndex = index

                var valOver = PQCSettings.getDefaultForInterfaceBackgroundCustomOverlay()
                bgaccentusecheck.checked = (valOver === 0)
                bgcustomusecheck.checked = (valOver === 1)

            }

            function handleEscape() {
                testbut.contextmenu.close()
                accentcolor.popup.close()
            }

            function hasChanged() {
                return (accentcolor.hasChanged() || bgaccentusecheck.hasChanged() || bgcustomusecheck.hasChanged() ||
                        (bgcustomusecheck.checked && bgcustomuse.color !== PQCSettings.interfaceBackgroundCustomOverlayColor))
            }

            function load() {

                var index = accentcolor.hexes.indexOf(PQCSettings.interfaceAccentColor)
                accentcustom.color = PQCSettings.interfaceAccentColor
                if(index === -1) index = accentcolor.options.length-1
                accentcolor.loadAndSetDefault(index)

                bgaccentusecheck.loadAndSetDefault(!PQCSettings.interfaceBackgroundCustomOverlay)
                bgcustomusecheck.loadAndSetDefault(PQCSettings.interfaceBackgroundCustomOverlay)

            }

            function applyChanges() {

                if(accentcolor.currentIndex < accentcolor.hexes.length)
                    PQCSettings.interfaceAccentColor = accentcolor.hexes[accentcolor.currentIndex]
                else
                    PQCSettings.interfaceAccentColor = accent_coltxt.text

                PQCSettings.interfaceBackgroundCustomOverlay = bgcustomusecheck.checked
                if(bgcustomusecheck.checked)
                    PQCSettings.interfaceBackgroundCustomOverlayColor = PQCScriptsOther.convertRgbToHex([255*bgcustomuse.color.r, 255*bgcustomuse.color.g, 255*bgcustomuse.color.b])

                accentcolor.saveDefault()

                bgcustomusecheck.saveDefault()
                bgaccentusecheck.saveDefault()

                // this needs to happen after saving the above
                // and afterwards we need to reset the index
                // otherwise the currentIndex will be reset when updating the translations
                PQCScriptsConfig.updateTranslation()
                var index = accentcolor.hexes.indexOf(PQCSettings.interfaceAccentColor)
                if(index === -1) index = accentcolor.options.length-1
                accentcolor.loadAndSetDefault(index)

            }

        }

        ColorDialog {
            id: coldiag
            modality: Qt.ApplicationModal
            property string section: ""
            onAccepted: {
                if(section == "accent")
                    accentcustom.color = coldiag.currentColor
                else
                    bgcustomuse.color = coldiag.currentColor
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_fontweight

            helptext: qsTranslate("settingsmanager", "All text in PhotoQt is shown with one of two weights, either as regular text or in bold face. Here the actual weight used can be adjusted for the two types. The default weight for normal text is 400 and for bold text is 700.")

            //: A settings title
            title: qsTranslate("settingsmanager", "Font weight")

            property list<string> values: [
                        //: This refers to a type of font weight (thin is the lightest weight)
                        qsTranslate("settingsmanager", "thin"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "very light"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "light"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "normal"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "medium"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "medium bold"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "bold"),
                        //: This refers to a type of font weight
                        qsTranslate("settingsmanager", "extra bold"),
                        //: This refers to a type of font weight (black is the darkest, most bold weight)
                        qsTranslate("settingsmanager", "black")
            ]

            content: [

                Flow {
                    width: set_fontweight.rightcol
                    spacing: 5
                    PQText {
                        y: (fw_normalslider.height-height)/2
                        text: qsTranslate("settingsmanager", "normal font weight:")
                    }
                    PQSlider {
                        id: fw_normalslider
                        from: 100
                        to: 900
                        stepSize: 10
                        wheelStepSize: 10
                        onValueChanged: setting_top.checkDefault()
                    }

                },

                PQText {
                    text: qsTranslate("settingsmanager", "current weight:") + " " + fw_normalslider.value + " (" + set_fontweight.values[Math.floor(fw_normalslider.value/100)-1] + ")"
                },

                Item {
                    width: 1
                    height: 10
                },

                Flow {
                    width: set_fontweight.rightcol
                    spacing: 5
                    PQText {
                        y: (fw_boldslider.height-height)/2
                        //: The weight here refers to the font weight
                        text: qsTranslate("settingsmanager", "bold font weight:")
                    }
                    PQSlider {
                        id: fw_boldslider
                        from: 100
                        to: 900
                        stepSize: 10
                        wheelStepSize: 10
                        onValueChanged: setting_top.checkDefault()
                    }

                },

                PQText {
                    text: qsTranslate("settingsmanager", "current weight:") + " " + fw_boldslider.value + " (" + set_fontweight.values[Math.round(fw_boldslider.value/100)-1] + ")"
                }

            ]

            onResetToDefaults: {
                fw_normalslider.value = PQCSettings.getDefaultForInterfaceFontNormalWeight()
                fw_boldslider.value = PQCSettings.getDefaultForInterfaceFontBoldWeight()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (fw_normalslider.hasChanged() || fw_boldslider.hasChanged())
            }

            function load() {
                fw_normalslider.loadAndSetDefault(PQCSettings.interfaceFontNormalWeight)
                fw_boldslider.loadAndSetDefault(PQCSettings.interfaceFontBoldWeight)
            }

            function applyChanges() {
                PQCSettings.interfaceFontNormalWeight = fw_normalslider.value
                PQCSettings.interfaceFontBoldWeight = fw_boldslider.value
                fw_normalslider.saveDefault()
                fw_boldslider.saveDefault()
            }

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

                    onLocChanged:
                        setting_top.checkDefault()

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
                                    color: notif_grid.loc==="topleft" ? PQCLook.baseColorActive                     
                                                                     : mouse_tl.containsMouse ? PQCLook.baseColorHighlight
                                                                                              : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="top" ? PQCLook.baseColorActive                     
                                                                 : mouse_t.containsMouse ? PQCLook.baseColorHighlight
                                                                                         : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="topright" ? PQCLook.baseColorActive                    
                                                                      : mouse_tr.containsMouse ? PQCLook.baseColorHighlight
                                                                                               : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="centerleft" ? PQCLook.baseColorActive                      
                                                                        : mouse_ml.containsMouse ? PQCLook.baseColorHighlight
                                                                                                 : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="center" ? PQCLook.baseColorActive                      
                                                                    : mouse_m.containsMouse ? PQCLook.baseColorHighlight
                                                                                            : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="centerright" ? PQCLook.baseColorActive                     
                                                                         : mouse_mr.containsMouse ? PQCLook.baseColorHighlight
                                                                                                  : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="bottomleft" ? PQCLook.baseColorActive                      
                                                                        : mouse_bl.containsMouse ? PQCLook.baseColorHighlight
                                                                                                 : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="bottom" ? PQCLook.baseColorActive                      
                                                                    : mouse_b.containsMouse ? PQCLook.baseColorHighlight
                                                                                            : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                                    color: notif_grid.loc==="bottomright" ? PQCLook.baseColorActive                         
                                                                         : mouse_br.containsMouse ? PQCLook.baseColorHighlight
                                                                                                  : PQCLook.baseColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    width: 100
                                    height: 50
                                    border.width: 1
                                    border.color: PQCLook.baseColorHighlight 
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
                    visible: !PQCScriptsConfig.amIOnWindows() 
                    text: qsTranslate("settingsmanager", "try to show native notification")
                    onCheckedChanged:
                        setting_top.checkDefault()
                },

                Item {
                    width: 10
                    height: 50
                }

            ]

            onResetToDefaults: {
                notif_grid.loc = PQCSettings.getDefaultForInterfaceNotificationLocation()
                notif_external.checked = PQCSettings.getDefaultForInterfaceNotificationTryNative()
                notif_dist.setValue(PQCSettings.getDefaultForInterfaceNotificationDistanceFromEdge())
            }

            function handleEscape() {
                notif_dist.closeContextMenus()
                notif_dist.acceptValue()
            }

            function hasChanged() {
                return (notif_grid.default_loc !== notif_grid.loc || notif_external.hasChanged() || notif_dist.hasChanged())
            }

            function load() {
                notif_grid.loc = PQCSettings.interfaceNotificationLocation
                notif_grid.default_loc = PQCSettings.interfaceNotificationLocation
                notif_external.loadAndSetDefault(PQCSettings.interfaceNotificationTryNative)
                notif_dist.loadAndSetDefault(PQCSettings.interfaceNotificationDistanceFromEdge)
            }

            function applyChanges() {

                PQCSettings.interfaceNotificationLocation = notif_grid.loc
                PQCSettings.interfaceNotificationTryNative = notif_external.checked
                PQCSettings.interfaceNotificationDistanceFromEdge = notif_dist.value

                notif_grid.default_loc = notif_grid.loc
                notif_external.saveDefault()
                notif_dist.saveDefault()

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        // PQQuickActionsSettings {
        //     id: set_quick
        //     onCheckHasChanged: {
        //         setting_top.checkDefault()
        //     }
        // }

        Item {
            width: 1
            height: 20
        }

    }

    Component.onCompleted:
        load()

    // do not make this function typed, it will break
    function areTwoListsEqual(l1, l2) {

        if(l1.length !== l2.length)
            return false

        for(var i = 0; i < l1.length; ++i) {

            if(l1[i].length !== l2[i].length)
                return false

            for(var j = 0; j < l1[i].length; ++j) {
                if(l1[i][j] !== l2[i][j])
                    return false
            }
        }

        return true
    }

    function handleEscape() {

        set_lang.handleEscape()
        set_windowmode.handleEscape()
        set_winbut.handleEscape()
        set_accent.handleEscape()
        set_fontweight.handleEscape()
        set_notif.handleEscape()
        // set_quick.handleEscape()

    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        if(set_lang.hasChanged() || set_windowmode.hasChanged() || set_winbut.hasChanged() ||
                set_accent.hasChanged() || set_fontweight.hasChanged() || set_notif.hasChanged()/* ||
                set_quick.hasChanged()*/) {
            setting_top.settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        set_lang.load()
        set_windowmode.load()
        set_winbut.load()
        set_accent.load()
        set_fontweight.load()
        set_notif.load()
        // set_quick.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_lang.applyChanges()
        set_windowmode.applyChanges()
        set_winbut.applyChanges()
        set_accent.applyChanges()
        set_fontweight.applyChanges()
        set_notif.applyChanges()
        // set_quick.applyChanges()

        setting_top.settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
