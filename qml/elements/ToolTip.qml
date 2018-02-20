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

MouseArea {
    id: tooltip_top
    property string text: ""
    property int waitbefore: 500

    anchors.fill: parent
    hoverEnabled: tooltip_top.enabled

    onExited: globaltooltip.hideText()
    onCanceled: globaltooltip.hideText()

    Timer {
        interval: parent.waitbefore
        running: tooltip_top.enabled && tooltip_top.containsMouse && tooltip_top.text.length
        // The <span></span> part forces html rendering and adds dynamic linebreaks. Otherwise long lines may not be wrapped at all.
        onTriggered: globaltooltip.showText(tooltip_top, Qt.point(tooltip_top.mouseX, tooltip_top.mouseY), "<span></span>" + tooltip_top.text)
    }

}
