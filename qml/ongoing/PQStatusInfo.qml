import QtQuick

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCScriptsChromeCast

import "../elements"

Item {

    id: statusinfo_top

    x: 40
    y: 20

    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    visible: !(PQCNotify.slideshowRunning && PQCSettings.slideshowHideLabels) && !PQCNotify.faceTagging

    width: maincol.width
    height: maincol.height

    // possible values: counter, filename, filepathname, resolution, zoom, rotation
    property var info: PQCSettings.interfaceStatusInfoList

    // don't pass mouse clicks to background
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton|Qt.LeftButton
    }

    Column {

        id: maincol

        spacing: 10

        Rectangle {

            id: maincontainer

            color: PQCLook.transColor

            width: row.width+40
            height: row.height+20

            radius: 5

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
                                                                               rectDummy
                            }

                            Rectangle {
                                height: ldr.height
                                width: 1
                                color: PQCLook.textColor
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

            }

        }

        Rectangle {

            id: filterrect

            property bool filterset: false

            color: PQCLook.transColor

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
                    source: "/white/x.svg"
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
            color: PQCLook.transColor
            radius: 5

            visible: false

            Image {
                anchors.fill: parent
                anchors.margins: 5
                sourceSize: Qt.size(width, height)
                source: (PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC) ? "/white/viewermode_off.svg" : "/white/viewermode_on.svg"
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
                    else
                        PQCFileFolderModel.enableViewerMode()
                }
            }

            Connections {
                target: PQCFileFolderModel

                function onCurrentFileChanged() {

                    var s = false

                    if(PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile)) {
                        if(PQCFileFolderModel.isPDF || PQCScriptsImages.getNumberDocumentPages(PQCFileFolderModel.currentFile))
                            s = true
                    } else if(PQCScriptsImages.isArchive(PQCFileFolderModel.currentFile))
                        s = true

                    viewermode.visible = s

                }

            }

        }

    }

    Image {
        source: "/other/chromecastactive.svg"
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
        id: rectDummy
        PQText {
            text: "[unknown]"
        }
    }

}
