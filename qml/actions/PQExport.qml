import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import PQCNotify
import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsFileManagement

import "../elements"

PQTemplateFullscreen {

    id: convert_top

    thisis: "export"
    popout: PQCSettings.interfacePopoutExport
    shortcut: "__export"

    //: title of action element
    title: qsTranslate("export", "Export image")

    //: written on button
    button1.text: qsTranslate("export", "Export")
    button1.enabled: targetFormat!==""
    button2.visible: true
    button2.text: genericStringCancel

    button1.onClicked: {
        PQCSettings.exportLastUsed = targetFormat
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
        PQCSettings.interfacePopoutExport = popout

    /***************************************************************/

    // the favs are shown on a label and are used to identify the respective entry in the listview
    property var favs: PQCSettings.exportFavorites

    // this is the selected format, both the first ending (for identification) and all endings for a format
    property string targetFormat: PQCSettings.exportLastUsed

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
            font.weight: PQCLook.fontWeightBold
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
                    color: PQCLook.textColorHighlight
                    font.weight: PQCLook.fontWeightBold
                    font.italic: true
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    //: the favorites are image formats for exporting images to
                    text: " " + qsTranslate("export", "no favorites set")
                    visible: favs.length===0
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

                        model: favs.length

                        Rectangle {

                            id: favdeleg

                            property string myid: favs[index]

                            width: favcol.width
                            height: favsrow.height+10
                            radius: 5

                            property bool hovered: favcol.currentHover===index
                            property bool isActive: targetFormat===favdeleg.myid

                            color: isActive ? PQCLook.baseColorActive : (hovered ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent)
                            Behavior on color { ColorAnimation { duration: 200 } }

                            Row {
                                id: favsrow
                                x: 5
                                y: 5
                                spacing: 10
                                PQText {
                                    text: "*." + PQCImageFormats.getFormatEndings(favdeleg.myid).join(", *.")
                                    color: favdeleg.isActive ? PQCLook.textColorActive : PQCLook.textColor
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                PQTextS {
                                    y: (parent.height-height)/2
                                    font.italic: true
                                    text: "(" + PQCImageFormats.getFormatName(favdeleg.myid) + ")"
                                    color: favdeleg.isActive ? PQCLook.textColorActive : PQCLook.textColor
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
                                source: "/white/star.svg"
                                sourceSize: Qt.size(width, height)
                            }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("export", "Click to select this image format")
                                onEntered: {
                                    resetFavsHighlightIndex.stop()
                                    favcol.currentHover = index
                                }
                                onExited: {
                                    resetFavsHighlightIndex.oldIndex = index
                                    resetFavsHighlightIndex.restart()
                                }
                                onClicked: {
                                    targetFormat = favs[index]
                                    favcol.currentIndex = index
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
                                    var tmp = PQCSettings.exportFavorites
                                    tmp.splice(index, 1)
                                    PQCSettings.exportFavorites = tmp
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
            height: Math.min(400, convert_top.height-bottomrowHeight-toprowHeight-targettxt1.height-targettxt2.height-favs_item.height-120)

            color: PQCLook.baseColor
            border.width: 1
            border.color: PQCLook.baseColorHighlight

            ListView {

                id: formatsview

                anchors.fill: parent
                anchors.margins: 1

                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

                property var data: PQCImageFormats.getWriteableFormats()
                model: data.length

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

                    property var curData: formatsview.data[index]
                    property string curUniqueid: curData[1]
                    property var curEndings: curData[2].split(",")
                    property bool isFav: favs.indexOf(curUniqueid)!==-1

                    property bool isActive: curUniqueid===targetFormat
                    property bool isHover: formatsview.currentHover===index

                    width: formatsview.width
                    height: visible ? (formatsname.height+10) : 0
                    color: isActive ? PQCLook.baseColorActive : (isHover ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent)
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
                            color: isActive ? PQCLook.textColorActive : PQCLook.textColor
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        PQTextS {
                            y: (parent.height-height)/2
                            font.italic: true
                            text: "(" + curData[3] + ")"
                            color: isActive ? PQCLook.textColorActive : PQCLook.textColor
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
                        source: isFav ? "/white/star.svg" : "/white/star_empty.svg"
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: "<b>" + curData[3] + "</b><br>*." + deleg.curEndings.join(", *.") + "<br><br>" + qsTranslate("export", "Click to select this image format")
                        onEntered: {
                            resetCurrentHover.stop()
                            formatsview.currentHover = index
                        }
                        onExited: {
                            resetCurrentHover.oldIndex = index
                            resetCurrentHover.restart()
                        }

                        onClicked: {
                            formatsview.currentIndex = index
                            if(index !== -1)
                                targetFormat = deleg.curUniqueid
                        }
                    }

                    PQMouseArea {
                        id: favmousearea
                        anchors.fill: favs_icon
                        anchors.margins: -5
                        cursorShape: Qt.PointingHandCursor
                        text: isFav ? qsTranslate("export", "Click to remove this image format from your favorites")
                                    : qsTranslate("export", "Click to add this image format to your favorites")
                        onClicked: {
                            var tmp = PQCSettings.exportFavorites
                            if(isFav)
                                tmp.splice(tmp.indexOf(deleg.curUniqueid), 1)
                            else
                                tmp.push(deleg.curUniqueid)
                            PQCSettings.exportFavorites = tmp
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
            text: (targetFormat==="" ? "---" : PQCImageFormats.getFormatName(targetFormat))
            font.weight: PQCLook.fontWeightBold
        }

    ]

    PQBusy {
        id: exportbusy
    }

    Connections {
        target: PQCScriptsFileManagement
        function onExportCompleted(success) {
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
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {
                if(param === thisis)
                    show()
            } else if(convert_top.opacity > 0) {

                if(what === "keyEvent") {

                    // close something
                    if(param[0] === Qt.Key_Escape)

                        hide()

                    // perform action
                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(button1.enabled)
                            button1.clicked()

                    // go up in the list
                    } else if(param[0] === Qt.Key_Up || param[0] === Qt.Key_Left) {

                        if(formatsview.currentHover === 0) {

                            favcol.currentHover = favs.length-1

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

                        else if(favcol.currentHover > -1 && favcol.currentHover < favs.length-1)

                            favcol.currentHover += 1

                        else if(favcol.currentHover == favs.length-1)

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

                            if(favcol.currentHover+5 < favs.length)
                                favcol.currentHover += 5
                            else
                                formatsview.currentHover = (favcol.currentHover+5) - favs.length

                        }

                    // go 5 up
                    } else if(param[0] === Qt.Key_PageUp) {

                        if(favcol.currentHover > -1)
                            favcol.currentHover = Math.max(0, favcol.currentHover-5)

                        else if(formatsview.currentHover > -1) {

                            if(formatsview.currentHover-5 < 0)
                                favcol.currentHover = Math.max(0, favs.length-(5-formatsview.currentHover))
                            else
                                formatsview.currentHover -= 5

                        } else
                            formatsview.currentHover = formatsview.count-5

                    // select currently hovered item
                    } else if(param[0] === Qt.Key_Space) {

                        if(favcol.currentHover > -1) {
                            targetFormat = favs[favcol.currentHover]
                            favcol.currentIndex = favcol.currentHover
                            formatsview.currentIndex = -1
                        } else if(formatsview.currentHover > -1) {
                            targetFormat = formatsview.data[formatsview.currentHover][1]
                            formatsview.currentIndex = formatsview.currentHover
                            favcol.currentIndex = -1
                        }

                    }

                }

            }

        }
    }

    function show() {
        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }
        exportbusy.hide()
        convert_top.opacity = 1
        if(PQCSettings.interfacePopoutExport && !exportpopout_top.visible)
            exportpopout_top.show()
    }

    function hide() {
        convert_top.opacity = 0
        loader.elementClosed(thisis)
    }

}
