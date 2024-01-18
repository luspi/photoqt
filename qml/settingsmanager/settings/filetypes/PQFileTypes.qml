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

import PQCImageFormats
import PQCNotify

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - all file types

Item {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    property bool settingChanged: false

    property string defaultSettings: ""

    Column {

        Column {

            id: topcol

            spacing: 10

            Row {

                id: butrow

                spacing: 10

                PQComboBox {
                    id: catCombo
                    y: (enableBut.height-height)/2
                            //: This is a category of files PhotoQt can recognize: any image format
                    model: [qsTranslate("settingsmanager", "images"),
                            //: This is a category of files PhotoQt can recognize: compressed files like zip, tar, cbr, 7z, etc.
                            qsTranslate("settingsmanager", "compressed files")+" (zip, cbr, ...)",
                            //: This is a category of files PhotoQt can recognize: documents like pdf, txt, etc.
                            qsTranslate("settingsmanager", "documents")+" (pdf, txt, ...)",
                            //: This is a type of category of files PhotoQt can recognize: videos like mp4, avi, etc.
                            qsTranslate("settingsmanager", "videos")]
                }

                PQButton {
                    id: enableBut
                    //: As in: "Enable all formats in the seleted category of file types"
                    text: qsTranslate("settingsmanager", "Enable")
                    onClicked:
                        parent.checkUncheck(1)
                }
                PQButton {
                    //: As in: "Disable all formats in the seleted category of file types"
                    text: qsTranslate("settingsmanager", "Disable")
                    onClicked:
                        parent.checkUncheck(0)
                }

                function checkUncheck(checked) {
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
                    onControlActiveFocusChanged: {
                        PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
                    }
                }

                PQLineEdit {
                    id: filter_lib
                    width: setting_top.width/2 -20
                    placeholderText: qsTranslate("settingsmanager", "Search by image library or category")
                    onControlActiveFocusChanged: {
                        PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
                    }
                }
            }

        }

        PQSettingsSeparator {}

        ListView {

            id: listview

            width: setting_top.width
            height: setting_top.height-topcol.height

            property var ft: []
            onFtChanged:
                checkDefault()

            clip: true

            model: ft.length

            ScrollBar.vertical: PQVerticalScrollBar {}

            delegate:
                Rectangle {

                    id: entry_rect

                    width: setting_top.width

                    clip: true

                    property bool filterPass: true
                    height: filterPass ? 50 : 0
                    Behavior on height { NumberAnimation { duration: 50 } }

                    color: index%2==0 ? PQCLook.baseColorAccent : PQCLook.baseColor
                    visible: height > 0

                    PQCheckBox {
                        id: checkenable
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        checked: listview.ft[index][1]
                        onClicked: {
                            listview.ft[index][1] = (listview.ft[index][1]+1)%2
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
                        text: "<b>" + listview.ft[index][2] + "</b> &nbsp;&nbsp; *." + listview.ft[index][0].split(",").join(", *.")
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
                        text: listview.ft[index].slice(4).join(", ")
                        opacity: checkenable.checked ? 1 : 0.3
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            listview.ft[index][1] = (listview.ft[index][1]+1)%2
                            listview.ftChanged()
                        }
                        text: "<b>" + qsTranslate("settingsmanager", "File endings:") + "</b> *." + listview.ft[index][0].split(",").join(", *.")
                    }

                    function filterItem() {

                        var desc_pass = false
                        if(filter_desc.text === "" ||
                                entry_desc.text.toLowerCase().indexOf(filter_desc.text.toLowerCase()) !== -1 ||
                                listview.ft[index][0].toLowerCase().indexOf(filter_desc.text.toLowerCase()) !== -1) {
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

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEnterEsc = false


    function checkAll() {
        checkImg(true)
        checkPac(true)
        checkDoc(true)
        checkVid(true)
    }

    function checkImg(checked) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "img" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function checkPac(checked) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "pac" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function checkDoc(checked) {
        var val = (checked ? 1 : 0)
        for(var i in listview.ft) {
            if(listview.ft[i][3] === "doc" && listview.ft[i][1] !== val) {
                listview.ft[i][1] = val
            }
        }
        listview.ftChanged()
    }

    function checkVid(checked) {
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
            str += ""+listview.ft[e][1]
        }
        return str
    }

    function checkDefault() {
        var chk = composeChecker()
        settingChanged = (chk !== defaultSettings)
    }

    function load() {
        listview.ft = PQCImageFormats.getAllFormats()
        defaultSettings = composeChecker()
        settingChanged = false
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
