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

#include "mainhandler.h"

MainHandler::MainHandler(QWindow *parent) : QQuickView(parent) {

    // holding some variables of the current session
    permanentSettings = new Settings;

    trayIcon = nullptr;

    // Ensures we only once call setOverrideCursor in order to be able to properly restore it
    overrideCursorSet = false;

    // Perform some startup checks/tasks
    update = performSomeStartupChecks();

    // Register the qml types. This need to happen BEFORE loading the QML file
    registerQmlTypes();

    // Show tray icon (if enabled, checked by function)
    handleTrayIcon();

    addImageProvider();

    loadQML();

    setObjectAndConnect();

    connect(qApp, &QCoreApplication::aboutToQuit, this, &MainHandler::aboutToQuit);

    setupWindowProperties();

    connect(this, &MainHandler::xChanged, this, &MainHandler::windowXYchanged);
    connect(this, &MainHandler::yChanged, this, &MainHandler::windowXYchanged);

}

void MainHandler::windowXYchanged(int) {

    QMetaObject::invokeMethod(object, "windowXYchanged", Q_ARG(QVariant, this->x()), Q_ARG(QVariant, this->y()));

}

// Performs some initial startup checks to make sure everything is in order
int MainHandler::performSomeStartupChecks() {

    // Since version 1.4, PhotoQt uses proper standard folders for storing its config files. The configuration of older versions needs to be migrated.
    StartupCheck::Migration::migrateIfNecessary();

    // Using the settings file (and the stored version therein) check if PhotoQt was updated or installed (if settings file not present)
    int update = StartupCheck::UpdateCheck::checkForUpdateInstall(permanentSettings);

    if(update > 0) StartupCheck::Settings::moveToNewKeyNames();

    // Before the window is shown we create screenshots and store them in the temporary folder
    StartupCheck::Screenshots::getAndStore();

    // Check whether everything is alright with the thumbnails database
    StartupCheck::Thumbnails::checkThumbnailsDatabase(update, permanentSettings);

    if(update > 0) StartupCheck::Shortcuts::renameShortcutsFunctions();

    // Make sure default shortcuts are set on first start
    if(update > 0) StartupCheck::Shortcuts::setDefaultShortcutsIfShortcutFileDoesntExist();

    // Only on update do we need to (potentially) combine mouse and key shortcuts in single file
    if(update == 1) StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile();

    // Return the code whether PhotoQt was updated (1), installed (2), or none of the above (0)
    return update;

}

// Create a handler to the engine's object and connect to its signals
void MainHandler::setObjectAndConnect() {

    this->object = this->rootObject();

    // Connect to some signals of the qml code that require handling by c++ code
    connect(object, SIGNAL(verboseMessage(QString,QString)), this, SLOT(qmlVerboseMessage(QString,QString)));
    connect(object, SIGNAL(setOverrideCursor()), this, SLOT(setOverrideCursor()));
    connect(object, SIGNAL(restoreOverrideCursor()), this, SLOT(restoreOverrideCursor()));
    connect(object, SIGNAL(closePhotoQt()), this, SLOT(close()));
    connect(object, SIGNAL(quitPhotoQt()), this, SLOT(forceWindowQuit()));
    connect(object, SIGNAL(trayIconValueChanged(int)), this, SLOT(handleTrayIcon(int)));
    connect(object, SIGNAL(windowModeChanged(bool, bool, bool)), this, SLOT(handleWindowModeChanged(bool, bool, bool)));

}

// Add settings/scripts/... access to QML
void MainHandler::registerQmlTypes() {
    qmlRegisterType<Settings>("PSettings", 1, 0, "PSettings");
    qmlRegisterType<FileFormats>("PFileFormats", 1, 0, "PFileFormats");
    qmlRegisterType<GetMetaData>("PGetMetaData", 1, 0, "PGetMetaData");
    qmlRegisterType<GetAndDoStuff>("PGetAndDoStuff", 1, 0, "PGetAndDoStuff");
    qmlRegisterType<ToolTip>("PToolTip", 1, 0, "PToolTip");
    qmlRegisterType<Colour>("PColour", 1, 0, "PColour");
    qmlRegisterType<ShareOnline::Imgur>("PImgur", 1, 0, "PImgur");
    qmlRegisterType<ShortcutsNotifier>("PShortcutsNotifier", 1, 0, "PShortcutsNotifier");
    qmlRegisterType<ThumbnailManagement>("PThumbnailManagement", 1, 0, "PThumbnailManagement");
    qmlRegisterType<Shortcuts>("PShortcutsHandler", 1, 0, "PShortcutsHandler");
    qmlRegisterType<FileDialog>("PFileDialog", 1, 0, "PFileDialog");
    qmlRegisterType<Watcher>("PWatcher", 1, 0, "PWatcher");
    qmlRegisterType<Localisation>("PLocalisation", 1, 0, "PLocalisation");
    qmlRegisterType<ContextMenu>("PContextMenu", 1, 0, "PContextMenu");
}

// Add image providers to QML
void MainHandler::addImageProvider() {
    this->engine()->addImageProvider("thumb",new ImageProviderThumbnail);
    this->engine()->addImageProvider("full",new ImageProviderFull);
    this->engine()->addImageProvider("icon",new ImageProviderIcon);
    this->engine()->addImageProvider("empty", new ImageProviderEmpty);
    this->engine()->addImageProvider("hist", new ImageProviderHistogram);
}

// Load QML file and set transparent background
void MainHandler::loadQML() {

    this->setSource(QUrl("qrc:/qml/mainwindow.qml"));
    this->setColor(QColor(Qt::transparent));

}

// Output any QML debug messages if verbose mode is enabled
void MainHandler::qmlVerboseMessage(QString loc, QString msg) {
    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "[QML] " << loc.toStdString() << ": " << msg.toStdString() << NL;
}

void MainHandler::setupWindowProperties(bool dontCallShow) {

    this->setMinimumSize(QSize(640,480));
    this->setTitle("PhotoQt " + tr("Image Viewer"));

    bool debug = (qgetenv("PHOTOQT_DEBUG") == "yes");

    if(debug) LOG << CURDATE << "setupWindowProperties(): started processing" << std::endl;

    GetAndDoStuff gads;

    bool windowMaximised = true;
    if(!dontCallShow && this->isVisible()) {
        if(!(this->windowState() & Qt::WindowFullScreen))
            windowMaximised = false;
    }

    if(debug) LOG << CURDATE << "setupWindowProperties(): window maximised: " << windowMaximised << std::endl;

    if(debug) LOG << CURDATE << "setupWindowProperties(): settings values: "
                  << permanentSettings->getWindowMode() << " / "
                  << permanentSettings->getKeepOnTop()  << " / "
                  << permanentSettings->getWindowDecoration()  << " / "
                  << permanentSettings->getSaveWindowGeometry()  << " / "
                  << std::endl;

    // window mode
    if(permanentSettings->getWindowMode()) {

        // always keep window on top
        if(permanentSettings->getKeepOnTop()) {

            if(permanentSettings->getWindowDecoration())
                this->setFlags(Qt::Window|Qt::WindowStaysOnTopHint);
            else
                this->setFlags(Qt::Window|Qt::FramelessWindowHint|Qt::WindowStaysOnTopHint);

        // treat as normal window
        } else {

            if(permanentSettings->getWindowDecoration())
                this->setFlags(Qt::Window);
            else
                this->setFlags(Qt::Window|Qt::FramelessWindowHint);

        }

        // Restore the stored window geometry
        if(permanentSettings->getSaveWindowGeometry() && !dontCallShow) {

            QRect rect = gads.getStoredGeometry();

            // Check whether stored information is actually valid
            if(rect.width() < 100 || rect.height() < 100) {
                this->showNormal();
                if(windowMaximised)
                    this->showMaximized();
            } else {
                this->show();
                this->setGeometry(rect);
            }
        // If not stored, we display the image always maximised
        } else if(!dontCallShow) {
            this->showNormal();
            if(windowMaximised)
                this->showMaximized();
        }

    // fullscreen mode
    } else {

        // Always keep window on top...
        if(permanentSettings->getKeepOnTop())
            this->setFlags(Qt::WindowStaysOnTopHint|Qt::FramelessWindowHint);
        // ... or not
        else
            this->setFlags(Qt::FramelessWindowHint);

        // In Enlightenment, showing PhotoQt as fullscreen causes some problems, revert to showing it as maximised there by default
        if(gads.detectWindowManager() == "enlightenment") {
            if(!dontCallShow) {
                this->showNormal();
                if(windowMaximised)
                    this->showMaximized();
            }
        } else if(!dontCallShow)
            this->showFullScreen();

    }

}

// Handle events (both key and close)
bool MainHandler::event(QEvent *e) {

    if(e->type() == QEvent::KeyPress)
        QMetaObject::invokeMethod(object, "processShortcut", Q_ARG(QVariant, ComposeString::compose((QKeyEvent*)e)));
    else if(e->type() == QEvent::KeyRelease)
        QMetaObject::invokeMethod(object, "keysRelease");
    else if(e->type() == QEvent::Close) {
        HideClose::handleCloseEvent(e, permanentSettings, this);
        return true;
    } else if(e->type() == QEvent::MouseMove) {
        QMouseEvent *event = (QMouseEvent*)e;
        if(!(this->windowState() & Qt::WindowMaximized))
            QMetaObject::invokeMethod(object, "handleMouseExit", Q_ARG(QVariant, event->pos()));
    }

    return QQuickView::event(e);

}

// Called to force app to quit, bypassing QCloseEvent
void MainHandler::forceWindowQuit() {
    qApp->quit();
}

// Remote controlling
void MainHandler::remoteAction(QString cmd) {

    bool debug = (qgetenv("PHOTOQT_DEBUG") == "yes");

    if(debug) LOG << CURDATE << "remoteAction(): " << cmd.toStdString() << NL;

    // Open a new file (and show PhotoQt if necessary)
    if(cmd == "open") {

        if(debug) LOG << CURDATE << "remoteAction(): Open file" << NL;

        if(!this->isVisible()) {
            StartupCheck::Screenshots::getAndStore();
            setupWindowProperties();
        }

        QMetaObject::invokeMethod(object, "closeAnyElement");
        QMetaObject::invokeMethod(object, "openfileShow");
        this->requestActivate();

    // Disable thumbnails
    } else if(cmd == "nothumbs") {

        if(debug) LOG << CURDATE << "remoteAction(): Disable thumbnails" << NL;

        permanentSettings->setThumbnailDisable(true);

    // (Re-)enable thumbnails
    } else if(cmd == "thumbs") {

        if(debug) LOG << CURDATE << "remoteAction(): Enable thumbnails" << NL;

        permanentSettings->setThumbnailDisable(false);

    // Hide the window to system tray
    } else if(cmd == "hide" || (cmd == "toggle" && this->isVisible())) {

        if(debug) LOG << CURDATE << "remoteAction(): Hiding" << NL;

        permanentSettings->setTrayIcon(1);
        QMetaObject::invokeMethod(object, "closeAnyElement");
        this->hide();

    // Show the window again (after being hidden to system tray)
    } else if(cmd.startsWith("show") || (cmd == "toggle" && !this->isVisible())) {

        if(debug) LOG << CURDATE << "remoteAction(): Showing (" << cmd.toStdString() << ")" << NL;

        if(!this->isVisible()) {
            StartupCheck::Screenshots::getAndStore();
            setupWindowProperties();
        }

        this->requestActivate();

        QVariant curfile;
        QMetaObject::invokeMethod(object, "getCurrentFile", Q_RETURN_ARG(QVariant, curfile));
        if(curfile.toString() == "" && cmd != "show_noopen") {
            QMetaObject::invokeMethod(object, "closeAnyElement");
            QMetaObject::invokeMethod(object, "openfileShow");
        }

    // Load the specified file in PhotoQt
    } else if(cmd.startsWith("::file::")) {

        QString fname = cmd.remove(0,8);

        if(debug) LOG << CURDATE << "remoteAction(): Opening passed-on file: " << fname.toStdString() << NL;

        QMetaObject::invokeMethod(object, "closeAnyElement");
        QMetaObject::invokeMethod(object, "loadFile", Q_ARG(QVariant, fname));

        if(!this->isVisible()) {
            StartupCheck::Screenshots::getAndStore();
            setupWindowProperties();
        }

        this->requestActivate();

    }


}

// What to do exactly at startup: Load/Open file or minimise to system tray?
void MainHandler::manageStartupFilename(bool startInTray, QString filename) {

    if(startInTray) {
        if(permanentSettings->getTrayIcon() != 1) {
            if(permanentSettings->getTrayIcon() == 0)
                handleTrayIcon();
            permanentSettings->setTrayIcon(1);
        }
        this->hide();
    } else
        QMetaObject::invokeMethod(object, "manageStartup", Q_ARG(QVariant, filename), Q_ARG(QVariant, update));

}

// Show the tray icon (if enabled)
void MainHandler::handleTrayIcon(int val) {

    if(val == -1)
        val = permanentSettings->getTrayIcon();

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "handleTrayIcon(): " << val << " / " << (trayIcon==nullptr) << NL;

    if(val == 1 || val == 2) {

        // we delete a possibly already existing tray icon instance
        // if we don't do this and just re-show a hidden tray icon, then interaction by the user with icon seems to be broken
        if(trayIcon != nullptr)
            delete trayIcon;

        trayIcon = new QSystemTrayIcon(this);
        trayIcon->setIcon(QIcon(":/img/icon.png"));
        trayIcon->setToolTip("PhotoQt " + tr("Image Viewer"));

        // A context menu for the tray icon
        QMenu *trayIconMenu = new QMenu;
        trayIconMenu->setStyleSheet("background-color: rgb(67,67,67); color: white; border-radius: 5px;");
        QAction *trayAcToggle = new QAction(QIcon(":/img/logo.png"),tr("Hide/Show PhotoQt"),this);
        trayIconMenu->addAction(trayAcToggle);
        QAction *trayAcQuit = new QAction(QIcon(":/img/logo.png"),tr("Quit PhotoQt"),this);
        trayIconMenu->addAction(trayAcQuit);
        connect(trayAcToggle, &QAction::triggered, this, &MainHandler::toggleWindow);
        connect(trayAcQuit, &QAction::triggered, this, &MainHandler::forceWindowQuit);

        // Set the menu to the tray icon
        trayIcon->setContextMenu(trayIconMenu);
        connect(trayIcon, &QSystemTrayIcon::activated, this, &MainHandler::trayAction);

        trayIcon->show();

    } else {

        if(trayIcon != nullptr)
            trayIcon->hide();

    }

}

void MainHandler::handleWindowModeChanged(bool windowmode, bool windowdeco, bool keepontop) {

    bool dontShowNormal = true;
    if(permanentSettings->getWindowMode() != windowmode) {
        permanentSettings->setWindowMode(windowmode);
        dontShowNormal = false;
    }
    if(permanentSettings->getWindowDecoration() != windowdeco) {
        permanentSettings->setWindowDecoration(windowdeco);
        dontShowNormal = false;
    }
    permanentSettings->setKeepOnTop(keepontop);

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "handleWindowModeChanged(): " << windowmode << " / " << windowdeco << " / " << keepontop << NL;

    setupWindowProperties(dontShowNormal);

}

// What happens when clicked on tray icon
void MainHandler::trayAction(QSystemTrayIcon::ActivationReason reason) {

    if(reason == QSystemTrayIcon::Trigger)
        toggleWindow();

}

// Toggle the window (called from tray icon)
void MainHandler::toggleWindow() {

    if(!this->isVisible())
        this->show();
    else
        this->hide();

}

// When quitting simply say GoodBye. Not necessary at all, just nice...
void MainHandler::aboutToQuit() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE;
    LOG << "Goodbye!" << NL;

}
