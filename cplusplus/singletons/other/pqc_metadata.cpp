/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <pqc_metadata.h>

#include <pqc_filefoldermodelCPP.h>
#include <pqc_location.h>
#include <scripts/pqc_scriptsmetadata.h>
#include <pqc_configfiles.h>

#include <QFileInfo>
#include <QtDebug>
#include <QPointF>
#include <QTimer>

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCMetaData::PQCMetaData(QObject *parent) : QObject(parent) {

    loadDelay = new QTimer;
    loadDelay->setInterval(500);
    loadDelay->setSingleShot(true);

    m_validFile = true;
    m_fileSize = 0;

    m_exifMake = "";
    m_exifModel = "";
    m_exifSoftware = "";

    m_exifDateTimeOriginal = "";
    m_exifExposureTime = "";
    m_exifFlash = "";
    m_exifISOSpeedRatings = "";
    m_exifSceneCaptureType = "";
    m_exifFocalLength = "";
    m_exifFNumber = "";
    m_exifLightSource = "";
    m_exifPixelXDimension = "";
    m_exifPixelYDimension = "";

    m_exifGPS = "";

    m_iptcKeywords = "";
    m_iptcLocation = "";
    m_iptcCopyright = "";

    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::currentIndexChanged, loadDelay, [=, this](){loadDelay->start(); });
    connect(loadDelay, &QTimer::timeout, this, [=, this]() { updateMetadata(); });

}

void PQCMetaData::setEmptyData() {

    setExifMake("");
    setExifModel("");
    setExifSoftware("");
    setExifDateTimeOriginal("");
    setExifExposureTime("");
    setExifFlash("");
    setExifISOSpeedRatings("");
    setExifSceneCaptureType("");
    setExifFocalLength("");
    setExifFNumber("");
    setExifLightSource("");
    setExifPixelXDimension("");
    setExifPixelYDimension("");
    setExifGPS("");
    setIptcKeywords("");
    setIptcLocation("");
    setIptcCopyright("");

}

void PQCMetaData::updateMetadata() {

    qDebug() << "";

    // we always start with empty data fields
    setEmptyData();

    // make sure a currentIndex is set
    if(PQCFileFolderModelCPP::get().getCurrentIndex() == -1)
        return;

    QString path = PQCFileFolderModelCPP::get().getEntriesMainView()[PQCFileFolderModelCPP::get().getCurrentIndex()];

    if(path == "") {
        setValidFile(true);
        setFileSize(0);
        return;
    }

    if(path.contains("::PDF::"))
        path = path.split("::PDF::").at(1);
    if(path.contains("::ARC::"))
        path = path.split("::ARC::").at(1);

    QFileInfo info(path);

    if(!QFile(path).exists()) {

        qWarning() << "ERROR: File does not exist";

        setValidFile(false);

        return;

    }

    setValidFile(true);

    setFileSize(info.size());

#ifdef PQMEXIV2

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif
    try {
        image  = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of kerFileContainsUnknownImageType (older version: 11) means unknown file type \
        // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
        if(e.code() != 11)
#endif
            qWarning() << "ERROR reading exiv data (caught exception):" << e.what();
        else
            qDebug() << "ERROR reading exiv data (caught exception):" << e.what();

        return;
    }

    Exiv2::ExifData exifData;

    try {
        exifData = image->exifData();
    } catch(Exiv2::Error &e) {
        qDebug() << "ERROR: Unable to read exif metadata:" << e.what();
        return;
    }

    QString gpsLatRef = "", gpsLat = "", gpsLonRef = "", gpsLon = "";

    Exiv2::ExifData::const_iterator end = exifData.end();
    for (Exiv2::ExifData::const_iterator i = exifData.begin(); i != end; ++i) {

        const QString key = QString::fromStdString(i->key());
        const QString val = QString::fromStdString(Exiv2::toString(i->value()));

        if(key == "Exif.Image.Make")
            setExifMake(val);

        else if(key == "Exif.Image.Model")
            setExifModel(val);

        else if(key == "Exif.Image.Software")
            setExifSoftware(val);

        else if(key == "Exif.Photo.DateTimeOriginal")
            setExifDateTimeOriginal(PQCScriptsMetaData::get().analyzeDateTimeOriginal(val));

        else if(key == "Exif.Photo.ExposureTime")
            setExifExposureTime(PQCScriptsMetaData::get().analyzeExposureTime(val));

        else if(key == "Exif.Photo.Flash")
            setExifFlash(PQCScriptsMetaData::get().analyzeFlash(val));

        else if(key == "Exif.Photo.ISOSpeedRatings")
            setExifISOSpeedRatings(val);

        else if(key == "Exif.Photo.SceneCaptureType")
            setExifSceneCaptureType(PQCScriptsMetaData::get().analyzeSceneCaptureType(val));

        else if(key == "Exif.Photo.FocalLength")
            setExifFocalLength(PQCScriptsMetaData::get().analyzeFocalLength(val));

        else if(key == "Exif.Photo.FNumber")
            setExifFNumber(PQCScriptsMetaData::get().analyzeFNumber(val));

        else if(key == "Exif.Photo.LightSource")
            setExifLightSource(PQCScriptsMetaData::get().analyzeLightSource(val));

        else if(key == "Exif.Photo.PixelXDimension")
            setExifPixelXDimension(val);

        else if(key == "Exif.Photo.PixelYDimension")
            setExifPixelYDimension(val);

        else if(key == "Exif.GPSInfo.GPSLatitudeRef")
            gpsLatRef = val;

        else if(key == "Exif.GPSInfo.GPSLatitude")
            gpsLat = val;

        else if(key == "Exif.GPSInfo.GPSLongitudeRef")
            gpsLonRef = val;

        else if(key == "Exif.GPSInfo.GPSLongitude")
            gpsLon = val;

    }

    if(gpsLatRef != "" && gpsLat != "" && gpsLonRef != "" && gpsLon != "") {
        PQCLocation::get().storeLocation(path, PQCScriptsMetaData::get().convertGPSToDecimal(gpsLatRef, gpsLat, gpsLonRef, gpsLon));
        setExifGPS(PQCScriptsMetaData::get().analyzeGPS(gpsLatRef, gpsLat, gpsLonRef, gpsLon));
    }


    Exiv2::IptcData iptcData;

    try {
        iptcData = image->iptcData();
    } catch(Exiv2::Error &e) {
        qDebug() << "ERROR: Unable to read iptc metadata:" << e.what();
        return;
    }

    QString city = "", country = "";

    Exiv2::IptcData::const_iterator iptcEnd = iptcData.end();
    for (Exiv2::IptcData::const_iterator i = iptcData.begin(); i != iptcEnd; ++i) {

        const QString key = QString::fromStdString(i->key());
        const QString val = QString::fromStdString(Exiv2::toString(i->value()));

        if(key == "Iptc.Application2.Keywords")
            setIptcKeywords(val);

        else if(key == "Iptc.Application2.City")
            city = val;

        else if(key == "Iptc.Application2.CountryName")
            country = val;

        else if(key == "Iptc.Application2.Copyright")
            setIptcCopyright(val);

    }

    if(city != "" && country != "")
        setIptcLocation(city + ", " + country);
    else if(city != "")
        setIptcLocation(city);
    else
        setIptcLocation(country);

#endif

}
