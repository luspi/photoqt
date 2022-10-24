/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "handlingfacetags.h"

bool PQHandlingFaceTags::canWriteXmpTags(QString filename) {

    DBG << CURDATE << "PQHandlingFaceTags::canWriteXmpTags()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QStringList supportedEndings;
    supportedEndings << "jpg" << "jpeg" << "exv" << "cr2" << "tif" << "tiff" << "webp" << "dng" << "net"
                     << "pef" << "srw" << "orf" << "png" << "pgf" << "eps" << "xmp" << "psd" << "jp2";

    return supportedEndings.contains(QFileInfo(filename).suffix().toLower());

}

QVariantList PQHandlingFaceTags::getFaceTags(QString filename) {

    DBG << CURDATE << "PQHandlingFaceTags::getFaceTags()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

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
        if(e.code() != 11)
            LOG << CURDATE << "PQHandlingFaceTags::getFaceTags() - ERROR reading metadata (caught exception): " << e << NL;
        else
            DBG << CURDATE << "PQHandlingFaceTags::getFaceTags() - ERROR reading metadata (caught exception): " << e << NL;
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
        LOG << CURDATE << "PQHandlingFaceTags::getFaceTags() - ERROR analyzing metadata (caught exception): "
            << e.what() << NL;
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

void PQHandlingFaceTags::setFaceTags(QString filename, QVariantList tags) {

    DBG << CURDATE << "PQHandlingFaceTags::setFaceTags()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

#ifdef EXIV2

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
        LOG << CURDATE << "PQHandlingFaceTags::setFaceTags() - ERROR writing face tags (caught exception): "
            << e.what() << NL;
        return;
    }

#endif

}
