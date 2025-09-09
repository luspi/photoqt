/**************************************************************************
 * *                                                                      **
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
import PhotoQt.CPlusPlus
import "../../other/PQCommonFunctions.js" as PQF
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_stin

    SystemPalette { id: pqtPalette }

    property list<string> curEntries: []

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Status info")

            helptext: qsTranslate("settingsmanager", "The status information refers to the set of information shown in the top left corner of the screen. This typically includes the filename of the currently viewed image and information like the zoom level, rotation angle, etc. The exact set of information and their order can be adjusted as desired.")

        },

        Column {

            spacing: set_stin.contentSpacing

            PQCheckBox {
                id: status_show
                enforceMaxWidth: set_stin.contentWidth
                text: qsTranslate("settingsmanager", "show status information")
                onCheckedChanged: set_stin.checkForChanges()
            }

            Rectangle {
                enabled: status_show.checked
                width: set_stin.contentWidth-5
                radius: 5
                clip: true

                height: (60+(scrollbar.size<1.0 ? (scrollbar.height+5) : 0))

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
                        id: themodel
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
                                        set_stin.populateModel()
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
                                        parent: set_stin.parent
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
                                        set_stin.curEntries.splice(deleg.index, 1)
                                        set_stin.populateModel()
                                        set_stin.checkForChanges()
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
                            var element = set_stin.curEntries[avail.dragItemIndex];
                            set_stin.curEntries.splice(avail.dragItemIndex, 1);
                            set_stin.curEntries.splice(newindex, 0, element);

                            avail.model.move(avail.dragItemIndex, newindex, 1)
                            avail.dragItemIndex = newindex
                            set_stin.checkForChanges()
                        }
                    }
                }
            }

            Row {
                enabled: status_show.checked
                spacing: 10

                height: combo_add.height

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
                        set_stin.curEntries.push(combo_add.statusdata_keys[combo_add.currentIndex])
                        set_stin.populateModel()
                        set_stin.checkForChanges()
                    }
                }
            }

            PQSliderSpinBox {
                id: fontsize
                width: set_stin.contentWidth
                visible: set_stin.modernInterface
                minval: 5
                maxval: 30
                title: qsTranslate("settingsmanager", "Font size:")
                suffix: " pt"
                enabled: status_show.checked
                animateHeight: true
                onValueChanged:
                    set_stin.checkForChanges()
            }

        },

        /*************************************/

        PQSettingSubtitle {

            visible: set_stin.modernInterface

            //: Settings title
            title: qsTranslate("settingsmanager", "Visibility")

            helptext: qsTranslate("settingsmanager",  "The status info can either be shown at all times, or it can be hidden automatically based on different criteria. It can either be hidden unless the mouse cursor is near the top edge of the screen or until the mouse cursor is moved anywhere. After a specified timeout it will then hide again. In addition to these criteria, it can also be shown shortly whenever the image changes.")

        },

        Column {

            spacing: set_stin.contentSpacing
            visible: set_stin.modernInterface

            PQRadioButton {
                id: autohide_always
                enforceMaxWidth: set_stin.contentWidth
                //: visibility status of the status information
                text: qsTranslate("settingsmanager", "keep always visible")
                onCheckedChanged: set_stin.checkForChanges()
            }

            PQRadioButton {
                id: autohide_anymove
                enforceMaxWidth: set_stin.contentWidth
                //: visibility status of the status information
                text: qsTranslate("settingsmanager", "only show with any cursor move")
                onCheckedChanged: set_stin.checkForChanges()
            }

            PQRadioButton {
                id: autohide_topedge
                enforceMaxWidth: set_stin.contentWidth
                //: visibility status of the status information
                text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                onCheckedChanged: set_stin.checkForChanges()
            }

            PQSliderSpinBox {
                id: autohide_timeout
                width: set_stin.contentWidth
                minval: 0
                maxval: 10
                title: qsTranslate("settingsmanager", "hide again after timeout:")
                suffix: " s"
                enabled: !autohide_always.checked
                animateHeight: true
                onValueChanged:
                    set_stin.checkForChanges()
            }

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
                    enforceMaxWidth: set_stin.contentWidth
                    //: Refers to the status information's auto-hide feature, this is an additional case it can be shown
                    text: qsTranslate("settingsmanager", "also show when image changes")
                    onCheckedChanged: set_stin.checkForChanges()
                }

            }

        },

        /*************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Position")

            helptext: qsTranslate("settingsmanager",  "The status info is typically shown along the top left corner of the window. If preferred, it is also possible to show it centered along the top edge or in the top right corner.")

        },

        PQComboBox {
            id: infoalignment
            model: ["top left", "top center", "top right"]
            onCurrentIndexChanged: set_stin.checkForChanges()
        },

        /*************************************/

        PQSettingSubtitle {

            visible: set_stin.modernInterface

            //: Settings title
            title: qsTranslate("settingsmanager", "Window management")

            helptext: qsTranslate("settingsmanager",  "By default it is possible to drag the status info around as desired. However, it is also possible to use the status info for managing the window itself. When enabled, dragging the status info will drag the window around, and double clicking the status info will toggle the maximized status of the window.")

        },

        PQCheckBox {
            id: managewindow
            visible: set_stin.modernInterface
            enforceMaxWidth: set_stin.contentWidth
            text: qsTranslate("settingsmanager",  "manage window through status info")
            onCheckedChanged: set_stin.checkForChanges()
        }

    ]

    function populateModel() {
        themodel.clear()
        for(var j = 0; j < curEntries.length; ++j)
            themodel.append({"name": curEntries[j], "index": j})
    }

    onResetToDefaults: {

        status_show.checked = PQCSettings.getDefaultForInterfaceStatusInfoShow()
        curEntries = PQCSettings.getDefaultForInterfaceStatusInfoList()
        populateModel()
        fontsize.setValue(PQCSettings.getDefaultForInterfaceStatusInfoFontSize())

        var val_hide = PQCSettings.getDefaultForInterfaceStatusInfoAutoHide()
        var val_topedge = PQCSettings.getDefaultForInterfaceStatusInfoAutoHideTopEdge()
        var val_timeout = PQCSettings.getDefaultForInterfaceStatusInfoAutoHideTimeout()/1000
        autohide_always.checked = (val_hide === 0 && val_topedge === 0)
        autohide_anymove.checked = (val_hide === 1 && val_topedge === 0)
        autohide_topedge.checked = (val_topedge === 1)
        autohide_timeout.setValue(val_timeout)
        imgchange.checked = PQCSettings.getDefaultForInterfaceStatusInfoShowImageChange()

        var opts = ["left", "center", "right"]
        infoalignment.currentIndex = Math.max(0, opts.indexOf(PQCSettings.getDefaultForInterfaceStatusInfoPosition()))

        managewindow.checked = PQCSettings.getDefaultForInterfaceStatusInfoManageWindow()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {
        fontsize.acceptValue()
        autohide_timeout.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        PQCConstants.settingsManagerSettingChanged = (status_show.hasChanged() ||
                                                      !PQF.areTwoListsEqual(set_stin.curEntries, PQCSettings.interfaceStatusInfoList) ||
                                                      fontsize.hasChanged()) ||
                                                     (autohide_always.hasChanged() || autohide_topedge.hasChanged() ||
                                                     autohide_anymove.hasChanged() || autohide_timeout.hasChanged() ||
                                                     imgchange.hasChanged()) || infoalignment.hasChanged() ||
                                                      managewindow.hasChanged()

    }

    function load() {

        settingsLoaded = false

        status_show.loadAndSetDefault(PQCSettings.interfaceStatusInfoShow)
        curEntries = PQCSettings.interfaceStatusInfoList
        populateModel()
        fontsize.loadAndSetDefault(PQCSettings.interfaceStatusInfoFontSize)

        autohide_always.loadAndSetDefault(!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
        autohide_anymove.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
        autohide_topedge.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHideTopEdge)
        autohide_timeout.loadAndSetDefault(PQCSettings.interfaceStatusInfoAutoHideTimeout/1000)
        imgchange.loadAndSetDefault(PQCSettings.interfaceStatusInfoShowImageChange)

        infoalignment.loadAndSetDefault(PQCSettings.interfaceStatusInfoPosition==="center" ? 1 : (PQCSettings.interfaceStatusInfoPosition==="right" ? 2 : 0))

        managewindow.loadAndSetDefault(PQCSettings.interfaceStatusInfoManageWindow)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

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

        PQCSettings.interfaceStatusInfoAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
        PQCSettings.interfaceStatusInfoAutoHideTopEdge = autohide_topedge.checked
        PQCSettings.interfaceStatusInfoAutoHideTimeout = autohide_timeout.value*1000
        PQCSettings.interfaceStatusInfoShowImageChange = imgchange.checked

        autohide_always.saveDefault()
        autohide_anymove.saveDefault()
        autohide_topedge.saveDefault()
        autohide_timeout.saveDefault()
        imgchange.saveDefault()

        fontsize.saveDefault()
        status_show.saveDefault()

        var opts2 = ["left", "center", "right"]
        PQCSettings.interfaceStatusInfoPosition = ""
        PQCSettings.interfaceStatusInfoPosition = opts2[infoalignment.currentIndex]
        infoalignment.saveDefault()

        PQCSettings.interfaceStatusInfoManageWindow = managewindow.checked
        managewindow.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
