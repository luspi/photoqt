import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfacePopoutMainMenu
// - interfacePopoutMetadata
// - interfacePopoutHistogram
// - interfacePopoutScale
// - interfacePopoutSlideshowSetup
// - interfacePopoutSlideshowControls
// - interfacePopoutFileRename
// - interfacePopoutFileDelete
// - interfacePopoutAbout
// - interfacePopoutImgur
// - interfacePopoutWallpaper
// - interfacePopoutFilter
// - interfacePopoutSettingsManager
// - interfacePopoutExport
// - interfacePopoutChromecast
// - interfacePopoutAdvancedSort
// - interfacePopoutMapCurrent
// - interfacePopoutMapExplorer
// - interfacePopoutFileDialog
// - interfacePopoutMapExplorerKeepOpen
// - interfacePopoutFileDialogKeepOpen
// - interfacePopoutWhenWindowIsSmall

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    //: Used as identifying name for one of the elements in the interface
    property var pops: [["interfacePopoutFileDialog", qsTranslate("settingsmanager", "File dialog")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMapExplorer", qsTranslate("settingsmanager", "Map explorer")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSettingsManager", qsTranslate("settingsmanager", "Settings manager")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMainMenu", qsTranslate("settingsmanager", "Main menu")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMetadata", qsTranslate("settingsmanager", "Metadata")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutHistogram", qsTranslate("settingsmanager", "Histogram")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMapCurrent", qsTranslate("settingsmanager", "Map (current image)")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutScale", qsTranslate("settingsmanager", "Scale")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSlideshowSetup", qsTranslate("settingsmanager", "Slideshow setup")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSlideShowControls", qsTranslate("settingsmanager", "Slideshow controls")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileRename", qsTranslate("settingsmanager", "Rename file")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileDelete", qsTranslate("settingsmanager", "Delete file")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutExport", qsTranslate("settingsmanager", "Export file")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutAbout", qsTranslate("settingsmanager", "About")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutImgur", qsTranslate("settingsmanager", "Imgur")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutWallpaper", qsTranslate("settingsmanager", "Wallpaper")],
                        //: Noun, not a verb. Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFilter", qsTranslate("settingsmanager", "Filter")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutAdvancedSort", qsTranslate("settingsmanager", "Advanced image sort")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutChromecast", qsTranslate("settingsmanager", "Streaming (Chromecast)")]]

    property var currentCheckBoxStates: ["0","0","0","0","0",
                                         "0","0","0","0","0",
                                         "0","0","0","0","0",
                                         "0","0","0","0"]
    property string _defaultCurrentCheckBoxStates: ""
    onCurrentCheckBoxStatesChanged:
        checkDefault()

    signal popoutLoadDefault()
    signal popoutSaveChanges()

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Popout")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "Almost all of the elements for displaying information or performing actions can either be shown integrated into the main window or shown popped out in their own window. Most of them can also be popped out/in through a small button at the top left corner of each elements.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            spacing: 5

            Repeater {

                model: pops.length

                Rectangle {

                    id: deleg

                    width: Math.min(setting_top.width, 600)
                    height: 35
                    radius: 5

                    property bool hovered: false

                    color: hovered||check.checked ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
                    Behavior on color { ColorAnimation { duration: 200 } }

                    PQCheckBox {
                        id: check
                        x: 10
                        y: (parent.height-height)/2
                        text: pops[index][1]
                        font.weight: PQCLook.fontWeightBold
                        color: deleg.hovered||check.checked ? PQCLook.textColorActive : PQCLook.textColor
                        onCheckedChanged: {
                            currentCheckBoxStates[index] = (checked ? "1" : "0")
                            currentCheckBoxStatesChanged()
                        }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered:
                            deleg.hovered = true
                        onExited:
                            deleg.hovered = false
                        onClicked:
                            check.checked = !check.checked
                    }

                    Connections {

                        target: setting_top

                        function onPopoutLoadDefault() {
                            check.checked = PQCSettings[pops[index][0]]
                        }

                        function onPopoutSaveChanges() {
                            PQCSettings[pops[index][0]] = check.checked
                        }
                    }

                }

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Keep popouts open")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "Two of the elements have an optional special behavior when it comes to keeping them open after they performed their action. The two elements are the file dialog and the map explorer (if available). Both of them can be kept open after a file is selected and loaded in the main view allowing for quick and convenient browsing of images.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            spacing: 5

            Rectangle {

                id: keepopen_fd

                width: Math.min(setting_top.width, 600)
                height: 35
                radius: 5

                property bool hovered: false

                color: hovered||keepopen_fd_check.checked ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
                Behavior on color { ColorAnimation { duration: 200 } }

                PQCheckBox {
                    id: keepopen_fd_check
                    x: 10
                    y: (parent.height-height)/2
                    text: qsTranslate("settingsmanager", "keep file dialog open")
                    font.weight: PQCLook.fontWeightBold
                    color: keepopen_fd.hovered||keepopen_fd_check.checked ? PQCLook.textColorActive : PQCLook.textColor
                    checked: PQCSettings.interfacePopoutFileDialogKeepOpen
                    onCheckedChanged:
                        checkDefault()
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered:
                        keepopen_fd.hovered = true
                    onExited:
                        keepopen_fd.hovered = false
                    onClicked:
                        keepopen_fd_check.checked = !keepopen_fd_check.checked
                }

            }

            /*******************************************************/

            Rectangle {

                id: keepopen_me

                width: Math.min(setting_top.width, 600)
                height: 35
                radius: 5

                property bool hovered: false

                color: hovered||keepopen_me_check.checked ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
                Behavior on color { ColorAnimation { duration: 200 } }

                PQCheckBox {
                    id: keepopen_me_check
                    x: 10
                    y: (parent.height-height)/2
                    text: qsTranslate("settingsmanager", "keep map explorer open")
                    font.weight: PQCLook.fontWeightBold
                    color: keepopen_me.hovered||keepopen_me_check.checked ? PQCLook.textColorActive : PQCLook.textColor
                    checked: PQCSettings.interfacePopoutMapExplorerKeepOpen
                    onCheckedChanged:
                        checkDefault()
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered:
                        keepopen_me.hovered = true
                    onExited:
                        keepopen_me.hovered = false
                    onClicked:
                        keepopen_me_check.checked = !keepopen_me_check.checked
                }

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Pop out when window is small")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "Some elements might not be as usable or function well when the window is too small. Thus it is possible to force such elements to be popped out automatically whenever the application window is too small.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: checksmall
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager",  "pop out when application window is small")
            checked: PQCSettings.interfacePopoutWhenWindowIsSmall
            onCheckedChanged:
                checkDefault()
        }

        Item {
            width: 1
            height: 10
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(_defaultCurrentCheckBoxStates !== currentCheckBoxStates.join("")) {
            settingChanged = true
            return
        }

        if(keepopen_fd_check.hasChanged() || keepopen_me_check.hasChanged() || checksmall.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    Timer {
        interval: 100
        id: loadtimer
        onTriggered: {

            setting_top.popoutLoadDefault()

            keepopen_fd_check.loadAndSetDefault(PQCSettings.interfacePopoutFileDialogKeepOpen)
            keepopen_me_check.loadAndSetDefault(PQCSettings.interfacePopoutMapExplorerKeepOpen)
            checksmall.loadAndSetDefault(PQCSettings.interfacePopoutWhenWindowIsSmall)

            saveDefaultCheckTimer.restart()

            settingChanged = false
        }
    }

    Timer {
        interval: 100
        id: saveDefaultCheckTimer
        onTriggered: {
            _defaultCurrentCheckBoxStates = currentCheckBoxStates.join("")
        }
    }

    function load() {
        loadtimer.restart()
    }

    function applyChanges() {

        setting_top.popoutSaveChanges()
        PQCSettings.interfacePopoutFileDialogKeepOpen = keepopen_fd_check.checked
        PQCSettings.interfacePopoutMapExplorerKeepOpen = keepopen_me_check.checked
        PQCSettings.interfacePopoutWhenWindowIsSmall = checksmall.checked

        _defaultCurrentCheckBoxStates = currentCheckBoxStates.join("")
        keepopen_fd_check.saveDefault()
        keepopen_me_check.saveDefault()
        checksmall.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
