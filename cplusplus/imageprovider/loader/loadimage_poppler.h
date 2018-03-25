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

            // extract page and totalpage value from filename (prepended to filename (after filepath))
            int page = 0;
            if(filename.contains("::PQT1::") && filename.contains("::PQT2::")) {

                QString pageinfo = filename.split("::PQT1::").at(1).split("::PQT2::").at(0);
                page = pageinfo.split("::").at(0).toInt();

                filename = filename.remove(QString("::PQT1::%1::PQT2::").arg(pageinfo));
            }

            // Load poppler document and render to QImage
            Poppler::Document* document = Poppler::Document::load(filename);
            if(!document || document->isLocked()) {
                std::stringstream ss;
                ss << "LoadImage::PDF::load(): ERROR: Invalid PDF document, unable to load!";
                LOG << CURDATE << ss.str() << NL;
                return ErrorImage::load(QString::fromStdString(ss.str()));
            }
            document->setRenderHint(Poppler::Document::TextAntialiasing);
            document->setRenderHint(Poppler::Document::Antialiasing);
            QImage ret = document->page(page)->renderToImage(pdfQuality, pdfQuality);
            delete document;

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
