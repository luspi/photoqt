import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../../elements"

Rectangle {

    id: popuptop

    parent: settingsmanager_top
    anchors.fill: parent

    color: "#87000000"

    property alias additionalSettingsVisible: addSetCont.visible
    property alias additionalSettings: addSetCont.children
    property string description: ""

    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    signal resetChecked()

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Click here to close popup")
        onClicked: hide()
    }

    Rectangle {

        id: inside

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        width: Math.max(parent.width/3, 500)
        height: Math.max(parent.height/2, 300)

        color: "#bb000000"
        border.width: 1
        border.color: "#88bbbbbb"
        radius: 5

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Row {
            id: titlerow
            y: 20
            x: (parent.width-width)/2
            spacing: 10
            Image {
                id: iconsource
                y: (parent.height-height)/2
                visible: source!=""
                sourceSize.height: titletext.height
                source: tile_top.iconsource
            }
            Text {
                id: titletext
                y: (parent.height-height)/2
                text: tile_top.title
                color: "white"
                font.pointSize: 20
                font.bold: true
                PQMouseArea {
                    id: descriptionMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.WhatsThisCursor
                    tooltip: tile_top.description
                }
            }
        }

        Text {
            id: descrow
            x: 3
            y: titlerow.y+titlerow.height+20
            width: parent.width-6
            wrapMode: Text.WordWrap
            color: "white"
            text: popuptop.description
        }

        Item {
            id: buttonrow
            x: 1
            y: descrow.text=="" ? (titlerow.y+titlerow.height+20) : (descrow.y+descrow.height+20)
            width: parent.width-2
            height: checkall.height
            PQButton {
                id: checkdefault
                x: 0
                y: 0
                forceWidth: parent.width/3
                //: as in: default file types
                text: em.pty+qsTranslate("settingsmanager_filetypes", "default")
                //: Check here refers to marking a checkbox (i.e., the act of checking the box)
                tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Check default file endings")
                onClicked: {
                    for(var key in tile_top.checkedItems)
                        tile_top.checkedItems[key] = (tile_top.defaultEnabled.indexOf(key) != -1)
                    tile_top.checkedItemsChanged()
                    resetChecked()
                }
            }
            PQButton {
                id: checkall
                x: parent.width/3 +1
                y: 0
                forceWidth: parent.width/3 -2
                //: as in: all file types
                text: em.pty+qsTranslate("settingsmanager_filetypes", "all")
                //: Check here refers to marking a checkbox (i.e., the act of checking the box)
                tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Check all file endings")
                onClicked: {
                    for(var key in tile_top.checkedItems)
                        tile_top.checkedItems[key] = true
                    tile_top.checkedItemsChanged()
                    resetChecked()
                }
            }
            PQButton {
                id: checknone
                x: 2*parent.width/3
                y: 0
                forceWidth: parent.width/3
                //: as in: no file types
                text: em.pty+qsTranslate("settingsmanager_filetypes", "none")
                //: Check here refers to marking a checkbox (i.e., the act of checking the box)
                tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Check no file endings")
                onClicked: {
                    for(var key in tile_top.checkedItems)
                        tile_top.checkedItems[key] = false
                    tile_top.checkedItemsChanged()
                    resetChecked()
                }
            }
        }

        Item {

            x: 5
            y: buttonrow.y+buttonrow.height+5
            width: parent.width-8
            height: parent.height-y-4 - (!additionalSettingsVisible ? 0 : (addSetCont.height+10))

            Flickable {
                anchors.fill: parent
                contentHeight: flow.height
                clip: true
                ScrollBar.vertical: PQScrollBar { id: scroll }
                Flow {
                    id: flow
                    y: 5
                    width: parent.width-scroll.width-2
                    spacing: 2
                    Repeater {
                        model: tile_top.available.length
                        PQTile {
                            id: endingtile
                            overrideWidth: 115
                            text: tile_top.available[index][0]
                            tooltip: "<b>" + tile_top.available[index][1] + "</b><br><br>" + em.pty+qsTranslate("settingsmanager_filetypes", "Left click to check/uncheck. Right click to check/uncheck all endings for this image type.")
                            onRightClicked: {
                                popuptop.toggleCategory(tile_top.available[index][2], !endingtile.checked)
                            }
                            onCheckedChanged: {
                                tile_top.checkedItems[tile_top.available[index][0]] = checked
                                tile_top.checkedItemsChanged()
                            }

                            Connections {
                                target: popuptop
                                onResetChecked: {
                                    endingtile.checked = tile_top.checkedItems[tile_top.available[index][0]]
                                }
                            }
                        }
                    }
                }
            }

        }

        Item {

            id: addSetCont

            x: 0
            y: parent.height-height-10
            width: parent.width
            height: childrenRect.height+10
            visible: additionalSettingsVisible

            Rectangle {
                width: parent.width
                height: 1
                color: "#88444444"
            }

        }

    }

    Image {
        x: inside.x+inside.width-width/2
        y: inside.y-height/2
        width: 50
        height: 50
        source: "/settingsmanager/filetypes/advancedclose.png"
        opacity: closemouse.containsMouse ? 1 : 0.5
        Behavior on opacity { NumberAnimation { duration: 100 } }
        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Click here to close popup")
            onClicked: hide()
        }
    }

    Connections {
        target: settingsmanager_top
        onCloseModalWindow:
            hide()
    }

    function toggleCategory(cat, enabled) {
        for(var i = 0; i < tile_top.available.length; ++i) {
            if(tile_top.available[i][2] == cat)
                tile_top.checkedItems[tile_top.available[i][0]] = enabled
        }
        tile_top.checkedItemsChanged()
        resetChecked()
    }

    function show() {
        resetChecked()
        opacity = 1
        settingsmanager_top.modalWindowOpen = true
    }
    function hide() {
        settingsmanager_top.modalWindowOpen = false
        opacity = 0
    }

}
