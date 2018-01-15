#include "mainhandler.h"

MainHandler::MainHandler(bool verbose, QWindow *parent) : QQuickView(parent) {

    // holding some variables of the current session
    variables = new Variables;
    variables->verbose = verbose;
    permanentSettings = new Settings;

    // Ensures we only once call setOverrideCursor in order to be able to properly restore it
    overrideCursorSet = false;

    // Perform some startup checks/tasks
    update = performSomeStartupChecks();

    // Find and load the right translation file
    loadTranslation();

    // Register the qml types. This need to happen BEFORE loading the QML file
    registerQmlTypes();

    // Show tray icon (if enabled, checked by function)
    showTrayIcon();

    addImageProvider();

    loadQML();

    setObjectAndConnect();

    connect(qApp, &QCoreApplication::aboutToQuit, this, &MainHandler::aboutToQuit);

    setupWindowProperties();

}

// Performs some initial startup checks to make sure everything is in order
int MainHandler::performSomeStartupChecks() {

    // Since version 1.4, PhotoQt uses proper standard folders for storing its config files. The configuration of older versions needs to be migrated.
    StartupCheck::Migration::migrateIfNecessary(variables->verbose);

    // Using the settings file (and the stored version therein) check if PhotoQt was updated or installed (if settings file not present)
    int update = StartupCheck::UpdateCheck::checkForUpdateInstall(variables->verbose, permanentSettings);

    if(update > 0) StartupCheck::Settings::moveToNewKeyNames();

    // Before the window is shown we create screenshots and store them in the temporary folder
    StartupCheck::Screenshots::getAndStore(variables->verbose);

    // If we start PhotoQt in system tray, we need to make sure the tray is properly enabled
    StartupCheck::StartInTray::makeSureSettingsReflectTrayStartupSetting(variables->verbose, variables->startintray, permanentSettings);

    // Check whether everything is alright with the thumbnails database
    StartupCheck::Thumbnails::checkThumbnailsDatabase(update, permanentSettings, variables->verbose);

    // Ensure PhotoQt knows about all the required file formats
    StartupCheck::FileFormats::checkForDefaultSettingsFileAndReturnWhetherDefaultsAreToBeSet(variables->verbose);

    // Only on update do we need to (potentially) combine mouse and key shortcuts in single file
    if(update == 1) StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile(variables->verbose);

    // Return the code whether PhotoQt was updated (1), installed (2), or none of the above (0)
    return update;

}

// Load the right translation file
void MainHandler::loadTranslation() {

    StartupCheck::Localisation::loadTranslation(variables->verbose, permanentSettings, &trans);

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

}

// Add settings/scripts/... access to QML
void MainHandler::registerQmlTypes() {
    qmlRegisterType<Settings>("PSettings", 1, 0, "PSettings");
    qmlRegisterType<FileFormats>("PFileFormats", 1, 0, "PFileFormats");
    qmlRegisterType<GetMetaData>("PGetMetaData", 1, 0, "PGetMetaData");
    qmlRegisterType<GetAndDoStuff>("PGetAndDoStuff", 1, 0, "PGetAndDoStuff");
    qmlRegisterType<ToolTip>("PToolTip", 1, 0, "PToolTip");
    qmlRegisterType<Colour>("PColour", 1, 0, "PColour");
    qmlRegisterType<ImageWatch>("PImageWatch", 1, 0, "PImageWatch");
    qmlRegisterType<ShareOnline::Imgur>("PImgur", 1, 0, "PImgur");
    qmlRegisterType<Clipboard>("PClipboard", 1, 0, "PClipboard");
    qmlRegisterType<ShortcutsNotifier>("PShortcutsNotifier", 1, 0, "PShortcutsNotifier");
    qmlRegisterType<ThumbnailManagement>("PThumbnailManagement", 1, 0, "PThumbnailManagement");
    qmlRegisterType<Shortcuts>("PShortcutsHandler", 1, 0, "PShortcutsHandler");
    qmlRegisterType<FileDialog>("PFileDialog", 1, 0, "PFileDialog");
    qmlRegisterType<Watcher>("PWatcher", 1, 0, "PWatcher");
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
    if(variables->verbose)
        LOG << CURDATE << "[QML] " << loc.toStdString() << ": " << msg.toStdString() << NL;
}

void MainHandler::setupWindowProperties() {

    this->setMinimumSize(QSize(640,480));
    this->setTitle("PhotoQt " + tr("Image Viewer"));

    if(variables->verbose)
        LOG << CURDATE << "setupWindowProperties(): started processing" << std::endl;

    GetAndDoStuff gads;

    // window mode
    if(permanentSettings->windowMode) {

        // always keep window on top
        if(permanentSettings->keepOnTop) {

            if(permanentSettings->windowDecoration)
                this->setFlags(Qt::Window|Qt::WindowStaysOnTopHint);
            else
                this->setFlags(Qt::Window|Qt::FramelessWindowHint|Qt::WindowStaysOnTopHint);

        // treat as normal window
        } else {

            if(permanentSettings->windowDecoration)
                this->setFlags(Qt::Window);
            else
                this->setFlags(Qt::Window|Qt::FramelessWindowHint);

        }

        // Restore the stored window geometry
        if(permanentSettings->saveWindowGeometry) {

            QRect rect = gads.getStoredGeometry();

            // Check whether stored information is actually valid
            if(rect.width() < 100 || rect.height() < 100)
                this->showMaximized();
            else {
                this->show();
                this->setGeometry(rect);
            }
        // If not stored, we display the image always maximised
        } else
            this->showMaximized();

    // fullscreen mode
    } else {

        // Always keep window on top...
        if(permanentSettings->keepOnTop)
            this->setFlags(Qt::WindowStaysOnTopHint|Qt::FramelessWindowHint);
        // ... or not
        else
            this->setFlags(Qt::FramelessWindowHint);

        // In Enlightenment, showing PhotoQt as fullscreen causes some problems, revert to showing it as maximised there by default
        if(gads.detectWindowManager() == "enlightenment")
            this->showMaximized();
        else
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
    }

    return QQuickView::event(e);

}

// Called to force app to quit, bypassing QCloseEvent
void MainHandler::forceWindowQuit() {
    qApp->quit();
}

// Remote controlling
void MainHandler::remoteAction(QString cmd) {

    if(variables->verbose)
        LOG << CURDATE << "remoteAction(): " << cmd.toStdString() << NL;

    // Open a new file (and show PhotoQt if necessary)
    if(cmd == "open") {

        if(variables->verbose)
            LOG << CURDATE << "remoteAction(): Open file" << NL;
        if(!this->isVisible()) {
            StartupCheck::Screenshots::getAndStore(variables->verbose);
            setupWindowProperties();
        }
        QMetaObject::invokeMethod(object, "openfileShow");
        this->requestActivate();

    // Disable thumbnails
    } else if(cmd == "nothumbs") {

        if(variables->verbose)
            LOG << CURDATE << "remoteAction(): Disable thumbnails" << NL;
        permanentSettings->thumbnailDisable = true;
        permanentSettings->thumbnailDisableChanged(true);

    // (Re-)enable thumbnails
    } else if(cmd == "thumbs") {

        if(variables->verbose)
            LOG << CURDATE << "remoteAction(): Enable thumbnails" << NL;
        permanentSettings->thumbnailDisable = true;

    // Hide the window to system tray
    } else if(cmd == "hide" || (cmd == "toggle" && this->isVisible())) {

        if(variables->verbose)
            LOG << CURDATE << "remoteAction(): Hiding" << NL;
        if(permanentSettings->trayIcon != 1) {
            permanentSettings->trayIcon = 1;
            permanentSettings->trayIconChanged(1);
        }
        QMetaObject::invokeMethod(object, "closeAnyElement");
        this->hide();

    // Show the window again (after being hidden to system tray)
    } else if(cmd.startsWith("show") || (cmd == "toggle" && !this->isVisible())) {

        if(variables->verbose)
            LOG << CURDATE << "remoteAction(): Showing" << NL;

        // The same code can be found at the end of main.cpp
        if(!this->isVisible()) {
            StartupCheck::Screenshots::getAndStore(variables->verbose);
            setupWindowProperties();
        }

        this->requestActivate();

        QVariant curfile;
        QMetaObject::invokeMethod(object, "getCurrentFile", Q_RETURN_ARG(QVariant, curfile));
        if(curfile.toString() == "" && cmd != "show_noopen")
            QMetaObject::invokeMethod(object, "openfileShow");

    // Load the specified file in PhotoQt
    } else if(cmd.startsWith("::file::")) {

        if(variables->verbose)
            LOG << CURDATE << "remoteAction(): Opening passed-on file" << NL;
        QMetaObject::invokeMethod(object, "closeAnyElement");
        QMetaObject::invokeMethod(object, "loadFile", Q_ARG(QVariant, cmd.remove(0,8)));

    }


}

// What to do exactly at startup: Load/Open file or minimise to system tray?
void MainHandler::manageStartupFilename(bool startInTray, QString filename) {

    if(startInTray) {
        if(permanentSettings->trayIcon != 1) {
            if(permanentSettings->trayIcon == 0)
                showTrayIcon();
            permanentSettings->trayIcon = 1;
            permanentSettings->trayIconChanged(1);
        }
        this->hide();
    } else
        QMetaObject::invokeMethod(object, "manageStartup", Q_ARG(QVariant, filename), Q_ARG(QVariant, update));

}

// Show the tray icon (if enabled)
void MainHandler::showTrayIcon() {

    if(variables->verbose)
        LOG << CURDATE << "showTrayIcon()" << NL;

    if(permanentSettings->trayIcon != 0) {

        if(variables->verbose)
            LOG << CURDATE << "showTrayIcon(): Setting up" << NL;

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

        if(variables->verbose)
            LOG << CURDATE << "showTrayIcon(): Setting icon to visible" << NL;

        trayIcon->show();

    }

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

    if(variables->verbose)
        LOG << CURDATE;
    LOG << "Goodbye!" << NL;

}
