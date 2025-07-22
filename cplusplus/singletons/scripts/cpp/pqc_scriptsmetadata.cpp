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

#include <scripts/cpp/pqc_scriptsmetadata.h>
#include <pqc_configfiles.h>
#include <pqc_imageformats.h>

#include <QtDebug>
#include <QPointF>
#include <QVariant>
#include <QFileInfo>

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCScriptsMetaData::PQCScriptsMetaData() {

}

PQCScriptsMetaData::~PQCScriptsMetaData() {

}

QString PQCScriptsMetaData::analyzeDateTimeOriginal(const QString val) {

    qDebug() << "args: val =" << val;

    QStringList split1 = val.split(" ");
    QStringList split2 = split1.at(0).split(":");
    if(split1.length() > 1 && split2.length() > 2)
        return split2.at(2) + "/" + split2.at(1) + "/" + split2.at(0) + ", " + split1.at(1);

    return val;

}

QString PQCScriptsMetaData::analyzeExposureTime(const QString val) {

    qDebug() << "args: val =" << val;

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

QString PQCScriptsMetaData::analyzeFlash(const QString val) {

    qDebug() << "args: val =" << val;

    //: This string identifies that flash was fired, stored in image metadata
    QString fYes = tr("yes");
    //: This string identifies that flash was not fired, stored in image metadata
    QString fNo = tr("no");
    //: This string refers to the absence of a flash, stored in image metadata
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

QString PQCScriptsMetaData::analyzeSceneCaptureType(const QString val) {

    qDebug() << "args: val =" << val;

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

QString PQCScriptsMetaData::analyzeFocalLength(const QString val) {

    qDebug() << "args: val =" << val;

    if(val.contains("/")) {

        QStringList split = val.split("/");

        if(split.at(0) == "f")
            split.removeFirst();

        if(split.length() == 2)
            return QString::number(split.at(0).toFloat()/split.at(1).toFloat());

    }

    return val;

}

QString PQCScriptsMetaData::analyzeFNumber(const QString val) {

    qDebug() << "args: val =" << val;

    if(val.contains("/")) {

        QStringList split = val.split("/");

        if(split.at(0) == "f")
            split.removeFirst();

        if(split.length() == 2)
            return QString::number(split.at(0).toFloat()/split.at(1).toFloat());

    }

    return val;

}

QString PQCScriptsMetaData::analyzeLightSource(const QString val) {

    qDebug() << "args: val =" << val;

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

QString PQCScriptsMetaData::analyzeGPS(QString latRef, QString lat, QString lonRef, QString lon) {

    qDebug() << "args: latRef =" << latRef;
    qDebug() << "args: lat =" << lat;
    qDebug() << "args: lonRef =" << lonRef;
    qDebug() << "args: lon =" << lon;

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

QPointF PQCScriptsMetaData::convertGPSToDecimal(QString gpsLatRef, QString gpsLat, QString gpsLonRef, QString gpsLon) {

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

QString PQCScriptsMetaData::convertGPSToDecimalForOpenStreetMap(QString gps) {

    if(!gps.contains(", "))
        return "";

    const QPointF pt = convertGPSToPoint(gps);

    if(pt.x() == 9999)
        return "";

    return QString("%1/%2").arg(pt.x()).arg(pt.y());

}

QPointF PQCScriptsMetaData::convertGPSToPoint(QString gps) {

    if(!gps.contains(", "))
        return QPointF(9999,9999);

    const QString one = gps.split(", ")[0];
    const QString two = gps.split(", ")[1];

    if(!one.contains("°") || !one.contains("'") || !one.contains("''"))
        return QPointF(9999,9999);
    if(!two.contains("°") || !two.contains("'") || !two.contains("''"))
        return QPointF(9999,9999);

    float one_dec = one.split("°")[0].toFloat() + (one.split("°")[1].split("'")[0]).toFloat()/60.0 + (one.split("'")[1].split("''")[0]).toFloat()/3600.0;
    if(one.contains("S"))
        one_dec *= -1;

    float two_dec = two.split("°")[0].toFloat() + (two.split("°")[1].split("'")[0]).toFloat()/60.0 + (two.split("'")[1].split("''")[0]).toFloat()/3600.0;
    if(two.contains("W"))
        two_dec *= -1;

    return QPointF(one_dec, two_dec);

}

QString PQCScriptsMetaData::convertGPSDecimalToDegree(double lat, double lon) {

    QString ret = "";

    // find N/S/E/W labels
    QString lat_dir = (lat < 0 ? " S" : (lat > 0 ? " N" : ""));
    QString lon_dir = (lon < 0 ? " W" : (lon > 0 ? " E" : ""));

    // make sure values are positive
    lat = fabs(lat);
    lon = fabs(lon);

    // find degree
    int lat_deg = qFloor(lat);
    int lon_deg = qFloor(lon);

    // find minute
    double lat_min_full = (lat-lat_deg)*60;
    double lon_min_full = (lon-lon_deg)*60;
    int lat_min = qFloor(lat_min_full);
    int lon_min = qFloor(lon_min_full);

    // find seconds
    double lat_sec = qRound((lat_min_full-lat_min)*60*1e3)/1e3;
    double lon_sec = qRound((lon_min_full-lon_min)*60*1e3)/1e3;
    
    // assemble final string
    ret = QString("%1° %2' %3''%4, %5° %6' %7''%8").arg(lat_deg).arg(lat_min).arg(lat_sec).arg(lat_dir)
                                                   .arg(lon_deg).arg(lon_min).arg(lon_sec).arg(lon_dir);

    return ret;

}

QVariantList PQCScriptsMetaData::getFaceTags(QString filename) {

    qDebug() << "args: filename =" << filename;

    QVariantList ret;

#ifdef PQMEXIV2

    if(filename.contains("::PDF::") || filename.contains("::ARC::"))
        return ret;

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif
    try {
        image  = Exiv2::ImageFactory::open(filename.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means image not supported. This is much more reliable than, e.g., checking a file ending
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
        if(e.code() != 11)
#endif
            qWarning() << "ERROR reading metadata:" << e.what();
        else
            qDebug() << "ERROR reading metadata:" << e.what();
        return ret;
    }

    // This will hold the data extracted from the metadata
    // It will be filtered again before returning to make sure the data is coherent
    QMap<QString, QMap<QString,QString> > facedata;

    try {

        // This data is stored in the XMP data
        Exiv2::XmpData &xmpData = image->xmpData();
        for(Exiv2::XmpData::const_iterator it_xmp = xmpData.begin(); it_xmp != xmpData.end(); ++it_xmp) {

            QString familyName = QString::fromStdString(it_xmp->familyName());
            QString groupName = QString::fromStdString(it_xmp->groupName());
            QString tagName = QString::fromStdString(it_xmp->tagName());

            // Find the right key pattern (part before index)
            if(familyName == "Xmp" && groupName == "MP" && tagName.startsWith("RegionInfo/MPRI:Regions[")) {

                // Remove beginning part (up to index)
                tagName = tagName.remove(0,QString("RegionInfo/MPRI:Regions[").length());

                // Make sure this is data we are actually interested in
                if(tagName.contains("]/MPReg:")) {

                    // Filter out index (usually starts at 1, increments by 1 for each tag)
                    QString index = tagName.split("]/MPReg:").at(0);

                    // If this item contains the rectangle data
                    if(tagName.contains("MPReg:Rectangle")) {

                        // Find the four values specifying the rectangle: x, y, width, height
                        QString value = QString::fromStdString(Exiv2::toString(it_xmp->value()));
                        QStringList pos = value.split(",");

                        // If all the data is there, store data
                        if(pos.length() == 4) {

                            const QString w = pos.at(2).trimmed();
                            const QString h = pos.at(3).trimmed();

                            if(w != "0" && h != "0") {
                                facedata[index].insert("x",pos.at(0).trimmed());
                                facedata[index].insert("y",pos.at(1).trimmed());
                                facedata[index].insert("w",w);
                                facedata[index].insert("h",h);
                            }
                        }

                        // If this item contains the person's name
                    } else if(tagName.contains("MPReg:PersonDisplayName"))

                    // Store person's name
                    facedata[index].insert("name", QString::fromStdString(Exiv2::toString(it_xmp->value())));

                }

            }

        }

    } catch(Exiv2::Error& e) {
        qWarning() << "ERROR analyzing metadata (caught exception):" << e.what();
        return ret;
    }

    // Loop over all the extracted data
    QMapIterator<QString,QMap<QString,QString> > iter(facedata);
    while(iter.hasNext()) {

        iter.next();

        // If we found all the information we need: x, y, width, height, name
        if(iter.value().keys().contains("x") && iter.value().keys().contains("y") &&
            iter.value().keys().contains("w") && iter.value().keys().contains("h") &&
            iter.value().keys().contains("name")) {

            // Store data in return list
            ret.append(iter.key());
            ret.append(iter.value()["x"]);
            ret.append(iter.value()["y"]);
            ret.append(iter.value()["w"]);
            ret.append(iter.value()["h"]);
            ret.append(iter.value()["name"]);

        }

    }

#endif

    return ret;

}

void PQCScriptsMetaData::setFaceTags(QString filename, QVariantList tags) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: tags.length =" << tags;

#ifdef PQMEXIV2

    try {

// Open image for exif reading
#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Image::UniquePtr xmpImage = Exiv2::ImageFactory::open(filename.toStdString());
#else
        Exiv2::Image::AutoPtr xmpImage = Exiv2::ImageFactory::open(filename.toStdString());
#endif

        if(xmpImage.get() == 0)
            return;

        // read exif
        xmpImage->readMetadata();
        Exiv2::XmpData &xmpDataOld = xmpImage->xmpData();
        Exiv2::XmpData xmpDataNew;

        // we first need to remove already existing data before replacing it with the new stuff
        for(Exiv2::XmpData::const_iterator it_xmp = xmpDataOld.begin(); it_xmp != xmpDataOld.end(); ++it_xmp) {
            QString key = QString::fromStdString(it_xmp->key());
            if(!key.startsWith("Xmp.MP.RegionInfo/MPRI:Regions")) {
                xmpDataNew.add(Exiv2::XmpKey(it_xmp->key()), &it_xmp->value());
            }
        }

// The intro node
#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Value::UniquePtr regioninfo = Exiv2::Value::create(Exiv2::xmpText);
#else
        Exiv2::Value::AutoPtr regioninfo = Exiv2::Value::create(Exiv2::xmpText);
#endif
        regioninfo->read("type=\"Struct\"");
        xmpDataNew.add(Exiv2::XmpKey("Xmp.MP.RegionInfo"), regioninfo.get());

// Start of 'Bag'
#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Value::UniquePtr arrayStart = Exiv2::Value::create(Exiv2::xmpText);
#else
        Exiv2::Value::AutoPtr arrayStart = Exiv2::Value::create(Exiv2::xmpText);
#endif
        arrayStart->read("type=\"Bag\"");
        xmpDataNew.add(Exiv2::XmpKey("Xmp.MP.RegionInfo/MPRI:Regions"), arrayStart.get());

        // Loop over the passed on value
        for(int i = 0; i < tags.length()/6; ++i) {

// First: This is a struct
#if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::XmpTextValue::UniquePtr arrayOne(new Exiv2::XmpTextValue);
#else
            Exiv2::XmpTextValue::AutoPtr arrayOne(new Exiv2::XmpTextValue);
#endif
            arrayOne->read("type=\"Struct\"");
            xmpDataNew.add(Exiv2::XmpKey(QString("Xmp.MP.RegionInfo/MPRI:Regions[%1]").arg(i+1).toStdString()), arrayOne.get());

// Second: This is the rectangle where the face is located
#if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::XmpTextValue::UniquePtr arrayTwo(new Exiv2::XmpTextValue);
#else
            Exiv2::XmpTextValue::AutoPtr arrayTwo(new Exiv2::XmpTextValue);
#endif
            arrayTwo->read(QString("%1, %2, %3, %4").arg(tags[6*i+1].toString(),
                                                         tags[6*i+2].toString(),
                                                         tags[6*i+3].toString(),
                                                         tags[6*i+4].toString()).toStdString());
            xmpDataNew.add(Exiv2::XmpKey(QString("Xmp.MP.RegionInfo/MPRI:Regions[%1]/MPReg:Rectangle").arg(i+1).toStdString()), arrayTwo.get());

// Third: This is the name of the person
#if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::XmpTextValue::UniquePtr arrayThree(new Exiv2::XmpTextValue);
#else
            Exiv2::XmpTextValue::AutoPtr arrayThree(new Exiv2::XmpTextValue);
#endif
            arrayThree->read(tags[6*i+5].toString().toStdString());
            xmpDataNew.add(Exiv2::XmpKey(QString("Xmp.MP.RegionInfo/MPRI:Regions[%1]/MPReg:PersonDisplayName").arg(i+1).toStdString()),
                           arrayThree.get());

        }

        // and write XMP metadata
        xmpImage->clearXmpData();
        xmpImage->setXmpData(xmpDataNew);
        xmpImage->writeMetadata();

    } catch(Exiv2::Error& e) {
        qWarning() << "ERROR writing face tags:" << e.what();
        return;
    }

#endif

}

int PQCScriptsMetaData::getExifOrientation(QString path) {

    qDebug() << "args: path =" << path;

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
            qWarning() << "ERROR reading exif data (caught exception):" << e.what();
        else
            qDebug() << "ERROR reading exif data (caught exception):" << e.what();

        return 1;
    }

    Exiv2::ExifData exifData;

    try {
        exifData = image->exifData();
    } catch(Exiv2::Error &e) {
        qDebug() << "ERROR: Unable to read exif metadata:" << e.what();
        return 1;
    }

    Exiv2::ExifData::iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.Image.Orientation"));
    if(iter != exifData.end()) {

        const int val = QString::fromStdString(Exiv2::toString(iter->value())).toInt();
        if(val >= 1 && val <= 8)
            return val;

    }

#endif

    return 1;

}

bool PQCScriptsMetaData::areFaceTagsSupported(QString filename) {

    qDebug() << "args: filename =" << filename;

#ifdef PQMEXIV2

    if(filename.contains("::PDF::") || filename.contains("::ARC::"))
        return false;

    const QString suffix = QFileInfo(filename).suffix().toLower();
    if(!PQCImageFormats::get().getEnabledFormatsQt().contains(suffix) &&
        !PQCImageFormats::get().getEnabledFormatsMagick().contains(suffix)) {
        return false;
    }

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif
    try {
        image  = Exiv2::ImageFactory::open(filename.toStdString());
        image->readMetadata();
        Exiv2::XmpData &xmpDataOld = image->xmpData();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means image not supported. This is much more reliable than, e.g., checking a file ending
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
        if(e.code() != 11)
#endif
            qWarning() << "ERROR reading metadata:" << e.what();
        else
            qDebug() << "ERROR reading metadata:" << e.what();
        return false;
    }

    // if we got here then we can read/write xmp exif data
    return true;

#endif

    return false;

}
