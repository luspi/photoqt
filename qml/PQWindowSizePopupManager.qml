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

    id: manager

    property bool fileDialog: false
    property bool settingsManager: false
    property bool slideShowSettings: false
    property bool scaleImage: false
    property bool about: false
    property bool wallpaper: false
    property bool filter: false
    property bool saveAs: false
    property bool chromecast: false
    property bool advancedSort: false

    Connections {

        target: PQSettings

        onInterfacePopoutWhenWindowIsSmallChanged:
            checkWindowSize()

    }

    Connections {

        target: toplevel

        onWidthChanged:
            checkWindowSize()
        onHeightChanged:
            checkWindowSize()

    }

    function checkWindowSize() {

        var forcepopout = (toplevel.width < 800 || toplevel.height < 600)
        if(!PQSettings.interfacePopoutWhenWindowIsSmall)
            forcepopout = false

        settingsManager = forcepopout
        fileDialog = forcepopout
        slideShowSettings = forcepopout
        scaleImage = forcepopout
        about = forcepopout
        wallpaper = forcepopout
        filter = forcepopout
        saveAs = forcepopout
        chromecast = forcepopout
        advancedSort = forcepopout

    }

}
