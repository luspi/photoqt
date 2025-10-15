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
import PhotoQt.CPlusPlus

Item {

    Connections {

        target: PQCReceiveMessages

        function onCmdSetDebugMode(dbg : bool) {
            PQCConstants.debugMode = dbg
        }

        function onCmdSettingUpdate(val : list<string>) {
            PQCSettings.updateFromCommandLine(val)
        }

        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::debugChanged, this, [=](bool val) { m_debugMode = val; Q_EMIT debugModeChanged(); });
        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::addDebugLogMessages, this, &PQCConstants::addDebugLogMessages);
        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::startInTrayChanged, this, [=](bool val) { m_startupStartInTray = val; Q_EMIT startupStartInTrayChanged(); });
        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::settingUpdateChanged, this, [=](QStringList val) { m_startupHaveSettingUpdate = (val.length()>0); Q_EMIT startupHaveSettingUpdateChanged(); });
    }

    Connections {
        target: PQCNotify

        function onStoreLocationToDatabase(path : string, location : point) {
            PQCLocation.storeLocation(path, location)
        }

    }

}
