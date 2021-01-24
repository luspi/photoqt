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

    id: slideshowcontrols_window

    Component.onCompleted: {
        slideshowcontrols_window.x = windowgeometry.slideshowControlsWindowGeometry.x
        slideshowcontrols_window.y = windowgeometry.slideshowControlsWindowGeometry.y
        slideshowcontrols_window.width = windowgeometry.slideshowControlsWindowGeometry.width
        slideshowcontrols_window.height = windowgeometry.slideshowControlsWindowGeometry.height
    }

    minimumWidth: 200
    minimumHeight: 200

    modality: Qt.NonModal

    objectName: "slideshowcontrolspopout"

    onClosing: {

        windowgeometry.slideshowControlsWindowGeometry = Qt.rect(slideshowcontrols_window.x, slideshowcontrols_window.y, slideshowcontrols_window.width, slideshowcontrols_window.height)
        windowgeometry.slideshowControlsWindowMaximized = (slideshowcontrols_window.visibility==Window.Maximized)

        loader.passOn("slideshowcontrols", "quit", undefined)

        if(variables.visibleItem == "slideshowcontrols")
            variables.visibleItem = ""

    }

    visible: PQSettings.slideShowControlsPopoutElement

    color: "#88000000"

    Loader {
        source: "PQSlideShowControls.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return slideshowcontrols_window.width })
                item.parentHeight = Qt.binding(function() { return slideshowcontrols_window.height })
                slideshowcontrols_window.minimumHeight  = item.childrenRect.height
                slideshowcontrols_window.minimumWidth  = item.childrenRect.width
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(slideshowcontrols_window.objectName)
    }

}
