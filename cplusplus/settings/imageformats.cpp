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

#include "imageformats.h"
#include <QImageReader>

PQImageFormats::PQImageFormats() {

    db = QSqlDatabase::database("imageformats");

    QFileInfo infodb(ConfigFiles::IMAGEFORMATS_DB());

    if(!infodb.exists() || !db.open()) {

        LOG << CURDATE << "PQImageFormats::PQImageFormats(): ERROR opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        LOG << CURDATE << "PQImageFormats::PQImageFormats(): Will load built-in read-only database of imageformats" << NL;

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/imageformats.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/imageformats.db", tmppath)) {
            LOG << CURDATE << "PQImageFormats::PQImageFormats(): ERROR copying read-only default database!" << NL;
            //: This is the window title of an error message box
            QMessageBox::critical(0, QCoreApplication::translate("PQImageFormats", "ERROR getting default image formats"),
                                     QCoreApplication::translate("PQImageFormats", "I tried hard, but I just cannot open even a read-only version of the database of default image formats.") + QCoreApplication::translate("PQImageFormats", "Something went terribly wrong somewhere!"));
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            LOG << CURDATE << "PQImageFormats::PQImageFormats(): ERROR opening read-only default database!" << NL;
            QMessageBox::critical(0, QCoreApplication::translate("PQImageFormats", "ERROR getting default image formats"),
                                     QCoreApplication::translate("PQImageFormats", "I tried hard, but I just cannot open the database of default image formats.") + QCoreApplication::translate("PQImageFormats", "Something went terribly wrong somewhere!"));
            return;
        }

        readFromDatabase();

    } else {

        readonly = false;
        if(!infodb.permission(QFileDevice::WriteOwner))
            readonly = true;

        readFromDatabase();

    }

}

void PQImageFormats::readFromDatabase() {

    DBG << CURDATE << "PQImageFormats::readFromDatabase()" << NL;

    formats.clear();
    formats_enabled.clear();
    formats_qt.clear();
    formats_libvips.clear();
    formats_magick.clear();
    formats_libraw.clear();
    formats_poppler.clear();
    formats_xcftools.clear();
    formats_devil.clear();
    formats_freeimage.clear();
    formats_archive.clear();
    formats_video.clear();
    formats_libmpv.clear();

    mimetypes_enabled.clear();
    mimetypes_qt.clear();
    mimetypes_libvips.clear();
    mimetypes_magick.clear();
    mimetypes_libraw.clear();
    mimetypes_poppler.clear();
    mimetypes_xcftools.clear();
    mimetypes_devil.clear();
    mimetypes_freeimage.clear();
    mimetypes_archive.clear();
    mimetypes_video.clear();
    mimetypes_libmpv.clear();

    magick.clear();
    magick_mimetype.clear();

    const QList<QByteArray> qtSupported = QImageReader::supportedImageFormats();

    QSqlQuery query("SELECT * FROM imageformats ORDER BY enabled DESC, description ASC", db);

    while(query.next()) {

        const QString endings = query.record().value("endings").toString();
        const QString mimetypes = query.record().value("mimetypes").toString();
        const QString desc = query.record().value("description").toString();
        const QString cat = query.record().value("category").toString();
        const int enabled = query.record().value("enabled").toInt();
        const int qt = query.record().value("qt").toInt();

#ifndef ENABLE_WEBP
        // if webp support is disabled we exclude it from the list of known formats
        if(endings == "webp") {
            continue;
        }
#endif

#ifdef LIBVIPS
        const int libvips = query.record().value("libvips").toInt();
#endif
#ifdef IMAGEMAGICK
        const int imgmmagick = query.record().value("imagemagick").toInt();
#elif defined(GRAPHICSMAGICK)
        const int imgmmagick = query.record().value("graphicsmagick").toInt();
#endif
#ifdef RAW
        const int libraw = query.record().value("libraw").toInt();
#endif
#if defined(POPPLER) || defined(QTPDF)
        const int poppler = query.record().value("poppler").toInt();
#endif
        const int xcftools = query.record().value("xcftools").toInt();
#ifdef DEVIL
        const int devil = query.record().value("devil").toInt();
#endif
#ifdef FREEIMAGE
        const int freeimage = query.record().value("freeimage").toInt();
#endif
#ifdef LIBARCHIVE
        const int archive = query.record().value("archive").toInt();
#endif
#ifdef VIDEOQT
        const int video = query.record().value("video").toInt();
#endif
#ifdef VIDEOMPV
        const int libmpv = query.record().value("libmpv").toInt();
#endif
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
        const QString im_gm_magick = query.record().value("im_gm_magick").toString();
#endif
        const QString qt_formatname = query.record().value("qt_formatname").toString();

        bool supportedByAnyLibrary = false;
        bool magickToBeAdded = false;

        QList<QVariant> all;
        all << endings;
        all << enabled;
        all << desc;
        all << cat;
        if(qt) {
            // we check the formats against the list of supported image formats
            // this list can vary depending on which plugins are installed
            if(qtSupported.contains(qt_formatname.toUtf8())) {
                supportedByAnyLibrary = true;
                all << "Qt";
                formats_qt << endings.split(",");
                if(mimetypes != "")
                    mimetypes_qt << mimetypes.split(",");
            }
        }

#ifdef LIBVIPS
        if(libvips) {
            supportedByAnyLibrary = true;
            all << "libvips";
            formats_libvips << endings.split(",");
            if(mimetypes != "")
                mimetypes_libvips << mimetypes.split(",");
        }
#endif

        QStringList validImGmMagick;

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
        if(imgmmagick) {

            // we check with the Magick++ API to see if each format is readable
            // by default we assume it is and if either no codec is available (exception thrown)
            // or when it is reported as not readable, then we skip this format
            bool alright = true;
            if(im_gm_magick != "") {
#if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
                QStringList tmp = im_gm_magick.split(",", Qt::SkipEmptyParts);
#else
                QStringList tmp = im_gm_magick.split(",", QString::SkipEmptyParts);
#endif

                for(const auto &t: qAsConst(tmp)) {
                    try {
                        Magick::CoderInfo magickCoderInfo(t.toStdString());
                        if(magickCoderInfo.isReadable())
                            validImGmMagick << t;
                    } catch(Magick::Exception &) {
                        // do nothing here
                    }
                }
                alright = (validImGmMagick.length()>0);
            }

            if(alright) {
                supportedByAnyLibrary = true;
                magickToBeAdded = true;
#ifdef IMAGEMAGICK
                all << "ImageMagick";
#elif defined(GRAPHICSMAGICK)
                all << "GraphicsMagick";
#endif
                formats_magick << endings.split(",");
                if(mimetypes != "")
                    mimetypes_magick << mimetypes.split(",");
            }
        }
#endif
#ifdef RAW
        if(libraw) {
            supportedByAnyLibrary = true;
            all << "libraw";
            formats_libraw << endings.split(",");
            if(mimetypes != "")
                mimetypes_libraw << mimetypes.split(",");
        }
#endif
#if defined(POPPLER) || defined(QTPDF)
        if(poppler) {
            supportedByAnyLibrary = true;
            all << "Poppler";
            formats_poppler << endings.split(",");
            if(mimetypes != "")
                mimetypes_poppler << mimetypes.split(",");
        }
#endif
        if(xcftools) {
            supportedByAnyLibrary = true;
            all << "XCFTools";
            formats_xcftools << endings.split(",");
            if(mimetypes != "")
                mimetypes_xcftools << mimetypes.split(",");
        }
#ifdef DEVIL
        if(devil) {
            supportedByAnyLibrary = true;
            all << "DevIL";
            formats_devil << endings.split(",");
            if(mimetypes != "")
                mimetypes_devil << mimetypes.split(",");
        }
#endif
#ifdef FREEIMAGE
        if(freeimage) {
            supportedByAnyLibrary = true;
            all << "FreeImage";
            formats_freeimage << endings.split(",");
            if(mimetypes != "")
                mimetypes_freeimage << mimetypes.split(",");
        }
#endif
#ifdef LIBARCHIVE
        if(archive) {
            supportedByAnyLibrary = true;
            all << "LibArchive";
            formats_archive << endings.split(",");
            if(mimetypes != "")
                mimetypes_archive << mimetypes.split(",");
        }
#endif
#ifdef VIDEOQT
        if(video) {
            supportedByAnyLibrary = true;
            all << "Video";
            formats_video << endings.split(",");
            if(mimetypes != "")
                mimetypes_video << mimetypes.split(",");
        }
#endif
#ifdef VIDEOMPV
        if(libmpv) {
            supportedByAnyLibrary = true;
            all << "libmpv";
            formats_libmpv << endings.split(",");
            if(mimetypes != "")
                mimetypes_libmpv << mimetypes.split(",");
        }
#endif

        if(supportedByAnyLibrary) {

            formats << QVariant::fromValue(all);

            if(enabled) {
                formats_enabled << endings.split(",");
                if(mimetypes != "")
                    mimetypes_enabled << mimetypes.split(",");
            }
            if(magickToBeAdded && validImGmMagick.length() > 0) {
                for(QString &e : endings.split(",")) {
                    if(magick.contains(e))
                        magick[e] = QStringList() << magick[e].toStringList() << validImGmMagick;
                    else
                        magick.insert(e, QStringList() << validImGmMagick);
                }
                for(QString &mt : mimetypes.split(",")) {
                    if(magick_mimetype.contains(mt))
                        magick_mimetype[mt] = QStringList() << magick_mimetype[mt].toStringList() << validImGmMagick;
                    else
                        magick_mimetype.insert(mt, QStringList() << validImGmMagick);
                }
            }

        }
    }

}

void PQImageFormats::writeToDatabase(QVariantList f) {

    DBG << CURDATE << "PQImageFormats::writeToDatabase()" << NL;

    if(readonly) return;

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
    if(!db.lastError().text().trimmed().isEmpty())
        LOG << CURDATE << "PQImageFormats::writeToDatabase(): SQL Query error: " << db.lastError().text().trimmed().toStdString() << NL;

    readFromDatabase();

}

QVariantList PQImageFormats::getWriteableFormats() {

    DBG << CURDATE << "PQImageFormats::getWriteableFormats()" << NL;

    QVariantList ret;

    QImageWriter writer;
    QSqlQuery query("SELECT * FROM imageformats ORDER BY qt DESC", db);
    while(query.next()) {

        QString qt_formatname = query.record().value("qt_formatname").toString();
        const QString endings = query.record().value("endings").toString();
        const QString description = query.record().value("description").toString();
        const QString magick = query.record().value("im_gm_magick").toString();

        bool qt = false;
        bool imgm = false;
        if(qt_formatname != "" &&writer.supportedImageFormats().contains(qt_formatname.toUtf8()))
            qt = true;
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
        else if(magick != "") {
            try {
                Magick::CoderInfo magickCoderInfo(magick.toStdString());
                if(magickCoderInfo.isReadable() && magickCoderInfo.isWritable())
                    imgm = true;
            } catch(Magick::Exception &) {}
        }
#endif

        if(qt || imgm) {

            QVariantList entry;
            entry << (qt&&imgm ? "qt/magick" : (qt ? "qt" : "magick"));
            entry << endings << description << magick;

            ret << QVariant::fromValue(entry);
        }
    }

    return ret;

}

QVariantMap PQImageFormats::getFormatsInfo(QString endings) {

    DBG << CURDATE << "PQImageFormats::getFormatsInfo()" << NL;

    QVariantMap ret;

    QSqlQuery query(db);
    query.prepare("SELECT * FROM imageformats WHERE endings=:endings");
    query.bindValue(":endings", endings);
    if(!query.exec()) {
        LOG << CURDATE << "PQImageFormats::getFormatsInfo(): SQL Query error: " << query.lastError().text().trimmed().toStdString() << NL;
        return ret;
    }

    if(!query.next()) {
        LOG << CURDATE << "PQImageFormats::getFormatsInfo(): No SQL results returned" << NL;
        return ret;
    }

    ret.insert("endings", endings);
    ret.insert("mimetypes", query.record().value("mimetypes"));
    ret.insert("description", query.record().value("description"));
    ret.insert("category", query.record().value("category"));
    ret.insert("enabled", query.record().value("enabled"));
    ret.insert("qt", query.record().value("qt"));
    ret.insert("libvips", query.record().value("libvips"));
    ret.insert("imagemagick", query.record().value("imagemagick"));
    ret.insert("graphicsmagick", query.record().value("graphicsmagick"));
    ret.insert("libraw", query.record().value("libraw"));
    ret.insert("poppler", query.record().value("poppler"));
    ret.insert("xcftools", query.record().value("xcftools"));
    ret.insert("devil", query.record().value("devil"));
    ret.insert("freeimage", query.record().value("freeimage"));
    ret.insert("archive", query.record().value("archive"));
    ret.insert("video", query.record().value("video"));
    ret.insert("libmpv", query.record().value("libmpv"));
    ret.insert("im_gm_magick", query.record().value("im_gm_magick"));
    ret.insert("qt_formatname", query.record().value("qt_formatname"));

    return ret;

}

bool PQImageFormats::enterNewFormat(QString endings, QString mimetypes, QString description, QString category, int enabled,
                                    int qt, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv,
                                    QString im_gm_magick, QString qt_formatname,
                                    bool silentIfExists = false) {

    // first check that it doesn't exist yet

    QSqlQuery query(db);
    query.prepare("SELECT COUNT(endings) AS NumFormats FROM imageformats WHERE description=:description");
    query.bindValue(":description", description);
    if(!query.exec()) {
        LOG << CURDATE << "PQImageFormats::enterNewFormat(): SQL Query error (1): " << query.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    if(!query.next()) {
        LOG << CURDATE << "PQImageFormats::enterNewFormat(): No SQL results returned" << NL;
        return false;
    }

    int howmany = query.record().value("NumFormats").toInt();
    if(howmany != 0) {
        if(!silentIfExists)
            LOG << CURDATE << "PQImageFormats::enterNewFormat(): Found " << howmany << " format with the new descrption, not entering anything new." << NL;
        return false;
    }

    QSqlQuery query2(db);
    query2.prepare("INSERT INTO imageformats (endings, mimetypes, description, category, enabled, qt, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv, im_gm_magick, qt_formatname) VALUES (:endings, :mimetypes, :description, :category, :enabled, :qt, :libvips, :imagemagick, :graphicsmagick, :libraw, :poppler, :xcftools, :devil, :freeimage, :archive, :video, :libmpv, :im_gm_magick, :qt_formatname)");

    query2.bindValue(":endings", endings);
    query2.bindValue(":mimetypes", mimetypes);
    query2.bindValue(":description", description);
    query2.bindValue(":category", category);
    query2.bindValue(":enabled", enabled);
    query2.bindValue(":qt", qt);
    query2.bindValue(":libvips", libvips);
    query2.bindValue(":imagemagick", imagemagick);
    query2.bindValue(":graphicsmagick", graphicsmagick);
    query2.bindValue(":libraw", libraw);
    query2.bindValue(":poppler", poppler);
    query2.bindValue(":xcftools", xcftools);
    query2.bindValue(":devil", devil);
    query2.bindValue(":freeimage", freeimage);
    query2.bindValue(":archive", archive);
    query2.bindValue(":video", video);
    query2.bindValue(":libmpv", libmpv);
    query2.bindValue(":im_gm_magick", im_gm_magick);
    query2.bindValue(":qt_formatname", qt_formatname);

    if(!query2.exec()) {
        LOG << CURDATE << "PQImageFormats::enterNewFormat(): SQL Query error (2): " << query2.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    // it is recommended to re-read the database after inserting formats
    // it is not done automatically as this function might be called multiple times
    // thus it should be taken care of from whererever this function is called.

    return true;

}

bool PQImageFormats::updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category, int enabled,
                                          int qt, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv,
                                          QString im_gm_magick, QString qt_formatname,
                                          bool silentIfExists = false) {

    // first check that it doesn't exist yet

    QSqlQuery query(db);
    query.prepare("SELECT COUNT(endings) AS NumFormats FROM imageformats WHERE description=:description");
    query.bindValue(":description", description);
    if(!query.exec()) {
        LOG << CURDATE << "PQImageFormats::updateFormatByEnding(): SQL Query error (1): " << query.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    if(!query.next()) {
        LOG << CURDATE << "PQImageFormats::updateFormatByEnding(): No SQL results returned" << NL;
        return false;
    }

    // if it doesn't exist yet, then it might need to be entered as new
    int howmany = query.record().value("NumFormats").toInt();
    if(howmany != 1) {
        return enterNewFormat(endings, mimetypes, description, category, enabled,
                              qt, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv,
                              im_gm_magick, qt_formatname, silentIfExists);
    }

    QSqlQuery query2(db);
    query2.prepare("UPDATE imageformats SET  mimetypes=:mimetypes, description=:description, category=:category, enabled=:enabled, qt=:qt, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, libmpv=:libmpv, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE endings=:endings");

    query2.bindValue(":endings", endings);
    query2.bindValue(":mimetypes", mimetypes);
    query2.bindValue(":description", description);
    query2.bindValue(":category", category);
    query2.bindValue(":enabled", enabled);
    query2.bindValue(":qt", qt);
    query2.bindValue(":libvips", libvips);
    query2.bindValue(":imagemagick", imagemagick);
    query2.bindValue(":graphicsmagick", graphicsmagick);
    query2.bindValue(":libraw", libraw);
    query2.bindValue(":poppler", poppler);
    query2.bindValue(":xcftools", xcftools);
    query2.bindValue(":devil", devil);
    query2.bindValue(":freeimage", freeimage);
    query2.bindValue(":archive", archive);
    query2.bindValue(":video", video);
    query2.bindValue(":libmpv", libmpv);
    query2.bindValue(":im_gm_magick", im_gm_magick);
    query2.bindValue(":qt_formatname", qt_formatname);

    if(!query2.exec()) {
        LOG << CURDATE << "PQImageFormats::updateFormatByEnding(): SQL Query error (2): " << query2.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    // it is recommended to re-read the database after updating formats
    // it is not done automatically as this function might be called multiple times
    // thus it should be taken care of from whererever this function is called.

    return true;

}

void PQImageFormats::restoreDefaults() {

    db.close();

    QSqlDatabase::removeDatabase("imageformats");

    if(!QFile::remove(ConfigFiles::IMAGEFORMATS_DB())) {
        LOG << CURDATE << "PQImageFormats::restoreDefaults(): Error removing old database." << NL;
        return;
    }

    if(!QFile::copy(":/imageformats.db", ConfigFiles::IMAGEFORMATS_DB())) {
        LOG << CURDATE << "PQImageFormats::restoreDefaults(): Error copying over new database." << NL;
        return;
    }

    QFile file(ConfigFiles::IMAGEFORMATS_DB());
    if(!file.setPermissions(file.permissions()|QFile::WriteOwner)) {
        LOG << CURDATE << "PQImageFormats::restoreDefaults(): Error setting write permission to new database, setting read-only flag." << NL;
        readonly = true;
        return;
    }

    if(!db.open()) {
        LOG << CURDATE << "PQImageFormats::restoreDefaults(): Error opening new database: " << db.lastError().text().trimmed().toStdString() << NL;
        return;
    }

    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "imageformats");
    else
        db = QSqlDatabase::addDatabase("QSQLITE", "imageformats");
    db.setDatabaseName(ConfigFiles::IMAGEFORMATS_DB());

    readFromDatabase();

}
