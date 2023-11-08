import QtQuick

import PQCNotify

import "../elements"

Item {

    id: maincatcol

    height: settingsmanager_top.contentHeight

    PQTextS {
        width: parent.width
        height: 30
        font.weight: PQCLook.fontWeightBold
        text: qsTranslate("settingsmanager", "main category")
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

        property var currentIndex: [0,0]
        onCurrentIndexChanged: {
            if(confirmIfUnsavedChanged("main", currentIndex[0])) {
                var newkey = categoryKeys[currentIndex[0]]
                selectedCategories = [newkey, Object.keys(categories[newkey][1])[0]]
                sm_subcategory.setCurrentIndex(0)
            } else {
                if(currentIndex[0] !== currentIndex[1]) {
                    currentIndex = [currentIndex[1], currentIndex[1]]
                }
            }
        }

        Column {

            id: contcol

            spacing: 0

            Repeater {
                model: categoryKeys.length

                delegate:
                    Rectangle {

                        id: deleg

                        height: 75
                        width: maincatcol.width

                        property bool mouseOver: false

                        property bool passingFilter: true

                        color: (maincatflick.currentIndex[0]===index) ?
                                   (passingFilter ?
                                        PQCLook.baseColorActive :
                                        PQCLook.baseColor) :
                                   (mouseOver ?
                                        (passingFilter ?
                                             PQCLook.baseColorHighlight :
                                             PQCLook.baseColor) :
                                        "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Rectangle {
                            x: 0
                            y: 0
                            width: parent.width
                            height: 1
                            color: PQCLook.baseColorHighlight
                        }

                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            property bool tooltipSetup: false
                            text: ""
                            onEntered: {
                                parent.mouseOver = true
                                if(!tooltipSetup) {
                                    tooltipSetup = true
                                    var txt = "<h1>" + maincattxt.text + "</h1>"
                                    var subs = categories[categoryKeys[index]][1]
                                    var keys = Object.keys(subs)
                                    for(var i = 0; i < keys.length; ++i) {
                                        txt += "<div>&gt; " + subs[keys[i]][0] + "</div>"
                                    }
                                    text = txt
                                }
                            }
                            onExited:
                                parent.mouseOver = false
                            onClicked: {
                                var tmp = [index, maincatflick.currentIndex[0]]
                                maincatflick.currentIndex = tmp
                            }
                        }

                        PQText {
                            id: maincattxt
                            x: 5
                            y: 5
                            width: parent.width-10 - rightarrow.width
                            height: parent.height-10
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.weight: PQCLook.fontWeightBold
                            text: categories[categoryKeys[index]][0]
                            color: maincatflick.currentIndex[0]===index&&deleg.passingFilter ? PQCLook.textColorActive : (deleg.passingFilter ? PQCLook.textColor : PQCLook.textColorHighlight )
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Image {
                            id: rightarrow
                            x: parent.width-width-5
                            y: (parent.height-height)/2
                            opacity: 0.5
                            fillMode: Image.Pad
                            sourceSize: Qt.size(20, 20)
                            source: "/white/slideshownext.svg"
                        }

                        Rectangle {
                            x: 0
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: PQCLook.baseColorHighlight
                        }

                        Connections {

                            target: settingsmanager_top

                            function onFilterCategoriesChanged() {

                                deleg.passingFilter = (settingsmanager_top.filterCategories.length===0 || settingsmanager_top.filterCategories.indexOf(categoryKeys[index]) > -1)

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
            placeholderText: qsTranslate("settingsmanager", "Filter settings")
            onControlActiveFocusChanged:
                PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
            onTextChanged:
                settingsmanager_top.filterSettings(filtertxt.text.toLowerCase())
        }

    }

    function setFocusOnFilter() {
        filtertxt.setFocus()
    }

    function gotoNextIndex() {
        var tmp = [(maincatflick.currentIndex[0]+1)%categoryKeys.length, maincatflick.currentIndex[0]]
        maincatflick.currentIndex = tmp
    }

    function gotoPreviousIndex() {
        var tmp = [(maincatflick.currentIndex[0]+categoryKeys.length-1)%categoryKeys.length, maincatflick.currentIndex[0]]
        maincatflick.currentIndex = tmp
    }

    function setCurrentIndex(ind) {
        var tmp = [ind, maincatflick.currentIndex[0]]
        maincatflick.currentIndex = tmp
    }

}
