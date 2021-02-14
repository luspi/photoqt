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
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../loadfiles.js" as LoadFiles
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: filter_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.filterPopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#cc000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.filterPopoutElement
            onClicked:
                button_cancel.clicked()
        }

        Item {

            id: insidecont

            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 20

                Text {
                    id: heading
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 20
                    font.bold: true
                    text: em.pty+qsTranslate("filter", "Filter images in current directory")
                }

                Text {
                    id: description1
                    x: 10
                    width: insidecont.width-20
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("filter", "Enter here the terms you want to filter the images by. Separate multiple terms by a space.")
                }

                Text {
                    id: description2
                    x: 10
                    width: insidecont.width-20
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("filter", "If you want to filter by file extension, start the term with a dot.")
                }


                PQLineEdit {

                    id: filteredit

                    x: (insidecont.width-width)/2
                    width: 300
                    height: 40

                    placeholderText: em.pty+qsTranslate("filter", "Enter filter term")

                }

                Item {

                    id: butcont

                    x: 0
                    width: insidecont.width
                    height: childrenRect.height

                    Row {

                        spacing: 5

                        x: (parent.width-width)/2

                        PQButton {
                            id: button_ok
                            //: Written on a clickable button - please keep short
                            text: em.pty+qsTranslate("filter", "Filter")
                            onClicked: {
                                filter_top.opacity = 0
                                variables.visibleItem = ""
                                if(filteredit.text == "")
                                    removeFilter()
                                else
                                    setFilter(filteredit.text)
                            }
                        }
                        PQButton {
                            id: button_cancel
                            text: genericStringCancel
                            onClicked: {
                                filter_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }
                        PQButton {
                            scale: 0.8
                            id: button_removefilter
                            //: Written on a clickable button - please keep short
                            text: em.pty+qsTranslate("filter", "Remove filter")
                            onClicked: {
                                filter_top.opacity = 0
                                variables.visibleItem = ""
                                removeFilter()
                            }
                        }

                    }

                }

            }

        }

        Connections {
            target: loader
            onFilterPassOn: {
                if(what == "show") {
                    if(variables.indexOfCurrentImage == -1 && !variables.filterSet)
                        return
                    opacity = 1
                    variables.visibleItem = "filter"
                    filteredit.setFocus()
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "removeFilter") {
                    removeFilter()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_ok.clicked()
                }
            }
        }

    }

    Image {
        x: parent.width-width-5
        y: 5
        width: 25
        height: 25
        source: "/popin.png"
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.aboutPopoutElement ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.filterPopoutElement)
                    filter_window.storeGeometry()
                button_cancel.clicked()
                PQSettings.filterPopoutElement = (PQSettings.filterPopoutElement+1)%2
                HandleShortcuts.executeInternalFunction("__filterImages")
            }
        }
    }

    function setFilter(term) {

        variables.filterStrings = []
        variables.filterSuffixes = []

        var filterStr = ""

        // filter out search terms and search suffixes
        var spl = filteredit.text.split(" ")
        for(var iSpl = 0; iSpl < spl.length; ++iSpl) {
            if(spl[iSpl][0] == ".") {
                variables.filterSuffixes.push(spl[iSpl].slice(1))
                filterStr += ", ." + spl[iSpl].slice(1)
            } else {
                variables.filterStrings.push(spl[iSpl])
                filterStr += ", " + spl[iSpl]
            }
        }
        variables.filterStringConcat = filterStr.slice(2)

        var filteredlist = []

        // deep copy image list
        if(!variables.filterSet) {
            variables.allImageFilesInOrderFilterBackup = []
            for(var i = 0; i < variables.allImageFilesInOrder.length; ++i)
                variables.allImageFilesInOrderFilterBackup.push(variables.allImageFilesInOrder[i])
            variables.filterSet = true
        }


        // we check for filenames that satisfies all filter terms

        for(var j = 0; j < variables.allImageFilesInOrderFilterBackup.length; ++j) {

            var suf = handlingFileDir.getSuffix(variables.allImageFilesInOrderFilterBackup[j], false)
            var bas = handlingFileDir.getBaseName(variables.allImageFilesInOrderFilterBackup[j])

            var allgood = true

            // check search term
            for(var k = 0; k < variables.filterStrings.length; ++k) {
                if(bas.indexOf(variables.filterStrings[k]) == -1) {
                    allgood = false
                    break
                }
            }

            if(allgood) {
                for(var l = 0; l < variables.filterSuffixes.length; ++l) {
                    if(suf != variables.filterSuffixes[l]) {
                        allgood = false
                        break;
                    }
                }
            }

            if(allgood)
                filteredlist.push(variables.allImageFilesInOrderFilterBackup[j])

        }

        var newindex = filteredlist.indexOf(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
        if(filteredlist.length > 0 && newindex == -1)
            newindex = 0

        variables.filterSet = true
        variables.allImageFilesInOrder = filteredlist
        variables.indexOfCurrentImage = newindex
        variables.newFileLoaded()
        thumbnails.reloadThumbnails()

    }

    function removeFilter() {

        var newindex = variables.allImageFilesInOrderFilterBackup.indexOf(variables.allImageFilesInOrder[variables.indexOfCurrentImage])

        variables.allImageFilesInOrder = []
        for(var i = 0; i < variables.allImageFilesInOrderFilterBackup.length; ++i)
            variables.allImageFilesInOrder.push(variables.allImageFilesInOrderFilterBackup[i]);

        variables.filterSet = false
        variables.filterStrings = []
        variables.filterSuffixes = []
        filteredit.text = ""

        variables.indexOfCurrentImage = -1
        variables.indexOfCurrentImage = (newindex==-1 ? 0 : newindex)

        thumbnails.reloadThumbnails()

    }

}
