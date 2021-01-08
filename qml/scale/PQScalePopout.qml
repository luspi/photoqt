/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: scale_window

    Component.onCompleted: {
        scale_window.setX(windowgeometry.scaleWindowGeometry.x)
        scale_window.setY(windowgeometry.scaleWindowGeometry.y)
        scale_window.setWidth(windowgeometry.scaleWindowGeometry.width)
        scale_window.setHeight(windowgeometry.scaleWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.scaleWindowGeometry = Qt.rect(scale_window.x, scale_window.y, scale_window.width, scale_window.height)
        windowgeometry.scaleWindowMaximized = (scale_window.visibility==Window.Maximized)

        if(variables.visibleItem == "filerename")
            variables.visibleItem = ""
    }

    visible: PQSettings.scalePopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onScalePopoutElementChanged: {
            if(!PQSettings.scalePopoutElement)
                scale_window.visible = Qt.binding(function() { return PQSettings.scalePopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQScale.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return scale_window.width })
                item.parentHeight = Qt.binding(function() { return scale_window.height })
            }
    }

}
