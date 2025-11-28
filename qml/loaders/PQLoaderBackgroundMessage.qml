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
import PhotoQt

Loader {

    width: PQCConstants.availableWidth
    height: PQCConstants.availableHeight
    asynchronous: (PQCConstants.startupFilePath!=="")

    sourceComponent: PQCSettings.generalInterfaceVariant==="modern" ? comp_modern : comp_integrated

    Component {
        id: comp_modern
        PQBackgroundMessageModern {
            width: PQCConstants.availableWidth
            height: PQCConstants.availableHeight
        }
    }

    Component {
        id: comp_integrated
        PQBackgroundMessageIntegrated {
            x: (PQCSettings.metadataSideBar&&PQCSettings.metadataSideBarLocation==="left" ? PQCSettings.metadataSideBarWidth : 0)
            width: PQCConstants.availableWidth-300
            height: PQCConstants.availableHeight
        }
    }

}
