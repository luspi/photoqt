/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

    x: variables.metaDataWidthWhenKeptOpen + 10
    Behavior on x { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    y: 10

    width: row.width
    height: row.height+10

    color: "#000000"
    radius: 5

    visible: !(variables.slideShowActive&&PQSettings.slideShowHideLabels) &&
             (filefoldermodel.current>-1 || filefoldermodel.filterCurrentlyActive) &&
             (filefoldermodel.countMainView>0 || filefoldermodel.filterCurrentlyActive) &&
             !variables.faceTaggingActive

    Row {

        id: row
        y: 5
        spacing: 10

        Item {
            width: 1
            height: 1
        }

        Text {
            id: counter
            color: "white"
            visible: !PQSettings.labelsHideCounter && (filefoldermodel.current > -1) && pageInfo.text==""
            width: visible ? children.width : 0
            text: PQSettings.labelsHideCounter ? "" : ((filefoldermodel.current+1) + "/" + filefoldermodel.countMainView)
        }

        // filename
        Text {
            id: filename
            visible: text!="" && (filefoldermodel.current > -1)
            color: "white"
            text: ((PQSettings.labelsHideFilename&&PQSettings.labelsHideFilepath) || filefoldermodel.current==-1) ?
                      "" :
                      (PQSettings.labelsHideFilepath ?
                           handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath) :
                           (PQSettings.labelsHideFilename ?
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
            visible: !PQSettings.labelsHideZoomLevel && (filefoldermodel.current > -1)
            width: visible ? children.width : 0
            text: PQSettings.labelsHideZoomLevel ? "" : (Math.round(variables.currentZoomLevel)+"%")
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
            visible: !PQSettings.labelsHideRotationAngle && (filefoldermodel.current > -1)
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
                                            (em.pty+qsTranslate("quickinfo", "File %1 of %2").arg(filefoldermodel.current+1).arg(filefoldermodel.countMainView)) :
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
        y: row.y+row.height+20 + (filterremove_cont.visible ? filterremove_cont.height+10 : 0)

        width: 2*row.height+10
        height: width
        color: "#000000"
        radius: 5

        visible: (imageproperties.isPopplerDocument(filefoldermodel.currentFilePath)
                        &&(imageproperties.getDocumentPages(filefoldermodel.currentFilePath)>1 || filefoldermodel.isPQT))
                    || (imageproperties.isArchive(filefoldermodel.currentFilePath))

        Image {
            anchors.fill: parent
            anchors.margins: 5
            source: pageInfo.text=="" ? "/image/viewermode.png" : "/image/noviewermode.png"
        }

    }

    // filter string
    Rectangle {
        id: filterremove_cont
        x: row.x
        y: row.y+row.height+10
        visible: filefoldermodel.filterCurrentlyActive
        width: visible ? filterrow.width : 0
        height: visible ? filterrow.height+10 : 0
        color: "#000000"
        radius: 5
        Row {
            id: filterrow
            spacing: 5
            y: 5
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
                text: em.pty+qsTranslate("quickinfo", "Filter:") + " " + filefoldermodel.filenameFilters.join(" ") + (filefoldermodel.nameFilters.length==0 ? "" : " ." + filefoldermodel.nameFilters.join(" ."))
            }
            Item {
                width: 1
                height: 1
            }
        }

    }

    PQMenu {

        id: rightclickmenu

        model: [(PQSettings.labelsHideCounter ?
                     em.pty+qsTranslate("quickinfo", "Show counter") :
                     em.pty+qsTranslate("quickinfo", "Hide counter")),
            (PQSettings.labelsHideFilepath ?
                 em.pty+qsTranslate("quickinfo", "Show file path") :
                 em.pty+qsTranslate("quickinfo", "Hide file path")),
            (PQSettings.labelsHideFilename ?
                 em.pty+qsTranslate("quickinfo", "Show file name") :
                 em.pty+qsTranslate("quickinfo", "Hide file name")),
            (PQSettings.labelsHideZoomLevel ?
                 em.pty+qsTranslate("quickinfo", "Show zoom level") :
                 em.pty+qsTranslate("quickinfo", "Hide zoom level")),
            (PQSettings.labelsHideWindowButtons ?
                 em.pty+qsTranslate("quickinfo", "Show window buttons") :
                 em.pty+qsTranslate("quickinfo", "Hide window buttons"))
        ]

        onTriggered: {
            if(index == 0)
                PQSettings.labelsHideCounter = !PQSettings.labelsHideCounter
            else if(index == 1)
                PQSettings.labelsHideFilepath = !PQSettings.labelsHideFilepath
            else if(index == 2)
                PQSettings.labelsHideFilename = !PQSettings.labelsHideFilename
             else if(index == 3)
                PQSettings.labelsHideZoomLevel = !PQSettings.labelsHideZoomLevel
            else if(index == 4)
                PQSettings.labelsHideWindowButtons = !PQSettings.labelsHideWindowButtons
        }

    }


    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        drag.target: PQSettings.labelsManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : parent
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
            if(PQSettings.labelsManageWindow && isPressed) {
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

    PQMouseArea {
        x: viewermode.x
        y: viewermode.y
        width: viewermode.width+5
        height: viewermode.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        drag.target: PQSettings.labelsManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : parent
        tooltip: pageInfo.text=="" ? em.pty+qsTranslate("quickinfo", "Click here to enter viewer mode") : em.pty+qsTranslate("quickinfo", "Click here to exit viewer mode")
        onClicked: {
            if(filefoldermodel.isPQT || filefoldermodel.isARC)
                exitViewerMode()
            else
                enterViewerMode()
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

}
