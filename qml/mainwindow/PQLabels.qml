/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Window 2.2
import "../elements"

Rectangle {

    id: labels_top

    x: 2*PQSettings.interfaceHotEdgeSize + 10
    Behavior on x { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    y: PQSettings.thumbnailsEdge=="Bottom" ? 10 : parent.height-height-10

    width: row.width+20
    height: (filefoldermodel.countMainView==0&&filefoldermodel.filterCurrentlyActive) ? 0 : row.height+20

    color: "#dd2f2f2f"
    radius: 5

    visible: !(variables.slideShowActive&&PQSettings.slideshowHideLabels) &&
             (filefoldermodel.current>-1 || filefoldermodel.filterCurrentlyActive) &&
             (filefoldermodel.countMainView>0 || filefoldermodel.filterCurrentlyActive) &&
             !variables.faceTaggingActive && anyLabelsVisible

    property bool anyLabelsVisible: !PQSettings.interfaceLabelsHideCounter || !PQSettings.interfaceLabelsHideFilepath || !PQSettings.interfaceLabelsHideFilename ||
                                    !PQSettings.interfaceLabelsHideZoomLevel || !PQSettings.interfaceLabelsHideRotationAngle


    Row {

        id: row
        x: 10
        y: 10
        spacing: 10

        Item {
            width: 1
            height: 1
        }

        Text {
            id: counter
            color: "white"
            visible: !PQSettings.interfaceLabelsHideCounter && (filefoldermodel.current > -1) && pageInfo.text==""
            width: visible ? children.width : 0
            text: PQSettings.interfaceLabelsHideCounter ? "" : ((filefoldermodel.current+1) + "/" + filefoldermodel.countMainView)
        }

        // filename
        Text {
            id: filename
            visible: text!="" && (filefoldermodel.current > -1)
            color: "white"
            text: ((PQSettings.interfaceLabelsHideFilename&&PQSettings.interfaceLabelsHideFilepath) || filefoldermodel.current==-1) ?
                      "" :
                      (PQSettings.interfaceLabelsHideFilepath ?
                           handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath) :
                           (PQSettings.interfaceLabelsHideFilename ?
                                handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath) :
                                filefoldermodel.currentFilePath))
        }

        Rectangle {
            color: "#cccccc"
            width: 1
            height: filename.height
            visible: zoomlevel.visible
        }

        // zoom level
        Text {
            id: zoomlevel
            color: "white"
            visible: !PQSettings.interfaceLabelsHideZoomLevel && (filefoldermodel.current > -1)
            width: visible ? children.width : 0
            text: PQSettings.interfaceLabelsHideZoomLevel ? "" : (Math.round(variables.currentZoomLevel)+"%")
        }

        Rectangle {
            color: "#cccccc"
            width: 1
            height: filename.height
            visible: rotationangle.visible
        }

        // rotation angle
        Text {
            id: rotationangle
            color: "white"
            visible: !PQSettings.interfaceLabelsHideRotationAngle && (filefoldermodel.current > -1)
            width: visible ? children.width : 0
            text: (Math.round(variables.currentRotationAngle)%360+360)%360 + "°"
        }

        Rectangle {
            color: "#cccccc"
            width: 1
            height: filename.height
            visible: pageInfo.visible
        }

        Text {
            id: pageInfo
            text: (filefoldermodel.current>-1 && filefoldermodel.current < filefoldermodel.countMainView && filefoldermodel.isPQT) ?
                      //: Used as in: Page 12/34 - please keep as short as possible
                      (em.pty+qsTranslate("quickinfo", "Page %1 of %2").arg(filefoldermodel.pqtNum+1).arg(filefoldermodel.countMainView)) :
                                (filefoldermodel.current>-1 && filefoldermodel.current < filefoldermodel.countMainView && filefoldermodel.isARC) ?
                                            //: Used as in: File 12/34 - please keep as short as possible
                                            (em.pty+qsTranslate("quickinfo", "File %1 of %2").arg(filefoldermodel.current+1).arg(filefoldermodel.countMainView) + ": " + handlingFileDir.getInternalFilenameArchive(filefoldermodel.currentFilePath)) :
                        ""
            visible: text != "" && (filefoldermodel.current > -1)
            color: "white"
        }

        Item {
            width: 1
            height: 1
        }

    }

    Rectangle {

        id: viewermode

        x: row.x+10
        y: PQSettings.thumbnailsEdge=="Bottom" ? (row.y+row.height+20 + (filterremove_cont.visible ? filterremove_cont.height+10 : 0)) : -height-filterremove_cont.height-10

        width: 2*row.height+10
        height: width
        color: "#dd2f2f2f"
        radius: 5

        visible: (imageproperties.isPopplerDocument(filefoldermodel.currentFilePath)
                        &&(imageproperties.getDocumentPages(filefoldermodel.currentFilePath)>1 || filefoldermodel.isPQT))
                    || (imageproperties.isArchive(filefoldermodel.currentFilePath))

        Image {
            anchors.fill: parent
            anchors.margins: 5
            source: pageInfo.text=="" ? "/image/viewermode.png" : "/image/noviewermode.png"
            mipmap: true
        }

    }

    // filter string
    Rectangle {
        id: filterremove_cont
        x: row.x
        y: PQSettings.thumbnailsEdge=="Bottom" ? (row.y+row.height+20) : -height-5
        visible: filefoldermodel.filterCurrentlyActive
        width: visible ? filterrow.width : 0
        height: visible ? filterrow.height+20 : 0
        color: "#dd2f2f2f"
        radius: 5
        Row {
            id: filterrow
            spacing: 10
            y: 10
            Item {
                width: 1
                height: 1
            }
            Text {
                id: filterremove
                color: "#999999"
                text: "x"
            }
            Text {
                id: filtertext
                color: "white"
                property string txt: filefoldermodel.filenameFilters.join(" ") + (filefoldermodel.nameFilters.length==0 ? "" : " ." + filefoldermodel.nameFilters.join(" ."))
                property string res: (filefoldermodel.imageResolutionFilter.width != 0 || filefoldermodel.imageResolutionFilter.height != 0) ?
                                         ((filefoldermodel.imageResolutionFilter.width<0||filefoldermodel.imageResolutionFilter.height<0 ? "< " : "> ") + Math.abs(filefoldermodel.imageResolutionFilter.width)+"x"+Math.abs(filefoldermodel.imageResolutionFilter.height)) :
                                         ""
                property string siz: filefoldermodel.fileSizeFilter!=0 ? ((filefoldermodel.fileSizeFilter<0 ? "< " : "> ") + variables.filterExactFileSizeSet) : ""
                text: "<b>" + em.pty+qsTranslate("quickinfo", "Filter:") + "</b> " + txt + (txt!=""&&res!="" ? "; " : "") + res + (siz!=""&&(txt!=""||res!="") ? "; " : "") + siz
            }
            Item {
                width: 1
                height: 1
            }
        }

    }

    Image {
        x: row.x+row.width+10
        y: row.y-5
        width: row.height+10
        height: width
        visible: variables.chromecastConnected
        mipmap: true
        source: "/streaming/chromecastactive.png"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            //: This is followed by the name of the Chromecast streaming device currently connected to
            tooltip: em.pty+qsTranslate("quickinfo", "Connected to:") + " " + variables.chromecastName
            cursorShape: Qt.PointingHandCursor
            onClicked:
                loader.show("chromecast")
        }
    }

    PQMenu {

        id: rightclickmenu

        model: [em.pty+qsTranslate("quickinfo", "Copy filename to clipboard"),
            (PQSettings.interfaceLabelsHideCounter ?
                     em.pty+qsTranslate("quickinfo", "Show counter") :
                     em.pty+qsTranslate("quickinfo", "Hide counter")),
            (PQSettings.interfaceLabelsHideFilepath ?
                 em.pty+qsTranslate("quickinfo", "Show file path") :
                 em.pty+qsTranslate("quickinfo", "Hide file path")),
            (PQSettings.interfaceLabelsHideFilename ?
                 em.pty+qsTranslate("quickinfo", "Show file name") :
                 em.pty+qsTranslate("quickinfo", "Hide file name")),
            (PQSettings.interfaceLabelsHideZoomLevel ?
                 em.pty+qsTranslate("quickinfo", "Show zoom level") :
                 em.pty+qsTranslate("quickinfo", "Hide zoom level")),
            (PQSettings.interfaceLabelsHideWindowButtons ?
                 em.pty+qsTranslate("quickinfo", "Show window buttons") :
                 em.pty+qsTranslate("quickinfo", "Hide window buttons"))
        ]

        lineBelowIndices: [0]

        onTriggered: {
            if(index === 0)
                handlingExternal.copyTextToClipboard(filename.text)
            else if(index == 1)
                PQSettings.interfaceLabelsHideCounter = !PQSettings.interfaceLabelsHideCounter
            else if(index == 2)
                PQSettings.interfaceLabelsHideFilepath = !PQSettings.interfaceLabelsHideFilepath
            else if(index == 3)
                PQSettings.interfaceLabelsHideFilename = !PQSettings.interfaceLabelsHideFilename
             else if(index == 4)
                PQSettings.interfaceLabelsHideZoomLevel = !PQSettings.interfaceLabelsHideZoomLevel
            else if(index == 5)
                PQSettings.interfaceLabelsHideWindowButtons = !PQSettings.interfaceLabelsHideWindowButtons
        }

    }


    PQMouseArea {

        x: row.x
        y: row.y

        width: Math.max(row.width + viewermode.width + chromecast.width, filterremove.width)
        height: row.height+filterremove.height+10

        hoverEnabled: true

        drag.target: PQSettings.interfaceLabelsManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : parent
        drag.minimumX: 0
        drag.maximumX: toplevel.width-parent.width
        drag.minimumY: 0
        drag.maximumY: toplevel.height-parent.height

        tooltip: em.pty+qsTranslate("quickinfo", "Some info about the current image and directory")
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.RightButton) {
                var pos = parent.mapFromItem(parent.parent, mouse.x, mouse.y)
                rightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
            }
        }
        property point clickPos: Qt.point(0,0)
        property bool isPressed: false
        onPressed: {
            if(toplevel.visibility != Window.Maximized) {
                isPressed = true
                clickPos = Qt.point(mouse.x, mouse.y)
            }
        }
        onPositionChanged: {
            if(PQSettings.interfaceLabelsManageWindow && isPressed) {
                if(toplevel.visibility == Window.Maximized)
                    toplevel.visibility = Window.Windowed
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                toplevel.x += delta.x;
                toplevel.y += delta.y;
            }
        }
        onReleased: {
            isPressed = false
        }
        onDoubleClicked: {
            if(toplevel.visibility == Window.Maximized)
                toplevel.visibility = Window.Windowed
            else if(toplevel.visibility == Window.Windowed)
                toplevel.visibility = Window.Maximized
            else if(toplevel.visibility == Window.FullScreen)
                toplevel.visibility = Window.Maximized
        }
    }

    PQMenu {

        id: viewermoderightclickmenu

        model: [PQSettings.imageviewBigViewerModeButton ?
                     em.pty+qsTranslate("quickinfo", "Hide central 'viewer mode' button") :
                     em.pty+qsTranslate("quickinfo", "Show central 'viewer mode' button")]

        onTriggered: {
            PQSettings.imageviewBigViewerModeButton = !PQSettings.imageviewBigViewerModeButton
        }

    }

    PQMouseArea {
        x: viewermode.x
        y: viewermode.y
        width: viewermode.width+5
        height: viewermode.height
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        acceptedButtons: Qt.LeftButton|Qt.RightButton

        enabled: viewermode.visible

        drag.target: PQSettings.interfaceLabelsManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : parent
        drag.minimumX: 0
        drag.maximumX: toplevel.width-parent.width
        drag.minimumY: 0
        drag.maximumY: toplevel.height-parent.height

        tooltip: pageInfo.text=="" ? em.pty+qsTranslate("quickinfo", "Click here to enter viewer mode") : em.pty+qsTranslate("quickinfo", "Click here to exit viewer mode")
        onClicked: {
            if(mouse.button == Qt.LeftButton) {
                if(filefoldermodel.isPQT || filefoldermodel.isARC)
                    exitViewerMode()
                else
                    enterViewerMode()
            } else {
                var pos = parent.mapFromItem(parent.parent, mouse.x+viewermode.x, mouse.y+viewermode.y)
                viewermoderightclickmenu.popup(Qt.point(parent.x+pos.x, parent.y+pos.y))
            }
        }
    }

    function enterViewerMode() {
        if(imageproperties.isPopplerDocument(filefoldermodel.currentFilePath)) {
            filefoldermodel.readDocumentOnly = true
            filefoldermodel.setFileNameOnceReloaded = "0::PQT::" + filefoldermodel.currentFilePath
            filefoldermodel.fileInFolderMainView = filefoldermodel.currentFilePath
        } else {
            filefoldermodel.readArchiveOnly = true
            filefoldermodel.setFileNameOnceReloaded = "---"
            filefoldermodel.fileInFolderMainView = filefoldermodel.currentFilePath
        }
    }

    function exitViewerMode() {
        if(filefoldermodel.isPQT)
            filefoldermodel.setFileNameOnceReloaded = filefoldermodel.pqtName
        else
            filefoldermodel.setFileNameOnceReloaded = filefoldermodel.arcName
        filefoldermodel.fileInFolderMainView = filefoldermodel.setFileNameOnceReloaded
    }

    function toggleViewerMode() {
        if(filefoldermodel.isPQT || filefoldermodel.isARC)
            exitViewerMode()
        else
            enterViewerMode()
    }

    PQMouseArea {
        x: filterremove_cont.x
        y: filterremove_cont.y
        width: filterremove.width+5
        height: filterremove_cont.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: em.pty+qsTranslate("quickinfo", "Click to remove filter")
        onPressed:
            loader.passOn("filter", "removeFilter", undefined)
    }


    // this makes sure that a change in the window geometry does not leeds to the element being outside the visible area
    Connections {
        target: toplevel
        onWidthChanged: {
            if(labels_top.x < 0)
                labels_top.x = 0
            else if(labels_top.x > toplevel.width-labels_top.width)
                labels_top.x = toplevel.width-labels_top.width
        }
        onHeightChanged: {
            if(labels_top.y < 0)
                labels_top.y = 0
            else if(labels_top.y > toplevel.height-labels_top.height)
                labels_top.y = toplevel.height-labels_top.height
        }
    }
}
