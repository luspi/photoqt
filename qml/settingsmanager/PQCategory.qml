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

import PQCNotify

import "../elements"

Item {

    id: categories_top

    height: settingsmanager_top.contentHeight

    property var currentMainIndex: [0,0]
    property var currentSubIndex: [0,0]

    property var filterCategories: []
    property var filterSubCategories: []

    PQTextS {
        width: parent.width
        height: 30
        font.weight: PQCLook.fontWeightBold
        text: qsTranslate("settingsmanager", "category")
        color: PQCLook.textColorHighlight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Flickable {

        id: maincatflick

        anchors.fill: parent
        anchors.topMargin: 30
        anchors.bottomMargin: filtercont.height+2

        contentHeight: contcol.height
        clip: true

        Column {

            id: contcol

            spacing: 0

            Repeater {
                model: categoryKeys.length

                delegate:
                    Item {

                        id: deleg

                        width: categories_top.width

                        height: passingFilter ? (heading.height + ((isSelected||filtertxt.text!=="") ? subcatcol.height+4 : 0)) : 0
                        Behavior on height { NumberAnimation { duration: 200 } }

                        visible: height>0
                        clip: true

                        property int catindex: index
                        property string cat: categoryKeys[index]
                        property var catitems: categories[cat][1]
                        property var catitemskeys: Object.keys(catitems)

                        property bool isSelected: categories_top.currentMainIndex[0]===deleg.catindex
                        property bool passingFilter: true

                        Connections {

                            target: categories_top

                            function onFilterCategoriesChanged() {

                                deleg.passingFilter = (filterCategories.length===0 || filterCategories.indexOf(deleg.cat) > -1)

                            }

                        }

                        Rectangle {

                            id: heading

                            height: 60
                            width: categories_top.width
                            radius: 5

                            color: deleg.isSelected ? PQCLook.baseColorActive : (hovered ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent)
                            Behavior on color { ColorAnimation { duration: 200 } }

                            opacity: deleg.passingFilter ? 1 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            property bool hovered: false

                            Rectangle {
                                x: 0
                                y: 0
                                width: parent.width
                                height: 1
                                color: PQCLook.baseColorActive
                            }

                            PQText {
                                x: 5
                                y: 5
                                width: parent.width-expandicon.width-15
                                height: parent.height-10
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.weight: PQCLook.fontWeightBold
                                text: categories[deleg.cat][0]
                                color: deleg.isSelected ? PQCLook.textColorActive : PQCLook.textColor
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
                                source: "image://svg/:/white/forwards.svg"
                                sourceSize: Qt.size(width, height)
                            }

                            Rectangle {
                                x: 0
                                y: parent.height-height
                                width: parent.width
                                height: 1
                                color: PQCLook.baseColorActive
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
                                        var txt = "<h2>" + categories[deleg.cat][0] + "</h2>"
                                        for(var i = 0; i < deleg.catitemskeys.length; ++i) {
                                            txt += "<div>&gt; " + deleg.catitems[deleg.catitemskeys[i]][0] + "</div>"
                                        }
                                        text = txt
                                    }
                                }
                                onExited:
                                    heading.hovered = false
                                onClicked: {

                                    if(!confirmIfUnsavedChanged("main", deleg.catindex))
                                        return

                                    if(currentMainIndex[0] !== deleg.catindex)
                                        currentMainIndex = [deleg.catindex, currentMainIndex[0]]

                                    var tmp = 0
                                    if(filterSubCategories.length > 0) {
                                        while(filterSubCategories.indexOf(deleg.catitemskeys[tmp]) == -1 && tmp < filterSubCategories.length)
                                            tmp += 1
                                    }
                                    currentSubIndex = [tmp, currentSubIndex[0]]

                                    settingsmanager_top.selectedCategories = [deleg.cat, deleg.catitemskeys[currentSubIndex[0]]]
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

                                    property string curcat: deleg.catitems[deleg.catitemskeys[index]][0]
                                    property var sets: deleg.catitems[deleg.catitemskeys[index]][2]

                                    property bool hovered: false
                                    property bool isSelected: (currentSubIndex[0] === index && deleg.isSelected)
                                    property bool passingFilter: true

                                    width: categories_top.width
                                    height: passingFilter ? 40 : 0
                                    Behavior on height { NumberAnimation { duration: 200 } }
                                    visible: height>0

                                    color: isSelected ? PQCLook.baseColorHighlight : (hovered ? PQCLook.transColorHighlight : PQCLook.baseColorAccent)
                                    radius: 5

                                    opacity: subdeleg.passingFilter ? 1 : 0.4
                                    Behavior on opacity { NumberAnimation { duration: 200 } }

                                    Connections {

                                        target: categories_top

                                        function onFilterCategoriesChanged() {

                                            subdeleg.passingFilter = (filterSubCategories.length===0 || filterSubCategories.indexOf(deleg.catitemskeys[index]) > -1)

                                        }

                                    }

                                    PQText {
                                        x: 25
                                        y: (parent.height-height)/2
                                        width: parent.width-30
                                        elide: Text.ElideRight
                                        text: subdeleg.curcat
                                        color: PQCLook.textColor
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                    }

                                    PQMouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        property bool tooltipSetup: false
                                        onEntered: {
                                            parent.hovered = true
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
                                            parent.hovered = false
                                        onClicked: {

                                            if(!confirmIfUnsavedChanged("sub", index))
                                                return

                                            if(currentMainIndex[0] !== deleg.catindex)
                                                currentMainIndex = [deleg.catindex, currentMainIndex[0]]
                                            if(currentSubIndex[0] !== index)
                                                currentSubIndex = [index, currentSubIndex[0]]
                                            settingsmanager_top.selectedCategories = [deleg.cat, deleg.catitemskeys[index]]
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
                PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
            onTextChanged:
                filterSettings(filtertxt.text.toLowerCase())
        }

    }

    function laodFromUnsavedActions(cat, ind) {

        if(cat === "main") {

            currentMainIndex = [ind, currentMainIndex[0]]
            var tmp = 0
            if(filterSubCategories.length > 0) {
                while(filterSubCategories.indexOf(deleg.catitemskeys[tmp]) == -1 && tmp < filterSubCategories.length)
                    tmp += 1
            }
            currentSubIndex = [tmp, currentSubIndex[0]]

        } else if(cat === "sub") {
            currentSubIndex = [ind, currentSubIndex[0]]
        }

        var _main = categoryKeys[currentMainIndex[0]]
        var _sub = Object.keys(categories[_main][1])[currentSubIndex[0]]

        settingsmanager_top.selectedCategories = [_main, _sub]

    }

    function filterSettings(str) {

        if(str === "") {
            filterCategories = []
            filterSubCategories = []
        }

        var foundcat = []
        var foundsubcat = []

        for(var i in categoryKeys) {

            var key = categoryKeys[i]
            var val = categories[key]

            var subkeys = Object.keys(val[1])

            if(key.toLowerCase().includes(str)) {
                if(foundcat.indexOf(key) === -1)
                    foundcat.push(key)
                for(var i in subkeys)
                foundsubcat.push(subkeys[i])
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

    }

    function setFocusOnFilter() {
        filtertxt.setFocus()
    }

    function gotoNextIndex(section) {

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

            if(!confirmIfUnsavedChanged("main", newmain))
                return

            currentMainIndex = [newmain, currentMainIndex[1]]

            var sub_k = Object.keys(categories[categoryKeys[currentMainIndex[0]]][1])

            settingsmanager_top.selectedCategories = [categoryKeys[currentMainIndex[0]], sub_k[0]]

        } else if(section === "sub") {

            var k = Object.keys(categories[categoryKeys[currentMainIndex[0]]][1])

            var newsub = (currentSubIndex[0]+1)%k.length

            if(!confirmIfUnsavedChanged("sub", newsub))
                return

            currentSubIndex = [newsub, currentSubIndex[0]]
            settingsmanager_top.selectedCategories = [settingsmanager_top.selectedCategories[0], k[currentSubIndex[0]]]

        }

    }

    function gotoPreviousIndex(section) {

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

            if(!confirmIfUnsavedChanged("main", newmain))
                return

            currentMainIndex = [newmain, currentMainIndex[1]]

            var sub_k = Object.keys(categories[categoryKeys[currentMainIndex[0]]][1])

            settingsmanager_top.selectedCategories = [categoryKeys[currentMainIndex[0]], sub_k[0]]

        } else if(section === "sub") {

            var k = Object.keys(categories[categoryKeys[currentMainIndex[0]]][1])
            var newsub = (currentSubIndex[0]+k.length-1)%k.length

            if(!confirmIfUnsavedChanged("sub", newsub))
                return

            currentSubIndex = [newsub, currentSubIndex[0]]
            settingsmanager_top.selectedCategories = [settingsmanager_top.selectedCategories[0], k[currentSubIndex[0]]]

        }

    }

}
