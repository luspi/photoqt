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

                property var imagelibraries: ["qt", "libraw", "poppler", "archive", "xcftools", "graphicsmagick", "imagemagick", "freeimage", "devil", "video"]
                property var imagelibraries_disp: ["Qt", "libraw", "Poppler", "LibArchive", "XCFTools", "GraphicsMagick", "ImageMagick", "FreeImage", "DevIL", "Video"]

                id: visualModel
                model: imagelibraries.length

                delegate: DropArea {
                    id: delegate

                    width: gridview.cellWidth
                    height: gridview.cellHeight

                    onEntered: function(drag) {
                        visualModel.items.move((drag.source as Icon).visualIndex, icon.visualIndex)
                    }

                    property int listIndex: 0
                    property int visualIndex: DelegateModel.itemsIndex

                    // we don't want to have a property binding for this property:
                    // the initial index should remain its listIndex no matter what position it is dragged to
                    Component.onCompleted: listIndex = DelegateModel.itemsIndex

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

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {

        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {

    }

}
