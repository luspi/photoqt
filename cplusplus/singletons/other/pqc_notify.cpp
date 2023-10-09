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
    m_debugLogMessages += val;
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