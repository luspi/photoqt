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
		return s;

	}

}

QPoint GetStuff::getCursorPos() {

	return QCursor::pos();

}

QString GetStuff::removePathFromFilename(QString path) {

	return QFileInfo(path).fileName();

}

QColor GetStuff::addAlphaToColor(QString col, int alpha) {

	col = col.remove(0,1);

	bool ok;
	int red = (QString(col.at(0)) + QString(col.at(1))).toUInt(&ok,16);
	int green = (QString(col.at(2)) + QString(col.at(3))).toUInt(&ok,16);
	int blue = (QString(col.at(4)) + QString(col.at(5))).toUInt(&ok,16);

	qDebug() << col << " - " << red << " - " << green << " - " << blue << " - " << alpha;

	return QColor(red, green, blue, alpha);

}

QString GetStuff::getFilenameQtImage() {

	return QFileDialog::getOpenFileName(0,"Please select image file",QDir::homePath());

}
