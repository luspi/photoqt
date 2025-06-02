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

void PQCNotify::setFreshInstall(bool val) {
    if(val != m_freshInstall) {
        m_freshInstall = val;
        Q_EMIT freshInstallChanged();
    }
}
bool PQCNotify::getFreshInstall() {
    return m_freshInstall;
}

void PQCNotify::setThumbs(int val) {
    if(val != m_thumbs) {
        m_thumbs = val;
        Q_EMIT thumbsChanged();
    }
}
int PQCNotify::getThumbs() {
    return m_thumbs;
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

void PQCNotify::setModalFileDialogOpen(bool val) {
    if(val != m_modalFileDialogOpen) {
        m_modalFileDialogOpen = val;
        Q_EMIT modalFileDialogOpenChanged();
    }
}
bool PQCNotify::getModalFileDialogOpen() {
    return m_modalFileDialogOpen;
}

void PQCNotify::setSpinBoxPassKeyEvents(bool val) {
    if(val != m_spinBoxPassKeyEvents) {
        m_spinBoxPassKeyEvents = val;
        Q_EMIT spinBoxPassKeyEventsChanged();
    }
}
bool PQCNotify::getSpinBoxPassKeyEvents() {
    return m_spinBoxPassKeyEvents;
}

void PQCNotify::setIgnoreKeysExceptEnterEsc(bool val) {
    if(val != m_ignoreKeysExceptEnterEsc) {
        m_ignoreKeysExceptEnterEsc = val;
        Q_EMIT ignoreKeysExceptEnterEscChanged();
    }
}
bool PQCNotify::getIgnoreKeysExceptEnterEsc() {
    return m_ignoreKeysExceptEnterEsc;
}

void PQCNotify::setIgnoreKeysExceptEsc(bool val) {
    if(val != m_ignoreKeysExceptEsc) {
        m_ignoreKeysExceptEsc = val;
        Q_EMIT ignoreKeysExceptEscChanged();
    }
}
bool PQCNotify::getIgnoreKeysExceptEsc() {
    return m_ignoreKeysExceptEsc;
}

void PQCNotify::setIgnoreAllKeys(bool val) {
    if(val != m_ignoreAllKeys) {
        m_ignoreAllKeys = val;
        Q_EMIT ignoreAllKeysChanged();
    }
}
bool PQCNotify::getIgnoreAllKeys() {
    return m_ignoreAllKeys;
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

void PQCNotify::setSlideshowRunning(bool val) {
    if(val != m_slideshowRunning) {
        m_slideshowRunning = val;
        Q_EMIT slideshowRunningChanged();
    }
}
bool PQCNotify::getSlideshowRunning() {
    return m_slideshowRunning;
}

void PQCNotify::setFaceTagging(bool val) {
    if(val != m_faceTagging) {
        m_faceTagging = val;
        Q_EMIT faceTaggingChanged();
    }
}
bool PQCNotify::getFaceTagging() {
    return m_faceTagging;
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

void PQCNotify::setStartupCheck(int val) {
    if(val != m_startupCheck) {
        m_startupCheck = val;
        Q_EMIT startupCheckChanged();
    }
}
int PQCNotify::getStartupCheck() {
    return m_startupCheck;
}

void PQCNotify::setShowingPhotoSphere(bool val) {
    if(val != m_showingPhotoSphere) {
        m_showingPhotoSphere = val;
        Q_EMIT showingPhotoSphereChanged();
    }
}
bool PQCNotify::getShowingPhotoSphere() {
    return m_showingPhotoSphere;
}

void PQCNotify::setIsMotionPhoto(bool val) {
    if(val != m_isMotionPhoto) {
        m_isMotionPhoto = val;
        Q_EMIT isMotionPhotoChanged();
    }
}
bool PQCNotify::getIsMotionPhoto() {
    return m_isMotionPhoto;
}

void PQCNotify::setBarcodeDisplayed(bool val) {
    if(val != m_barcodeDisplayed) {
        m_barcodeDisplayed = val;
        Q_EMIT barcodeDisplayedChanged();
    }
}
bool PQCNotify::getBarcodeDisplayed() {
    return m_barcodeDisplayed;
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
