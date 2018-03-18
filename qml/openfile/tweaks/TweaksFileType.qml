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
            //: Used as in 'Qt images'
            model.push("Qt " + em.pty+qsTr("images"))
            allfiletypes.push("qt")
            if(getanddostuff.isGraphicsMagickSupportEnabled()) {
                //: Used as in 'GraphicsMagick images'
                model.push("GraphicsMagick " + em.pty+qsTr("images"))
                allfiletypes.push("gm")
            }
            //: Used as in 'LibRaw images'
            if(getanddostuff.isLibRawSupportEnabled()) {
                model.push("LibRaw " + em.pty+qsTr("images"))
                allfiletypes.push("raw")
            }
            //: Used as in 'DevIL images'
            if(getanddostuff.isDevILSupportEnabled()) {
                model.push("DevIL " + em.pty+qsTr("images"))
                allfiletypes.push("devil")
            }
            //: Used as in 'FreeImage images'
            if(getanddostuff.isFreeImageSupportEnabled()) {
                model.push("FreeImage " + em.pty+qsTr("images"))
                allfiletypes.push("freeimage")
            }
            //: Used as in 'Poppler documents'
            if(getanddostuff.isPopplerSupportEnabled()) {
                model.push("Poppler " + em.pty+qsTr("documents"))
                allfiletypes.push("poppler")
            }
            model.push(em.pty+qsTr("All files"))
            allfiletypes.push("allfiles")
        }
    }

}
