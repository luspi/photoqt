#include "handlingfacetags.h"

PQHandlingFaceTags::PQHandlingFaceTags(QObject *parent) : QObject(parent) {

}

QVariantList PQHandlingFaceTags::getFaceTags(QString filename) {

    QVariantList ret;

#ifdef EXIV2

    Exiv2::Image::AutoPtr image;
    try {
        image  = Exiv2::ImageFactory::open(filename.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of 11 means image not supported. This is much more reliable than, e.g., checking a file ending
        if(e.code() != 11)
            LOG << CURDATE << "PQHandlingFaceTags::getFaceTags() - ERROR reading metadata (caught exception): " << e << NL;
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
