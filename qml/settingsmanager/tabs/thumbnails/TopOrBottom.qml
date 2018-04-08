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

    //: Refers to the top and bottom screen edges
    title: em.pty+qsTr("Top or Bottom")
    helptext: em.pty+qsTr("Per default the bar with the thumbnails is shown at the lower screen edge. However, some might find it nice and handy to have the thumbnail bar at the upper edge.")

    ExclusiveGroup { id: edgegroup; }

    content: [

        CustomRadioButton {
            id: loweredge
            //: Edge refers to a screen edge
            text: em.pty+qsTr("Show at lower edge")
            checked: true
            exclusiveGroup: edgegroup
        },

        CustomRadioButton {
            id: upperedge
            //: Edge refers to a screen edge
            text: em.pty+qsTr("Show at upper edge")
            exclusiveGroup: edgegroup
        }

    ]

    function setData() {
        loweredge.checked = (settings.thumbnailPosition !== "Top")
        upperedge.checked = (settings.thumbnailPosition === "Top")
    }

    function saveData() {
        settings.thumbnailPosition = (loweredge.checked ? "Bottom" : "Top")
    }

}
