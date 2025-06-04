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
#include <QQmlEngine>

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

    Q_PROPERTY(bool ignoreAllKeys READ getIgnoreAllKeys WRITE setIgnoreAllKeys NOTIFY ignoreAllKeysChanged)
    void setIgnoreAllKeys(bool val);
    Q_INVOKABLE bool getIgnoreAllKeys();

    /******************************************************/

    Q_PROPERTY(QString debugLogMessages READ getDebugLogMessages WRITE setDebugLogMessages NOTIFY debugLogMessagesChanged)
    void setDebugLogMessages(QString val);
    Q_INVOKABLE QString getDebugLogMessages();
    void addDebugLogMessages(QString val);

    /******************************************************/

    Q_PROPERTY(bool faceTagging READ getFaceTagging WRITE setFaceTagging NOTIFY faceTaggingChanged)
    void setFaceTagging(bool val);
    Q_INVOKABLE bool getFaceTagging();

    /******************************************************/

    Q_PROPERTY(bool haveScreenshots READ getHaveScreenshots WRITE setHaveScreenshots NOTIFY haveScreenshotsChanged)
    void setHaveScreenshots(bool val);
    Q_INVOKABLE bool getHaveScreenshots();

    /******************************************************/

    Q_PROPERTY(QStringList settingUpdate READ getSettingUpdate WRITE setSettingUpdate NOTIFY settingUpdateChanged)
    void setSettingUpdate(QStringList val);
    Q_INVOKABLE QStringList getSettingUpdate();

    /******************************************************/

    Q_PROPERTY(int startupCheck READ getStartupCheck WRITE setStartupCheck NOTIFY startupCheckChanged)
    void setStartupCheck(int val);
    Q_INVOKABLE int getStartupCheck();

    /******************************************************/

    Q_PROPERTY(bool showingPhotoSphere READ getShowingPhotoSphere WRITE setShowingPhotoSphere NOTIFY showingPhotoSphereChanged)
    void setShowingPhotoSphere(bool val);
    Q_INVOKABLE bool getShowingPhotoSphere ();

    /******************************************************/

    Q_PROPERTY(bool isMotionPhoto READ getIsMotionPhoto WRITE setIsMotionPhoto NOTIFY isMotionPhotoChanged)
    void setIsMotionPhoto(bool val);
    Q_INVOKABLE bool getIsMotionPhoto();

    /******************************************************/

    Q_PROPERTY(bool barcodeDisplayed READ getBarcodeDisplayed WRITE setBarcodeDisplayed NOTIFY barcodeDisplayedChanged)
    void setBarcodeDisplayed(bool val);
    Q_INVOKABLE bool getBarcodeDisplayed();

    /******************************************************/

    void setColorProfileFor(QString path, QString val);
    Q_INVOKABLE QString getColorProfileFor(QString path);

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
        m_ignoreAllKeys = false;
        m_debugLogMessages = "";
        m_faceTagging = false;
        m_haveScreenshots = false;
        m_settingUpdate.clear();
        m_startupCheck = 0;
        m_isMotionPhoto = false;
        m_showingPhotoSphere = false;
        m_barcodeDisplayed = false;
        m_colorProfiles.clear();
    }
    // these are used at startup
    // afterwards we only listen to the signals
    QString m_filepath;
    bool m_debug;
    bool m_freshInstall;
    int m_thumbs;
    bool m_startInTray;

    QString m_debugLogMessages;
    QMutex addDebugLogMessageMutex;

    bool m_modalFileDialogOpen;
    bool m_spinBoxPassKeyEvents;
    bool m_ignoreAllKeys;

    bool m_faceTagging;

    bool m_haveScreenshots;
    QStringList m_settingUpdate;

    int m_startupCheck;

    bool m_showingPhotoSphere;
    bool m_isMotionPhoto;

    bool m_barcodeDisplayed;

    QMap<QString, QString> m_colorProfiles;

Q_SIGNALS:

    // startup properties changes
    void filePathChanged();
    void debugChanged();
    void freshInstallChanged();
    void thumbsChanged();
    void startInTrayChanged();
    void settingUpdateChanged();
    void startupCheckChanged();

    // some window states control from QML
    void modalFileDialogOpenChanged();
    void spinBoxPassKeyEventsChanged();
    void ignoreAllKeysChanged();
    void setWindowState(int state);
    void windowRaiseAndFocus();
    void windowClose();
    void windowTitleOverride(QString title);
    void windowStartSystemMove();
    void windowStartSystemResize(int edge);
    void photoQtQuit();

    // actions happening that block the interface in some way
    void faceTaggingChanged();
    void showingPhotoSphereChanged();
    void isMotionPhotoChanged();
    void barcodeDisplayedChanged();

    // context menu properties
    void closeAllContextMenus();

    // command line signals
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdQuit();
    void cmdToggle();
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);

    // reset methods
    void resetSettingsToDefault();
    void resetShortcutsToDefault();
    void resetFormatsToDefault();
    void resetSessionData();

    // key/shortcuts related
    void keyPress(int key, int modifiers);
    void keyRelease(int key, int modifiers);
    void executeInternalCommand(QString cmd);

    // these are called by various qml elements to trigger mouse shortcuts
    void mouseWheel(QPointF pos, QPointF angleDelta, int modifiers);
    void mousePressed(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseReleased(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseMove(double x, double y);
    void mouseDoubleClicked(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseWindowExit();
    void mouseWindowEnter();

    // other
    void showNotificationMessage(QString title, QString msg);
    void haveScreenshotsChanged();
    void debugLogMessagesChanged();
    void colorProfilesChanged();
    void openSettingsManagerAt(QString category, QString subcategory);
    void playPauseAnimationVideo();

    // slideshow
    void slideshowHideHandler();
    void slideshowToggle();
    void slideshowNextImage(bool switchedManually = false);
    void slideshowPrevImage(bool switchedManually = false);

    // loader methods
    void loaderShow(QString ele);
    void loaderShowExtension(QString ele);
    void loaderSetup(QString ele);
    void loaderSetupExtension(QString ele);
    void loaderPassOn(QString what, QVariantList args);
    void loaderRegisterClose(QString ele);
    void loaderOverrideVisibleItem(QString ele);
    void loaderRestoreVisibleItem();

};


#endif // PQCNotify_H
