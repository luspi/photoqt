/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls
import PhotoQt.Shared

MenuBar {

    Menu {

        id: menu_file

        title: qsTr("&File")

        Action {
            text: qsTr("&Open")
            onTriggered: {
                menu_file.close()
                PQCNotify.loaderShow("filedialog")
            }
        }

        Action {
            text: qsTr("&Rename")
        }

        Action {
            text: qsTr("&Delete")
        }

        MenuSeparator {}

        Action {
            text: qsTr("&Quit")
            onTriggered: {
                PQCNotify.photoQtQuit()
            }
        }

    }

    Menu {

        id: menu_about

        title: qsTr("&Help")

        Action {
            text: qsTr("&About")
            onTriggered: {
                PQCNotify.loaderShow("about")
                menu_about.close()
            }
        }

    }
}
