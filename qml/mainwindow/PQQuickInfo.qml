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

Item {

    x: variables.metaDataWidthWhenKeptOpen + 10
    Behavior on x { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    y: 10

    width: cont.width
    height: cont.height

    visible: !(variables.slideShowActive&&PQSettings.slideShowHideQuickInfo) &&
             (filefoldermodel.current>-1 || filefoldermodel.filterCurrentlyActive) &&
             (filefoldermodel.countMainView>0 || filefoldermodel.filterCurrentlyActive) &&
             !variables.faceTaggingActive

    Rectangle {

        id: cont
        width: childrenRect.width+20
        height: childrenRect.height+10

        clip: true

        Behavior on width { NumberAnimation { duration: 200 } }

        color: "#88000000"
        radius: 5

        Text {

            id: counter

            x: PQSettings.quickInfoHideCounter ? 0 : 10
            y: 5
            color: "white"

            visible: !PQSettings.quickInfoHideCounter && (filefoldermodel.current > -1) && pageInfo.text==""

            width: visible ? children.width : 0

            text: PQSettings.quickInfoHideCounter ? "" : ((filefoldermodel.current+1) + "/" + filefoldermodel.countMainView)

        }

        // filename
        Text {

            id: filename

            x: counter.x+counter.width + (text==""||!counter.visible ? 0 : 10)

            visible: text!="" && (filefoldermodel.current > -1)

            y: 5
            color: "white"
            text: ((PQSettings.quickInfoHideFilename&&PQSettings.quickInfoHideFilepath) || filefoldermodel.current==-1) ?
                      "" :
                      (PQSettings.quickInfoHideFilepath ?
                           handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath) :
                           (PQSettings.quickInfoHideFilename ?
                                handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath) :
                                filefoldermodel.currentFilePath))
        }

        Rectangle {

            id: seperator1

            color: "#cccccc"

            x: filename.x+filename.width+(visible ? 10 : 0)
            y: 5

            visible: (filename.visible||counter.visible) && (pageInfo.visible) && (filefoldermodel.current > -1)

            width: 1
            height: filename.height

        }

        Text {

            id: pageInfo

            anchors.left: seperator1.right
            anchors.leftMargin: visible ? 10 : 0
            y: 5

            text: (filefoldermodel.current>-1 && filefoldermodel.current < filefoldermodel.countMainView && filefoldermodel.currentFilePath.indexOf("::PQT::")>-1) ?
                      //: Used as in: Page 12/34 - please keep as short as possible
                      (em.pty+qsTranslate("quickinfo", "Page") + " " + (filefoldermodel.currentFilePath.split("::PQT::")[0]*1+1) + " of " + filefoldermodel.countMainView) :
                                (filefoldermodel.current>-1 && filefoldermodel.current < filefoldermodel.countMainView && filefoldermodel.currentFilePath.indexOf("::ARC::")>-1) ?
                                            //: Used as in: File 12/34 - please keep as short as possible
                                            (em.pty+qsTranslate("quickinfo", "File") + " " + (filefoldermodel.current+1) + " of " + filefoldermodel.countMainView) :
                        ""
            visible: text != "" && (filefoldermodel.current > -1)

            color: "white"

        }

        Rectangle {

            id: seperator2

            color: "#cccccc"

            x: pageInfo.x+pageInfo.width+(visible ? 10 : 0)
            y: 5

            visible: (filename.visible||counter.visible||pageInfo.visible) && zoomlevel.visible && (filefoldermodel.current > -1)

            width: 1
            height: filename.height

        }

        // zoom level
        Text {
            id: zoomlevel
            x: seperator2.x+seperator2.width + (visible ? 10 : 0)
            y: 5
            color: "white"
            visible: !PQSettings.quickInfoHideZoomLevel && (filefoldermodel.current > -1) && pageInfo.text==""
            width: visible ? children.width : 0
            text: PQSettings.quickInfoHideZoomLevel ? "" : (Math.round(variables.currentZoomLevel)+"%")
        }

        Rectangle {

            id: seperator3

            color: "white"

            x: zoomlevel.x+zoomlevel.width+(visible ? 10 : 0)
            y: 5

            visible: enterpdf_cont.visible||enterarchive_cont.visible

            width: 1
            height: filename.height

        }

        // enter Document Viewer
        Item {
            id: enterpdf_cont
            x: seperator3.x+10
            y: 5
            visible: imageproperties.isPopplerDocument(filefoldermodel.currentFilePath)
            width: visible ? enterpdf.width : 0
            height: visible ? enterpdf.height : 0
            Text {
                id: enterpdf
                color: "white"
                font.italic: true
                text: pageInfo.text=="" ? "Enter Document Viewer" : "Exit Document Viewer"
            }

        }

        // enter Archive Viewer
        Item {
            id: enterarchive_cont
            x: seperator3.x+10
            y: 5
            visible: imageproperties.isArchive(filefoldermodel.currentFilePath)
            width: visible ? enterarchive.width : 0
            height: visible ? enterarchive.height : 0
            Text {
                id: enterarchive
                color: "white"
                font.italic: true
                text: pageInfo.text=="" ? "Enter Archive Viewer" : "Exit Archive Viewer"
            }

        }

        // filter string
        Item {
            id: filterremove_cont
            x: counter.x
            y: (filefoldermodel.filterCurrentlyActive&&filefoldermodel.current==-1) ? 5 : (counter.y+counter.height + (visible ? 10 : 0))
            visible: filefoldermodel.filterCurrentlyActive
            width: visible ? filtertext.width : 0
            height: visible ? filtertext.height : 0
            Row {
                height: childrenRect.height
                spacing: 5
                Text {
                    id: filterremove
                    color: "#999999"
                    text: "x"
                }
                Text {
                    id: filtertext
                    color: "white"
                    text: em.pty+qsTranslate("quickinfo", "Filter:") + " " + filefoldermodel.filenameFilters.join(" ") + " ." + filefoldermodel.nameFilters.join(" .")
                }
            }

        }

        PQMenu {

            id: rightclickmenu

            model: [(PQSettings.quickInfoHideCounter ?
                         em.pty+qsTranslate("quickinfo", "Show counter") :
                         em.pty+qsTranslate("quickinfo", "Hide counter")),
                (PQSettings.quickInfoHideFilepath ?
                     em.pty+qsTranslate("quickinfo", "Show file path") :
                     em.pty+qsTranslate("quickinfo", "Hide file path")),
                (PQSettings.quickInfoHideFilename ?
                     em.pty+qsTranslate("quickinfo", "Show file name") :
                     em.pty+qsTranslate("quickinfo", "Hide file name")),
                (PQSettings.quickInfoHideZoomLevel ?
                     em.pty+qsTranslate("quickinfo", "Show zoom level") :
                     em.pty+qsTranslate("quickinfo", "Hide zoom level")),
                (PQSettings.quickInfoHideWindowButtons ?
                     em.pty+qsTranslate("quickinfo", "Show window buttons") :
                     em.pty+qsTranslate("quickinfo", "Hide window buttons"))
            ]

            onTriggered: {
                if(index == 0)
                    PQSettings.quickInfoHideCounter = !PQSettings.quickInfoHideCounter
                else if(index == 1)
                    PQSettings.quickInfoHideFilepath = !PQSettings.quickInfoHideFilepath
                else if(index == 2)
                    PQSettings.quickInfoHideFilename = !PQSettings.quickInfoHideFilename
                 else if(index == 3)
                    PQSettings.quickInfoHideZoomLevel = !PQSettings.quickInfoHideZoomLevel
                else if(index == 4)
                    PQSettings.quickInfoHideWindowButtons = !PQSettings.quickInfoHideWindowButtons
            }

        }

    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        drag.target: PQSettings.quickInfoManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : parent
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
            if(PQSettings.quickInfoManageWindow && isPressed) {
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
        x: enterpdf_cont.x
        y: enterpdf_cont.y
        width: enterpdf_cont.width+5
        height: enterpdf_cont.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: pageInfo.text=="" ? em.pty+qsTranslate("quickinfo", "Click here to enter Document Viewer") : em.pty+qsTranslate("quickinfo", "Click here to exit Document Viewer")
        onClicked: {
            if(pageInfo.text == "") {
                filefoldermodel.readDocumentOnly = true
                filefoldermodel.setFileNameOnceReloaded = "0::PQT::" + filefoldermodel.currentFilePath
                filefoldermodel.fileInFolderMainView = filefoldermodel.currentFilePath
            } else {
                filefoldermodel.setFileNameOnceReloaded = filefoldermodel.currentFilePath.split("::PQT::")[1]
                filefoldermodel.fileInFolderMainView = filefoldermodel.setFileNameOnceReloaded
            }
        }
    }

    PQMouseArea {
        x: enterarchive_cont.x
        y: enterarchive_cont.y
        width: enterarchive_cont.width+5
        height: enterarchive_cont.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: pageInfo.text=="" ? em.pty+qsTranslate("quickinfo", "Click here to enter Archive Viewer") : em.pty+qsTranslate("quickinfo", "Click here to exit Archive Viewer")
        onClicked: {
            if(pageInfo.text=="") {
                filefoldermodel.readArchiveOnly = true
                filefoldermodel.setFileNameOnceReloaded = "---"
                filefoldermodel.fileInFolderMainView = filefoldermodel.currentFilePath
            } else {
                filefoldermodel.setFileNameOnceReloaded = filefoldermodel.currentFilePath.split("::ARC::")[1]
                filefoldermodel.fileInFolderMainView = filefoldermodel.setFileNameOnceReloaded
            }
        }
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
