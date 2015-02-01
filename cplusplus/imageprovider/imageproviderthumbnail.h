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

	QImage getThumbnailImage(QByteArray filename, int thbsize);

	bool dbTransactionStarted;

	QHash<QString,QSize> allSizes;

};

#endif // IMAGEPROVIDERTHUMBS_H
