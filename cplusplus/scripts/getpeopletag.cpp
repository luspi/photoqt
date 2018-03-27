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

#include "getpeopletag.h"
#include <QtDebug>

GetPeopleTag::GetPeopleTag(QObject *parent) : QObject(parent) { }

GetPeopleTag::~GetPeopleTag() { }

QVariantList GetPeopleTag::getPeopleLocations(QString path) {

    QVariantList ret;

#ifdef EXIV2

    Exiv2::Image::AutoPtr image;
    try {
        image  = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means image not supported. This is much more reliable than, e.g., checking a file ending
        if(e.code() != 11)
            LOG << CURDATE << "GetPeopleTag::getPeopleLocations() - ERROR reading exiv data (caught exception): " << e << NL;
        return ret;
    }

    // This will hold the data extracted from the metadata
    // It will be filtered again before returning to make sure the data is coherent
    QMap<QString, QMap<QString,QString> > facedata;

    // This data is stored in the XMP data
    Exiv2::XmpData &xmpData = image->xmpData();
    for(Exiv2::XmpData::const_iterator it_xmp = xmpData.begin(); it_xmp != xmpData.end(); ++it_xmp) {

        QString key = QString::fromStdString(it_xmp->key());

        // Find the right key pattern (part before index)
        if(key.startsWith("Xmp.MP.RegionInfo/MPRI:Regions[")) {

            // Remove beginning part (up to index)
            key = key.split("Xmp.MP.RegionInfo/MPRI:Regions[").at(1);

            // Make sure this is data we are actually interested in
            if(key.contains("]/MPReg:")) {

                // Filter out index (usually starts at 1, increments by 1 for each tag)
                QString index = key.split("]/MPReg:").at(0);

                // If this item contains the rectangle data
                if(key.contains("MPReg:Rectangle")) {

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
                } else if(key.contains("MPReg:PersonDisplayName"))

                    // Store person's name
                    facedata[index].insert("name", QString::fromStdString(Exiv2::toString(it_xmp->value())));

            }

        }

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
