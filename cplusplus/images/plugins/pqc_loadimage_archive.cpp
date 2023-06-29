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

#include <pqc_loadimage_archive.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptsimages.h>
#include <QSize>
#include <QtDebug>
#include <QFileInfo>
#include <QImage>

#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

PQCLoadImageArchive::PQCLoadImageArchive() {}

QSize PQCLoadImageArchive::loadSize(QString filename) {

#ifdef LIBARCHIVE

    // filter out name of archivefile and of compressed file inside
    QString archivefile = filename;
    QString compressedFilename = "";
    if(archivefile.contains("::ARC::")) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = parts.at(1);
        compressedFilename = parts.at(0);
    } else {
        QStringList cont = PQCScriptsImages::get().listArchiveContent(archivefile);
        if(cont.length() == 0) {
            qWarning() << "Unable to list contents of archive file...";
            return QSize();
        }
        compressedFilename = cont.at(0).split("::ARC::").at(0);
    }

    if(!QFileInfo::exists(archivefile)) {
        qWarning() << "File doesn't seem to exist...";
        return QSize();
    }

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

    // Read file
    int r = archive_read_open_filename(a, archivefile.toLocal8Bit().data(), 10240);

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        qWarning() << QString("archive_read_open_filename() returned code of %1").arg(r);
        return QSize();
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename == "" && QFileInfo(filenameinside).suffix() != "")) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the image data
            uchar *buff = new uchar[size];

            // And finally read the file into the buffer
            ssize_t r = archive_read_data(a, (void*)buff, size);
            if(r != size) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(r).arg(size);
                return QSize();
            }

            // and finish off by turning it into an image
            QSize origSize = QImage::fromData(buff, size).size();

            delete[] buff;

            r = archive_read_free(a);
            if(r != ARCHIVE_OK)
                qWarning() << "PQLoadImage::Archive::load(): ERROR: archive_read_free() returned code of" << r;

            return origSize;
        }

    }
#endif

    return QSize();

}

QString PQCLoadImageArchive::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

    QString errormsg = "";

#ifdef LIBARCHIVE

    // filter out name of archivefile and of compressed file inside
    QString archivefile = filename;
    QString compressedFilename = "";
    if(archivefile.contains("::ARC::")) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = parts.at(1);
        compressedFilename = parts.at(0);
    } else {
        QStringList cont = PQCScriptsImages::get().listArchiveContent(archivefile);
        if(cont.length() == 0) {
            errormsg = "Unable to list contents of archive file...";
            qWarning() << errormsg;
            return errormsg;
        }
        compressedFilename = cont.at(0).split("::ARC::").at(0);
    }

    if(!QFileInfo::exists(archivefile)) {
        errormsg = "File doesn't seem to exist...";
        qWarning() << errormsg;
        return errormsg;
    }

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

    // Read file
    int r = archive_read_open_filename(a, archivefile.toLocal8Bit().data(), 10240);

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        errormsg = QString("archive_read_open_filename() returned code of %1").arg(r);
        qWarning() << errormsg;
        return errormsg;
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename == "" && QFileInfo(filenameinside).suffix() != "")) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the image data
            uchar *buff = new uchar[size];

            // And finally read the file into the buffer
            ssize_t r = archive_read_data(a, (void*)buff, size);
            if(r != size) {
                errormsg = QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(r).arg(size);
                qWarning() << errormsg;
                return errormsg;
            }

            // and finish off by turning it into an image
            img = QImage::fromData(buff, size);

            origSize = img.size();

            delete[] buff;

            // Nothing more to do except some cleaning up below
            break;
        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        qWarning() << "PQLoadImage::Archive::load(): ERROR: archive_read_free() returned code of" << r;

    // cache image before potentially scaling it
    if(!img.isNull())
        PQCImageCache::get().saveImageToCache(filename, &img);

    // Scale image if necessary
    if(maxSize.width() != -1) {

        QSize finalSize = origSize;

        double q;

        if(finalSize.width() > maxSize.width()) {
            q = maxSize.width()/(finalSize.width()*1.0);
            finalSize.setWidth(finalSize.width()*q);
            finalSize.setHeight(finalSize.height()*q);
        }
        if(finalSize.height() > maxSize.height()) {
            q = maxSize.height()/(finalSize.height()*1.0);
            finalSize.setWidth(finalSize.width()*q);
            finalSize.setHeight(finalSize.height()*q);
        }

        img = img.scaled(finalSize);

    }

    return "";

#else

    origSize = QSize(-1,-1);
    errormsg = "Failed to load archive, LibArchive not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

#endif

}
