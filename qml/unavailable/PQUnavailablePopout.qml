/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../elements"

Window {

    id: unavailable_window

    //: Window title, informing user that the requested feature is currently not available
    title: em.pty+qsTranslate("unavailable", "Feature unavailable")

    Component.onCompleted: {
        unavailable_window.setX(windowgeometry.unavailableWindowGeometry.x)
        unavailable_window.setY(windowgeometry.unavailableWindowGeometry.y)
        unavailable_window.setWidth(windowgeometry.unavailableWindowGeometry.width)
        unavailable_window.setHeight(windowgeometry.unavailableWindowGeometry.height)
    }

    modality: Qt.ApplicationModal

    objectName: "unavailablepopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "unavailablepopout")
            variables.visibleItem = ""
    }

    visible: false
    flags: Qt.WindowStaysOnTopHint

    color: "#ee000000"

    Column {

        id: contcol

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: parent.width-50
        height: childrenRect.height

        spacing: 10

        PQTextXL {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.weight: baselook.boldweight
            text: em.pty+qsTranslate("unavailable", "Sorry, but this feature is not yet available on Windows.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item { width: 1; height: 50 }

        PQButton {
            id: buttonClose
            x: (parent.width-width)/2
            text: genericStringClose
            scale: 1.5
            onClicked: {
                if(variables.visibleItem == "unavailablepopout") {
                    unavailable_window.visible = false
                    variables.visibleItem = ""
                }
            }
        }

    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(unavailable_window.objectName)
    }

    Connections {
        target: loader
        onUnavailablePopoutPassOn: {
            if(what == "show" && variables.visibleItem == "") {
                unavailable_window.visible = true
                variables.visibleItem = "unavailablepopout"
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape || param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return) {
                    unavailable_window.visible = false
                    variables.visibleItem = ""
                }
            }
        }
    }

    function storeGeometry() {
        windowgeometry.unavailableWindowGeometry = Qt.rect(unavailable_window.x, unavailable_window.y, unavailable_window.width, unavailable_window.height)
        windowgeometry.unavailableWindowMaximized = (unavailable_window.visibility==Window.Maximized)
    }

}
