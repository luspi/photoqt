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
#include <QMutex>
#include <QMap>
#include <QQmlEngine>

#include <pqc_notify.h>

/********************************************/
//
// This class is ONLY available from QML.
// It is used for two things:
//
//  1) QML elements talking to each other
//  2) signal from PQCNotify are picked up and emitted again from a pure QML context
//
// This approach allows for much better AOT compilation and much better performance
//
/********************************************/

class PQCNotifyQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCNotifyQML() {

        connect(&PQCNotify::get(), &PQCNotify::keyPress, this, &PQCNotifyQML::keyPress);
        connect(&PQCNotify::get(), &PQCNotify::keyRelease, this, &PQCNotifyQML::keyRelease);

        connect(&PQCNotify::get(), &PQCNotify::mouseWindowEnter, this, &PQCNotifyQML::mouseWindowEnter);
        connect(&PQCNotify::get(), &PQCNotify::mouseWindowExit, this, &PQCNotifyQML::mouseWindowExit);

        connect(&PQCNotify::get(), &PQCNotify::showNotificationMessage, this, &PQCNotifyQML::showNotificationMessage);

        connect(&PQCNotify::get(), &PQCNotify::cmdOpen, this, &PQCNotifyQML::cmdOpen);
        connect(&PQCNotify::get(), &PQCNotify::cmdShow, this, &PQCNotifyQML::cmdShow);
        connect(&PQCNotify::get(), &PQCNotify::cmdHide, this, &PQCNotifyQML::cmdHide);
        connect(&PQCNotify::get(), &PQCNotify::cmdQuit, this, &PQCNotifyQML::cmdQuit);
        connect(&PQCNotify::get(), &PQCNotify::cmdToggle, this, &PQCNotifyQML::cmdToggle);
        connect(&PQCNotify::get(), &PQCNotify::cmdShortcutSequence, this, &PQCNotifyQML::cmdShortcutSequence);
        connect(&PQCNotify::get(), &PQCNotify::cmdTray, this, &PQCNotifyQML::cmdTray);

        connect(this, &PQCNotifyQML::resetSessionData, &PQCNotify::get(), &PQCNotify::resetSessionData);

    }

    ~PQCNotifyQML() {}

Q_SIGNALS:

    // This signal is THE ONLY ONE that is passed from QML to C++
    // It is picked up in PQCNotify
    void resetSessionData();

    /**********************************************************/
    // These signals are received from C++ via PQCNotify
    // They are assumed to not to be called from QML.

    // key/shortcuts related
    void keyPress(int key, int modifiers);
    void keyRelease(int key, int modifiers);

    // enter/leave main window
    void mouseWindowExit();
    void mouseWindowEnter();

    // command line signals, received from C++ via PQCNotify
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdQuit();
    void cmdToggle();
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);

    // there are a few more indicated below that are picked up from PQCNotify
    // but that also are called from QML to QML

    /**********************************************************/

    // Q_PROPERTY SIGNALS
    void debugChanged();
    void debugLogMessagesChanged();
    void startInTrayChanged();
    void haveScreenshotsChanged();
    void haveSettingUpdateChanged();

    // some window states control from QML
    void setWindowState(int state);
    void windowRaiseAndFocus();
    void windowClose();
    void windowTitleOverride(QString title);
    void windowStartSystemMove();
    void windowStartSystemResize(int edge);
    void photoQtQuit();

    // some image signals
    void enterPhotoSphere();
    void exitPhotoSphere();
    void currentViewFlick(QString direction);
    void currentViewMove(QString direction);
    void currentImageDetectBarCodes();
    void currentArchiveCloseCombo();
    void currentVideoJump(int s);
    void currentAnimatedJump(int leftright);
    void currentDocumentJump(int leftright);
    void currentArchiveJump(int leftright);
    void currentImageReload();

    // context menu properties
    void closeAllContextMenus();

    // these are called by various qml elements to trigger mouse shortcuts
    void mouseWheel(QPointF pos, QPointF angleDelta, int modifiers);
    void mousePressed(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseReleased(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseMove(double x, double y);
    void mouseDoubleClicked(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);

    // other
    void showNotificationMessage(QString title, QString msg); // -> also picked up from PQCNotify
    void currentImageLoadedAndDisplayed(QString filename);
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
    void loaderRegisterOpen(QString ele);
    void loaderRegisterClose(QString ele);
    void loaderOverrideVisibleItem(QString ele);
    void loaderRestoreVisibleItem();

};
