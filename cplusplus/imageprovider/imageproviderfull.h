#ifndef IMAGEPROVIDERFULL_H
#define IMAGEPROVIDERFULL_H

#include <QQuickImageProvider>
#include <iostream>
#include <QFileInfo>
#include <QtSvg/QtSvg>
#include "../settings/settings.h"

#ifdef GM
#include <GraphicsMagick/Magick++/Image.h>
#endif

class ImageProviderFull : public QQuickImageProvider {

public:
	explicit ImageProviderFull();

	QImage requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize);

	QSize origSize;

private:
	bool verbose;

	QSize maxSize;
	QSettings *settingsPerSession;
	Settings settings;

	QString qtfiles;
	QString gmfiles;
	QString extrasfiles;

	QImage readImage_QT(QString filename);
	QImage readImage_GM(QString filename);
	QImage readImage_XCF(QString filename);

	QString whatDoIUse(QString filename);

};


#endif // IMAGEPROVIDERFULL_H
