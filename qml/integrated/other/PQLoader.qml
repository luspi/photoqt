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
import PhotoQt.Integrated
import PQCImageFormats

Item {

    anchors.fill: parent

    Loader {
        id: loader_about
        active: false
        sourceComponent: PQAbout {}
    }

    Loader {
        id: loader_settingsmanager
        active: false
        sourceComponent: PQSettingsManagerPopout {}
    }

    Connections {

        target: PQCNotify

        function onLoaderShow(ele : string) {

            console.log("args: ele =", ele)

            if(ele === "about") {
                if(loader_about.active)
                    PQCNotify.loaderPassOn("show", ["about"])
                else
                    loader_about.active = true
                PQCConstants.idOfVisibleItem = "about"
            } else if(ele === "settingsmanager") {
                if(loader_settingsmanager.active)
                    PQCNotify.loaderPassOn("show", ["settingsmanager"])
                else
                    loader_settingsmanager.active = true
                PQCConstants.idOfVisibleItem = "settingsmanager"
            }

        }

    }

}
