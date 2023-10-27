import QtQuick
import QtQuick.Controls

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

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_interface", "Status info")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_interface",  "The status information refers to the set of information shown in the top right corner of the screen. This typically includes the filename of the currently viewed image and information like the zoom level, rotation angle, etc. The exact set of information and their order can be adjusted as desired.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: status_show
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_interface", "show status information")
            onCheckedChanged: checkDefault()
        }

        Rectangle {
            enabled: status_show.checked
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            width: setting_top.width
            height: 60+(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)
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
                    "counter": qsTranslate("settingsmanager_interface", "counter"),
                    //: Please keep short!
                    "filename": qsTranslate("settingsmanager_interface", "filename"),
                    //: Please keep short!
                    "filepathname": qsTranslate("settingsmanager_interface", "filepath"),
                    //: Please keep short! This is the image resolution.
                    "resolution": qsTranslate("settingsmanager_interface", "resolution"),
                    //: Please keep short! This is the current zoom level.
                    "zoom": qsTranslate("settingsmanager_interface", "zoom"),
                    //: Please keep short! This is the rotation of the current image
                    "rotation": qsTranslate("settingsmanager_interface", "rotation"),
                    //: Please keep short! This is the filesize of the current image.
                    "filesize": qsTranslate("settingsmanager_interface", "filesize")
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

                            source: "/white/close.svg"
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
        }

        Row {
            x: (parent.width-width)/2
            enabled: status_show.checked
            spacing: 10
            PQComboBox {
                id: combo_add
                y: (but_add.height-height)/2
                property var data: [
                    //: Please keep short! The counter shows where we are in the folder.
                    ["counter", qsTranslate("settingsmanager_interface", "counter")],
                    //: Please keep short!
                    ["filename", qsTranslate("settingsmanager_interface", "filename")],
                    //: Please keep short!
                    ["filepathname", qsTranslate("settingsmanager_interface", "filepath")],
                    //: Please keep short! This is the image resolution.
                    ["resolution", qsTranslate("settingsmanager_interface", "resolution")],
                    //: Please keep short! This is the current zoom level.
                    ["zoom", qsTranslate("settingsmanager_interface", "zoom")],
                    //: Please keep short! This is the rotation of the current image
                    ["rotation", qsTranslate("settingsmanager_interface", "rotation")],
                    //: Please keep short! This is the filesize of the current image.
                    ["filesize", qsTranslate("settingsmanager_interface", "filesize")]
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
                text: qsTranslate("settingsmanager_interface", "add")
                onClicked: {
                    model.append({name: combo_add.data[combo_add.currentIndex][0]})
                    checkDefault()
                }
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title, the font sized of the status information
            text: qsTranslate("settingsmanager_interface", "Font size")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_interface",  "The size of the status info is determined by the font size of the text.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                y: (fontsize.height-height)/2
                text: fontsize.from+"pt"
            }
            PQSlider {
                id: fontsize
                extraWide: true
                from: 5
                to: 30
                onValueChanged: checkDefault()
            }
            PQText {
                y: (fontsize.height-height)/2
                text: fontsize.to+"pt"
            }
        }
        PQText {
            x: (parent.width-width)/2
            //: The current value of the slider specifying the font size for the status information
            text: qsTranslate("settingsmanager_interface", "current value:") + " " + fontsize.value + "pt"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_interface", "Hide automatically")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_interface",  "The status info can either be shown at all times, or it can be hidden automatically based on different criteria. It can either be hidden unless the mouse cursor is near the top edge of the screen or until the mouse cursor is moved anywhere. After a specified timeout it will hide again. In addition to these criteria, it can also be shown shortly whenever the image changes.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            PQRadioButton {
                id: autohide_always
                //: visibility status of the status information
                text: qsTranslate("settingsmanager_interface", "keep always visible")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: autohide_anymove
                //: visibility status of the status information
                text: qsTranslate("settingsmanager_interface", "only show with any cursor move")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: autohide_topedge
                //: visibility status of the status information
                text: qsTranslate("settingsmanager_interface", "only show when cursor near top edge")
                onCheckedChanged: checkDefault()
            }

        }

        PQText {
            enabled: !autohide_always.checked
            x: (parent.width-width)/2
            //: the status information can be hidden automatically after a set timeout
            text: qsTranslate("settingsmanager_interface", "hide again after timeout:")
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                enabled: !autohide_always.checked
                y: (autohide_timeout.height-height)/2
                text: autohide_timeout.from+"s"
            }
            PQSlider {
                id: autohide_timeout
                enabled: !autohide_always.checked
                from: 0
                to: 5
                stepSize: 0.1
                wheelStepSize: 0.1
                onValueChanged: checkDefault()
            }
            PQText {
                enabled: !autohide_always.checked
                y: (autohide_timeout.height-height)/2
                text: autohide_timeout.to+"s"
            }
        }
        PQText {
            enabled: !autohide_always.checked
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_interface", "current value:") + " " + autohide_timeout.value.toFixed(1) + "s"
        }

        PQCheckBox {
            id: imgchange
            x: (parent.width-width)/2
            enabled: !autohide_always.checked
            //: Refers to the status information's auto-hide feature, this is an additional case it can be shown
            text: qsTranslate("settingsmanager_interface", "also show when image changes")
            onCheckedChanged: checkDefault()
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

        if(fontsize.value !== PQCSettings.interfaceStatusInfoFontSize) {
            settingChanged = true
            return
        }

        if(autohide_topedge.checked && !PQCSettings.interfaceStatusInfoAutoHideTopEdge) {
            settingChanged = true
            return
        }
        if(autohide_anymove.checked && (!PQCSettings.interfaceStatusInfoAutoHide || PQCSettings.interfaceStatusInfoAutoHideTopEdge)) {
            settingChanged = true
            return
        }
        if(autohide_always.checked && (PQCSettings.interfaceStatusInfoAutoHide || PQCSettings.interfaceStatusInfoAutoHideTopEdge)) {
            settingChanged = true
            return
        }

        if(autohide_timeout.value.toFixed(1) !== (PQCSettings.interfaceStatusInfoAutoHideTimeout/1000).toFixed(1)) {
            settingChanged = true
            return
        }

        if(imgchange.checked !== PQCSettings.interfaceStatusInfoShowImageChange) {
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

        fontsize.value = PQCSettings.interfaceStatusInfoFontSize

        autohide_always.checked = !PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge
        autohide_anymove.checked = PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge
        autohide_topedge.checked = PQCSettings.interfaceStatusInfoAutoHideTopEdge
        autohide_timeout.value = PQCSettings.interfaceStatusInfoAutoHideTimeout/1000

        imgchange.checked = PQCSettings.interfaceStatusInfoShowImageChange

        settingChanged = false

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

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
