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

import "../elements"

Rectangle {

    id: top

    property string title: ""
    property string helptext: ""
    property bool helptext_warning: false

    property string fontcolor: colour.text

    property string imageSource: ""
    property int imageHeight: titletext.height*1.5

    width: tab_top.titlewidth + 40
    height: childrenRect.height
    y: (item_top.height-height)/2
    color: "transparent"
    Row {
        spacing: 10
        Rectangle { color: "transparent"; width: 10; height: 1; }
        Image {
            id: titleimage
            source: top.imageSource
            fillMode: Image.PreserveAspectFit
            height: imageSource!=""?top.imageHeight:0
            visible: imageSource!=""
            mipmap: true
            opacity: enabled ? 1 : 0.3
        }

        Text {
            id: titletext
            y: (parent.height-height)/2
            color: top.fontcolor
            font.pointSize: 12
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            text: top.title
            Component.onCompleted:
                if(width > tab_top.titlewidth)
                    tab_top.titlewidth = width+titleimage.width
        }

    }

    ToolTip {
        text: parent.helptext
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
