import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

Rectangle {

    id: tile_top

    width: 300
    height: 300
    color: "#88444444"
    radius: 5

    property alias title: titletext.text
    property alias iconsource: iconsource.source
    property alias additionalSetting: advanced.additionalSettings
    property alias additionalSettingShow: advanced.additionalSettingsVisible
    property var projectWebpage: []
    property var available: []
    property var defaultEnabled: []
    property var currentlyEnabled: []

    property var checkedItems: ({})

    Column {

        spacing: 10

        x: 10
        y: 10
        width: parent.width-20

        Row {
            x: (parent.width-width)/2
            spacing: 10
            Image {
                id: iconsource
                y: (parent.height-height)/2
                visible: source!=""
                sourceSize.height: titletext.height-10
                source: ""
            }

            Text {
                id: titletext
                y: (parent.height-height)/2
                text: "Title"
                font.pointSize: 17
                font.bold: true
                color: "white"
            }
        }

        Row {
            spacing: 5
            x: (parent.width-width)/2
            width: childrenRect.width
            Text {
                id: count_txt
                text: ""
                color: "white"
                font.pointSize: 12
                font.bold: true
                Connections {
                    target: tile_top
                    onCheckedItemsChanged: {
                        var c = 0
                        for(var key in tile_top.checkedItems) {
                            if(tile_top.checkedItems[key])
                                c += 1
                        }
                        count_txt.text = c
                    }
                }
            }
            Text {
                text: "enabled"
                color: "white"
                font.pointSize: 12
            }
        }

        PQButton {
            forceWidth: parent.width
            text: "enable default"
            tooltip: "Enable default file endings"
            onClicked: {
                for(var key in tile_top.checkedItems)
                    tile_top.checkedItems[key] = (tile_top.defaultEnabled.indexOf(key) != -1)
                tile_top.checkedItemsChanged()
            }
        }

        PQButton {
            forceWidth: parent.width
            text: "disable"
            tooltip: "Disable this category"
            onClicked: {
                for(var key in tile_top.checkedItems)
                    tile_top.checkedItems[key] = false
                tile_top.checkedItemsChanged()
            }
        }

        PQButton {
            forceWidth: parent.width
            text: "advanced fine-tuning"
            tooltip: "Fine-tune enabled fine endings"
            onClicked:
                advanced.show()
        }

    }

    Row {
        x: (parent.width-width)/2
        y: parent.height-height-10
        spacing: 20
        Repeater {
            model: projectWebpage.length/2
            Text {
                color: "#888888"
                text: projectWebpage[2*index]
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: projectWebpage[2*index+1]
                    onClicked:
                        Qt.openUrlExternally(projectWebpage[2*index+1])
                }
            }
        }
    }

    function resetChecked() {
        for(var i = 0; i < available.length; ++i)
            checkedItems[available[i][0]] = (currentlyEnabled.indexOf(available[i][0])!=-1)
        tile_top.checkedItemsChanged()
    }

    PQAdvancedTuning {
        id: advanced
    }

}
