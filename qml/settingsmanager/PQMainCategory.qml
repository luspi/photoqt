import QtQuick

import "../elements"

Item {

    id: maincatcol

    height: settingsmanager_top.contentHeight
    width: 300-8

    property string selectedCategory: categoryKeys[0]

    PQTextS {
        width: parent.width
        height: 30
        font.weight: PQCLook.fontWeightBold
        text: "select category"
        color: PQCLook.textColorHighlight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Flickable {

        id: maincatflick

        anchors.fill: parent
        anchors.topMargin: 30

        property var currentIndex: [0,0]
        onCurrentIndexChanged: {
            if(confirmIfUnsavedChanged("main", currentIndex[0]))
                selectedCategory = categoryKeys[currentIndex[0]]
            else {
                if(currentIndex[0] !== currentIndex[1])
                    currentIndex = [currentIndex[1], currentIndex[1]]
            }
        }

        Column {

            spacing: 0

            Repeater {
                model: categoryKeys.length

                delegate:
                    Rectangle {

                        id: deleg

                        height: 50
                        width: maincatcol.width

                        property bool mouseOver: false

                        color: maincatflick.currentIndex[0]===index ? PQCLook.baseColorActive : (mouseOver ? PQCLook.baseColorHighlight : "transparent")
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
                            color: maincatflick.currentIndex[0]===index ? PQCLook.textColorActive : PQCLook.textColor
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Image {
                            id: rightarrow
                            x: parent.width-width-5
                            height: parent.height
                            opacity: 0.5
//                            width: height
                            fillMode: Image.Pad
                            sourceSize: Qt.size(parent.height-30, parent.height-30)
                            source: "/white/slideshownext.svg"
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

    function setCurrentIndex(ind) {
        var tmp = [ind, maincatflick.currentIndex[0]]
        maincatflick.currentIndex = tmp
    }

}
