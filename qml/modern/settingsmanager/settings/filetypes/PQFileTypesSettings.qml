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
import PQCImageFormats
import PhotoQt.Modern

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - all file types

Item {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: enableBut.contextmenu.visible || disableBut.contextmenu.visible ||
                               enableallBut.contextmenu.visible || catCombo.popup.visible

    property string defaultSettings: ""

    Column {

        Column {

            id: topcol

            spacing: 10

            Flow {

                id: butrow

                spacing: 10

                width: setting_top.width

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
                        setting_top.checkImg(checked)
                    else if(catCombo.currentIndex === 1)
                        setting_top.checkPac(checked)
                    else if(catCombo.currentIndex === 2)
                        setting_top.checkDoc(checked)
                    else if(catCombo.currentIndex === 3)
                        setting_top.checkVid(checked)
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
                        setting_top.checkAll()
                    }
                }

            }

            PQText {
                id: countEnabled
                property int num: 0
                //: The %1 will be replaced with the number of file formats, please don't forget to add it.
                text:  qsTranslate("settingsmanager", "Currently there are %1 file formats enabled").arg("<b>"+num+"</b>")
                Connections {
                    target: listview
                    function onFtChanged() {
                        countEnabled.countFormats()
                    }
                }
                Component.onCompleted: {
                    countEnabled.countFormats()
                }
                function countFormats() {
                    var c = 0
                    for(var i = 0; i< listview.ft.length; ++i)
                        if(listview.ft[i][1] === 1) c += 1
                    countEnabled.num = c
                }
            }

            Item {
                width: 1
                height: 1
            }

            Row {
                spacing: 10

                PQLineEdit {
                    id: filter_desc
                    width: setting_top.width/2
                    placeholderText: qsTranslate("settingsmanager", "Search by description or file ending")
                    Keys.onTabPressed: (event) => {
                        PQCNotify.loaderPassOn("keyEvent", [event.key, event.modifiers])
                    }
                    onPressed: (key, modifiers) => {
                       if(key === Qt.Key_S && modifiers === Qt.ControlModifier)
                            PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                        else if(key === Qt.Key_R && modifiers === Qt.ControlModifier)
                            PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                    }
                }

                PQLineEdit {
                    id: filter_lib
                    width: setting_top.width/2 -20
                    placeholderText: qsTranslate("settingsmanager", "Search by image library or category")
                    Keys.onTabPressed: (event) => {
                        PQCNotify.loaderPassOn("keyEvent", [event.key, event.modifiers])
                    }
                    onPressed: (key, modifiers) => {
                        if(key === Qt.Key_S && modifiers === Qt.ControlModifier)
                            PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                        else if(key === Qt.Key_R && modifiers === Qt.ControlModifier)
                            PQCNotify.loaderPassOn("keyEvent", [key, modifiers])
                    }
                }
            }

        }

        PQSettingsSeparator {}

        ListView {

            id: listview

            width: setting_top.width
            height: setting_top.height-topcol.height

            property list<var> ft: []
            onFtChanged:
                setting_top.checkDefault()

            clip: true

            model: ft.length

            ScrollBar.vertical: PQVerticalScrollBar {}

            PQScrollManager { flickable: listview }

            delegate:
                Rectangle {

                    id: entry_rect

                    required property int modelData

                    width: setting_top.width

                    clip: true

                    property bool filterPass: true
                    height: filterPass ? 50 : 0
                    Behavior on height { NumberAnimation { duration: 50 } }

                    color: entry_rect.modelData%2==0 ? PQCLook.baseColorAccent : PQCLook.baseColor 
                    visible: height > 0

                    PQCheckBox {
                        id: checkenable
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        checked: listview.ft[entry_rect.modelData][1]
                        onClicked: {
                            listview.ft[entry_rect.modelData][1] = (listview.ft[entry_rect.modelData][1]+1)%2
                            listview.ftChanged()
                        }
                    }

                    PQText {
                        id: entry_desc
                        anchors {
                            left: checkenable.right
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        elide: Text.ElideRight
                        width: entry_rect.width/2 - checkenable.width-10
                        verticalAlignment: Text.AlignVCenter
                        text: "<b>" + listview.ft[entry_rect.modelData][2] + "</b> &nbsp;&nbsp; *." + listview.ft[entry_rect.modelData][0].split(",").join(", *.")
                        opacity: checkenable.checked ? 1 : 0.3
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        textFormat: Text.StyledText
                    }

                    PQText {
                        id: entry_libs
                        anchors {
                            left: entry_desc.right
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: entry_rect.width/2-10
                        verticalAlignment: Text.AlignVCenter
                        text: listview.ft[entry_rect.modelData].slice(4).join(", ")
                        opacity: checkenable.checked ? 1 : 0.3
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            listview.ft[entry_rect.modelData][1] = (listview.ft[entry_rect.modelData][1]+1)%2
                            listview.ftChanged()
                        }
                        text: "<b>" + qsTranslate("settingsmanager", "File endings:") + "</b> *." + listview.ft[entry_rect.modelData][0].split(",").join(", *.")
                    }

                    function filterItem() : void {

                        var desc_pass = false
                        if(filter_desc.text === "" ||
                                entry_desc.text.toLowerCase().indexOf(filter_desc.text.toLowerCase()) !== -1 ||
                                listview.ft[entry_rect.modelData][0].toLowerCase().indexOf(filter_desc.text.toLowerCase()) !== -1) {
                            desc_pass = true
                        }

                        var lib_pass = false
                        if(filter_lib.text === "" ||
                                entry_libs.text.toLowerCase().indexOf(filter_lib.text.toLowerCase()) !== -1) {
                            lib_pass = true
                        }

                        entry_rect.filterPass = (desc_pass && lib_pass)

                    }

                    Connections {
                        target: filter_desc
                        function onTextChanged() {
                            entry_rect.filterItem()
                        }
                    }

                    Connections {
                        target: filter_lib
                        function onTextChanged() {
                            entry_rect.filterItem()
                        }
                    }

                    // this is needed as not all items might be set up as they are too far outside the view
                    // thus they wont be able to respond to the above signals
                    Component.onCompleted:
                        entry_rect.filterItem()

                }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        enableBut.contextmenu.close()
        disableBut.contextmenu.close()
        enableallBut.contextmenu.close()
        catCombo.popup.close()
    }

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

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        var chk = composeChecker()
        settingChanged = (chk !== defaultSettings)
    }

    function load() {
        listview.ft = PQCImageFormats.getAllFormats() 
        defaultSettings = composeChecker()
        settingChanged = false
        settingsLoaded = true
    }

    function applyChanges() {
        PQCImageFormats.setAllFormats(listview.ft) 
        defaultSettings = composeChecker()
        settingChanged = false
    }

    function revertChanges() {
        load()
    }

}
