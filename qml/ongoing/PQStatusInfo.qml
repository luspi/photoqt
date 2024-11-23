pragma ComponentBehavior: Bound
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
import QtQuick.Window
import QtQuick.Controls

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCScriptsChromeCast
import PQCScriptsConfig
import PQCScriptsOther

import "../elements"
import "../manage"
import "../image"

Item {

    id: statusinfo_top

    x: 2*distanceFromEdge
    y: distanceFromEdge

    Behavior on y { NumberAnimation { duration: (PQCSettings.interfaceStatusInfoAutoHide || PQCSettings.interfaceStatusInfoAutoHideTopEdge || statusinfo_top.movedByMouse) ? 200 : 0 } } // qmllint disable unqualified
    Behavior on x { NumberAnimation { duration: (statusinfo_top.movedByMouse) ? 200 : 0 } }

    property bool movedByMouse: false

    opacity: (!(PQCNotify.slideshowRunning && PQCSettings.slideshowHideLabels) && !PQCNotify.faceTagging && PQCSettings.interfaceStatusInfoShow) ? 1 : 0 // qmllint disable unqualified
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    width: maincol.width
    height: maincol.height

    // possible values: counter, filename, filepathname, resolution, zoom, rotation
    property list<string> info: PQCSettings.interfaceStatusInfoList // qmllint disable unqualified

    property int distanceFromEdge: 20

    property alias radius: maincontainer.radius

    PQShadowEffect { masterItem: statusinfo_top }

    property PQLoader access_loader: loader // qmllint disable unqualified
    property PQImage access_image: image // qmllint disable unqualified

    // don't pass mouse clicks to background
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onPressed: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.item.popup() // qmllint disable missing-property
        }
    }

    state: (!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge && PQCSettings.interfaceStatusInfoShow) ? // qmllint disable unqualified
               "visible" :
               "hidden"

    onStateChanged: {
        if(state === "hidden" && menu.item !== null)
            menu.item.dismiss() // qmllint disable missing-property
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                statusinfo_top.y: statusinfo_top.distanceFromEdge
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                statusinfo_top.y: -statusinfo_top.height-5
            }
        }
    ]

    Column {

        id: maincol

        spacing: 10

        Rectangle {

            id: maincontainer

            color: PQCLook.baseColor // qmllint disable unqualified

            width: row.width+40
            height: row.height+20

            radius: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 5 // qmllint disable unqualified

            Row {

                id: row

                x: 20
                y: 10

                spacing: 10

                Repeater {

                    model: PQCFileFolderModel.countMainView===0 ? 1 : statusinfo_top.info.length // qmllint disable unqualified

                    Item {

                        id: deleg

                        required property int modelData

                        width: childrenRect.width
                        height: childrenRect.height

                        Row {

                            spacing: 10

                            Loader {
                                id: ldr
                                property string t: statusinfo_top.info[deleg.modelData]
                                sourceComponent: PQCFileFolderModel.countMainView===0 ? // qmllint disable unqualified
                                                   rectNoImages :
                                                   t=="counter" ?
                                                       rectCounter :
                                                       t=="filename" ?
                                                           rectFilename :
                                                           t=="filepathname" ?
                                                               rectFilepath :
                                                               t=="resolution" ?
                                                                   rectResolution :
                                                                   t=="zoom" ?
                                                                       rectZoom :
                                                                       t=="rotation" ?
                                                                           rectRotation :
                                                                           t=="filesize" ?
                                                                               rectFilesize :
                                                                               t=="colorprofile" ?
                                                                                   rectColorProfile :
                                                                                   rectDummy
                            }

                            Rectangle {
                                height: ldr.height
                                width: 1
                                color: PQCLook.textColorDisabled // qmllint disable unqualified
                                visible: deleg.modelData<statusinfo_top.info.length-1 && PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
                            }

                        }

                    }

                }

            }

            PQMouseArea {
                anchors.fill: parent
                drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : statusinfo_top // qmllint disable unqualified
                hoverEnabled: true
                text: PQCSettings.interfaceStatusInfoManageWindow ? // qmllint disable unqualified
                          qsTranslate("statusinfo", "Click and drag to move window around") :
                          qsTranslate("statusinfo", "Click and drag to move status info around")
                onWheel: (wheel) => {
                    wheel.accepted = true
                }
                onPressed: {
                    if(PQCSettings.interfaceStatusInfoManageWindow) // qmllint disable unqualified
                        toplevel.startSystemMove()
                }
                onDoubleClicked: {
                    if(PQCSettings.interfaceStatusInfoManageWindow) { // qmllint disable unqualified
                        if(toplevel.visibility === Window.Maximized)
                            toplevel.visibility = Window.Windowed
                        else if(toplevel.visibility === Window.Windowed)
                            toplevel.visibility = Window.Maximized
                    }
                }
                drag.onActiveChanged:
                    statusinfo_top.movedByMouse = true

            }

        }

        Rectangle {

            id: filterrect

            property bool filterset: false

            color: PQCLook.baseColor // qmllint disable unqualified

            width: filterrow.width+30
            height: filterrow.height+20

            opacity: filterset ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

            radius: 5

            PQMouseArea {
                anchors.fill: parent
                drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : statusinfo_top // qmllint disable unqualified
                hoverEnabled: true
                text: PQCSettings.interfaceStatusInfoManageWindow ? // qmllint disable unqualified
                          "" :
                          qsTranslate("statusinfo", "Click and drag to move status info around")
                onWheel: (wheel) => {
                    wheel.accepted = true
                }
                drag.onActiveChanged:
                    statusinfo_top.movedByMouse = true
            }

            Row {

                id: filterrow

                x: 10
                y: 10

                spacing: 10

                Image {
                    y: (parent.height-height)/2
                    width: filtertxt.height/2
                    height: width
                    source: "image://svg/:/" + PQCLook.iconShade + "/x.svg" // qmllint disable unqualified
                    sourceSize: Qt.size(width, height)
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("statusinfo", "Click to remove filter")
                        onClicked: {
                            PQCFileFolderModel.removeAllUserFilter() // qmllint disable unqualified
                        }
                    }
                }

                PQText {
                    id: filtertxt

                    Connections {
                        target: PQCFileFolderModel // qmllint disable unqualified
                        function onFilenameFiltersChanged() {
                            filtertxt.composeText()
                        }
                        function onNameFiltersChanged() {
                            filtertxt.composeText()
                        }
                        function onImageResolutionFilterChanged() {
                            filtertxt.composeText()
                        }
                        function onFileSizeFilterChanged() {
                            filtertxt.composeText()
                        }
                    }

                    function composeText() {

                        var txt = []

                        var txt1 = PQCFileFolderModel.filenameFilters.join(" ") // qmllint disable unqualified
                        if(txt1 !== "") txt.push(txt1)

                        var txt2 = ""
                        if(PQCFileFolderModel.nameFilters.length > 0)
                            txt2 += "."
                        txt2 += PQCFileFolderModel.nameFilters.join(" .")
                        if(txt2 !== "") txt.push(txt2)

                        var txt3 = ""
                        if(PQCFileFolderModel.imageResolutionFilter.width!==0 || PQCFileFolderModel.imageResolutionFilter.height!==0) {
                            var w = Math.abs(PQCFileFolderModel.imageResolutionFilter.width)
                            var h = Math.abs(PQCFileFolderModel.imageResolutionFilter.height)
                            txt3 += ((PQCFileFolderModel.imageResolutionFilter.width < 0) ? "&lt; " : "&gt; ")
                            txt3 += w+"x"+h
                            if(txt3 !== "") txt.push(txt3)
                        }

                        var txt4 = ""
                        if(PQCFileFolderModel.fileSizeFilter !== 0) {
                            txt4 += ((PQCFileFolderModel.fileSizeFilter < 0) ? "&lt; " : "&gt; ")
                            var s = Math.abs(PQCFileFolderModel.fileSizeFilter)
                            var mb = Math.round(s/(1024*1024))
                            var kb = Math.round(s/1024)
                            if(mb*1024*1024 === s)
                                txt4 += mb + " MB"
                             else
                                txt4 += kb + " KB"
                            if(txt4 !== "") txt.push(txt4)
                        }

                        filterrect.filterset = txt.length>0

                        //: This refers to the currently set filter
                        text = "<b>" + qsTranslate("statusinfo", "Filter:") + "</b>&nbsp;&nbsp;" + txt.join("&nbsp;&nbsp;|&nbsp;&nbsp;")

                    }
                }

            }

        }

        Rectangle {

            id: viewermode

            width: 50
            height: width
            color: PQCLook.baseColor // qmllint disable unqualified
            radius: 5

            opacity: (!PQCNotify.slideshowRunning && (currentIsPDF||currentIsARC)) ? 1 : 0 // qmllint disable unqualified
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

            property bool currentIsPDF: false
            property bool currentIsARC: false

            Image {
                anchors.fill: parent
                anchors.margins: 5
                sourceSize: Qt.size(width, height)
                source: (PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC) ? ("image://svg/:/" + PQCLook.iconShade + "/viewermode_off.svg") : ("image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg") // qmllint disable unqualified
                mipmap: true
            }

            PQMouseArea {
                anchors.fill: parent
                drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : statusinfo_top // qmllint disable unqualified
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: PQCSettings.interfaceStatusInfoManageWindow ? // qmllint disable unqualified
                          "" :
                          qsTranslate("statusinfo", "Click and drag to move status info around")
                onWheel: (wheel) => {
                    wheel.accepted = true
                }
                onClicked: {
                    if(PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC) // qmllint disable unqualified
                        PQCFileFolderModel.disableViewerMode()
                    else {
                        PQCFileFolderModel.enableViewerMode(statusinfo_top.access_image.currentFileInside)
                    }
                }
                drag.onActiveChanged:
                    statusinfo_top.movedByMouse = true
            }

            Connections {
                target: PQCFileFolderModel // qmllint disable unqualified

                function onCurrentFileChanged() {

                    viewermode.currentIsPDF = (PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile) && // qmllint disable unqualified
                                               (PQCFileFolderModel.isPDF || PQCScriptsImages.getNumberDocumentPages(PQCFileFolderModel.currentFile)))

                    viewermode.currentIsARC = (PQCScriptsImages.isArchive(PQCFileFolderModel.currentFile))

                }

            }

        }

    }

    Image {
        source: "image://svg/:/other/chromecastactive.svg"
        width: 32
        height: 32
        opacity: PQCScriptsChromeCast.connected ? 1 : 0 // qmllint disable unqualified
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0
        sourceSize: Qt.size(width, height)
        anchors.left: maincol.right
        anchors.top: maincol.top
        anchors.leftMargin: 10
        anchors.topMargin: (maincontainer.height-height)/2
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            //: Used in tooltip for the chromecast icon
            text: qsTranslate("statusinfo","Connected to:") + " " + PQCScriptsChromeCast.curDeviceName // qmllint disable unqualified
            onClicked:
                statusinfo_top.access_loader.show("chromecastmanager", undefined)
        }
    }

    Component {
        id: rectNoImages
        PQText {
            text: qsTranslate("statusinfo", "Click anywhere to open a file")
        }
    }

    Component {
        id: rectCounter
        PQText {
            text: (PQCFileFolderModel.currentIndex+1) + "/" + PQCFileFolderModel.countMainView // qmllint disable unqualified
        }
    }

    Component {
        id: rectFilename
        PQText {
            text: PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile) // qmllint disable unqualified
        }
    }

    Component {
        id: rectFilepath
        PQText {
            text: PQCFileFolderModel.currentFile // qmllint disable unqualified
        }
    }

    Component {
        id: rectZoom
        PQText {
            text: Math.round(toplevel.getDevicePixelRatio() * statusinfo_top.access_image.currentScale*100)+"%" // qmllint disable unqualified
        }
    }

    Component {
        id: rectRotation
        PQText {
            text: (Math.round(statusinfo_top.access_image.currentRotation)%360+360)%360 + "°"
        }
    }

    Component {
        id: rectResolution
        Row {
            spacing: 2
            PQText {
                text: statusinfo_top.access_image.currentResolution.width
            }
            PQText {
                opacity: 0.7
                text: "x"
            }
            PQText {
                text: statusinfo_top.access_image.currentResolution.height
            }
        }
    }

    Component {
        id: rectFilesize
        PQText {
            text: PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFile) // qmllint disable unqualified
        }
    }

    Component {
        id: rectColorProfile
        PQText {
            id: csptxt
            Behavior on color { ColorAnimation { duration: 200 } }
            Component.onCompleted: {
                var val = PQCNotify.getColorProfileFor(PQCFileFolderModel.currentFile) // qmllint disable unqualified
                if(val !== "") {
                    csptxt.text = val
                    csptxt.color = PQCLook.textColor
                } else {
                    csptxt.text = "---"
                    csptxt.color = PQCLook.textColorDisabled
                }
            }

            Connections {
                target: PQCNotify // qmllint disable unqualified
                function onColorProfilesChanged() {
                    var val = PQCNotify.getColorProfileFor(PQCFileFolderModel.currentFile) // qmllint disable unqualified
                    if(val !== "") {
                        csptxt.text = val
                        csptxt.color = PQCLook.textColor
                    } else {
                        csptxt.text = "---"
                        csptxt.color = PQCLook.textColorDisabled
                    }
                }
            }
            Connections {
                target: PQCFileFolderModel // qmllint disable unqualified
                function onCurrentFileChanged() {
                    if(PQCScriptsImages.isMpvVideo(PQCFileFolderModel.currentFile) || PQCScriptsImages.isQtVideo(PQCFileFolderModel.currentFile)) { // qmllint disable unqualified
                        csptxt.color = PQCLook.textColorDisabled
                        loadVideoColorInfo.restart()
                    } else if(PQCScriptsImages.isItAnimated(PQCFileFolderModel.currentFile)) {
                        csptxt.color = PQCLook.textColor
                        csptxt.text = "sRGB"
                    } else {
                        var val = PQCNotify.getColorProfileFor(PQCFileFolderModel.currentFile)
                        if(val !== "") {
                            csptxt.color = PQCLook.textColor
                            csptxt.text = val
                        } else {
                            csptxt.text = "---"
                            csptxt.color = PQCLook.textColorDisabled
                        }
                    }
                }
            }
            Timer {
                id: loadVideoColorInfo
                interval: 1
                onTriggered: {
                    var val = PQCScriptsImages.detectVideoColorProfile(PQCFileFolderModel.currentFile) // qmllint disable unqualified
                    csptxt.color = PQCLook.textColor
                    if(val === "")
                        val = qsTranslate("statusinfo", "unknown color profile")
                    csptxt.text = val
                }
            }
        }
    }

    Component {
        id: rectDummy
        PQText {
            text: "[???]"
        }
    }

    ButtonGroup { id: grp }

    Loader {
        id: menu
        asynchronous: true
        sourceComponent:
            PQMenu {

            id: menuitem

                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "show")
                    checked: PQCSettings.interfaceStatusInfoShow // qmllint disable unqualified
                    onCheckedChanged: {
                        PQCSettings.interfaceStatusInfoShow = checked // qmllint disable unqualified
                        if(!checked)
                            menuitem.dismiss()
                    }
                }
                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager",  "manage window")
                    checked: PQCSettings.interfaceStatusInfoManageWindow // qmllint disable unqualified
                    onCheckedChanged:
                        PQCSettings.interfaceStatusInfoManageWindow = checked // qmllint disable unqualified
                }
                PQMenuSeparator {}
                PQMenuItem {
                    enabled: false
                    moveToRightABit: true
                    text: "visibility:"
                }

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "always")
                    ButtonGroup.group: grp
                    checked: !PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceStatusInfoAutoHide = false // qmllint disable unqualified
                            PQCSettings.interfaceStatusInfoAutoHideTopEdge = false
                        }
                    }
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "cursor move")
                    ButtonGroup.group: grp
                    checked: PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceStatusInfoAutoHide = true // qmllint disable unqualified
                            PQCSettings.interfaceStatusInfoAutoHideTopEdge = false
                        }
                    }
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "cursor near top edge")
                    ButtonGroup.group: grp
                    checked: PQCSettings.interfaceStatusInfoAutoHideTopEdge // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceStatusInfoAutoHide = false // qmllint disable unqualified
                            PQCSettings.interfaceStatusInfoAutoHideTopEdge = true
                        }
                    }
                }

                onAboutToHide:
                    recordAsClosed.restart()
                onAboutToShow:
                    PQCNotify.addToWhichContextMenusOpen("statusinfo") // qmllint disable unqualified

                Timer {
                    id: recordAsClosed
                    interval: 200
                    onTriggered:
                        PQCNotify.removeFromWhichContextMenusOpen("statusinfo") // qmllint disable unqualified
                }
            }
    }

    property bool nearTopEdge: false

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onMouseMove(posx : int, posy : int) {

            if((!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge) || statusinfo_top.access_loader.visibleItem !== "") { // qmllint disable unqualified
                resetAutoHide.stop()
                statusinfo_top.state = "visible"
                statusinfo_top.nearTopEdge = true
                return
            }

            var trigger = PQCSettings.interfaceHotEdgeSize*5
            if(PQCSettings.interfaceEdgeTopAction !== "")
                trigger *= 2

            if((posy < trigger && PQCSettings.interfaceStatusInfoAutoHideTopEdge) || !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
                statusinfo_top.state = "visible"

            statusinfo_top.nearTopEdge = (posy < trigger)

            if(!statusinfo_top.nearTopEdge && (!resetAutoHide.running || PQCSettings.interfaceStatusInfoAutoHide))
                resetAutoHide.restart()

        }

        function onCloseAllContextMenus() {
            menu.item.dismiss() // qmllint disable missing-property
        }

    }

    Connections {

        target: PQCFileFolderModel // qmllint disable unqualified

        function onCurrentIndexChanged() {

            if(PQCSettings.interfaceStatusInfoAutoHideTimeout === 0 || // qmllint disable unqualified
                    (!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge) ||
                    !PQCSettings.interfaceStatusInfoShowImageChange)
                return

            statusinfo_top.state = "visible"
            statusinfo_top.nearTopEdge = false
            resetAutoHide.restart()

        }
    }

    Connections {

        target: statusinfo_top.access_loader

        function onVisibleItemChanged() {
            if(statusinfo_top.access_loader.visibleItem !== "")
                statusinfo_top.state = "visible"
        }

    }

    Timer {
        id: resetAutoHide
        interval:  500 + PQCSettings.interfaceStatusInfoAutoHideTimeout // qmllint disable unqualified
        repeat: false
        running: false
        onTriggered: {
            if((!statusinfo_top.nearTopEdge || !PQCSettings.interfaceStatusInfoAutoHideTopEdge) && !menu.item.opened) // qmllint disable unqualified
                statusinfo_top.state = "hidden"
        }
    }

}
