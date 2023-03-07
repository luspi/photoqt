/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

Rectangle {

    id: control

    height: 40
    width: buttonSameWidthAsMenu ? menu.width : ((forceWidth==0) ? (txt.width+iconview.width)+2*leftRightTextSpacing : forceWidth)
    property int forceWidth: 0

    opacity: enabled ? 1 : 0.3
    border.width: 0
    border.color: "#00000000"
    radius: 2

    property alias font: txt.font

    color: menu.isOpen ? control.backgroundColorMenuOpen : (control.down ? control.backgroundColorActive : (control.mouseOver ? control.backgroundColorHover : control.backgroundColor))
    clip: true

    Behavior on color { ColorAnimation { duration: 150 } }

    property string text: ""

    property string backgroundColor: "#333333"
    property string backgroundColorHover: "#3a3a3a"
    property string backgroundColorActive: "#444444"
    property string backgroundColorMenuOpen: "#666666"
    property string textColor: "#ffffff"
    property string textColorHover: "#ffffff"
    property string textColorActive: "#ffffff"

    property bool clickOpensMenu: false
    property bool menuOpenDownward: true
    property bool centerMenuOnButton: false
    property bool buttonSameWidthAsMenu: false
    property var listMenuItems: []

    property string imageButtonSource: ""
    property real imageOpacity: 1

    property bool mouseOver: false
    property bool down: false

    property alias tooltip: mousearea.tooltip
    property alias tooltipFollowsMouse: mousearea.tooltipFollowsMouse

    property alias elide: txt.elide

    signal menuItemClicked(var pos)
    signal clicked()

    property int leftRightTextSpacing: 10

    property alias renderType: txt.renderType

    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringOk: em.pty+qsTranslate("buttongeneric", "Ok")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringCancel: em.pty+qsTranslate("buttongeneric", "Cancel")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringSave: em.pty+qsTranslate("buttongeneric", "Save")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringClose: em.pty+qsTranslate("buttongeneric", "Close")

    PQText {
        id: txt
        x: (parent.width-width)/2
        text: parent.text
        height: parent.height
        width: (parent.forceWidth == 0 ? undefined : parent.forceWidth-10)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? control.textColorActive : (control.mouseOver ? control.textColorHover : control.textColor)
        Behavior on color { ColorAnimation { duration: 100 } }
        elide: Text.ElideRight
        renderType: Text.QtRendering
    }

    Image {

        id: iconview

        source: imageButtonSource

        opacity: imageOpacity
        visible: imageButtonSource!=undefined&&imageButtonSource!=""

        sourceSize: Qt.size(control.height*0.75,control.height*0.75)

        x: (parent.width-width)/2
        y: (parent.height-height)/2

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: control.text
        onEntered:
            control.mouseOver = true
        onExited:
            control.mouseOver = false
        onPressed:
            control.down = true
        onReleased:
            control.down = false
        onClicked: {
            if(clickOpensMenu) {
                if(listMenuItems.length > 0) {
                    if(menu.isOpen)
                        menu.close()
                    else {
                        var pos = parent.mapFromItem(control.parent, parent.x, parent.y)
                        if(menuOpenDownward)
                            menu.popup(Qt.point(pos.x + (centerMenuOnButton ? (parent.width-menu.width)/2 : 0), pos.y+parent.height))
                        else
                            menu.popup(Qt.point(pos.x + (centerMenuOnButton ? (parent.width-menu.width)/2 : 0), pos.y-menu.height))
                    }
                }
            } else
                control.clicked()
        }
    }

    PQDropDown {

        id: menu

        entries: listMenuItems
        onTriggered:
            control.menuItemClicked(index)

    }

}
