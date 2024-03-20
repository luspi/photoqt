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
import PQCNotify

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfaceStatusInfoList
// - interfaceStatusInfoShow
// - interfaceStatusInfoFontSize
// - interfaceStatusInfoAutoHide
// - interfaceStatusInfoAutoHideTimeout
// - interfaceStatusInfoAutoHideTopEdge
// - interfaceStatusInfoShowImageChange
// - interfaceStatusInfoManageWindow

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Status info")

            helptext: qsTranslate("settingsmanager",  "The status information refers to the set of information shown in the top left corner of the screen. This typically includes the filename of the currently viewed image and information like the zoom level, rotation angle, etc. The exact set of information and their order can be adjusted as desired.")

            content: [

                PQCheckBox {
                    id: status_show
                    text: qsTranslate("settingsmanager", "show status information")
                    onCheckedChanged: checkDefault()
                },

                Rectangle {
                    enabled: status_show.checked
                    Behavior on opacity { NumberAnimation { duration: 200 } }
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

                        property var widths: []

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
                            "filesize": qsTranslate("settingsmanager", "filesize")
                        }

                        model: ListModel {
                            id: model
                        }

                        delegate: Item {
                            id: deleg
                            width: Math.max.apply(Math, avail.widths)
                            height: avail.height-(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)

                            Rectangle {
                                id: dragRect
                                width: deleg.width
                                height: deleg.height
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: PQCLook.baseColorActive
                                radius: 5
                                PQText {
                                    id: txt
                                    x: (parent.width-width)/2
                                    y: (parent.height-height)/2
                                    text: avail.disp[name]
                                    font.weight: PQCLook.fontWeightBold
                                    color: PQCLook.textColorActive
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
                                            avail.dragItemIndex = index;
                                        }
                                        dragRect.Drag.drop();
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

                                    source: "image://svg/:/white/close.svg"
                                    sourceSize: Qt.size(width, height)

                                    opacity: closemouse.containsMouse ? 0.8 : 0.2
                                    Behavior on opacity { NumberAnimation { duration: 150 } }

                                    PQMouseArea {
                                        id: closemouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: {
                                            avail.model.remove(index, 1)
                                            checkDefault()
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
                                avail.model.move(avail.dragItemIndex, newindex, 1)
                                avail.dragItemIndex = newindex
                                checkDefault()
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
                        property var data: [
                            //: Please keep short! The counter shows where we are in the folder.
                            ["counter", qsTranslate("settingsmanager", "counter")],
                            //: Please keep short!
                            ["filename", qsTranslate("settingsmanager", "filename")],
                            //: Please keep short!
                            ["filepathname", qsTranslate("settingsmanager", "filepath")],
                            //: Please keep short! This is the image resolution.
                            ["resolution", qsTranslate("settingsmanager", "resolution")],
                            //: Please keep short! This is the current zoom level.
                            ["zoom", qsTranslate("settingsmanager", "zoom")],
                            //: Please keep short! This is the rotation of the current image
                            ["rotation", qsTranslate("settingsmanager", "rotation")],
                            //: Please keep short! This is the filesize of the current image.
                            ["filesize", qsTranslate("settingsmanager", "filesize")]
                        ]
                        property var modeldata: []
                        model: modeldata
                        Component.onCompleted: {
                            var tmp = []
                            for(var i = 0; i < data.length; ++i)
                                tmp.push(data[i][1])
                            modeldata = tmp
                        }
                    }
                    PQButton {
                        id: but_add
                        //: This is written on a button that is used to add a selected block to the status info section.
                        text: qsTranslate("settingsmanager", "add")
                        smallerVersion: true
                        onClicked: {
                            model.append({name: combo_add.data[combo_add.currentIndex][0]})
                            checkDefault()
                        }
                    }
                },

                Row {

                    id: sizerow

                    spacing: 10

                    enabled: status_show.checked
                    height: enabled ? fontsize.height : 0
                    opacity: enabled ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQText {
                        y: (parent.height-height)/2
                        //: This is the size of the integrated window buttons.
                        text: qsTranslate("settingsmanager", "Font size:")
                    }

                    Rectangle {

                        width: fontsize.width
                        height: fontsize.height
                        color: PQCLook.baseColorHighlight

                        PQSpinBox {
                            id: fontsize
                            from: 5
                            to: 100
                            width: 120
                            onValueChanged: checkDefault()
                            visible: !fontsize_val.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: fontsize_val
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: fontsize.value + " px"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    fontsize_val.visible = false
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
                        visible: !fontsize_val.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            fontsize_val.visible = true
                        }
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Hide automatically")

            helptext: qsTranslate("settingsmanager",  "The status info can either be shown at all times, or it can be hidden automatically based on different criteria. It can either be hidden unless the mouse cursor is near the top edge of the screen or until the mouse cursor is moved anywhere. After a specified timeout it will then hide again. In addition to these criteria, it can also be shown shortly whenever the image changes.")

            content: [
                PQRadioButton {
                    id: autohide_always
                    //: visibility status of the status information
                    text: qsTranslate("settingsmanager", "keep always visible")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: autohide_anymove
                    //: visibility status of the status information
                    text: qsTranslate("settingsmanager", "only show with any cursor move")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: autohide_topedge
                    //: visibility status of the status information
                    text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                    onCheckedChanged: checkDefault()
                },


                Row {

                    spacing: 10

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
                            visible: !autohide_timeout_val.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: autohide_timeout_val
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: autohide_timeout.value + " s"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    autohide_timeout_val.visible = false
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
                        visible: !autohide_timeout_val.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            autohide_timeout_val.visible = true
                        }
                    }

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
                        //: Refers to the status information's auto-hide feature, this is an additional case it can be shown
                        text: qsTranslate("settingsmanager", "also show when image changes")
                        onCheckedChanged: checkDefault()
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Window management")

            helptext: qsTranslate("settingsmanager",  "By default it is possible to drag the status info around as desired. However, it is also possible to use the status info for managing the window itself. When enabled, dragging the status info will drag the window around, and double clicking the status info will toggle the maximized status of the window.")

            content: [
                PQCheckBox {
                    id: managewindow
                    text: qsTranslate("settingsmanager",  "manage window through status info")
                    onCheckedChanged: checkDefault()
                }
            ]

        }

        /**********************************************************************/

        Item {
            width: 1
            height: 1
        }


    }

    Component.onCompleted:
        load()

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

        if(status_show.checked !== PQCSettings.interfaceStatusInfoShow) {
            settingChanged = true
            return
        }

        var opts = []
        for(var i = 0; i < model.count; ++i)
            opts.push(model.get(i).name)

        if(!areTwoListsEqual(opts, PQCSettings.interfaceStatusInfoList)) {
            settingChanged = true
            return
        }

        if(fontsize.hasChanged() || autohide_always.hasChanged() || autohide_topedge.hasChanged() || autohide_anymove.hasChanged() || autohide_timeout.hasChanged()) {
            settingChanged = true
            return
        }

        if(imgchange.hasChanged() || managewindow.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        status_show.checked = PQCSettings.interfaceStatusInfoShow

        model.clear()
        var setprops = PQCSettings.interfaceStatusInfoList
        for(var j = 0; j < setprops.length; ++j)
            model.append({name: setprops[j]})

        fontsize.loadAndSetDefault(PQCSettings.interfaceStatusInfoFontSize)

        autohide_always.loadAndSetDefault(!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
        autohide_anymove.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
        autohide_topedge.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHideTopEdge)
        autohide_timeout.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHideTimeout/1000)

        imgchange.loadAndSetDefault(PQCSettings.interfaceStatusInfoShowImageChange)
        managewindow.loadAndSetDefault(PQCSettings.interfaceStatusInfoManageWindow)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceStatusInfoShow = status_show.checked

        var opts = []
        for(var i = 0; i < model.count; ++i)
            opts.push(model.get(i).name)
        PQCSettings.interfaceStatusInfoList = opts

        PQCSettings.interfaceStatusInfoFontSize = fontsize.value
        PQCSettings.interfaceStatusInfoAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
        PQCSettings.interfaceStatusInfoAutoHideTopEdge = autohide_topedge.checked
        PQCSettings.interfaceStatusInfoAutoHideTimeout = autohide_timeout.value.toFixed(1)*1000
        PQCSettings.interfaceStatusInfoShowImageChange = imgchange.checked
        PQCSettings.interfaceStatusInfoManageWindow = managewindow.checked

        fontsize.saveDefault()
        autohide_always.saveDefault()
        autohide_anymove.saveDefault()
        autohide_topedge.saveDefault()
        autohide_timeout.saveDefault()

        imgchange.saveDefault()
        managewindow.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
