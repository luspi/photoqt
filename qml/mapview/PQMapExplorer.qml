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
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls 1.4
import "../elements"

SplitView {

    id: mapexplorer_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    property int currentDetailLevel: -1

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    property bool finishShow: false

    property var imagesWithLocation: []

    Plugin {
        id: osmPlugin
        name: "osm"//PQSettings.mapviewProvider
        parameters: [
            PluginParameter {
                name: "osm.useragent"
                value: "PhotoQt Image Viewer"
            }
        ]
    }

    Plugin {
        id: googlePlugin
        name: "googlemaps"
        parameters: [
            PluginParameter {
                name: "googlemaps.maps.apikey"
                value: (PQSettings.mapviewProviderGoogleMapsToken=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderGoogleMapsToken))
            }
        ]
    }

    Plugin {
        id: esriPlugin
        name: "esri"
        parameters: [
            PluginParameter {
                name: "esri.token"
                value: (PQSettings.mapviewProviderEsriAPIKey=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderEsriAPIKey))
            }
        ]
    }

    Map {

        id: map

        width: parent.width-visibleimages.width
        height: parent.height

        center: QtPositioning.coordinate(49.01, 8.40) // Karlsruhe
        zoomLevel: 1

        property int curZ: 0

        plugin: (PQSettings.mapviewProvider=="googlemaps" ? googlePlugin : (PQSettings.mapviewProvider=="esri" ? esriPlugin : osmPlugin))

        onZoomLevelChanged: {
            if(finishShow)
                PQLocation.storeMapState(map.zoomLevel, map.center.latitude, map.center.longitude)
            for(var i = 0; i < steps.length; ++i) {
                if(map.zoomLevel > steps[i][1]) {
                    detaillevel = i
                    break
                }
            }
        }

        property real visibleLatitudeLeft: -180
        property real visibleLatitudeRight: 180
        property real visibleLongitudeLeft: -180
        property real visibleLongitudeRight: 180

        Timer {
            id: updateVisibleRegion
            interval: 500
            repeat: true
            running: mapexplorer_top.visible
            onTriggered: {
                map.visibleLatitudeLeft = map.visibleRegion.boundingGeoRectangle().topLeft.latitude
                map.visibleLongitudeLeft = map.visibleRegion.boundingGeoRectangle().topLeft.longitude
                map.visibleLatitudeRight = map.visibleRegion.boundingGeoRectangle().bottomRight.latitude
                map.visibleLongitudeRight= map.visibleRegion.boundingGeoRectangle().bottomRight.longitude
            }
        }

        onCenterChanged: {
            if(finishShow)
                PQLocation.storeMapState(map.zoomLevel, map.center.latitude, map.center.longitude)
        }

        property var steps: [
            [0.001, 16.5],
            [0.005, 14],
            [0.01, 13],
            [0.02, 12],
            [0.05, 11],
            [0.1, 10],
            [0.2, 9],
            [0.5, 7.5],
            [1, 6.5],
            [2, 5.5],
            [4, 4.5],
            [8, 3.5],
            [12, 1],
        ]

        property int detaillevel: 0

        MapItemView {

            model: ListModel { id: mdl }

            delegate: MapQuickItem {

                id: deleg

                anchorPoint.x: container.width/2
                anchorPoint.y: container.height/2

                visible: (x > -width && x < map.width && y > -height && y < map.height) && (lvls.indexOf(""+map.detaillevel) != -1)

                coordinate: QtPositioning.coordinate(latitude, longitude)

                property var lvls

                sourceItem:
                    Rectangle {
                        id: container
                        width: 68
                        height: 68
                        color: "white"
                        property var keys: Object.keys(labels)
                        Image {
                            id: image
                            x: 2
                            y: 2
                            width: 64
                            height: 64
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: width
                            sourceSize.height: height
                            mipmap: true
                            cache: true
                            asynchronous: true
                            source: (!visible && source=="") ? "" : ("image://thumb/" + handlingGeneral.toPercentEncoding(filename))
                        }
                        Repeater {
                            model: container.keys.length
                            Rectangle {
                                x: parent.width-width*0.8
                                y: -height*0.2
                                width: numlabel.width+20
                                height: numlabel.height+4
                                color: "#0088ff"
                                radius: height/4
                                visible: labels[container.keys[index]]>1 && map.detaillevel==container.keys[index]
                                PQText {
                                    id: numlabel
                                    x: 10
                                    y: 2
                                    font.weight: baselook.boldweight
                                    anchors.centerIn: parent
                                    text: labels[container.keys[index]]
                                }
                            }
                        }
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            tooltip: "<img src='" + image.source + "'><br><br>" +
                                     " <b>" + handlingFileDir.getFileNameFromFullPath(filename) + "</b>" +
                                     (labels[map.detaillevel]>1 ? (" + " + (labels[map.detaillevel]-1) + "") : "")
                            onEntered: {
                                map.curZ += 1
                                deleg.z = map.curZ
                            }
                        }

                        Component.onCompleted: {
                            lvls = levels.split("_")
                        }

                    }

            }

        }

    }


    Rectangle {

        id: visibleimages

        x: (parent.width-width)
        width: parent.width/2
        height: parent.height

        color: "#333333"

//        Component.onCompleted:
//            console.log(map.visibleRegion.contains())

        Flow {

            id: files_grid

            anchors.fill: parent

            Repeater {

                model: imagesWithLocation.length/3

                delegate: Item {

                    id: maindeleg

                    width: opacity!=0 ? 100 : 0
                    height: 100

                    Behavior on width { NumberAnimation { duration: 200 } }

    //                Component.onCompleted:
    //                    console.log("index =", imagesWithLocation[index])

                    readonly property string fpath: imagesWithLocation[3*index+0]
                    readonly property real latitude: imagesWithLocation[3*index+1]
                    readonly property real longitude: imagesWithLocation[3*index+2]
                    readonly property string fname: handlingFileDir.getFileNameFromFullPath(fpath)

                    opacity: (latitude>map.visibleLatitudeRight &&
                             latitude<map.visibleLatitudeLeft &&
                             longitude>map.visibleLongitudeLeft &&
                             longitude<map.visibleLongitudeRight) ? 1 : 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Rectangle {

                        id: deleg_container

                        width: maindeleg.width
                        height: maindeleg.height

                        opacity: 1


                        color: "#44aaaaaa"

                        border.width: 1
                        border.color: "#282828"

                        Image {

                            id: fileicon

                            x: (parent.width-width)/2
                            y: (parent.height-height)/2
                            width: parent.width-2*PQSettings.openfileElementPadding
                            height: parent.height-2*PQSettings.openfileElementPadding

                            asynchronous: true

                            fillMode: Image.PreserveAspectFit

                            smooth: true
                            mipmap: false

                            opacity: 1
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            // if we do not cache this image, then we keep the generic icon here
                            source: filethumb.status==Image.Ready ? "" : "image://icon/::squared::"+handlingFileDir.getSuffix(maindeleg.fname)

                            Image {

                                id: filethumb
                                anchors.fill: parent

                                cache: false

                                sourceSize: Qt.size(256, 256)

                                fillMode: Image.PreserveAspectCrop

                                // mipmap does not look good, use only smooth
                                smooth: true
                                asynchronous: true

                                // if we do not cache this image, then we keep this empty and thus preserve the generic icon in the outside image
                                source: "image://thumb/" + maindeleg.fpath

                            }

                        }
                    }
                }

            }

        }


    }


    Connections {
        target: loader
        onMapExplorerPassOn: {
            if(what == "show") {
                map.curZ = 0
                opacity = 1
                variables.visibleItem = "mapexplorer"
                var dat = PQLocation.getMapState()
                map.zoomLevel = dat[0]
                map.center.latitude = dat[1]
                map.center.longitude = dat[2]
                finishShow = true
                PQLocation.scanForLocations(filefoldermodel.entriesMainView)
                PQLocation.processSummary(handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath))
                loadImageBG.start()
            } else if(what == "hide") {
                opacity = 0
            } else if(what == "keyevent") {
//                if(param[0] == Qt.Key_Escape)
//                    button_cancel.clicked()
//                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
//                    button_start.clicked()
            }
        }
    }

    Timer {
        id: loadImageBG
        interval: 250
        repeat: false
        running: false
        onTriggered:
            loadImages()
    }

    function loadImages() {

        var items = PQLocation.imageList
        var labels = PQLocation.labelList

        mdl.clear()

        for(var key in items) {


            var item_labels = {}

            for(var det = 0; det < 13; ++det) {
                var labelkey = det + "::" + key;
                if(labelkey in labels)
                    item_labels[det] = labels[labelkey]
            }

            var _latitude = ""+key.split("::")[0]
            var _longitude = ""+key.split("::")[1]
            var _filename = ""+items[key][0]
            var _detaillevels = items[key]
            _detaillevels.shift()
            _detaillevels = _detaillevels.join("_")

            mdl.append({"latitude": _latitude,
                        "longitude": _longitude,
                        "filename": _filename,
                        "levels": _detaillevels,
                        "labels": item_labels
                       })

        }

        console.log(PQLocation.allImages.length)
        console.log(PQLocation.allImages[0])
        imagesWithLocation = PQLocation.allImages

    }

}
