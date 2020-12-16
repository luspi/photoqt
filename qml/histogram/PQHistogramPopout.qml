/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

    id: histogram_window

    Component.onCompleted: {
        histogram_window.x = windowgeometry.histogramWindowGeometry.x
        histogram_window.y = windowgeometry.histogramWindowGeometry.y
        histogram_window.width = windowgeometry.histogramWindowGeometry.width
        histogram_window.height = windowgeometry.histogramWindowGeometry.height
    }

    minimumWidth: 100
    minimumHeight: 100

    modality: Qt.NonModal

    onClosing: {

        windowgeometry.histogramWindowGeometry = Qt.rect(histogram_window.x, histogram_window.y, histogram_window.width, histogram_window.height)

        PQSettings.histogram = 0
    }

    Connections {
        target: toplevel
        onClosing: {
            windowgeometry.histogramWindowGeometry = Qt.rect(histogram_window.x, histogram_window.y, histogram_window.width, histogram_window.height)
            windowgeometry.histogramWindowMaximized = (histogram_window.visibility==Window.Maximized)
        }
    }

    visible: (PQSettings.histogramPopoutElement&&PQSettings.histogram)

    color: "#88000000"

    Loader {
        source: "PQHistogram.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return histogram_window.width })
                item.parentHeight = Qt.binding(function() { return histogram_window.height })
            }
    }

}
