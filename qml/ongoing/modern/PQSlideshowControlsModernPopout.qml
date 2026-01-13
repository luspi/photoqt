/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import PhotoQt

Window {

    id: slideshow_popout

    //: Window title
    title: qsTranslate("slideshow", "Slideshow") + " | PhotoQt"

    PQSlideshowControls {
        id: slideshow
        state: "popout"
    }

    modality: Qt.NonModal

    minimumWidth: 400
    minimumHeight: 600

    color: palette.base

    onClosing: {
        PQCNotify.slideshowHideHandler()
    }

    onWidthChanged: {
        if(width != PQCWindowGeometry.slideshowcontrolsGeometry.width)
            PQCWindowGeometry.slideshowcontrolsGeometry.width = width
        slideshow.parentWidth = width
    }
    onHeightChanged: {
        if(height != PQCWindowGeometry.slideshowcontrolsGeometry.height)
            PQCWindowGeometry.slideshowcontrolsGeometry.height = height
        slideshow.parentHeight = height
    }
    onXChanged: {
        if(x != PQCWindowGeometry.slideshowcontrolsGeometry.x)
            PQCWindowGeometry.slideshowcontrolsGeometry.x = x
    }
    onYChanged: {
        if(y != PQCWindowGeometry.slideshowcontrolsGeometry.y)
            PQCWindowGeometry.slideshowcontrolsGeometry.y = y
    }

    onVisibilityChanged: {
        var isMax = (visibility === Qt.WindowMaximized)
        if(isMax !== PQCWindowGeometry.slideshowcontrolsMaximized)
            PQCWindowGeometry.slideshowcontrolsMaximized = isMax
    }

    Component.onCompleted: {
        slideshow_popout.setX(PQCWindowGeometry.slideshowcontrolsGeometry.x)
        slideshow_popout.setY(PQCWindowGeometry.slideshowcontrolsGeometry.y)
        slideshow_popout.setWidth(PQCWindowGeometry.slideshowcontrolsGeometry.width)
        slideshow_popout.setHeight(PQCWindowGeometry.slideshowcontrolsGeometry.height)
        slideshow.parentWidth = width
        slideshow.parentHeight = height
        if(PQCConstants.slideshowRunning)
            showNormal()
    }

    Connections {
        target: PQCConstants
        function onSlideshowRunningChanged() {
            if(PQCConstants.slideshowRunning)
                slideshow_popout.showNormal()
            else
                slideshow_popout.close()
        }
    }

}
