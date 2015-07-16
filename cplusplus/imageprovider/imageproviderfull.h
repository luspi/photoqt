#ifndef IMAGEPROVIDERFULL_H
#define IMAGEPROVIDERFULL_H

#include <QQuickImageProvider>
#include <QFileInfo>
#include <QtSvg/QtSvg>
#include "../settings/fileformats.h"
#include "../settings/settings.h"
#include "../logger.h"

#ifdef GM
#include <GraphicsMagick/Magick++/Image.h>
#endif

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

class ImageProviderFull : public QQuickImageProvider {

public:
	explicit ImageProviderFull();
	~ImageProviderFull();

	QImage requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize);

	QSize origSize;

private:
	bool verbose;

	QSize maxSize;
	QSettings *settingsPerSession;
	Settings *settings;
	FileFormats *fileformats;

	QString qtfiles;
	QString gmfiles;
	QString extrasfiles;

	QImage readImage_QT(QString filename);
	QImage readImage_GM(QString filename);
	QImage readImage_XCF(QString filename);

	QString whatDoIUse(QString filename);

};


#endif // IMAGEPROVIDERFULL_H
