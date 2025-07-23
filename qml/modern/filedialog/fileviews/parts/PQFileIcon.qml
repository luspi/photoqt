/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import PhotoQt.Modern

Image {

    id: fileicon

    sourceSize: Qt.size(width,height)

    smooth: true
    mipmap: false

    opacity: view_top.currentFileCut ? 0.3 : 1
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property bool gridlike: false

    property string _foldername: gridlike ? "folder" : (PQCSettings.filedialogZoom<35 ? "folder_listicon_verysmall" : (PQCSettings.filedialogZoom<75 ? "folder_listicon_small" : "folder_listicon"))
    property string sourceString: ("image://icon/" + (deleg.onNetwork ? "network_" : "") + (deleg.isFolder ?
                                        _foldername : PQCScriptsFilesPaths.getSuffix(deleg.currentPath).toLowerCase()))

    source: sourceString

}
