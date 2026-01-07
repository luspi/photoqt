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
import QtQuick.Controls
import PhotoQt

ApplicationWindow {

    id: control

    width: 500
    height: 200

    minimumHeight: height
    maximumHeight: height
    minimumWidth: width
    maximumWidth: width

    color: palette.window

    title: "title"

    property string text: ""
    property string informativeText: ""
    property string detailedText: ""

    property alias button1: but1
    property alias button2: but2
    property alias button3: but3

    modality: Qt.ApplicationModal

    signal buttonClicked(int butId)

    onVisibilityChanged: {
        if(visibility == Window.Windowed) {
            PQCConstants.modalWindowOpen = true
        }
    }

    onClosing: {
        console.warn(">>> ON CLOSING ON CLOSING ON CLOSING")
        PQCConstants.modalWindowOpen = false
    }

    Column {

        spacing: 10

        x: 10
        y: 10
        width: parent.width-20

        PQTextL {
            width: control.width-20
            font.weight: PQCLook.fontWeightBold
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: palette.windowText
            text: control.text
        }

        PQText {
            width: control.width-20
            font.weight: PQCLook.fontWeightNormal
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: palette.windowText
            text: control.informativeText
        }

        PQText {
            width: control.width-20
            font.weight: PQCLook.fontWeightNormal
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: palette.windowText
            text: control.detailedText
        }

    }

    Rectangle {
        width: control.width
        height: 1
        color: palette.text
        y: butrow.y-10
        opacity: 0.3
    }

    Row {

        id: butrow

        x: (control.width-20-width)/2
        y: control.height-10-height
        spacing: 5

        PQButton {
            id: but1
            text: genericStringOk
            smallerVersion: true
            extraSmall: true
            onClicked: {
                PQCConstants.modalWindowOpen = false
                control.close()
                control.buttonClicked(1)
            }
        }

        PQButton {
            id: but2
            text: genericStringCancel
            smallerVersion: true
            visible: false
            extraSmall: true
            onClicked: {
                PQCConstants.modalWindowOpen = false
                control.close()
                control.buttonClicked(2)
            }
        }

        PQButton {
            id: but3
            text: ""
            visible: false
            smallerVersion: true
            extraSmall: true
            onClicked: {
                PQCConstants.modalWindowOpen = false
                control.close()
                control.buttonClicked(3)
            }
        }

    }

}
