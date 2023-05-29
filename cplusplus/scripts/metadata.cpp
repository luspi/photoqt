/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "metadata.h"

PQMetaData::PQMetaData(QObject *parent) : QObject(parent) {

    m_validFile = true;
    m_fileSize = 0;

    m_exifImageMake = "";
    m_exifImageModel = "";
    m_exifImageSoftware = "";

    m_exifPhotoDateTimeOriginal = "";
    m_exifPhotoExposureTime = "";
    m_exifPhotoFlash = "";
    m_exifPhotoISOSpeedRatings = "";
    m_exifPhotoSceneCaptureType = "";
    m_exifPhotoFocalLength = "";
    m_exifPhotoFNumber = "";
    m_exifPhotoLightSource = "";
    m_exifPhotoPixelXDimension = "";
    m_exifPhotoPixelYDimension = "";

    m_exifGPS = "";

    m_iptcApplication2Keywords = "";
    m_iptcLocation = "";
    m_iptcApplication2Copyright = "";

}

void PQMetaData::setEmptyExivData() {

    setExifImageMake("");
    setExifImageModel("");
    setExifImageSoftware("");
    setExifPhotoDateTimeOriginal("");
    setExifPhotoExposureTime("");
    setExifPhotoFlash("");
    setExifPhotoISOSpeedRatings("");
    setExifPhotoSceneCaptureType("");
    setExifPhotoFocalLength("");
    setExifPhotoFNumber("");
    setExifPhotoLightSource("");
    setExifPhotoPixelXDimension("");
    setExifPhotoPixelYDimension("");
    setExifGPS("");
    setIptcApplication2Keywords("");
    setIptcLocation("");
    setIptcApplication2Copyright("");

}

void PQMetaData::updateMetadata(QString path) {

    DBG << CURDATE << "PQMetaData::updateMetadata()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    if(path == "") {
        setValidFile(true);
        setFileSize(0);
        setEmptyExivData();
        return;
    }

    if(path.contains("::PQT::"))
        path = path.split("::PQT::").at(1);
    if(path.contains("::ARC::"))
        path = path.split("::ARC::").at(1);

    QFileInfo info(path);

    if(!QFile(path).exists()) {

        LOG << CURDATE << "PQMetaData::updateMetadata(): ERROR: File does not exist" << NL;

        setValidFile(false);

        return;

    }

    setValidFile(true);

    setFileSize(info.size());

#ifdef EXIV2

    // Obtain METADATA

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif
    try {
        image  = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means unknown file type
        // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerUnsupportedImageType)
#else
        if(e.code() != 11)
#endif
            LOG << CURDATE << "PQMetaData::updateMetadaya(): ERROR reading exiv data (caught exception): " << e.what() << NL;
        else
            DBG << CURDATE << "PQMetaData::updateMetadaya(): ERROR reading exiv data (caught exception): " << e.what() << NL;
        setEmptyExivData();
        return;
    }


    /*******************
    * Obtain EXIF data *
    ********************/

    Exiv2::ExifData exifData;

    try {
        exifData = image->exifData();
    } catch(Exiv2::Error &e) {
        LOG << CURDATE << "PQMetaData::updateMetaData(): ERROR: Unable to read exif metadata: " << e.what() << NL;
        setEmptyExivData();
        return;
    }


    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Image.Make"));
        if(iter != exifData.end())
            setExifImageMake(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setExifImageMake("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifImageMake("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Image.Model"));
        if(iter != exifData.end())
            setExifImageModel(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setExifImageModel("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifImageModel("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Image.Software"));
        if(iter != exifData.end())
            setExifImageSoftware(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setExifImageSoftware("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifImageSoftware("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.DateTimeOriginal"));
        if(iter != exifData.end())
            setExifPhotoDateTimeOriginal(analyzeDateTimeOriginal(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoDateTimeOriginal("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoDateTimeOriginal("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.ExposureTime"));
        if(iter != exifData.end())
            setExifPhotoExposureTime(analyzeExposureTime(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoExposureTime("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoExposureTime("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.Flash"));
        if(iter  != exifData.end())
            setExifPhotoFlash(analyzeFlash(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoFlash("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoFlash("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.ISOSpeedRatings"));
        if(iter != exifData.end())
            setExifPhotoISOSpeedRatings(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setExifPhotoISOSpeedRatings("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoISOSpeedRatings("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.SceneCaptureType"));
        if(iter != exifData.end())
            setExifPhotoSceneCaptureType(analyzeSceneCaptureType(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoSceneCaptureType("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoSceneCaptureType("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.FocalLength"));
        if(iter != exifData.end())
            setExifPhotoFocalLength(analyzeFocalLength(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoFocalLength("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoFocalLength("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.FNumber"));
        if(iter != exifData.end())
            setExifPhotoFNumber(analyzeFNumber(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoFNumber("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoFNumber("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.LightSource"));
        if(iter != exifData.end())
            setExifPhotoLightSource(analyzeLightSource(QString::fromStdString(Exiv2::toString(iter->value()))));
        else
            setExifPhotoLightSource("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoLightSource("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.PixelXDimension"));
        if(iter != exifData.end())
            setExifPhotoPixelXDimension(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setExifPhotoPixelXDimension("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoPixelXDimension("");
    }

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.PixelYDimension"));
        if(iter != exifData.end())
            setExifPhotoPixelYDimension(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setExifPhotoPixelYDimension("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setExifPhotoPixelYDimension("");
    }


    QString gpsLatRef = "", gpsLat = "", gpsLonRef = "", gpsLon = "";

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLatitudeRef"));
        if(iter != exifData.end())
            gpsLatRef = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLatitude"));
        if(iter != exifData.end())
            gpsLat = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLongitudeRef"));
        if(iter != exifData.end())
            gpsLonRef = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLongitude"));
        if(iter != exifData.end())
            gpsLon = QString::fromStdString(Exiv2::toString(iter->value()));
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
    }

    if(gpsLatRef != "" && gpsLat != "" && gpsLonRef != "" && gpsLon != "")
        setExifGPS(analyzeGPS(gpsLatRef, gpsLat, gpsLonRef, gpsLon));
    else
        setExifGPS("");


    /*******************
    * Obtain IPTC data *
    ********************/

    Exiv2::IptcData iptcData;

    try {
        iptcData = image->iptcData();
    } catch(Exiv2::Error &e) {
        LOG << CURDATE << "PQMetaData::updateMetaData(): ERROR: Unable to read iptc metadata: " << e.what() << NL;
    }

    try {
        Exiv2::IptcMetadata::const_iterator iter = iptcData.findKey(Exiv2::IptcKey("Iptc.Application2.Keywords"));
        if(iter != iptcData.end())
            setIptcApplication2Keywords(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setIptcApplication2Keywords("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
        setIptcApplication2Keywords("");
    }


    QString city = "", country = "";

    try {
        Exiv2::IptcMetadata::const_iterator iter = iptcData.findKey(Exiv2::IptcKey("Iptc.Application2.City"));
        if(iter != iptcData.end())
            city = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = iptcData.findKey(Exiv2::IptcKey("Iptc.Application2.CountryName"));
        if(iter != iptcData.end())
            country = QString::fromStdString(Exiv2::toString(iter->value()));
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
    }

    if(city != "" && country != "")
        setIptcLocation(city + ", " + country);
    else if(city != "")
        setIptcLocation(city);
    else
        setIptcLocation(country);


    try {
        Exiv2::IptcMetadata::const_iterator iter = iptcData.findKey(Exiv2::IptcKey("Iptc.Application2.Copyright"));
        if(iter != iptcData.end())
            setIptcApplication2Copyright(QString::fromStdString(Exiv2::toString(iter->value())));
        else
            setIptcApplication2Copyright("");
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
            setIptcApplication2Copyright("");
    }

#endif

}

QString PQMetaData::analyzeDateTimeOriginal(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeDateTimeOriginal()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    QStringList split1 = val.split(" ");
    QStringList split2 = split1.at(0).split(":");
    if(split1.length() > 1 && split2.length() > 2)
        return split2.at(2) + "/" + split2.at(1) + "/" + split2.at(0) + ", " + split1.at(1);

    return val;

}

QString PQMetaData::analyzeExposureTime(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeExposureTime()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    if(val.contains("/")) {

        QStringList split = val.split("/");

        int t1 = split.at(0).toInt();
        double t2 = split.at(1).split(" ").at(0).toDouble();

        // I got a bug report of PhotoQt crashing for certain images that have an exposure time
        // of "1/0". So we have to check for it, or we get a division by zero, i.e., crash
        if(t1 == 0 || t2 == 0)
            return "0";

        else if(t1 != 1)
            return QString("1/%2").arg(t2/t1);

        return QString("%1/%2").arg(t1).arg(t2);

    }

    return val;

}

QString PQMetaData::analyzeFlash(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeFlash()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    //: This string identifies that flash was fired, stored in image metadata
    QString fYes = tr("yes");
    //: This string identifies that flash was not fired, stored in image metadata
    QString fNo = tr("no");
    //: This string refers to the absense of a flash, stored in image metadata
    QString fNoFlash = tr("No flash function");
    //: This string refers to a flash mode, stored in image metadata
    QString fNoStrobe = tr("strobe return light not detected");
    //: This string refers to a flash mode, stored in image metadata
    QString fYesStrobe = tr("strobe return light detected");
    //: This string refers to a flash mode, stored in image metadata
    QString fComp = tr("compulsory flash mode");
    //: This string refers to a flash mode, stored in image metadata
    QString fAuto = tr("auto mode");
    //: This string refers to a flash mode, stored in image metadata
    QString fRed = tr("red-eye reduction mode");
    //: This string refers to a flash mode, stored in image metadata
    QString fYesReturn = tr("return light detected");
    //: This string refers to a flash mode, stored in image metadata
    QString fNoReturn = tr("return light not detected");

    if(val == "0")
        return fYes;
    else if(val == "1")
        return fNo;
    else if(val == "5")
        return fNoStrobe;
    else if(val == "6")
        return fYesStrobe;
    else if(val == "9")
        return fYes + " (" + fComp + ")";
    else if(val == "13")
        return fYes + " (" + fComp + ", " + fNoReturn + ")";
    else if(val == "15")
        return fYes + " (" + fComp + ", " + fYesReturn + ")";
    else if(val == "16")
        return fNo + " (" + fComp + ")";
    else if(val == "24")
        return fNo + " (" + fAuto + ")";
    else if(val == "25")
        return fYes + " (" + fAuto + ")";
    else if(val == "29")
        return fYes + " (" + fAuto + ", " + fNoReturn + ")";
    else if(val == "31")
        return fYes + " (" + fAuto + ", " + fYesReturn + ")";
    else if(val == "32")
        return fNoFlash;
    else if(val == "65")
        return fYes + " (" + fRed + ")";
    else if(val == "69")
        return fYes + " (" + fRed + ", " + fNoReturn + ")";
    else if(val == "71")
        return fYes + " (" + fRed + ", " + fYesReturn + ")";
    else if(val == "73")
        return fYes + " (" + fComp + ", " + fRed + ")";
    else if(val == "77")
        return fYes + " (" + fComp + ", " + fRed + ", " + fNoReturn + ")";
    else if(val == "79")
        return fYes + " (" + fComp + ", " + fRed + ", " + fYesReturn + ")";
    else if(val == "89")
        return fYes + " (" + fAuto + ", " + fRed + ")";
    else if(val == "93")
        return fYes + " (" + fAuto + ", " + fNoReturn + ", " + fRed + ")";
    else if(val == "95")
        return fYes + " (" + fAuto + ", " + fYesReturn + ", " + fRed + ")";
    else
        //: This string refers to a flash mode, stored in image metadata
        return tr("Invalid flash") + " " + val;

}

QString PQMetaData::analyzeSceneCaptureType(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeSceneCaptureType()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    if(val == "0")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Standard");
    else if(val == "1")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Landscape");
    else if(val == "2")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Portrait");
    else if(val == "3")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Night Scene");
    else
        //: This string refers to a type of scene, stored in image metadata
        return tr("Invalid Scene Type") + " " + val;

}

QString PQMetaData::analyzeFocalLength(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeFocalLength()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    if(val.contains("/")) {

        QStringList split = val.split("/");

        if(split.at(0) == "f")
            split.removeFirst();

        if(split.length() == 2)
            return QString::number(split.at(0).toFloat()/split.at(1).toFloat());

    }

    return val;

}

QString PQMetaData::analyzeFNumber(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeFNumber()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    if(val.contains("/")) {

        QStringList split = val.split("/");

        if(split.at(0) == "f")
            split.removeFirst();

        if(split.length() == 2)
            return QString::number(split.at(0).toFloat()/split.at(1).toFloat());

    }

    return val;

}

QString PQMetaData::analyzeLightSource(const QString val) {

    DBG << CURDATE << "PQMetaData::analyzeLightSource()" << NL
        << CURDATE << "** val = " << val.toStdString() << NL;

    if(val == "0")
        //: This string refers to the light source stored in image metadata
        return tr("Unknown");
    else if(val == "1")
        //: This string refers to the light source stored in image metadata
        return tr("Daylight");
    else if(val == "2")
        //: This string refers to the light source stored in image metadata
        return tr("Fluorescent");
    else if(val == "3")
        //: This string refers to the light source stored in image metadata
        return tr("Tungsten (incandescent light)");
    else if(val == "4")
        //: This string refers to the light source stored in image metadata
        return tr("Flash");
    else if(val == "9")
        //: This string refers to the light source stored in image metadata
        return tr("Fine weather");
    else if(val == "10")
        //: This string refers to the light source stored in image metadata
        return tr("Cloudy Weather");
    else if(val == "11")
        //: This string refers to the light source stored in image metadata
        return tr("Shade");
    else if(val == "12")
        //: This string refers to the light source stored in image metadata
        return tr("Daylight fluorescent") + " (D 5700 - 7100K)";
    else if(val == "13")
        //: This string refers to the light source stored in image metadata
        return tr("Day white fluorescent") + " (N 4600 - 5400K)";
    else if(val == "14")
        //: This string refers to the light source stored in image metadata
        return tr("Cool white fluorescent") + " (W 3900 - 4500K)";
    else if(val == "15")
        //: This string refers to the light source stored in image metadata
        return tr("White fluorescent") + " (WW 3200 - 3700K)";
    else if(val == "17")
        //: This string refers to the light source stored in image metadata
        return tr("Standard light") + " A";
    else if(val == "18")
        //: This string refers to the light source stored in image metadata
        return tr("Standard light") + " B";
    else if(val == "19")
        //: This string refers to the light source stored in image metadata
        return tr("Standard light") + " C";
    else if(val == "20")
        return "D55";
    else if(val == "21")
        return "D65";
    else if(val == "22")
        return "D75";
    else if(val == "23")
        return "D50";
    else if(val == "24")
        return "ISO studio tungsten";
    else if(val == "255")
        //: This string refers to the light source stored in image metadata
        return tr("Other light source");
    else
        //: This string refers to the light source stored in image metadata
        return tr("Invalid light source") + " " + val;

}

QString PQMetaData::analyzeGPS(QString latRef, QString lat, QString lonRef, QString lon) {

    DBG << CURDATE << "PQMetaData::analyzeGPS()" << NL
        << CURDATE << "** latRef = " << latRef.toStdString() << NL
        << CURDATE << "** lat = " << lat.toStdString() << NL
        << CURDATE << "** lonRef = " << lonRef.toStdString() << NL
        << CURDATE << "** lon = " << lon.toStdString() << NL;

    if(latRef == "") latRef = "N";
    if(lonRef == "") lonRef = "E";

    // Format the latitude string
    QStringList split = lat.split(" ");

    // Some photos have the GPS minutes stored as decimal. That needs to be converted into:
    // - Integer value for minute
    // - Decimal value *60 for seconds
    // This float holds the decimal value (if any)
    float calcSecs = 0;
    for(int i = 0; i < split.length(); ++i) {
        if(split.at(i).contains("/")) {
            float t1 = split.at(i).split("/").at(0).toFloat();
            float t2 = split.at(i).split("/").at(1).toFloat();
            float division = t1/t2;
            // If there's a decimal value...
            if(i == 1 && t2 > 1) {
                calcSecs = division-int(division);
                division = int(division);
            }
            split.replace(i,QString("%1").arg(division));
        } else if(split.at(i) == "")
            split[i] = "0";

    }
    // And calculate seconds and set them into third position
    if(calcSecs > 0 && split.length() >= 3)
        split.replace(2,QString::number(split.at(2).toFloat()+calcSecs*60));

    if(split.length() == 3)
        lat = split.at(0) + "°" + split.at(1) + "'" + split.at(2) + "''";
    else if(split.length() == 2)
        lat = split.at(0) + "°" + split.at(1) + "'0''";
    else if(split.length() == 1)
        lat = split.at(0) + "°0'0''";


    // Format the longitude string
    split = lon.split(" ");
    // See above for this float's role
    calcSecs = 0;
    for(int i = 0; i < split.length(); ++i) {
        if(split.at(i).contains("/")) {
            float t1 = split.at(i).split("/").at(0).toFloat();
            float t2 = split.at(i).split("/").at(1).toFloat();
            float division = t1/t2;
            // If there's a decimal value...
            if(i == 1 && t2 > 1) {
                calcSecs = division-int(division);
                division = int(division);
            }
            split.replace(i,QString("%1").arg(division));
        } else if(split.at(i) == "")
            split[i] = "0";
    }
    // And calculate seconds and set them into third position
    if(calcSecs > 0 && split.length() > 2)
        split.replace(2,QString::number(split.at(2).toFloat()+calcSecs*60));

    if(split.length() == 3)
        lon = split.at(0) + "°" + split.at(1) + "'" + split.at(2) + "''";
    else if(split.length() == 2)
        lon = split.at(0) + "°" + split.at(1) + "'0''";
    else if(split.length() == 1)
        lon = split.at(0) + "°0'0''";



    return lat + " " + latRef + ", " + lon + " " + lonRef;

}

QPointF PQMetaData::getGPSDataOnly(QString fname) {

#ifdef EXIV2

// Obtain METADATA

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif
    try {
        image  = Exiv2::ImageFactory::open(fname.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means unknown file type
        // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerUnsupportedImageType)
#else
        if(e.code() != 11)
#endif
            LOG << CURDATE << "PQMetaData::updateMetadaya(): ERROR reading exiv data (caught exception): " << e.what() << NL;
        else
            DBG << CURDATE << "PQMetaData::updateMetadaya(): ERROR reading exiv data (caught exception): " << e.what() << NL;
        return QPointF(9999,9999);
    }


    /*******************
    * Obtain EXIF data *
    ********************/

    Exiv2::ExifData exifData;

    try {
        exifData = image->exifData();
    } catch(Exiv2::Error &e) {
        LOG << CURDATE << "PQMetaData::updateMetaData(): ERROR: Unable to read exif metadata: " << e.what() << NL;
        return QPointF(9999,9999);
    }

    QString gpsLatRef = "", gpsLat = "", gpsLonRef = "", gpsLon = "";

    try {
        Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLatitudeRef"));
        if(iter != exifData.end())
            gpsLatRef = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLatitude"));
        if(iter != exifData.end())
            gpsLat = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLongitudeRef"));
        if(iter != exifData.end())
            gpsLonRef = QString::fromStdString(Exiv2::toString(iter->value()));

        iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLongitude"));
        if(iter != exifData.end())
            gpsLon = QString::fromStdString(Exiv2::toString(iter->value()));
    } catch(Exiv2::Error &) {
        // ignore exception -> most likely thrown as key does not exist
    }

    if(gpsLatRef == "" && gpsLat == "" && gpsLonRef == "" && gpsLon == "")
        return QPointF(9999,9999);

    return convertGPSToDecimal(gpsLatRef, gpsLat, gpsLonRef, gpsLon);

#endif

    return QPointF(9999,9999);

}

QPointF PQMetaData::convertGPSToDecimal(QString gpsLatRef, QString gpsLat, QString gpsLonRef, QString gpsLon) {

    const QStringList lat = gpsLat.split(" ");
    const QStringList lon = gpsLon.split(" ");
    if(lat.length() != 3 || lon.length() != 3)
        return QPointF(9999,9999);

    double x = 0, y = 0;

    const QList<double> div = {1, 60, 3600};

    for(int i = 0; i < 3; ++i) {

        double xval = 0;

        if(lat.at(i).contains("/")) {
            const QStringList p = lat.at(i).split("/");
            const double one = p.at(0).toDouble();
            const double two = p.at(1).toDouble();

            xval = one;
            if(two != 0)
                xval /= two;

        } else
            xval = lat.at(i).toDouble();

        x += xval/div.at(i);

        double yval = 0;

        if(lon.at(i).contains("/")) {
            const QStringList p = lon.at(i).split("/");
            const double one = p.at(0).toDouble();
            const double two = p.at(1).toDouble();

            yval = one;
            if(two != 0)
                yval /= two;

        } else
            yval = lon.at(i).toDouble();

        y += yval/div.at(i);

    }

    if(gpsLatRef.toLower() == "s")
        x *= -1;

    if(gpsLonRef.toLower() == "w")
        y *= -1;

    return QPointF(x,y);

}
