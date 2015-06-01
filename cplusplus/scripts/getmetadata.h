#ifndef GETMETADATA_H
#define GETMETADATA_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QVariantMap>
#include <QUrl>
#include <QImageReader>

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

class GetMetaData : public QObject {

	Q_OBJECT

public:
	explicit GetMetaData(QObject *parent = 0);

	Q_INVOKABLE QVariantMap getExiv2(QString path);

private:
	QString exifExposureTime(QString value);
	QString exifFNumberFLength(QString value);
	QString exifPhotoTaken(QString value);

	QString exifLightSource(QString value);
	QString exifFlash(QString value);
	QString exifSceneType(QString value);

	QStringList exifGps(QString gpsLonRef, QString gpsLon, QString gpsLatRef, QString gpsLat);

};


#endif // GETMETADATA_H
