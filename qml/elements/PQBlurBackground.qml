pragma ComponentBehavior: Bound
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

/*1off_Qt64

import QtQuick

Rectangle {

    id: blur_top
    anchors.fill: parent

    color: PQCLook.transColor // qmllint disable unqualified

    property string thisis: ""

}

2off_Qt64*/

/*1on_Qt65+*/

import QtQuick
import QtQuick.Effects
import PQCExtensionsHandler

Item {

    id: blur_top
    anchors.fill: parent

    property list<string> itemkeys: ["image", "statusinfo", "thumbnails", "metadata", "mainmenu"].concat(PQCExtensionsHandler.getNotModalExtensions())
    property var items: {
        "image" : image, // qmllint disable unqualified
        "thumbnails" : loader_thumbnails,
        "statusinfo" : statusinfo,
        "mainmenu" : loader_mainmenu,
        "metadata" : loader_metadata
    }
    property int numIntegratedItems: Object.keys(items).length

    property string thisis: ""

    property int bluruntil: thisis!=="" ? itemkeys.indexOf(thisis) : itemkeys.length

    property bool resetBlur: false

    Repeater {

        model: (PQCSettings.interfaceBlurElementsInBackground && !blur_top.resetBlur) ? blur_top.bluruntil : 0 // qmllint disable unqualified

        Item {

            id: deleg

            required property int modelData
            property bool isExtension: modelData>=blur_top.numIntegratedItems

            anchors.fill: parent

            ShaderEffectSource{
                id: shader
                sourceItem: isExtension ? loader_extensions.itemAt(PQCExtensionsHandler.getExtensions().indexOf(blur_top.itemkeys[deleg.modelData])) : blur_top.items[blur_top.itemkeys[deleg.modelData]]
                anchors.fill: parent
                property int adjust: deleg.modelData == 0 ? PQCSettings.imageviewMargin : 0 // qmllint disable unqualified
                sourceRect: Qt.rect(blur_top.parent.x-adjust, blur_top.parent.y-adjust, blur_top.width, blur_top.height)
            }

            MultiEffect {
                source: shader
                anchors.fill: parent
                blur: 1.0
                blurEnabled: true
                blurMax: 32
                shadowBlur: 0
                shadowEnabled: false
                paddingRect: Qt.rect(0,0,0,0)
            }

        }

    }

    Rectangle {
        visible: PQCSettings.interfaceBlurElementsInBackground // qmllint disable unqualified
        anchors.fill: parent
        color: PQCLook.transColor // qmllint disable unqualified
        radius: blur_top.parent.radius // qmllint disable missing-property
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // When switching to fullscreen mode and back then the blur region is a stretched vertically
    // To fix this we reset the blur everytime the window mode setting is changed.

    Connections {
        target: PQCSettings
        function onInterfaceWindowModeChanged() {
            blur_top.resetBlur = true
        }
    }

    Timer {
        interval: 200
        running: blur_top.resetBlur
        onTriggered: {
            blur_top.resetBlur
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////

}

/*2on_Qt65+*/
