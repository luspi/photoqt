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
import PhotoQt.CPlusPlus
import PhotoQt.Integrated
import ExtensionSettings
import PQCExtensionsHandler

Item {

    id: extension_container

    property string extensionId: ""

    ExtensionSettings {
        id: extsettings
        extensionId: extension_container.extensionId
        onValueChanged: (key, value) => {
            if(key === "ExtPopout") {
                extension_container.setActive()
            }
        }
    }

    Component.onCompleted: {
        if(extsettings["ExtPopout"] !== undefined) {
            setActive()
        } else {
            loadWhenReady.restart()
        }
    }

    Timer {
        id: loadWhenReady
        interval: 100
        onTriggered: {
            if(extsettings["ExtPopout"] !== undefined) {
                setActive()
            } else {
                loadWhenReady.restart()
            }
        }
    }

    function setActive() {

        var val = extsettings["ExtPopout"]

        var itg = PQCExtensionsHandler.getExtensionIntegratedAllow(extensionId)
        var ppt = PQCExtensionsHandler.getExtensionPopoutAllow(extensionId)
        var mdl = PQCExtensionsHandler.getExtensionModalMake(extensionId)

        if(mdl) {
            ldr_floating.active = false
            ldr_floating_popout.active = false
            ldr_fullscreen_popout.active = true
        } else {
            ldr_fullscreen_popout.active = false
            ldr_floating.active = ((!val || !ppt) && itg)
            ldr_floating_popout.active = (val && ppt)
        }

    }

    Loader {

        id: ldr_floating
        active: false

        sourceComponent:
            PQTemplateExtensionFloating {
                extensionId: extension_container.extensionId
                settings: extsettings
            }

    }

    Loader {

        id: ldr_floating_popout
        active: false

        sourceComponent:
            PQTemplateExtensionFloatingPopout {
                extensionId: extension_container.extensionId
                settings: extsettings
            }

    }

    Loader {

        id: ldr_fullscreen_popout
        active: false

        sourceComponent:
            PQTemplateExtensionModalPopout {
                extensionId: extension_container.extensionId
                settings: extsettings
            }

    }

}
