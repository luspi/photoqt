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
#ifdef QUAZIP
#include <quazip5/quazip.h>
#include <quazip5/quazipfile.h>
#endif

#include "errorimage.h"
#include "../../logger.h"

namespace LoadImage {

    namespace QuaZIP {

        QImage load(QString filename, QSize maxSize) {

            // If no zip info is stored, return error image
            if(!filename.contains("::ZIP1::") || !filename.contains("::ZIP2::"))
                return ErrorImage::load("LoadImage::QuaZIP(): ERROR: Don't know which zip file to load file from...");

            // filter out name of zipfile and of compressed file inside
            QString zipfile = filename.split("::ZIP1::").at(1).split("::ZIP2::").at(0);
            QString compressedFilename = filename.split("::ZIP2::").at(1);

            // Extract suffix and remove (added on to signal zip compressed file, not part of actual compressed filename)
            QString suffix = QFileInfo(filename).suffix();
            compressedFilename = compressedFilename.remove(compressedFilename.length()-suffix.length()-1, compressedFilename.length());

            // Access zip file (for unpacking)
            QuaZip c_zip(zipfile);
            c_zip.open(QuaZip::mdUnzip);

            // Extract compressed file and convert to image
            QuaZipFile c_file(&c_zip);
            c_zip.setCurrentFile(compressedFilename);
            c_file.open(QIODevice::ReadOnly);
            QImage ret = QImage::fromData(c_file.readAll());

            // If image needs to be scaled down, return scaled down version
            if(maxSize.width() > 5 && maxSize.height() > 5)
                if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                    return ret.scaled(maxSize, ::Qt::KeepAspectRatio);

            return ret;

        }

    }

}
