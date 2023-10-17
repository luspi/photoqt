import QtQuick

import "../elements"

Item {

    id: subcatcol

    height: settingsmanager_top.contentHeight
    width: 300-8

    property var subitems: categories[sm_maincategory.selectedCategory][1]

    property var subitemskeys: Object.keys(subitems)

    property string selectedSubCategory: subitems[subitemskeys[0]]

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

        property int currentIndex: 0
        onCurrentIndexChanged:
            selectedSubCategory = subitems[subitemskeys[currentIndex]]

        Column {

            spacing: 0

            Repeater {
                model: subitemskeys.length

                delegate:
                    Rectangle {

                        id: deleg

                        height: 50
                        width: subcatcol.width

                        property bool mouseOver: false

                        color: subcatflick.currentIndex===index ? PQCLook.baseColorActive : (mouseOver ? PQCLook.baseColorHighlight : "transparent")
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
                            onClicked:
                                subcatflick.currentIndex = index
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
                            text: subitems[subitemskeys[index]]
                            color: subcatflick.currentIndex===index ? PQCLook.textColorActive : PQCLook.textColor
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Rectangle {
                            x: 0
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: PQCLook.baseColorHighlight
                        }

                    }


            }

        }
    }

}
