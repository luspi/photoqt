/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#include <QImageReader>
#include <QFileInfo>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>
#include <QMessageBox>
#include <QImageWriter>
#include <QMimeDatabase>
#include <pqc_imageformats.h>
#include <pqc_configfiles.h>
#include <pqc_notify.h>

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#endif

PQCImageFormats::PQCImageFormats() {

    // connect to database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "imageformats");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "imageformats");
    db.setDatabaseName(PQCConfigFiles::IMAGEFORMATS_DB());

    QFileInfo infodb(PQCConfigFiles::IMAGEFORMATS_DB());

    if(!infodb.exists() || !db.open()) {

        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "Will load built-in read-only database of imageformats";

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/imageformats.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/imageformats.db", tmppath)) {
            //: This is the window title of an error message box
            QMessageBox::critical(0, QCoreApplication::translate("PQCImageFormats", "ERROR getting default image formats"),
                                  QCoreApplication::translate("PQCImageFormats", "Not even a read-only version of the database of default image formats could be opened.") + QCoreApplication::translate("PQCImageFormats", "Something went terribly wrong somewhere!"));
            qCritical() << "ERROR copying read-only default database!";
            qApp->quit();
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            QMessageBox::critical(0, QCoreApplication::translate("PQCImageFormats", "ERROR getting default image formats"),
                                  QCoreApplication::translate("PQCImageFormats", "Not even a read-only version of the database of default image formats could be opened.") + QCoreApplication::translate("PQCImageFormats", "Something went terribly wrong somewhere!"));
            qCritical() << "ERROR opening read-only default database!";
            qApp->quit();
            return;
        }

        readFromDatabase();

    } else {

        readonly = false;
        if(!infodb.permission(QFileDevice::WriteOwner))
            readonly = true;

        readFromDatabase();

    }

    connect(&PQCNotify::get(), &PQCNotify::resetFormatsToDefault, this, &PQCImageFormats::restoreDefaults);

}

void PQCImageFormats::readFromDatabase() {

    qDebug() << "";

    formats.clear();
    formats_enabled.clear();
    formats_qt.clear();
    formats_resvg.clear();
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
    mimetypes_resvg.clear();
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

    QSqlQuery query("SELECT * FROM imageformats ORDER BY description ASC", db);

    while(query.next()) {

        const QString endings = query.record().value("endings").toString();
        const QString mimetypes = query.record().value("mimetypes").toString();
        const QString desc = query.record().value("description").toString();
        const QString cat = query.record().value("category").toString();
        const int enabled = query.record().value("enabled").toInt();
        const int qt = query.record().value("qt").toInt();
#ifdef PQMLIBVIPS
        const int libvips = query.record().value("libvips").toInt();
#endif
#ifdef PQMRESVG
        const int resvg = query.record().value("resvg").toInt();
#endif
#ifdef PQMIMAGEMAGICK
        const int imgmmagick = query.record().value("imagemagick").toInt();
#elif defined(PQMGRAPHICSMAGICK)
        const int imgmmagick = query.record().value("graphicsmagick").toInt();
#endif
#ifdef PQMRAW
        const int libraw = query.record().value("libraw").toInt();
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
        const int poppler = query.record().value("poppler").toInt();
#endif
        const int xcftools = query.record().value("xcftools").toInt();
#ifdef PQMDEVIL
        const int devil = query.record().value("devil").toInt();
#endif
#ifdef PQMFREEIMAGE
        const int freeimage = query.record().value("freeimage").toInt();
#endif
#ifdef PQMLIBARCHIVE
        const int archive = query.record().value("archive").toInt();
#endif
#ifdef PQMVIDEOQT
        const int video = query.record().value("video").toInt();
#endif
#ifdef PQMVIDEOMPV
        const int libmpv = query.record().value("libmpv").toInt();
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
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

#ifdef PQMRESVG
        if(resvg) {
            supportedByAnyLibrary = true;
            all << "resvg";
            formats_resvg << endings.split(",");
            if(mimetypes != "")
                mimetypes_resvg << mimetypes.split(",");
        }
#endif

#ifdef PQMLIBVIPS
        if(libvips) {
            supportedByAnyLibrary = true;
            all << "libvips";
            formats_libvips << endings.split(",");
            if(mimetypes != "")
                mimetypes_libvips << mimetypes.split(",");
        }
#endif

        QStringList validImGmMagick;

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
        if(imgmmagick) {

            // we check with the Magick++ API to see if each format is readable
            // by default we assume it is and if either no codec is available (exception thrown)
            // or when it is reported as not readable, then we skip this format
            bool alright = true;
            if(im_gm_magick != "") {
                const QStringList tmp = im_gm_magick.split(",", Qt::SkipEmptyParts);
                for(const auto &t: tmp) {
                    try {
                        Magick::CoderInfo magickCoderInfo(t.toStdString());
                        if(magickCoderInfo.isReadable())
                            validImGmMagick << t;
                    } catch(...) {
                        // do nothing here
                    }
                }
                alright = (validImGmMagick.length()>0);
            }

            if(alright) {
                supportedByAnyLibrary = true;
                magickToBeAdded = true;
#ifdef PQMIMAGEMAGICK
                all << "ImageMagick";
#elif defined(PQMGRAPHICSMAGICK)
                all << "GraphicsMagick";
#endif
                formats_magick << endings.split(",");
                if(mimetypes != "")
                    mimetypes_magick << mimetypes.split(",");
            }
        }
#endif
#ifdef PQMRAW
        if(libraw) {
            supportedByAnyLibrary = true;
            all << "libraw";
            formats_libraw << endings.split(",");
            if(mimetypes != "")
                mimetypes_libraw << mimetypes.split(",");
        }
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
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
#ifdef PQMDEVIL
        if(devil) {
            supportedByAnyLibrary = true;
            all << "DevIL";
            formats_devil << endings.split(",");
            if(mimetypes != "")
                mimetypes_devil << mimetypes.split(",");
        }
#endif
#ifdef PQMFREEIMAGE
        if(freeimage) {
            supportedByAnyLibrary = true;
            all << "FreeImage";
            formats_freeimage << endings.split(",");
            if(mimetypes != "")
                mimetypes_freeimage << mimetypes.split(",");
        }
#endif
#ifdef PQMLIBARCHIVE
        if(archive) {
            supportedByAnyLibrary = true;
            all << "LibArchive";
            formats_archive << endings.split(",");
            if(mimetypes != "")
                mimetypes_archive << mimetypes.split(",");
        }
#endif
#ifdef PQMVIDEOQT
        if(video) {
            supportedByAnyLibrary = true;
            all << "Video";
            formats_video << endings.split(",");
            if(mimetypes != "")
                mimetypes_video << mimetypes.split(",");
        }
#endif
#ifdef PQMVIDEOMPV
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

    Q_EMIT formatsUpdated();

}

void PQCImageFormats::writeToDatabase(QVariantList f) {

    qDebug() << "args.length: f.length =" << f.length();

    if(readonly) return;

    db.transaction();

    for(QVariant entry : f) {

        QSqlQuery query(db);
        query.prepare("UPDATE imageformats SET enabled=:enabled WHERE endings=:endings");
        query.bindValue(":enabled", entry.toList()[1].toInt());
        query.bindValue(":endings", entry.toList()[0].toString());
        if(!query.exec())
            qWarning() << "SQL Query error:" << query.lastError().text();

    }

    db.commit();
    if(!db.lastError().text().trimmed().isEmpty())
        qWarning() << "SQL Query error:" << db.lastError().text();

    readFromDatabase();

}

QVariantList PQCImageFormats::getWriteableFormats() {

    qDebug() << "";

    QVariantList ret;

    QImageWriter writer;
    QSqlQuery query("SELECT uniqueid,qt_formatname,endings,description,im_gm_magick FROM imageformats ORDER BY description ASC", db);
    while(query.next()) {

        const QString uniqueid = query.value(0).toString();
        QString qt_formatname = query.value(1).toString();
        const QString endings = query.value(2).toString();
        const QString description = query.value(3).toString();
        const QString magick = query.value(4).toString();

        bool qt = false;
        bool imgm = false;
        if(qt_formatname != "" && writer.supportedImageFormats().contains(qt_formatname.toUtf8()))
            qt = true;
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
        else if(magick != "") {
            try {
                Magick::CoderInfo magickCoderInfo(magick.toStdString());
                if(magickCoderInfo.isReadable() && magickCoderInfo.isWritable())
                    imgm = true;
            } catch(...) {
                // do nothing here
            }
        }
#endif

        if(qt || imgm) {

            QVariantList entry;
            entry << (qt&&imgm ? "qt/magick" : (qt ? "qt" : "magick"));
            entry << uniqueid << endings << description << magick;

            ret << QVariant::fromValue(entry);
        }
    }

    return ret;

}

QString PQCImageFormats::getFormatName(int uniqueid) {

    qDebug() << "args: uniqueid =" << uniqueid;

    QSqlQuery query(db);
    query.prepare("SELECT description FROM imageformats WHERE uniqueid=:uniqueid");
    query.bindValue(":uniqueid", uniqueid);
    if(!query.exec()) {
        qWarning() << "SQL Query error:" << query.lastError().text();
        return "[unknown]";
    }

    if(!query.next()) {
        qWarning() << "No SQL results returned";
        return "[unknown]";
    }

    return query.value(0).toString();

}

QStringList PQCImageFormats::getFormatEndings(int uniqueid) {

    qDebug() << "args: uniqueid =" << uniqueid;

    QSqlQuery query(db);
    query.prepare("SELECT endings FROM imageformats WHERE uniqueid=:uniqueid");
    query.bindValue(":uniqueid", uniqueid);
    if(!query.exec()) {
        qWarning() << "SQL Query error:" << query.lastError().text();
        return QStringList();
    }

    if(!query.next()) {
        qWarning() << "No SQL results returned";
        return QStringList();
    }

    return query.value(0).toString().split(",");

}

QVariantMap PQCImageFormats::getFormatsInfo(int uniqueid) {

    qDebug() << "args: uniqueid =" << uniqueid;

    QVariantMap ret;

    QSqlQuery query(db);
    query.prepare("SELECT * FROM imageformats WHERE uniqueid=:uniqueid");
    query.bindValue(":uniqueid", uniqueid);
    if(!query.exec()) {
        qWarning() << "SQL Query error:" << query.lastError().text();
        return ret;
    }

    if(!query.next()) {
        qWarning() << "No SQL results returned";
        return ret;
    }

    ret.insert("uniqueid", uniqueid);
    ret.insert("endings", query.record().value("endings"));
    ret.insert("mimetypes", query.record().value("mimetypes"));
    ret.insert("description", query.record().value("description"));
    ret.insert("category", query.record().value("category"));
    ret.insert("enabled", query.record().value("enabled"));
    ret.insert("qt", query.record().value("qt"));
    ret.insert("resvg", query.record().value("resvg"));
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

int PQCImageFormats::detectFormatId(QString filename) {

    QFileInfo info(filename);
    QString suffix = info.suffix();

    QMimeDatabase mimedb;
    QString mimetype = mimedb.mimeTypeForFile(filename).name();

    if(mimetype != "") {

        QSqlQuery query(db);
        query.prepare("SELECT uniqueid FROM imageformats WHERE mimetypes LIKE :mimetype");
        query.bindValue(":mimetype", QString("%%%1%%").arg(mimetype));
        if(query.exec()) {
            if(query.next())
                return query.record().value(0).toInt();
        } else
            qDebug() << "SQL error:" << query.lastError().text();

    }

    QSqlQuery query(db);
    query.prepare("SELECT uniqueid FROM imageformats WHERE endings LIKE :endings1 OR endings LIKE :endings2 OR endings LIKE :endings3 or endings=:endings4");
    query.bindValue(":endings1", QString("%1,%%").arg(suffix));
    query.bindValue(":endings2", QString("%%,%1,%%").arg(suffix));
    query.bindValue(":endings3", QString("%%,%1").arg(suffix));
    query.bindValue(":endings4", suffix);
    if(query.exec()) {
        if(query.next())
            return query.record().value(0).toInt();
    } else
        qDebug() << "SQL error:" << query.lastError().text();

    return -1;

}

// return: 0 (not writable), 1 (qt/magick), 2 (qt), 3 (magick)
int PQCImageFormats::getWriteStatus(int uniqueid) {

    QImageWriter writer;
    QSqlQuery query(db);
    query.prepare("SELECT qt_formatname,im_gm_magick FROM imageformats WHERE uniqueid=:uniqueid ORDER BY qt DESC, description ASC");
    query.bindValue(":uniqueid", uniqueid);
    if(!query.exec()) {
        qDebug() << "SQL error:" << query.lastError().text();
        return 0;
    }
    if(!query.next()) {
        qDebug() << "No results found";
        return 0;
    }

    QString qt_formatname = query.value(0).toString();
    const QString magick = query.value(1).toString();

    bool qt = false;
    bool imgm = false;
    if(qt_formatname != "" && writer.supportedImageFormats().contains(qt_formatname.toUtf8()))
        qt = true;
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    else if(magick != "") {
        try {
            Magick::CoderInfo magickCoderInfo(magick.toStdString());
            if(magickCoderInfo.isReadable() && magickCoderInfo.isWritable())
                imgm = true;
        } catch(...) {
            // do nothing here
        }
    }
#endif

    if(qt && imgm)
        return 1;

    if(qt)
        return 2;

    if(imgm)
        return 3;

    return 0;

}

bool PQCImageFormats::enterNewFormat(QString endings, QString mimetypes, QString description, QString category, int enabled,
                                    int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv,
                                    QString im_gm_magick, QString qt_formatname,
                                    bool silentIfExists = false) {

    // first check that it doesn't exist yet

    QSqlQuery query(db);
    query.prepare("SELECT COUNT(endings) AS NumFormats FROM imageformats WHERE description=:description");
    query.bindValue(":description", description);
    if(!query.exec()) {
        qWarning() << "SQL Query error:" << query.lastError().text();
        return false;
    }

    if(!query.next()) {
        qWarning() << "No SQL results returned";
        return false;
    }

    int howmany = query.record().value("NumFormats").toInt();
    if(howmany != 0) {
        if(!silentIfExists)
            qDebug() << "Found" << howmany << "format with the new descrption, not entering anything new.";
        return false;
    }

    QSqlQuery query2(db);
    query2.prepare("INSERT INTO imageformats (endings, mimetypes, description, category, enabled, qt, resvg, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv, im_gm_magick, qt_formatname) VALUES (:endings, :mimetypes, :description, :category, :enabled, :qt, :resvg, :libvips, :imagemagick, :graphicsmagick, :libraw, :poppler, :xcftools, :devil, :freeimage, :archive, :video, :libmpv, :im_gm_magick, :qt_formatname)");

    query2.bindValue(":endings", endings);
    query2.bindValue(":mimetypes", mimetypes);
    query2.bindValue(":description", description);
    query2.bindValue(":category", category);
    query2.bindValue(":enabled", enabled);
    query2.bindValue(":qt", qt);
    query2.bindValue(":resvg", resvg);
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
        qWarning() << "SQL Query error:" << query2.lastError().text();
        return false;
    }

    // it is recommended to re-read the database after inserting formats
    // it is not done automatically as this function might be called multiple times
    // thus it should be taken care of from whererever this function is called.

    return true;

}

bool PQCImageFormats::updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category, int enabled,
                                          int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv,
                                          QString im_gm_magick, QString qt_formatname,
                                          bool silentIfExists = false) {

    // first check that it doesn't exist yet

    QSqlQuery query(db);
    query.prepare("SELECT COUNT(endings) AS NumFormats FROM imageformats WHERE description=:description");
    query.bindValue(":description", description);
    if(!query.exec()) {
        qWarning() << "SQL Query error:" << query.lastError().text();
        return false;
    }

    if(!query.next()) {
        qDebug() << "No SQL results returned";
        return false;
    }

    // if it doesn't exist yet, then it might need to be entered as new
    int howmany = query.record().value("NumFormats").toInt();
    if(howmany != 1) {
        return enterNewFormat(endings, mimetypes, description, category, enabled,
                              qt, resvg, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv,
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
    query2.bindValue(":resvg", resvg);
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
        qWarning() << "SQL Query error:" << query2.lastError().text();
        return false;
    }

    // it is recommended to re-read the database after updating formats
    // it is not done automatically as this function might be called multiple times
    // thus it should be taken care of from whererever this function is called.

    return true;

}

void PQCImageFormats::restoreDefaults() {

    qDebug() << "readonly =" << readonly;

    if(readonly)
        return;

    db.transaction();

    // open database
    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "shortcutsrestoredefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "shortcutsrestoredefault");
    else {
        qCritical() << "ERROR: SQLite driver not available. Available drivers are:" << QSqlDatabase::drivers().join(",");
        qCritical() << "PhotoQt cannot function without SQLite available.";
        return;
    }

    QFile::remove(PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/imageformats.db", PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                              QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!dbdefault.open()) {
        qWarning() << "SQL error:" << dbdefault.lastError().text();
        dbdefault.close();
        return;
    }

    QSqlQuery queryDefault(dbdefault);
    if(!queryDefault.exec("SELECT * FROM 'imageformats'")) {
        qCritical() << "SQL error:" << queryDefault.lastError().text();
        queryDefault.clear();
        dbdefault.close();
        return;
    }

    while(queryDefault.next()) {

        QMap<QString,QVariant> vals;
        for(int i = 0; i < queryDefault.record().count(); ++i)
            vals.insert(queryDefault.record().fieldName(i), queryDefault.record().value(i));

        const QStringList keys = vals.keys();

        QString str = "UPDATE 'imageformats' SET ";
        bool first = true;
        for(const QString &k : keys) {
            if(!first) str += ", ";
            first = false;
            str += QString("`%1`=:%2").arg(k,k);
        }
        str += QString(" WHERE `uniqueid`=%1").arg(vals["uniqueid"].toInt());

        QSqlQuery query(db);
        query.prepare(str);

        for(const QString &k : keys)
            query.bindValue(QString(":%1").arg(k), vals[k]);

        if(!query.exec()) {
            qCritical() << "SQL error:" << query.lastError().text();
            query.clear();
            dbdefault.close();
            return;
        }
        query.clear();

    }


    queryDefault.clear();
    dbdefault.close();

    db.commit();
    if(db.lastError().text().trimmed().length())
        qWarning() << "ERROR committing database:" << db.lastError().text();

    readFromDatabase();

}

void PQCImageFormats::closeDatabase() {

    db.close();

}
