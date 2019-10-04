#include <QImage>

#include <archive.h>
#include <archive_entry.h>

#include "../../logger.h"
#include "../../variables.h"
#include "../../scripts/handlingfiledialog.h"

namespace PQLoadImage {

    namespace Archive {

        static QString errormsg = "";

        static QImage load(QString filename, QSize maxSize, QSize *origSize) {

            // filter out name of archivefile and of compressed file inside
            QString archivefile = filename;
            QString compressedFilename = "";
            if(archivefile.contains("::ARC::")) {
                QStringList parts = archivefile.split("::ARC::");
                archivefile = parts.at(1);
                compressedFilename = parts.at(0);
            } else {
                PQHandlingFileDialog handling;
                QStringList cont = handling.listArchiveContent(archivefile);
                if(cont.length() == 0) {
                    errormsg = "Error: unable to list contents of archive file...";
                    LOG << CURDATE << "PQLoadImage::Archive::load(): " << errormsg.toStdString() << NL;
                    return QImage();
                }
                compressedFilename = cont.at(0).split("::ARC::").at(0);
            }

            if(!QFileInfo(archivefile).exists()) {
                errormsg = "ERROR loading archive, file doesn't seem to exist...";
                LOG << CURDATE << errormsg.toStdString() << NL;
                return QImage();
            }

            // Create new archive handler
            struct archive *a = archive_read_new();

            // We allow any type of compression and format
            archive_read_support_filter_all(a);
            archive_read_support_format_all(a);

            // Read file
            int r = archive_read_open_filename(a, archivefile.toLatin1(), 10240);

            // If something went wrong, output error message and stop here
            if(r != ARCHIVE_OK) {
                errormsg = "PQLoadImage::Archive::load(): ERROR: archive_read_open_filename() returned code of " + r;
                LOG << CURDATE << errormsg.toStdString() << NL;
                return QImage();
            }

            // Loop over entries in archive
            struct archive_entry *entry;
            QImage ret;
            while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

                // Read the current file entry
                QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

                // If this is the file we are looking for:
                if(filenameinside == compressedFilename || (compressedFilename == "" && QFileInfo(filenameinside).suffix() != "")) {

                    // Find out the size of the data
                    int64_t size = archive_entry_size(entry);

                    // Create a uchar buffer of that size to hold the image data
                    uchar *buff = new uchar[size];

                    // And finally read the file into the buffer
                    ssize_t r = archive_read_data(a, (void*)buff, size);
                    if(r != size) {
                        errormsg = QString("LoadImage::Archive::load(): ERROR: Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(r).arg(size);
                        LOG << CURDATE << errormsg.toStdString() << NL;
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

            // If image needs to be scaled down, return scaled down version
            if(maxSize.width() > 5 && maxSize.height() > 5)
                if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                    return ret.scaled(maxSize, ::Qt::KeepAspectRatio);

            return ret;

        }

    }

}
