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

Item {

    // Element radius is the radius of "windows" (e.g., About or Quicksettings)
    // Item radius is the radius of smaller items (e.g., spinbox)
    readonly property int global_element_radius: 10
    readonly property int global_item_radius: 5

    property bool guiBlocked: false

    property bool imageItemBlocked: false

    property bool slideshowRunning: false

    property int totalNumberImagesCurrentFolder: 0
    property int currentFilePos: allFilesCurrentDir.indexOf(getanddostuff.removePathFromFilename(currentFile))>=0
                                    ? allFilesCurrentDir.indexOf(getanddostuff.removePathFromFilename(currentFile))
                                    : -1
    property string currentFile: ""
    property string filter: ""
    property string currentDir: ""
    property var allFilesCurrentDir: []

    property bool deleteNothingLeft: false
    property bool filterNoMatch: false

    property string filemanagementCurrentCategory: ""

    property int startupUpdateStatus: 0
    property string startupFilenameAfter: ""

    property var shortcutsMouseGesture: []
    property point shorcutsMouseGesturePointIntermediate: Qt.point(-1,-1)

    property int thumbnailsheight: 0

    property point windowXY: Qt.point(-1,-1)

    property int animationSpeed: settings.animations ? 250 : 0

    property int wheelUpDown: 0
    property int wheelLeftRight: 0

    // temporary solution to avoid having to retranslate the names for the possible shortcuts (will be replaced with better solution for following release)
    property var shortcutTitles: ({})

}
