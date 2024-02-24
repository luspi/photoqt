/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import PQCNotify
import PQCFileFolderModel

import "../elements"

Item {

    id: sphere_top

    parent: image_top
    anchors.fill: parent
    anchors.margins: -PQCSettings.imageviewMargin

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    onOpacityChanged: (opacity) => {
        if(opacity === 0) {
            thesphere.visible = false
            thesphere.source = ""
        }
    }

    Connections {

        target: PQCNotify

        function onEnterPhotoSphere() {
            sphere_top.show()
            // show notification
            // sphere_top.show()
        }

    }

    function show() {
        loader.show("notification", qsTranslate("unavailable", "Photo spheres are not supported by this build of PhotoQt."))
    }

    function hide() {}

}
