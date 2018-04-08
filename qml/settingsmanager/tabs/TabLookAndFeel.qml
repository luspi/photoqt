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

import "./lookandfeel"
import "../../elements"


Item {

    id: tab_top

    anchors {
        fill: parent
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: maincol.height+50
        contentWidth: maincol.width

        Column {

            id: maincol

            Item { width: 1; height: 10; }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 20
                font.bold: true
                //: The look of PhotoQt and how it feels and behaves
                text: em.pty+qsTr("Look and Feel")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20; }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 9
                wrapMode: Text.WordWrap
                text: qsTranslate("SettingsManager", "Move your mouse cursor over (or click on) the different settings titles to see more information.")
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 20; }

            Rectangle { color: "#88ffffff"; width: tab_top.width; height: 1; }

            Item { width: 1; height: 20; }

            SortBy { id: sortby; }
            WindowMode { id: windowmode }
            TrayIcon { id: trayicon }
            ClosingX { id: closingx }
            FitInWindow { id: fitin }
            Quickinfo { id: quickinfo }
            Background { id: background }
            OverlayColor { id: overlay }
            BorderAroundImage { id: border }
            CloseOnClick { id: closeonclick }
            Loop { id: loop }
            Transition { id: transition }
            TransparencyMarker { id: transparency }
            HotEdge { id: hotedge }
            MouseWheelSensitivity { id: mousewheel }
            Interpolation { id: interpolation }
            PixmapCache { id: pixmapcache }
            ReOpenFile { id: reopenfile }
            Keep { id: remember }
            Animation { id: animation }
        }

    }

    function setData() {

        verboseMessage("SettingsManager/TabMetadata", "setData()")

        sortby.setData()
        windowmode.setData()
        trayicon.setData()
        closingx.setData()
        fitin.setData()
        quickinfo.setData()
        background.setData()
        overlay.setData()
        border.setData()
        closeonclick.setData()
        loop.setData()
        transition.setData()
        transparency.setData()
        hotedge.setData()
        mousewheel.setData()
        interpolation.setData()
        pixmapcache.setData()
        reopenfile.setData()
        remember.setData()
        animation.setData()

    }

    function saveData() {

        verboseMessage("SettingsManager/TabMetadata", "saveData()")

        sortby.saveData()
        windowmode.saveData()
        trayicon.saveData()
        closingx.saveData()
        fitin.saveData()
        quickinfo.saveData()
        background.saveData()
        overlay.saveData()
        border.saveData()
        closeonclick.saveData()
        loop.saveData()
        transition.saveData()
        transparency.saveData()
        hotedge.saveData()
        mousewheel.saveData()
        interpolation.saveData()
        pixmapcache.saveData()
        reopenfile.saveData()
        remember.saveData()
        animation.saveData()

    }

}
