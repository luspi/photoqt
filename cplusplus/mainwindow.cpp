#include "mainwindow.h"

MainWindow::MainWindow(QWindow *parent) : QQuickView(parent) {

	// Settings and variables
	settingsPerSession = new QSettings("photoqt_session");
	settingsPermanent = new Settings;
	variables = new Variables;

	// Add image providers
	this->engine()->addImageProvider("thumb",new ImageProviderThumbnail);
	this->engine()->addImageProvider("full",new ImageProviderFull);

	// Add settings access to QML
	qmlRegisterType<Settings>("my.settings", 1, 0, "Settings");

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

	// Quit PhotoQt
	connect(this->engine(), SIGNAL(quit()), qApp, SLOT(quit()));

	// We have to call it with a timer to ensure the window is actually visible first
	QTimer::singleShot(100, this, SLOT(openNewFile()));

}

// Window has been resized
void MainWindow::resized() {

	settingsPerSession->setValue("curSize",QSize(this->width(),this->height()));

	QMetaObject::invokeMethod(object, "resizeElements",
		Q_ARG(QVariant, this->width()),
		Q_ARG(QVariant, this->height()));

}

// Open a new file
void MainWindow::openNewFile() {

	// Get new filename
	QByteArray file = QFileDialog::getOpenFileName(0,tr("Open image file"),QDir::homePath(),tr("All Files") + " (*)").toUtf8();

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

	// Setiup thumbnail model
	QMetaObject::invokeMethod(object, "setupModel",
		Q_ARG(QVariant, ll));

	// Get and store current position
	int curPos = l.indexOf(QFileInfo(file));
	settingsPerSession->setValue("curPos",curPos);

	// Display current postiion in main image view
	QMetaObject::invokeMethod(object, "displayImage",
				  Q_ARG(QVariant, curPos));

	// And handle the thumbnails
	handleThumbnails(curPos);

}

// Thumbnail handling (centerPos is image currently displayed in the visible center of thumbnail bar)
void MainWindow::handleThumbnails(QVariant centerPos) {

	// Get some settings for later use
	int thumbSize = settingsPermanent->value("Thumbnail/ThumbnailSize").toInt();
	int thumbSpacing = settingsPermanent->value("Thumbnail/ThumbnailSpacingBetween").toInt();
	int dynamicSmartNormal = settingsPermanent->value("Thumbnail/ThumbnailDynamic").toInt();

	// Get total and center pos
	int countTot = settingsPerSession->value("countTot").toInt();
	int center = centerPos.toInt();

	// Generate how many to each side
	int numberToOneSide = (this->width()/(thumbSize+thumbSpacing))/2;

	// Load full directory
	if(dynamicSmartNormal == 0) numberToOneSide = qMax(center,countTot-center);

	// Load thumbnails (we start at the screen edge working towards the center, cause QML starts with the latest one changed)
	for(int i = numberToOneSide+3; i >= 1; --i) {
		if(center-i >= 0 && !variables->loadedThumbnails.contains(center-i)) {
			QMetaObject::invokeMethod(object, "reloadImage",
						Q_ARG(QVariant, center-i));
			variables->loadedThumbnails.append(center-i);
		}
		if(center+i < countTot && !variables->loadedThumbnails.contains(center+i)) {
			QMetaObject::invokeMethod(object, "reloadImage",
						Q_ARG(QVariant, center+i));
			variables->loadedThumbnails.append(center+i);
		}
	}
	// The first image to be loaded should be the central image
	if(!variables->loadedThumbnails.contains(center)) {
		QMetaObject::invokeMethod(object, "reloadImage",
					Q_ARG(QVariant, center));
		variables->loadedThumbnails.append(center);
	}

	// In 'smart thumbnails' mode we load all other visible thumbnails after the currently visible ones are loaded
	if(dynamicSmartNormal == 2)
		smartLoadDirectory();

}

void MainWindow::smartLoadDirectory() {

	// TO-DO

}

MainWindow::~MainWindow() { }
