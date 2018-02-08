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

Item {
    id: container
    property string category: ""
    property string itemSource: ""
    visible: (opacity!=0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    width: management_top.width-300
    height: management_top.height-250

    signal itemShown()
    signal itemHidden()

    Loader { id: item }

    property bool categorySetUp: false

    onOpacityChanged: {
        if(opacity != 0)
           itemShown()
        else if(opacity == 0)
            itemHidden()
    }

    Connections {
        target: management_top
        onCurrentChanged: {
            if(management_top.current == container.category) {
                container.opacity = 1
                if(!categorySetUp) {
                    item.source = itemSource
                    categorySetUp = true
                }
            } else
                container.opacity = 0
        }
        onVisibleChanged:
            container.opacity = (management_top.visible&&management_top.current==category ? 1 : 0)
    }

}
