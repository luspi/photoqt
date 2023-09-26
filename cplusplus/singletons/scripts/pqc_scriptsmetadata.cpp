#include <scripts/pqc_scriptsmetadata.h>

#include <QtDebug>
#include <QPointF>
#include <QVariant>

#ifdef EXIV2
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

QVariantList PQCScriptsMetaData::getFaceTags(QString filename) {

    qDebug() << "args: filename =" << filename;

    QVariantList ret;

#ifdef EXIV2

    if(filename.contains("::PQT::") || filename.contains("::ARC::"))
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
                            facedata[index].insert("x",pos.at(0).trimmed());
                            facedata[index].insert("y",pos.at(1).trimmed());
                            facedata[index].insert("w",pos.at(2).trimmed());
                            facedata[index].insert("h",pos.at(3).trimmed());
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
