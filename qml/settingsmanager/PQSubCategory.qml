import QtQuick

import "../elements"

Item {

    id: subcatcol

    height: settingsmanager_top.contentHeight
    width: 250-8

    visible: subitemskeys.length>1

    property var subitems: categories[selectedCategories[0]][1]
    property var subitemskeys: Object.keys(subitems)

    PQTextS {
        width: parent.width
        height: 30
        font.weight: PQCLook.fontWeightBold
        text: "subcategory"
        color: PQCLook.textColorHighlight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Flickable {

        id: subcatflick

        anchors.fill: parent
        anchors.topMargin: 30
        anchors.bottomMargin: catcont.height+2

        contentHeight: contcol.height
        clip: true

        property var currentIndex: [0,0]
        onCurrentIndexChanged: {
            if(confirmIfUnsavedChanged("sub", currentIndex[0])) {
                selectedCategories[1] = subitemskeys[currentIndex[0]]
                selectedCategoriesChanged()
            } else {
                if(currentIndex[0] !== currentIndex[1])
                    currentIndex = [currentIndex[1], currentIndex[1]]
            }
        }

        Column {

            id: contcol

            spacing: 0

            Repeater {
                model: subitemskeys.length

                delegate:
                    Rectangle {

                        id: deleg

                        height: 75
                        width: subcatcol.width

                        property bool mouseOver: false

                        property bool passingFilter: true

                        color: (subcatflick.currentIndex[0]===index) ?
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
                            text: "Select subcategory: " + subcattxt.text
                            onEntered:
                                parent.mouseOver = true
                            onExited:
                                parent.mouseOver = false
                            onClicked: {
                                var tmp = [index, subcatflick.currentIndex[0]]
                                subcatflick.currentIndex = tmp
                            }
                        }

                        PQText {
                            id: subcattxt
                            x: 5
                            y: 5
                            width: parent.width-10
                            height: parent.height-10
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.weight: PQCLook.fontWeightBold
                            text: subitems[subitemskeys[index]][0]
                            color: subcatflick.currentIndex[0]===index&&deleg.passingFilter ? PQCLook.textColorActive : (deleg.passingFilter ? PQCLook.textColor : PQCLook.textColorHighlight )
                            Behavior on color { ColorAnimation { duration: 200 } }
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

                            function onFilterSubCategoriesChanged() {
                                deleg.checkFilter()
                            }

                        }

                        Component.onCompleted:
                            checkFilter()

                        function checkFilter() {
                            deleg.passingFilter = (settingsmanager_top.filterSubCategories.length===0 || settingsmanager_top.filterSubCategories.indexOf(subitemskeys[index]) > -1)
                        }

                    }


            }

        }
    }

    Rectangle {
        y: (parent.height-catcont.height-height)
        width: parent.width
        height: 1
        color: PQCLook.baseColorHighlight
    }

    Item {
        id: catcont
        y: (parent.height-height)
        width: parent.width
        height: catcontcol.height+20
        visible: sets.length>0

        property var sets: subitems[selectedCategories[1]][2]

        Column {

            id: catcontcol

            y: 10

            spacing: 5

            PQText {
                x: 10
                visible: catcont.sets.length>0
                text: qsTranslate("settingsmanager", "Settings:")
            }

            Repeater {

                model: catcont.sets.length

                PQText {
                    x: 10
                    width: catcont.width-20
                    elide: Text.ElideRight
                    text: "> " + catcont.sets[index]
                    font.weight: PQCLook.fontWeightBold
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        text: catcont.sets[index]
                    }
                }

            }

        }

    }

    function setCurrentIndex(ind) {
        var tmp = [ind, subcatflick.currentIndex[0]]
        subcatflick.currentIndex = tmp
    }

}
