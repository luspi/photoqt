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

        QString err = "";

        QStringList order = PQSettings::get().getImageLibrariesOrder().split(",");
        qDebug() << order;

        QString suffix = info.suffix().toLower();


        //////////////////////////////////////////////
        //////////////////////////////////////////////
        // first we check for filename suffix matches

        for(QString o : order) {

            if(o == "qt" && PQImageFormats::get().getEnabledFormatsQt().contains(suffix))

                loadWithQt(filename, requestedSize, origSize, img, err);

#ifdef RAW

             else if(o == "libraw" && PQImageFormats::get().getEnabledFormatsLibRaw().contains(suffix))

                loadWithLibRaw(filename, requestedSize, origSize, img, err);

#endif
#ifdef POPPLER

            else if(o == "poppler" && PQImageFormats::get().getEnabledFormatsPoppler().contains(suffix))

                loadWithPoppler(filename, requestedSize, origSize, img, err);

#endif
#ifdef LIBARCHIVE

            else if(o == "archive" && PQImageFormats::get().getEnabledFormatsLibArchive().contains(suffix))

                loadWithLibArchive(filename, requestedSize, origSize, img, err);

#endif

            else if(o == "xcftools" && PQImageFormats::get().getEnabledFormatsXCFTools().contains(suffix))

                loadWithXCFTools(filename, requestedSize, origSize, img, err);

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)

            else if(o == "magick" && PQImageFormats::get().getEnabledFormatsMagick().contains(suffix))

                loadWithMagick(filename, requestedSize, origSize, img, err);

#endif
#ifdef FREEIMAGE

            else if(o == "freeimage" && PQImageFormats::get().getEnabledFormatsFreeImage().contains(suffix))

                loadWithFreeImage(filename, requestedSize, origSize, img, err);

#endif
#ifdef DEVIL

            else if(o == "devil" && PQImageFormats::get().getEnabledFormatsDevIL().contains(suffix))

                loadWithDevIL(filename, requestedSize, origSize, img, err);

#endif
#ifdef VIDEO

            else if(o == "video" && PQImageFormats::get().getEnabledFormatsVideo().contains(suffix))

                loadWithVideo(filename, requestedSize, origSize, img, err);

#endif


            if(!img.isNull())
                break;

        }


        //////////////////////////////////////////////
        //////////////////////////////////////////////
        // if that failed, then we check for mimetype matches

        if(img.isNull() && !img.isNull()) {

            QString mimetype = db.mimeTypeForFile(filename).name();

            for(QString o : order) {

                if(o == "qt" && PQImageFormats::get().getEnabledMimeTypesQt().contains(mimetype))

                    loadWithQt(filename, requestedSize, origSize, img, err);

#ifdef RAW

                 else if(o == "libraw" && PQImageFormats::get().getEnabledMimeTypesLibRaw().contains(mimetype))

                    loadWithLibRaw(filename, requestedSize, origSize, img, err);

#endif
#ifdef POPPLER

                else if(o == "poppler" && PQImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))

                    loadWithPoppler(filename, requestedSize, origSize, img, err);

#endif
#ifdef LIBARCHIVE

                else if(o == "archive" && PQImageFormats::get().getEnabledMimeTypesLibArchive().contains(mimetype))

                    loadWithLibArchive(filename, requestedSize, origSize, img, err);

#endif

                else if(o == "xcftools" && PQImageFormats::get().getEnabledMimeTypesXCFTools().contains(mimetype))

                    loadWithXCFTools(filename, requestedSize, origSize, img, err);

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)

                else if(o == "magick" && PQImageFormats::get().getEnabledMimeTypesMagick().contains(mimetype))

                    loadWithMagick(filename, requestedSize, origSize, img, err);

#endif
#ifdef FREEIMAGE

                else if(o == "freeimage" && PQImageFormats::get().getEnabledMimeTypesFreeImage().contains(mimetype))

                    loadWithFreeImage(filename, requestedSize, origSize, img, err);

#endif
#ifdef DEVIL

                else if(o == "devil" && PQImageFormats::get().getEnabledMimeTypesDevIL().contains(mimetype))

                    loadWithDevIL(filename, requestedSize, origSize, img, err);

#endif
#ifdef VIDEO

                else if(o == "video" && PQImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype))

                    loadWithVideo(filename, requestedSize, origSize, img, err);

#endif

                if(!img.isNull())
                    break;

            }

        }


#if defined(GRAPHICSMAGICK) || defined(IMAGEMAGICK)
        // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
        if(img.isNull()) {

            // we use two dummy variables to not override the old error image/message
            QImage newimg;
            QString newerr = "";
            loadWithMagick(filename, requestedSize, origSize, newimg, newerr);
            if(newerr == "") {
                img = newimg;
                err = "";
            }

        }
#endif

        if(!img.isNull())
            err = "";

        // cache image (if not scaled)
        if(!img.isNull() && img.size() == *origSize && requestedSize != QSize(-1,-1) && *origSize != QSize(-1,-1))
            load_helper->saveImageToCache(filename, &img);

        return err;

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

    inline void loadWithQt(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with qt" << NL;

        QFileInfo info(filename);
        QString suffix = info.suffix();
        QString qterr = "";

        img = load_qt->load(filename, requestedSize, origSize);

        if(load_qt->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with qt" << NL;
            err += QString("<b>Qt</b><br>%1<br><br>").arg(load_qt->errormsg);
        }

    }

    inline void loadWithLibRaw(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with libraw" << NL;

        img = load_raw->load(filename, requestedSize, origSize);

        if(load_raw->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with libraw" << NL;
            err += QString("<b>LibRaw</b><br>%1<br><br>").arg(load_raw->errormsg);
        }

    }

    inline void loadWithPoppler(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with poppler" << NL;

        img = load_poppler->load(filename, requestedSize, origSize);

        if(load_poppler->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with poppler" << NL;
            err += QString("<b>Poppler</b><br>%1<br><br>").arg(load_poppler->errormsg);
        }

    }

    inline void loadWithLibArchive(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with archive" << NL;

        QFileInfo info(filename);
        QString suffix = info.suffix();

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
                if(load_unrar->errormsg == "")
                    used_unrar = true;
                else {
                    LOG << CURDATE << "PQLoadImage::load(): failed to load image with unrar" << NL;
                    err += QString("<b>unrar</b><br>%1<br><br>").arg(load_unrar->errormsg);
                }
            }
        }

        if(!used_unrar) {
            img = load_archive->load(filename, requestedSize, origSize);
            if(load_archive->errormsg != "") {
                LOG << CURDATE << "PQLoadImage::load(): failed to load image with libarchive" << NL;
                err += QString("<b>libarchive</b><br>%1<br><br>").arg(load_archive->errormsg);
            }
        }


    }

    inline void loadWithXCFTools(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with xcftools" << NL;

        img = load_xcf->load(filename, requestedSize, origSize);

        if(load_xcf->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with xcftools" << NL;
            err += QString("<b>XCFTools</b><br>%1<br><br>").arg(load_xcf->errormsg);
        }

    }

    inline void loadWithMagick(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

#ifdef IMAGEMAGICK
        DBG << CURDATE << "attempt to load image with imagemagick" << NL;
#elif defined(GRAPHICSMAGICK)
        DBG << CURDATE << "attempt to load image with graphicsmagick" << NL;
#endif

        img = load_magick->load(filename, requestedSize, origSize);

        if(load_magick->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with magick" << NL;
            err += QString("<b>Magick</b><br>%1<br><br>").arg(load_magick->errormsg);
        }

    }

    inline void loadWithFreeImage(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with freeimage" << NL;

        img = load_freeimage->load(filename, requestedSize, origSize);

        if(load_freeimage->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with freeimage" << NL;
            err += QString("<b>FreeImage</b><br>%1<br><br>").arg(load_freeimage->errormsg);
        }

    }

    inline void loadWithDevIL(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with devil" << NL;

        img = load_devil->load(filename, requestedSize, origSize);

        if(load_devil->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with devil" << NL;
            err += QString("<b>DevIL</b><br>%1<br><br>").arg(load_devil->errormsg);
        }

    }

    inline void loadWithVideo(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

        DBG << CURDATE << "attempt to load image with video" << NL;

        img = load_video->load(filename, requestedSize, origSize);

        if(load_video->errormsg != "") {
            LOG << CURDATE << "PQLoadImage::load(): failed to load image with video" << NL;
            err += QString("<b>Video</b><br>%1<br><br>").arg(load_video->errormsg);
        }

    }

};

#endif // PQLOADIMAGE_H
