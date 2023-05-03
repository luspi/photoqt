/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title. This refers to the way and emphasis with which thumbnails are highlight when active/hovered.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "highlight animation")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Which animation to use for highlighting thumbnails and how much emphasis should be put on it.")
    content: [

        Column {

            spacing: 5

            PQCheckbox {
                id: animLift
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "lift up active thumbnail")
            }

            Row {

                spacing: 10

                enabled: animLift.checked

                Item {
                    width: 20
                    height: 1
                }

                PQText {
                    y: (emphasis.height-height)/2
                    text: "0px"
                }

                PQSlider {
                    id: emphasis
                    from: 0
                    to: 100
                    toolTipSuffix: " px"
                }

                PQText {
                    y: (emphasis.height-height)/2
                    text: "100px"
                }

            }

            PQCheckbox {
                id: animBg
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "invert background color of active thumbnail")
            }

            PQCheckbox {
                id: animLabel
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "invert color of label of active thumbnail")
            }

            PQCheckbox {
                id: animLine
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "line below active thumbnail")
            }

            PQCheckbox {
                id: animMag
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "magnify active thumbnail")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {

            var opt = []
            if(animLift.checked)
                opt.push("liftup")
            if(animBg.checked)
                opt.push("invertbg")
            if(animLabel.checked)
                opt.push("invertlabel")
            if(animLine.checked)
                opt.push("line")
            if(animMag.checked)
                opt.push("magnify")

            PQSettings.thumbnailsHighlightAnimation = opt

            PQSettings.thumbnailsHighlightAnimationLiftUp = emphasis.value

        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        animLift.checked = PQSettings.thumbnailsHighlightAnimation.includes("liftup")
        animBg.checked = PQSettings.thumbnailsHighlightAnimation.includes("invertbg")
        animLabel.checked = PQSettings.thumbnailsHighlightAnimation.includes("invertlabel")
        animLine.checked = PQSettings.thumbnailsHighlightAnimation.includes("line")
        animMag.checked = PQSettings.thumbnailsHighlightAnimation.includes("magnify")
        emphasis.value = PQSettings.thumbnailsHighlightAnimationLiftUp
    }

}
