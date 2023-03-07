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

    x: 10
    Behavior on x { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    y: 10

    width: cont.width
    height: cont.height

    visible: (filefoldermodel.countMainView==0&&!filefoldermodel.filterCurrentlyActive) ||
             variables.faceTaggingActive

    Rectangle {

        id: cont
        width: childrenRect.width+20
        height: childrenRect.height+10

        clip: true

        Behavior on width { NumberAnimation { duration: 200 } }

        color: "#88000000"
        radius: 5

        PQText {
            id: thex
            x: 10
            y: 5
            text: "x"
            visible: variables.faceTaggingActive
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("facetagging", "Click to exit face tagging mode")
                onClicked:
                    loader.passOn("facetagger", "stop", undefined)
            }
        }

        PQText {

            x: variables.faceTaggingActive ? (thex.x+thex.width+5) : 10
            y: 5

            text: variables.faceTaggingActive ?
                      em.pty+qsTranslate("facetagging", "Click to tag faces, changes are saved automatically") :
                      em.pty+qsTranslate("other", "Open a file to start")

        }

    }

}
