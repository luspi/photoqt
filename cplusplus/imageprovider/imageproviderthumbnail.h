#ifndef IMAGEPROVIDERTHUMBS_H
#define IMAGEPROVIDERTHUMBS_H

#include <QQuickImageProvider>
#include <QtSql/QtSql>
#include <QPainter>
#include <QTextDocument>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include "../settings/settings.h"

#include "imageproviderfull.h"

class ImageProviderThumbnail : public QQuickImageProvider {

public:
	explicit ImageProviderThumbnail();
	~ImageProviderThumbnail();

	QPixmap requestPixmap(const QString &filename_encoded, QSize *size, const QSize &requestedSize);

private:
	QSqlDatabase db;
	Settings *settings;

	QImage getThumbnailImage(QByteArray filename);

	bool dbTransactionStarted;
	bool dontCreateThumbnailNew;

	QHash<QString,QSize> allSizes;

	int origwidth;
	int origheight;

};

#endif // IMAGEPROVIDERTHUMBS_H
