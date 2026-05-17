/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_loadimage.h>
#include <pqc_loadimage_archive.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_settingscpp.h>
#include <pqc_configfiles.h>
#include <pqc_loadimage.h>
#include <pqc_imageformats.h>
#include <pqc_notify_cpp.h>

#include <QSize>
#include <QtDebug>
#include <QFileInfo>
#include <QImage>
#include <QProcess>
#include <QTemporaryFile>

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

PQCLoadImageArchive::PQCLoadImageArchive() {}

QSize PQCLoadImageArchive::loadSize(QString filename) {

#ifdef PQMLIBARCHIVE

    // filter out name of archivefile and of compressed file inside
    QString archivefile = filename;
    QString compressedFilename = "";
    if(archivefile.contains("::ARC::")) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = parts.at(1);
        compressedFilename = parts.at(0);
    } else {
        QStringList cont = PQCScriptsImages::get().listArchiveContentWithoutThread(archivefile);
        if(cont.length() == 0) {
            qWarning() << "Unable to list contents of archive file...";
            return QSize();
        }
        compressedFilename = cont.at(0);
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
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archivefile.utf16()), 10240);
#else
    QByteArray tmpPath = QFile::encodeName(archivefile);
    int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif

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
        // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
        // and PhotoQt might crash if not handled properly -> check before converting to QString
        const wchar_t *wpath = archive_entry_pathname_w(entry);
        if(!wpath) continue;
        QString filenameinside = QString::fromWCharArray(wpath);

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename.isEmpty() && !QFileInfo(filenameinside).suffix().isEmpty())) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            if(size <= 0) {
                qWarning() << QString("Invalid image size of file in archive: %1").arg(size);
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            // Create a buffer of that size to hold the image data
            QByteArray data;
            data.resize(size);

            // And finally read the file into the buffer in chunks
            char* ptr = data.data();
            qint64 total = 0;
            while (total < size) {
                la_ssize_t chunk = archive_read_data(a, ptr + total, size - total);
                if(chunk < 0) {
                    qWarning() << QString("Invalid chunk read: %1").arg(archive_error_string(a));
                    archive_read_close(a);
                    archive_read_free(a);
                    return QSize();
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            // and finish off by turning it into an image

            // we use a temporary file that is automatically removed afterwards
            QTemporaryFile tempFile;
            tempFile.setAutoRemove(true);

            // write buffer to file
            if(!tempFile.open()) {
                qWarning() << "Unable to load archive file to temporary file.";
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            if(tempFile.write(data) != data.size()) {
                qWarning() << "Failed to write image to temporary file.";
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            tempFile.flush();

            QSize origSize = PQCLoadImage::get().load(tempFile.fileName());

            r = archive_read_free(a);
            if(r != ARCHIVE_OK)
                qWarning() << "PQLoadImage::Archive::load(): ERROR: archive_read_free() returned code of" << r;

            archive_read_close(a);
            archive_read_free(a);
            return origSize;
        }

    }

    archive_read_close(a);
    archive_read_free(a);

#endif

    return QSize();

}

QString PQCLoadImageArchive::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

    QString errormsg = "";

#ifdef PQMLIBARCHIVE

    // filter out name of archivefile and of compressed file inside
    QString archivefile = filename;
    QString compressedFilename = "";
    if(archivefile.contains("::ARC::")) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = parts.at(1);
        compressedFilename = parts.at(0);
    } else {
        QStringList cont = PQCScriptsImages::get().listArchiveContentWithoutThread(archivefile);
        if(cont.length() == 0) {
            errormsg = "Unable to list contents of archive file...";
            qWarning() << errormsg;
            return errormsg;
        }
        compressedFilename = cont.at(0);
    }

    if(!QFileInfo::exists(archivefile)) {
        errormsg = "File doesn't seem to exist...";
        qWarning() << errormsg;
        return errormsg;
    }

    QFileInfo info(archivefile);
    const QString suffix = info.suffix().toLower();

#ifndef Q_OS_WIN
    if(PQCSettingsCPP::get().getFiletypesExternalUnrar() && (suffix == "cbr" || suffix == "rar")) {

        qDebug() << "trying to load archive with unrar";

        const QString tmpDir = PQCConfigFiles::get().CACHE_DIR()+"/unrar/";

        QDir dir;
        if(dir.mkpath(tmpDir)) {

            QProcess p;
            p.setProcessChannelMode(QProcess::MergedChannels);
            p.start("unrar", QStringList() << "x" << "-y" << archivefile << compressedFilename << tmpDir);

            if(p.waitForStarted()) {

                p.waitForFinished(15000);

                PQCLoadImage::get().load(tmpDir + compressedFilename, QSize(-1,-1), origSize, img);
                QDir dir(tmpDir);
                dir.removeRecursively();

                // cache image before potentially scaling it
                if(!img.isNull()) {
                    PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
                    PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
                }

                // Scale image if necessary
                if(!maxSize.isEmpty()) {

                    QSize finalSize = origSize;

                    if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
                        finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

                    img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

                }

                return "";

            } else
                qWarning() << "Failed to run unrar, trying with libarchive";

        } else
            qWarning() << "unable to create temporary folder for unrar target:" << tmpDir;

    }
#endif

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

    // Read file
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archivefile.utf16()), 10240);
#else
    QByteArray tmpPath = QFile::encodeName(info.absoluteFilePath());
    int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif

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
        // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
        // and PhotoQt might crash if not handled properly -> check before converting to QString
        const wchar_t *wpath = archive_entry_pathname_w(entry);
        if(!wpath) continue;
        QString filenameinside = QString::fromWCharArray(wpath);

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename.isEmpty() && !QFileInfo(filenameinside).suffix().isEmpty())) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            if(size <= 0) {
                const QString err = QString("Invalid image size of file in archive: %1").arg(size);
                qWarning() << err;
                return err;
            }

            // Create a buffer of that size to hold the image data
            QByteArray data;
            data.resize(size);

            // And finally read the file into the buffer in chunks
            char* ptr = data.data();
            qint64 total = 0;
            while (total < size) {
                la_ssize_t chunk = archive_read_data(a, ptr + total, size - total);
                if(chunk < 0) {
                    const QString err = QString("Invalid chunk read: %1").arg(archive_error_string(a));
                    qWarning() << err;
                    return err;
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                errormsg = QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                qWarning() << errormsg;
                return errormsg;
            }

            // and finish off by turning it into an image

            // we use a temporary file that is automatically removed afterwards
            QTemporaryFile tempFile;
            tempFile.setAutoRemove(true);

            // write buffer to file
            if(!tempFile.open()) {
                const QString err = "Unable to load archive file to temporary file.";
                qWarning() << err;
                return err;
            }

            if(tempFile.write(data) != data.size()) {
                const QString err = "Failed to write image to temporary file.";
                qWarning() << err;
                return err;
            }

            tempFile.flush();

            // attempt to load file
            QString err = PQCLoadImage::get().load(tempFile.fileName(), QSize(-1,-1), origSize, img);
            if(!err.isEmpty())
                qWarning() << "Failed to load image inside archive:" << filenameinside;

            // Nothing more to do except some cleaning up below
            break;
        }

    }

    // Close archive
    r = archive_read_close(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_close() returned code of" << r;
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_free() returned code of" << r;

    // cache image before potentially scaling it
    if(!img.isNull()) {

        if(PQCSettingsCPP::get().getMetadataAutoRotation()) {
            // apply transformations if any
            PQCScriptsImages::get().applyExifOrientation(filename, img);
        }

        PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
        PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
    }

    // Scale image if necessary
    if(!maxSize.isEmpty()) {
        img = img.scaled(origSize.scaled(maxSize, Qt::KeepAspectRatio),
                         Qt::IgnoreAspectRatio,
                         (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
    }

    return "";

#else

    origSize = QSize(-1,-1);
    errormsg = "Failed to load archive, LibArchive not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

#endif

}
