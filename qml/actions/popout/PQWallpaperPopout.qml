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

import PQCWindowGeometry
import "../../elements"

PQTemplatePopout {

    id: wallpaper_popout

    //: Window title
    title: qsTranslate("wallpaper", "Wallpaper") + " | PhotoQt"

    geometry: PQCWindowGeometry.wallpaperGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.wallpaperMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutWallpaper // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.wallpaperForcePopout // qmllint disable unqualified
    source: "actions/PQWallpaper.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "wallpaper") // qmllint disable unqualified
            loader.elementClosed("wallpaper")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutWallpaper) // qmllint disable unqualified
            PQCSettings.interfacePopoutWallpaper = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.wallpaperGeometry) // qmllint disable unqualified
            PQCWindowGeometry.wallpaperGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.wallpaperMaximized) // qmllint disable unqualified
            PQCWindowGeometry.wallpaperMaximized = isMax
    }

}
