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

#include <QImageReader>
#include <QFileInfo>
#include <QApplication>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>
#include <QMessageBox>
#include <QImageWriter>
#include <QMimeDatabase>

#include <cpp/pqc_imageformats.h>
#include <cpp/pqc_validate.h>
#include <shared/pqc_configfiles.h>

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#endif

PQCImageFormats::PQCImageFormats() {

    // connect to database
    db = QSqlDatabase::database("imageformats");

    QFileInfo infodb(PQCConfigFiles::get().IMAGEFORMATS_DB());

    if(!infodb.exists()) {
        if(!QFile::copy(":/imageformats.db", PQCConfigFiles::get().IMAGEFORMATS_DB()))
            qWarning() << "Unable to (re-)create default imageformats database";
        else {
            QFile file(PQCConfigFiles::get().IMAGEFORMATS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    if(!db.open()) {

        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "Will load built-in read-only database of imageformats";

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/imageformats.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/imageformats.db", tmppath)) {
            //: This is the window title of an error message box
            QMessageBox::critical(0, QApplication::translate("PQCImageFormats", "ERROR getting default image formats"),
                                  QApplication::translate("PQCImageFormats", "Not even a read-only version of the database of default image formats could be opened.") + QApplication::translate("PQCImageFormats", "Something went terribly wrong somewhere!"));
            qCritical() << "ERROR copying read-only default database!";
            qApp->quit();
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            QMessageBox::critical(0, QApplication::translate("PQCImageFormats", "ERROR getting default image formats"),
                                  QApplication::translate("PQCImageFormats", "Not even a read-only version of the database of default image formats could be opened.") + QApplication::translate("PQCImageFormats", "Something went terribly wrong somewhere!"));
            qCritical() << "ERROR opening read-only default database!";
            qApp->quit();
            return;
        }

    } else {

        readonly = false;
        if(!infodb.permission(QFileDevice::WriteOwner))
            readonly = true;

    }

    // on updates we validate database
    int chk = checkForUpdateOrNew();
    if(chk == 1) {
        PQCValidate::validateImageFormatsDatabase();
    }
    readFromDatabase();

}

int PQCImageFormats::checkForUpdateOrNew() {

    // 0 := no update
    // 1 := update
    // 2 := new install
    int updateornew = 0;

    // make sure db exists
    QFileInfo info(PQCConfigFiles::get().IMAGEFORMATS_DB());
    if(!info.exists()) {
        updateornew = 2;
        if(!QFile::copy(":/imageformats.db", PQCConfigFiles::get().IMAGEFORMATS_DB()))
            qWarning() << "Unable to (re-)create default imageformats database";
        else {
            QFile file(PQCConfigFiles::get().IMAGEFORMATS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
            QSqlQuery queryEnter(db);
            queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', :ver)");
            queryEnter.bindValue(":ver", PQMVERSION);
            if(!queryEnter.exec()) {
                qCritical() << "Unable to enter version in new config table";
            }
        }
    }

    if(updateornew != 2) {

        // ensure config table exists
        QSqlQuery query(db);
        // check if config table exists
        if(!query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='config';")) {
            qCritical() << "Unable to verify existince of config table";
        } else {
            // the table does not exist
            if(!query.next()) {
                updateornew = 1;
                QSqlQuery queryNew(db);
                if(!queryNew.exec("CREATE TABLE 'config' ('name' TEXT UNIQUE, 'value' TEXT)")) {
                    qCritical() << "Unable to create config table";
                } else {
                    QSqlQuery queryEnter(db);
                    queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', :ver)");
                    queryEnter.bindValue(":ver", PQMVERSION);
                    if(!queryEnter.exec()) {
                        qCritical() << "Unable to enter version in new config table";
                    }
                }
            }
        }

    }

    // this means the db existed already AND the config table exists already
    if(updateornew == 0) {

        QSqlQuery query(db);
        if(!query.exec("SELECT `value` FROM `config` WHERE `name`='version'")) {
            qCritical() << "Unable to retrieve existing version number";
        } else {
            if(!query.next()) {
                QSqlQuery queryEnter(db);
                queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', :ver)");
                queryEnter.bindValue(":ver", PQMVERSION);
                if(!queryEnter.exec()) {
                    qCritical() << "Unable to enter version in new config table";
                }
            } else {
                const QString value = query.value(0).toString();
                const QString curver = PQMVERSION;
                if(curver != value) {
                    updateornew = 1;
                    QSqlQuery queryEnter(db);
                    queryEnter.prepare("UPDATE 'config' SET `value`=:ver WHERE `name`='version'");
                    queryEnter.bindValue(":ver", PQMVERSION);
                    if(!queryEnter.exec()) {
                        qCritical() << "Unable to enter version in new config table";
                    }
                }
            }
        }

    }

    return updateornew;

}

void PQCImageFormats::readFromDatabase() {

    qDebug() << "";

    formats.clear();            formats.reserve(200);
    formats_enabled.clear();    formats_enabled.reserve(300);
    formats_qt.clear();         formats_qt.reserve(125);
    formats_resvg.clear();      formats_resvg.reserve(10);
    formats_libvips.clear();    formats_libvips.reserve(75);
    formats_magick.clear();     formats_magick.reserve(250);
    formats_libraw.clear();     formats_libraw.reserve(100);
    formats_poppler.clear();    formats_poppler.reserve(4);
    formats_xcftools.clear();   formats_xcftools.reserve(2);
    formats_devil.clear();      formats_devil.reserve(60);
    formats_freeimage.clear();  formats_freeimage.reserve(80);
    formats_archive.clear();    formats_archive.reserve(15);
    formats_video.clear();      formats_video.reserve(40);
    formats_libmpv.clear();     formats_libmpv.reserve(40);
    formats_libsai.clear();     formats_libsai.reserve(2);

    mimetypes_enabled.clear();  mimetypes_enabled.reserve(100);
    mimetypes_qt.clear();       mimetypes_qt.reserve(65);
    mimetypes_resvg.clear();    mimetypes_resvg.reserve(5);
    mimetypes_libvips.clear();  mimetypes_libvips.reserve(30);
    mimetypes_magick.clear();   mimetypes_magick.reserve(85);
    mimetypes_libraw.clear();   mimetypes_libraw.reserve(8);
    mimetypes_poppler.clear();  mimetypes_poppler.reserve(8);
    mimetypes_xcftools.clear(); mimetypes_xcftools.reserve(2);
    mimetypes_devil.clear();    mimetypes_devil.reserve(35);
    mimetypes_freeimage.clear();mimetypes_freeimage.reserve(40);
    mimetypes_archive.clear();  mimetypes_archive.reserve(4);
    mimetypes_video.clear();    mimetypes_video.reserve(25);
    mimetypes_libmpv.clear();   mimetypes_libmpv.reserve(25);

    magick.clear();
    magick_mimetype.clear();

    const QList<QByteArray> qtSupported = QImageReader::supportedImageFormats();

    QSqlQuery query("SELECT endings,mimetypes,description,category,enabled,qt,resvg,"
                    "libvips,imagemagick,graphicsmagick,im_gm_magick,libraw,poppler,"
                    "xcftools,devil,freeimage,archive,video,libmpv,libsai,qt_formatname FROM imageformats ORDER BY description ASC", db);

    while(query.next()) {

        const QString endings = query.record().value("endings").toString();
        const QString mimetypes = query.record().value("mimetypes").toString();
        const QString desc = query.record().value("description").toString();
        const QString cat = query.record().value("category").toString();
        const int enabled = query.record().value("enabled").toInt();

        bool supportedByAnyLibrary = false;
        bool magickToBeAdded = false;

        QList<QVariant> all;
        all << endings;
        all << enabled;
        all << desc;
        all << cat;

        const QStringList endingsList = endings.split(",");
        const QStringList mimetypesList = mimetypes.split(",");

        if(query.record().value("qt").toInt()) {
            // we check the formats against the list of supported image formats
            // this list can vary depending on which plugins are installed
            if(qtSupported.contains(query.record().value("qt_formatname").toString().toUtf8())) {
                supportedByAnyLibrary = true;
                all << "Qt";
                formats_qt << endingsList;
                if(mimetypes != "")
                    mimetypes_qt << mimetypesList;
            }
        }

#ifdef PQMRESVG
        if(query.record().value("resvg").toInt()) {
            supportedByAnyLibrary = true;
            all << "resvg";
            formats_resvg << endingsList;
            if(mimetypes != "")
                mimetypes_resvg << mimetypesList;
        }
#endif

#ifdef PQMLIBVIPS
        if(query.record().value("libvips").toInt()) {
            supportedByAnyLibrary = true;
            all << "libvips";
            formats_libvips << endingsList;
            if(mimetypes != "")
                mimetypes_libvips << mimetypesList;
        }
#endif

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

#ifdef PQMIMAGEMAGICK
        if(query.record().value("imagemagick").toInt()) {
#elif defined(PQMGRAPHICSMAGICK)
        if(query.record().value("graphicsmagick").toInt()) {
#endif
            supportedByAnyLibrary = true;
            magickToBeAdded = true;
#ifdef PQMIMAGEMAGICK
            all << "ImageMagick";
#elif defined(PQMGRAPHICSMAGICK)
            all << "GraphicsMagick";
#endif
            formats_magick << endingsList;
            if(mimetypes != "")
                mimetypes_magick << mimetypesList;
        }
#endif
#ifdef PQMRAW
        if(query.record().value("libraw").toInt()) {
            supportedByAnyLibrary = true;
            all << "libraw";
            formats_libraw << endingsList;
            if(mimetypes != "")
                mimetypes_libraw << mimetypesList;
        }
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
        if(query.record().value("poppler").toInt()) {
            supportedByAnyLibrary = true;
            all << "Poppler";
            formats_poppler << endingsList;
            if(mimetypes != "")
                mimetypes_poppler << mimetypesList;
        }
#endif
        if(query.record().value("xcftools").toInt()) {
            supportedByAnyLibrary = true;
            all << "XCFTools";
            formats_xcftools << endingsList;
            if(mimetypes != "")
                mimetypes_xcftools << mimetypesList;
        }
#ifdef PQMDEVIL
        if(query.record().value("devil").toInt()) {
            supportedByAnyLibrary = true;
            all << "DevIL";
            formats_devil << endingsList;
            if(mimetypes != "")
                mimetypes_devil << mimetypesList;
        }
#endif
#ifdef PQMFREEIMAGE
        if(query.record().value("freeimage").toInt()) {
            supportedByAnyLibrary = true;
            all << "FreeImage";
            formats_freeimage << endingsList;
            if(mimetypes != "")
                mimetypes_freeimage << mimetypesList;
        }
#endif
#ifdef PQMLIBARCHIVE
        if(query.record().value("archive").toInt()) {
            supportedByAnyLibrary = true;
            all << "LibArchive";
            formats_archive << endingsList;
            if(mimetypes != "")
                mimetypes_archive << mimetypesList;
        }
#endif
#ifdef PQMVIDEOQT
        if(query.record().value("video").toInt()) {
            supportedByAnyLibrary = true;
            all << "Video";
            formats_video << endingsList;
            if(mimetypes != "")
                mimetypes_video << mimetypesList;
        }
#endif
#ifdef PQMVIDEOMPV
        if(query.record().value("libmpv").toInt()) {
            supportedByAnyLibrary = true;
            all << "libmpv";
            formats_libmpv << endingsList;
            if(mimetypes != "")
                mimetypes_libmpv << mimetypesList;
        }
#endif
#ifdef PQMLIBSAI
        if(query.record().value("libsai").toInt()) {
            supportedByAnyLibrary = true;
            all << "libsai";
            formats_libsai << endingsList;
            if(mimetypes != "")
                mimetypes_libsai << mimetypesList;
        }
#endif

        if(supportedByAnyLibrary) {

            formats << QVariant::fromValue(all);

            if(enabled) {
                formats_enabled << endingsList;
                if(mimetypes != "")
                    mimetypes_enabled << mimetypesList;
            }
            const QStringList imGmMagick = query.record().value("im_gm_magick").toString().split(",", Qt::SkipEmptyParts);
            if(magickToBeAdded && imGmMagick.length() > 0) {
                for(const QString &e : endingsList) {
                    if(magick.contains(e))
                        magick[e] = QStringList() << magick[e].toStringList() << imGmMagick;
                    else
                        magick.insert(e, QStringList() << imGmMagick);
                }
                for(const QString &mt : mimetypesList) {
                    if(magick_mimetype.contains(mt))
                        magick_mimetype[mt] = QStringList() << magick_mimetype[mt].toStringList() << imGmMagick;
                    else
                        magick_mimetype.insert(mt, QStringList() << imGmMagick);
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
    ret.insert("libsai", query.record().value("libsai"));
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
                                    int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai,
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
            qDebug() << "Found" << howmany << "format with the new description, not entering anything new.";
        return false;
    }

    QSqlQuery query2(db);
    query2.prepare("INSERT INTO imageformats (endings, mimetypes, description, category, enabled, qt, resvg, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv, libsai, im_gm_magick, qt_formatname) VALUES (:endings, :mimetypes, :description, :category, :enabled, :qt, :resvg, :libvips, :imagemagick, :graphicsmagick, :libraw, :poppler, :xcftools, :devil, :freeimage, :archive, :video, :libmpv, :libsai, :im_gm_magick, :qt_formatname)");

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
    query2.bindValue(":libsai", libsai);
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
                                           int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai,
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
                              qt, resvg, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv, libsai,
                              im_gm_magick, qt_formatname, silentIfExists);
    }

    QSqlQuery query2(db);
    query2.prepare("UPDATE imageformats SET  mimetypes=:mimetypes, description=:description, category=:category, enabled=:enabled, qt=:qt, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, libmpv=:libmpv, libsai=:libsai, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE endings=:endings");

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
    query2.bindValue(":libsai", libsai);
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

void PQCImageFormats::resetToDefault() {

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

    QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/imageformats.db", PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                              QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
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

    qDebug() << "";

    db.close();

}

void PQCImageFormats::reopenDatabase() {

    qDebug() << "";

    if(!db.open())
        qCritical() << "Unable to reopen database:" << db.lastError().text();

}
