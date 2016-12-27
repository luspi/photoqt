/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef GETMETADATA_H
#define GETMETADATA_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QVariantMap>
#include <QUrl>
#include <QImageReader>

#include "../logger.h"

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
