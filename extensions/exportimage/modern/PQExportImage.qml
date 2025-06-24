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
import QtQuick.Controls

import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsFilesPaths

import PhotoQt

import "../../../qml/modern/elements"

PQTemplateFullscreen {

    id: convert_top

    thisis: "exportimage"
    popout: PQCSettings.extensions.ExportImagePopout
    forcePopout: PQCWindowGeometry.exportForcePopout
    shortcut: "__export"

    //: title of action element
    title: qsTranslate("export", "Export image")

    //: written on button
    button1.text: qsTranslate("export", "Export")
    button1.enabled: targetFormat!==""
    button2.visible: true
    button2.text: genericStringCancel

    button1.onClicked: {
        PQCSettings.extensions.ExportImageLastUsed = targetFormat
        var file = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("export", "Export"), PQCFileFolderModel.currentFile, parseInt(targetFormat), true);
        if(file !== "") {
            errormessage.opacity = 0
            exportbusy.showBusy()
            PQCScriptsFileManagement.exportImage(PQCFileFolderModel.currentFile, file, parseInt(targetFormat))
        }

    }

    button2.onClicked:
        hide()

    onPopoutChanged:
        PQCSettings.extensions.ExportImagePopout = popout

    /***************************************************************/

    // the favs are shown on a label and are used to identify the respective entry in the listview
    property list<string> favs: PQCSettings.extensions.ExportImageFavorites

    // this is the selected format, both the first ending (for identification) and all endings for a format
    property string targetFormat: PQCSettings.extensions.ExportImageLastUsed

    content: [

        /*****************************************************/
        // error message

        PQTextL {
            id: errormessage
            visible: false
            x: (parent.width-width)/2
            width: favs_item.width
            horizontalAlignment: Qt.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("export", "Something went wrong during export to the selected format...")
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        },

        Item {
            visible: errormessage.visible
            width: 1
            height: 10
        },

        /*****************************************************/
        // at first we list any selected favorites

        Item {

            id: favs_item

            x: (parent.width-width)/2

            width: favs_col.width
            height: favs_col.height

            Column {

                id: favs_col

                spacing: 10

                PQText {
                    width: Math.min(600, convert_top.width-100)
                    //: These are the favorite image formats for exporting images to
                    text: qsTranslate("export", "Favorites:")
                }

                // only shown when no favorites are set
                PQText {
                    width: favcol.width
                    height: 30
                    color: PQCLook.textColorDisabled // qmllint disable unqualified
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                    font.italic: true
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    //: the favorites are image formats for exporting images to
                    text: " " + qsTranslate("export", "no favorites set")
                    visible: convert_top.favs.length===0
                }

                // all favorites
                Column {
                    id: favcol
                    width: Math.min(600, convert_top.width-100)
                    spacing: 5

                    property int currentIndex: -1
                    property int currentHover: -1

                    Timer {
                        id: resetFavsHighlightIndex
                        interval: 100
                        property int oldIndex
                        onTriggered: {
                            if(favcol.currentHover==oldIndex)
                                favcol.currentHover = -1
                        }
                    }

                    onCurrentHoverChanged: {
                        if(favcol.currentHover !== -1)
                            formatsview.currentHover = -1
                    }

                    Repeater {

                        model: convert_top.favs.length

                        Rectangle {

                            id: favdeleg

                            required property int modelData

                            property string myid: convert_top.favs[modelData]

                            width: favcol.width
                            height: favsrow.height+10
                            radius: 5

                            property bool hovered: favcol.currentHover===modelData
                            property bool isActive: convert_top.targetFormat===favdeleg.myid

                            color: isActive ? PQCLook.baseColorActive : (hovered ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent) // qmllint disable unqualified
                            Behavior on color { ColorAnimation { duration: 200 } }

                            Row {
                                id: favsrow
                                x: 5
                                y: 5
                                spacing: 10
                                PQText {
                                    text: "*." + PQCImageFormats.getFormatEndings(favdeleg.myid).join(", *.") // qmllint disable unqualified
                                    color: PQCLook.textColor // qmllint disable unqualified
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                PQTextS {
                                    y: (parent.height-height)/2
                                    font.italic: true
                                    text: "(" + PQCImageFormats.getFormatName(favdeleg.myid) + ")" // qmllint disable unqualified
                                    color: PQCLook.textColor // qmllint disable unqualified
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                            Image {
                                id: rem
                                x: parent.width-width-5-scroll.width
                                y: (parent.height-height)/2
                                width: 20
                                height: 20
                                property bool hovered: false
                                opacity: hovered ? 1 : 0.5
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                source: "image://svg/:/" + PQCLook.iconShade + "/star.svg" // qmllint disable unqualified
                                sourceSize: Qt.size(width, height)
                            }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("export", "Click to select this image format")
                                onEntered: {
                                    resetFavsHighlightIndex.stop()
                                    favcol.currentHover = favdeleg.modelData
                                }
                                onExited: {
                                    resetFavsHighlightIndex.oldIndex = favdeleg.modelData
                                    resetFavsHighlightIndex.restart()
                                }
                                onClicked: {
                                    convert_top.targetFormat = convert_top.favs[favdeleg.modelData]
                                    favcol.currentIndex = favdeleg.modelData
                                    formatsview.currentIndex = -1
                                }
                            }

                            PQMouseArea {
                                anchors.fill: rem
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: rem.hovered = true
                                onExited: rem.hovered = false
                                text: qsTranslate("export", "Click to remove this image format from your favorites")
                                onClicked: {
                                    var tmp = PQCSettings.extensions.ExportImageFavorites
                                    tmp.splice(favdeleg.modelData, 1)
                                    PQCSettings.extensions.ExportImageFavorites = tmp
                                }
                            }
                        }
                    }
                }

            }

        },

        Item {
            width: 1
            height: 20
        },

        /*************************************************/
        // then we list all available writable formats

        Rectangle {

            x: (parent.width-width)/2
            width: Math.min(600, convert_top.width-100)
            height: Math.min(400, convert_top.height-convert_top.bottomrowHeight-convert_top.toprowHeight-targettxt1.height-targettxt2.height-favs_item.height-120)

            color: PQCLook.baseColor // qmllint disable unqualified
            border.width: 1
            border.color: PQCLook.baseColorHighlight // qmllint disable unqualified

            ListView {

                id: formatsview

                anchors.fill: parent
                anchors.margins: 1

                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

                property list<var> thedata: PQCImageFormats.getWriteableFormats() // qmllint disable unqualified
                model: thedata.length

                clip: true

                property int currentHover: -1
                Timer {
                    id: resetCurrentHover
                    interval: 100
                    property int oldIndex
                    running: true
                    onTriggered: {
                        if(oldIndex === formatsview.currentHover)
                            formatsview.currentHover = -1
                    }
                }

                onCurrentHoverChanged: {
                    if(formatsview.currentHover !== -1) {
                        formatsview.positionViewAtIndex(formatsview.currentHover, ListView.Contain)
                        favcol.currentHover = -1
                    }
                }

                delegate: Rectangle {

                    id: deleg

                    required property int modelData

                    property list<var> curData: formatsview.thedata[modelData]
                    property string curUniqueid: curData[1]
                    property list<string> curEndings: curData[2].split(",")
                    property bool isFav: convert_top.favs.indexOf(curUniqueid)!==-1

                    property bool isActive: curUniqueid===convert_top.targetFormat
                    property bool isHover: formatsview.currentHover===modelData

                    width: formatsview.width
                    height: visible ? (formatsname.height+10) : 0
                    color: isActive ? PQCLook.baseColorActive : (isHover ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent) // qmllint disable unqualified
                    border.width: 1
                    border.color: "black"
                    radius: 5

                    Row {
                        id: formatsname
                        x: 5
                        y: 5
                        spacing: 10
                        PQText {
                            text: "*." + deleg.curEndings.join(", *.")
                            color: PQCLook.textColor // qmllint disable unqualified
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        PQTextS {
                            y: (parent.height-height)/2
                            font.italic: true
                            text: "(" + deleg.curData[3] + ")"
                            color: PQCLook.textColor // qmllint disable unqualified
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    Image {
                        id: favs_icon
                        x: (parent.width-width-5) - scroll.width
                        y: (parent.height-height)/2
                        height: formatsname.height
                        width: height
                        opacity: favmousearea.containsMouse ? 1 : 0.5
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        sourceSize: Qt.size(width, height)
                        source: deleg.isFav ? ("image://svg/:/" + PQCLook.iconShade + "/star.svg") : ("image://svg/:/" + PQCLook.iconShade + "/star_empty.svg") // qmllint disable unqualified
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: "<b>" + deleg.curData[3] + "</b><br>*." + deleg.curEndings.join(", *.") + "<br><br>" + qsTranslate("export", "Click to select this image format")
                        onEntered: {
                            resetCurrentHover.stop()
                            formatsview.currentHover = deleg.modelData
                        }
                        onExited: {
                            resetCurrentHover.oldIndex = deleg.modelData
                            resetCurrentHover.restart()
                        }

                        onClicked: {
                            formatsview.currentIndex = deleg.modelData
                            if(deleg.modelData !== -1)
                                convert_top.targetFormat = deleg.curUniqueid
                        }
                    }

                    PQMouseArea {
                        id: favmousearea
                        anchors.fill: favs_icon
                        anchors.margins: -5
                        cursorShape: Qt.PointingHandCursor
                        text: deleg.isFav ? qsTranslate("export", "Click to remove this image format from your favorites")
                                          : qsTranslate("export", "Click to add this image format to your favorites")
                        onClicked: {
                            var tmp = PQCSettings.extensions.ExportImageFavorites
                            if(isFav)
                                tmp.splice(tmp.indexOf(deleg.curUniqueid), 1)
                            else
                                tmp.push(deleg.curUniqueid)
                            PQCSettings.extensions.ExportImageFavorites = tmp
                        }
                    }

                }

            }

        },

        Item {
            width: 1
            height: 10
        },

        PQText {
            id: targettxt1
            x: (parent.width-width)/2
            //: The target format is the format the image is about to be exported to
            text: qsTranslate("export", "Selected target format:")
        },

        PQText {
            id: targettxt2
            x: (parent.width-width)/2
            text: (convert_top.targetFormat==="" ? "---" : PQCImageFormats.getFormatName(convert_top.targetFormat)) // qmllint disable unqualified
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        }

    ]

    PQWorking {
        id: exportbusy
    }

    Connections {
        target: PQCScriptsFileManagement // qmllint disable unqualified
        function onExportCompleted(success : bool) {
            if(success) {
                errormessage.visible = false
                exportbusy.showSuccess()
            } else {
                exportbusy.hide()
                errormessage.visible = true
            }
        }
    }

    Connections {
        target: exportbusy
        function onSuccessHidden() {
            convert_top.hide()
       }
    }

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onLoaderPassOn(what : string, param : list<var>) : void {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(what === "show" && param[0] === "exportimage") {

                convert_top.show()

            } else if(convert_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(convert_top.contextMenuOpen) {
                        convert_top.closeContextMenus()
                        return
                    }

                    // close something
                    if(param[0] === Qt.Key_Escape)

                        convert_top.hide()

                    // perform action
                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(convert_top.button1.enabled)
                            convert_top.button1.clicked()

                    // go up in the list
                    } else if(param[0] === Qt.Key_Up || param[0] === Qt.Key_Left) {

                        if(formatsview.currentHover === 0) {

                            favcol.currentHover = convert_top.favs.length-1

                        } else if(formatsview.currentHover > 0)

                            formatsview.currentHover -= 1

                        else if(formatsview.currentHover === -1) {

                            if(favcol.currentHover > 0)
                                favcol.currentHover -= 1

                            else if(favcol.currentHover === -1)
                                formatsview.currentHover = formatsview.count-1

                        }

                    // go down in the list
                    } else if(param[0] === Qt.Key_Down || param[0] === Qt.Key_Right) {

                        if(formatsview.currentHover == -1 && favcol.currentHover == -1)

                            favcol.currentHover = 0

                        else if(favcol.currentHover > -1 && favcol.currentHover < convert_top.favs.length-1)

                            favcol.currentHover += 1

                        else if(favcol.currentHover == convert_top.favs.length-1)

                            formatsview.currentHover = 0

                        else if(formatsview.currentHover < formatsview.count-1)

                            formatsview.currentHover += 1


                    // go to end of list
                    } else if(param[0] === Qt.Key_End) {

                        formatsview.currentHover = formatsview.count-1

                    // go to beginning of list
                    } else if(param[0] === Qt.Key_Home) {

                        favcol.currentHover = 0

                    // go 5 down
                    } else if(param[0] === Qt.Key_PageDown) {

                        if(formatsview.currentHover > -1)
                            formatsview.currentHover = Math.min(formatsview.currentHover+5, formatsview.count-1)

                        else {

                            if(favcol.currentHover+5 < convert_top.favs.length)
                                favcol.currentHover += 5
                            else
                                formatsview.currentHover = (favcol.currentHover+5) - convert_top.favs.length

                        }

                    // go 5 up
                    } else if(param[0] === Qt.Key_PageUp) {

                        if(favcol.currentHover > -1)
                            favcol.currentHover = Math.max(0, favcol.currentHover-5)

                        else if(formatsview.currentHover > -1) {

                            if(formatsview.currentHover-5 < 0)
                                favcol.currentHover = Math.max(0, convert_top.favs.length-(5-formatsview.currentHover))
                            else
                                formatsview.currentHover -= 5

                        } else
                            formatsview.currentHover = formatsview.count-5

                    // select currently hovered item
                    } else if(param[0] === Qt.Key_Space) {

                        if(favcol.currentHover > -1) {
                            convert_top.targetFormat = convert_top.favs[favcol.currentHover]
                            favcol.currentIndex = favcol.currentHover
                            formatsview.currentIndex = -1
                        } else if(formatsview.currentHover > -1) {
                            convert_top.targetFormat = formatsview.thedata[formatsview.currentHover][1]
                            formatsview.currentIndex = formatsview.currentHover
                            favcol.currentIndex = -1
                        }

                    }

                }

            }

        }
    }

    function show() {
        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) { // qmllint disable unqualified
            hide()
            return
        }
        exportbusy.hide()
        convert_top.opacity = 1
        if(popoutWindowUsed)
            export_popout.visible = true
    }

    function hide() {

        if(convert_top.contextMenuOpen)
            convert_top.closeContextMenus()

        convert_top.opacity = 0
        if(popoutWindowUsed && export_popout.visible)
            export_popout.visible = false // qmllint disable unqualified
        else
            PQCNotify.loaderRegisterClose(thisis)
    }

}
