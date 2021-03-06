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

    id: imgur_window

    //: Window title
    title: em.pty+qsTranslate("imgur", "Upload to imgur.com")

    Component.onCompleted: {
        imgur_window.setX(windowgeometry.imgurWindowGeometry.x)
        imgur_window.setY(windowgeometry.imgurWindowGeometry.y)
        imgur_window.setWidth(windowgeometry.imgurWindowGeometry.width)
        imgur_window.setHeight(windowgeometry.imgurWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    objectName: "imgurpopout"

    onClosing: {

        windowgeometry.imgurWindowGeometry = Qt.rect(imgur_window.x, imgur_window.y, imgur_window.width, imgur_window.height)
        windowgeometry.imgurWindowMaximized = (imgur_window.visibility==Window.Maximized)

        if(variables.visibleItem == "imgur")
            variables.visibleItem = ""
    }

    visible: PQSettings.imgurPopoutElement&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onImgurPopoutElementChanged: {
            if(!PQSettings.imgurPopoutElement)
                imgur_window.visible = Qt.binding(function() { return PQSettings.imgurPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQImgur.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return imgur_window.width })
                item.parentHeight = Qt.binding(function() { return imgur_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(imgur_window.objectName)
    }

}
