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

// this is the file to be used with Qt >= 6.4
// when running CMake, this file is copied to the real filename if Qt >= 6.4

import QtQuick
import QtQuick.Effects

Item {

    id: blur_top
    anchors.fill: parent

    property list<string> itemkeys: ["image", "statusinfo", "histogram", "quickactions", "mapcurrent", "thumbnails", "metadata", "mainmenu"]
    property var items: {
        "image" : image, // qmllint disable unqualified
        "thumbnails" : loader_thumbnails,
        "statusinfo" : statusinfo,
        "histogram" : loader_histogram,
        "quickactions" : loader_quickactions,
        "mapcurrent" : loader_mapcurrent,
        "mainmenu" : loader_mainmenu,
        "metadata" : loader_metadata
    }

    property string thisis: ""

    property int bluruntil: thisis==="-" ? 0 : (thisis!=="" ? itemkeys.indexOf(thisis) : itemkeys.length)

    Repeater {

        model: PQCSettings.interfaceBlurElementsInBackground ? blur_top.bluruntil : 0 // qmllint disable unqualified

        Item {

            id: deleg

            required property int modelData

            anchors.fill: parent

            ShaderEffectSource{
                id: shader
                sourceItem: blur_top.items[blur_top.itemkeys[deleg.modelData]]
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

}
