/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#include "getmetadata.h"

GetMetaData::GetMetaData(QObject *parent) : QObject(parent) {
    settings = new SlimSettingsReadOnly;
}

GetMetaData::~GetMetaData() {
    delete settings;
}


QVariantMap GetMetaData::getExiv2(QString path) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetMetaData::getExiv2()" << NL;

    QVariantMap returnMap;

    // Clean path
    if(path.startsWith("image://full/"))
        path = path.remove(0,13);
    else if(path.startsWith("file:/"))
        path = path.remove(0,6);

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.remove(0,1);
#endif

    path = QUrl::fromPercentEncoding(path.toUtf8());
    QFileInfo info(path);

    if(!QFile(path).exists()) {

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "GetMetaData::getExiv2() - file does not exist" << NL;

        returnMap.insert("validfile","0");
        return returnMap;

    } else {

        returnMap.insert("validfile","1");
        returnMap.insert("filesize",QString("%1").arg(info.size()/1024) + " KB");

        // Obtain dimensions (if supported by ImageReader)
        if(QImageReader::supportedImageFormats().contains(info.suffix().toLower().toUtf8())) {
            QSize s = QImageReader(path).size();
            if(s.width() > 0 && s.height() > 0)
                returnMap.insert("dimensions",QString("%1x%2").arg(s.width()).arg(s.height()));
        }

        // These formats known by PhotoQt are supported by exiv2
        QStringList formats;
        formats << "jpeg" << "jpg" << "tif" << "tiff"
                << "png" << "psd" << "jpeg2000" << "jp2"
                << "j2k" << "jpc" << "jpf" << "jpx"
                << "jpm" << "mj2" << "bmp" << "bitmap"
                << "gif" << "tga";

        // "Unsupported"
        if(!formats.contains(info.suffix().toLower())) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "GetMetaData::getExiv2() - unsupported image format" << NL;

            returnMap.insert("supported","0");
            return returnMap;

        // "Supported"
        } else {

            returnMap.insert("supported","1");

            if(settings->metaMake)
                returnMap.insert("Exif.Image.Make","");
            if(settings->metaModel)
                returnMap.insert("Exif.Image.Model","");
            if(settings->metaSoftware)
                returnMap.insert("Exif.Image.Software","");
            if(settings->metaTimePhotoTaken)
                returnMap.insert("Exif.Photo.DateTimeOriginal","");
            if(settings->metaExposureTime)
                returnMap.insert("Exif.Photo.ExposureTime","");
            if(settings->metaFlash)
                returnMap.insert("Exif.Photo.Flash","");
            if(settings->metaIso)
                returnMap.insert("Exif.Photo.ISOSpeedRatings","");
            if(settings->metaSceneType)
                returnMap.insert("Exif.Photo.SceneCaptureType","");
            if(settings->metaFLength)
                returnMap.insert("Exif.Photo.FocalLength","");
            if(settings->metaFNumber)
                returnMap.insert("Exif.Photo.FNumber","");
            if(settings->metaLightSource)
                returnMap.insert("Exif.Photo.LightSource","");
            if(settings->metaDimensions) {
                returnMap.insert("Exif.Photo.PixelXDimension","");
                returnMap.insert("Exif.Photo.PixelYDimension","");
            }
            if(settings->metaGps) {
                returnMap.insert("Exif.GPSInfo.GPSLatitudeRef","");
                returnMap.insert("Exif.GPSInfo.GPSLatitude","");
                returnMap.insert("Exif.GPSInfo.GPSLongitudeRef","");
                returnMap.insert("Exif.GPSInfo.GPSLongitude","");
            }

            if(settings->metaKeywords)
                returnMap.insert("Iptc.Application2.Keywords","");
            if(settings->metaLocation) {
                returnMap.insert("Iptc.Application2.City","");
                returnMap.insert("Iptc.Application2.CountryName","");
            }
            if(settings->metaCopyright)
                returnMap.insert("Iptc.Application2.Copyright","");

#ifdef EXIV2

            // Obtain METADATA

            Exiv2::Image::AutoPtr image;
            try {
                image  = Exiv2::ImageFactory::open(path.toStdString());
                image->readMetadata();
            } catch (Exiv2::Error& e) {
                LOG << CURDATE << "GetMetaData::getExiv2() - ERROR reading exiv data (caught exception): " << e.what() << NL;
                returnMap.clear();
                returnMap.insert("validfile","0");
                return returnMap;
            }

            /*******************
            * Obtain EXIF data *
            ********************/

            Exiv2::ExifData &exifData = image->exifData();
            Exiv2::ExifData::const_iterator exifEnd = exifData.end();
            for (Exiv2::ExifData::const_iterator it_exif = exifData.begin(); it_exif != exifEnd; ++it_exif) {

                // Key/Value
                QString key = QString::fromStdString(it_exif->key());

                if(returnMap.keys().contains(key)) {

                    QString value = QString::fromStdString(Exiv2::toString(it_exif->value()));

                    // Compose data

                    if(key == "Exif.Photo.ExposureTime")
                        value = exifExposureTime(value) + " s";

                    else if(key == "Exif.Photo.FocalLength")
                        value = exifFNumberFLength(value) + " mm";

                    else if(key == "Exif.Photo.FNumber")
                        value = "F" + exifFNumberFLength(value);

                    else if(key == "Exif.Photo.DateTimeOriginal")
                        value = exifPhotoTaken(value);

                    else if(key == "Exif.Photo.LightSource")
                        value = exifLightSource(value);

                    else if(key == "Exif.Photo.Flash")
                        value = exifFlash(value);

                    else if(key == "Exif.Photo.SceneCaptureType")
                        value = exifSceneType(value);

                    // Store values

                    returnMap[key] = value;

                }

            }

            // If GPS is set, compose into one string

            if(returnMap["Exif.GPSInfo.GPSLatitudeRef"] != ""
               && returnMap["Exif.GPSInfo.GPSLatitude"] != ""
               && returnMap["Exif.GPSInfo.GPSLongitudeRef"] != ""
               && returnMap["Exif.GPSInfo.GPSLongitude"] != "") {

                QStringList l = exifGps(returnMap["Exif.GPSInfo.GPSLongitudeRef"].toString(),
                        returnMap["Exif.GPSInfo.GPSLongitude"].toString(),
                        returnMap["Exif.GPSInfo.GPSLatitudeRef"].toString(),
                        returnMap["Exif.GPSInfo.GPSLatitude"].toString());
                returnMap["Exif.GPSInfo.GPSLongitudeRef"] = l.at(0);
                returnMap["Exif.GPSInfo.GPSLatitudeRef"] = l.at(1);

            }

            /*******************
            * Obtain IPTC data *
            ********************/

            Exiv2::IptcData &iptcData = image->iptcData();

            Exiv2::IptcData::iterator iptcEnd = iptcData.end();
            for (Exiv2::IptcData::iterator it_iptc = iptcData.begin(); it_iptc != iptcEnd; ++it_iptc) {

                // Key/Value
                QString key = QString::fromStdString(it_iptc->key());

                if(returnMap.keys().contains(key)) {

                    QString value = QString::fromStdString(Exiv2::toString(it_iptc->value()));
                    returnMap[key] = value;

                }

            }

            QString city = returnMap["Iptc.Application2.City"].toString();
            QString country = returnMap["Iptc.Application2.CountryName"].toString();

            returnMap["Iptc.Application2.City"] = city + ((city != "" && country != "") ? ", " : "") + country;

#endif

            return returnMap;

        }

    }

}



// Format exposure time
QString GetMetaData::exifExposureTime(QString value) {

    if(value.contains("/")) {
        QStringList split = value.split("/");
        int t1 = split.at(0).toInt();
        double t2 = split.at(1).split(" ").at(0).toDouble();
        // I got a bug report of PhotoQt crashing for certain images that have an exposure time
        // of "1/0". So we have to check for it, or we get a division by zero, i.e., crash
        if(t1 == 0 || t2 == 0) {
            t1 = 0;
            t2 = 0;
            value = "0";
        } else if(t1 != 1) {
            t2 = t2/t1;
            t1 = t1/t1;
            value = QString("%1/%2").arg(t1).arg(t2);
        } else {
            value = QString("%1/%2").arg(t1).arg(t2);
        }

    }

    return value;

}

// Format Focal Length
QString GetMetaData::exifFNumberFLength(QString value) {

    if(value.startsWith("f/"))
        value = value.remove(0,2);

    if(value.contains("/")) {
        QStringList split = value.split("/");
        float t1 = split.at(0).toFloat();
        float t2 = split.at(1).toFloat();
        t1 = t1/t2;
        value = QString("%1").arg(t1);
    }

    return value;

}

// Format time the photo was taken
QString GetMetaData::exifPhotoTaken(QString value) {

    QStringList split = value.split(" ");
    QStringList split2 = split.at(0).split(":");
    if(split.length() > 1 && split2.length() > 2)
        value = split2.at(2) + "/" + split2.at(1) + "/" + split2.at(0) + ", " + split.at(1);

    return value;

}

// Compose GPS data
QStringList GetMetaData::exifGps(QString gpsLonRef, QString gpsLon, QString gpsLatRef, QString gpsLat) {

    if(gpsLatRef == "") gpsLatRef = "N";
    if(gpsLonRef == "") gpsLonRef = "E";

    // Format the latitude string
    QStringList split = gpsLat.split(" ");

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
        gpsLat = split.at(0) + "°" + split.at(1) + "'" + split.at(2) + "''";
    else if(split.length() == 2)
        gpsLat = split.at(0) + "°" + split.at(1) + "'0''";
    else if(split.length() == 1)
        gpsLat = split.at(0) + "°0'0''";

    float secL = 0;
    if(split.length() == 3)
        secL = ((split.at(1).toFloat()*60+split.at(2).toFloat())/3600.0);
    else if(split.length() == 2)
        secL = ((split.at(1).toFloat()*60)/3600.0);

    float left = split.at(0).toFloat() + secL;
    if(gpsLatRef == "S") left *= -1;


    // Format the longitude string
    split = gpsLon.split(" ");
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
        gpsLon = split.at(0) + "°" + split.at(1) + "'" + split.at(2) + "''";
    else if(split.length() == 2)
        gpsLon = split.at(0) + "°" + split.at(1) + "'0''";
    else if(split.length() == 1)
        gpsLon = split.at(0) + "°0'0''";

    float secR = 0;
    if(split.length() == 3)
        secR = ((split.at(1).toFloat()*60+split.at(2).toFloat())/3600.0);
    else if(split.length() == 2)
        secR = ((split.at(1).toFloat()*60)/3600.0);

    float right = split.at(0).toFloat() + secR;
    if(gpsLonRef == "W") right *= -1;

    QString value = gpsLat + " " + gpsLatRef + ", " + gpsLon + " " + gpsLonRef;

    QStringList allVal;
    allVal << value << QString("%1 %2").arg(left).arg(right);

    // Compose all the gps data into one string
    return allVal;

}

QString GetMetaData::exifLightSource(QString value) {

    if(value == "0")
        //: This string refers to the light source stored in image metadata
        return tr("Unknown");
    else if(value == "1")
        //: This string refers to the light source stored in image metadata
        return tr("Daylight");
    else if(value == "2")
        //: This string refers to the light source stored in image metadata
        return tr("Fluorescent");
    else if(value == "3")
        //: This string refers to the light source stored in image metadata
        return tr("Tungsten (incandescent light)");
    else if(value == "4")
        //: This string refers to the light source stored in image metadata
        return tr("Flash");
    else if(value == "9")
        //: This string refers to the light source stored in image metadata
        return tr("Fine weather");
    else if(value == "10")
        //: This string refers to the light source stored in image metadata
        return tr("Cloudy Weather");
    else if(value == "11")
        //: This string refers to the light source stored in image metadata
        return tr("Shade");
    else if(value == "12")
        //: This string refers to the light source stored in image metadata
        return tr("Daylight fluorescent") + " (D 5700 - 7100K)";
    else if(value == "13")
        //: This string refers to the light source stored in image metadata
        return tr("Day white fluorescent") + " (N 4600 - 5400K)";
    else if(value == "14")
        //: This string refers to the light source stored in image metadata
        return tr("Cool white fluorescent") + " (W 3900 - 4500K)";
    else if(value == "15")
        //: This string refers to the light source stored in image metadata
        return tr("White fluorescent") + " (WW 3200 - 3700K)";
    else if(value == "17")
        //: This string refers to the light source stored in image metadata
        return tr("Standard light") + " A";
    else if(value == "18")
        //: This string refers to the light source stored in image metadata
        return tr("Standard light") + " B";
    else if(value == "19")
        //: This string refers to the light source stored in image metadata
        return tr("Standard light") + " C";
    else if(value == "20")
        return "D55";
    else if(value == "21")
        return "D65";
    else if(value == "22")
        return "D75";
    else if(value == "23")
        return "D50";
    else if(value == "24")
        return "ISO studio tungsten";
    else if(value == "255")
        //: This string refers to the light source stored in image metadata
        return tr("Other light source");
    else
        //: This string refers to the light source stored in image metadata
        return tr("Invalid light source") + " " + value;



}

QString GetMetaData::exifFlash(QString value) {

    //: This string identifies that flash was fired, stored in image metadata
    QString fYes = tr("yes");
    //: This string identifies that flash wasn't fired, stored in image metadata
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

    if(value == "0")
        return fYes;
    else if(value == "1")
        return fNo;
    else if(value == "5")
        return fNoStrobe;
    else if(value == "6")
        return fYesStrobe;
    else if(value == "9")
        return fYes + " (" + fComp + ")";
    else if(value == "13")
        return fYes + " (" + fComp + ", " + fNoReturn + ")";
    else if(value == "15")
        return fYes + " (" + fComp + ", " + fYesReturn + ")";
    else if(value == "16")
        return fNo + " (" + fComp + ")";
    else if(value == "24")
        return fNo + " (" + fAuto + ")";
    else if(value == "25")
        return fYes + " (" + fAuto + ")";
    else if(value == "29")
        return fYes + " (" + fAuto + ", " + fNoReturn + ")";
    else if(value == "31")
        return fYes + " (" + fAuto + ", " + fYesReturn + ")";
    else if(value == "32")
        return fNoFlash;
    else if(value == "65")
        return fYes + " (" + fRed + ")";
    else if(value == "69")
        return fYes + " (" + fRed + ", " + fNoReturn + ")";
    else if(value == "71")
        return fYes + " (" + fRed + ", " + fYesReturn + ")";
    else if(value == "73")
        return fYes + " (" + fComp + ", " + fRed + ")";
    else if(value == "77")
        return fYes + " (" + fComp + ", " + fRed + ", " + fNoReturn + ")";
    else if(value == "79")
        return fYes + " (" + fComp + ", " + fRed + ", " + fYesReturn + ")";
    else if(value == "89")
        return fYes + " (" + fAuto + ", " + fRed + ")";
    else if(value == "93")
        return fYes + " (" + fAuto + ", " + fNoReturn + ", " + fRed + ")";
    else if(value == "95")
        return fYes + " (" + fAuto + ", " + fYesReturn + ", " + fRed + ")";
    else
        //: This string refers to a flash mode, stored in image metadata
        return tr("Invalid flash") + " " + value;



}

QString GetMetaData::exifSceneType(QString value) {

    if(value == "0")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Standard");
    else if(value == "1")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Landscape");
    else if(value == "2")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Portrait");
    else if(value == "3")
        //: This string refers to a type of scene, stored in image metadata
        return tr("Night Scene");
    else
        //: This string refers to a type of scene, stored in image metadata
        return tr("Invalid Scene Type") + " " + value;


}
