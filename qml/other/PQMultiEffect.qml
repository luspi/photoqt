/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

/* :-)) <3 */

/*1off_Qt64
import QtQuick

Item {
    property var source
    property bool blurEnabled
    property int blurMax
    property int blur
    property bool autoPaddingEnabled
    property real saturation
    property bool shadowEnabled
    property bool maskEnabled
    property Item maskSource
    property real shadowVerticalOffset
}
2off_Qt64*/

/*1on_Qt65+*/
import QtQuick.Effects

MultiEffect {
    anchors.fill: source
}
/*2on_Qt65+*/
