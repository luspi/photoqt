/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import PhotoQt

PQSetting {

    id: set_fity

    disabledAutoIndentation: true
    addBlankSpaceBottom: false

    property string defaultSettings: ""

    content: [

        Column {

            id: topcol

            spacing: 10

            Flow {

                id: butrow

                spacing: 10

                width: set_fity.contentWidth

                PQComboBox {
                    id: catCombo
                                                      //: This is a category of files PhotoQt can recognize: any image format
                    property list<string> modeldata: [qsTranslate("settingsmanager", "images"),
                                                      //: This is a category of files PhotoQt can recognize: compressed files like zip, tar, cbr, 7z, etc.
                                                      qsTranslate("settingsmanager", "compressed files")+" (zip, cbr, ...)",
                                                      //: This is a category of files PhotoQt can recognize: documents like pdf, txt, etc.
                                                      qsTranslate("settingsmanager", "documents")+" (pdf, txt, ...)",
                                                      //: This is a type of category of files PhotoQt can recognize: videos like mp4, avi, etc.
                                                      qsTranslate("settingsmanager", "videos")]
                    model: modeldata
                }

                PQButton {
                    id: enableBut
                    //: As in: "Enable all formats in the seleted category of file types"
                    text: qsTranslate("settingsmanager", "Enable")
                    onClicked:
                        butrow.checkUncheck(1)
                }
                PQButton {
                    id: disableBut
                    //: As in: "Disable all formats in the seleted category of file types"
                    text: qsTranslate("settingsmanager", "Disable")
                    onClicked:
                        butrow.checkUncheck(0)
                }

                function checkUncheck(checked : bool) {
                    if(catCombo.currentIndex === 0)
                        set_fity.checkImg(checked)
                    else if(catCombo.currentIndex === 1)
                        set_fity.checkPac(checked)
                    else if(catCombo.currentIndex === 2)
                        set_fity.checkDoc(checked)
                    else if(catCombo.currentIndex === 3)
                        set_fity.checkVid(checked)
                    else
                        console.warn("Error: Unknown category selected:", catCombo.currentText)
                }

                Item {
                    width: 10
                    height: 1
                }

                PQButton {
                    id: enableallBut
                    //: As in "Enable every single file format PhotoQt can open in any category"
                    text: qsTranslate("settingsmanager", "Enable everything")
                    onClicked: {
                        set_fity.checkAll()
                    }
                }

            }

            PQText {
                id: countEnabled
                property int num: 0
                //: The %1 will be replaced with the number of file formats, please don't forget to add it.
                text:  qsTranslate("settingsmanager", "Currently there are %1 file formats enabled").arg("<b>"+num+"</b>")
                // Connections {
                //     target: listview
                //     function onFtChanged() {
                //         countEnabled.countFormats()
                //     }
                // }
                // Component.onCompleted: {
                //     countEnabled.countFormats()
                // }
                // function countFormats() {
                //     var c = 0
                //     for(var i = 0; i< listview.ft.length; ++i)
                //         if(listview.ft[i][1] === 1) c += 1
                //     countEnabled.num = c
                // }
            }

            Item {
                width: 1
                height: 1
            }

            Row {
                spacing: 10

                PQLineEdit {
                    id: filter_desc
                    width: set_fity.contentWidth/2 -5
                    placeholderText: qsTranslate("settingsmanager", "Search by description or file ending")
                    // Keys.onTabPressed: (event) => {
                    //     PQCNotify.loaderPassOn("keyEvent", [event.key, event.modifiers])
                    // }
                    // onPressed: (key, modifiers) => {
                    //    if(key === Qt.Key_S && modifiers === Qt.ControlModifier)
                    //         PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                    //     else if(key === Qt.Key_R && modifiers === Qt.ControlModifier)
                    //         PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                    // }
                }

                PQLineEdit {
                    id: filter_lib
                    width: set_fity.contentWidth/2 -5
                    placeholderText: qsTranslate("settingsmanager", "Search by image library or category")
                    // Keys.onTabPressed: (event) => {
                    //     PQCNotify.loaderPassOn("keyEvent", [event.key, event.modifiers])
                    // }
                    // onPressed: (key, modifiers) => {
                    //     if(key === Qt.Key_S && modifiers === Qt.ControlModifier)
                    //         PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                    //     else if(key === Qt.Key_R && modifiers === Qt.ControlModifier)
                    //         PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                    // }
                }
            }

        },

        PQText {
            id: warn_width
            text: qsTranslate("settingsmanager", "Increase the window size for better seeing all the details.")
            width: set_fity.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "red"
            visible: width < 600
        },

        ListView {

            id: listview

            width: set_fity.contentWidth
            height: set_fity.availableHeight - topcol.height - set_fity.contentSpacing - 10 - (warn_width.visible ? (warn_width.height+10) : 0)

            clip: true

            property list<string> entries: []

            property list<string> plugins: []
            property var entry2status: ({})
            property var entry2plugins: ({})

            model: entries.length

            delegate: Rectangle {

                id: deleg

                required property int modelData
                property string entry: listview.entries[deleg.modelData]
                property list<int> entrystatus: listview.entry2status[entry]
                property list<string> supportedPlugins: listview.entry2plugins[entry]

                width: listview.width
                height: 50
                color: palette.alternateBase
                Rectangle {
                    width: parent.width
                    height: 1
                    y: parent.height-height
                    color: PQCLook.baseBorder
                }

                Row {

                    x: 10
                    y: (parent.height-height)/2

                    spacing: 10

                    PQCheckBox {
                        id: formatcheck
                        y: (parent.height-height)/2
                        width: (listview.width-30)/3
                        text: deleg.entry
                        elide: Text.ElideMiddle
                        opacity: (checkState != Qt.Unchecked) ? 1 : 0.5
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 100 } }
                        tristate: true
                        checkState: deleg.supportedPlugins.length===pluginrow.howManyEnabled ? Qt.Checked : pluginrow.howManyEnabled>0 ? Qt.PartiallyChecked : Qt.Unchecked
                        nextCheckState: function() {
                            if(checkState == Qt.Checked) {
                                pluginrow.checkAll(false)
                                return Qt.Unchecked
                            } else {
                                pluginrow.checkAll(true)
                                return Qt.Checked
                            }
                        }
                    }

                    Row {
                        id: pluginrow

                        y: (parent.height-height)/2
                        width: 2*(listview.width-20)/3
                        spacing: 0

                        opacity: (formatcheck.checkState != Qt.Unchecked) ? 1 : 0.5
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 100 } }

                        property int allunits: 0

                        property int howManyEnabled: 0

                        signal checkAll(var check)

                        Repeater {
                            model: listview.plugins.length
                            Item {

                                id: butdeleg

                                required property int modelData

                                enabled: deleg.supportedPlugins.indexOf(plugin)>-1
                                opacity: enabled ? 1 : 0.2

                                property int units: Math.max(5, buttxt.text.length)
                                onUnitsChanged:
                                    pluginrow.allunits += units

                                property string plugin: listview.plugins[modelData]

                                width: units * (pluginrow.width/pluginrow.allunits)
                                height: deleg.height

                                property bool hovered: butmouse.containsMouse
                                property bool checked: deleg.entrystatus[modelData]

                                onCheckedChanged:
                                    pluginrow.howManyEnabled += (checked ? 1 : -1)

                                Connections {
                                    target: pluginrow
                                    function onCheckAll(check : bool) {
                                        if(butdeleg.enabled) butdeleg.checked = check
                                    }
                                }

                                Rectangle {
                                    id: mainbut
                                    height: parent.height
                                    width: parent.width
                                    color: palette.alternateBase
                                    border.width: 1
                                    border.color: PQCLook.baseBorder
                                    PQText {
                                        id:  buttxt
                                        width: parent.width
                                        height: parent.height
                                        font.pointSize: pluginrow.width/listview.plugins.length < 50 ? PQCLook.fontSizeS : PQCLook.fontSize
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideMiddle
                                        verticalAlignment: Text.AlignVCenter
                                        text: butdeleg.plugin
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    opacity: (formatcheck.checkState != Qt.Unchecked) ? 1 : 0.5
                                    radius: 10
                                    color: "transparent"
                                    visible: butdeleg.enabled
                                    border.width: 1
                                    border.color: butdeleg.checked ? "green" : "red"
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        opacity: 0.3
                                        color: butdeleg.checked ? "green" : "red"
                                    }
                                }

                                PQMouseArea {

                                    id: butmouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    text: butdeleg.enabled ? buttxt.text : qsTranslate("settingsmanager", "format not supported by this plugin")

                                    onClicked:
                                        butdeleg.checked = !butdeleg.checked

                                }

                            }

                        }

                    }
                }
            }

        }

    ]

    function checkAll() {
        checkImg(true)
        checkPac(true)
        checkDoc(true)
        checkVid(true)
    }

    function checkImg(checked: bool) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "img" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function checkPac(checked: bool) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "pac" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function checkDoc(checked: bool) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "doc" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function checkVid(checked: bool) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "vid" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function composeChecker() {
        var str = ""
        for(var e in listview.ft) {
            str += listview.ft[e][1].toString()
        }
        return str
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        var chk = composeChecker()
        PQCConstants.settingsManagerSettingChanged = (chk !== defaultSettings)

    }

    function load() {

        settingsLoaded = false

        listview.entries = []

        var descs = PQCImageHandler.getAllDescriptions()
        var plugins = PQCImageHandler.getPluginNames()
        var stat = ({})
        var pluginstat = ({})
        for(var iD in descs) {
            var d = descs[iD]
            if(d in stat) continue;
            var supported = PQCImageHandler.getPluginsForFormatByDescription(d)
            var cur = []
            for(var iPl in plugins) {
                cur.push(PQCImageHandler.isEnabled(plugins[iPl], d) ? 1 : 0)
            }
            stat[d] = cur
            pluginstat[d] = supported
        }
        listview.plugins = plugins
        listview.entry2status = stat
        listview.entry2plugins = pluginstat
        listview.entries = descs

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        // TODO
        // PQCImageFormats.setAllFormats(listview.ft)
        defaultSettings = composeChecker()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
