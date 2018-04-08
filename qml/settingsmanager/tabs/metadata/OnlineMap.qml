/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

Entry {

    title: em.pty+qsTr("Online Map for GPS")
    helptext: em.pty+qsTr("If your image includes a GPS location, then a click on the location text will load this location in an online map using your default external browser. Here you can choose which online service to use (suggestions for other online maps always welcome).")

    ExclusiveGroup { id: mapgroup; }

    content: [

        CustomRadioButton {
            id: openstreetmap
            text: "openstreetmap.org"
            exclusiveGroup: mapgroup
            checked: true
        },

        CustomRadioButton {
            id: googlemaps
            text: "maps.google.com"
            exclusiveGroup: mapgroup
        },

        CustomRadioButton {
            id: bingmaps
            text: "bing.com/maps"
            exclusiveGroup: mapgroup
        }

    ]

    function setData() {
        openstreetmap.checked = (settings.metaGpsMapService === "openstreetmap.org")
        googlemaps.checked = (settings.metaGpsMapService === "maps.google.com")
        bingmaps.checked = (settings.metaGpsMapService === "bing.com/maps")
    }

    function saveData() {
        settings.metaGpsMapService = openstreetmap.checked ? "openstreetmap.org" : (googlemaps.checked ? "maps.google.com" : "bing.com/maps")
    }

}
