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
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import PQStartup 1.0

Window {

    id: top_first

    //: Window title
    title: "PhotoQt updated"

    minimumWidth: 600
    minimumHeight: 300

    color: "#ffffff"

    x: (Screen.width - width)/2
    y: (Screen.height - height)/2

    PQStartup {
        id: startup
    }

    Item {

        anchors.fill: parent

        Column {

            spacing: 10
            x: 5
            width: top_first.width-10

            Item {
                width: 1
                height: 1
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "PhotoQt updated"
                font.pointSize: 25
                font.bold: true
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "PhotoQt is an image viewer that aims to be very flexible in order to adapt to your needs and workflow instead of the other way around. Thus, most things and behaviours can be adjusted in the settings manager."
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                text: "<b>In order to complete the update, some things need to be updated/migrated (done automatically).</b> Simply close this window to continue."
            }

            Item {
                width: 1
                height: 10
            }

            Button {
                x: (parent.width-width)/2
                //: written on a clickable button
                text: "Continue"
                focus: true
                onClicked:
                    top_first.close()
            }

        }

    }

    Component.onCompleted: {
        top_first.showNormal()
    }

    onClosing: {
        startup.performChecksAndMigrations()
    }

    Shortcut {
        sequences: ["Escape", "Enter", "Return"]
        onActivated:
            top_first.close()
    }

}
