#include "getstuff.h"
#include <QtDebug>
#include <QUrl>

GetStuff::GetStuff(QObject *parent) : QObject(parent) {
	settings = new QSettings("photoqt_session");
}

bool GetStuff::isImageAnimated(QString path) {

	if(!reader.supportedImageFormats().contains(QFileInfo(path).suffix().toLower().toLatin1()))
		return false;

	reader.setFileName(path);
	return reader.supportsAnimation();

}

QSize GetStuff::getImageSize(QString path) {

	path = path.remove("image://full/");
	path = QUrl::fromPercentEncoding(path.toLatin1());

	if(reader.supportedImageFormats().contains(QFileInfo(path).suffix().toLower().toLatin1())) {
		reader.setFileName(path);
		return reader.size();
	} else {

		Magick::Image image;
		image.read(path.toStdString());
		Magick::Geometry geo = image.size();
		QSize s = QSize(geo.width(),geo.height());
		if(s.width() < 2 && s.height() < 2)
			return settings->value("curSize").toSize();

	}

}

QPoint GetStuff::getCursorPos() {

	return QCursor::pos();

}
