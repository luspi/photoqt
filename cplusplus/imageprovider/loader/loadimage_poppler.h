/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef PQLOADIMAGESPOPPLER_H
#define PQLOADIMAGESPOPPLER_H

#include <QImage>
#include "../../settings/settings.h"
#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

#include "../../logger.h"

class PQLoadImagePoppler {

public:
    PQLoadImagePoppler() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

#ifdef POPPLER

        errormsg = "";

        // extract page and totalpage value from filename (prepended to filename (after filepath))
        int page = 0;
        if(filename.contains("::PQT::")) {
            page = filename.split("::PQT::").at(0).toInt();
            filename = filename.split("::PQT::").at(1);
        }

        // Load poppler document and render to QImage
        Poppler::Document* document = Poppler::Document::load(filename);
        if(!document || document->isLocked()) {
            errormsg = "Invalid PDF document, unable to load!";
            LOG << CURDATE << "PQLoadImagePoppler::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }
        document->setRenderHint(Poppler::Document::TextAntialiasing);
        document->setRenderHint(Poppler::Document::Antialiasing);
        Poppler::Page *p = document->page(page);
        if(p == nullptr) {
            errormsg = QString("Unable to read page %1").arg(page);
            LOG << CURDATE << "PQLoadImagePoppler::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        double useQuality = PQSettings::get().getPdfQuality();
        if(maxSize.width() != -1 && maxSize.height() != -1) {
            double factor1 = maxSize.width()/p->pageSizeF().width();
            double factor2 = maxSize.height()/p->pageSizeF().height();
            double factor = qMin(factor1, factor2);
            useQuality = 72.0*factor;
        }

        QImage ret = p->renderToImage(useQuality, useQuality);

        *origSize = p->pageSize()*(PQSettings::get().getPdfQuality()/72.0);
        delete document;

        // return render image
        return ret;

#endif

    errormsg = "Failed to load image, Poppler not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImagePoppler::load(): " << errormsg.toStdString() << NL;
    return QImage();


    }

    QString errormsg;

};

#endif // PQLOADIMAGESPOPPLER_H
