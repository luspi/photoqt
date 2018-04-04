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
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4
import PContextMenu 1.0

import "../elements"

Item {

    id: top

    visible: (!variables.slideshowRunning && !settings.quickInfoHideX) || (variables.slideshowRunning && !settings.slideShowHideQuickInfo)

    // Position it
    anchors.right: parent.right
    anchors.top: parent.top

    // Width depends on type of 'x'
    width: 3*settingsQuickInfoCloseXSize
    height: 3*settingsQuickInfoCloseXSize

    // make sure settings values are valid
    property int settingsQuickInfoCloseXSize: Math.max(5, Math.min(25, settings.quickInfoCloseXSize))

    // Plain 'x'
    Image {
        visible: !settings.quickInfoFullX
        anchors.fill: parent
        source: "qrc:/img/closingxplain.png"
    }

    // Full 'x'
    Image {
        visible: settings.quickInfoFullX
        anchors.fill: parent
        source: "qrc:/img/closingx.png"
    }

    // Click on either one of them
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.RightButton)
                context.popup()
            else
                mainwindow.closePhotoQt()
        }
    }

    // The actual context menu
    PContextMenu {

        id: context

        Component.onCompleted: {

            //: The counter shows the position of the currently loaded image in the folder
            addItem(em.pty+qsTr("Show counter"))
            setCheckable(0, true)
            setChecked(0, !settings.quickInfoHideCounter)

            addItem(em.pty+qsTr("Show filepath"))
            setCheckable(1, true)
            setChecked(1, !settings.quickInfoHideFilepath)

            addItem(em.pty+qsTr("Show filename"))
            setCheckable(2, true)
            setChecked(2, !settings.quickInfoHideFilename)

            addItem(em.pty+qsTr("Show zoom level"))
            setCheckable(3, true)
            setChecked(3, !settings.quickInfoHideZoomLevel)

            //: The clsoing 'x' is the button in the top right corner of the screen for closing PhotoQt
            addItem(em.pty+qsTr("Show closing 'x'"))
            setCheckable(4, true)
            setChecked(4, !settings.quickInfoHideX)

        }

        onCheckedChanged: {
            if(index == 0)
                settings.quickInfoHideCounter = !checked
            else if(index == 1)
                settings.quickInfoHideFilepath = !checked
            else if(index == 2)
                settings.quickInfoHideFilename = !checked
            else if(index == 3)
                settings.quickInfoHideZoomLevel = !checked
            else if(index == 4)
                settings.quickInfoHideX = !checked
        }

    }

}
