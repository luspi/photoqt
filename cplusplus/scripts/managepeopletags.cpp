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

#include "managepeopletags.h"
#include <QtDebug>

ManagePeopleTags::ManagePeopleTags(QObject *parent) : QObject(parent) { }

ManagePeopleTags::~ManagePeopleTags() { }

QVariantList ManagePeopleTags::getFaceTags(QString path) {

    QVariantList ret;

#ifdef EXIV2

    Exiv2::Image::AutoPtr image;
    try {
        image  = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means image not supported. This is much more reliable than, e.g., checking a file ending
        if(e.code() != 11)
            LOG << CURDATE << "GetPeopleTag::getPeopleLocations() 1 - ERROR reading exiv data (caught exception): " << e << NL;
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
        LOG << CURDATE << "GetPeopleTag::getPeopleLocations() 2 - ERROR reading exiv data (caught exception): "
            << e << " (" << Exiv2::errMsg(e.code()) << ")" << NL;
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

    // Done :)
    return ret;

}

void ManagePeopleTags::setFaceTags(QString filename, QVariantList tags) {

    if(!canWriteXmpTags(filename))
        return;

#ifdef EXIV2

    try {

        // Open image for exif reading
        Exiv2::Image::AutoPtr xmpImage = Exiv2::ImageFactory::open(filename.toStdString());

        if(xmpImage.get() != 0) {

            // read exif
            xmpImage->readMetadata();
            Exiv2::XmpData &xmpDataOld = xmpImage->xmpData();
            xmpImage->clearXmpData();
            Exiv2::XmpData xmpDataNew;

            // we first need to remove already existing data before replacing it with the new stuff
            for(Exiv2::XmpData::const_iterator it_xmp = xmpDataOld.begin(); it_xmp != xmpDataOld.end(); ++it_xmp) {
                QString key = QString::fromStdString(it_xmp->key());
                if(!key.startsWith("Xmp.MP.RegionInfo")) {
                    xmpDataNew.add(Exiv2::XmpKey(it_xmp->key()), &it_xmp->value());
                    LOG << "START: " << it_xmp->key() << " :: " << it_xmp->value() << NL;
                }
            }

            // The intro node
            Exiv2::Value::AutoPtr regioninfo = Exiv2::Value::create(Exiv2::xmpText);
            regioninfo->read("type=\"Struct\"");
            xmpDataNew.add(Exiv2::XmpKey("Xmp.MP.RegionInfo"), regioninfo.get());

            // Start of 'Bag'
            Exiv2::Value::AutoPtr arrayStart = Exiv2::Value::create(Exiv2::xmpText);
            arrayStart->read("type=\"Bag\"");
            xmpDataNew.add(Exiv2::XmpKey("Xmp.MP.RegionInfo/MPRI:Regions"), arrayStart.get());

            // Loop over the passed on value
            for(int i = 0; i < tags.length()/6; ++i) {

                // First: This is a struct
                Exiv2::XmpTextValue::AutoPtr arrayOne(new Exiv2::XmpTextValue);
                arrayOne->read("type=\"Struct\"");
                xmpDataNew.add(Exiv2::XmpKey(QString("Xmp.MP.RegionInfo/MPRI:Regions[%1]").arg(i+1).toStdString()), arrayOne.get());

                // Second: This is the rectangle where the face is located
                Exiv2::XmpTextValue::AutoPtr arrayTwo(new Exiv2::XmpTextValue);
                arrayTwo->read(QString("%1, %2, %3, %4").arg(tags[6*i+1].toString()).arg(tags[6*i+2].toString())
                                                        .arg(tags[6*i+3].toString()).arg(tags[6*i+4].toString()).toStdString());
                xmpDataNew.add(Exiv2::XmpKey(QString("Xmp.MP.RegionInfo/MPRI:Regions[%1]/MPReg:Rectangle").arg(i+1).toStdString()), arrayTwo.get());

                // Third: This is the name of the person
                Exiv2::XmpTextValue::AutoPtr arrayThree(new Exiv2::XmpTextValue);
                arrayThree->read(tags[6*i+5].toString().toStdString());
                xmpDataNew.add(Exiv2::XmpKey(QString("Xmp.MP.RegionInfo/MPRI:Regions[%1]/MPReg:PersonDisplayName").arg(i+1).toStdString()),
                               arrayThree.get());

            }

            // and write XMP metadata
            xmpImage->setXmpData(xmpDataNew);
            xmpImage->writeMetadata();

        }

    } catch(Exiv2::Error& e) {
        LOG << CURDATE << "GetPeopleTag::setFaceTags() - ERROR reading exiv data (caught exception): "
            << e << " (" << Exiv2::errMsg(e.code()) << ")" << NL;
        return;
    }

#endif

}

bool ManagePeopleTags::canWriteXmpTags(QString filename) {

    QStringList supportedEndings;
    supportedEndings << "jpg" << "jpeg" << "exv" << "cr2" << "tif" << "tiff" << "webp" << "dng" << "net"
                     << "pef" << "srw" << "orf" << "png" << "pgf" << "eps" << "xmp" << "psd" << "jp2";

    QStringList supportedMimeTypes;
    supportedMimeTypes << "image/jpeg" << "image/x-canon-cr2" << "image/tiff" << "image/webp" << "image/x-adobe-dng" << "image/x-nikon-nef"
                       << "image/x-pentax-pef" << "image/x-olympus-orf" << "image/png" << "image/x-eps" << "image/vnd.adobe.photoshop" << "image/jp2";

    QMimeDatabase mimedb;
    QString suffix = QFileInfo(filename).suffix();
    if(supportedEndings.contains(suffix) || (supportedMimeTypes.contains(mimedb.mimeTypeForFile(filename).name()) && suffix != "psb"))
        return true;
    return false;

}
