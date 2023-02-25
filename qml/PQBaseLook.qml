/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

Item {

    // these are some base definitions for the look and feel of PhotoQt

    // base font size in pt
    property int fontsize: 11
    // various sizes based on the value defined above
    property int fontsize_s: fontsize-3
    property int fontsize_l: fontsize+4
    property int fontsize_xl: fontsize+9

    // font weights, possible values:
    // - Font.Thin
    // - Font.Light
    // - Font.ExtraLight
    // - Font.Normal
    // - Font.Medium
    // - Font.DemiBold
    // - Font.Bold
    // - Font.ExtraBold
    // - Font.Black
    property int boldweight: Font.Bold
    property int normalweight: Font.Normal


}
