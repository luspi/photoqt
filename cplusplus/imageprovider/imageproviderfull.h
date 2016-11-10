#ifndef IMAGEPROVIDERFULL_H
#define IMAGEPROVIDERFULL_H

#include <QQuickImageProvider>
#include <QFileInfo>
#include <QtSvg/QtSvg>
#include "pixmapcache.h"
#include "../settings/fileformats.h"
#include "../settings/settings.h"
#include "../logger.h"

#include "loader/loadimage_qt.h"
#include "loader/loadimage_gm.h"
#include "loader/loadimage_xcf.h"
#include "loader/loadimage_raw.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#include "../scripts/gmimagemagick.h"
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
	QString rawfiles;

	LoadImageGM *loaderGM;
	LoadImageQt *loaderQT;
	LoadImageRaw *loaderRAW;
	LoadImageRaw *loaderXCF;

	QCache<QByteArray,QPixmap> *pixmapcache;


	QString whatDoIUse(QString filename);

#ifdef GM
	GmImageMagick imagemagick;
#endif

	QByteArray getUniqueCacheKey(QString path);

};


#endif // IMAGEPROVIDERFULL_H
