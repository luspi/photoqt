#include "mainwindow.h"

MainWindow::MainWindow(bool verbose, QWindow *parent) : QQuickView(parent) {

	connect(this, SIGNAL(statusChanged(QQuickView::Status)), this, SLOT(loadStatus(QQuickView::Status)));

#ifdef Q_OS_WIN
	QtWin::enableBlurBehindWindow(this);
#endif

	// Settings and variables
	settingsPermanent = new Settings;
	fileformats = new FileFormats(verbose);
	variables = new Variables;
	touchHandler = new TouchHandler;
	touchEventInProgress = false;
	mouseHandler = new MouseHandler;
	keyHandler = new KeyHandler;

	variables->verbose = verbose;

	overrideCursorHowOftenSet = 0;

	this->setMinimumSize(QSize(800,600));

	// Add image providers
	this->engine()->addImageProvider("thumb",new ImageProviderThumbnail);
	this->engine()->addImageProvider("full",new ImageProviderFull);
	this->engine()->addImageProvider("icon",new ImageProviderIcon);
	this->engine()->addImageProvider("empty", new ImageProviderEmpty);

	// Add settings access to QML
	qmlRegisterType<Settings>("Settings", 1, 0, "Settings");
	qmlRegisterType<FileFormats>("FileFormats", 1, 0, "FileFormats");
	qmlRegisterType<GetMetaData>("GetMetaData", 1, 0, "GetMetaData");
	qmlRegisterType<GetAndDoStuff>("GetAndDoStuff", 1, 0, "GetAndDoStuff");
	qmlRegisterType<ThumbnailManagement>("ThumbnailManagement", 1, 0, "ThumbnailManagement");
	qmlRegisterType<ToolTip>("ToolTip", 1, 0, "ToolTip");
	qmlRegisterType<ShortcutsNotifier>("ShortcutsNotifier", 1, 0, "ShortcutsNotifier");
	qmlRegisterType<Colour>("Colour", 1, 0, "Colour");
	qmlRegisterType<ImageWatch>("ImageWatch", 1, 0, "ImageWatch");

	// Load QML
	this->setSource(QUrl("qrc:/qml/mainwindow.qml"));
	this->setColor(QColor(Qt::transparent));

	// Get object (for signals and stuff)
	object = this->rootObject();

	// Class to load a new directory
	loadDir = new LoadDir(verbose);


	connect(object, SIGNAL(reloadDirectory(QString,QString)), this, SLOT(handleOpenFileEvent(QString,QString)));
	connect(object, SIGNAL(setOverrideCursor()), this, SLOT(setOverrideCursor()));
	connect(object, SIGNAL(restoreOverrideCursor()), this, SLOT(restoreOverrideCursor()));

	connect(object, SIGNAL(verboseMessage(QString,QString)), this, SLOT(qmlVerboseMessage(QString,QString)));

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

	// Pass on shortcuts events
	connect(keyHandler, SIGNAL(receivedKeyEvent(QString)),
			this, SLOT(passOnKeyEvent(QString)));
	connect(touchHandler, SIGNAL(updatedTouchEvent(QPointF,QPointF,QString,uint,qint64,QStringList)),
			this, SLOT(passOnUpdatedTouchEvent(QPointF,QPointF,QString,uint,qint64,QStringList)));
	connect(touchHandler, SIGNAL(receivedTouchEvent(QPointF,QPointF,QString,uint,qint64,QStringList)),
			this, SLOT(passOnFinishedTouchEvent(QPointF,QPointF,QString,uint,qint64,QStringList)));
	connect(touchHandler, SIGNAL(setImageInteractiveMode(bool)),
			this, SLOT(setImageInteractiveMode(bool)));
	connect(mouseHandler, SIGNAL(finishedMouseEvent(QPoint,QPoint,qint64,QString,QStringList,int,QString)),
			this, SLOT(passOnFinishedMouseEvent(QPoint,QPoint,qint64,QString,QStringList,int,QString)));
	connect(mouseHandler, SIGNAL(updatedMouseEvent(QString,QStringList,QString)),
			this, SLOT(passOnUpdatedMouseEvent(QString,QStringList,QString)));
	connect(mouseHandler, SIGNAL(setImageInteractiveMode(bool)),
			this, SLOT(setImageInteractiveMode(bool)));

	showTrayIcon();

	// We need to call this with a little delay, as the automatic restoration of the window geometry at startup when window mode
	// is enabled doesn't update the actualy window x/y (and thus PhotoQt might be detected on the wrong screen which messes up
	// calculations involving local cursor coordinates (e.g., for 'close on click on grey'))
	QTimer::singleShot(100,this, SLOT(updateWindowXandY()));

}

void MainWindow::handleStartup(int upd, QString filename) {

	if(upd != 0)
		showStartup(upd == 2 ? "installed" : "updated", filename);
	else {
		if(settingsPermanent->startupLoadLastLoadedImage && filename == "")
			handleOpenFileEvent(settingsPermanent->startupLoadLastLoadedImageString, "");
		else
			handleOpenFileEvent(filename, "");
	}

}

// Open a new file
void MainWindow::handleOpenFileEvent(QString filename, QString filter) {

	if(filename.startsWith("file:/"))
		filename = filename.remove(0,6);
	if(filename.startsWith("image://full/"))
		filename = filename.remove(0,13);

	if(filename.trimmed() == "") {
		QMetaObject::invokeMethod(object, "openFile");
		return;
	}

	variables->keepLoadingThumbnails = true;

	setOverrideCursor();

	if(variables->verbose)
		LOG << CURDATE << "handleOpenFileEvent(): Handle response to request to open new file" << NL;

	// Decode filename
	QByteArray usethis = QByteArray::fromPercentEncoding(filename.trimmed().toUtf8());

	// Store filter
	variables->openfileFilter = filter;


	QString file = "";

	// Check return file
	file = usethis;

	QMetaObject::invokeMethod(object, "alsoIgnoreSystemShortcuts",
				  Q_ARG(QVariant, false));

	// Save current directory
	variables->currentDir = QFileInfo(file).absolutePath();

	// Clear loaded thumbnails
	variables->loadedThumbnails.clear();

	// Load direcgtory
	QVector<QFileInfo> l = loadDir->loadDir(file,variables->openfileFilter);
	if(l.isEmpty()) {
		QMetaObject::invokeMethod(object, "noResultsFromFilter");
		restoreOverrideCursor();
		return;
	}
	if(!l.contains(QFileInfo(file)))
		file = l.at(0).filePath();

	// Get and store length
	int l_length = l.length();

	// Convert QFileInfoList into QStringList and store it
	QStringList ll;
	for(int i = 0; i < l_length; ++i)
		ll.append(l.at(i).absoluteFilePath());

	// Get and store current position
	int curPos = l.indexOf(QFileInfo(file));

	// Setiup thumbnail model
	QMetaObject::invokeMethod(object, "setupModel",
		Q_ARG(QVariant, ll),
		Q_ARG(QVariant, curPos));

	// Display current postiion in main image view
	QMetaObject::invokeMethod(object, "displayImage",
				  Q_ARG(QVariant, curPos));

	restoreOverrideCursor();

}

bool MainWindow::event(QEvent *e) {

	if(!touchHandler->handle(e) && !touchHandler->isTouchGestureDetecting())
		if(!mouseHandler->handle(e))
			keyHandler->handle(e);

	// update local cursor position
	if(e->type() == QEvent::MouseMove) {
		QPoint pos = ((QMouseEvent*)e)->pos();
		mouseDx += abs(mouseOrigPoint.x()-pos.x());
		mouseDy += abs(mouseOrigPoint.y()-pos.y());
		object->setProperty("localcursorpos",this->mapFromGlobal(QCursor::pos()));
	}

	if (e->type() == QEvent::Close) {

		if(variables->verbose)
			LOG << CURDATE << "closeEvent()" << NL;

		// Hide to system tray (except if a 'quit' was requested)
		if(settingsPermanent->trayicon == 1 && !variables->skipSystemTrayAndQuit) {

			trayAction(QSystemTrayIcon::Trigger);
			if(variables->verbose) LOG << CURDATE << "closeEvent(): Hiding to System Tray." << NL;
			e->ignore();

		// Quit
		} else {

			// Save current geometry
			QFile geo(CFG_MAINWINDOW_GEOMETRY_FILE);
			if(geo.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
				QTextStream out(&geo);
				QRect rect = geometry();
				QString txt = "[General]\n";
				txt += QString("mainWindowGeometry=@Rect(%1 %2 %3 %4)\n").arg(rect.x()).arg(rect.y()).arg(rect.width()).arg(rect.height());
				out << txt;
				geo.close();
			}

			e->accept();

			if(variables->verbose)
				LOG << CURDATE;
			LOG << "Goodbye!" << NL;

			qApp->quit();

		}

	}

	return QQuickWindow::event(e);

}

void MainWindow::trayAction(QSystemTrayIcon::ActivationReason reason) {

	if(variables->verbose)
		LOG << CURDATE << "trayAction()" << NL;

	if(reason == QSystemTrayIcon::Trigger) {

		if(!variables->hiddenToTrayIcon) {
			variables->geometryWhenHiding = this->geometry();
			if(variables->verbose)
				LOG << CURDATE << "trayAction(): Hiding to tray" << NL;
			this->hide();
		} else {

			if(variables->verbose)
				LOG << CURDATE << "trayAction(): Updating screenshots" << NL;

			// Get screenshots
			for(int i = 0; i < QGuiApplication::screens().count(); ++i) {
				QScreen *screen = QGuiApplication::screens().at(i);
				QRect r = screen->geometry();
				QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
				if(!pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i)))
					LOG << CURDATE << "ERROR: Unable to update screenshot for screen #" << i << NL;
			}

			if(variables->verbose)
				LOG << CURDATE << "trayAction(): SHowing window" << NL;

			updateWindowGeometry();

			if(variables->currentDir == "")
				QMetaObject::invokeMethod(object, "openFile");
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
		LOG << CURDATE << "showTrayIcon()" << NL;

	if(settingsPermanent->trayicon != 0) {

		if(!variables->trayiconSetup) {

			if(variables->verbose)
				LOG << CURDATE << "showTrayIcon(): Setting up" << NL;

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
			LOG << CURDATE << "showTrayIcon(): Setting icon to visible" << NL;

		trayIcon->show();
		variables->trayiconVisible = true;

	}

}

void MainWindow::hideTrayIcon() {

	if(variables->verbose)
		LOG << CURDATE << "hideTrayIcon()" << NL;

	if(settingsPermanent->trayicon == 0 && variables->trayiconSetup) {

		trayIcon->hide();
		variables->trayiconVisible = false;

	}

}

// Remote controlling
void MainWindow::remoteAction(QString cmd) {

	if(variables->verbose)
		LOG << CURDATE << "remoteAction(): " << cmd.toStdString() << NL;

	if(cmd == "open") {

		if(variables->verbose)
			LOG << CURDATE << "remoteAction(): Open file" << NL;
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
			this->requestActivate();
		}

		QMetaObject::invokeMethod(object, "openFile");

	} else if(cmd == "nothumbs") {

		if(variables->verbose)
			LOG << CURDATE << "remoteAction(): Disable thumbnails" << NL;
		settingsPermanent->thumbnailDisable = true;
		settingsPermanent->thumbnailDisableChanged(settingsPermanent->thumbnailDisable);

	} else if(cmd == "thumbs") {

		if(variables->verbose)
			LOG << CURDATE << "remoteAction(): Enable thumbnails" << NL;
		settingsPermanent->thumbnailDisable = true;
		settingsPermanent->thumbnailDisableChanged(settingsPermanent->thumbnailDisable);

	} else if(cmd == "hide" || (cmd == "toggle" && this->isVisible())) {

		if(variables->verbose)
			LOG << CURDATE << "remoteAction(): Hiding" << NL;
		if(settingsPermanent->trayicon != 1) {
			settingsPermanent->trayicon = 1;
			settingsPermanent->trayiconChanged(settingsPermanent->trayicon);
		}
		QMetaObject::invokeMethod(object, "hideOpenFile");
		this->hide();

	} else if(cmd.startsWith("show") || (cmd == "toggle" && !this->isVisible())) {

		if(variables->verbose)
			LOG << CURDATE << "remoteAction(): Showing" << NL;

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
		}
		this->raise();
		this->requestActivate();

		if(variables->currentDir == "" && cmd != "show_noopen")
			QMetaObject::invokeMethod(object, "openFile");

	} else if(cmd.startsWith("::file::")) {

		if(variables->verbose)
			LOG << CURDATE << "remoteAction(): Opening passed-on file" << NL;
		QMetaObject::invokeMethod(object, "hideOpenFile");
		handleOpenFileEvent(cmd.remove(0,8));

	}


}

void MainWindow::updateWindowGeometry() {

	// Open PhotoQt on pre-selected screen (if enabled)
	// NOTE: setScreen() currently doesn't seem to work on Linux!!
	if(settingsPermanent->openOnScreen) {
		QList<QScreen *> sc = qApp->screens();
		for(int i = 0; i < sc.length(); ++i) {
			if(sc.at(i)->name() == settingsPermanent->openOnScreenName) {
				this->setScreen(qApp->screens()[1]);
				i = sc.length();
			}
		}
	} else {

		/***************************************/
		// Patch provided by John Morris

		#ifdef Q_OS_MAC
			// If on a Mac, show fullscreen on monitor containing the mouse pointer.
			int screenNum = qApp->desktop()->screenNumber(QCursor::pos());
			this->setScreen(qApp->screens()[screenNum]);
		#endif

		/***************************************/

	}


	if(variables->verbose)
		LOG << CURDATE << "updateWindowGeometry()" << NL;

	if(settingsPermanent->windowmode) {
		if(settingsPermanent->keepOnTop) {
			settingsPermanent->windowDecoration
					  ? this->setFlags(Qt::Window | Qt::WindowStaysOnTopHint)
					  : this->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
		} else {
			settingsPermanent->windowDecoration
					  ? this->setFlags(Qt::Window)
					  : this->setFlags(Qt::Window | Qt::FramelessWindowHint);
		}
#ifndef Q_OS_WIN
		if(settingsPermanent->saveWindowGeometry) {
			QFile geo(CFG_MAINWINDOW_GEOMETRY_FILE);
			if(geo.open(QIODevice::ReadOnly)) {
				QTextStream in(&geo);
				QString all = in.readAll();
				if(all.contains("mainWindowGeometry=@Rect(")) {
					QStringList vars = all.split("mainWindowGeometry=@Rect(").at(1).split(")\n").at(0).split(" ");
					if(vars.length() == 4) {
						this->show();
						this->setGeometry(QRect(vars.at(0).toInt(),vars.at(1).toInt(),vars.at(2).toInt(),vars.at(3).toInt()));
					} else
						this->showMaximized();
				} else
					this->showMaximized();
			} else
				this->showMaximized();
		} else
#endif
			this->showMaximized();
	} else {

		if(settingsPermanent->keepOnTop)
			this->setFlags(Qt::WindowStaysOnTopHint | Qt::FramelessWindowHint);
		else
			this->setFlags(Qt::FramelessWindowHint);

		QString(getenv("DESKTOP")).startsWith("Enlightenment") ? this->showMaximized() : this->showFullScreen();
	}

}

void MainWindow::resetWindowGeometry() {
	if(variables->verbose)
		LOG << CURDATE << "resetWindowGeometry()" << NL;
	QSettings settings("photoqt","photoqt");
	this->setGeometry(settings.value("mainWindowGeometry").toRect());
}

void MainWindow::updateWindowXandY() {

	object->setProperty("windowx",this->x());
	object->setProperty("windowy",this->y());

	QRect rect = this->screen()->geometry();
	int x_cur = this->x()-rect.x();
	int y_cur = this->y()-rect.y();
	object->setProperty("windowx_currentscreen",x_cur < 0 ? this->x() : x_cur);
	object->setProperty("windowy_currentscreen",y_cur < 0 ? this->y() : x_cur);

}

void MainWindow::showStartup(QString type, QString filename) {

	if(variables->verbose)
		LOG << CURDATE << "showStartup(): " << type.toStdString() << NL;

	QMetaObject::invokeMethod(object,"showStartup",
							  Q_ARG(QVariant, type), Q_ARG(QVariant, filename));

}

void MainWindow::qmlVerboseMessage(QString loc, QString msg) {
	if(variables->verbose) {
		LOG << CURDATE << "[QML] " << loc.toStdString();
		if(msg.trimmed() != "") LOG << ": " << msg.toStdString() << NL;
	}
}

MainWindow::~MainWindow() {
	QFile file(CFG_SETTINGS_SESSION_FILE);
	file.remove();
	delete settingsPermanent;
	delete fileformats;
	if(variables->trayiconSetup) delete trayIcon;
	delete variables;
	delete keyHandler;
	delete loadDir;
	delete touchHandler;
}
