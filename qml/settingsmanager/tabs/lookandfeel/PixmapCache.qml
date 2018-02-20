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

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle
            //: The pixmap cache is used to cache loaded images so they can be loaded much quicker a second time
            title: em.pty+qsTr("Pixmap Cache")
            helptext: em.pty+qsTr("Here you can adjust the size of the pixmap cache. This cache holds the loaded image elements that have been displayed. This doesn't help when first displaying an image, but can speed up its second display significantly. On the other hand, it does increase the memory in use, up to the limit set here. If you disable the cache altogether (value of 0), then each time an image is displayed, it is loaded fresh from the harddrive.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: pixmapcache_sizeslider

                    width: Math.min(400, settings_top.width-entrytitle.width-pixmapcache_sizespinbox.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 1000

                    stepSize: 1
                    scrollStep: 5

                    value: entry.val

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: pixmapcache_sizespinbox

                    width: 85

                    minimumValue: 0
                    maximumValue: 1000

                    suffix: " MB"

                    value: entry.val

                    onValueChanged:
                        entry.val = value

                }

            }

        }

    }

    function setData() {
        entry.val = settings.pixmapCache
    }

    function saveData() {
        settings.pixmapCache = entry.val
    }

}
