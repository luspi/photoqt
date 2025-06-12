import QtQuick
import QtQuick.Controls

import PQCScriptsConfig
import PhotoQt

PQSetting {

    id: settop

    //: Settings title
    title: qsTranslate("settingsmanager", "Quick Actions")

    helptext: qsTranslate("settingsmanager",  "The quick actions are some actions that can be performed with a currently viewed image. They allow for quickly performing an action with the mouse with a single click.")

    property list<string> curEntries: []

    signal checkHasChanged()

    content: [

        PQCheckBox {
            id: quick_show
            enforceMaxWidth: settop.rightcol
            text: qsTranslate("settingsmanager", "show quick actions")
            onCheckedChanged: settop.checkHasChanged()
        },

        Rectangle {
            enabled: quick_show.checked
            width: Math.min(parent.width-5, 600)
            radius: 5
            clip: true

            height: enabled ? 600 : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            opacity: enabled ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            color: PQCLook.baseColorHighlight // qmllint disable unqualified
            ListView {

                id: avail

                x: 5
                y: 5

                width: parent.width-10
                height: parent.height-10

                clip: true
                orientation: ListView.Vertical
                spacing: 5

                ScrollBar.vertical: PQVerticalScrollBar { id: scrollbar }

                property int dragItemIndex: -1

                property list<int> heights: []

                property list<int> deleted: []

                property var disp: {
                    "|"           : "["+qsTranslate("quickactions", "separator") + "]",
                    "rename"      : qsTranslate("quickactions", "Rename file"),
                    "copy"        : qsTranslate("quickactions", "Copy file"),
                    "move"        : qsTranslate("quickactions", "Move file"),
                    "delete"      : qsTranslate("quickactions", "Delete file"),
                    "rotateleft"  : qsTranslate("quickactions", "Rotate left"),
                    "rotateright" : qsTranslate("quickactions", "Rotate right"),
                    "mirrorhor"   : qsTranslate("quickactions", "Mirror horizontally"),
                    "mirrorver"   : qsTranslate("quickactions", "Mirror vertically"),
                    "crop"        : qsTranslate("quickactions", "Crop image"),
                    "scale"       : qsTranslate("quickactions", "Scale image"),
                    "tagfaces"    : qsTranslate("quickactions", "Tag faces"),
                    "clipboard"   : qsTranslate("quickactions", "Copy to clipboard"),
                    "export"      : qsTranslate("quickactions", "Export to different format"),
                    "wallpaper"   : qsTranslate("quickactions", "Set as wallpaper"),
                    "qr"          : qsTranslate("quickactions", "Detect/hide QR/barcodes"),
                    "close"       : qsTranslate("quickactions", "Close window"),
                    "quit"        : qsTranslate("quickactions", "Quit")
                }

                model: ListModel {
                    id: model
                }

                delegate: Item {
                    id: deleg
                    width: avail.width-(scrollbar.size<1.0 ? (scrollbar.width+5) : 0)
                    height: Math.max.apply(Math, avail.heights)

                    required property string name
                    required property int index

                    Rectangle {
                        id: dragRect
                        width: deleg.width
                        height: deleg.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: PQCLook.baseColorActive // qmllint disable unqualified
                        radius: 5

                        Item {
                            id: thehandle
                            x: 5
                            height: parent.height
                            width: height/2
                            Row {
                                y: (parent.height-height)/2
                                Repeater {
                                    model: 4
                                    Item {
                                        width: thehandle.width/4
                                        height: thehandle.height/2
                                        Rectangle {
                                            x: (parent.width-width)/2
                                            width: 2
                                            height: parent.height
                                            color: PQCLook.baseColorHighlight
                                        }
                                    }
                                }
                            }
                            PQMouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                drag.target: dragRect
                                drag.axis: Drag.YAxis
                                drag.onActiveChanged: {
                                    if(mouseArea.drag.active) {
                                        avail.dragItemIndex = deleg.index;
                                    }
                                    dragRect.Drag.drop();
                                    if(!mouseArea.drag.active) {
                                        settop.populateModel()
                                    }
                                }
                                cursorShape: Qt.OpenHandCursor
                                onPressed:
                                    cursorShape = Qt.ClosedHandCursor
                                onReleased:
                                    cursorShape = Qt.OpenHandCursor
                            }
                        }

                        PQText {
                            id: txt
                            x: thehandle.width+10 + (parent.width-width-thehandle.width-10)/2
                            y: (parent.height-height)/2
                            text: avail.disp[deleg.name]
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            color: PQCLook.textColor // qmllint disable unqualified
                            onWidthChanged: {
                                avail.heights.push(height+20)
                                avail.heightsChanged()
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

                            x: parent.width-width-5
                            y: (parent.height-height)/2
                            width: 20
                            height: 20

                            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                            sourceSize: Qt.size(width, height)

                            opacity: closemouse.containsMouse ? 0.8 : 0.2
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            PQMouseArea {
                                id: closemouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    settop.curEntries.splice(deleg.index, 1)
                                    settop.populateModel()
                                    settop.checkHasChanged()
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
                        var element = settop.curEntries[avail.dragItemIndex];
                        settop.curEntries.splice(avail.dragItemIndex, 1);
                        settop.curEntries.splice(newindex, 0, element);

                        // visual feedback, move the actual model around
                        avail.model.move(avail.dragItemIndex, newindex, 1)
                        avail.dragItemIndex = newindex
                        settop.checkHasChanged()
                    }
                }
            }
        },

        Row {
            enabled: quick_show.checked
            spacing: 10

            height: enabled ? combo_add.height : 0
            opacity: enabled ? 1 : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQComboBox {
                id: combo_add
                y: (but_add.height-height)/2
                width: 600 - but_add.width - 20
                property list<string> quickdata_keys: [
                    "rename",
                    "copy",
                    "move",
                    "delete",
                    "rotateleft",
                    "rotateright",
                    "mirrorhor",
                    "mirrorver",
                    "crop",
                    "scale",
                    "tagfaces",
                    "clipboard",
                    "export",
                    "wallpaper",
                    "qr",
                    "close",
                    "quit",
                    "|"
                ]
                property list<string> quickdata_vals: [
                    qsTranslate("quickactions", "Rename file"),
                    qsTranslate("quickactions", "Copy file"),
                    qsTranslate("quickactions", "Move file"),
                    qsTranslate("quickactions", "Delete file"),
                    qsTranslate("quickactions", "Rotate left"),
                    qsTranslate("quickactions", "Rotate right"),
                    qsTranslate("quickactions", "Mirror horizontally"),
                    qsTranslate("quickactions", "Mirror vertically"),
                    qsTranslate("quickactions", "Crop image"),
                    qsTranslate("quickactions", "Scale image"),
                    qsTranslate("quickactions", "Tag faces"),
                    qsTranslate("quickactions", "Copy to clipboard"),
                    qsTranslate("quickactions", "Export to different format"),
                    qsTranslate("quickactions", "Set as wallpaper"),
                    qsTranslate("quickactions", "Detect/hide QR/barcodes"),
                    qsTranslate("quickactions", "Close window"),
                    qsTranslate("quickactions", "Quit"),
                    "["+qsTranslate("quickactions", "separator") + "]"
                ]
                model: quickdata_vals
            }
            PQButton {
                id: but_add
                //: This is written on a button that is used to add a selected block to the status info section.
                text: qsTranslate("settingsmanager", "add")
                smallerVersion: true
                onClicked: {
                    settop.curEntries.push(combo_add.quickdata_keys[combo_add.currentIndex])
                    settop.populateModel()
                    settop.checkHasChanged()
                }
            }
        }

    ]

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

    onResetToDefaults: {

        quick_show.checked = (1*PQCScriptsConfig.getDefaultSettingValueFor("interfaceQuickActions") == 1) // qmllint disable unqualified

        settop.curEntries = PQCScriptsConfig.getDefaultSettingValueFor("interfaceQuickActionsItems")
        populateModel()

        // this is needed to check for model changes
        settop.checkHasChanged()

    }

    function handleEscape() {
        but_add.contextmenu.close()
        combo_add.popup.close()
    }

    function hasChanged() {
        return (quick_show.hasChanged() ||
                !settop.areTwoListsEqual(settop.curEntries, PQCSettings.extensions.QuickActionsItems))
    }

    function load() {

        quick_show.loadAndSetDefault(PQCSettings.extensions.QuickActions)

        settop.curEntries = PQCSettings.extensions.QuickActionsItems
        populateModel()

    }

    function applyChanges() {

        PQCSettings.extensions.QuickActions = quick_show.checked

        var opts = []
        for(var i = 0; i < model.count; ++i)
            opts.push(model.get(i).name)
        PQCSettings.extensions.QuickActionsItems = opts

        if(quick_show.checked)
            PQCNotify.loaderShowExtension("quickactions")

        quick_show.saveDefault()

    }

    function populateModel() {
        model.clear()
        for(var j = 0; j < settop.curEntries.length; ++j)
            model.append({"name": settop.curEntries[j], "index": j})
    }

}
