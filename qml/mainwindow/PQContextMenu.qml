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
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Rectangle {

    id: context_top

    width: mainlistview.width+20
    height: mainlistview.height+20

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    radius: 5

    color: "#dd000000"
    border.color: "#88ffffff"
    border.width: 1

    property var allitems_static: [
        //: This is an entry in the context menu, used as in: Zoom image. Please keep short!
        [["zoom","zoom",em.pty+qsTranslate("MainMenu", "Zoom")],
                ["__zoomIn","","+", "donthide"],
                ["__zoomOut","","-", "donthide"],
                ["__zoomReset","","0", "donthide"],
                ["__zoomActual","","1:1", "donthide"]],
        //: This is an entry in the context menu, used as in: Rotate image. Please keep short!
        [["rotate","rotate",em.pty+qsTranslate("MainMenu", "Rotate")],
                //: This is an entry in the context menu, used as in: Rotate image left. Please keep short!
                ["__rotateL","",em.pty+qsTranslate("MainMenu", "left"), "donthide"],
                //: This is an entry in the context menu, used as in: Rotate image right. Please keep short!
                ["__rotateR","",em.pty+qsTranslate("MainMenu", "right"), "donthide"],
                //: This is an entry in the context menu, used as in: Reset rotation of image. Please keep short!
                ["__rotate0","",em.pty+qsTranslate("MainMenu", "reset"), "donthide"]],
        //: This is an entry in the context menu, used as in: Flip/Mirror image. Please keep short!
        [["flip","flip",em.pty+qsTranslate("MainMenu", "Flip")],
                //: This is an entry in the context menu, used as in: Flip/Mirror image horizontally. Please keep short!
                ["__flipH","",em.pty+qsTranslate("MainMenu", "horizontal"), "donthide"],
                //: This is an entry in the context menu, used as in: Flip/Mirror image vertically. Please keep short!
                ["__flipV","",em.pty+qsTranslate("MainMenu", "vertical"), "donthide"],
                //: This is an entry in the context menu, used as in: Reset flip/mirror of image. Please keep short!
                ["__flipReset","",em.pty+qsTranslate("MainMenu", "reset"), "donthide"]],
        //: This is an entry in the context menu, used to refer to the current file (specifically the file, not directly the image). Please keep short!
        [["","copy",em.pty+qsTranslate("MainMenu", "File")],
                //: This is an entry in the context menu, used as in: rename file. Please keep short!
                ["__rename","",em.pty+qsTranslate("MainMenu", "rename"), "hide"],
                //: This is an entry in the context menu, used as in: copy file. Please keep short!
                ["__copy","",em.pty+qsTranslate("MainMenu", "copy"), "hide"],
                //: This is an entry in the context menu, used as in: move file. Please keep short!
                ["__move","",em.pty+qsTranslate("MainMenu", "move"), "hide"],
                //: This is an entry in the context menu, used as in: delete file. Please keep short!
                ["__delete","",em.pty+qsTranslate("MainMenu", "delete"), "hide"]],

        [["separator", "", "", ""]],

        //: This is an entry in the context menu, 'streaming' as in stream PhotoQt to Chromecast devices. Please keep short!
        [["__chromecast", "chromecast", em.pty+qsTranslate("MainMenu", "Streaming (Chromecast)"), "hide"]],

        // having 'chromecast' as third entry allows us to also hide this seperator if chromecast is disabled and the above item is hidden
        [["separator", "", "chromecast", ""]],

        //: This is an entry in the context menu. Please keep short!
        [["__clipboard", "clipboard", em.pty+qsTranslate("MainMenu", "Copy to clipboard"), "hide"]],
        //: This is an entry in the context menu. Please keep short!
        [["__open", "open", em.pty+qsTranslate("MainMenu", "Open File"), "hide"]],
        //: This is an entry in the context menu. Please keep short!
        [["__histogram", "histogram", em.pty+qsTranslate("MainMenu", "Show/Hide Histogram"), "donthide"]],
        //: This is an entry in the context menu. Please keep short!
        [["__tagFaces", "faces", em.pty+qsTranslate("MainMenu", "Face tagging mode"), "hide"]],

        [["separator", "", "", ""]],

        //: This is an entry in the context menu. Please keep short!
        [["__logging", "logging", em.pty+qsTranslate("MainMenu", "Manage debug log"), "hide"]]
    ]
    property var allitems_external: []
    property var allitems: allitems_static.concat(allitems_external)

    property bool containsMouse: false

    MouseArea {
        id: backmouse
        anchors.fill: parent
        acceptedButtons: Qt.RightButton|Qt.LeftButton|Qt.MiddleButton
        hoverEnabled: true
        onEntered:
            parent.containsMouse = true
        onExited:
            parent.containsMouse = false
    }

    ListView {

        id: mainlistview
        x: 10
        y: 10
        height: childrenRect.height
        width: maxrowwidth
        model: allitems.length
        delegate: maindeleg
        clip: true

        property int maxrowwidth: 0

        orientation: ListView.Vertical

    }

    Component {

        id: maindeleg

        Row {

            id: deleg_top

            spacing: 5

            property int mainindex: index

            visible: (allitems[mainindex][0][1] != "chromecast" && allitems[mainindex][0][2] != "chromecast") || handlingGeneral.isChromecastEnabled()

            Repeater {

                model: allitems[mainindex].length


                Item {

                    property bool separator: allitems[deleg_top.mainindex][index][0] == "separator"

                    width: separator ? mainlistview.maxrowwidth : childrenRect.width
                    height: visible ? (separator ? 10 : childrenRect.height) : 0

                    Rectangle {
                        width: separator ? parent.width : -deleg_top.spacing
                        height: 1
                        color: separator ? "#aaaaaa" : "transparent"
                    }

                    Component.onCompleted: {
                        if(width > mainlistview.maxrowwidth && !separator)
                            mainlistview.maxrowwidth = width
                    }
                    onWidthChanged: {
                        if(width > mainlistview.maxrowwidth && !separator)
                            mainlistview.maxrowwidth = width
                    }

                    Row {

                        spacing: 5

                        visible: !parent.separator
                        width: childrenRect.width
                        height: separator ? 0 : childrenRect.height

                        Text {
                            id: sep
                            lineHeight: 1.5

                            color: "#cccccc"
                            visible: allitems[deleg_top.mainindex][index].length > 1 && index > 1
                            font.bold: true
                            font.pointSize: 11
                            text: "/"
                        }

                        Image {
                            y: 2.5
                            width: ((source!="" || allitems[deleg_top.mainindex][index][0]==="separator") ? val.height*0.5 : 0)
                            height: val.height*0.5
                            sourceSize.width: width
                            sourceSize.height: height
                            source: allitems[deleg_top.mainindex][index][1]===""
                                    ? "" : (allitems[deleg_top.mainindex][index][0].slice(0,8)=="_:_EX_:_"
                                            ? handlingExternal.getIconPathFromTheme(allitems[deleg_top.mainindex][index][1]) :
                                              "/mainmenu/" + allitems[deleg_top.mainindex][index][1] + ".png")
                            opacity: allitems[deleg_top.mainindex][index][0] !== "hide" ? 1 : 0.5
                            visible: (source!="" || allitems[deleg_top.mainindex][index][0]==="separator")
                        }

                        Text {

                            id: val;

                            color: (allitems[deleg_top.mainindex][index][0]==="separator") ? "white" : "#cccccc"
                            lineHeight: 1.5

                            font.capitalization: (allitems[deleg_top.mainindex][index][0]==="separator") ? Font.SmallCaps : Font.MixedCase

                            opacity: enabled ? 1 : 0.5

                            font.pointSize: 11
                            font.bold: true

                            enabled: ((allitems[deleg_top.mainindex][index][0] !== "__close" &&
                                       allitems[deleg_top.mainindex][index][0] !=="separator" &&
                                      (allitems[deleg_top.mainindex].length === 1 || index > 0)))


                            // The spaces guarantee a bit of space betwene icon and text
                            text: allitems[deleg_top.mainindex][index][2] + ((allitems[deleg_top.mainindex].length > 1 && index == 0) ? ":" : "")

                            MouseArea {

                                anchors.fill: parent

                                hoverEnabled: true
                                cursorShape: (allitems[deleg_top.mainindex][index][0]!=="separator" && (allitems[deleg_top.mainindex].length === 1 || index > 0)) ?
                                                 Qt.PointingHandCursor :
                                                 Qt.ArrowCursor

                                onEntered: {
                                    context_top.containsMouse = true
                                    if(allitems[deleg_top.mainindex][index][0]!=="separator" && (allitems[deleg_top.mainindex].length === 1 || index > 0))
                                        val.color = "#ffffff"
                                }
                                onExited: {
                                    context_top.containsMouse = false
                                    if(allitems[deleg_top.mainindex][index][0]!=="separator" && (allitems[deleg_top.mainindex].length === 1 || index > 0))
                                        val.color = "#cccccc"
                                }
                                onClicked: {
                                    if(allitems[deleg_top.mainindex][index][0]!=="separator" && (allitems[deleg_top.mainindex].length === 1 || index > 0)) {
                                        if(allitems[deleg_top.mainindex][index][3] === "hide" && !PQSettings.interfacePopoutMainMenu)
                                            context_top.opacity = 0
                                        else
                                            context_top.opacity = 1
                                        var cmd = allitems[deleg_top.mainindex][index][0]
                                        var close = 0
                                        if(cmd.slice(0,8) === "_:_EX_:_") {
                                            if(filefoldermodel.current != -1 && filefoldermodel.countMainView > 0) {
                                                handlingExternal.executeExternal(cmd.substring(8), filefoldermodel.currentFilePath)
                                                if(allitems[deleg_top.mainindex][index][3] === "close")
                                                    toplevel.closePhotoQt()
                                            }
                                            return
                                        }
                                        HandleShortcuts.executeInternalFunction(cmd)
                                    }
                                }

                            }

                        }

                    }

                }

            }

            Component.onCompleted: {
                if(width > mainlistview.maxrowwidth)
                    mainlistview.maxrowwidth = width
            }
            onWidthChanged: {
                if(width > mainlistview.maxrowwidth)
                    mainlistview.maxrowwidth = width
            }

        }

    }

    Component.onCompleted:
        readExternalContextmenu()

    Connections {
        target: PQSettings
        onInterfaceLanguageChanged:
            mainlistview.maxrowwidth = 0
    }

    Connections {
        target: PQKeyPressMouseChecker
        onReceivedMouseButtonPress: {
            if(!context_top.containsMouse)
                hide()
        }
    }

    Connections {
        target: filewatcher
        onContextmenuChanged: {
            readExternalContextmenu()
        }
    }

    function readExternalContextmenu() {

        var tmpentries = handlingExternal.getContextMenuEntries()
        var entries = [[["separator", "", "", ""]]]
        for(var i = 0; i < tmpentries.length; ++i) {
            tmpentries[i][3] = "hide"   // the context menu is hidden when one of these entries is selected
            entries.push([tmpentries[i]])
        }
        // no external entries (only the separator in the list)
        if(entries.length == 1)
            entries = []
        allitems_external = entries
    }

    function show() {

        x = Math.min(variables.mousePos.x, parent.width-width)
        y = Math.min(variables.mousePos.y, parent.height-height)

        opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
