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
import QtQuick.Controls
import QtQuick.Layouts

import PQCFileFolderModel
import PQCWindowGeometry

import "../elements"

PQTemplateFullscreen {

    id: advancedsort_top

    spacing: 20

    thisis: "advancedsort"
    popout: PQCSettings.interfacePopoutAdvancedSort
    forcePopout: PQCWindowGeometry.advancedsortForcePopout
    shortcut: "__advancedSort"
    title: qsTranslate("advancedsort", "Advanced image sort") + " | PhotoQt"

    button1.text: qsTranslate("advancedsort", "Sort images")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQCSettings.interfacePopoutAdvancedSort = popout

    button1.onClicked:
        doSorting()

    button2.onClicked:
        hide()

    signal loadData()
    signal saveData()

    content: [

        Row {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            spacing: 20

            Column {

                y: (parent.height-height)/2

                spacing: 10

                PQText {
                    width: 200
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTranslate("advancedsort", "Sorting criteria:")
                }

                PQTabBar {
                    id: bar
                    width: 200
                    //: The image resolution (width/height in pixels)
                    model: [qsTranslate("advancedsort", "Resolution"),
                            //: The color that is most common in the image
                            qsTranslate("advancedsort", "Dominant color"),
                            //: the average color of the image
                            qsTranslate("advancedsort", "Average color"),
                            //: the average color of the image
                            qsTranslate("advancedsort", "Luminosity"),
                            qsTranslate("advancedsort", "Exif date")]
                }

                Connections {

                    target: advancedsort_top

                    function onLoadData() {
                        var order = ["resolution", "dominantcolor", "averagecolor", "luminosity", "exifdate"]
                        var curindex = 0
                        for(var i = 0; i < order.length; ++i) {
                            if(order[i] === PQCSettings.imageviewAdvancedSortCriteria) {
                                curindex = i
                                break;
                            }
                        }
                        bar.currentIndex = curindex
                    }

                    function onSaveData() {
                        var order = ["resolution", "dominantcolor", "averagecolor", "luminosity", "exifdate"]
                        PQCSettings.imageviewAdvancedSortCriteria = order[bar.currentIndex]
                    }
                }

            }

            StackLayout {

                id: layout

                width: 400
                height: advancedsort_top.height-advancedsort_top.toprowHeight-advancedsort_top.bottomrowHeight

                currentIndex: bar.currentIndex

                /*******************************/
                // Tab 1

                Item {

                    y: (parent.height-height)/2
                    width: 400
                    height: Math.max(parent.height, col1.height)

                    Column {

                        id: col1
                        width: 400
                        y: (layout.height-height)/2

                        spacing: 5

                        PQTextXL {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTranslate("advancedsort", "Sort by image resolution")
                            font.weight: PQCLook.fontWeightBold
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        Column {

                            x: (parent.width-width)/2
                            spacing: 5

                            PQRadioButton {
                                id: asc1
                                //: as is: sort in ascending order
                                text: qsTranslate("advancedsort", "in ascending order")
                            }

                            PQRadioButton {
                                id: desc1
                                //: as is: sort in descending order
                                text: qsTranslate("advancedsort", "in descending order")
                            }
                        }

                    }

                    Connections {
                        target: advancedsort_top

                        function onLoadData() {
                            asc1.checked = (PQCSettings.imageviewAdvancedSortAscending)
                            desc1.checked = (!PQCSettings.imageviewAdvancedSortAscending)
                        }

                        function onSaveData() {
                            if(bar.currentIndex === 0) {
                                PQCSettings.imageviewAdvancedSortAscending = asc1.checked
                            }
                        }

                    }

                }

                /*******************************/
                // Tab 2

                Item {

                    y: (parent.height-height)/2
                    width: 400
                    height: Math.max(parent.height, col2.height)

                    Column {

                        id: col2
                        width: 400
                        y: (layout.height-height)/2

                        spacing: 5

                        PQTextXL {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTranslate("advancedsort", "Sort by dominant color")
                            font.weight: PQCLook.fontWeightBold
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        Column {

                            x: (parent.width-width)/2
                            spacing: 5

                            PQRadioButton {
                                id: asc2
                                text: qsTranslate("advancedsort", "in ascending order")
                            }

                            PQRadioButton {
                                id: desc2
                                text: qsTranslate("advancedsort", "in descending order")
                            }
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        PQComboBox {

                            id: qual2

                            x: (parent.width-width)/2

                                    //: quality and speed of advanced sorting of images
                            model: [qsTranslate("advancedsort", "low quality (fast)"),
                                    //: quality and speed of advanced sorting of images
                                    qsTranslate("advancedsort", "medium quality"),
                                    //: quality and speed of advanced sorting of images
                                    qsTranslate("advancedsort", "high quality (slow)")]

                        }

                    }

                    Connections {
                        target: advancedsort_top

                        function onLoadData() {
                            asc2.checked = (PQCSettings.imageviewAdvancedSortAscending)
                            desc2.checked = (!PQCSettings.imageviewAdvancedSortAscending)

                            qual2.currentIndex = (PQCSettings.imageviewAdvancedSortQuality==="low" ?
                                                      0 :
                                                      (PQCSettings.imageviewAdvancedSortQuality==="high" ?
                                                           2 :
                                                           1))
                        }

                        function onSaveData() {
                            if(bar.currentIndex === 1) {
                                PQCSettings.imageviewAdvancedSortAscending = asc2.checked
                                PQCSettings.imageviewAdvancedSortQuality = (qual2.currentIndex === 0 ?
                                                                                "low" :
                                                                                qual2.currentIndex===1 ?
                                                                                    "medium" :
                                                                                    "high")
                            }
                        }

                    }

                }

                /*******************************/
                // Tab 3

                Item {

                    y: (parent.height-height)/2
                    width: 400
                    height: Math.max(parent.height, col3.height)

                    Column {

                        id: col3
                        width: 400
                        y: (layout.height-height)/2

                        spacing: 5

                        PQTextXL {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTranslate("advancedsort", "Sort by average color")
                            font.weight: PQCLook.fontWeightBold
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        Column {

                            x: (parent.width-width)/2
                            spacing: 5

                            PQRadioButton {
                                id: asc3
                                text: qsTranslate("advancedsort", "in ascending order")
                            }

                            PQRadioButton {
                                id: desc3
                                text: qsTranslate("advancedsort", "in descending order")
                            }
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        PQComboBox {

                            id: qual3

                            x: (parent.width-width)/2

                            model: [qsTranslate("advancedsort", "low quality (fast)"),
                                    qsTranslate("advancedsort", "medium quality"),
                                    qsTranslate("advancedsort", "high quality (slow)")]

                        }

                    }

                    Connections {

                        target: advancedsort_top

                        function onLoadData() {
                            asc3.checked = (PQCSettings.imageviewAdvancedSortAscending)
                            desc3.checked = (!PQCSettings.imageviewAdvancedSortAscending)

                            qual3.currentIndex = (PQCSettings.imageviewAdvancedSortQuality==="low" ?
                                                      0 :
                                                      (PQCSettings.imageviewAdvancedSortQuality==="high" ?
                                                           2 :
                                                           1))
                        }

                        function onSaveData() {
                            if(bar.currentIndex === 2) {
                                PQCSettings.imageviewAdvancedSortAscending = asc3.checked
                                PQCSettings.imageviewAdvancedSortQuality = (qual3.currentIndex === 0 ?
                                                                                "low" :
                                                                                qual3.currentIndex===1 ?
                                                                                    "medium" :
                                                                                    "high")
                            }
                        }
                    }

                }

                /*******************************/
                // Tab 4

                Item {

                    y: (parent.height-height)/2
                    width: 400
                    height: Math.max(parent.height, col4.height)

                    Column {

                        id: col4
                        width: 400
                        y: (layout.height-height)/2

                        spacing: 5

                        PQTextXL {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTranslate("advancedsort", "Sort by luminosity")
                            font.weight: PQCLook.fontWeightBold
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        Column {

                            x: (parent.width-width)/2
                            spacing: 5

                            PQRadioButton {
                                id: asc4
                                text: qsTranslate("advancedsort", "in ascending order")
                            }

                            PQRadioButton {
                                id: desc4
                                text: qsTranslate("advancedsort", "in descending order")
                            }
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        PQComboBox {

                            id: qual4

                            x: (parent.width-width)/2

                            model: [qsTranslate("advancedsort", "low quality (fast)"),
                                    qsTranslate("advancedsort", "medium quality"),
                                    qsTranslate("advancedsort", "high quality (slow)")]

                        }

                    }

                    Connections {

                        target: advancedsort_top

                        function onLoadData() {
                            asc4.checked = (PQCSettings.imageviewAdvancedSortAscending)
                            desc4.checked = (!PQCSettings.imageviewAdvancedSortAscending)

                            qual4.currentIndex = (PQCSettings.imageviewAdvancedSortQuality==="low" ?
                                                      0 :
                                                      (PQCSettings.imageviewAdvancedSortQuality==="high" ?
                                                           2 :
                                                           1))
                        }

                        function onSaveData() {
                            if(bar.currentIndex === 3) {
                                PQCSettings.imageviewAdvancedSortAscending = asc4.checked
                                PQCSettings.imageviewAdvancedSortQuality = (qual4.currentIndex === 0 ?
                                                                                "low" :
                                                                                qual4.currentIndex===1 ?
                                                                                    "medium" :
                                                                                    "high")
                            }
                        }

                    }

                }

                /*******************************/
                // Tab 5

                Item {

                    y: (parent.height-height)/2
                    width: 400
                    height: 300//Math.min(parent.height, Math.max(parent.height, col5.height))

                    Column {

                        id: col5
                        y: (parent.height-height)/2
                        width: 400

                        spacing: 5

                        PQTextXL {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTranslate("advancedsort", "Sort by date")
                            font.weight: PQCLook.fontWeightBold
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        Column {

                            x: (parent.width-width)/2
                            spacing: 5

                            PQRadioButton {
                                id: asc5
                                text: qsTranslate("advancedsort", "in ascending order")
                            }

                            PQRadioButton {
                                id: desc5
                                text: qsTranslate("advancedsort", "in descending order")
                            }
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        PQText {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTranslate("advancedsort", "Order of priority:")
                            font.weight: PQCLook.fontWeightBold
                        }

                        ListView {

                            id: exifsort

                            width: 400
                            height: 4*45
                            interactive: false

                            property var ordering: [
                                [qsTranslate("advancedsort", "Exif tag: Original date/time"), "exiforiginal"],
                                [qsTranslate("advancedsort", "Exif tag: Digitized date/time"), "exifdigital"],
                                [qsTranslate("advancedsort", "File creation date"), "filecreation"],
                                [qsTranslate("advancedsort", "File modification date"), "filemodification"]
                            ]

                            model: 4

                            spacing: 5

                            delegate: Rectangle {
                                width: 400
                                height: 40
                                color: PQCLook.baseColorHighlight

                                PQText {
                                    x: 10
                                    height: parent.height
                                    width: parent.width-2*height-30
                                    verticalAlignment: Text.AlignVCenter
                                    text: (index+1) + ". " + exifsort.ordering[index][0]
                                }

                                Image {
                                    x: parent.width-2*width-5
                                    y: (parent.height-height)/2
                                    width: parent.height*0.6
                                    height: width
                                    source: "image://svg/:/white/upwards.svg"
                                    sourceSize: Qt.size(width, height)
                                    enabled: index>0
                                    opacity: enabled ? 1 : 0.5
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if(index > 0) {
                                                exifsort.ordering[index-1] = exifsort.ordering.splice(index, 1, exifsort.ordering[index-1])[0]
                                                exifsort.orderingChanged()
                                            }
                                        }
                                    }
                                }

                                Image {
                                    x: parent.width-width-5
                                    y: (parent.height-height)/2
                                    width: parent.height*0.6
                                    height: width
                                    rotation: 180
                                    source: "image://svg/:/white/upwards.svg"
                                    sourceSize: Qt.size(width, height)
                                    enabled: index<3
                                    opacity: enabled ? 1 : 0.5
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if(index < 3) {
                                                exifsort.ordering[index+1] = exifsort.ordering.splice(index, 1, exifsort.ordering[index+1])[0]
                                                exifsort.orderingChanged()
                                            }
                                        }
                                    }
                                }


                            }

                        }

                        PQText {
                            width: 400
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTranslate("advancedsort", "If a value cannot be found, PhotoQt will proceed to the next item in the list.")
                        }
                    }

                    Connections {

                        target: advancedsort_top

                        function onLoadData() {

                            asc5.checked = (PQCSettings.imageviewAdvancedSortAscending)
                            desc5.checked = (!PQCSettings.imageviewAdvancedSortAscending)

                            var neworder = []
                            for(var j = 0; j < PQCSettings.imageviewAdvancedSortDateCriteria.length; ++j) {

                                var foundindex = 0
                                for(var k = 0; k < 4; ++k) {

                                    if(exifsort.ordering[k][1] === PQCSettings.imageviewAdvancedSortDateCriteria[j]) {
                                        foundindex = k
                                        break
                                    }
                                }
                                neworder.push(exifsort.ordering[k])
                            }
                            exifsort.ordering = neworder
                        }

                        function onSaveData() {
                            if(bar.currentIndex === 4) {
                                PQCSettings.imageviewAdvancedSortAscending = asc5.checked

                                var save = []
                                for(var i = 0; i < exifsort.ordering.length; ++i)
                                    save.push(exifsort.ordering[i][1])
                                PQCSettings.imageviewAdvancedSortDateCriteria = save
                            }
                        }

                    }

                }

            }

        }

    ]

    PQWorking {
        id: working

        PQText {
            id: progress
            anchors.centerIn: parent
            font.weight: PQCLook.fontWeightBold

            property int current: 0
            property int total: 0

            text: PQCFileFolderModel.advancedSortDone+"/" + PQCFileFolderModel.countMainView
        }

        PQButton {
            id: workingcancel
            text: genericStringCancel
            x: (parent.width-width)/2
            y: (parent.height-height)/2 + 200
            onClicked: {
                PQCFileFolderModel.advancedSortMainViewCANCEL()
                working.hide()
            }
        }

    }

    Connections {
        target: loader
        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(advancedsort_top.visible) {

                if(working.visible) {

                    if(param[0] === Qt.Key_Escape || param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        workingcancel.clicked()

                } else {

                    if(what === "keyEvent") {

                        if(param[0] === Qt.Key_Escape)
                            hide()

                        else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                            doSorting()

                        else if(param[0] === Qt.Key_Up || param[0] === Qt.Key_Left)
                            bar.currentIndex = (bar.currentIndex+bar.model.length-1)%bar.model.length

                        else if(param[0] === Qt.Key_Down || param[0] === Qt.Key_Right)
                            bar.currentIndex = (bar.currentIndex+1)%bar.model.length

                    }

                }

            }
        }
    }

    Connections {

        target: PQCFileFolderModel

        function onAdvancedSortingComplete() {
            working.hide()
            hide()
        }

    }

    function doSorting() {

        advancedsort_top.saveData()

        PQCFileFolderModel.advancedSortMainView()
        working.showBusy()

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }
        working.hide()
        opacity = 1
        if(popoutWindowUsed)
            advancedsort_popout.visible = true
        advancedsort_top.loadData()

    }

    function hide() {

        opacity = 0
        if(popoutWindowUsed)
            advancedsort_popout.visible = false
        loader.elementClosed(thisis)

    }

}

