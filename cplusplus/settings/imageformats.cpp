/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#include "imageformats.h"

PQImageFormats::PQImageFormats() {

    db = QSqlDatabase::addDatabase("QSQLITE3");
    db.setHostName("formats");
    db.setDatabaseName(ConfigFiles::IMAGEFORMATS_DB());
    if(!db.open()) {
        LOG << CURDATE << "PQImageFormats::PQImageFormats(): ERROR opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        return;
    }

    readFromDatabase();

}

void PQImageFormats::readFromDatabase() {

    formats.clear();
    formats_enabled.clear();
    formats_defaultenabled.clear();
    formats_qt.clear();
    formats_im.clear();
    formats_gm.clear();
    formats_libraw.clear();
    formats_poppler.clear();
    formats_xcftools.clear();
    formats_devil.clear();
    formats_freeimage.clear();
    formats_archive.clear();
    formats_video.clear();

    QSqlQuery query("SELECT * FROM imageformats ORDER BY description ASC", db);

    while(query.next()) {

        const QString ending = query.record().value("endings").toString();
        const QString desc = query.record().value("description").toString();
        const int enabled = query.record().value("enabled").toInt();
        const int defaultenabled = query.record().value("defaultenabled").toInt();
        const int qt = query.record().value("qt").toInt();
        const int im = query.record().value("imagemagick").toInt();
        const int gm = query.record().value("graphicsmagick").toInt();
        const int libraw = query.record().value("libraw").toInt();
        const int poppler = query.record().value("poppler").toInt();
        const int xcftools = query.record().value("xcftools").toInt();
        const int devil = query.record().value("devil").toInt();
        const int freeimage = query.record().value("freeimage").toInt();
        const int archive = query.record().value("archive").toInt();
        const int video = query.record().value("video").toInt();
        const QString im_gm_magick = query.record().value("im_gm_magick").toString();

        bool supportedByAnyLibrary = false;
        bool magickToBeAdded = false;

        QList<QVariant> all;
        all << ending;
        all << enabled;
        all << desc;
        if(qt) {
            supportedByAnyLibrary = true;
            all << "Qt";
            formats_qt << ending.split(",").toVector();
        }
#ifdef IMAGEMAGICK
        if(im) {
            supportedByAnyLibrary = true;
            magickToBeAdded = true;
            all << "ImageMagick";
            formats_im << ending.split(",").toVector();
        }
#endif
#ifdef GRAPHICSMAGICK
        if(gm) {
            supportedByAnyLibrary = true;
            magickToBeAdded = true;
            all << "GraphicsMagick";
            formats_gm << ending.split(",").toVector();
        }
#endif
        if(libraw) {
            supportedByAnyLibrary = true;
            all << "libraw";
            formats_libraw << ending.split(",").toVector();
        }
#ifdef POPPLER
        if(poppler) {
            supportedByAnyLibrary = true;
            all << "Poppler";
            formats_poppler << ending.split(",").toVector();
        }
#endif
        if(xcftools) {
            supportedByAnyLibrary = true;
            all << "XCFTools";
            formats_xcftools << ending.split(",").toVector();
        }
#ifdef DEVIL
        if(devil) {
            supportedByAnyLibrary = true;
            all << "DevIL";
            formats_devil << ending.split(",").toVector();
        }
#endif
#ifdef FREEIMAGE
        if(freeimage) {
            supportedByAnyLibrary = true;
            all << "FreeImage";
            formats_freeimage << ending.split(",").toVector();
        }
#endif
#ifdef LIBARCHIVE
        if(archive) {
            supportedByAnyLibrary = true;
            all << "LibArchive";
            formats_archive << ending.split(",").toVector();
        }
#endif
#ifdef VIDEO
        if(video) {
            supportedByAnyLibrary = true;
            all << "Video";
            formats_video << ending.split(",").toVector();
        }
#endif

        if(supportedByAnyLibrary) {

            formats << QVariant::fromValue(all);

            if(enabled)
                formats_enabled << ending.split(",").toVector();
            if(defaultenabled)
                formats_defaultenabled << ending;
            if(magickToBeAdded) {
                for(QString e : ending.split(","))
                    magick.insert(e, im_gm_magick);
            }

        }
    }

}

void PQImageFormats::writeToDatabase(QVariantList f) {

    db.transaction();

    for(QVariant entry : f) {

        QSqlQuery query(db);
        query.prepare("UPDATE imageformats SET enabled=:enabled WHERE endings=:endings");
        query.bindValue(":enabled", entry.toList()[1].toInt());
        query.bindValue(":endings", entry.toList()[0].toString());
        if(!query.exec())
            LOG << CURDATE << "PQImageFormats::writeToDatabase(): SQL Query error: " << query.lastError().text().trimmed().toStdString() << NL;

    }

    db.commit();

    readFromDatabase();

}
