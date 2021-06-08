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
import "shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    property var shortcuts: []
    property string visibleItem: ""
    property real currentZoomLevel: 1
    property real currentRotationAngle: 0
    property real currentPaintedZoomLevel: 1
    property string openCurrentDirectory: PQSettings.openKeepLastLocation ? handlingFileDialog.getLastLocation() : handlingFileDir.getHomeDir()
    property point mousePos: Qt.point(-1, -1)
    property int metaDataWidthWhenKeptOpen: 0

    property bool slideShowActive: false
    property bool faceTaggingActive: false

    property var zoomRotationMirror: ({})

    property bool settingsManagerExpertMode: false

    property bool videoControlsVisible: false

    Connections {

        target: PQSettings

        onMainMenuPopoutElementChanged:
            loader.ensureItIsReady("mainmenu")

        onMetadataPopoutElementChanged:
            loader.ensureItIsReady("metadata")

        onHistogramPopoutElementChanged:
            loader.ensureItIsReady("histogram")

        onSlideShowSettingsPopoutElementChanged: {
            if(variables.visibleItem == "slideshowsettings") {
                loader.ensureItIsReady("slideshowsettings")
                loader.show("slideshowsettings")
            }
        }

    }

}
