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

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCScriptsChromeCast
import PQCScriptsConfig

import "../elements"

Item {

    id: statusinfo_top

    x: 2*distanceFromEdge
    y: distanceFromEdge

    Behavior on y { NumberAnimation { duration: (PQCSettings.interfaceStatusInfoAutoHide || PQCSettings.interfaceStatusInfoAutoHideTopEdge || movedByMouse) ? 200 : 0 } }
    Behavior on x { NumberAnimation { duration: (movedByMouse) ? 200 : 0 } }

    property bool movedByMouse: false

    visible: !(PQCNotify.slideshowRunning && PQCSettings.slideshowHideLabels) && !PQCNotify.faceTagging && !PQCNotify.insidePhotoSphere && PQCSettings.interfaceStatusInfoShow

    width: maincol.width
    height: maincol.height

    // possible values: counter, filename, filepathname, resolution, zoom, rotation
    property var info: PQCSettings.interfaceStatusInfoList

    property int distanceFromEdge: 20

    property alias radius: maincontainer.radius

    PQShadowEffect { masterItem: statusinfo_top }

    // don't pass mouse clicks to background
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onPressed: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.item.popup()
        }
    }

    state: (!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge && PQCSettings.interfaceStatusInfoShow) ?
               "visible" :
               "hidden"

    onStateChanged: {
        if(state === "hidden" && menu.item !== null)
            menu.item.dismiss()
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: statusinfo_top
                y: distanceFromEdge
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: statusinfo_top
                y: -height-5
            }
        }
    ]

    Column {

        id: maincol

        spacing: 10

        Rectangle {

            id: maincontainer

            color: PQCLook.baseColor

            width: row.width+40
            height: row.height+20

            radius: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 5

            Row {

                id: row

                x: 20
                y: 10

                spacing: 10

                Repeater {

                    model: PQCFileFolderModel.countMainView===0 ? 1 : info.length

                    Item {

                        width: childrenRect.width
                        height: childrenRect.height

                        Row {

                            spacing: 10

                            Loader {
                                id: ldr
                                property string t: info[index]
                                sourceComponent: PQCFileFolderModel.countMainView===0 ?
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
                                                                               t=="colorspace" ?
                                                                                   rectColorSpace :
                                                                                   rectDummy
                            }

                            Rectangle {
                                height: ldr.height
                                width: 1
                                color: PQCLook.textColorDisabled
                                visible: index<info.length-1 && PQCFileFolderModel.countMainView>0
                            }

                        }

                    }

                }

            }

            PQMouseArea {
                anchors.fill: parent
                drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : statusinfo_top
                hoverEnabled: true
                text: PQCSettings.interfaceStatusInfoManageWindow ?
                          qsTranslate("statusinfo", "Click and drag to move window around") :
                          qsTranslate("statusinfo", "Click and drag to move status info around")
                onWheel: (wheel) => {
                    wheel.accepted = true
                }
                onPressed: {
                    if(PQCSettings.interfaceStatusInfoManageWindow)
                        toplevel.startSystemMove()
                }
                onDoubleClicked: {
                    if(PQCSettings.interfaceStatusInfoManageWindow) {
                        if(toplevel.visibility === Window.Maximized)
                            toplevel.visibility = Window.Windowed
                        else if(toplevel.visibility === Window.Windowed)
                            toplevel.visibility = Window.Maximized
                    }
                }
                drag.onActiveChanged:
                    movedByMouse = true

            }

        }

        Rectangle {

            id: filterrect

            property bool filterset: false

            color: PQCLook.baseColor

            width: filterrow.width+30
            height: filterrow.height+20

            visible: filterset

            radius: 5

            PQMouseArea {
                anchors.fill: parent
                drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : statusinfo_top
                hoverEnabled: true
                text: PQCSettings.interfaceStatusInfoManageWindow ?
                          "" :
                          qsTranslate("statusinfo", "Click and drag to move status info around")
                onWheel: (wheel) => {
                    wheel.accepted = true
                }
                drag.onActiveChanged:
                    movedByMouse = true
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
                    source: "image://svg/:/white/x.svg"
                    sourceSize: Qt.size(width, height)
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("statusinfo", "Click to remove filter")
                        onClicked: {
                            PQCFileFolderModel.removeAllUserFilter()
                        }
                    }
                }

                PQText {
                    id: filtertxt

                    Connections {
                        target: PQCFileFolderModel
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

                        var txt1 = PQCFileFolderModel.filenameFilters.join(" ")
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
            color: PQCLook.baseColor
            radius: 5

            visible: currentIsPDF||currentIsARC

            property bool currentIsPDF: false
            property bool currentIsARC: false

            Image {
                anchors.fill: parent
                anchors.margins: 5
                sourceSize: Qt.size(width, height)
                source: (PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC) ? "image://svg/:/white/viewermode_off.svg" : "image://svg/:/white/viewermode_on.svg"
                mipmap: true
            }

            PQMouseArea {
                anchors.fill: parent
                drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : statusinfo_top
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: PQCSettings.interfaceStatusInfoManageWindow ?
                          "" :
                          qsTranslate("statusinfo", "Click and drag to move status info around")
                onWheel: (wheel) => {
                    wheel.accepted = true
                }
                onClicked: {
                    if(PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC)
                        PQCFileFolderModel.disableViewerMode()
                    else {
                        PQCFileFolderModel.enableViewerMode(image.currentFileInside)
                    }
                }
                drag.onActiveChanged:
                    movedByMouse = true
            }

            Connections {
                target: PQCFileFolderModel

                function onCurrentFileChanged() {

                    viewermode.currentIsPDF = (PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile) &&
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
        visible: PQCScriptsChromeCast.connected
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
            text: qsTranslate("statusinfo","Connected to:") + " " + PQCScriptsChromeCast.curDeviceName
            onClicked:
                loader.show("chromecastmanager")
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
            text: (PQCFileFolderModel.currentIndex+1) + "/" + PQCFileFolderModel.countMainView
        }
    }

    Component {
        id: rectFilename
        PQText {
            text: PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)
        }
    }

    Component {
        id: rectFilepath
        PQText {
            text: PQCFileFolderModel.currentFile
        }
    }

    Component {
        id: rectZoom
        PQText {
            text: Math.round(image.currentScale*100)+"%"
        }
    }

    Component {
        id: rectRotation
        PQText {
            text: (Math.round(image.currentRotation)%360+360)%360 + "°"
        }
    }

    Component {
        id: rectResolution
        Row {
            spacing: 2
            PQText {
                text: image.currentResolution.width
            }
            PQText {
                opacity: 0.7
                text: "x"
            }
            PQText {
                text: image.currentResolution.height
            }
        }
    }

    Component {
        id: rectFilesize
        PQText {
            text: PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFile)
        }
    }

    Component {
        id: rectColorSpace
        PQText {
            id: csptxt
            Behavior on color { ColorAnimation { duration: 200 } }
            Component.onCompleted: {
                var val = PQCNotify.getColorProfileFor(PQCFileFolderModel.currentFile)
                if(val !== "") {
                    csptxt.text = val
                    csptxt.color = PQCLook.textColor
                } else
                    csptxt.color = PQCLook.textColorDisabled
            }

            Connections {
                target: PQCNotify
                function onColorProfilesChanged() {
                    var val = PQCNotify.getColorProfileFor(PQCFileFolderModel.currentFile)
                    if(val !== "") {
                        csptxt.text = val
                        csptxt.color = PQCLook.textColor
                    } else
                        csptxt.color = PQCLook.textColorDisabled
                }
            }
            Connections {
                target: PQCFileFolderModel
                function onCurrentFileChanged() {
                    if(PQCScriptsImages.isMpvVideo(PQCFileFolderModel.currentFile) || PQCScriptsImages.isQtVideo(PQCFileFolderModel.currentFile)) {
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
                        } else
                            csptxt.color = PQCLook.textColorDisabled
                    }
                }
            }
            Timer {
                id: loadVideoColorInfo
                interval: 1
                onTriggered: {
                    var val = PQCScriptsImages.detectVideoColorProfile(PQCFileFolderModel.currentFile)
                    csptxt.color = PQCLook.textColor
                    if(val === "")
                        val = qsTranslate("statusinfo", "unknown color space")
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
                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "show")
                    checked: PQCSettings.interfaceStatusInfoShow
                    onCheckedChanged:
                        PQCSettings.interfaceStatusInfoShow = checked
                }
                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager",  "manage window")
                    checked: PQCSettings.interfaceStatusInfoManageWindow
                    onCheckedChanged:
                        PQCSettings.interfaceStatusInfoManageWindow = checked
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
                    checked: !PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceStatusInfoAutoHide = false
                            PQCSettings.interfaceStatusInfoAutoHideTopEdge = false
                        }
                    }
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "cursor move")
                    ButtonGroup.group: grp
                    checked: PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceStatusInfoAutoHide = true
                            PQCSettings.interfaceStatusInfoAutoHideTopEdge = false
                        }
                    }
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "cursor near top edge")
                    ButtonGroup.group: grp
                    checked: PQCSettings.interfaceStatusInfoAutoHideTopEdge
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceStatusInfoAutoHide = false
                            PQCSettings.interfaceStatusInfoAutoHideTopEdge = true
                        }
                    }
                }
            }
    }

    property bool nearTopEdge: false

    Connections {

        target: PQCNotify

        function onMouseMove(posx, posy) {

            if((!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge) || loader.visibleItem !== "") {
                resetAutoHide.stop()
                statusinfo_top.state = "visible"
                nearTopEdge = true
                return
            }

            var trigger = PQCSettings.interfaceHotEdgeSize*5
            if(PQCSettings.interfaceEdgeTopAction !== "")
                trigger *= 2

            if((posy < trigger && PQCSettings.interfaceStatusInfoAutoHideTopEdge) || !PQCSettings.interfaceStatusInfoAutoHideTopEdge)
                statusinfo_top.state = "visible"

            nearTopEdge = (posy < trigger)

            if(!nearTopEdge && (!resetAutoHide.running || PQCSettings.interfaceStatusInfoAutoHide))
                resetAutoHide.restart()

        }

    }

    Connections {

        target: PQCFileFolderModel

        function onCurrentIndexChanged() {

            if(PQCSettings.interfaceStatusInfoAutoHideTimeout === 0 ||
                    (!PQCSettings.interfaceStatusInfoAutoHide && !PQCSettings.interfaceStatusInfoAutoHideTopEdge) ||
                    !PQCSettings.interfaceStatusInfoShowImageChange)
                return

            statusinfo_top.state = "visible"
            nearTopEdge = false
            resetAutoHide.restart()

        }
    }

    Connections {

        target: loader

        function onVisibleItemChanged() {
            if(loader.visibleItem !== "")
                statusinfo_top.state = "visible"
        }

    }

    Timer {
        id: resetAutoHide
        interval:  500 + PQCSettings.interfaceStatusInfoAutoHideTimeout
        repeat: false
        running: false
        onTriggered: {
            if((!nearTopEdge || !PQCSettings.interfaceStatusInfoAutoHideTopEdge) && !menu.item.opened)
                statusinfo_top.state = "hidden"
        }
    }

}
