import QtQuick 2.3
import QtQuick.Controls 1.2

import "./tabs"
import "../elements"

Rectangle {

    id: settings_top

    // Positioning and basic look
    anchors.fill: background
    color: colour.fadein_slidein_bg

    // Invisible at startup
    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: settings.myWidgetAnimated ? 250 : 0 } }
    onVisibleChanged: {
        if(!visible && thumbnailBar.currentFile == "")
            openFile()
    }

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

            //: This is used as a title for one of the tabs in the settings manager
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

            //: This is used as a title for one of the tabs in the settings manager
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

            //: This is used as a title for one of the tabs in the settings manager
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

            //: This is used as a title for one of the tabs in the settings manager
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

            //: This is used as a title for one of the tabs in the settings manager
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

            //: This is used as a title for one of the tabs in the settings manager
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

            //: This is written on a button in the settings manager
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

            //: This is written on a button in the settings manager
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

            //: This is written on a button in the settings manager
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
            //: This is the tooltip of the exit button (little 'x' top right corner)
            text: qsTr("Close settings manager")
        }

    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmclean
        //: Used in settings manager when asking for confirmation for cleaning up thumbnail database
        header: qsTr("Clean Database!")
        //: Used in settings manager when asking for confirmation for cleaning up thumbnail database
        description: qsTr("Do you really want to clean up the database?") + "<br><br>" +
                     //: Used in settings manager when asking for confirmation for cleaning up thumbnail database
                     qsTr("This removes all obsolete thumbnails, thus possibly making PhotoQt a little faster.") + "<bR><br>" +
                     //: Used in settings manager when asking for confirmation for cleaning up thumbnail database
                     qsTr("This process might take a little while.")
        //: Used in settings manager when asking for confirmation for cleaning up thumbnail database (written on button)
        confirmbuttontext: qsTr("Yes, clean is good")
        //: Used in settings manager when asking for confirmation for cleaning up thumbnail database (written on button)
        rejectbuttontext: qsTr("No, don't have time for that")
        onAccepted: cleanDatabase()
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmerase
        //: Used in settings manager when asking for confirmation for erasing thumbnail database
        header: qsTr("Erase Database?")
        //: Used in settings manager when asking for confirmation for erasing thumbnail database
        description: qsTr("Do you really want to ERASE the entire database?") + "<br><br>" +
                     //: Used in settings manager when asking for confirmation for erasing thumbnail database
                     qsTr("This removes every single item from the database! This step is never really necessary, and generally should not be used. After that, every thumbnail has to be re-created.") + "<br>" +
                     //: Used in settings manager when asking for confirmation for erasing thumbnail database
                     qsTr("This step cannot be reversed!")
        //: Used in settings manager when asking for confirmation for erasing thumbnail database (written on button)
        confirmbuttontext: qsTr("Yes, get rid of it all")
        //: Used in settings manager when asking for confirmation for erasing thumbnail database (written on button)
        rejectbuttontext: qsTr("Nooo, I want to keep it")
        onAccepted: eraseDatabase()
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: confirmdefaultssettings
        //: Used in settings manager when asking for confirmation for restoring default SETTINGS
        header: qsTr("Restore Default Settings")
        //: Used in settings manager when asking for confirmation for restoring default settings
        description: qsTr("Are you sure you want to revert back to the default settings?") + "<br><br>" +
                     //: Used in settings manager when asking for confirmation for restoring default settings
                     qsTr("This change is not permanent until you click on 'Save'.")
        //: Used in settings manager when asking for confirmation for restoring default settings (written on button)
        confirmbuttontext: qsTr("Yup, go ahead")
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
        //: Used in settings manager when asking for confirmation for restoring default SHORTCUTS
        header: qsTr("Set Default Shortcuts")
        //: Used in settings manager when asking for confirmation for restoring default shortcuts
        description: qsTr("Are you sure you want to reset the shortcuts to the default set?") + "<br><br>" +
                     //: Used in settings manager when asking for confirmation for restoring default shortcuts
                     qsTr("This change is not permanent until you click on 'Save'.")
        //: Used in settings manager when asking for confirmation for restoring default shortcuts (written on button)
        confirmbuttontext: qsTr("Yes, please")
        //: Used in settings manager when asking for confirmation for restoring default shortcuts (written on button)
        rejectbuttontext: qsTr("Nah, don't")
        maxwidth: 400
        onAccepted: {
            verboseMessage("Settings","Setting default shortcuts...")
            shortcutsLoadDefaults()
        }
    }

    CustomConfirm {
        fillAnchors: settings_top
        id: invalidshortcuts
        //: Used in settings manager to notify the user that there's a problem with the shortcuts settings
        header: qsTr("Invalid Shortcuts Settings")
        //: Used in settings manager to notify the user that there's a problem with the shortcuts settings
        description: qsTr("There is a problem with the shortcuts setup you've created. You seem to have used a key/mouse/touch combination more than once. Please go back and fix that before saving your changes...")
        //: Used in settings manager to notify the user that there's a problem with the shortcuts settings (written on button)
        rejectbuttontext: qsTr("Go back")
        actAsErrorMessage: true
        onRejected: gotoTab(4)
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
        //: Inform the user of a possible shortcut action in the settings manager
        settingsmanagershortcuts.shortcuts[str_keys.get("ctrl") + " + " + str_keys.get("tab")] = qsTr("Go to the next tab")
        //: Inform the user of a possible shortcut action in the settings manager
        settingsmanagershortcuts.shortcuts[str_keys.get("ctrl") + " + " + str_keys.get("shift") + " + " + str_keys.get("tab")] = qsTr("Go to the previous tab")
        //: Inform the user of a possible shortcut action in the settings manager
        settingsmanagershortcuts.shortcuts[str_keys.get("alt") + "+1 " + " ... " + " " + str_keys.get("alt") + "+5"] = qsTr("Switch to tab 1 to 5")
        //: Inform the user of a possible shortcut action in the settings manager
        settingsmanagershortcuts.shortcuts[str_keys.get("ctrl") + "+S"] = qsTr("Save settings")
        //: Inform the user of a possible shortcut action in the settings manager
        settingsmanagershortcuts.shortcuts[str_keys.get("escape")] = qsTr("Discard settings")
    }

    DetectShortcut {
        id: detectshortcut
    }
    function isDetectShortcutShown() {
        return detectshortcut.opacity==1
    }

    function showSettings() {
        verboseMessage("Settings::showSettings()","Showing Settings...")
        opacity = 1
        blurAllBackgroundElements()
        blocked = true
        setData()	// We DO need to call setData() here, as otherwise - once set up - a tab would not be updated (e.g. with changes from quicksettings)
        updateDatabaseInfo()
    }
    function hideSettings() {
        verboseMessage("Settings::hideSettings()",confirmclean.visible + "/" + confirmerase.visible + "/" + confirmdefaultshortcuts.visible + "/" + confirmdefaultssettings.visible + "/" + settingsmanagershortcuts.visible + "/" + detectshortcut.visible + "/" + invalidshortcuts.visible)
        if(confirmclean.visible)
            confirmclean.hide()
        else if(confirmerase.visible)
            confirmerase.hide()
        else if(confirmdefaultshortcuts.visible)
            confirmdefaultshortcuts.hide()
        else if(confirmdefaultssettings.visible)
            confirmdefaultssettings.hide()
        else if(settingsmanagershortcuts.visible)
            settingsmanagershortcuts.reject()
        else if(detectshortcut.opacity == 1)
            detectshortcut.hide()
        else if(invalidshortcuts.opacity == 1)
            invalidshortcuts.accept()
        else if(exportimport.opacity == 1)
            exportimport.hide()
        else if(settingsinfooverlay.opacity == 1)
            settingsinfooverlay.hide()
        else {
            opacity = 0
            blocked = false
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

        verboseMessage("Settings::saveSettings()",detectshortcut.checkForShortcutErrors())

        if(detectshortcut.checkForShortcutErrors())
            invalidshortcuts.show()
        else {
            saveData();
            hideSettings();
        }
    }

    function updateKeyShortcut(combo) {
        detectshortcut.updateKeyShortcut(combo)
    }
    function updatedMouseGesture(button, gesture, modifiers) {
        detectshortcut.updateMouseGesture(button, gesture, modifiers)
    }
    function finishedMouseGesture(button, gesture, modifiers) {
        detectshortcut.finishedMouseGesture(button, gesture, modifiers)
    }
    function updateTouchGesture(fingers, type, path) {
        detectshortcut.updateTouchGesture(fingers, type, path)
    }
    function finishedTouchGesture(fingers, type, path) {
        detectshortcut.finishedTouchGesture(fingers, type, path)
    }

}


