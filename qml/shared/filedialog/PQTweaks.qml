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

import QtQuick
import QtQuick.Controls
import PQCImageFormats
// import PhotoQt.Modern   // this is used to show the context menu for the file types as it SHOULD look different
import PhotoQt.Shared

Item {

    id: tweaks_top

    width: parent.width
    height: 50

    property int zoomMoveUpHeight: leftcolrect.state==="moveup" ? leftcolrect.height : 0

    property list<PQFileDialogButtonElement> allbuttons: [cancelbutton]

    SystemPalette { id: pqtPalette }

    Rectangle {

        id: leftcolrect

        y: 0
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutElastic } }

        width: leftcol.width+15
        height: parent.height

        color: pqtPalette.base
        border.color: PQCLook.baseBorder
        border.width: state==="moveup" ? 1 : 0

        Row {

            id: leftcol
            x: 5
            y: (parent.height-height)/2

            spacing: 5

            Label {
                y: (parent.height-height)/2
                text: qsTranslate("filedialog", "Zoom:")
                font.weight: PQCLook.fontWeightBold
                font.pointSize: PQCLook.fontSize
                color: pqtPalette.text
                PQGenericMouseArea {
                    anchors.fill: parent
                    tooltip: qsTranslate("filedialog", "Adjust size of files and folders")
                }
            }

            PQFileDialogSlider {

                id: zoomslider

                y: (parent.height-height)/2

                from: 1
                to: 100

                stepSize: 1
                // wheelStepSize: 1

                value: PQCSettings.filedialogZoom
                onValueChanged: {
                    var newval = Math.round(value)
                    if(newval !== PQCSettings.filedialogZoom)
                        PQCSettings.filedialogZoom = newval
                    tweaks_top.forceActiveFocus()
                }

                Connections {

                    target: PQCSettings

                    function onFiledialogZoomChanged() {
                        if(zoomslider.value !== PQCSettings.filedialogZoom)
                            zoomslider.value = PQCSettings.filedialogZoom
                    }
                }

                Component.onCompleted: {
                    value = 1*value
                }

            }

            Text {
                y: (parent.height-height)/2
                text: zoomslider.value + "%"
                font.pointSize: PQCLook.fontSize
                color: pqtPalette.text
            }

        }

        Connections {
            target: tweaks_top
            function onWidthChanged() {
                if(tweaks_top.width < (rightcol.width+leftcol.width+cancelbutton.width+50))
                    leftcolrect.state   = "moveup"
                else
                    leftcolrect.state = "movedown"
            }
        }

        states: [
            State {
                name: "moveup"
                PropertyChanges {
                    leftcolrect.y: -leftcolrect.height+1
                }
            },
            State {
                name: "movedown"
                PropertyChanges {
                    leftcolrect.y: 0
                }
            }
        ]

    }

    Item {
        anchors.left: parent.left
        anchors.right: rightcol.parent.left
        anchors.leftMargin: leftcolrect.state==="moveup" ? 0 : (leftcol.width+leftcol.x)
        Behavior on anchors.leftMargin { NumberAnimation { duration: 200; easing.type: Easing.OutBounce } }
        height: parent.height

        PQFileDialogButtonElement {
            id: cancelbutton
            height: parent.height
            anchors.centerIn: parent
            text: genericStringCancel
            tooltip: qsTranslate("filedialog", "Cancel and close")
            onClicked:
                filedialog_top.hideFileDialog()
        }
    }

    Item {

        x: parent.width-width-5
        width: rightcol.width
        height: parent.height

        Row {

            id: rightcol
            y: (parent.height-height)/2
            spacing: 5
            Label {
                y: (parent.height-height)/2
                text: qsTranslate("filedialog", "Sort by:")
                font.pointSize: PQCLook.fontSize
                color: pqtPalette.text
            }

            PQFileDialogComboBox {

                id: rightcombo

                y: (parent.height-height)/2
                property list<int> linedat: [4]
                lineBelowItem: linedat

                property list<string> modeldata: [qsTranslate("filedialog", "Name"),
                                                  qsTranslate("filedialog", "Natural Name"),
                                                  qsTranslate("filedialog", "Time modified"),
                                                  qsTranslate("filedialog", "File size"),
                                                  qsTranslate("filedialog", "File type"),
                                                  "[" + qsTranslate("filedialog", "reverse order") + "]"]
                model: modeldata

                hideEntries: PQCScriptsConfig.isICUSupportEnabled() ? [] : [1]

                Component.onCompleted: {
                    setCurrentIndex()
                }

                // this hack is needed as at startup the currentIndex gets set to 0 and its changed signal gets triggered
                property bool delayAfterSetup: false
                Timer {
                    running: true
                    interval: 200
                    onTriggered:
                        rightcombo.delayAfterSetup = true
                }

                onCurrentIndexChanged: {
                    if(!delayAfterSetup) return
                    if(currentIndex === 0)
                        PQCSettings.imageviewSortImagesBy = "name"
                    else if(currentIndex === 1)
                        PQCSettings.imageviewSortImagesBy = "naturalname"
                    else if(currentIndex === 2)
                        PQCSettings.imageviewSortImagesBy = "time"
                    else if(currentIndex === 3)
                        PQCSettings.imageviewSortImagesBy = "size"
                    else if(currentIndex === 4)
                        PQCSettings.imageviewSortImagesBy = "type"
                    else if(currentIndex === 5) {
                        PQCSettings.imageviewSortImagesAscending = !PQCSettings.imageviewSortImagesAscending
                        setCurrentIndex()
                    }
                }

                function setCurrentIndex() {
                    var sortby = PQCSettings.imageviewSortImagesBy
                    if(sortby === "name" || (sortby === "naturalname" && !PQCScriptsConfig.isICUSupportEnabled()))
                        currentIndex = 0
                    else if(sortby === "naturalname")
                        currentIndex = 1
                    else if(sortby === "time")
                        currentIndex = 2
                    else if(sortby === "size")
                        currentIndex = 3
                    else if(sortby === "type")
                        currentIndex = 4
                }

                popup.onClosed: {
                    tweaks_top.forceActiveFocus()
                }

            }

            PQFileDialogButton {

                id: filetypes_button

                y: (parent.height-height)/2
                font.weight: PQCLook.fontWeightNormal
                font.pointSize: PQCLook.fontSize
                horizontalAlignment: Text.AlignLeft
                width: 300
                forceWidth: width

                enableContextMenu: false

                Connections {
                    target: PQCConstants
                    function onWhichContextMenusOpenChanged() {
                        filetypes_button.forceHovered = PQCConstants.isContextmenuOpen("filedialogtypes")
                    }
                }
                Connections {
                    target: PQCNotify
                    function onFiledialogTweaksSetFiletypesButtonText(txt : string) {
                        filetypes_button.text = txt
                    }
                }

                text: qsTranslate("filedialog", "All supported images")

                onClicked: {
                    PQCNotify.showFileDialogContextMenu(!PQCConstants.isContextmenuOpen("filedialogtypes"), ["filedialogtypes", filetypes_button.mapToGlobal(filetypes_button.x, filetypes_button.y)])
                }

            }

        }

    }

    Rectangle {
        y: 0
        width: parent.width
        height: 1
        color: PQCLook.baseBorder
    }

}
