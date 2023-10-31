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

#ifndef PQCNOTIFY_H
#define PQCNOTIFY_H

#include <QObject>

class PQCNotify : public QObject {

    Q_OBJECT

public:
    static PQCNotify& get();

    PQCNotify(PQCNotify const&)     = delete;
    void operator=(PQCNotify const&) = delete;

    /******************************************************/

    Q_PROPERTY(QString filePath READ getFilePath WRITE setFilePath NOTIFY filePathChanged)
    void setFilePath(QString val);
    Q_INVOKABLE QString getFilePath();

    /******************************************************/

    Q_PROPERTY(bool debug READ getDebug WRITE setDebug NOTIFY debugChanged)
    void setDebug(bool val);
    Q_INVOKABLE bool getDebug();

    /******************************************************/

    // used to show 'welcome' screen if this seems to be a new install
    Q_PROPERTY(bool freshInstall READ getFreshInstall WRITE setFreshInstall NOTIFY freshInstallChanged)
    void setFreshInstall(bool val);
    Q_INVOKABLE bool getFreshInstall();

    /******************************************************/

    Q_PROPERTY(int thumbs READ getThumbs WRITE setThumbs NOTIFY thumbsChanged)
    void setThumbs(int val);
    Q_INVOKABLE int getThumbs();

    /******************************************************/

    Q_PROPERTY(bool startInTray READ getStartInTray WRITE setStartInTray NOTIFY startInTrayChanged)
    void setStartInTray(bool val);
    Q_INVOKABLE bool getStartInTray();

    /******************************************************/

    Q_PROPERTY(bool modalFileDialogOpen READ getModalFileDialogOpen WRITE setModalFileDialogOpen NOTIFY modalFileDialogOpenChanged)
    void setModalFileDialogOpen(bool val);
    Q_INVOKABLE bool getModalFileDialogOpen();

    /******************************************************/

    Q_PROPERTY(bool spinBoxPassKeyEvents READ getSpinBoxPassKeyEvents WRITE setSpinBoxPassKeyEvents NOTIFY spinBoxPassKeyEventsChanged)
    void setSpinBoxPassKeyEvents(bool val);
    Q_INVOKABLE bool getSpinBoxPassKeyEvents();

    /******************************************************/

    Q_PROPERTY(bool ignoreKeysExceptEnterEsc READ getIgnoreKeysExceptEnterEsc WRITE setIgnoreKeysExceptEnterEsc NOTIFY ignoreKeysExceptEnterEscChanged)
    void setIgnoreKeysExceptEnterEsc(bool val);
    Q_INVOKABLE bool getIgnoreKeysExceptEnterEsc();

    /******************************************************/

    Q_PROPERTY(QString debugLogMessages READ getDebugLogMessages WRITE setDebugLogMessages NOTIFY debugLogMessagesChanged)
    void setDebugLogMessages(QString val);
    Q_INVOKABLE QString getDebugLogMessages();
    void addDebugLogMessages(QString val);

    /******************************************************/

    Q_PROPERTY(bool slideshowRunning READ getSlideshowRunning WRITE setSlideshowRunning NOTIFY slideshowRunningChanged)
    void setSlideshowRunning(bool val);
    Q_INVOKABLE bool getSlideshowRunning();

    /******************************************************/

    Q_PROPERTY(bool faceTagging READ getFaceTagging WRITE setFaceTagging NOTIFY faceTaggingChanged)
    void setFaceTagging(bool val);
    Q_INVOKABLE bool getFaceTagging();

    /******************************************************/

    Q_PROPERTY(bool haveScreenshots READ getHaveScreenshots WRITE setHaveScreenshots NOTIFY haveScreenshotsChanged)
    void setHaveScreenshots(bool val);
    Q_INVOKABLE bool getHaveScreenshots();

    /******************************************************/

private:
    PQCNotify(QObject *parent = 0) : QObject(parent) {
        m_filepath = "";
        m_debug = false;
        m_freshInstall = false;
        m_startInTray = false;
        m_thumbs = 2;
        m_modalFileDialogOpen = false;
        m_spinBoxPassKeyEvents = false;
        m_ignoreKeysExceptEnterEsc = false;
        m_debugLogMessages = "";
        m_slideshowRunning = false;
        m_faceTagging = false;
        m_haveScreenshots = false;
    }
    // these are used at startup
    // afterwards we only listen to the signals
    QString m_filepath;
    bool m_debug;
    bool m_freshInstall;
    int m_thumbs;
    bool m_startInTray;

    QString m_debugLogMessages;

    bool m_modalFileDialogOpen;
    bool m_spinBoxPassKeyEvents;
    bool m_ignoreKeysExceptEnterEsc;

    bool m_slideshowRunning;
    bool m_faceTagging;

    bool m_haveScreenshots;

Q_SIGNALS:
    void filePathChanged();
    void debugChanged();
    void freshInstallChanged();
    void thumbsChanged();
    void startInTrayChanged();

    void modalFileDialogOpenChanged();
    void spinBoxPassKeyEventsChanged();
    void ignoreKeysExceptEnterEscChanged();
    void haveScreenshotsChanged();

    void debugLogMessagesChanged();

    void slideshowRunningChanged();
    void faceTaggingChanged();

    // these are kept similar to the
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdToggle();
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);
    void resetSessionData();

    void keyPress(int key, int modifiers);
    void executeInternalCommand(QString cmd);

    // these are called by various qml elements to trigger mouse shortcuts
    void mouseWheel(QPointF angleDelta, int modifiers);
    void mousePressed(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseReleased(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseMove(double x, double y);
    void mouseDoubleClicked(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);

};


#endif // PQCNotify_H
