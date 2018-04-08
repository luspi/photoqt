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

import "./metadata"
import "../../elements"


Item {

    id: tab_top

    property int titlewidth: 100

    anchors {
        fill: parent
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height+20
        contentWidth: maincol.width

        Column {

            id: maincol

            Item { width: 1; height: 10 }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 20
                font.bold: true
                text: em.pty+qsTr("Image Metadata")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20 }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 9
                text: qsTranslate("SettingsManager", "Move your mouse cursor over (or click on) the different settings titles to see more information.")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20 }

            Text {
                color: "white"
                width: flickable.width-20
                x: 10
                wrapMode: Text.WordWrap
                //: Introduction text of metadata tab in settings manager
                text: em.pty+qsTr("PhotoQt can display different information of and about each image. The element for this information is hidden on the left side of the screen and fades in when the mouse cursor gets close to the left screen edge and/or when the set shortcut is triggered. On demand, the triggering by mouse movement can be disabled by checking the box below.")
            }

            Item { width: 1; height: 30 }

            Rectangle { color: "#88ffffff"; width: tab_top.width; height: 1; }

            Item { width: 1; height: 20 }

            MouseTrigger { id: trigger }
            MetaData { id: metadata }
            FontSize { id: fontsize }
            Opacity { id: op }
            RotateFlip { id: rotateflip }
            OnlineMap { id: onlinemap }
            PeopleTags { id: peopletags }

        }

    }

    function setData() {
        verboseMessage("SettingsManager/TabMetadata", "setData()")
        trigger.setData()
        metadata.setData()
        fontsize.setData()
        op.setData()
        rotateflip.setData()
        onlinemap.setData()
        peopletags.setData()
    }

    function saveData() {
        verboseMessage("SettingsManager/TabMetadata", "saveData()")
        trigger.saveData()
        metadata.saveData()
        fontsize.saveData()
        op.saveData()
        rotateflip.saveData()
        onlinemap.saveData()
        peopletags.saveData()
    }

}
