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

    //: the center is the center of the screen edge. The thing talked about are the thumbnails.
    title: em.pty+qsTr("Keep in Center")
    helptext: em.pty+qsTr("If this option is set, then the current thumbnail (i.e., the thumbnail of the currently displayed image) will always be\
 kept in the center of the thumbnail bar (if possible). If this option is not set, then the active thumbnail will simply be kept visible, but not\
 necessarily in the center.")

    content: [

        CustomCheckBox {
            id: centeron
            text: em.pty+qsTr("Center on Current Thumbnail")
        }

    ]

    function setData() {
        centeron.checkedButton = settings.thumbnailCenterActive
    }

    function saveData() {
        settings.thumbnailCenterActive = centeron.checkedButton
    }

}
