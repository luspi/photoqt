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
import QtQuick.Controls 1.4

import "../elements"

FadeInTemplate {

    id: scaleUnsupported_top

    heading: ""
    showSeperators: false

    marginTopBottom: (background.height-300)/2
    clipContent: false

    content: [

        Rectangle {
            color: "transparent"
            width: childrenRect.width
            height: childrenRect.height
            x: (scaleUnsupported_top.contentWidth-width)/2
            Text {
                color: colour.text
                font.pointSize: 20
//				font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: Math.min(background.width/2,500)
                lineHeight: 1.1
                text: em.pty+qsTr("Sorry, this fileformat cannot be scaled with PhotoQt yet!")
            }
        },

        Rectangle {
            color: "transparent"
            width: scaleUnsupported_top.contentWidth
            height: 1
        },

        CustomButton {
            text: em.pty+qsTr("Close")
            fontsize: 15
            x: (scaleUnsupported_top.contentWidth-width)/2
            onClickedButton: hide()
        }

    ]

    Connections {
        target: call
        onScaleunsupportedShow: {
            if(variables.currentFile === "") return
            show()
        }
        onShortcut: {
            if(!scaleUnsupported_top.visible) return
            if(sh == "Escape")
                hide()
        }
        onCloseAnyElement:
            if(scaleUnsupported_top.visible)
                hide()
    }

}
