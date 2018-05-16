/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Layouts 1.2

import "../elements"

Rectangle {

    id: item_top

    // These are some properties controlling the title of the entry
    property string title: ""
    property string helptext: ""
    property bool helptext_warning: false
    property string fontcolor: colour.text

    // This is the placeholder for the content
    property alias content: entrycontentflow1.children
    property alias content2: entrycontentflow2.children
    property alias content3: entrycontentflow3.children

    // Adjust size
    x: 10
    width: settings_top.width-20
    height: childrenRect.height+16

    color: "transparent"

    property string imageSource: ""


    // Two items next to each other: Entry and Content
    Item {

        y: 8

        width: parent.width
        height: Math.max(entrytitle.height, entrycontent.height)

        // The entry title
        Item {

            id: entrytitle

            // The width is the max title text width in this tab, plus 40 pixels for padding
            x: 0
            y: (Math.max(entrytitle.height, entrycontent.height)-height)/2
            width: Math.min(400, settings_top.width/4+20)
            height: Math.max(titleimage.height, thetext.height)

            Image {
                id: titleimage
                source: item_top.imageSource
                fillMode: Image.PreserveAspectFit
                width: 50
                visible: imageSource!=""
                mipmap: true
                opacity: enabled ? 1 : 0.3
            }

            // This holds the title text
            Text {

                id: thetext

                x: (imageSource!=""?titleimage.width+10:0)
                y: (imageSource!=""?(titleimage.height-height)/2:0)
                width: settings_top.width/4 - (imageSource!=""?titleimage.width+10:0)

                // some styling
                color: item_top.fontcolor
                font.pointSize: 12
                font.bold: true
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter

                // The title text
                text: item_top.title

            }

            // The tooltip with some info acting as accessor for SettingInfoOverlay
            ToolTip {
                text: item_top.helptext
                cursorShape: Qt.PointingHandCursor
                waitbefore: 100
                onEntered: {
                    if(parent.helptext_warning)
                        globaltooltip.setTextColor(colour.tooltip_warning)
                    else
                        globaltooltip.setTextColor(colour.tooltip_text)
                }
                onExited:
                    globaltooltip.setTextColor(colour.tooltip_text)
                onClicked:
                    settingsinfooverlay.show(title, helptext)
            }

        }

        // Placeholder for the content
        Item {

            id: entrycontent

            x: entrytitle.width
            y: 0
            width: item_top.width-entrytitle.width
            height: childrenRect.height

            Flow {

                id: entrycontentflow1

                width: parent.width
                height: childrenRect.height
                spacing: 10

            }

            Flow {

                id: entrycontentflow2

                anchors.top: entrycontentflow1.bottom
                anchors.topMargin: height>0 ? 20 : 0

                width: parent.width
                height: childrenRect.height
                spacing: 10

            }

            Flow {

                id: entrycontentflow3

                anchors.top: entrycontentflow2.bottom
                anchors.topMargin: height>0 ? 20 : 0

                width: parent.width
                height: childrenRect.height
                spacing: 10

            }

        }

    }

    Rectangle {
        x: 0
        y: Math.max(entrytitle.height, entrycontent.height)+24
        width: parent.width
        height: 1
        color: "#22ffffff"
    }

}
