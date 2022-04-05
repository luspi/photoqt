/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "loadimage_archive.h"

PQLoadImageArchive::PQLoadImageArchive() {
    errormsg = "";
}

QImage PQLoadImageArchive::load(QString filename, QSize maxSize, QSize *origSize) {

    errormsg = "";

    // filter out name of archivefile and of compressed file inside
    QString archivefile = filename;
    QString compressedFilename = "";
    if(archivefile.contains("::ARC::")) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = parts.at(1);
        compressedFilename = parts.at(0);
    } else {
        PQHandlingFileDir handling;
        QStringList cont = handling.listArchiveContent(archivefile);
        if(cont.length() == 0) {
            errormsg = "Unable to list contents of archive file...";
            LOG << CURDATE << "PQLoadImageArchive::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }
        compressedFilename = cont.at(0).split("::ARC::").at(0);
    }

    if(!QFileInfo::exists(archivefile)) {
        errormsg = "File doesn't seem to exist...";
        LOG << CURDATE << "PQLoadImageArchive::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

#ifdef LIBARCHIVE

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
        LOG << CURDATE << "PQLoadImageArchive::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    QImage ret;
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
                LOG << CURDATE << "PQLoadImageArchive::load(): " << errormsg.toStdString() << NL;
                return QImage();
            }

            // and finish off by turning it into an image
            ret = QImage::fromData(buff, size);

            *origSize = ret.size();

            delete[] buff;

            // Nothing more to do except some cleaning up below
            break;
        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        LOG << CURDATE << "PQLoadImage::Archive::load(): ERROR: archive_read_free() returned code of " << r << NL;

    return ret;

#else

    errormsg = "Failed to load archive, LibArchive not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImageArchive::load(): " << errormsg.toStdString() << NL;
    return QImage();

#endif

}
