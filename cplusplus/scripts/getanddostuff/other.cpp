#include "other.h"

GetAndDoStuffOther::GetAndDoStuffOther(QObject *parent) : QObject(parent) { }
GetAndDoStuffOther::~GetAndDoStuffOther() { }

bool GetAndDoStuffOther::isImageAnimated(QString path) {

	return QMovie::supportedFormats().contains(QFileInfo(path).suffix().toLower().toLatin1());

}

QSize GetAndDoStuffOther::getImageSize(QString path) {

	path = path.remove("image://full/");
	path = QUrl::fromPercentEncoding(path.toLatin1());

	if(reader.supportedImageFormats().contains(QFileInfo(path).suffix().toLower().toLatin1())) {
		reader.setFileName(path);
		return reader.size();
	} else {

#ifdef GM
		Magick::Image image;
		image.read(path.toStdString());
		Magick::Geometry geo = image.size();
		QSize s = QSize(geo.width(),geo.height());
		if(s.width() < 2 && s.height() < 2)
			return QSize(1024,768);
		return s;
#else
		return QSize();
#endif

	}

}

QPoint GetAndDoStuffOther::getCursorPos() {

	QPoint p = QCursor::pos();

	// Find the values taken away from x/y coordinates to make the point local to screen
	int sub_x = 0;
	int sub_y = 0;
	for(int i = 0; i < QGuiApplication::screens().count(); ++i) {
		if(QGuiApplication::screens().at(i)->geometry().contains(p.x(),p.y())) {
			sub_x = QGuiApplication::screens().at(i)->geometry().x();
			sub_y = QGuiApplication::screens().at(i)->geometry().y();
		}
	}

	// Return "corrected" point
	return QPoint(p.x()-sub_x,p.y()-sub_y);

}

QPoint GetAndDoStuffOther::getGlobalCursorPos() {

	return QCursor::pos();

}

QColor GetAndDoStuffOther::addAlphaToColor(QString col, int alpha) {

	col = col.remove(0,1);

	bool ok;
	int red = (QString(col.at(0)) + QString(col.at(1))).toUInt(&ok,16);
	int green = (QString(col.at(2)) + QString(col.at(3))).toUInt(&ok,16);
	int blue = (QString(col.at(4)) + QString(col.at(5))).toUInt(&ok,16);

	return QColor(red, green, blue, alpha);

}

bool GetAndDoStuffOther::amIOnLinux() {
#ifdef Q_OS_LINUX
	return true;
#else
	return false;
#endif
}

int GetAndDoStuffOther::getCurrentScreen(int x, int y) {

	for(int i = 0; i < QGuiApplication::screens().count(); ++i)
		if(QGuiApplication::screens().at(i)->geometry().contains(x,y))
			return i;

}

QString GetAndDoStuffOther::getTempDir() {
	return QDir::tempPath();
}

QString GetAndDoStuffOther::getHomeDir() {
	return QDir::homePath();
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
