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

#include <pqc_loadimage.h>
#include <pqc_loadimage_archive.h>
#include <pqc_imagecache.h>
#include <scripts/qmlcpp/pqc_scriptsimages.h>
#include <scripts/qmlcpp/pqc_scriptscolorprofiles.h>
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
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archivefile.utf16()), 10240);
#else
    int r = archive_read_open_filename(a, archivefile.toLocal8Bit().data(), 10240);
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
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename == "" && QFileInfo(filenameinside).suffix() != "")) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the image data
            uchar *buff = new uchar[size];

            // And finally read the file into the buffer
            la_ssize_t r = archive_read_data(a, (void*)buff, size);

            if(r != size || size == 0) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(r).arg(size);
                return QSize();
            }

            // and finish off by turning it into an image

            // we extract it to a temp location from where we can load it then
            const QString temppath = PQCConfigFiles::get().CACHE_DIR() + "/archive/" + filenameinside;

            // file handles
            QFile file(temppath);
            QFileInfo info(file);

            // remove it if it exists, there is no way to know if it's the same file or not
            if(file.exists()) file.remove();

            // make sure the path exists
            QDir dir(info.absolutePath());
            if(!dir.exists())
                dir.mkpath(info.absolutePath());

            // write buffer to file
            file.open(QIODevice::WriteOnly);
            QDataStream out(&file);   // we will serialize the data into the file
            out.writeRawData((const char*) buff,size);
            file.close();
            delete[] buff;

            QSize origSize = PQCLoadImage::get().load(temppath);

            // finally remove file again
            file.remove();

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

#ifdef PQMLIBARCHIVE

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

    QFileInfo info(archivefile);
    const QString suffix = info.suffix().toLower();

#ifndef Q_OS_WIN
    if(PQCSettingsCPP::get().getFiletypesExternalUnrar() && (suffix == "cbr" || suffix == "rar")) {

        QProcess which;
        which.setStandardOutputFile(QProcess::nullDevice());
        which.start("which", QStringList() << "unrar");
        which.waitForFinished();

        if(!which.exitCode()) {

            qDebug() << "loading archive with unrar";

            const QString tmpDir = PQCConfigFiles::get().CACHE_DIR()+"/unrar/";

            QDir dir;
            if(dir.mkpath(tmpDir)) {

                QProcess p;
                p.start("unrar", QStringList() << "x" << "-y" << archivefile << compressedFilename << tmpDir);
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
                if(maxSize.width() != -1) {

                    QSize finalSize = origSize;

                    if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
                        finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

                    img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

                }

                return "";

            } else
                qWarning() << "unable to create temporary folder for unrar target:" << tmpDir;

        } else
            qWarning() << "unrar was not found in system path";

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
    int r = archive_read_open_filename(a, archivefile.toLocal8Bit().data(), 10240);
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
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename == "" && QFileInfo(filenameinside).suffix() != "")) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the image data
            uchar *buff = new uchar[size];

            // And finally read the file into the buffer
            la_ssize_t r = archive_read_data(a, (void*)buff, size);

            if(r != size || size == 0) {
                errormsg = QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(r).arg(size);
                qWarning() << errormsg;
                return errormsg;
            }

            // and finish off by turning it into an image

            // we extract it to a temp location from where we can load it then
            const QString temppath = PQCConfigFiles::get().CACHE_DIR() + "/archive/" + filenameinside;

            // file handles
            QFile file(temppath);
            QFileInfo info(file);

            // remove it if it exists, there is no way to know if it's the same file or not
            if(file.exists()) file.remove();

            // make sure the path exists
            QDir dir(info.absolutePath());
            if(!dir.exists())
                dir.mkpath(info.absolutePath());

            // write buffer to file
            file.open(QIODevice::WriteOnly);
            QDataStream out(&file);   // we will serialize the data into the file
            out.writeRawData((const char*) buff,size);
            file.close();
            delete[] buff;

            // attempt to load file
            QString err = PQCLoadImage::get().load(temppath, QSize(-1,-1), origSize, img);
            if(err != "")
                qWarning() << "Failed to load image inside archive:" << filenameinside;

            // finally remove file again
            file.remove();

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
        PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
        PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
    }

    // Scale image if necessary
    if(maxSize.width() != -1) {

        QSize finalSize = origSize;

        if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
            finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

        img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    }

    return "";

#else

    origSize = QSize(-1,-1);
    errormsg = "Failed to load archive, LibArchive not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

#endif

}
