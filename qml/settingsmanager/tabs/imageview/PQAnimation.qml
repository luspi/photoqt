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

import "../../../elements"

PQSetting {
    id: set
    //: A settings title referring to the in/out animation of images
    title: em.pty+qsTranslate("settingsmanager_imageview", "animation")
    //: This is referring to the in/out animation of images
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "What type of animation to show, and how fast.")
    content: [

        Flow {

            spacing: 5
            width: set.contwidth

            PQComboBox {
                id: anim_type
                //: This is referring to the in/out animation of images
                tooltip: em.pty+qsTranslate("settingsmanager_imageview", "type of animation")
                y: (parent.height-height)/2
                //: This is referring to the in/out animation of images
                model: [em.pty+qsTranslate("settingsmanager_imageview", "opacity"),
                        //: This is referring to the in/out animation of images
                        em.pty+qsTranslate("settingsmanager_imageview", "along x-axis"),
                        //: This is referring to the in/out animation of images
                        em.pty+qsTranslate("settingsmanager_imageview", "along y-axis")]
            }

            Item {
                width: 10
                height: 2
            }

            Row {

                spacing: 5

                Text {
                    height: anim_type.height
                    verticalAlignment: Text.AlignVCenter
                    //: This is referring to the in/out animation of images
                    text: em.pty+qsTranslate("settingsmanager_imageview", "no animation")
                    color: "white"
                }

                PQSlider {
                    id: anim_dur
                    height: anim_type.height
                    from: 1
                    to: 10
                }

                Text {
                    height: anim_type.height
                    verticalAlignment: Text.AlignVCenter
                    //: This is referring to the in/out animation of images
                    text: em.pty+qsTranslate("settingsmanager_imageview", "long animation")
                    color: "white"
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
            PQSettings.animationDuration = anim_dur.value
            if(anim_type.currentIndex == 1)
                PQSettings.animationType = "x"
            else if(anim_type.currentIndex == 2)
                PQSettings.animationType = "y"
            else
                PQSettings.animationType = "opacity"
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        anim_dur.value = PQSettings.animationDuration
        if(PQSettings.animationType == "x")
            anim_type.currentIndex = 1
        else if(PQSettings.animationType == "y")
            anim_type.currentIndex = 2
        else
            anim_type.currentIndex = 0
    }

}
