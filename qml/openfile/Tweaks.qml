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

import "./tweaks"
import "handlestuff.js" as Handle

Rectangle {

    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    property alias tweaksZoom: zoom

    height: 50

    color: "#44000000"

    TweaksUserPlaces { id: up }

    // Zoom files view
    TweaksZoom { id: zoom }

    // choose which file type group to show
    TweaksFileType { id: ft }

    // remember the current location in between PhotoQt sessions
    TweaksRememberLocation { id: remember }

    // control the preview image
    TweaksPreview { id: prev }

    // manage the file thumbnails
    TweaksThumbnails { id: thumb }

    // which view mode to use (lists vs icons)
    TweaksViewMode { id: viewmode }

}
