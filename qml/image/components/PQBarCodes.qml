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

import PQCScriptsOther
import PQCScriptsClipboard
import PQCNotify
import PQCScriptsImages
import PQCScriptsFilesPaths

import "../../elements"

Item {

    anchors.fill: parent

    property var barcodes: []
    property int barcode_z: 0

    Connections {
        target: image_top
        function onCurrentlyVisibleIndexChanged(currentlyVisibleIndex) {
            if(!loader_top.isMainImage) {
                // videoloader.active = false
                barcodes = []
            }
        }
        function onDetectBarCodes() {
            if(loader_top.isMainImage) {
                if(!PQCNotify.barcodeDisplayed) {
                    barcodes = PQCScriptsImages.getZXingData(imageloaderitem.imageSource)
                    if(barcodes.length === 0) {
                        loader.show("notification", [qsTranslate("image", "Nothing found"), qsTranslate("image", "No bar/QR codes found.")])
                    } else if(barcodes.length/3 == 1) {
                        loader.show("notification", [qsTranslate("image", "Success"),  qsTranslate("image", "1 bar/QR code found.")])
                    } else if(barcodes.length/3 > 1) {
                        loader.show("notification", [qsTranslate("image", "Success"),  qsTranslate("image", "%1 bar/QR codes found.").arg(barcodes.length/3)])
                    }
                    PQCNotify.barcodeDisplayed = barcodes.length>0
                } else {
                    PQCNotify.barcodeDisplayed = false
                    barcodes = []
                }
            }
        }
    }

    Loader {

        active: barcodes.length>0

        Item {
            // id: barcodes
            anchors.fill: parent
            property var list_barcodes: []
            Repeater {
                model: barcodes.length/3

                Rectangle {

                    id: bardeleg
                    property var val: barcodes[3*index]
                    property var loc: barcodes[3*index+1]
                    property var sze: barcodes[3*index+2]
                    x: loc.x
                    y: loc.y
                    width: sze.width
                    height: sze.height

                    color: "#8800ff00"
                    radius: 5

                    property bool overrideCursorSet: false

                    Column {

                        x: (parent.width-width)/2
                        y: (parent.height-height)/2

                        spacing: 1

                        scale: 1/loader_top.imageScale
                        Behavior on scale { NumberAnimation { duration: 200 } }

                        Rectangle {
                            id: txtcont
                            x: (parent.width-width)/2
                            width: valtxt.width+10
                            height: valtxt.height+10
                            color: "white"
                            radius: 5
                            PQTextL {
                                id: valtxt
                                x: 5
                                y: 5
                                color: "black"
                                text: bardeleg.val
                            }

                        }

                        Row {

                            x: (parent.width-width)/2

                            spacing: 1

                            Rectangle {
                                id: copycont
                                width: 32
                                height: 32
                                color: "#88000000"
                                radius: 5
                                property bool hovered: false
                                opacity: hovered ? 1 : 0.4
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    sourceSize: Qt.size(width, height)
                                    fillMode: Image.Pad
                                    source: "/white/copy.svg"
                                }
                            }

                            Rectangle {
                                id: linkcont
                                width: 32
                                height: 32
                                color: "#88000000"
                                radius: 5
                                property bool hovered: false
                                opacity: hovered ? 1 : 0.4
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                visible: PQCScriptsFilesPaths.isUrl(bardeleg.val)
                                enabled: visible
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    sourceSize: Qt.size(width, height)
                                    fillMode: Image.Pad
                                    source: "/white/globe.svg"
                                }
                            }

                            Connections {

                                target: image_top

                                function onBarcodeClick() {
                                    if(copycont.hovered)
                                        PQCScriptsClipboard.copyTextToClipboard(bardeleg.val)
                                    else if(linkcont.hovered)
                                        Qt.openUrlExternally(bardeleg.val)
                                }

                            }

                            Connections {

                                target: PQCNotify
                                enabled: loader_top.isMainImage

                                function onMouseMove(x, y) {

                                    var local = copycont.mapFromItem(fullscreenitem, Qt.point(x,y))
                                    copycont.hovered = (local.x > 0 && local.y > 0 && local.x < copycont.width && local.y < copycont.height)

                                    local = linkcont.mapFromItem(fullscreenitem, Qt.point(x,y))
                                    linkcont.hovered = (local.x > 0 && local.y > 0 && local.x < linkcont.width && local.y < linkcont.height)

                                    if(copycont.hovered || linkcont.hovered) {
                                        barcode_z += 1
                                        bardeleg.z = barcode_z
                                        bardeleg.overrideCursorSet = true
                                        PQCScriptsOther.setPointingHandCursor()
                                    } else if(bardeleg.overrideCursorSet) {
                                        bardeleg.overrideCursorSet = false
                                        PQCScriptsOther.restoreOverrideCursor()
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
