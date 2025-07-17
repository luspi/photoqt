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

#include <pqc_notify.h>

PQCNotify &PQCNotify::get() {
    static PQCNotify instance;
    return instance;
}

void PQCNotify::setFilePath(QString val) {
    if(val != m_filepath) {
        m_filepath = val;
        Q_EMIT filePathChanged();
    }
}
QString PQCNotify::getFilePath() {
    return m_filepath;
}

void PQCNotify::setDebug(bool val) {
    if(val != m_debug) {
        m_debug = val;
        Q_EMIT debugChanged();
    }
}
bool PQCNotify::getDebug() {
    return m_debug;
}

void PQCNotify::setStartInTray(bool val) {
    if(val != m_startInTray) {
        m_startInTray = val;
        Q_EMIT startInTrayChanged();
    }
}
bool PQCNotify::getStartInTray() {
    return m_startInTray;
}

void PQCNotify::setDebugLogMessages(QString val) {
    if(val != m_debugLogMessages) {
        m_debugLogMessages = val;
        Q_EMIT debugLogMessagesChanged();
    }
}
QString PQCNotify::getDebugLogMessages() {
    return m_debugLogMessages;
}
void PQCNotify::addDebugLogMessages(QString val) {
    // without a mutex a crash can be encountered here when multiple threads write to this variable at the same time
    addDebugLogMessageMutex.lock();
    m_debugLogMessages.append(val);
    addDebugLogMessageMutex.unlock();
    Q_EMIT debugLogMessagesChanged();
}

void PQCNotify::setHaveScreenshots(bool val) {
    if(val != m_haveScreenshots) {
        m_haveScreenshots = val;
        Q_EMIT haveScreenshotsChanged();
    }
}
bool PQCNotify::getHaveScreenshots() {
    return m_haveScreenshots;
}

void PQCNotify::setSettingUpdate(QStringList val) {
    if(val != m_settingUpdate) {
        m_settingUpdate = val;
        Q_EMIT settingUpdateChanged();
    }
}
QStringList PQCNotify::getSettingUpdate() {
    return m_settingUpdate;
}

void PQCNotify::setColorProfileFor(QString path, QString val) {
    if(m_colorProfiles.value(path, "") != val) {
        m_colorProfiles[path] = val;
        Q_EMIT colorProfilesChanged();
    }
}
QString PQCNotify::getColorProfileFor(QString path) {
    return m_colorProfiles.value(path, "");
}
