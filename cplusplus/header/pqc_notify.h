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

#ifndef PQCNOTIFY_H
#define PQCNOTIFY_H

#include <QObject>
#include <QMutex>
#include <QMap>

class PQCNotify : public QObject {

    Q_OBJECT

public:
    static PQCNotify &get() {
        static PQCNotify instance;
        return instance;
    }

    PQCNotify(PQCNotify const&)     = delete;
    void operator=(PQCNotify const&) = delete;

    /******************************************************/

    // Some startup properties.
    // These might be set before PQCConstants is set up from QML.
    // Thus we cache them here so that we can initialize them properly
    // in its constructor.

    void setFilePath(QString val) { m_filepath = val; Q_EMIT filePathChanged(val); }
    void setDebug(bool val) { m_debug = val; Q_EMIT debugChanged(val); }
    void setStartInTray(bool val) { m_startInTray = val; Q_EMIT startInTrayChanged(val); }
    void setHaveScreenshots(bool val) { m_haveScreenshots = val; Q_EMIT haveScreenshotsChanged(val); }
    void setSettingUpdate(QStringList val) { m_settingUpdate = val; Q_EMIT settingUpdateChanged(val); }

    QString getFilePath() { return m_filepath; }
    bool getDebug() { return m_debug; }
    bool getStartInTray() { return m_startInTray; }
    bool getHaveScreenshots() { return m_haveScreenshots; }
    QStringList getSettingUpdate() { return m_settingUpdate; }

    /******************************************************/

private:
    PQCNotify(QObject *parent = 0) : QObject(parent) {
        m_filepath = "";
        m_debug = false;
        m_startInTray = false;
        m_haveScreenshots = false;
        m_settingUpdate.clear();
    }

    /******************************************************/

    // Some startup properties.
    // These might be set before PQCConstants is set up from QML.
    // Thus we cache them here so that we can initialize them properly
    // in its constructor.

    bool m_debug;
    QString m_filepath;
    bool m_startInTray;
    bool m_haveScreenshots;
    QStringList m_settingUpdate;

    /******************************************************/

Q_SIGNALS:

    // reset current session to free up as much memory as possible
    // NOTE: THIS ONE IS PASSED ON FROM PQCNotifyQML
    void resetSessionData();

    /*************************************************************/
    // these cached startup property signals are picked up in PQCConstants

    void filePathChanged(QString val);
    void debugChanged(bool val);
    void startInTrayChanged(bool val);
    void haveScreenshotsChanged(bool val);
    void settingUpdateChanged(QStringList val);
    void addDebugLogMessages(QString val);

    void setColorProfileFor(QString path, QString val);

    /*************************************************************/
    // these are signals from C++ to C++, no QML interaction

    void disableColorSpaceSupport();

    /*************************************************************/
    // this are picked up by PQCNotifyQML and passed on to QML

    // command line signals
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdQuit();
    void cmdToggle();
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);

    // key/shortcuts related
    void keyPress(int key, int modifiers);
    void keyRelease(int key, int modifiers);

    void mouseWindowExit();
    void mouseWindowEnter();

    void showNotificationMessage(QString title, QString msg);

};


#endif // PQCNotify_H
