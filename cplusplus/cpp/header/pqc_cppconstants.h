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
#pragma once

#include <QObject>

enum class CMDActions {
    File = Qt::UserRole+1,
    Open,
    Show,
    Hide,
    Quit,
    Toggle,
    StartInTray,
    Tray,
    NoTray,
    Shortcut,
    Debug,
    NoDebug,
    Setting
};

class PQCCPPConstants : public QObject {

    Q_OBJECT

public:
    static PQCCPPConstants& get() {
        static PQCCPPConstants instance;
        return instance;
    }

    PQCCPPConstants(PQCCPPConstants const&) = delete;
    void operator=(PQCCPPConstants const&) = delete;

    void setDebugMode(bool dbg) { m_debugMode = dbg; }
    bool getDebugMode() { return m_debugMode; }

    void setStartupMessage(QByteArray msg) { m_startupMessage = msg; }
    QByteArray getStartupMessage() { return m_startupMessage; }

private:
    PQCCPPConstants() {

        m_startupMessage = "";

        m_debugMode = false;
    }

    QByteArray m_startupMessage;

    bool m_debugMode;

};
