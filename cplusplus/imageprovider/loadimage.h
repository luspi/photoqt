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
#include "loader/loadimage_graphicsmagick.h"
#include "loader/loadimage_imagemagick.h"
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
        load_graphicsmagick = new PQLoadImageGraphicsMagick;
        load_imagemagick = new PQLoadImageImageMagick;
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
        delete load_graphicsmagick;
        delete load_imagemagick;
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

        // this stores whether we already attempted to use GraphicsMagick/ImageMagick once
        // if loading fails, then this way we don't need to try again with graphicsmagick/imagemagick, thus being slightly faster
        bool triedWithGraphicsMagick = false;
        bool triedWithImageMagick = false;

        for(QString o : order) {

            if(o == "qt") {

                if(PQImageFormats2::get().getEnabledFileformatsQt().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with qt" << NL;

                    if(suffix == "svg" || suffix == "svgz" || PQImageFormats2::get().getEnabledFileformatsQt().contains("*." + suffix)) {
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

                if(PQImageFormats2::get().getEnabledFileformatsRAW().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with libraw" << NL;

                    img = load_raw->load(filename, requestedSize, origSize);
                    ret_err = load_raw->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

#endif

            } else if(o == "poppler") {

#ifdef POPPLER

                if(PQImageFormats2::get().getEnabledFileformatsPoppler().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with poppler" << NL;

                    img = load_poppler->load(filename, requestedSize, origSize);
                    ret_err = load_poppler->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

#endif

            } else if(o == "archive") {

#ifdef LIBARCHIVE

                if(PQImageFormats2::get().getEnabledFileformatsArchive().contains("*." + suffix)) {

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

                if(PQImageFormats2::get().getEnabledFileformatsXCF().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with xcftools" << NL;

                    img = load_xcf->load(filename, requestedSize, origSize);
                    ret_err = load_xcf->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

            } else if(o == "graphicsmagick") {

#ifdef GRAPHICSMAGICK

                if(PQImageFormats2::get().getEnabledFileformatsGraphicsMagick().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with graphicsmagick" << NL;

                    triedWithGraphicsMagick = true;

                    img = load_graphicsmagick->load(filename, requestedSize, origSize);
                    ret_err = load_graphicsmagick->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

#endif

            } else if(o == "imagemagick") {

#ifdef IMAGEMAGICK

                if(PQImageFormats2::get().getEnabledFileformatsImageMagick().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with imagemagick" << NL;

                    triedWithImageMagick = true;

                    img = load_imagemagick->load(filename, requestedSize, origSize);
                    ret_err = load_imagemagick->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

#endif

            } else if(o == "freeimage") {

#ifdef FREEIMAGE

                if(PQImageFormats2::get().getEnabledFileformatsFreeImage().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with freeimage" << NL;

                    img = load_freeimage->load(filename, requestedSize, origSize);
                    ret_err = load_freeimage->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

#endif

            } else if(o == "devil") {

#ifdef DEVIL

                if(PQImageFormats2::get().getEnabledFileformatsDevIL().contains("*." + suffix)) {

                    DBG << CURDATE << "attempt to load image with devil" << NL;

                    img = load_devil->load(filename, requestedSize, origSize);
                    ret_err = load_devil->errormsg;

                    if(ret_err != "")
                        LOG << CURDATE << "PQLoadImage::load(): failed to load image with " << o.toStdString() << NL;

                }

#endif

            } else if(o == "video") {

#ifdef VIDEO

                if(PQImageFormats2::get().getEnabledFileformatsVideo().contains("*." + suffix)) {

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

        // if everything failed, we make sure to try one more time with ImageMagick to see what could be done
        if(ret_err != "" && !triedWithGraphicsMagick) {

#ifdef GRAPHICSMAGICK

            DBG << CURDATE << "loading image failed, trying with graphicsmagick" << NL;

            QImage new_img = load_graphicsmagick->load(filename, requestedSize, origSize);
            QString new_ret_err = load_graphicsmagick->errormsg;
            if(new_ret_err == "") {
                img = new_img;
                ret_err = "";
            }

        }

#endif

        if(ret_err != "" && !triedWithImageMagick) {

#ifdef IMAGEMAGICK

            DBG << CURDATE << "loading image failed, trying with imagemagick" << NL;

            QImage new_img = load_imagemagick->load(filename, requestedSize, origSize);
            QString new_ret_err = load_imagemagick->errormsg;
            if(new_ret_err == "") {
                img = new_img;
                ret_err = "";
            }

#endif

        }

        // cache image (if not scaled)
        if(ret_err == "" && img.width() == origSize->width() && img.height() == origSize->height() && requestedSize.width() == -1 && requestedSize.height() == -1)
            load_helper->saveImageToCache(filename, &img);

        return ret_err;

    }

private:
    int foundExternalUnrar;
    PQLoadImageHelper *load_helper;
    PQLoadImageErrorImage *load_err;
    PQLoadImageQt *load_qt;
    PQLoadImageGraphicsMagick *load_graphicsmagick;
    PQLoadImageImageMagick *load_imagemagick;
    PQLoadImageXCF *load_xcf;
    PQLoadImagePoppler *load_poppler;
    PQLoadImageRAW *load_raw;
    PQLoadImageDevil *load_devil;
    PQLoadImageFreeImage *load_freeimage;
    PQLoadImageArchive *load_archive;
    PQLoadImageUNRAR *load_unrar;
    PQLoadImageVideo *load_video;

};

#endif // PQLOADIMAGE_H
