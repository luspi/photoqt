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

Image {

    property string filePath: ""

    asynchronous: true
    source: (filePath==""||!PQSettings.openfilePreview||fileview.currentFolderExcluded) ? "" : ("image://thumb/" + filePath)
    fillMode: Image.PreserveAspectFit

    opacity: 0.4

    Image {

        width: Math.min(200, parent.width-50)
        height: Math.min(200, parent.height-50)

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        visible: imageproperties.isVideo(filePath)

        opacity: 0.5

        source: visible ? "/multimedia/play.png" : ""

    }

}
