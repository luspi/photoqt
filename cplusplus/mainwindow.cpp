#include "mainwindow.h"

MainWindow::MainWindow(QWindow *parent) : QQuickView(parent) {

	// Settings and variables
	settingsPerSession = new SettingsSession;
	settingsPermanent = new Settings;
	fileformats = new FileFormats;
	variables = new Variables;

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
	this->setFlags(Qt::FramelessWindowHint | Qt::Window);

	// Get object (for signals and stuff)
	object = this->rootObject();

	// Class to load a new directory
	loadDir = new LoadDir;

	// Window resized
	connect(this, SIGNAL(widthChanged(int)), this, SLOT(resized()));
	connect(this, SIGNAL(heightChanged(int)), this, SLOT(resized()));

	// Scrolled view
	connect(object, SIGNAL(thumbScrolled(QVariant)), this, SLOT(handleThumbnails(QVariant)));

	// Open file
	connect(object, SIGNAL(openFile()), this, SLOT(openNewFile()));

	connect(object, SIGNAL(loadMoreThumbnails()), this, SLOT(loadMoreThumbnails()));
	connect(object, SIGNAL(didntLoadThisThumbnail(QVariant)), this, SLOT(didntLoadThisThumbnail(QVariant)));

	// Quit PhotoQt
	connect(this->engine(), SIGNAL(quit()), qApp, SLOT(quit()));

}

// Window has been resized
void MainWindow::resized() {

	settingsPerSession->setValue("curSize",QSize(this->width(),this->height()));

	QMetaObject::invokeMethod(object, "resizeElements",
		Q_ARG(QVariant, this->width()),
		Q_ARG(QVariant, this->height()));

}

// Open a new file
void MainWindow::openNewFile(QString usethis) {

	// Get new filename
	QString opendir = QDir::homePath();
	if(variables->currentDir != "")
		opendir = variables->currentDir;

	QByteArray file = usethis.toUtf8();

	if(usethis == "") {

		// Get new filename
		QString knownQT = fileformats->formatsQtEnabled.join(" ") + " " + fileformats->formatsQtEnabledExtras.join(" ");
		QString knownGM = fileformats->formatsGmEnabled.join(" ");
		QString known = knownQT + " " + knownGM + " " + fileformats->formatsExtrasEnabled.join(" ");
		// FileDialog is unresponsive with the DontUseNativeDialog option in Qt 5.4.1
		file = QFileDialog::getOpenFileName(NULL,tr("Open image file"),opendir,tr("Images") + " (" + known.trimmed() + ");;"
										+ tr("Images") + " (Qt)" + " (" + knownQT.trimmed() + ");;"
						 #ifdef GM
										+ tr("Images") + " (GraphicsMagick)" + " (" + knownGM.trimmed() + ");;"
						 #endif

#if (QT_VERSION == QT_VERSION_CHECK(5, 4, 1))
										+ tr("All Files") + " (*)",0,QFileDialog::DontUseNativeDialog).toUtf8();
#else
										+ tr("All Files") + " (*)").toUtf8();
#endif
	}

	if(file.trimmed() == "") return;

	// Clear loaded thumbnails
	variables->loadedThumbnails.clear();

	// Load direcgtory
	QFileInfoList l = loadDir->loadDir(file);

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

	if(loadThumbnailsInThisOrder.length() == 0 && smartLoadThumbnailsInThisOrder.length() == 0) return;

	if(loadThumbnailsInThisOrder.length() != 0) {

		int load = loadThumbnailsInThisOrder.first();

		if(variables->loadedThumbnails.contains(load)) {
			loadThumbnailsInThisOrder.removeFirst();
			return loadMoreThumbnails();
		}

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

		smartLoadThumbnailsInThisOrder.removeFirst();

		QMetaObject::invokeMethod(object, "reloadImage",
					  Q_ARG(QVariant, load),
					  Q_ARG(QVariant, true));
		variables->loadedThumbnails.append(load);
	}

}

// This one was tried to be preloaded smartly, but didn't exist yet -> nothing done
void MainWindow::didntLoadThisThumbnail(QVariant pos) {
	variables->loadedThumbnails.removeAt(variables->loadedThumbnails.indexOf(pos.toInt()));
}

MainWindow::~MainWindow() { }
