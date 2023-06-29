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

#include <pqc_loadimage_poppler.h>
#include <pqc_imagecache.h>
#include <pqc_settings.h>
#include <QSize>
#include <QImage>
#ifdef POPPLER
#include <poppler/qt6/poppler-qt6.h>
#endif

PQCLoadImagePoppler::PQCLoadImagePoppler() {}

QSize PQCLoadImagePoppler::loadSize(QString filename) {

    qDebug() << "args: filename =" << filename;

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    int page = 0;
    if(filename.contains("::PQT::")) {
        page = filename.split("::PQT::").at(0).toInt();
        filename = filename.split("::PQT::").at(1);
    }

    // Load poppler document and render to QImage
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(filename);
    if(!document || document->isLocked()) {
        qWarning() << "Invalid PDF document, unable to load!";
        return QSize();
    }

    std::unique_ptr<Poppler::Page> p = document->page(page);
    if(p == nullptr) {
        qWarning() << QString("Unable to read page %1").arg(page);
        return QSize();
    }

    return p->pageSize()*(PQCSettings::get()["filetypesPDFQuality"].toDouble()/72.0);

}

QString PQCLoadImagePoppler::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

#ifdef POPPLER

    QString errormsg = "";

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    int page = 0;
    if(filename.contains("::PQT::")) {
        page = filename.split("::PQT::").at(0).toInt();
        filename = filename.split("::PQT::").at(1);
    }

    // Load poppler document and render to QImage
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(filename);
    if(!document || document->isLocked()) {
        errormsg = "Invalid PDF document, unable to load!";
        qWarning() << errormsg;
        return errormsg;
    }
    document->setRenderHint(Poppler::Document::TextAntialiasing);
    document->setRenderHint(Poppler::Document::Antialiasing);
    std::unique_ptr<Poppler::Page> p = document->page(page);
    if(p == nullptr) {
        errormsg = QString("Unable to read page %1").arg(page);
        qWarning() << errormsg;
        return errormsg;
    }

    const double quality = PQCSettings::get()["filetypesPDFQuality"].toDouble();
    double useQuality = quality;
    if(maxSize.width() != -1 && maxSize.height() != -1) {
        double factor1 = maxSize.width()/p->pageSizeF().width();
        double factor2 = maxSize.height()/p->pageSizeF().height();
        double factor = qMin(factor1, factor2);
        useQuality = 72.0*factor;
    }

    img = p->renderToImage(useQuality, useQuality);

    if(!img.isNull())
        PQCImageCache::get().saveImageToCache(filename, &img);

    origSize = p->pageSize()*(quality/72.0);

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

    // return render image
    return "";

#endif

    origSize = QSize(-1,-1);
    errormsg = "Failed to load image, Poppler not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

}
