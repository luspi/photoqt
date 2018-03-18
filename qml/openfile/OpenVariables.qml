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
import "handlestuff.js" as Handle

Item {

    property string currentDirectory: ""
    onCurrentDirectoryChanged: {
        if(getanddostuff.doesThisExist(currentDirectory) || currentDirectory.substring(0,7) == "remote:") {
            Handle.loadDirectory()
            watcher.setCurrentDirectoryForChecking(currentDirectory)
            getanddostuff.setOpenFileLastLocation(openvariables.currentDirectory)
        } else
            currentDirectory = getanddostuff.getHomeDir()
    }

    property string currentFocusOn: "filesview"

    property int historypos: -1
    property var history: []
    property bool loadedFromHistory: false

    property var currentDirectoryFolders: []
    property var currentDirectoryFiles: []

    property string filesFileTypeCategorySelected: "all"
    onFilesFileTypeCategorySelectedChanged: {
        Handle.loadDirectoryFiles()
        Handle.loadDirectoryFolders()
    }

    property bool highlightingFromUserInput: false
    property bool textEditedFromHighlighting: false

    Component.onCompleted:
        currentFocusOn = "filesview"

}
