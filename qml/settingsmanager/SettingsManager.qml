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

import "./tabs"
import "../elements"

Rectangle {

    id: settings_top

    // Positioning and basic look
    x: 0
    y: 0
    width: mainwindow.width
    height: mainwindow.height
    color: colour.fadein_slidein_bg

    // Invisible at startup
    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    property int settingsQuickInfoCloseXSize: Math.max(5, Math.min(25, settings.quickInfoCloseXSize))

    property alias settingsDetectShortcuts: detectshortcut

    // setData is only emitted when settings have been 'closed without saving'
    // See comment above 'setData_restore()' function below
    signal setData()

    // Save data
    signal saveData()

    // signals needed for thumbnail db handling (for communication between confirm rect here and thumbnails>advanced tab)
    signal cleanDatabase()
    signal eraseDatabase()
    signal updateDatabaseInfo()

    // tell TabShortcuts to load set of default shortcuts
    signal shortcutsLoadDefaults()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    CustomTabView {

        id: view

        enabled: detectshortcut.opacity!=1

        x: 0
        y: 0
        width: parent.width
        height: parent.height-butrow.height

        tabCount: 6     // We currently have 5 tabs in the settings

        Tab {

            //: The look of PhotoQt and how it feels and behaves
            title: em.pty+qsTr("Look and Feel")

            TabLookAndFeel {

                Connections {
                    target: settings_top
                    onSetData:{
                        setData()
                    }
                    onSaveData:{
                        saveData()
                    }
                }
                Component.onCompleted: {
                    setData()
                }

            }

        }

        Tab {

            title: em.pty+qsTr("Thumbnails")

            TabThumbnails {

                Connections {
                    target: settings_top
                    onSetData:{
                        setData()
                    }
                    onSaveData:{
                        saveData()
                    }
                    onCleanDatabase: {
                        cleanDatabase()
                    }
                    onEraseDatabase: {
                        eraseDatabase()
                    }
                    onUpdateDatabaseInfo: {
                        updateDatabaseInfo()
                    }
                }
                Component.onCompleted: {
                    setData()
                }

            }

        }


        Tab {

            title: em.pty+qsTr("Metadata")
            TabMetadata {
                Connections {
                    target: settings_top
                    onSetData:{
                        setData()
                    }
                    onSaveData:{
                        saveData()
                    }
                }
                Component.onCompleted: {
                    setData()
                }
            }

        }

        Tab {

            title: em.pty+qsTr("Fileformats")

            TabFileformats {
                Connections {
                    target: settings_top
                    onSetData:{
                        setData()
                    }
                    onSaveData:{
                        saveData()
                    }
                }
                Component.onCompleted: {
                    setData()
                }
            }

        }

        Tab {

            title: em.pty+qsTr("Image Formats")

            TabImageFormats {
                Connections {
                    target: settings_top
                    onSetData:{
                        setData()
                    }
                    onSaveData:{
                        saveData()
                    }
                }
                Component.onCompleted: {
                    setData()
                }
            }

        }

        Tab {

            title: em.pty+qsTr("Other Settings")

            TabOther {
                Connections {
                    target: settings_top
                    onSetData:{
                        setData()
                    }
                    onSaveData:{
                        saveData()
                    }
                }
                Component.onCompleted: {
                    setData()
                }
            }
        }

        Tab {

            title: em.pty+qsTr("Shortcuts")

            TabShortcuts {
                Connections {
                    target: settings_top
                    onSetData: {
                        setData()
                    }
                    onSaveData: {
                        saveData()
                    }
                    onShortcutsLoadDefaults:
                        loadDefault()
                }
                Component.onCompleted: {
                    setData()
                }
            }
        }

    }

    // Line between settings and buttons
    Rectangle {

        id: sep

        x: 0
        y: butrow.y-1
        height: 1
        width: parent.width

        color: colour.linecolour

    }

    // A rectangle holding the buttons at the bottom
    Rectangle {

        id: butrow

        x: 0
        y: parent.height-40
        width: parent.width
        height: 40

        color: "#00000000"

        // Button to restore default settings - bottom left
        CustomButton {

            id: restoredefault

            x: 5
            y: 5
            height: parent.height-10

            text: em.pty+qsTr("Restore Default Settings")

            onClickedButton: confirmdefaultssettings.show()

        }

        CustomButton {
            id: exportimportbutton
            text: "Export/Import"
            x: restoredefault.x+restoredefault.width+10
            y: 5
            onClickedButton: {
                exportimport.show()
            }
        }

        // Button to exit without saving - bottom right
        CustomButton {

            id: exitnosave

            x: parent.width-width-10
            y: 5
            height: parent.height-10

            //: Changes here refer to changes in the settings manager
            text: em.pty+qsTr("Exit and Discard Changes")

            onClickedButton: {
                setData_restore()
                hideSettings()
            }

        }

        // Button to exit with saving - bottom right, next to exitnosave button
        CustomButton {

            id: exitsave

            x: exitnosave.x-width-10
            y: 5
            height: parent.height-10

            //: Changes here refer to changes in the settings manager
            text: em.pty+qsTr("Save Changes and Exit")

            onClickedButton: {
                saveSettings()
            }

        }

    }

    // This button closes the SettingsManager dialog -> it is displayed to the RIGHT of the tabbar, in the top right corner
    Image {

        id: closeopenfile

        anchors.right: parent.right
        anchors.top: parent.top

        source: "qrc:/img/closingx.png"
        sourceSize: Qt.size(3*settingsQuickInfoCloseXSize, 3*settingsQuickInfoCloseXSize)

        ToolTip {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: hideSettings()
            text: em.pty+qsTr("Close settings manager")
        }

    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmclean
        //: The database refers to the database used for thumbnail caching
        header: em.pty+qsTr("Clean Database!")
        //: The database refers to the database used for thumbnail caching
        description: em.pty+qsTr("Do you really want to clean up the database?") + "<br><br>" +
                     em.pty+qsTr("This removes all obsolete thumbnails, thus possibly making PhotoQt a little faster.") + "<bR><br>" +
                     em.pty+qsTr("This process might take a little while.")
        //: Along the lines of "Yes, clean the database for thumbnails caching"
        confirmbuttontext: em.pty+qsTr("Yes, clean is good")
        //: Along the lines of "No, cleaning the database for thumbnails caching takes too long, don't do it"
        rejectbuttontext: em.pty+qsTr("No, don't have time for that")
        onAccepted: cleanDatabase()
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmerase
        //: The database refers to the database used for thumbnail caching
        header: em.pty+qsTr("Erase Database?")
         //: The database refers to the database used for thumbnail caching
        description: em.pty+qsTr("Do you really want to ERASE the entire database?") + "<br><br>" +
                      //: The database refers to the database used for thumbnail caching
                     em.pty+qsTr("This removes every single item from the database! This step should never really be necessary. Afterwards every thumbnail has to be re-created.") + "<br>" +
                     em.pty+qsTr("This step cannot be reversed!")
        //: Along the lines of "Yes, empty the database for thumbnails caching"
        confirmbuttontext: em.pty+qsTr("Yes, get rid of it all")
        //: Along the lines of "No, don't empty the database for thumbnails caching, I want to keep it"
        rejectbuttontext: em.pty+qsTr("No, I want to keep it")
        onAccepted: eraseDatabase()
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmdefaultssettings
        header: em.pty+qsTr("Restore Default Settings")
        description: em.pty+qsTr("Are you sure you want to revert back to the default settings?") + "<br><br>" +
                     em.pty+qsTr("This step cannot be reversed!")
        confirmbuttontext: em.pty+qsTr("Yes, go ahead")
        //: Used in settings manager when asking for confirmation for restoring default settings (written on button)
        rejectbuttontext: em.pty+qsTr("No, thanks")
        onAccepted: {
            settings.setDefault()
            imageformats.setDefaultFileformats()
            setData()
        }
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmdefaultshortcuts
        header: em.pty+qsTr("Set Default Shortcuts")
        description: em.pty+qsTr("Are you sure you want to reset the shortcuts to the default set?") + "<br><br>" +
                     em.pty+qsTr("This step cannot be reversed!")
        confirmbuttontext: em.pty+qsTr("Yes, please")
        rejectbuttontext: em.pty+qsTr("No, don't")
        maxwidth: 400
        onAccepted: {
            verboseMessage("SettingsManager","Setting default shortcuts...")
            shortcutsLoadDefaults()
        }
    }

    ShortcutNotifier {
        id: settingsmanagershortcuts
        area: "settingsmanager"

        onClosed:
            settings_top.forceActiveFocus()

    }

    ExportImport {
        id: exportimport
        anchors.fill: parent
    }

    SettingInfoOverlay {
        id: settingsinfooverlay
    }

    Component.onCompleted: {
        //: The tab refers to the tabs in the settings manager
        settingsmanagershortcuts.shortcuts[strings.get("ctrl") + " + " + strings.get("tab")] = em.pty+qsTr("Go to the next tab")
        //: The tab refers to the tabs in the settings manager
        settingsmanagershortcuts.shortcuts[strings.get("ctrl") + " + " + strings.get("shift") + " + " + strings.get("tab")] = em.pty+qsTr("Go to the previous tab")
        //: The tab refers to the tabs in the settings manager
        settingsmanagershortcuts.shortcuts[strings.get("alt") + "+1 " + " ... " + " " + strings.get("alt") + "+6"] = em.pty+qsTr("Switch to tab 1 to 5")
        settingsmanagershortcuts.shortcuts[strings.get("ctrl") + "+S"] = em.pty+qsTr("Save settings")
        settingsmanagershortcuts.shortcuts[strings.get("escape")] = em.pty+qsTr("Discard settings")
    }

    Connections {
        target: call
        onSettingsmanagerShow:
            showSettings()
        onShortcut: {
            if(!settings_top.visible) return
            if(sh == "Escape")
                hideSettings()
            else if(sh == "Ctrl+S")
                saveSettings()
            else if(sh == "Ctrl+Tab")
                nextTab()
            else if(sh == "Ctrl+Shift+Tab")
                prevTab()
            else if(sh == "Alt+1")
                gotoTab(0)
            else if(sh == "Alt+2")
                gotoTab(1)
            else if(sh == "Alt+3")
                gotoTab(2)
            else if(sh == "Alt+4")
                gotoTab(3)
            else if(sh == "Alt+5")
                gotoTab(4)
            else if(sh == "Alt+6")
                gotoTab(5)

        }
        onCloseAnyElement:
            if(settings_top.visible)
                forceHideEverything()

    }

    DetectShortcut {
        id: detectshortcut
    }

    function showSettings() {
        verboseMessage("SettingsManager", "showSettings()")
        opacity = 1
        variables.guiBlocked = true
        setData()	// We DO need to call setData() here, as otherwise - once set up - a tab would not be updated (e.g. with changes from quicksettings)
        updateDatabaseInfo()
        settingsmanagershortcuts.display()
    }
    function hideSettings() {
        verboseMessage("SettingsManager", "hideSettings(): ", confirmclean.visible + " / " +
                                                              confirmerase.visible + " / " +
                                                              confirmdefaultshortcuts.visible + " / " +
                                                              confirmdefaultssettings.visible + " / " +
                                                              settingsmanagershortcuts.visible + " / " +
                                                              detectshortcut.visible + " / " +
                                                              exportimport.visible + " / " +
                                                              settingsinfooverlay.visible)
        if(confirmclean.visible)
            confirmclean.reject()
        else if(confirmerase.visible)
            confirmerase.reject()
        else if(confirmdefaultshortcuts.visible)
            confirmdefaultshortcuts.reject()
        else if(confirmdefaultssettings.visible)
            confirmdefaultssettings.reject()
        else if(settingsmanagershortcuts.visible)
            settingsmanagershortcuts.reject()
        else if(detectshortcut.visible)
            return
        else if(exportimport.visible)
            exportimport.hide()
        else if(settingsinfooverlay.visible)
            settingsinfooverlay.hide()
        else {
            opacity = 0
            if(variables.currentFile === "" )
                call.show("openfile")
            else
                variables.guiBlocked = false
        }
    }
    function forceHideEverything() {
        verboseMessage("SettingsManager", "forceHideEverything()")
        if(confirmclean.visible)
            confirmclean.reject()
        if(confirmerase.visible)
            confirmerase.reject()
        if(confirmdefaultshortcuts.visible)
            confirmdefaultshortcuts.reject()
        if(confirmdefaultssettings.visible)
            confirmdefaultssettings.reject()
        if(settingsmanagershortcuts.visible)
            settingsmanagershortcuts.reject()
        if(detectshortcut.opacity == 1)
            detectshortcut.hide()
        if(exportimport.opacity == 1)
            exportimport.hide()
        if(settingsinfooverlay.opacity == 1)
            settingsinfooverlay.hide()
        opacity = 0
        variables.guiBlocked = false
    }

    // This function is only called, when settings have been opened and "closed without saving"
    // In any other case, the actual tabs are ONLY SET UP WHEN OPENED (i.e., as needed) and use
    // the Component.onCompleted signal to make sure that the settings are loaded.
    function setData_restore() {
        setData()
    }

    function nextTab() {
        view.nextTab()
    }
    function prevTab() {
        view.prevTab()
    }
    function gotoTab(num) {
        view.currentIndex = num
    }

    function saveSettings() {
        saveData();
        hideSettings()
    }

}


