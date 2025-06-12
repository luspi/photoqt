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
import PhotoQt

Item {

    id: categories_top

    property list<int> currentMainIndex: [0,0]
    property list<int> currentSubIndex: [0,0]

    property var categories: ({})

    property list<string> filterCategories: []

    // This variable (and only this one) causes a crash in qmlcachegen for Qt 6.4
    // if its type is left as list<string>
    /*1off_Qt64
    property var filterSubCategories: []
    2off_Qt64*/
    /*1on_Qt65+*/
    property list<string> filterSubCategories: []
    /*2on_Qt65+*/

    property list<string> selectedCategories: []

    property list<string> categoryKeys: Object.keys(categories)
    property var subCategoryKeys: ({})
    Component.onCompleted: {
        var tmp = {}
        for(var i in categoryKeys) {
            tmp[categoryKeys[i]] = Object.keys(categories[categoryKeys[i]][1])
        }
        subCategoryKeys = tmp
    }

    Flickable {

        id: maincatflick

        anchors.fill: parent
        anchors.bottomMargin: filtercont.height+2

        contentHeight: contcol.height
        clip: true

        Column {

            id: contcol

            spacing: 0

            Repeater {
                model: categories_top.categoryKeys.length

                delegate:
                    Item {

                        id: deleg

                        width: categories_top.width

                        height: passingFilter ? (heading.height + ((isSelected||filtertxt.text!=="") ? subcatcol.height+4 : 0)) : 0
                        Behavior on height { NumberAnimation { duration: 200 } }

                        visible: height>0
                        clip: true

                        required property int modelData

                        property string cat: categories_top.categoryKeys[modelData]
                        property var catitems: categories_top.categories[cat][1]
                        property list<string> catitemskeys: categories_top.subCategoryKeys[cat]

                        property bool isSelected: categories_top.currentMainIndex[0]===deleg.modelData
                        property bool passingFilter: true

                        Connections {

                            target: categories_top

                            function onFilterCategoriesChanged() {
                                deleg.passingFilter = (categories_top.filterCategories.length===0 || categories_top.filterCategories.indexOf(deleg.cat) > -1)
                            }

                        }

                        Rectangle {

                            id: heading

                            height: 60
                            width: categories_top.width

                            color: deleg.isSelected ?
                                       PQCLook.baseColorActive :    // qmllint disable unqualified
                                       (hovered ?
                                            PQCLook.baseColorHighlight :
                                            PQCLook.baseColorAccent)
                            Behavior on color { ColorAnimation { duration: 200 } }

                            opacity: deleg.passingFilter ? 1 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            property bool hovered: false

                            Rectangle {
                                x: 0
                                y: 0
                                width: parent.width
                                height: 1
                                color: PQCLook.baseColorActive  // qmllint disable unqualified
                                visible: deleg.modelData>0
                            }

                            PQText {
                                x: 5
                                y: 5
                                width: parent.width-expandicon.width-15
                                height: parent.height-10
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                text: categories_top.categories[deleg.cat][0]
                                color: PQCLook.textColor // qmllint disable unqualified
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            Image {
                                id: expandicon
                                x: (parent.width-width-5)
                                y: 15
                                width: parent.height-30
                                height: width
                                rotation: (deleg.isSelected||filtertxt.text!=="") ? 90 : 0
                                Behavior on rotation { NumberAnimation { duration: 200 } }
                                source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg" // qmllint disable unqualified
                                sourceSize: Qt.size(width, height)
                            }

                            Rectangle {
                                x: 0
                                y: parent.height-height
                                width: parent.width
                                height: 1
                                color: PQCLook.baseColorActive // qmllint disable unqualified
                            }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                property bool tooltipSetup: false
                                onEntered: {
                                    heading.hovered = true
                                    if(!tooltipSetup) {
                                        tooltipSetup = true
                                        var txt = "<h2>" + categories_top.categories[deleg.cat][0] + "</h2>"
                                        for(var i = 0; i < deleg.catitemskeys.length; ++i) {
                                            txt += "<div>&gt; " + deleg.catitems[deleg.catitemskeys[i]][0] + "</div>"
                                        }
                                        text = txt
                                    }
                                }
                                onExited:
                                    heading.hovered = false
                                onClicked: {

                                    if(!settingsmanager_top.confirmIfUnsavedChanged("main", deleg.modelData))   // qmllint disable unqualified
                                        return

                                    if(currentMainIndex[0] !== deleg.modelData)
                                        currentMainIndex = [deleg.modelData, currentMainIndex[0]]

                                    var tmp = 0
                                    if(filterSubCategories.length > 0) {
                                        while(filterSubCategories.indexOf(deleg.catitemskeys[tmp]) == -1 && tmp < filterSubCategories.length)
                                            tmp += 1
                                    }
                                    categories_top.currentSubIndex = [tmp, categories_top.currentSubIndex[0]]

                                    categories_top.selectedCategories = [deleg.cat, deleg.catitemskeys[categories_top.currentSubIndex[0]]]
                                }
                            }

                        }

                        Column {

                            id: subcatcol

                            y: heading.height+2

                            spacing: 2

                            Repeater {

                                model: deleg.catitemskeys.length

                                Rectangle {

                                    id: subdeleg

                                    required property int modelData

                                    property string curcat: deleg.catitems[deleg.catitemskeys[modelData]][0]
                                    property list<string> sets: deleg.catitems[deleg.catitemskeys[modelData]][2]

                                    property bool hovered: false
                                    property bool isSelected: (categories_top.currentSubIndex[0] === modelData && deleg.isSelected)
                                    property bool passingFilter: true

                                    width: categories_top.width
                                    height: passingFilter ? 40 : 0
                                    Behavior on height { NumberAnimation { duration: 200 } }
                                    visible: height>0

                                    color: isSelected ?
                                               PQCLook.baseColorHighlight : // qmllint disable unqualified
                                               (hovered ?
                                                    PQCLook.transColorHighlight :
                                                    PQCLook.baseColorAccent)

                                    opacity: subdeleg.passingFilter ? 1 : 0.4
                                    Behavior on opacity { NumberAnimation { duration: 200 } }

                                    Connections {

                                        target: categories_top

                                        function onFilterSubCategoriesChanged() {

                                            subdeleg.passingFilter = (categories_top.filterSubCategories.length===0 || categories_top.filterSubCategories.indexOf(deleg.catitemskeys[subdeleg.modelData]) > -1)

                                        }

                                    }

                                    PQText {
                                        x: 25
                                        y: (parent.height-height)/2
                                        width: parent.width-30
                                        elide: Text.ElideRight
                                        text: subdeleg.curcat
                                        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                        color: PQCLook.textColor // qmllint disable unqualified
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                    }

                                    PQMouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        property bool tooltipSetup: false
                                        onEntered: {
                                            subdeleg.hovered = true
                                            if(!tooltipSetup) {
                                                tooltipSetup = true
                                                var txt = "<h2>" + subdeleg.curcat + "</h2>"
                                                for(var i = 0; i < subdeleg.sets.length; ++i) {
                                                    txt += "<div>&gt; " + subdeleg.sets[i] + "</div>"
                                                }
                                                text = txt
                                            }
                                        }
                                        onExited:
                                            subdeleg.hovered = false
                                        onClicked: {

                                            if(!settingsmanager_top.confirmIfUnsavedChanged("sub", subdeleg.modelData)) // qmllint disable unqualified
                                                return

                                            if(currentMainIndex[0] !== deleg.modelData)
                                                currentMainIndex = [deleg.modelData, currentMainIndex[0]]
                                            if(currentSubIndex[0] !== subdeleg.modelData)
                                                currentSubIndex = [subdeleg.modelData, currentSubIndex[0]]
                                            categories_top.selectedCategories = [deleg.cat, deleg.catitemskeys[subdeleg.modelData]]

                                        }
                                    }

                                }

                            }

                        }

                    }

            }

        }
    }

    Item {
        id: filtercont
        y: (parent.height-height)
        width: parent.width-2
        height: filtertxt.height+2

        PQLineEdit {
            id: filtertxt
            width: filtercont.width
            placeholderText: qsTranslate("settingsmanager", "Filter")
            onControlActiveFocusChanged:
                PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus // qmllint disable unqualified
            onTextChanged:
                categories_top.filterSettings(filtertxt.text.toLowerCase())
        }

    }

    function loadSpecificCategory(cat: string, subcat: string) {

        currentMainIndex = [categoryKeys.indexOf(cat), currentMainIndex[0]]
        currentSubIndex = [subCategoryKeys[cat].indexOf(subcat), currentSubIndex[0]]
        categories_top.selectedCategories = [cat, subcat]

    }

    function laodFromUnsavedActions(cat: string, ind: int) {

        if(cat === "main") {

            currentMainIndex = [ind, currentMainIndex[0]]
            var tmp = 0
            if(filterSubCategories.length > 0) {
                while(filterSubCategories.indexOf(deleg.catitemskeys[tmp]) == -1 && tmp < filterSubCategories.length)   // qmllint disable unqualified
                    tmp += 1
            }
            currentSubIndex = [tmp, currentSubIndex[0]]

        } else if(cat === "sub") {
            currentSubIndex = [ind, currentSubIndex[0]]
        }

        var _main = categoryKeys[currentMainIndex[0]]
        var _sub = subCategoryKeys[_main][currentSubIndex[0]]

        categories_top.selectedCategories = [_main, _sub]

    }

    function filterSettings(str: string) {

        if(str === "") {
            filterCategories = []
            filterSubCategories = []
        }

        var foundcat = []
        var foundsubcat = []

        for(var i in categoryKeys) {

            var key = categoryKeys[i]
            var val = categories[key]

            var subkeys = subCategoryKeys[key]

            if(key.toLowerCase().includes(str)) {
                if(foundcat.indexOf(key) === -1)
                    foundcat.push(key)
                for(var j in subkeys)
                    foundsubcat.push(subkeys[j])
            }

            for(var j in subkeys) {

                var subkey = subkeys[j]
                var subval = val[1][subkey]

                if(subval[0].toLowerCase().includes(str)) {
                    if(foundcat.indexOf(key) === -1)
                        foundcat.push(key)
                    foundsubcat.push(subkey)
                } else {

                    for(var k in subval[2]) {

                        if(subval[2][k].toLowerCase().includes(str)) {
                            if(foundcat.indexOf(key) === -1)
                                foundcat.push(key)
                            foundsubcat.push(subkey)
                            break
                        }

                    }

                    for(var l in subval[3]) {

                        if(subval[3][l].toLowerCase().includes(str)) {
                            if(foundcat.indexOf(key) === -1)
                                foundcat.push(key)
                            if(foundsubcat.indexOf(subkey) === -1)
                                foundsubcat.push(subkey)
                            break
                        }

                    }
                }

            }

        }

        // if nothing was found we need to distinguish this from 'no filter text entered'
        if(foundcat.length == 0 || foundsubcat.length == 0) {
            foundcat = ["-"]
            foundsubcat = ["-"]
        }

        filterCategories = foundcat
        filterSubCategories = foundsubcat

        if(filterCategories.indexOf(categoryKeys[currentMainIndex[0]]) == -1)
            gotoNextIndex("main")
        else if(filterSubCategories.indexOf(subCategoryKeys[categoryKeys[currentMainIndex[0]]][currentSubIndex[0]]) == -1)
            gotoNextIndex("sub")

        filtertxt.setFocus()
        filtertxt.moveToEnd()

    }

    function setFocusOnFilter() {
        filtertxt.setFocus()
    }

    function gotoNextIndex(section: string) {

        if(section === "main") {

            var newmain = (currentMainIndex[0]+1)%categoryKeys.length
            if(filterCategories.length > 0 && filterCategories.indexOf(newmain) == -1) {
                while(filterCategories.indexOf(categoryKeys[newmain]) == -1 && newmain < categoryKeys.length)
                    newmain += 1
                if(newmain == categoryKeys.length) {
                    newmain = 0
                    while(filterCategories.indexOf(categoryKeys[newmain]) == -1 && newmain < currentMainIndex[0])
                        newmain += 1
                }
            }

            if(newmain === currentMainIndex[0] || newmain == categoryKeys.length)
                return

            if(!settingsmanager_top.confirmIfUnsavedChanged("main", newmain)) // qmllint disable unqualified
                return

            currentMainIndex = [newmain, currentMainIndex[1]]
            currentSubIndex = [0, currentSubIndex[0]]

            var sub_k = Object.keys(categories[categoryKeys[currentMainIndex[0]]][1])

            categories_top.selectedCategories = [categoryKeys[currentMainIndex[0]], sub_k[0]]

        } else if(section === "sub") {

            var k = subCategoryKeys[categoryKeys[currentMainIndex[0]]]

            var newsub = (currentSubIndex[0]+1)%k.length
            if(filterSubCategories.length > 0 && filterSubCategories.indexOf(newsub) == -1) {
                while(filterSubCategories.indexOf(k[newsub]) == -1 && newsub < k.length)
                    newsub += 1
                if(newsub === k.length) {
                    newsub = 0
                    while(filterSubCategories.indexOf(k[newsub]) == -1 && newsub < currentSubIndex[0])
                        newsub += 1
                }
            }

            if(!settingsmanager_top.confirmIfUnsavedChanged("sub", newsub))
                return

            currentSubIndex = [newsub, currentSubIndex[0]]
            categories_top.selectedCategories = [categories_top.selectedCategories[0], k[currentSubIndex[0]]]

        }

    }

    function gotoPreviousIndex(section: string) {

        if(section === "main") {

            var newmain = (currentMainIndex[0]+categoryKeys.length-1)%categoryKeys.length
            if(filterCategories.length > 0 && filterCategories.indexOf(newmain) == -1) {
                while(newmain > -1 && filterCategories.indexOf(categoryKeys[newmain]) == -1 && newmain >= 0)
                    newmain -= 1
                if(newmain == -1) {
                    newmain = categoryKeys.length-1
                    while(filterCategories.indexOf(categoryKeys[newmain]) == -1 && newmain > currentSubIndex[0])
                        newmain -= 1
                }
            }

            if(!settingsmanager_top.confirmIfUnsavedChanged("main", newmain)) // qmllint disable unqualified
                return

            currentMainIndex = [newmain, currentMainIndex[1]]
            currentSubIndex = [0, currentSubIndex[0]]

            var sub_k = Object.keys(categories[categoryKeys[currentMainIndex[0]]][1])

            categories_top.selectedCategories = [categoryKeys[currentMainIndex[0]], sub_k[0]]

        } else if(section === "sub") {

            var k = subCategoryKeys[categoryKeys[currentMainIndex[0]]]

            var newsub = (currentSubIndex[0]+k.length-1)%k.length

            if(filterSubCategories.length > 0 && filterSubCategories.indexOf(newsub) == -1) {
                while(filterSubCategories.indexOf(k[newsub]) == -1 && newsub >= 0)
                    newsub -= 1
                if(newsub === -1) {
                    newsub = k.length-1
                    while(filterSubCategories.indexOf(k[newsub]) == -1 && newsub > currentSubIndex[0])
                        newsub -= 1
                }
            }

            if(!settingsmanager_top.confirmIfUnsavedChanged("sub", newsub))
                return

            currentSubIndex = [newsub, currentSubIndex[0]]
            categories_top.selectedCategories = [categories_top.selectedCategories[0], k[currentSubIndex[0]]]

        }

    }

}
