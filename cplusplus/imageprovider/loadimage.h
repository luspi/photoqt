/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQLOADIMAGE_H
#define PQLOADIMAGE_H

#include <QSize>
#include <QFileInfo>
#include "../settings/imageformats.h"
#include "loader/errorimage.h"
#include "loader/loadimage_qt.h"
#include "loader/loadimage_magick.h"
#include "loader/loadimage_xcf.h"
#include "loader/loadimage_poppler.h"
#include "loader/loadimage_raw.h"
#include "loader/loadimage_devil.h"
#include "loader/loadimage_freeimage.h"
#include "loader/loadimage_archive.h"
#include "loader/loadimage_unrar.h"
#include "loader/loadimage_video.h"
#include "loader/helper.h"

class PQLoadImage {

public:
    PQLoadImage() {
        foundExternalUnrar = -1;
        load_helper = new PQLoadImageHelper;
        load_err = new PQLoadImageErrorImage;
        load_qt = new PQLoadImageQt;
        load_magick = new PQLoadImageMagick;
        load_xcf = new PQLoadImageXCF;
        load_poppler = new PQLoadImagePoppler;
        load_raw = new PQLoadImageRAW;
        load_devil = new PQLoadImageDevil;
        load_freeimage = new PQLoadImageFreeImage;
        load_archive = new PQLoadImageArchive;
        load_unrar = new PQLoadImageUNRAR;
        load_video = new PQLoadImageVideo;
    }

    ~PQLoadImage() {
        delete load_helper;
        delete load_err;
        delete load_qt;
        delete load_magick;
        delete load_xcf;
        delete load_poppler;
        delete load_raw;
        delete load_devil;
        delete load_freeimage;
        delete load_archive;
        delete load_unrar;
        delete load_video;
    }

    QString load(QString filename, QSize requestedSize, QSize *origSize, QImage &img) {

        DBG << CURDATE << "PQLoadImage::load()" << NL
            << CURDATE << "** filename = " << filename.toStdString() << NL
            << CURDATE << "** requestedSize = " << requestedSize.width() << "x" << requestedSize.height() << NL;

        if(filename.trimmed() == "")
            return "";

        QFileInfo info(filename);

        // check image cache, we might be done right here
        if(load_helper->getCachedImage(filename, img)) {
            load_helper->ensureImageFitsMaxSize(img, requestedSize);
            return "";
        }

        QString ret_err = "";

        QStringList order = PQSettings::get().getImageLibrariesOrder().split(",");

        QString suffix = info.suffix().toLower();
        QString mimetype = db.mimeTypeForFile(filename).name();

        // this stores whether we already attempted to use GraphicsMagick/ImageMagick once
        // if loading fails, then this way we don't need to try again with graphicsmagick/imagemagick, thus being slightly faster
        bool triedWithImageOrGraphicsMagick = false;

        // first check filetypes ("ft") for all libs, then mimetypes ("mt")
        // some mimetypes for RAW files are recognized by Qt and Qt might load a thumbnail version only of that file
        // this way libraw would never be called for the full image
        // thus first checking all file endings helps with that
        for(int ftmt = 0; ftmt < 2; ++ftmt) {

            for(QString o : order) {

                if(o == "qt") {

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsQt().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesQt().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with qt" << NL;

                        if(suffix == "svg" || suffix == "svgz" || PQImageFormats::get().getEnabledFormatsQt().contains(suffix)) {
                            img = load_qt->load(filename, requestedSize, origSize);
                            ret_err = load_qt->errormsg;
                        }

                        if(ret_err != "" || img.width() < 1 || img.height() < 1) {
                            img = load_qt->load(filename, requestedSize, origSize);
                            ret_err = load_qt->errormsg;
                        }

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

                } else if(o == "libraw") {

#ifdef RAW

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsLibRaw().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesLibRaw().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with libraw" << NL;

                        img = load_raw->load(filename, requestedSize, origSize);
                        ret_err = load_raw->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "poppler") {

#ifdef POPPLER

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsPoppler().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with poppler" << NL;

                        img = load_poppler->load(filename, requestedSize, origSize);
                        ret_err = load_poppler->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "archive") {

#ifdef LIBARCHIVE

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsLibArchive().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesLibArchive().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with archive" << NL;

                        bool used_unrar = false;

                        if(PQSettings::get().getArchiveUseExternalUnrar() && (info.suffix().toLower() == "rar" || info.suffix().toLower() == "cbr")) {
                            if(foundExternalUnrar == -1) {
                                QProcess which;
                                which.setStandardOutputFile(QProcess::nullDevice());
                                which.start("which", QStringList() << "unrar");
                                which.waitForFinished();
                                foundExternalUnrar = which.exitCode() ? 0 : 1;
                            }
                            if(foundExternalUnrar == 1) {
                                img = load_unrar->load(filename, requestedSize, origSize);
                                ret_err = load_unrar->errormsg;
                                if(ret_err == "")
                                    used_unrar = true;
                            }
                        }

                        if(!used_unrar) {
                            img = load_archive->load(filename, requestedSize, origSize);
                            ret_err = load_archive->errormsg;
                        }

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "xcftools") {

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsXCFTools().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesXCFTools().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with xcftools" << NL;

                        img = load_xcf->load(filename, requestedSize, origSize);
                        ret_err = load_xcf->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

                } else if(o == "graphicsmagick") {

#ifdef GRAPHICSMAGICK

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsGraphicsMagick().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesGraphicsMagick().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with graphicsmagick" << NL;

                        triedWithImageOrGraphicsMagick = true;

                        img = load_magick->load(filename, requestedSize, origSize);
                        ret_err = load_magick->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "imagemagick") {

#ifdef IMAGEMAGICK

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsImageMagick().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesImageMagick().contains(mimetype))) {


                        DBG << CURDATE << "attempt to load image with imagemagick" << NL;

                        triedWithImageOrGraphicsMagick = true;

                        img = load_magick->load(filename, requestedSize, origSize);
                        ret_err = load_magick->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "freeimage") {

#ifdef FREEIMAGE

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsFreeImage().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesFreeImage().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with freeimage" << NL;

                        img = load_freeimage->load(filename, requestedSize, origSize);
                        ret_err = load_freeimage->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "devil") {

#ifdef DEVIL

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsDevIL().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesDevIL().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with devil" << NL;

                        img = load_devil->load(filename, requestedSize, origSize);
                        ret_err = load_devil->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                } else if(o == "video") {

#ifdef VIDEO

                    if((ftmt == 0 && PQImageFormats::get().getEnabledFormatsVideo().contains(suffix))
                            || (ftmt == 1 && PQImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype))) {

                        DBG << CURDATE << "attempt to load image with video" << NL;

                        img = load_video->load(filename, requestedSize, origSize);
                        ret_err = load_video->errormsg;

                        if(ret_err != "")
                            LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                    }

#endif

                }

                if(ret_err == "" && img.width() > 0 && img.height() > 0) {
                    break;
                }

            }

            if(ret_err == "" && img.width() > 0 && img.height() > 0) {
                break;
            }

        }

#if defined(GRAPHICSMAGICK) || defined(IMAGEMAGICK)
        // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
        if(ret_err != "" && !triedWithImageOrGraphicsMagick) {

#ifdef GRAPHICSMAGICK
            DBG << CURDATE << "Loading image failed, trying with GraphicsMagick" << NL;
#endif
#ifdef IMAGEMAGICK
            DBG << CURDATE << "Loading image failed, trying with ImageMagick" << NL;
#endif

            QImage new_img = load_magick->load(filename, requestedSize, origSize);
            QString new_ret_err = load_magick->errormsg;
            if(new_ret_err == "") {
                img = new_img;
                ret_err = "";
            }

        }
#endif

        // cache image (if not scaled)
        if(ret_err == "" && img.width() == origSize->width() && img.height() == origSize->height() && requestedSize != QSize(-1,-1) && *origSize != QSize(-1,-1))
            load_helper->saveImageToCache(filename, &img);

        return ret_err.trimmed();

    }

private:
    int foundExternalUnrar;
    PQLoadImageHelper *load_helper;
    PQLoadImageErrorImage *load_err;
    PQLoadImageQt *load_qt;
    PQLoadImageMagick *load_magick;
    PQLoadImageXCF *load_xcf;
    PQLoadImagePoppler *load_poppler;
    PQLoadImageRAW *load_raw;
    PQLoadImageDevil *load_devil;
    PQLoadImageFreeImage *load_freeimage;
    PQLoadImageArchive *load_archive;
    PQLoadImageUNRAR *load_unrar;
    PQLoadImageVideo *load_video;

    QMimeDatabase db;

};

#endif // PQLOADIMAGE_H
