/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#include <pqc_loadimage_qt.h>
#include <pqc_loadimage_resvg.h>
#include <pqc_loadimage_raw.h>
#include <pqc_loadimage_poppler.h>
#include <pqc_loadimage_qtpdf.h>
#include <pqc_loadimage_xcf.h>
#include <pqc_loadimage_magick.h>
#include <pqc_loadimage_libvips.h>
#include <pqc_loadimage_archive.h>
#include <pqc_loadimage_devil.h>
#include <pqc_loadimage_freeimage.h>
#include <pqc_loadimage_video.h>

#include <pqc_loadimage.h>
#include <pqc_settings.h>
#include <pqc_imageformats.h>
#include <scripts/pqc_scriptsimages.h>
#include <QSize>
#include <QImage>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QtDebug>

PQCLoadImage::PQCLoadImage() {}
PQCLoadImage::~PQCLoadImage() {}

QSize PQCLoadImage::load(QString filename) {

    if(filename.trimmed() == "")
        return QSize();

    QFileInfo info(filename);

    // check image cache, we might be done right here
    QImage img;
    if(PQCImageCache::get().getCachedImage(filename, img))
        return img.size();

    // for easier access below
    QString suffix = info.suffix().toLower();

    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // first we check for filename suffix matches

    // we need to explicitely set the initial size to be 0,0 otherwise the isNull check below will always fail
    QSize sze(0,0);

    // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
    if(PQCImageFormats::get().getEnabledFormatsResvg().contains(suffix))
        sze = PQCLoadImageResvg::loadSize(filename);
#endif

#ifdef PQMPOPPLER
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
        sze = PQCLoadImagePoppler::loadSize(filename);
#endif

#ifdef PQMQTPDF
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
        sze = PQCLoadImageQtPDF::loadSize(filename);
#endif

    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsQt().contains(suffix))
        sze = PQCLoadImageQt::loadSize(filename);

#ifdef PQMRAW
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsLibRaw().contains(suffix))
        sze = PQCLoadImageRAW::loadSize(filename);
#endif

#ifdef PQMLIBARCHIVE
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsLibArchive().contains(suffix))
        sze = PQCLoadImageArchive::loadSize(filename);
#endif

    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsXCFTools().contains(suffix))
        sze = PQCLoadImageXCF::loadSize(filename);

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsMagick().contains(suffix))
        sze = PQCLoadImageMagick::loadSize(filename);
#endif

#ifdef PQMLIBVIPS
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsLibVips().contains(suffix))
        sze = PQCLoadImageLibVips::loadSize(filename);
#endif

#ifdef PQMFREEIMAGE
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsFreeImage().contains(suffix))
        sze = PQCLoadImageFreeImage::loadSize(filename);
#endif

#ifdef PQMDEVIL
    if(sze.isNull() && PQCImageFormats::get().getEnabledFormatsDevIL().contains(suffix))
        sze = PQCLoadImageDevil::loadSize(filename);
#endif

    if(sze.isNull() && (PQCImageFormats::get().getEnabledFormatsVideo().contains(suffix) || PQCImageFormats::get().getEnabledFormatsLibmpv().contains(suffix)))
        sze = PQCLoadImageVideo::loadSize(filename);


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // if that failed, then we check for mimetype matches
    if(sze.isNull()) {

        QMimeDatabase db;
        QString mimetype = db.mimeTypeForFile(filename).name();

        if(mimetype != "" && mimetype != "application/octet-stream") {

            // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
            if(PQCImageFormats::get().getEnabledMimeTypesResvg().contains(mimetype))
                sze = PQCLoadImageResvg::loadSize(filename);
#endif

#ifdef PQMPOPPLER
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
                sze = PQCLoadImagePoppler::loadSize(filename);
#endif

#ifdef PQMQTPDF
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
                sze = PQCLoadImageQtPDF::loadSize(filename);
#endif

            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesQt().contains(mimetype))
                sze = PQCLoadImageQt::loadSize(filename);

#ifdef PQMRAW
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibRaw().contains(mimetype))
                sze = PQCLoadImageRAW::loadSize(filename);
#endif

#ifdef PQMLIBARCHIVE
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibArchive().contains(mimetype))
                sze = PQCLoadImageArchive::loadSize(filename);
#endif

            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesXCFTools().contains(mimetype))
                sze = PQCLoadImageXCF::loadSize(filename);

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesMagick().contains(mimetype))
                sze = PQCLoadImageMagick::loadSize(filename);
#endif

#ifdef PQMLIBVIPS
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibVips().contains(mimetype))
                sze = PQCLoadImageLibVips::loadSize(filename);
#endif

#ifdef PQMFREEIMAGE
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesFreeImage().contains(mimetype))
                sze = PQCLoadImageFreeImage::loadSize(filename);
#endif

#ifdef PQMDEVIL
            if(sze.isNull() && PQCImageFormats::get().getEnabledMimeTypesDevIL().contains(mimetype))
                sze = PQCLoadImageDevil::loadSize(filename);
#endif

            if(sze.isNull() && (PQCImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype) || PQCImageFormats::get().getEnabledMimeTypesLibmpv().contains(mimetype)))
                sze = PQCLoadImageVideo::loadSize(filename);

        }

    }


#if defined(PQMGRAPHICSMAGICK) || defined(PQMIMAGEMAGICK)
    // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
    if(sze.isNull()) {

        // we use two dummy variables to not override the old error image/message
        sze = PQCLoadImageMagick::loadSize(filename);

    }
#endif

    return sze;

}

QString PQCLoadImage::load(QString filename, QSize requestedSize, QSize &origSize, QImage &img) {

    if(filename.trimmed() == "")
        return "";

    QFileInfo info(filename);

    // check image cache, we might be done right here
    if(PQCImageCache::get().getCachedImage(filename, img)) {

        if(requestedSize.width() > 2 && requestedSize.height() > 2 && (img.width() > requestedSize.width() || img.height() > requestedSize.height()))
            img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

        return "";

    }

    QString err = "";

    // for easier access below
    QString suffix = info.suffix().toLower();


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // first we check for filename suffix matches

    // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
    if(PQCImageFormats::get().getEnabledFormatsResvg().contains(suffix))
        err = PQCLoadImageResvg::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMPOPPLER
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
        err = PQCLoadImagePoppler::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMQTPDF
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
        err = PQCLoadImageQtPDF::load(filename, requestedSize, origSize, img);
#endif

    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsQt().contains(suffix))
        err = PQCLoadImageQt::load(filename, requestedSize, origSize, img);

#ifdef PQMRAW
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsLibRaw().contains(suffix))
        err = PQCLoadImageRAW::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMLIBARCHIVE
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsLibArchive().contains(suffix))
        err = PQCLoadImageArchive::load(filename, requestedSize, origSize, img);
#endif

    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsXCFTools().contains(suffix))
        err = PQCLoadImageXCF::load(filename, requestedSize, origSize, img);

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsMagick().contains(suffix))
        err = PQCLoadImageMagick::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMLIBVIPS
    if((err != "" || img.isNull()) && PQCImageFormats::get().getEnabledFormatsLibVips().contains(suffix))
        err = PQCLoadImageLibVips::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMFREEIMAGE
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsFreeImage().contains(suffix))
        err = PQCLoadImageFreeImage::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMDEVIL
    if(img.isNull() && PQCImageFormats::get().getEnabledFormatsDevIL().contains(suffix))
        err = PQCLoadImageDevil::load(filename, requestedSize, origSize, img);
#endif

    if(img.isNull() && (PQCImageFormats::get().getEnabledFormatsVideo().contains(suffix) || PQCImageFormats::get().getEnabledFormatsLibmpv().contains(suffix)))
        err = PQCLoadImageVideo::load(filename, requestedSize, origSize, img);


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // if that failed, then we check for mimetype matches
    if(img.isNull()) {

        QMimeDatabase db;
        QString mimetype = db.mimeTypeForFile(filename).name();

        if(mimetype != "" && mimetype != "application/octet-stream") {

            // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
            if(PQCImageFormats::get().getEnabledMimeTypesResvg().contains(suffix))
                err = PQCLoadImageResvg::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMPOPPLER
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
                err = PQCLoadImagePoppler::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMQTPDF
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
                err = PQCLoadImageQtPDF::load(filename, requestedSize, origSize, img);
#endif

            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesQt().contains(mimetype))
                err = PQCLoadImageQt::load(filename, requestedSize, origSize, img);

#ifdef PQMRAW
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibRaw().contains(mimetype))
                err = PQCLoadImageRAW::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMLIBARCHIVE
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibArchive().contains(mimetype))
                err = PQCLoadImageArchive::load(filename, requestedSize, origSize, img);
#endif

            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesXCFTools().contains(mimetype))
                err = PQCLoadImageXCF::load(filename, requestedSize, origSize, img);

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesMagick().contains(mimetype))
                err = PQCLoadImageMagick::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMLIBVIPS
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibVips().contains(mimetype))
                err = PQCLoadImageLibVips::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMFREEIMAGE
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesFreeImage().contains(mimetype))
                err = PQCLoadImageFreeImage::load(filename, requestedSize, origSize, img);
#endif

#ifdef PQMDEVIL
            if(img.isNull() && PQCImageFormats::get().getEnabledMimeTypesDevIL().contains(mimetype))
                err = PQCLoadImageDevil::load(filename, requestedSize, origSize, img);
#endif

            if(img.isNull() && (PQCImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype) || PQCImageFormats::get().getEnabledMimeTypesLibmpv().contains(mimetype)))
                err = PQCLoadImageVideo::load(filename, requestedSize, origSize, img);

        }

    }


#if defined(PQMGRAPHICSMAGICK) || defined(PQMIMAGEMAGICK)
    // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
    if(img.isNull()) {

        qDebug() << "null image, try magick";

        // we use two dummy variables to not override the old error image/message
        QString err = PQCLoadImageMagick::load(filename, requestedSize, origSize, img);

    }
#endif

    if(!img.isNull()) {
        err = "";
        PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
    }

    return err;

}
