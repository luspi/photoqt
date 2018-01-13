import QtQuick 2.4
import QtQuick.Controls 1.3

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
    Behavior on opacity { NumberAnimation { duration: settings.myWidgetAnimated ? 250 : 0 } }


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
            title: qsTr("Look and Feel")

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

            title: qsTr("Thumbnails")

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

            title: qsTr("Metadata")
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

            title: qsTr("Fileformats")

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

            title: qsTr("Other Settings")

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

            title: qsTr("Shortcuts")

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

            text: qsTr("Restore Default Settings")

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
            text: qsTr("Exit and Discard Changes")

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
            text: qsTr("Save Changes and Exit")

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
        sourceSize: Qt.size(3*settings.closeXsize,3*settings.closeXsize)

        ToolTip {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: hideSettings()
            text: qsTr("Close settings manager")
        }

    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmclean
        //: The database refers to the database used for thumbnail caching
        header: qsTr("Clean Database!")
        //: The database refers to the database used for thumbnail caching
        description: qsTr("Do you really want to clean up the database?") + "<br><br>" +
                     qsTr("This removes all obsolete thumbnails, thus possibly making PhotoQt a little faster.") + "<bR><br>" +
                     qsTr("This process might take a little while.")
        //: Along the lines of "Yes, clean the database for thumbnails caching"
        confirmbuttontext: qsTr("Yes, clean is good")
        //: Along the lines of "No, cleaning the database for thumbnails caching takes too long, don't do it"
        rejectbuttontext: qsTr("No, don't have time for that")
        onAccepted: cleanDatabase()
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmerase
        //: The database refers to the database used for thumbnail caching
        header: qsTr("Erase Database?")
         //: The database refers to the database used for thumbnail caching
        description: qsTr("Do you really want to ERASE the entire database?") + "<br><br>" +
                      //: The database refers to the database used for thumbnail caching
                     qsTr("This removes every single item from the database! This step should never really be necessary. Afterwards every thumbnail has to be re-created.") + "<br>" +
                     qsTr("This step cannot be reversed!")
        //: Along the lines of "Yes, empty the database for thumbnails caching"
        confirmbuttontext: qsTr("Yes, get rid of it all")
        //: Along the lines of "No, don't empty the database for thumbnails caching, I want to keep it"
        rejectbuttontext: qsTr("No, I want to keep it")
        onAccepted: eraseDatabase()
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmdefaultssettings
        header: qsTr("Restore Default Settings")
        description: qsTr("Are you sure you want to revert back to the default settings?") + "<br><br>" +
                     qsTr("This change is not permanent until you click on 'Save'.")
        confirmbuttontext: qsTr("Yes, go ahead")
        //: Used in settings manager when asking for confirmation for restoring default settings (written on button)
        rejectbuttontext: qsTr("No, thanks")
        onAccepted: {
            settings.setDefault()
            setData()
        }
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmdefaultshortcuts
        header: qsTr("Set Default Shortcuts")
        description: qsTr("Are you sure you want to reset the shortcuts to the default set?") + "<br><br>" +
                     qsTr("This change is not permanent until you click on 'Save'.")
        confirmbuttontext: qsTr("Yes, please")
        rejectbuttontext: qsTr("No, don't")
        maxwidth: 400
        onAccepted: {
            verboseMessage("Settings","Setting default shortcuts...")
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
        settingsmanagershortcuts.shortcuts[strings.get("ctrl") + " + " + strings.get("tab")] = qsTr("Go to the next tab")
        //: The tab refers to the tabs in the settings manager
        settingsmanagershortcuts.shortcuts[strings.get("ctrl") + " + " + strings.get("shift") + " + " + strings.get("tab")] = qsTr("Go to the previous tab")
        //: The tab refers to the tabs in the settings manager
        settingsmanagershortcuts.shortcuts[strings.get("alt") + "+1 " + " ... " + " " + strings.get("alt") + "+6"] = qsTr("Switch to tab 1 to 5")
        settingsmanagershortcuts.shortcuts[strings.get("ctrl") + "+S"] = qsTr("Save settings")
        settingsmanagershortcuts.shortcuts[strings.get("escape")] = qsTr("Discard settings")
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
    }

    DetectShortcut {
        id: detectshortcut
    }

    function showSettings() {
        verboseMessage("Settings::showSettings()","Showing Settings...")
        opacity = 1
        variables.guiBlocked = true
        setData()	// We DO need to call setData() here, as otherwise - once set up - a tab would not be updated (e.g. with changes from quicksettings)
        updateDatabaseInfo()
        settingsmanagershortcuts.display()
    }
    function hideSettings() {
        verboseMessage("Settings::hideSettings()",confirmclean.visible + "/" + confirmerase.visible + "/" + confirmdefaultshortcuts.visible + "/" + confirmdefaultssettings.visible + "/" + settingsmanagershortcuts.visible + "/" + detectshortcut.visible)
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
        else if(detectshortcut.opacity == 1)
            return
        else if(exportimport.opacity == 1)
            exportimport.hide()
        else if(settingsinfooverlay.opacity == 1)
            settingsinfooverlay.hide()
        else {
            opacity = 0
            if(variables.currentFile == "" )
                call.show("openfile")
            else
                variables.guiBlocked = false
        }
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


