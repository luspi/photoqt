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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt.Modern
import PhotoQt.Shared

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - interfaceStatusInfoList
// - interfaceStatusInfoShow
// - interfaceStatusInfoFontSize
// - interfaceStatusInfoAutoHide
// - interfaceStatusInfoAutoHideTimeout
// - interfaceStatusInfoAutoHideTopEdge
// - interfaceStatusInfoShowImageChange
// - interfaceStatusInfoPosition
// - interfaceStatusInfoManageWindow

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: fontsize.contextMenuOpen || fontsize.editMode ||
                               autohide_timeout.contextMenuOpen || autohide_timeout.editMode ||
                               but_add.contextmenu.visible || combo_add.popup.visible || infoalignment.popup.visible

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    SystemPalette { id: pqtPalette }

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQSetting {

            id: set_status

            property list<string> curEntries: []

            //: Settings title
            title: qsTranslate("settingsmanager", "Status info")

            helptext: qsTranslate("settingsmanager",  "The status information refers to the set of information shown in the top left corner of the screen. This typically includes the filename of the currently viewed image and information like the zoom level, rotation angle, etc. The exact set of information and their order can be adjusted as desired.")

            content: [

                PQCheckBox {
                    id: status_show
                    enforceMaxWidth: set_status.rightcol
                    text: qsTranslate("settingsmanager", "show status information")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Rectangle {
                    enabled: status_show.checked
                    width: parent.width-5
                    radius: 5
                    clip: true

                    height: enabled ? (60+(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    color: PQCLook.baseBorder
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
                            //: Please keep short! The counter shows where we are in the folder.
                            "counter": qsTranslate("settingsmanager", "counter"),
                            //: Please keep short!
                            "filename": qsTranslate("settingsmanager", "filename"),
                            //: Please keep short!
                            "filepathname": qsTranslate("settingsmanager", "filepath"),
                            //: Please keep short! This is the image resolution.
                            "resolution": qsTranslate("settingsmanager", "resolution"),
                            //: Please keep short! This is the current zoom level.
                            "zoom": qsTranslate("settingsmanager", "zoom"),
                            //: Please keep short! This is the rotation of the current image
                            "rotation": qsTranslate("settingsmanager", "rotation"),
                            //: Please keep short! This is the filesize of the current image.
                            "filesize": qsTranslate("settingsmanager", "filesize"),
                            //: Please keep short! This is the color profile used for the current image
                            "colorprofile": qsTranslate("settingsmanager", "color profile")
                        }

                        model: ListModel {
                            id: model
                        }

                        delegate: Item {
                            id: deleg
                            width: Math.max.apply(Math, avail.widths)
                            height: avail.height-(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)

                            required property string name
                            required property int index

                            Rectangle {
                                id: dragRect
                                width: deleg.width
                                height: deleg.height
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: pqtPalette.base
                                radius: 5
                                PQText {
                                    id: txt
                                    x: (parent.width-width)/2
                                    y: (parent.height-height)/2
                                    text: avail.disp[deleg.name]
                                    font.weight: PQCLook.fontWeightBold 
                                    color: pqtPalette.text
                                    onWidthChanged: {
                                        avail.widths.push(width+20)
                                        avail.widthsChanged()
                                    }
                                }
                                PQMouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    drag.target: parent
                                    drag.axis: Drag.XAxis
                                    drag.onActiveChanged: {
                                        if (mouseArea.drag.active) {
                                            avail.dragItemIndex = deleg.index;
                                        }
                                        dragRect.Drag.drop();
                                        if(!mouseArea.drag.active) {
                                            set_status.populateModel()
                                        }
                                    }
                                    cursorShape: Qt.OpenHandCursor
                                    onPressed:
                                        cursorShape = Qt.ClosedHandCursor
                                    onReleased:
                                        cursorShape = Qt.OpenHandCursor
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
                                            set_status.curEntries.splice(deleg.index, 1)
                                            set_status.populateModel()
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
                                var element = set_status.curEntries[avail.dragItemIndex];
                                set_status.curEntries.splice(avail.dragItemIndex, 1);
                                set_status.curEntries.splice(newindex, 0, element);

                                avail.model.move(avail.dragItemIndex, newindex, 1)
                                avail.dragItemIndex = newindex
                                setting_top.checkDefault()
                            }
                        }
                    }
                },

                Row {
                    enabled: status_show.checked
                    spacing: 10

                    height: enabled ? combo_add.height : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQComboBox {
                        id: combo_add
                        y: (but_add.height-height)/2
                        property list<string> statusdata_keys: [
                            "counter",
                            "filename",
                            "filepathname",
                            "resolution",
                            "zoom",
                            "rotation",
                            "filesize",
                            "colorprofile"
                        ]
                        property list<string> statusdata_vals: [
                            //: Please keep short! The counter shows where we are in the folder.
                            qsTranslate("settingsmanager", "counter"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "filename"),
                            //: Please keep short!
                            qsTranslate("settingsmanager", "filepath"),
                            //: Please keep short! This is the image resolution.
                            qsTranslate("settingsmanager", "resolution"),
                            //: Please keep short! This is the current zoom level.
                            qsTranslate("settingsmanager", "zoom"),
                            //: Please keep short! This is the rotation of the current image
                            qsTranslate("settingsmanager", "rotation"),
                            //: Please keep short! This is the filesize of the current image.
                            qsTranslate("settingsmanager", "filesize"),
                            //: Please keep short! This is the color profile used for the current image
                            qsTranslate("settingsmanager", "color profile")
                        ]
                        model: statusdata_vals
                    }
                    PQButton {
                        id: but_add
                        //: This is written on a button that is used to add a selected block to the status info section.
                        text: qsTranslate("settingsmanager", "add")
                        smallerVersion: true
                        onClicked: {
                            set_status.curEntries.push(combo_add.statusdata_keys[combo_add.currentIndex])
                            set_status.populateModel()
                            setting_top.checkDefault()
                        }
                    }
                },

                PQSliderSpinBox {
                    id: fontsize
                    width: set_status.rightcol
                    minval: 5
                    maxval: 30
                    title: qsTranslate("settingsmanager", "Font size:")
                    suffix: " pt"
                    enabled: status_show.checked
                    animateHeight: true
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {

                status_show.checked = PQCSettings.getDefaultForInterfaceStatusInfoShow()

                set_status.curEntries = PQCSettings.getDefaultForInterfaceStatusInfoList()
                populateModel()

                fontsize.setValue(PQCSettings.getDefaultForInterfaceStatusInfoFontSize())

                // this is needed to check for model changes
                setting_top.checkDefault()

            }

            function handleEscape() {
                but_add.contextmenu.close()
                fontsize.closeContextMenus()
                fontsize.acceptValue()
                combo_add.popup.close()
            }

            function hasChanged() {
                return (status_show.hasChanged() ||
                        !setting_top.areTwoListsEqual(set_status.curEntries, PQCSettings.interfaceStatusInfoList) ||
                        fontsize.hasChanged())
            }

            function load() {

                status_show.loadAndSetDefault(PQCSettings.interfaceStatusInfoShow) 

                set_status.curEntries = PQCSettings.interfaceStatusInfoList
                populateModel()

                fontsize.loadAndSetDefault(PQCSettings.interfaceStatusInfoFontSize)

            }

            function applyChanges() {

                PQCSettings.interfaceStatusInfoShow = status_show.checked 

                var opts = []
                for(var i = 0; i < model.count; ++i)
                    opts.push(model.get(i).name)
                // a line like this is needed. it seems like opts needs to be accessed for the value passed
                // on to PQCSettings to not be empty on older versions of Qt.
                console.log("new status info options:", opts)
                PQCSettings.interfaceStatusInfoList = opts

                PQCSettings.interfaceStatusInfoFontSize = fontsize.value

                fontsize.saveDefault()
                status_show.saveDefault()

            }

            function populateModel() {
                model.clear()
                for(var j = 0; j < set_status.curEntries.length; ++j)
                    model.append({"name": set_status.curEntries[j], "index": j})
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_hide

            //: Settings title
            title: qsTranslate("settingsmanager", "Hide automatically")

            helptext: qsTranslate("settingsmanager",  "The status info can either be shown at all times, or it can be hidden automatically based on different criteria. It can either be hidden unless the mouse cursor is near the top edge of the screen or until the mouse cursor is moved anywhere. After a specified timeout it will then hide again. In addition to these criteria, it can also be shown shortly whenever the image changes.")

            content: [
                PQRadioButton {
                    id: autohide_always
                    enforceMaxWidth: set_hide.rightcol
                    //: visibility status of the status information
                    text: qsTranslate("settingsmanager", "keep always visible")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: autohide_anymove
                    enforceMaxWidth: set_hide.rightcol
                    //: visibility status of the status information
                    text: qsTranslate("settingsmanager", "only show with any cursor move")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: autohide_topedge
                    enforceMaxWidth: set_hide.rightcol
                    //: visibility status of the status information
                    text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQSliderSpinBox {
                    id: autohide_timeout
                    width: set_hide.rightcol
                    minval: 0
                    maxval: 10
                    title: qsTranslate("settingsmanager", "hide again after timeout:")
                    suffix: " s"
                    enabled: !autohide_always.checked
                    animateHeight: true
                    onValueChanged:
                        setting_top.checkDefault()
                },

                Item {

                    clip: true
                    width: imgchange.width
                    enabled: !autohide_always.checked
                    height: enabled ? imgchange.height : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQCheckBox {
                        id: imgchange
                        enforceMaxWidth: set_hide.rightcol
                        //: Refers to the status information's auto-hide feature, this is an additional case it can be shown
                        text: qsTranslate("settingsmanager", "also show when image changes")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                }

            ]

            onResetToDefaults: {

                var val_hide = PQCSettings.getDefaultForInterfaceStatusInfoAutoHide()
                var val_topedge = PQCSettings.getDefaultForInterfaceStatusInfoAutoHideTopEdge()
                var val_timeout = PQCSettings.getDefaultForInterfaceStatusInfoAutoHideTimeout()/1000

                autohide_always.checked = (val_hide === 0 && val_topedge === 0)
                autohide_anymove.checked = (val_hide === 1 && val_topedge === 0)
                autohide_topedge.checked = (val_topedge === 1)
                autohide_timeout.setValue(val_timeout)

                imgchange.checked = PQCSettings.getDefaultForInterfaceStatusInfoShowImageChange()

            }

            function handleEscape() {
                autohide_timeout.closeContextMenus()
                autohide_timeout.acceptValue()
            }

            function hasChanged() {

                return (autohide_always.hasChanged() ||
                        autohide_topedge.hasChanged() ||
                        autohide_anymove.hasChanged() ||
                        autohide_timeout.hasChanged() ||
                        imgchange.hasChanged())

            }

            function load() {

                autohide_always.loadAndSetDefault(!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
                autohide_anymove.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
                autohide_topedge.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHideTopEdge)
                autohide_timeout.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHideTimeout/1000)
                imgchange.loadAndSetDefault(PQCSettings.interfaceStatusInfoShowImageChange)

            }

            function applyChanges() {

                PQCSettings.interfaceStatusInfoAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
                PQCSettings.interfaceStatusInfoAutoHideTopEdge = autohide_topedge.checked
                PQCSettings.interfaceStatusInfoAutoHideTimeout = autohide_timeout.value*1000
                PQCSettings.interfaceStatusInfoShowImageChange = imgchange.checked

                autohide_always.saveDefault()
                autohide_anymove.saveDefault()
                autohide_topedge.saveDefault()
                autohide_timeout.saveDefault()
                imgchange.saveDefault()

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_pos

            //: Settings title
            title: qsTranslate("settingsmanager", "Position")

            helptext: qsTranslate("settingsmanager",  "The status info is typically shown along the top left corner of the window. If preferred, it is also possible to show it centered along the top edge or in the top right corner.")

            content: [
                PQComboBox {
                    id: infoalignment
                    model: ["top left", "top center", "top right"]
                    onCurrentIndexChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                var opts = ["left", "center", "right"]
                infoalignment.currentIndex = Math.max(0, opts.indexOf(PQCSettings.getDefaultForInterfaceStatusInfoPosition()))
            }

            function handleEscape() {
                infoalignment.popup.close()
            }

            function hasChanged() {
                return infoalignment.hasChanged()
            }

            function load() {
                infoalignment.loadAndSetDefault(PQCSettings.interfaceStatusInfoPosition==="center" ? 1 : (PQCSettings.interfaceStatusInfoPosition==="right" ? 2 : 0))
            }

            function applyChanges() {
                var opts = ["left", "center", "right"]
                PQCSettings.interfaceStatusInfoPosition = ""
                PQCSettings.interfaceStatusInfoPosition = opts[infoalignment.currentIndex]
                infoalignment.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_win

            //: Settings title
            title: qsTranslate("settingsmanager", "Window management")

            helptext: qsTranslate("settingsmanager",  "By default it is possible to drag the status info around as desired. However, it is also possible to use the status info for managing the window itself. When enabled, dragging the status info will drag the window around, and double clicking the status info will toggle the maximized status of the window.")

            content: [
                PQCheckBox {
                    id: managewindow
                    enforceMaxWidth: set_hide.rightcol
                    text: qsTranslate("settingsmanager",  "manage window through status info")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                managewindow.checked = PQCSettings.getDefaultForInterfaceStatusInfoManageWindow()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return managewindow.hasChanged()
            }

            function load() {
                managewindow.loadAndSetDefault(PQCSettings.interfaceStatusInfoManageWindow)
            }

            function applyChanges() {
                PQCSettings.interfaceStatusInfoManageWindow = managewindow.checked
                managewindow.saveDefault()
            }

        }

        /**********************************************************************/

        Item {
            width: 1
            height: 1
        }


    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_status.handleEscape()
        set_hide.handleEscape()
        set_pos.handleEscape()
        set_win.handleEscape()
    }

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

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        settingChanged = (set_status.hasChanged() || set_hide.hasChanged() ||
                          set_pos.hasChanged() || set_win.hasChanged())

    }

    function load() {

        set_status.load()
        set_hide.load()
        set_pos.load()
        set_win.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_status.applyChanges()
        set_hide.applyChanges()
        set_pos.applyChanges()
        set_win.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
