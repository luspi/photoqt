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
import "../elements"

Item {
    id: highlightedges

    width: parent.width
    height: parent.height

    opacity: (PQSettings.interfaceHighlightEdges&&filefoldermodel.countMainView==0) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    Rectangle {
        id: leftedge

        visible: !PQSettings.interfacePopoutMetadata && PQSettings.metadataElementBehindLeftEdge

        x: 40
        y: (parent.height-height)/2
        width: 40
        height: (parent.height*0.8)
        radius: 10

        opacity: (variables.metadataVisible ? 0 : 1)
        Behavior on opacity { NumberAnimation { duration: 200 } }

        color: "#66ffffff"

        PQTextL {
            anchors.centerIn: parent
            rotation: -90
            color: "black"
            font.weight: baselook.boldweight
            text: em.pty+qsTranslate("metadata", "Metadata")
        }

    }

    Rectangle {
        id: rightedge

        visible: !PQSettings.interfacePopoutMainMenu

        x: parent.width-width-40
        y: (parent.height-height)/2
        width: 40
        height: (parent.height*0.8)
        radius: 10

        opacity: (variables.mainMenuVisible ? 0 : 1)
        Behavior on opacity { NumberAnimation { duration: 200 } }

        color: "#66ffffff"

        PQTextL {
            anchors.centerIn: parent
            rotation: 90
            color: "black"
            font.weight: baselook.boldweight
            text: em.pty+qsTranslate("MainMenu", "Main menu")
        }

    }

    Rectangle {
        id: bottomedge

        x: (parent.width-width)/2
        y: parent.height-height-40
        width: parent.width*0.8
        height: 40
        radius: 10

        opacity: (variables.thumbnailbarVisible ? 0 : 1)
        Behavior on opacity { NumberAnimation { duration: 200 } }

        color: "#66ffffff"

        PQTextL {
            anchors.centerIn: parent
            color: "black"
            font.weight: baselook.boldweight
            text: em.pty+qsTranslate("thumbnailbar", "Thumbnails (once a folder is loaded)")
        }

    }

}
