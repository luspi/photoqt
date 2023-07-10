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

#include <pqc_loadimage_qt.h>
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
#include <QSize>
#include <QImage>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QtDebug>

PQCLoadImage::PQCLoadImage() {}

QString PQCLoadImage::load(QString filename, QSize requestedSize, QSize &origSize, QImage &img) {

    if(filename.trimmed() == "")
        return "";

    QFileInfo info(filename);

    // check image cache, we might be done right here
    if(PQCImageCache::get().getCachedImage(filename, img)) {

        if(requestedSize.isValid() && (img.width() > requestedSize.width() || img.height() > requestedSize.height()))
            img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

        return "";

    }

    QString err = "";

    // for easier access below
    QString suffix = info.suffix().toLower();


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // first we check for filename suffix matches

    if(PQCImageFormats::get().getEnabledFormatsQt().contains(suffix))
        err = PQCLoadImageQt::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsLibRaw().contains(suffix))
        err = PQCLoadImageRAW::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
        err = PQCLoadImagePoppler::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
        err = PQCLoadImageQtPDF::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsLibArchive().contains(suffix))
        err = PQCLoadImageArchive::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsXCFTools().contains(suffix))
        err = PQCLoadImageXCF::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsMagick().contains(suffix))
        err = PQCLoadImageMagick::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsLibVips().contains(suffix))
        err = PQCLoadImageLibVips::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsFreeImage().contains(suffix))
        err = PQCLoadImageFreeImage::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledFormatsDevIL().contains(suffix))
        err = PQCLoadImageDevil::load(filename, requestedSize, origSize, img);

    if(err != "" && img.isNull() && (PQCImageFormats::get().getEnabledFormatsVideo().contains(suffix) || PQCImageFormats::get().getEnabledFormatsLibmpv().contains(suffix)))
        err = PQCLoadImageVideo::load(filename, requestedSize, origSize, img);


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // if that failed, then we check for mimetype matches
    if(err != "" && img.isNull()) {

        QMimeDatabase db;
        QString mimetype = db.mimeTypeForFile(filename).name();

        if(mimetype != "" && mimetype != "application/octet-stream") {

            if(PQCImageFormats::get().getEnabledMimeTypesQt().contains(mimetype))
                err = PQCLoadImageQt::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibRaw().contains(mimetype))
                err = PQCLoadImageRAW::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
                err = PQCLoadImagePoppler::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
                err = PQCLoadImageQtPDF::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibArchive().contains(mimetype))
                err = PQCLoadImageArchive::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesXCFTools().contains(mimetype))
                err = PQCLoadImageXCF::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesMagick().contains(mimetype))
                err = PQCLoadImageMagick::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesLibVips().contains(mimetype))
                err = PQCLoadImageLibVips::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesFreeImage().contains(mimetype))
                err = PQCLoadImageFreeImage::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && PQCImageFormats::get().getEnabledMimeTypesDevIL().contains(mimetype))
                err = PQCLoadImageDevil::load(filename, requestedSize, origSize, img);

            if(err != "" && img.isNull() && (PQCImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype) || PQCImageFormats::get().getEnabledMimeTypesLibmpv().contains(mimetype)))
                err = PQCLoadImageVideo::load(filename, requestedSize, origSize, img);

        }

    }


#if defined(GRAPHICSMAGICK) || defined(IMAGEMAGICK)
    // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
    if(err != "" && img.isNull()) {

        qDebug() << "null image, try magick";

        // we use two dummy variables to not override the old error image/message
        QString err = PQCLoadImageMagick::load(filename, requestedSize, origSize, img);

    }
#endif

    if(!img.isNull())
        err = "";

    return err;

}
