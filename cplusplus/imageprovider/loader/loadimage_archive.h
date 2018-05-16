/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#include <QImage>

#include <archive.h>
#include <archive_entry.h>

#include "errorimage.h"
#include "../../logger.h"

namespace PLoadImage {

    namespace Archive {

        QImage load(QString filename, QSize maxSize) {

            // If no archive info is stored, return error image
            if(!filename.contains("::ARCHIVE1::") || !filename.contains("::ARCHIVE2::")) {

                QString suffix = QFileInfo(filename).suffix();

                QStringList knownSuffix = QStringList() << "cbz" << "cbr" << "cbt" << "cb7" << "zip" << "rar" << "tar" << "7z";

                QImage ret;

                if(knownSuffix.contains(suffix))
                    ret = QImage(QString(":/img/openfile/archive/%1.png").arg(suffix));
                else
                    ret = QImage(":/img/openfile/archive/zip.png");

                // This is to make sure that this type of thumbnail is not cached (pretends to be error image)
                ret.setText("error", "error");

                // If image needs to be scaled down, return scaled down version
                if(maxSize.width() > 5 && maxSize.height() > 5)
                    if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                        return ret.scaled(maxSize, ::Qt::KeepAspectRatio);

                return ret;

            }

            // filter out name of archivefile and of compressed file inside
            QString archivefile = filename.split("::ARCHIVE1::").at(1).split("::ARCHIVE2::").at(0);
            QString compressedFilename = filename.split("::ARCHIVE2::").at(1);

            if(!QFileInfo(archivefile).exists()) {
                std::stringstream ss;
                ss << "ERROR loading archive, file doesn't seem to exist...";
                LOG << CURDATE << ss.str() << NL;
                return ErrorImage::load(QString::fromStdString(ss.str()));
            }

            // Extract suffix and remove (added on to signal archive compressed file, not part of actual compressed filename)
            QString suffix = QFileInfo(filename).suffix();
            compressedFilename = compressedFilename.remove(compressedFilename.length()-suffix.length()-1, compressedFilename.length());

            // Create new archive handler
            struct archive *a = archive_read_new();

            // We allow any type of compression and format
            archive_read_support_filter_all(a);
            archive_read_support_format_all(a);

            // Read file
            int r = archive_read_open_filename(a, archivefile.toLatin1(), 10240);

            // If something went wrong, output error message and stop here
            if(r != ARCHIVE_OK) {
                std::stringstream ss;
                ss << CURDATE << "LoadImage::Archive::load(): ERROR: archive_read_open_filename() returned code of " << r << NL;
                LOG << ss.str();
                return ErrorImage::load(QString::fromStdString(ss.str()));
            }

            // Loop over entries in archive
            struct archive_entry *entry;
            QImage ret;
            while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

                // Read the current file entry
                QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

                // If this is the file we are looking for:
                if(filenameinside == compressedFilename) {

                    // Find out the size of the data
                    int64_t size = archive_entry_size(entry);

                    // Create a uchar buffer of that size to hold the image data
                    uchar *buff = new uchar[size];

                    // And finally read the file into the buffer
                    ssize_t r = archive_read_data(a, (void*)buff, size);
                    if(r != size) {
                        std::stringstream ss;
                        ss << "LoadImage::Archive::load(): ERROR: Failed to read image data, read size (" << r << ")"
                           << " doesn't match expected size (" << size << ")...";
                        LOG << CURDATE << ss.str();
                        return ErrorImage::load(QString::fromStdString(ss.str()));
                    }

                    // and finish off by turning it into an image
                    ret = QImage::fromData(buff, size);

                    delete[] buff;

                    // Nothing more to do except some cleaning up below
                    break;
                }

            }

            // Close archive
            r = archive_read_free(a);
            if(r != ARCHIVE_OK)
                LOG << CURDATE << "LoadImage::Archive::load(): ERROR: archive_read_free() returned code of " << r << NL;

            // If image needs to be scaled down, return scaled down version
            if(maxSize.width() > 5 && maxSize.height() > 5)
                if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                    return ret.scaled(maxSize, ::Qt::KeepAspectRatio);

            return ret;

        }

    }

}
