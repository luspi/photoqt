/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQml.Models 2.9

import "../../../elements"

PQSetting {
    id: set
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "image library priorities")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "The priority of the image libraries, which one to try first to load an image.")
    content: [

        GridView {
            id: gridview
            width: set.contwidth; height: childrenRect.height
            cellWidth: 300; cellHeight: 50

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            model: DelegateModel {

                property var imagelibraries: []             // the internal key (in order)
                property var imagelibraries_disp: []        // what to display them as (in same order)
                property var imagelibraries_modified: ({})  // keys in modified order

                id: visualModel
                model: imagelibraries.length

                signal updateOrder()

                delegate: DropArea {
                    id: delegate

                    width: gridview.cellWidth
                    height: gridview.cellHeight

                    onEntered: function(drag) {
                        visualModel.items.move((drag.source as PQImageLibraryOrderItem).visualIndex, icon.visualIndex)
                    }

                    onVisualIndexChanged: {
                        updateImageLibrariesOrder.restart()
                    }

                    Connections {
                        target: visualModel
                        onUpdateOrder: {
                            if(delegate.listIndex == -1) return  // ignore startup trigger
                            visualModel.imagelibraries_modified[delegate.visualIndex] = visualModel.imagelibraries[delegate.listIndex]
                        }
                    }

                    property int listIndex: -1
                    property int visualIndex: DelegateModel.itemsIndex

                    // we don't want to have a property binding for this property:
                    // the initial index should remain its listIndex no matter what position it is dragged to
                    Component.onCompleted: {
                        listIndex = DelegateModel.itemsIndex
                    }

                    PQImageLibraryOrderItem {
                        id: icon
                        dragParent: gridview
                        visualIndex: delegate.visualIndex
                        listIndex: delegate.listIndex
                    }

                }

            }

        }

    ]

    Timer {
        id: updateImageLibrariesOrder
        interval: 100
        repeat: false
        onTriggered:
            visualModel.updateOrder()
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            var libs = ""
            for(var key in visualModel.imagelibraries_modified) {
                if(libs != "") libs += ","
                libs += visualModel.imagelibraries_modified[key]
            }
            PQSettings.imageLibrariesOrder = libs
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {

        var dispstr = { "qt" : "Qt",
                        "libraw" : "libraw",
                        "poppler" : "Poppler",
                        "archive" : "LibArchive",
                        "xcftools" : "XCFTools",
                        "graphicsmagick" : "GraphicsMagick",
                        "imagemagick" : "ImageMagick",
                        "freeimage" : "FreeImage",
                        "devil" : "DevIL",
                        "video" : "Video"}

        var libs = PQSettings.imageLibrariesOrder.split(",")
        var disp = []
        for(var l in libs) {
            disp.push(dispstr[libs[l]])
        }

        visualModel.imagelibraries_disp = disp

        for(var i = 0; i < libs.length; ++i)
            visualModel.imagelibraries_modified[i] = libs[i]

        visualModel.imagelibraries = libs

    }

}
