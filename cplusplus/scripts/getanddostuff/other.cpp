#include "other.h"
#include <QtDebug>

GetAndDoStuffOther::GetAndDoStuffOther(QObject *parent) : QObject(parent) { }
GetAndDoStuffOther::~GetAndDoStuffOther() { }

bool GetAndDoStuffOther::isImageAnimated(QString path) {

	return QMovie::supportedFormats().contains(QFileInfo(path).suffix().toLower().toLatin1());

}

QSize GetAndDoStuffOther::getAnimatedImageSize(QString path) {

	path = path.remove("image://full/");
	path = path.remove("file://");

	if(path.trimmed() == "") {
		std::cout << "empty...";
		return QSize();
	}

	QImageReader reader(path);
	return reader.size();

}

QPoint GetAndDoStuffOther::getGlobalCursorPos() {

	return QCursor::pos();

}

QColor GetAndDoStuffOther::addAlphaToColor(QString col, int alpha) {

	if(col.length() == 9) {

		col = col.remove(0,3);

		bool ok;
		int red = (QString(col.at(0)) + QString(col.at(1))).toUInt(&ok,16);
		int green = (QString(col.at(2)) + QString(col.at(3))).toUInt(&ok,16);
		int blue = (QString(col.at(4)) + QString(col.at(5))).toUInt(&ok,16);

		return QColor(red, green, blue, alpha);

	} else if(col.length() == 7) {

		col = col.remove(0,1);

		bool ok;
		int red = (QString(col.at(0)) + QString(col.at(1))).toUInt(&ok,16);
		int green = (QString(col.at(2)) + QString(col.at(3))).toUInt(&ok,16);
		int blue = (QString(col.at(4)) + QString(col.at(5))).toUInt(&ok,16);

		return QColor(red, green, blue, alpha);

	} else
		return QColor(col);

}

bool GetAndDoStuffOther::amIOnLinux() {
#ifdef Q_OS_LINUX
	return true;
#else
	return false;
#endif
}

bool GetAndDoStuffOther::amIOnWindows() {
#ifdef Q_OS_WIN
	return true;
#else
	return false;
#endif
}

int GetAndDoStuffOther::getCurrentScreen(int x, int y) {

	for(int i = 0; i < QGuiApplication::screens().count(); ++i)
		if(QGuiApplication::screens().at(i)->geometry().contains(x,y))
			return i;

	return 0;

}

QString GetAndDoStuffOther::getTempDir() {
	return QDir::tempPath();
}

QString GetAndDoStuffOther::getHomeDir() {
	return QDir::homePath();
}

QString GetAndDoStuffOther::getDesktopDir() {
	QStringList loc = QStandardPaths::standardLocations(QStandardPaths::DesktopLocation);
	if(loc.length() == 0)
		return "";
	return loc.first();
}

QString GetAndDoStuffOther::getPicturesDir() {
	QStringList loc = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
	if(loc.length() == 0)
		return "";
	return loc.first();
}

QString GetAndDoStuffOther::getDownloadsDir() {
	QStringList loc = QStandardPaths::standardLocations(QStandardPaths::DownloadLocation);
	if(loc.length() == 0)
		return "";
	return loc.first();
}

QString GetAndDoStuffOther::getRootDir() {
	return QDir::rootPath();
}

bool GetAndDoStuffOther::isExivSupportEnabled() {
#ifdef EXIV2
	return true;
#endif
	return false;
}

bool GetAndDoStuffOther::isGraphicsMagickSupportEnabled() {
#ifdef GM
	return true;
#endif
	return false;
}

bool GetAndDoStuffOther::isLibRawSupportEnabled() {
#ifdef RAW
	return true;
#endif
	return false;
}

QString GetAndDoStuffOther::getVersionString() {
	return VERSION;
}
