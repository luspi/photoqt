#include "mainwindow.h"

MainWindow::MainWindow(bool verbose, QWindow *parent) : QQuickView(parent) {

	// Settings and variables
	settingsPerSession = new SettingsSession;
	settingsPermanent = new Settings;
	fileformats = new FileFormats;
	variables = new Variables;
	shortcuts = new Shortcuts;

	variables->verbose = verbose;

	// Set only by main.cpp at start-up, contains filename passed via command line
	startup_filename = "";

	this->setMinimumSize(QSize(600,400));

	// Add image providers
	this->engine()->addImageProvider("thumb",new ImageProviderThumbnail);
	this->engine()->addImageProvider("full",new ImageProviderFull);

	// Add settings access to QML
	qmlRegisterType<Settings>("Settings", 1, 0, "Settings");
	qmlRegisterType<FileFormats>("FileFormats", 1, 0, "FileFormats");
	qmlRegisterType<SettingsSession>("SettingsSession", 1, 0, "SettingsSession");
	qmlRegisterType<GetMetaData>("GetMetaData", 1, 0, "GetMetaData");
	qmlRegisterType<GetAndDoStuff>("GetAndDoStuff", 1, 0, "GetAndDoStuff");
	qmlRegisterType<ThumbnailManagement>("ThumbnailManagement", 1, 0, "ThumbnailManagement");

	// Load QML
	this->setSource(QUrl("qrc:/qml/mainwindow.qml"));
	this->setColor(QColor(Qt::transparent));

	// Get object (for signals and stuff)
	object = this->rootObject();

	// Class to load a new directory
	loadDir = new LoadDir(verbose);

	// Filedialog to open new files
	// We HAVE TO use it this way (and NOT using, e.g., the static method getOpenFileName())
	// as otherwise the window might be displayed BEHIND the main app window without any way to interact with it.
	// Settings setModal() to false and calling it with .exec() later-on seems to does the trick...
	filedialog = new QFileDialog;
	filedialog->setModal(false);
	filedialog->setWindowTitle(tr("Open image file"));

	// Scrolled view
	connect(object, SIGNAL(thumbScrolled(QVariant)), this, SLOT(handleThumbnails(QVariant)));

	// Open file
	connect(object, SIGNAL(openFile()), this, SLOT(openNewFile()));


	connect(object, SIGNAL(reloadDirectory(QVariant,QVariant)), this, SLOT(openNewFile(QVariant,QVariant)));
	connect(object, SIGNAL(loadMoreThumbnails()), this, SLOT(loadMoreThumbnails()));
	connect(object, SIGNAL(didntLoadThisThumbnail(QVariant)), this, SLOT(didntLoadThisThumbnail(QVariant)));

	connect(object, SIGNAL(verboseMessage(QVariant,QVariant)), this, SLOT(qmlVerboseMessage(QVariant,QVariant)));

    // Hide/Quit window
    connect(object, SIGNAL(hideToSystemTray()), this, SLOT(hideToSystemTray()));
    connect(object, SIGNAL(quitPhotoQt()), this, SLOT(quitPhotoQt()));

	// React to some settings...
	connect(settingsPermanent, SIGNAL(trayiconChanged(int)), this, SLOT(showTrayIcon()));
	connect(settingsPermanent, SIGNAL(trayiconChanged(int)), this, SLOT(hideTrayIcon()));
	connect(settingsPermanent, SIGNAL(windowmodeChanged(bool)), this, SLOT(updateWindowGeometry()));
	connect(settingsPermanent, SIGNAL(windowDecorationChanged(bool)), this, SLOT(updateWindowGeometry()));

	connect(this, SIGNAL(xChanged(int)), this, SLOT(updateWindowXandY()));
	connect(this, SIGNAL(yChanged(int)), this, SLOT(updateWindowXandY()));

	showTrayIcon();

}

// Open a new file
void MainWindow::openNewFile(QVariant usethis, QVariant filter) { openNewFile(usethis.toString(), filter); }
void MainWindow::openNewFile(QString usethis, QVariant filter) {

	if(variables->verbose)
		LOG << DATE << "openNewFile(): Request to open new file" << std::endl;

	// Only possibly set at start-up, filename passed via command line
	if(startup_filename != "") {
		usethis = startup_filename;
		startup_filename = "";
	}

	// Get new filename
	QString opendir = QDir::homePath();
	if(variables->currentDir != "")
		opendir = variables->currentDir;

	QByteArray file = usethis.toUtf8();

	if(usethis == "") {

		if(variables->verbose)
			LOG << DATE << "openNewFile(): No filename passed -> requesting new one" << std::endl;

		QMetaObject::invokeMethod(object, "alsoIgnoreSystemShortcuts",
					  Q_ARG(QVariant, true));

		variables->fileDialogOpened = true;

		// Get new filename
		QString knownQT = fileformats->formatsQtEnabled.join(" ") + " " + fileformats->formatsQtEnabledExtras.join(" ");
		QString knownGM = fileformats->formatsGmEnabled.join(" ");
		QString known = knownQT + " " + knownGM + " " + fileformats->formatsExtrasEnabled.join(" ");

		// Set filedialog options
		filedialog->setDirectory(opendir);
		filedialog->setNameFilter(tr("Images") + " (" + known.trimmed() + ");;"
										+ tr("Images") + " (Qt)" + " (" + knownQT.trimmed() + ");;"
						 #ifdef GM
										+ tr("Images") + " (GraphicsMagick)" + " (" + knownGM.trimmed() + ");;"
						 #endif
										+ tr("All Files") + " (*)");
		filedialog->exec();

		// Check return file
		if(filedialog->selectedFiles().length() == 0)
			file = "";
		else
			file = filedialog->selectedFiles().first().toUtf8();

		variables->fileDialogOpened = false;

		QMetaObject::invokeMethod(object, "alsoIgnoreSystemShortcuts",
					  Q_ARG(QVariant, false));
	}

	if(file.trimmed() == "") return;

    // Save current directory
    variables->currentDir = QFileInfo(file).absolutePath();

	// Clear loaded thumbnails
	variables->loadedThumbnails.clear();

	// Load direcgtory
	QFileInfoList l = loadDir->loadDir(file,filter.toString());
	if(l.isEmpty()) {
		QMetaObject::invokeMethod(object, "noResultsFromFilter");
		return;
	}
	if(!l.contains(QFileInfo(file)))
		file = l.at(0).filePath().toLatin1();

	// Get and store length
	int l_length = l.length();
	settingsPerSession->setValue("countTot",l_length);

	// Convert QFileInfoList into QStringList and store it
	QStringList ll;
	for(int i = 0; i < l_length; ++i)
		ll.append(l.at(i).absoluteFilePath().toUtf8().toPercentEncoding("/ "));
	settingsPerSession->setValue("allFileList",ll);

	// Get and store current position
	int curPos = l.indexOf(QFileInfo(file));
	settingsPerSession->setValue("curPos",curPos);

	// Setiup thumbnail model
	QMetaObject::invokeMethod(object, "setupModel",
		Q_ARG(QVariant, ll),
		Q_ARG(QVariant, curPos));

	// Display current postiion in main image view
	QMetaObject::invokeMethod(object, "displayImage",
				  Q_ARG(QVariant, curPos));

	QVariant centerPos = curPos;
	if(!QMetaObject::invokeMethod(object, "getCenterPos",
				  Q_RETURN_ARG(QVariant, centerPos)))
		qDebug() << "couldn't get center pos!";

	// And handle the thumbnails
	handleThumbnails(centerPos.toInt());

}

// Thumbnail handling (centerPos is image currently displayed in the visible center of thumbnail bar)
void MainWindow::handleThumbnails(QVariant centerPos) {

	if(variables->verbose)
		LOG << DATE << "handleThumbnails(): New thumbnail center pos: " << centerPos.toInt() << std::endl;

	// Get some settings for later use
	int thumbSize = settingsPermanent->getThumbnailsize();
	int thumbSpacing = settingsPermanent->getThumbnailSpacingBetween();
	int dynamicSmartNormal = settingsPermanent->thumbnailDynamic;

	// Get total and center pos
	int countTot = settingsPerSession->value("countTot").toInt();
	currentCenter = centerPos.toInt();

	// Generate how many to each side
	int numberToOneSide = (this->width()/(thumbSize+thumbSpacing))/2;

	// Load full directory
	if(dynamicSmartNormal == 0) numberToOneSide = qMax(currentCenter,countTot-currentCenter);
	int maxLoad = numberToOneSide;
	if(dynamicSmartNormal == 2) maxLoad = qMax(currentCenter,countTot-currentCenter);

	loadThumbnailsInThisOrder.clear();
	smartLoadThumbnailsInThisOrder.clear();

	if(!variables->loadedThumbnails.contains(currentCenter)) loadThumbnailsInThisOrder.append(currentCenter);

	// Load thumbnails in this order
	for(int i = 1; i <= maxLoad+3; ++i) {
		if(i <= numberToOneSide+3) {
			if((currentCenter-i) >= 0 && !variables->loadedThumbnails.contains(currentCenter-i))
				loadThumbnailsInThisOrder.append(currentCenter-i);
			if(currentCenter+i < countTot && !variables->loadedThumbnails.contains(currentCenter+i))
				loadThumbnailsInThisOrder.append(currentCenter+i);
		} else {
			if((currentCenter-i) >= 0 && !variables->loadedThumbnails.contains(currentCenter-i))
				smartLoadThumbnailsInThisOrder.append(currentCenter-i);
			if(currentCenter+i < countTot && !variables->loadedThumbnails.contains(currentCenter+i))
				smartLoadThumbnailsInThisOrder.append(currentCenter+i);
		}
	}

	loadMoreThumbnails();

}

void MainWindow::loadMoreThumbnails() {

	if(variables->verbose)
		LOG << DATE << "loadMoreThumbnails(): Continue loading thumbnails?" << std::endl;

	if(settingsPermanent->thumbnailFilenameInstead) return;

	if(loadThumbnailsInThisOrder.length() == 0 && smartLoadThumbnailsInThisOrder.length() == 0) return;

	if(loadThumbnailsInThisOrder.length() != 0) {

		int load = loadThumbnailsInThisOrder.first();

		if(variables->loadedThumbnails.contains(load)) {
			loadThumbnailsInThisOrder.removeFirst();
			return loadMoreThumbnails();
		}

		if(variables->verbose)
			LOG << DATE << "loadMoreThumbnails(): Yes, please (visible)! Load #" << load << std::endl;

		loadThumbnailsInThisOrder.removeFirst();

		QMetaObject::invokeMethod(object, "reloadImage",
					  Q_ARG(QVariant, load),
					  Q_ARG(QVariant, false));
		variables->loadedThumbnails.append(load);

	} else {

		int load = smartLoadThumbnailsInThisOrder.first();

		if(variables->loadedThumbnails.contains(load)) {
			smartLoadThumbnailsInThisOrder.removeFirst();
			return loadMoreThumbnails();
		}

		if(variables->verbose)
			LOG << DATE << "loadMoreThumbnails(): Yes, please (invisible, smart)! Load #" << load << std::endl;

		smartLoadThumbnailsInThisOrder.removeFirst();

		QMetaObject::invokeMethod(object, "reloadImage",
					  Q_ARG(QVariant, load),
					  Q_ARG(QVariant, true));
		variables->loadedThumbnails.append(load);
	}

}

// This one was tried to be preloaded smartly, but didn't exist yet -> nothing done
void MainWindow::didntLoadThisThumbnail(QVariant pos) {
	if(variables->verbose)
		LOG << DATE << "didntLoadThisThumbnail(): Thumbnail #" << pos.toInt() << " not loaded smartly..." << std::endl;
	variables->loadedThumbnails.removeAt(variables->loadedThumbnails.indexOf(pos.toInt()));
}

// These are used to communicate key combos to the qml interface (for shortcuts, lineedits, etc.)
void MainWindow::detectedKeyCombo(QString combo) {
	if(variables->verbose)
		LOG << DATE << "detectedKeyCombo(): " << combo.toStdString() << std::endl;
	QMetaObject::invokeMethod(object, "detectedKeyCombo",
				  Q_ARG(QVariant, combo));
}
void MainWindow::keyPressEvent(QKeyEvent *e) {
	if(variables->verbose)
		LOG << DATE << "keyPressEvent()" << std::endl;
    detectedKeyCombo(shortcuts->handleKeyPress(e));
	QQuickView::keyPressEvent(e);
}
void MainWindow::keyReleaseEvent(QKeyEvent *e) {
	if(variables->verbose)
		LOG << DATE << "keyReleaseEvent()" << std::endl;
	QMetaObject::invokeMethod(object, "keysReleased",
							  Q_ARG(QVariant,shortcuts->handleKeyPress(e)));
	QQuickView::keyReleaseEvent(e);
}

// Catch wheel events
void MainWindow::wheelEvent(QWheelEvent *e) {

	if(variables->verbose)
		LOG << DATE << "wheelEvent()" << std::endl;

	if(e->angleDelta().y() < 0) {

		if(!object->property("blocked").toBool()) {

			// Wheel direction changed -> start counting at beginning
			if(variables->wheelcounter >= 0 && settingsPermanent->mouseWheelSensitivity > 1) {
				variables->wheelcounter = -1;
				return;
			// Same direction, but haven't reached counter yet
			} else if(variables->wheelcounter*-1 < settingsPermanent->mouseWheelSensitivity-1 && settingsPermanent->mouseWheelSensitivity > 1) {
				--variables->wheelcounter;
				return;
			}

		}

		// We got here? Great, so reset counter (i.e., next event starts at beginning again)
		variables->wheelcounter = 0;

		if(variables->verbose)
			LOG << DATE << "wheelEvent(): Wheel down" << std::endl;

		QMetaObject::invokeMethod(object,"mouseWheelEvent",
								  Q_ARG(QVariant, "Wheel Down"));

	} else if(e->angleDelta().y() > 0) {

		if(!object->property("blocked").toBool()) {

			// Wheel direction changed -> start counting at beginning
			if(variables->wheelcounter <= 0 && settingsPermanent->mouseWheelSensitivity > 1) {
				variables->wheelcounter = 1;
				return;
			// Same direction, but haven't reached counter yet
			} else if(variables->wheelcounter < settingsPermanent->mouseWheelSensitivity-1 && settingsPermanent->mouseWheelSensitivity > 1) {
				++variables->wheelcounter;
				return;
			}

		}

		// We got here? Great, so reset counter (i.e., next event starts at beginning again)
		variables->wheelcounter = 0;

		if(variables->verbose)
			LOG << DATE << "wheelEvent(): Wheel up" << std::endl;

		QMetaObject::invokeMethod(object,"mouseWheelEvent",
								  Q_ARG(QVariant, "Wheel Up"));

	}

	QQuickView::wheelEvent(e);

}

// Catch mouse events (ignored when mouse moved when button pressed)
void MainWindow::mousePressEvent(QMouseEvent *e) {

	if(variables->verbose)
		LOG << DATE << "mousePressEvent()" << std::endl;

	mouseCombo = "";
	mouseOrigPoint = e->pos();
	mouseDx = 0;
	mouseDy = 0;

	if(e->button() == Qt::RightButton)
		mouseCombo = "Right Button";
	else if(e->button() == Qt::MiddleButton)
		mouseCombo = "Middle Button";
	else if(e->button() == Qt::LeftButton)
		mouseCombo = "Left Button";

	if(variables->verbose)
		LOG << DATE << "mousePressEvent(): mouseCombo = " << mouseCombo.toStdString() << std::endl;

	QQuickView::mousePressEvent(e);

}
void MainWindow::mouseReleaseEvent(QMouseEvent *e) {

	if(variables->verbose)
		LOG << DATE << "mouseReleaseEvent()" << std::endl;

	QQuickView::mouseReleaseEvent(e);

    if(mouseDx > 20 || mouseDy > 20 || abs(mouseOrigPoint.x()-e->pos().x()) > 20 || abs(mouseOrigPoint.y()-e->pos().y()) > 20)
        QMetaObject::invokeMethod(object,"closeContextMenuWhenOpen");
    else
        QMetaObject::invokeMethod(object,"mouseWheelEvent",
                                  Q_ARG(QVariant, mouseCombo));

}
void MainWindow::mouseMoveEvent(QMouseEvent *e) {

	if(variables->verbose)
		LOG << DATE << "mouseMoveEvent()" << std::endl;

	mouseDx += abs(mouseOrigPoint.x()-e->pos().x());
	mouseDy += abs(mouseOrigPoint.y()-e->pos().y());

	QQuickView::mouseMoveEvent(e);

}

bool MainWindow::event(QEvent *e) {

	if (e->type() == QEvent::Close) {

		if(variables->verbose)
			LOG << DATE << "closeEvent()" << std::endl;

		// If a widget (like settings or about) is open, then this close event only closes this widget (like escape)
		if(object->property("blocked").toBool()) {

			if(variables->verbose)
				LOG << DATE << "closeEvent(): Ignoring event, sending 'Escape' shortcut" << std::endl;

			e->ignore();

			detectedKeyCombo("Escape");

		} else {

            // Hide to system tray (except if a 'quit' was requested)
			if(settingsPermanent->trayicon == 1 && !variables->skipSystemTrayAndQuit) {

                trayAction(QSystemTrayIcon::Trigger);
				if(variables->verbose) LOG << DATE << "closeEvent(): Hiding to System Tray." << std::endl;
				e->ignore();

			// Quit
			} else {

				// Save current geometry
				QSettings settings("photoqt","photoqt");
				settings.setValue("mainWindowGeometry", geometry());

				e->accept();

				if(variables->verbose)
					LOG << DATE;
				LOG << "Goodbye!" << std::endl;

				qApp->quit();

			}

		}
	}

	return QQuickWindow::event(e);

}

void MainWindow::trayAction(QSystemTrayIcon::ActivationReason reason) {

	if(variables->verbose)
		LOG << DATE << "trayAction()" << std::endl;

    if(reason == QSystemTrayIcon::Trigger) {

		if(!variables->hiddenToTrayIcon) {
            if(!variables->fileDialogOpened) {
                variables->geometryWhenHiding = this->geometry();
				if(variables->verbose)
					LOG << DATE << "trayAction(): Hiding to tray" << std::endl;
                this->hide();
            }
        } else {

			if(variables->verbose)
				LOG << DATE << "trayAction(): Updating screenshots" << std::endl;

			// Get screenshots
			for(int i = 0; i < QGuiApplication::screens().count(); ++i) {
				QScreen *screen = QGuiApplication::screens().at(i);
				QRect r = screen->geometry();
				QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
				if(!pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i)))
					std::cerr << "[ERROR] Unable to update screenshot for screen #" << i << std::endl;
			}

			if(variables->verbose)
				LOG << DATE << "trayAction(): SHowing window" << std::endl;

			updateWindowGeometry();

            if(variables->currentDir == "") openNewFile();
        }

	}

}

void MainWindow::hideToSystemTray() {
		this->close();
}
void MainWindow::quitPhotoQt() {
    variables->skipSystemTrayAndQuit = true;
    this->close();
}

void MainWindow::showTrayIcon() {

	if(variables->verbose)
		LOG << DATE << "showTrayIcon()" << std::endl;

	if(settingsPermanent->trayicon != 0) {

		if(!variables->trayiconSetup) {

			if(variables->verbose)
				LOG << DATE << "showTrayIcon(): Setting up" << std::endl;

			trayIcon = new QSystemTrayIcon(this);
			trayIcon->setIcon(QIcon(":/img/icon.png"));
			trayIcon->setToolTip("PhotoQt - " + tr("Image Viewer"));

			// A context menu for the tray icon
			QMenu *trayIconMenu = new QMenu;
			trayIconMenu->setStyleSheet("background-color: rgb(67,67,67); color: white; border-radius: 5px;");
			QAction *trayAcToggle = new QAction(QIcon(":/img/logo.png"),tr("Hide/Show PhotoQt"),this);
			trayIconMenu->addAction(trayAcToggle);
			connect(trayAcToggle, SIGNAL(triggered()), this, SLOT(show()));

			// Set the menu to the tray icon
			trayIcon->setContextMenu(trayIconMenu);
			connect(trayIcon, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), this, SLOT(trayAction(QSystemTrayIcon::ActivationReason)));

			variables->trayiconSetup = true;

		}

		if(variables->verbose)
			LOG << DATE << "showTrayIcon(): Setting icon to visible" << std::endl;

		trayIcon->show();
		variables->trayiconVisible = true;

	}

}

void MainWindow::hideTrayIcon() {

	if(variables->verbose)
		LOG << DATE << "hideTrayIcon()" << std::endl;

	if(settingsPermanent->trayicon == 0 && variables->trayiconSetup) {

		trayIcon->hide();
		variables->trayiconVisible = false;

	}

}

// Remote controlling
void MainWindow::remoteAction(QString cmd) {

	if(variables->verbose)
		LOG << DATE << "remoteAction()" << std::endl;

	if(cmd == "open") {

		if(variables->verbose)
			LOG << DATE << "remoteAction(): Open file" << std::endl;
		openNewFile();

	} else if(cmd == "nothumbs") {

		if(variables->verbose)
			LOG << DATE << "remoteAction(): Disable thumbnails" << std::endl;
		settingsPermanent->setThumbnailDisable(true);

	} else if(cmd == "thumbs") {

		if(variables->verbose)
			LOG << DATE << "remoteAction(): Enable thumbnails" << std::endl;
		settingsPermanent->setThumbnailDisable(false);

	} else if(cmd == "hide" || (cmd == "toggle" && this->isVisible())) {

		if(variables->verbose)
			LOG << DATE << "remoteAction(): Hiding" << std::endl;
		if(settingsPermanent->trayicon != 1)
			settingsPermanent->setTrayicon(1);
		this->hide();

	} else if(cmd.startsWith("show") || (cmd == "toggle" && !this->isVisible())) {

		if(variables->verbose)
			LOG << DATE << "remoteAction(): Showing" << std::endl;

		// The same code can be found at the end of main.cpp
		if(!this->isVisible()) {
			// Get screenshots
			for(int i = 0; i < QGuiApplication::screens().count(); ++i) {
				QScreen *screen = QGuiApplication::screens().at(i);
				QRect r = screen->geometry();
				QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
				pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i));
			}
			updateWindowGeometry();
			this->raise();
		}

		if(variables->currentDir == "" && cmd != "show_noopen")
			openNewFile();

	} else if(cmd.startsWith("::file::")) {

		if(variables->verbose)
			LOG << DATE << "remoteAction(): Opening passed-on file" << std::endl;
		openNewFile(cmd.remove(0,8));

	}


}

void MainWindow::updateWindowGeometry() {

	if(variables->verbose)
		LOG << DATE << "updateWindowGeometry()" << std::endl;

	if(settingsPermanent->windowmode) {
		if(settingsPermanent->keepOnTop) {
			filedialog->setWindowFlags(filedialog->windowFlags() | Qt::WindowStaysOnTopHint);
			settingsPermanent->windowDecoration
					  ? this->setFlags(Qt::Window | Qt::WindowStaysOnTopHint)
					  : this->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
		} else {
			filedialog->setWindowFlags(filedialog->windowFlags() & ~Qt::WindowStaysOnTopHint);
			settingsPermanent->windowDecoration
					  ? this->setFlags(Qt::Window)
					  : this->setFlags(Qt::Window | Qt::FramelessWindowHint);
		}
		QSettings settings("photoqt","photoqt");
		if(settings.allKeys().contains("mainWindowGeometry") && settingsPermanent->saveWindowGeometry) {
			this->show();
			this->setGeometry(settings.value("mainWindowGeometry").toRect());
			QTimer::singleShot(200,this, SLOT(resetWindowGeometry()));
		} else
			this->showMaximized();
	} else {

		if(settingsPermanent->keepOnTop) {
			this->setFlags(Qt::WindowStaysOnTopHint | Qt::FramelessWindowHint);
			filedialog->setWindowFlags(filedialog->windowFlags() | Qt::WindowStaysOnTopHint);
		} else {
			this->setFlags(Qt::FramelessWindowHint);
			filedialog->setWindowFlags(filedialog->windowFlags() & ~Qt::WindowStaysOnTopHint);
		}

		QString(getenv("DESKTOP")).startsWith("Enlightenment") ? this->showMaximized() : this->showFullScreen();
	}

}

void MainWindow::resetWindowGeometry() {
	if(variables->verbose)
		LOG << DATE << "resetWindowGeometry()" << std::endl;
	QSettings settings("photoqt","photoqt");
	this->setGeometry(settings.value("mainWindowGeometry").toRect());
}

void MainWindow::updateWindowXandY() {

	object->setProperty("windowx",this->x());
	object->setProperty("windowy",this->y());

}

void MainWindow::showStartup(QString type) {

	if(variables->verbose)
		LOG << DATE << "showStartup(): " << type.toStdString() << std::endl;

	QMetaObject::invokeMethod(object,"showStartup",
							  Q_ARG(QVariant, type));

}

void MainWindow::qmlVerboseMessage(QVariant loc, QVariant msg) {
	if(variables->verbose)
		LOG << DATE << "[QML] " << loc.toString().toStdString() << ": " << msg.toString().toStdString() << std::endl;
}

MainWindow::~MainWindow() {
	delete settingsPerSession;
	delete settingsPermanent;
	delete fileformats;
	if(variables->trayiconSetup) delete trayIcon;
	delete variables;
	delete shortcuts;
	delete loadDir;
}
