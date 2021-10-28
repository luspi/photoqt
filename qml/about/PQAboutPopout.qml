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

    id: about_window

    //: Window title
    title: em.pty+qsTranslate("about", "About")

    Component.onCompleted: {
        about_window.setX(windowgeometry.aboutWindowGeometry.x)
        about_window.setY(windowgeometry.aboutWindowGeometry.y)
        about_window.setWidth(windowgeometry.aboutWindowGeometry.width)
        about_window.setHeight(windowgeometry.aboutWindowGeometry.height)
    }

    minimumWidth: 300
    minimumHeight: 200

    modality: Qt.ApplicationModal

    objectName: "aboutpopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "about")
            variables.visibleItem = ""
    }

    visible: PQSettings.interfacePopoutAbout&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onInterfacePopoutAboutChanged: {
            if(!PQSettings.interfacePopoutAbout)
                about_window.visible = Qt.binding(function() { return PQSettings.interfacePopoutAbout&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQAbout.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return about_window.width })
                item.parentHeight = Qt.binding(function() { return about_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(about_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.aboutWindowGeometry = Qt.rect(about_window.x, about_window.y, about_window.width, about_window.height)
        windowgeometry.aboutWindowMaximized = (about_window.visibility==Window.Maximized)
    }

}
