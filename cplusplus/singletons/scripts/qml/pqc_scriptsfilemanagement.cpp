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

#include <scripts/qml/pqc_scriptsfilemanagement.h>
#include <scripts/pqc_scriptsundo.h>
#include <pqc_configfiles.h>
#include <pqc_imageformats.h>
#include <pqc_loadimage.h>
#include <QtDebug>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QStorageInfo>
#include <QDirIterator>
#include <QImageWriter>
#include <QImageReader>
#include <QtConcurrent/QtConcurrentRun>
#include <QFileDialog>
#ifdef WIN32
#include <thread>
#else
#include <unistd.h>
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif
#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

#ifdef PQMFLATPAKBUILD
#include <gio/gio.h>
#endif

PQCScriptsFileManagement::PQCScriptsFileManagement() {}

PQCScriptsFileManagement::~PQCScriptsFileManagement() {}

bool PQCScriptsFileManagement::copyFileToHere(QString filename, QString targetdir) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetdir =" << targetdir;

    QFileInfo info(filename);
    if(!info.exists())
        return false;

    QString targetFilename = QString("%1/%2").arg(targetdir, info.fileName());
    QFileInfo targetinfo(targetFilename);

    // file copied to itself
    if(targetFilename == filename)
        return true;

    if(targetinfo.exists()) {
        QFile tf(targetFilename);
        tf.remove();
    }

    QFile f(filename);
    return f.copy(targetFilename);

}

bool PQCScriptsFileManagement::deletePermanent(QString filename) {

    qDebug() << "args: filename = " << filename;

    QFileInfo info(filename);
    if(info.isDir()) {
        QDir dir(filename);
        if(!dir.removeRecursively()) {
            qWarning() << "Failed to delete folder recursively!";
            return false;
        }
        return true;
    }
    QFile file(filename);
    return file.remove();

}

bool PQCScriptsFileManagement::moveFileToTrash(QString filename) {

    qDebug() << "args: filename = " << filename;


#ifdef Q_OS_WIN
    QString deletedFilename = "";
    QFile file(filename);
    // we need to call moveToTrash on a different QFile object, otherwise the exists() check will return false
    // even while the file isn't deleted as it is seen as opened by PhotoQt
    QFile f(filename);
    bool ret = f.moveToTrash();
    int count = 0;
    while(file.exists() && count < 20) {
        QFile f(filename);
        ret = f.moveToTrash();
        if(ret && deletedFilename == "")
            deletedFilename = f.fileName();
        std::this_thread::sleep_for(std::chrono::milliseconds(250));
        ++count;
    }
    PQCScriptsUndo::get().recordAction("trash", {filename, deletedFilename});
    return ret;
#else

#ifndef PQMFLATPAKBUILD

    // this does not work with Flatpak, checked 2024-04-03
    QString trashFile = "";
    bool rettrash = QFile::moveToTrash(filename, &trashFile);
    if(rettrash)
        PQCScriptsUndo::get().recordAction("trash", {filename, trashFile});
    return rettrash;

#else

    // for flatpaks we use GIO trash function as this has support for the trash portal

    GFile *file = g_file_new_for_path(filename.toStdString().c_str());
    GError *error = nullptr;
    bool success = g_file_trash(file, nullptr, &error);

    if(!success) {
        qWarning() << "Failed to move file to trash:" << error->message;
        g_error_free(error);
    }

    g_object_unref(file);

    return success;

#endif

#endif

}

void PQCScriptsFileManagement::exportImage(QString sourceFilename, QString targetFilename, int uniqueid) {

    qDebug() << "args: sourceFilename =" << sourceFilename;
    qDebug() << "args: targetFilename =" << targetFilename;
    qDebug() << "args: uniqueid =" << uniqueid;

    QFuture<void> f = QtConcurrent::run([=]() {

        // get info about new file format and source file
        QVariantMap databaseinfo = PQCImageFormats::get().getFormatsInfo(uniqueid);

        // First we load the image...
        QSize tmp;
        QImage img;
        PQCLoadImage::get().load(sourceFilename, QSize(-1,-1), tmp, img);

        // we convert the image to this tmeporary file and then copy it to the right location
        // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
        QString tmpImagePath = PQCConfigFiles::get().CACHE_DIR() + "/temporaryfileforexport" + "." + databaseinfo.value("endings").toString().split(",")[0];
        if(QFile::exists(tmpImagePath))
            QFile::remove(tmpImagePath);

        // qt might support it
        if(databaseinfo.value("qt").toInt() == 1) {

            QImageWriter writer;

            // if the QImageWriter supports the format then we're good to go
            if(writer.supportedImageFormats().contains(databaseinfo.value("qt_formatname").toString())) {

                // ... and then we write it into the new format
                writer.setFileName(tmpImagePath);
                writer.setFormat(databaseinfo.value("qt_formatname").toString().toUtf8());

                // if the actual writing succeeds we're done now
                if(!writer.write(img))
                    qWarning() << "ERROR:" << writer.errorString();
                else {
                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);
                    Q_EMIT exportCompleted(true);
                    return;
                }

            }

        }

    // imagemagick/graphicsmagick might support it
    #if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    #ifdef PQMIMAGEMAGICK
        if(databaseinfo.value("imagemagick").toInt() == 1) {
    #else
        if(databaseinfo.value("graphicsmagick").toInt() == 1) {
    #endif

            // first check whether ImageMagick/GraphicsMagick supports writing this filetype
            bool canproceed = false;
            try {
                QString magick = databaseinfo.value("im_gm_magick").toString();
                Magick::CoderInfo magickCoderInfo(magick.toStdString());
                if(magickCoderInfo.isWritable())
                    canproceed = true;
            } catch(...) {
                // do nothing here
            }

            // yes, it's supported
            if(canproceed) {

                try {

                    // first we write the QImage to a temporary file
                    // then we load it into magick and write it to the target file

                    // find unique temporary path
                    QString tmppath = PQCConfigFiles::get().CACHE_DIR() + "/converttmp.ppm";
                    if(QFile::exists(tmppath))
                        QFile::remove(tmppath);

                    img.save(tmppath);

                    // load image and write to target file
                    Magick::Image image;
                    image.magick("PPM");
                    image.read(tmppath.toStdString());

                    image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                    image.write(tmpImagePath.toStdString());

                    // remove temporary file
                    QFile::remove(tmppath);

                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);

                    // success!
                    Q_EMIT exportCompleted(true);
                    return;

                } catch(Magick::Exception &) { }

            }

        }

    #endif

        // unsuccessful conversion...
        Q_EMIT exportCompleted(false);

    });

}

bool PQCScriptsFileManagement::canThisBeCropped(QString filename) {
    return canThisBeScaled(filename);
}

bool PQCScriptsFileManagement::canThisBeScaled(QString filename) {

    qDebug() << "args: filename = " << filename;

    int uniqueid = PQCImageFormats::get().detectFormatId(filename);
    return (PQCImageFormats::get().getWriteStatus(uniqueid) > 0);

}

void PQCScriptsFileManagement::scaleImage(QString sourceFilename, QString targetFilename, int uniqueid, QSize targetSize, int targetQuality) {

    qDebug() << "args: sourceFilename = " << sourceFilename;
    qDebug() << "args: targetFilename = " << targetFilename;
    qDebug() << "args: uniqueid = " << uniqueid;
    qDebug() << "args: targetSize = " << targetSize;
    qDebug() << "args: targetQuality = " << targetQuality;

    QFuture<void> f = QtConcurrent::run([=]() {

        int writeStatus = PQCImageFormats::get().getWriteStatus(uniqueid);

        if(writeStatus == 0) {
            qWarning() << "ERROR: file not supported for scaling:" << sourceFilename;
            Q_EMIT scaleCompleted(false);
            return;
        }

        QVariantMap databaseinfo = PQCImageFormats::get().getFormatsInfo(uniqueid);

    #ifdef PQMEXIV2

        // This will store all the exif data
        Exiv2::ExifData exifData;
        Exiv2::IptcData iptcData;
        Exiv2::XmpData xmpData;
        bool gotExifData = false;

#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Image::UniquePtr image_read;
#else
        Exiv2::Image::AutoPtr image_read;
#endif

        try {

    // Open image for exif reading
    #if EXIV2_TEST_VERSION(0, 28, 0)
            image_read = Exiv2::ImageFactory::open(sourceFilename.toStdString());
    #else
            image_read = Exiv2::ImageFactory::open(sourceFilename.toStdString());
    #endif

            if(image_read.get() != 0) {
                // YAY, WE FOUND SOME!!!!!
                gotExifData = true;
                image_read->readMetadata();
            }

        }

        catch (Exiv2::Error& e) {
            qDebug() << "ERROR reading exif data (caught exception):" << e.what();
        }

        if(gotExifData) {

            // read exif
            exifData = image_read->exifData();
            iptcData = image_read->iptcData();
            xmpData = image_read->xmpData();

            // Update dimensions
            exifData["Exif.Photo.PixelXDimension"] = int32_t(targetSize.width());
            exifData["Exif.Photo.PixelYDimension"] = int32_t(targetSize.height());

        }

    #endif

        // We need to do the actual scaling in between reading the exif data above and writing it below,
        // since we might be scaling the image in place and thus would overwrite old exif data
        bool success = false;

        QSize s;
        QImage img;
        PQCLoadImage::get().load(sourceFilename, targetSize, s, img);

        if(writeStatus == 1 || writeStatus == 2) {

            // we don't stop if this fails as we might be able to try again with Magick
            if(img.save(targetFilename, databaseinfo.value("qt_formatname").toString().toStdString().c_str(), targetQuality))
                success = true;
            else
                qWarning() << "Scaling image with Qt failed";

        }

        if(!success && (writeStatus == 1 || writeStatus == 3)) {

    // imagemagick/graphicsmagick might support it
    #if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    #ifdef PQMIMAGEMAGICK
            if(databaseinfo.value("imagemagick").toInt() == 1) {
    #else
            if(databaseinfo.value("graphicsmagick").toInt() == 1) {
    #endif

                // first check whether ImageMagick/GraphicsMagick supports writing this filetype
                bool canproceed = false;
                try {
                    QString magick = databaseinfo.value("im_gm_magick").toString();
                    Magick::CoderInfo magickCoderInfo(magick.toStdString());
                    if(magickCoderInfo.isWritable())
                        canproceed = true;
                } catch(...) {
                    // do nothing here
                }

                // yes, it's supported
                if(canproceed) {

                    // we scale the image to this tmeporary file and then copy it to the right location
                    // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                    QString tmpImagePath = PQCConfigFiles::get().CACHE_DIR() + "/temporaryfileforscale" + "." + databaseinfo.value("endings").toString().split(",")[0];
                    if(QFile::exists(tmpImagePath))
                        QFile::remove(tmpImagePath);

                    try {

                        // first we write the QImage to a temporary file
                        // then we load it into magick and write it to the target file

                        // find unique temporary path
                        QString tmppath = PQCConfigFiles::get().CACHE_DIR() + "/converttmp.ppm";
                        if(QFile::exists(tmppath))
                            QFile::remove(tmppath);

                        img.save(tmppath);

                        // load image and write to target file
                        Magick::Image image;
                        image.magick("PPM");
                        image.read(tmppath.toStdString());

                        image.resize(Magick::Geometry(targetSize.width(), targetSize.height()));

                        image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                        image.write(tmpImagePath.toStdString());

                        // remove temporary file
                        QFile::remove(tmppath);

                        // copy result to target destination
                        QFile::copy(tmpImagePath, targetFilename);
                        QFile::remove(tmpImagePath);

                        // success!
                        success = true;

                    } catch(Magick::Exception &) { }

                }

            }

    #endif

        }

        if(!success) {
            Q_EMIT scaleCompleted(false);
            return;
        }

    #ifdef PQMEXIV2

        if(gotExifData) {

            try {

    // And write exif data to new image file
    #if EXIV2_TEST_VERSION(0, 28, 0)
                Exiv2::Image::UniquePtr image_write = Exiv2::ImageFactory::open(targetFilename.toStdString());
    #else
                Exiv2::Image::AutoPtr image_write = Exiv2::ImageFactory::open(targetFilename.toStdString());
    #endif
                image_write->setExifData(exifData);
                image_write->setIptcData(iptcData);
                image_write->setXmpData(xmpData);
                image_write->writeMetadata();

            }

            catch (Exiv2::Error& e) {
                qWarning() << "ERROR writing exif data (caught exception):" << e.what();
            }

        }

    #endif

        Q_EMIT scaleCompleted(true);

    });

}

bool PQCScriptsFileManagement::renameFile(QString dir, QString oldName, QString newName) {

    qDebug() << "args: dir =" << dir;
    qDebug() << "args: oldName =" << oldName;
    qDebug() << "args: newName =" << newName;

    QFile file(dir + "/" + oldName);
    return file.rename(dir + "/" + newName);

}

bool PQCScriptsFileManagement::copyFile(QString filename, QString targetFilename) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetFilename =" << targetFilename;

    // if the target is the same as source, then we're done
    if(filename == targetFilename)
        return true;

    // if a file by the target filename already exists, then we need to remove it first
    if(QFileInfo::exists(targetFilename)) {
        if(!QFile::remove(targetFilename)) {
            qWarning() << "ERROR: File existing with this name could not be removed first.";
            return false;
        }
    }

    // copy source file to target filename
    QFile file(filename);
    if(!file.copy(targetFilename)) {
        qWarning() << "ERROR: The file could not be copied to its new location.";
        return false;
    }

    return true;

}

bool PQCScriptsFileManagement::moveFile(QString filename, QString targetFilename) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetFilename =" << targetFilename;

    // if the target is the same as source, then we're done
    if(filename == targetFilename)
        return true;

    // if a file by the target filename already exists, then we need to remove it first
    if(QFileInfo::exists(targetFilename)) {
        if(!QFile::remove(targetFilename)) {
            qWarning() << "ERROR: File existing with this name could not be removed first.";
            return false;
        }
    }

    // copy source file to target filename
    QFile file(filename);
    if(!file.copy(targetFilename)) {
        qWarning() << "ERROR: The file could not be copied to its new location.";
        return false;
    }

    if(!file.remove()) {
        qWarning() << "ERROR: The file was successfully copied to new location but the old file could not be removed.";
        return false;
    }

    return true;

}

void PQCScriptsFileManagement::cropImage(QString sourceFilename, QString targetFilename, int uniqueid, QPointF topLeft, QPointF botRight) {

    qDebug() << "args: sourceFilename =" << sourceFilename;
    qDebug() << "args: targetFilename =" << targetFilename;
    qDebug() << "args: uniqueid =" << uniqueid;
    qDebug() << "args: topLeft =" << topLeft;
    qDebug() << "args: botRight =" << botRight;

    QFuture<void> f = QtConcurrent::run([=]() {

        int writeStatus = PQCImageFormats::get().getWriteStatus(uniqueid);

        QVariantMap databaseinfo = PQCImageFormats::get().getFormatsInfo(uniqueid);

        if(writeStatus == 0) {
            qWarning() << "ERROR: file not supported for cropping:" << sourceFilename;
            Q_EMIT cropCompleted(false);
            return;
        }

        bool success = false;

        // create cropped QImage
        QImage img;
        QSize origSize;
        PQCLoadImage::get().load(sourceFilename, QSize(), origSize, img);

        QRect rect(img.width()*topLeft.x(), img.height()*topLeft.y(),
                   img.width()*(botRight.x()-topLeft.x()), img.height()*(botRight.y()-topLeft.y()));
        QImage croppedImg = img.copy(rect);

        if(writeStatus == 1 || writeStatus == 2) {

            // we don't stop if this fails as we might be able to try again with Magick
            if(croppedImg.save(targetFilename, databaseinfo.value("qt_formatname").toString().toStdString().c_str(), -1))
                success = true;
            else
                qWarning() << "Cropping image with Qt failed";

        }

        if(!success) {// && (writeStatus == 1 || writeStatus == 3)) {

            // imagemagick/graphicsmagick might support it
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#ifdef PQMIMAGEMAGICK
            if(databaseinfo.value("imagemagick").toInt() == 1) {
#else
            if(databaseinfo.value("graphicsmagick").toInt() == 1) {
#endif

                // first check whether ImageMagick/GraphicsMagick supports writing this filetype
                bool canproceed = false;
                try {
                    QString magick = databaseinfo.value("im_gm_magick").toString();
                    Magick::CoderInfo magickCoderInfo(magick.toStdString());
                    if(magickCoderInfo.isWritable())
                        canproceed = true;
                } catch(...) {
                    // do nothing here
                }

                // yes, it's supported
                if(canproceed) {

                    // we scale the image to this tmeporary file and then copy it to the right location
                    // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                    QString tmpImagePath = PQCConfigFiles::get().CACHE_DIR() + "/temporaryfileforcrop" + "." + databaseinfo.value("endings").toString().split(",")[0];
                    if(QFile::exists(tmpImagePath))
                        QFile::remove(tmpImagePath);

                    try {

                        // first we write the QImage to a temporary file
                        // then we load it into magick and write it to the target file

                        // find unique temporary path
                        QString tmppath = PQCConfigFiles::get().CACHE_DIR() + "/converttmp.ppm";
                        if(QFile::exists(tmppath))
                            QFile::remove(tmppath);

                        croppedImg.save(tmppath);

                        // load image and write to target file
                        Magick::Image image;
                        image.magick("PPM");
                        image.read(tmppath.toStdString());

                        image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                        image.write(tmpImagePath.toStdString());

                        // remove temporary file
                        QFile::remove(tmppath);

                        // copy result to target destination
                        QFile::copy(tmpImagePath, targetFilename);
                        QFile::remove(tmpImagePath);

                        // success!
                        success = true;

                    } catch(Magick::Exception &) { }

                } else
                    qDebug() << "Writing format not supported by Magick";

            }

#endif

        }

        Q_EMIT cropCompleted(success);

    });

}
