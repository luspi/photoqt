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
import PhotoQt

Window {

    id: metadata_popout

    //: Window title
    title: qsTranslate("actions", "Metadata") + " | PhotoQt"

    PQMetaDataModern {
        id: metadata
        setVisible: true
        state: "popout"
    }

    modality: Qt.NonModal

    minimumWidth: 400
    minimumHeight: 600

    color: "transparent"

    onClosing: {
        if(!PQCConstants.photoQtShuttingDown)
            PQCSettings.interfacePopoutMetadata = false
        PQCConstants.metadataShowWhenReady = true
    }

    onWidthChanged: {
        if(width != PQCSettings.metadataElementSize.width)
            PQCSettings.metadataElementSize.width = width
        metadata.parentWidth = width
    }
    onHeightChanged: {
        if(height != PQCSettings.metadataElementSize.height)
            PQCSettings.metadataElementSize.height = height
        metadata.parentHeight = height
    }
    onXChanged: {
        if(x != PQCSettings.metadataElementPosition.x)
            PQCSettings.metadataElementPosition.x = x
    }
    onYChanged: {
        if(y != PQCSettings.metadataElementPosition.y)
            PQCSettings.metadataElementPosition.y = y
    }

    onVisibilityChanged: {
        var isMax = (visibility === Qt.WindowMaximized)
        if(isMax !== PQCWindowGeometry.metadataMaximized)
            PQCWindowGeometry.metadataMaximized = isMax
    }

    Component.onCompleted: {
        metadata_popout.setX(PQCSettings.metadataElementPosition.x)
        metadata_popout.setY(PQCSettings.metadataElementPosition.y)
        metadata_popout.setWidth(PQCSettings.metadataElementSize.width)
        metadata_popout.setHeight(PQCSettings.metadataElementSize.height)
        metadata.parentWidth = width
        metadata.parentHeight = height
        showNormal()
    }

}
