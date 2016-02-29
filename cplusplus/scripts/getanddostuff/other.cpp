#include "other.h"
#include <QtDebug>

GetAndDoStuffOther::GetAndDoStuffOther(QObject *parent) : QObject(parent) { }
GetAndDoStuffOther::~GetAndDoStuffOther() { }

bool GetAndDoStuffOther::isImageAnimated(QString path) {

	return QMovie::supportedFormats().contains(QFileInfo(path).suffix().toLower().toLatin1());

}

QSize GetAndDoStuffOther::getImageSize(QString path) {

	path = path.remove("image://full/");
	path = path.remove("file://");

	if(path.trimmed() == "") {
		std::cout << "empty...";
		return QSize();
	}

	QFile file(QString(CACHE_DIR) + "/imagesizes");
	if(file.open(QIODevice::ReadOnly)) {

		QTextStream in(&file);
		QString all = in.readAll();

		if(all.contains(path + "=")) {
			QStringList s = all.split(path + "=").at(1).split("\n").at(0).split("x");
			qDebug() << s;
			return QSize(s.at(0).toInt(), s.at(1).toInt());
		}

		return QSize();

	}

	return QSize();

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

QString GetAndDoStuffOther::getVersionString() {
	return VERSION;
}
