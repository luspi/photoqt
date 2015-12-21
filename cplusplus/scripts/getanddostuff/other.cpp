#include "other.h"

GetAndDoStuffOther::GetAndDoStuffOther(QObject *parent) : QObject(parent) { }
GetAndDoStuffOther::~GetAndDoStuffOther() { }

bool GetAndDoStuffOther::isImageAnimated(QString path) {

	return QMovie::supportedFormats().contains(QFileInfo(path).suffix().toLower().toLatin1());

}

QSize GetAndDoStuffOther::getImageSize(QString path) {

	path = path.remove("image://full/");
	path = path.remove("file://");
	path = QUrl::fromPercentEncoding(path.toLatin1());

	if(path.trimmed() == "")
		return QSize(-1,-1);

	if(reader.supportedImageFormats().contains(QFileInfo(path).suffix().toLower().toLatin1())) {
		reader.setFileName(path);
		return reader.size();
	} else {

#ifdef GM
		QFile file(path);
		if(!file.open(QIODevice::ReadOnly)) {
			LOG << DATE << "getanddostuff > getImageSize GM - ERROR opening file, returning empty image (" << path.toStdString() << ")" << std::endl;
			return QSize(-1,-1);
		}
		char *data = new char[file.size()];
		qint64 s = file.read(data, file.size());
		if (s == -1) {
			delete[] data;
			LOG << DATE << "getanddostuff > getImageSize GM - ERROR reading image file data" << std::endl;
			return QSize(1024,768);
		}
		Magick::Blob blob(data, file.size());
		try {
			Magick::Image image;
			image = imagemagick.setImageMagick(image, QFileInfo(path).suffix().toLower());
			image.ping(blob);
			Magick::Geometry geo = image.size();
			QSize s = QSize(geo.width(),geo.height());
			if(s.width() < 2 && s.height() < 2)
				return QSize(1024,768);
			return s;
		} catch(Magick::Exception &error_) {
			delete[] data;
			LOG << DATE << "getanddostuff > getImageSize GM - Error: " << error_.what() << std::endl;
			reader.setFileName(QDir::tempPath() + "/photoqt_tmp.png");
			return reader.size();
		}

#else
		return QSize();
#endif

	}

}

QPoint GetAndDoStuffOther::getGlobalCursorPos() {

	return QCursor::pos();

}

QColor GetAndDoStuffOther::addAlphaToColor(QString col, int alpha) {

	if(col.length() == 7) {

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
