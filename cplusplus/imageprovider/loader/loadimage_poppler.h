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
#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

#include "errorimage.h"
#include "../../logger.h"

namespace LoadImage {

    namespace PDF {

        QImage load(QString filename, QSize maxSize, int pdfQuality) {

#ifdef POPPLER

            // extract page and totalpage value from filename (appended to end, before suffix)
            int page = 0;
            int totalpage = -1;
            if(filename.contains("__::pqt::__")) {
                QStringList parts = filename.split("__::pqt::__");
                QStringList pageparts = parts.at(1).split("__");
                page = pageparts.at(0).toInt();
                if(pageparts.size() > 1)
                    totalpage = pageparts.at(1).split(".").at(0).toInt();
                filename = filename.remove(QString("__::pqt::__%1__%2").arg(page).arg(totalpage));
            }

            // Load poppler document and render to QImage
            Poppler::Document* document = Poppler::Document::load(filename);
            QImage ret = document->page(page)->renderToImage(pdfQuality, pdfQuality);

            // ensure it fits inside maxSize
            if(maxSize.width() > 5 && maxSize.height() > 5) {
                if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                    return ret.scaled(maxSize, ::Qt::KeepAspectRatio);
            }

            // return render image
            return ret;

#endif

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "LoadImagePDF: PhotoQt was compiled without Poppler support, returning error image" << NL;

        return ErrorImage::load("Failed to load image with Poppler!");


        }

    }

}
