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
