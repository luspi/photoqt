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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../elements"

Window {

    id: slideshow_window

    //: Window title
    title: em.pty+qsTranslate("slideshow", "Slideshow settings")

    Component.onCompleted: {
        slideshow_window.setX(windowgeometry.slideshowWindowGeometry.x)
        slideshow_window.setY(windowgeometry.slideshowWindowGeometry.y)
        slideshow_window.setWidth(windowgeometry.slideshowWindowGeometry.width)
        slideshow_window.setHeight(windowgeometry.slideshowWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal
    objectName: "slideshowsettingspopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "slideshowsettings")
            variables.visibleItem = ""
    }

    visible: PQSettings.slideShowSettingsPopoutElement&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onSlideshowPopoutElementChanged: {
            if(!PQSettings.slideShowSettingsPopoutElement)
                slideshow_window.visible = Qt.binding(function() { return PQSettings.slideShowSettingsPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQSlideShowSettings.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return slideshow_window.width })
                item.parentHeight = Qt.binding(function() { return slideshow_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(slideshow_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.slideshowWindowGeometry = Qt.rect(slideshow_window.x, slideshow_window.y, slideshow_window.width, slideshow_window.height)
        windowgeometry.slideshowWindowMaximized = (slideshow_window.visibility==Window.Maximized)
    }

}
