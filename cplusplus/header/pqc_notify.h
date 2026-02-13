/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_notify_cpp.h>

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

class PQCNotify : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCNotify() {

        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, &PQCNotify::keyPress);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyRelease, this, &PQCNotify::keyRelease);

        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::mouseWindowEnter, this, &PQCNotify::mouseWindowEnter);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::mouseWindowExit, this, &PQCNotify::mouseWindowExit);

        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::showNotificationMessage, this, &PQCNotify::showNotificationMessage);

        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdOpen, this, &PQCNotify::cmdOpen);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdShow, this, &PQCNotify::cmdShow);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdHide, this, &PQCNotify::cmdHide);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdQuit, this, &PQCNotify::cmdQuit);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdToggle, this, &PQCNotify::cmdToggle);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdShortcutSequence, this, &PQCNotify::cmdShortcutSequence);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::cmdTray, this, &PQCNotify::cmdTray);

        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::storeLocationToDatabase, this, &PQCNotify::storeLocationToDatabase);

        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::showExtension, this, &PQCNotify::loaderShowExtension);
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::showSettingsForExtension, this, &PQCNotify::showSettingsForExtension);

        connect(this, &PQCNotify::resetSessionData, &PQCNotifyCPP::get(), &PQCNotifyCPP::resetSessionData);
        connect(this, &PQCNotify::reprocessStartupMessage, &PQCNotifyCPP::get(), &PQCNotifyCPP::reprocessStartupMessage);

    }

    ~PQCNotify() {}

Q_SIGNALS:

    // These signals are THE ONLY ONES that are passed from QML to C++
    // Calling these triggers the respective call in PQCNotifyCPP.
    void resetSessionData();
    void reprocessStartupMessage();

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
    void currentFlickableSetContentX(int x);
    void currentFlickableSetContentY(int y);
    void currentFlickableReturnToBounds();
    void currentFlickableAnimateContentPosChange(double propX, double propY);
    void currentImageDetectBarCodes();
    void currentArchiveCloseCombo();
    void currentVideoJump(int s);
    void currentVideoToPos(int pos);
    void currentVideoMuteUnmute();
    void currentVideoControlsResetPosition();
    void currentAnimatedJump(int leftright);
    void currentDocumentJump(int leftright);
    void currentDocumentControlsResetPosition();
    void currentArchiveJump(int leftright);
    void currentArchiveJumpTo(int index);
    void currentImageReload();
    void currentAnimatedSaveFrame();
    void currentFaceTagsReload();
    void stopFaceTagging();
    void newImageHasBeenDisplayed();

    // context menu properties
    void closeAllContextMenus();
    void showMinimapContextMenu(bool vis);
    void showVideoControlsContextMenu(bool vis);

    // these are called by various qml elements to trigger mouse shortcuts
    void mouseWheel(QPointF pos, QPointF angleDelta, int modifiers);
    void mousePressed(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseReleased(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);
    void mouseMove(double x, double y);
    void mouseDoubleClicked(Qt::KeyboardModifiers modifiers, Qt::MouseButton button, QPointF pos);

    // file dialog methods
    void filedialogReloadCurrentThumbnail();
    void filedialogLoadNewPath(QString path);
    void filedialogReloadPlaces();
    void filedialogClose();
    void filedialogSelectAll(bool sel);
    void filedialogDeleteFiles();
    void filedialogCutFiles(bool forceSelection);
    void filedialogCopyFiles(bool forceSelection);
    void filedialogPasteFiles();
    void filedialogTweaksSetFiletypesButtonText(QString txt);
    void filedialogGoBackInHistory();
    void filedialogGoForwardsInHistory();
    void filedialogShowAddressEdit(bool edit);

    // other
    void showNotificationMessage(QString title, QString msg); // -> also picked up from PQCNotify
    void currentImageLoadedAndDisplayed(QString filename);
    void openSettingsManagerAt(int categoryIndex, QString subcategory);
    void playPauseAnimationVideo();
    void showToolTip(QString txt, QPoint mouseXY);
    void hideToolTip(QString txt);
    void thumbnailReloadImage(int index);
    void elementSignal(QString elementId, QString what);
    void resetActiveFocus();
    void settingsmanagerSendCommand(QString what, QVariantList args);
    void storeLocationToDatabase(QString path, QPointF location);
    void showSettingsForExtension(QString id);
    void showBusyIndicatorWhileImageIsLoading();

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
