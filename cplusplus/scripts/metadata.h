#ifndef EXIV2_H
#define EXIV2_H

#include <QObject>
#include <QMap>
#include <QStringList>
#include <QFileInfo>
#include <QImageReader>
#include <QVariant>
#include <QtDebug>

//#ifdef EXIV2
#include "exiv2/image.hpp"
#include "exiv2/exif.hpp"
//#endif

class GetMetaData : public QObject {

	Q_OBJECT

public:
	explicit GetMetaData(QObject *parent = 0);

	Q_INVOKABLE QVariantMap getExiv2(QString path);

private:
	QMap<QString, QMap<QString,QString> > mapAll;

	QMap<QString,QString> exifKeysValues;
	QMap<QString,QString> units;

	QString exifExposureTime(QString value);
	QString exifFNumberFLength(QString value);
	QString exifPhotoTaken(QString value);
	QStringList exifGps(QString gpsLonRef, QString gpsLon, QString gpsLatRef, QString gpsLat);

signals:
	void hasOrientationStored(int rot, bool flip);

};


#endif // EXIV2_H
