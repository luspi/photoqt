/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QQuickView>
#include <QQmlApplicationEngine>
#include <QQmlProperty>
#include <iostream>

#include "hideclose.h"

#include "settings/colour.h"
#include "settings/fileformats.h"
#include "settings/settings.h"
#include "scripts/getanddostuff.h"
#include "scripts/getmetadata.h"
#include "scripts/shareonline/imgur.h"
#include "tooltip/tooltip.h"
#include "shortcuts/shortcutsnotifier.h"
#include "scripts/thumbnailsmanagement.h"
#include "shortcuts/shortcuts.h"
#include "scripts/filedialog.h"
#include "shortcuts/composestring.h"
#include "scripts/watcher.h"
#include "scripts/localisation.h"
#include "contextmenu/contextmenu.h"
#include "settings/imageformats.h"

#include "imageprovider/imageproviderempty.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageproviderhistogram.h"
#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumbnail.h"

#include "startup/exportimport.h"
#include "startup/migration.h"
#include "startup/screenshots.h"
#include "startup/thumbnails.h"
#include "startup/updatecheck.h"
#include "startup/shortcuts.h"
#include "startup/settings.h"

class MainHandler : public QQuickView {

    Q_OBJECT

public:

    MainHandler(QWindow *parent = 0);

    void setObjectAndConnect();
    int performSomeStartupChecks();
    void registerQmlTypes();
    void addImageProvider();
    void loadQML();
    void manageStartupFilename(bool startInTray, QString filename);

public slots:
    void remoteAction(QString cmd);
    void setOverrideCursor() { if(overrideCursorSet) return; qApp->setOverrideCursor(Qt::WaitCursor); overrideCursorSet = true; }
    void restoreOverrideCursor() { qApp->restoreOverrideCursor(); overrideCursorSet = false; }

private:

    QObject *object;

    QTranslator trans;
    QSystemTrayIcon *trayIcon;

    Settings *permanentSettings;

    bool overrideCursorSet;
    int update;

    void setupWindowProperties(bool dontCallShow = false);

private slots:
    void handleTrayIcon(int val = -1);
    void qmlVerboseMessage(QString loc, QString msg);
    void trayAction(QSystemTrayIcon::ActivationReason reason);
    void toggleWindow();
    void forceWindowQuit();
    void aboutToQuit();
    void windowXYchanged(int);
    void handleWindowModeChanged(bool windowmode, bool windowdeco, bool keepontop);

protected:
    bool event(QEvent *e);

};

#endif // MAINWINDOW_H
