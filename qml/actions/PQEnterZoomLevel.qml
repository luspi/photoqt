/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import QtQuick.Controls
import PhotoQt

ApplicationWindow {

    id: zoom_top

    width: 250
    minimumWidth: width
    maximumWidth: width
    height: contcol.height+20
    minimumHeight: contcol.height+20
    maximumHeight: contcol.height+20

    modality: Qt.ApplicationModal

    Column {

        id: contcol

        y: 10
        width: parent.width

        spacing: 10

        PQTextL {
            x: (parent.width-width)/2
            text: qsTranslate("zoom", "Zoom level")
            font.weight: PQCLook.fontWeightBold
        }

        Row {
            x: 10
            spacing: 5
            PQSpinBox {
                id: zoomedit
                width: zoom_top.width-suffix.width-20
                live: true

            }
            PQText {
                id: suffix
                y: (zoomedit.height-height)/2
                text: "%"
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQButton {
                text: genericStringOk
                smallerVersion: true
                extraSmall: true
                onClicked:
                    zoom_top.applyZoom()
            }
            PQButton {
                text: genericStringCancel
                smallerVersion: true
                extraSmall: true
                onClicked: zoom_top.close()
            }
        }

    }

    onVisibleChanged: (visible) => {
        if(visible) {
            zoomedit.enabled = true
            zoomedit.setValue(Math.round((PQCConstants.showingPhotoSphere ? 1 : PQCConstants.devicePixelRatio) * PQCConstants.currentImageScale*100))
            zoomedit.forceActiveFocus()
        } else {
            zoomedit.enabled = false
            PQCNotify.resetActiveFocus()
        }
        PQCConstants.modalEnterZoomLevel = visible
    }

    Component.onCompleted: {
        if(PQCFileFolderModel.currentFile !== "")
            show()
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "forceCloseEverything") {

                zoom_top.close()

            } else if(what === "show" && args[0] === "EnterZoom") {

                if(PQCFileFolderModel.currentFile !== "")
                    zoom_top.show()

            } else if(what === "hide" && args[0] === "EnterZoom") {

                zoom_top.close()

            } else if(zoom_top.visible) {

                if(what === "keyEvent") {

                    if(args[0] === Qt.Key_Escape)
                        zoom_top.close()

                    else if(args[0] === Qt.Key_Enter || args[0] === Qt.Key_Return)
                        zoom_top.applyZoom()

                }
            }
        }

    }

    function applyZoom() {

        PQCNotify.applyZoomLevel(zoomedit.value / ((PQCConstants.showingPhotoSphere ? 1 : PQCConstants.devicePixelRatio) * 100))
        close()

    }

}
