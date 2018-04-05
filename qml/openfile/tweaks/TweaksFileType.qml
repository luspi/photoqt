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

import "../../elements"

Rectangle {
    id: hovprev_but
    anchors.right: remember.left
    y: 10
    width: select.width+20
    height: parent.height-20
    color: "#00000000"

    // Select which group of images to display
    CustomComboBox {
        id: select
        y: (parent.height-height)/2
        width: 200
        backgroundColor: "#313131"
        radius: 5
        showBorder: false
        currentIndex: 0
        onCurrentIndexChanged:
            openvariables.filesFileTypeCategorySelected = allfiletypes[currentIndex]
        property var allfiletypes: []
        model: []
        Component.onCompleted: {
            model.push("[B]"+em.pty+qsTr("All supported images"))
            allfiletypes.push("all")
            model.push("---SEP---")
            model.push("Qt")
            allfiletypes.push("qt")
            if(getanddostuff.isGraphicsMagickSupportEnabled()) {
                model.push("GraphicsMagick")
                allfiletypes.push("gm")
            }
            if(getanddostuff.isLibRawSupportEnabled()) {
                model.push("LibRaw")
                allfiletypes.push("raw")
            }
            if(getanddostuff.isDevILSupportEnabled()) {
                model.push("DevIL")
                allfiletypes.push("devil")
            }
            if(getanddostuff.isFreeImageSupportEnabled()) {
                model.push("FreeImage")
                allfiletypes.push("freeimage")
            }
            if(getanddostuff.isPopplerSupportEnabled()) {
                model.push("PDF (Poppler)")
                allfiletypes.push("poppler")
            }
            model.push(em.pty+qsTr("All files"))
            allfiletypes.push("allfiles")
        }
    }

}
