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
import QtQuick.Controls.Styles 1.4

TabView {

    id: view

    // subtab=false means, that the tabbar will cover the full width
    // subtab=true means, that the tabbar will cover half of the width, centered
    property bool subtab: false

    // The number of tabs in the tabview
    property int tabCount: 2

    style: TabViewStyle {

        // Some spacing between the elements
        frameOverlap: -8

        // Slightly darker overall background
        frame: Rectangle {
            color: subtab ? colour.subtab_bg_color : colour.tab_bg_color
        }

        // Invisible main background of tabbar
        tabBar: Rectangle {
            height: childrenRect.height
            width: subtab ? view.width/2 : view.width
            color: "#00000000"
        }

        // ALign tabs in center
        tabsAlignment: Qt.AlignHCenter

        // The tab
        tab: Rectangle {

            // The color depending on state
            color: (styleData.selected || styleData.pressed) ? colour.tab_color_selected : (styleData.hovered ? colour.tab_color_active : colour.tab_color_inactive)
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }

            // Width and Height
            implicitWidth: (subtab ? view.width*2/5 : view.width)/tabCount
            implicitHeight: 30

            // The tab text
            Text {
                color: (styleData.selected || styleData.pressed) ? colour.tab_text_selected : (styleData.hovered ? colour.tab_text_active : colour.tab_text_inactive)
                Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
                font.bold: true
                font.pointSize: 10
                anchors.centerIn: parent
                text: styleData.title
            }
            // Line at TOP of tab (sub-tab only)
            Rectangle {
                x: 0
                y: 0
                width: parent.width
                height: 1
                color: colour.subtab_line_top
                visible: subtab
            }
            // Line at BOTTOM of tab (sub-tab only)
            Rectangle {
                x: 0
                y: parent.height-1
                width: parent.width
                height: 1
                color: colour.subtab_line_bottom
                visible: subtab
            }
            // Change cursor to pointing hand
            ToolTip {
                anchors.fill: parent
                text: styleData.title
                cursorShape: Qt.PointingHandCursor
                onClicked: view.currentIndex = styleData.index
            }
        }

    }

    function nextTab() {
        if(view.currentIndex < view.count-1)
            ++view.currentIndex
        else
            view.currentIndex = 0
    }
    function prevTab() {
        if(view.currentIndex > 0)
            --view.currentIndex
        else
            view.currentIndex = view.count-1
    }

}
