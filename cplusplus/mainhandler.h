#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QQuickView>
#include <QQmlApplicationEngine>
#include <QQmlProperty>
#include <iostream>

#include "variables.h"
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

#include "imageprovider/imageproviderempty.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageproviderhistogram.h"
#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumbnail.h"

#include "startup/exportimport.h"
#include "startup/fileformats.h"
#include "startup/localisation.h"
#include "startup/migration.h"
#include "startup/screenshots.h"
#include "startup/startintray.h"
#include "startup/thumbnails.h"
#include "startup/updatecheck.h"
#include "startup/shortcuts.h"
#include "startup/settings.h"

class MainHandler : public QQuickView {

    Q_OBJECT

public:

    MainHandler(bool verbose, QWindow *parent = 0);

    void setObjectAndConnect();
    int performSomeStartupChecks();
    void loadTranslation();
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

    Variables *variables;
    Settings *permanentSettings;

    bool overrideCursorSet;
    int update;

    void setupWindowProperties();

private slots:
    void handleTrayIcon(int val = -1);
    void qmlVerboseMessage(QString loc, QString msg);
    void trayAction(QSystemTrayIcon::ActivationReason reason);
    void toggleWindow();
    void forceWindowQuit();
    void aboutToQuit();
    void windowXYchanged(int);
    void handleWindowModeChanged(bool windowmode, bool windowdeco);

protected:
    bool event(QEvent *e);

};

#endif // MAINWINDOW_H
