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
import ExtensionSettings
import PQCExtensionsHandler

Item {

    id: exttop

    property string extensionId: ""

    ExtensionSettings {
        id: extsettings
        extensionId: exttop.extensionId
        onValueChanged: (key, value) => {
            if(key === "Popout") {
                ldr.setSource()
            }
        }
    }

    Component.onCompleted: {
        console.warn(">>> L:", extsettings["Popout"])
    }

    Loader {

        id: ldr

        Component.onCompleted: {
            setSource()
        }

        function setSource() {
            console.warn(">>>", extsettings["Popout"], exttop.extensionId)
            source = "file:/" + PQCExtensionsHandler.getExtensionLocation(exttop.extensionId) + "/modern/PQ" + exttop.extensionId +
                    (extsettings["Popout"] ? "Popout" : "Floating") + ".qml"
        }

    }

}
