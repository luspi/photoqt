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
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "map provider")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "The location of images can be shown on an embedded map. By default OpenStreetMap is used, but there are also other providers available, some of which require special setup.") + "<br><br>"
    content: [

        Flow  {

            spacing: 10
            width: set.contwidth

            Item {
                id: maps_combo_cont
                width: maps_combo.width
                height: google_token.height
                PQComboBox {
                    id: maps_combo
                    y: (parent.height-height)/2
                    model: ["OpenStreeMap",
                            "Google Maps",
                            "Esri: ArcGIS",
                            "Mapbox GL"]
                }
            }

            Row {

                spacing: 10

                PQText {
                    y: (google_token.height-height)/2
                    //: This is the language used by Google for authenticating with its API, they call it a token.
                    text: em.pty+qsTranslate("settingsmanager_imageview", "API token:")
                    enabled: visible
                    visible: maps_combo.currentIndex==1
                }

                PQLineEdit {
                    id: google_token
                    width:  400
                    visible: maps_combo.currentIndex==1
                    placeholderText: ""
                    passwordCharacter: "*"
                    echoMode: TextField.Password
                }

                /////////////////////////////////////////////////////

                PQText {
                    y: (google_token.height-height)/2
                    //: This is the language used by Esri for authenticating with its API, they call it a key.
                    text: em.pty+qsTranslate("settingsmanager_imageview", "API key:")
                    enabled: visible
                    visible: maps_combo.currentIndex==2
                }

                PQLineEdit {
                    id: esri_token
                    width:  400
                    visible: maps_combo.currentIndex==2
                    placeholderText: ""
                    passwordCharacter: "*"
                    echoMode: TextField.Password
                }

                /////////////////////////////////////////////////////

                PQText {
                    y: (mapbox_token.height-height)/2
                    //: This is the language used by Esri for authenticating with its API, they call it a key.
                    text: em.pty+qsTranslate("settingsmanager_imageview", "Access Token:")
                    enabled: visible
                    visible: maps_combo.currentIndex==3
                }

                PQLineEdit {
                    id: mapbox_token
                    width:  400
                    visible: maps_combo.currentIndex==3
                    placeholderText: ""
                    passwordCharacter: "*"
                    echoMode: TextField.Password
                }

                /////////////////////////////////////////////////////

                PQButton {

                    text: maps_combo.currentIndex == 0
                            ? "Open website"
                            : (maps_combo.currentIndex == 1
                                    ? "Get token"
                                    : (maps_combo.currentIndex == 2
                                            ? "Get API key"
                                            : "Get Access Token"))

                    scale: 0.8

                    onClicked: {
                        if(maps_combo.currentIndex == 0)
                            Qt.openUrlExternally("https://www.openstreetmap.org/")
                        else if(maps_combo.currentIndex == 1)
                            Qt.openUrlExternally("https://console.cloud.google.com/")
                        else if(maps_combo.currentIndex == 2)
                            Qt.openUrlExternally("https://developers.arcgis.com/sign-up/")
                       else if(maps_combo.currentIndex == 3)
                           Qt.openUrlExternally("https://www.mapbox.com/pricing")
                    }
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {

            if(maps_combo.currentIndex == 0) {
                PQSettings.mapviewProvider = "osm"
            } else if(maps_combo.currentIndex == 1) {
                PQSettings.mapviewProvider = "googlemaps"
            } else if(maps_combo.currentIndex == 2) {
                PQSettings.mapviewProvider = "esri"
            } else if(maps_combo.currentIndex == 3) {
                PQSettings.mapviewProvider = "mapboxgl"
            }

            PQSettings.mapviewProviderGoogleMapsToken = (google_token.text=="" ? "" : handlingGeneral.encryptString(google_token.text))
            PQSettings.mapviewProviderEsriAPIKey = (esri_token.text=="" ? "" : handlingGeneral.encryptString(esri_token.text))
            PQSettings.mapviewProviderMapboxAccessToken = (mapbox_token.text=="" ? "" : handlingGeneral.encryptString(mapbox_token.text))

        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {

        if(PQSettings.mapviewProvider == "googlemaps")
            maps_combo.currentIndex = 1
        else if(PQSettings.mapviewProvider == "esri")
            maps_combo.currentIndex = 2
        else if(PQSettings.mapviewProvider == "mapboxgl")
            maps_combo.currentIndex = 3
        else
            maps_combo.currentIndex = 0

        google_token.text = ""
        if(PQSettings.mapviewProviderGoogleMapsToken != "")
            google_token.text = handlingGeneral.decryptString(PQSettings.mapviewProviderGoogleMapsToken)

        esri_token.text = ""
        if(PQSettings.mapviewProviderEsriAPIKey != "")
            esri_token.text = handlingGeneral.decryptString(PQSettings.mapviewProviderEsriAPIKey)

        mapbox_token.text = ""
        if(PQSettings.mapviewProviderMapboxAccessToken != "")
            mapbox_token.text = handlingGeneral.decryptString(PQSettings.mapviewProviderMapboxAccessToken)

    }

}
