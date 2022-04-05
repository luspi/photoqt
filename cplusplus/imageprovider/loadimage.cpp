/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "loadimage.h"

PQLoadImage::PQLoadImage() {
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

PQLoadImage::~PQLoadImage() {
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


QString PQLoadImage::load(QString filename, QSize requestedSize, QSize *origSize, QImage &img) {

    DBG << CURDATE << "PQLoadImage::load()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** requestedSize = " << requestedSize.width() << "x" << requestedSize.height() << NL;

    if(filename.trimmed() == "")
        return "";

    QFileInfo info(filename);

    // check image cache, we might be done right here
    if(PQSettings::get()["imageviewCache"].toInt() > 0 && load_helper->getCachedImage(filename, img)) {
        load_helper->ensureImageFitsMaxSize(img, requestedSize);
        return "";
    }

    QString err = "";

    // the order in which to traverse the libraries
    // it is best to start with specilized libraries first before getting to the more catch-all libraries
    // the specialized ones are usually better for their specific image formats then the catch-all ones
    QStringList order;
    order << "qt"
#ifdef RAW
          << "libraw"
#endif
#ifdef POPPLER
          << "poppler"
#endif
#ifdef LIBARCHIVE
          << "archive"
#endif
          << "xcftools"
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
          << "magick"
#endif
#ifdef FREEIMAGE
          << "freeimage"
#endif
#ifdef DEVIL
          << "devil"
#endif
#ifdef VIDEO
          << "video"
#endif
    ;

    // for easier access below
    QString suffix = info.suffix().toLower();


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // first we check for filename suffix matches

    for(const QString &o : qAsConst(order)) {

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

        // the 'application/octet-stream' mime type simply means 'binary file', not enough info for our purposes
        if(mimetype != "" && mimetype != "application/octet-stream") {

            for(const QString &o : qAsConst(order)) {

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

    }


#if defined(GRAPHICSMAGICK) || defined(IMAGEMAGICK)
    // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
    if(img.isNull()) {

        qDebug() << "null image, try magick";

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
    // we always cache the last image if nothing else
    if(!img.isNull() && img.size() == *origSize && *origSize != QSize(-1,-1))
        load_helper->saveImageToCache(filename, &img);

    if(requestedSize != QSize(-1,-1) && requestedSize != img.size())
        img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    return err;

}

void PQLoadImage::loadWithQt(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with qt" << NL;

    img = load_qt->load(filename, requestedSize, origSize);

    if(load_qt->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with qt" << NL;
        err += QString("<b>Qt</b><br>%1<br><br>").arg(load_qt->errormsg);
    }

}

void PQLoadImage::loadWithLibRaw(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with libraw" << NL;

    img = load_raw->load(filename, requestedSize, origSize);

    if(load_raw->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with libraw" << NL;
        err += QString("<b>LibRaw</b><br>%1<br><br>").arg(load_raw->errormsg);
    }

}

void PQLoadImage::loadWithPoppler(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with poppler" << NL;

    img = load_poppler->load(filename, requestedSize, origSize);

    if(load_poppler->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with poppler" << NL;
        err += QString("<b>Poppler</b><br>%1<br><br>").arg(load_poppler->errormsg);
    }

}

void PQLoadImage::loadWithLibArchive(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with archive" << NL;

    const QFileInfo info(filename);
    const QString suffix = info.suffix().toLower();

    if(PQSettings::get()["filetypesExternalUnrar"].toBool() && (suffix == "rar" || suffix == "cbr")) {
        if(foundExternalUnrar == -1) {
            QProcess which;
            which.setStandardOutputFile(QProcess::nullDevice());
            which.start("which", QStringList() << "unrar");
            which.waitForFinished();
            foundExternalUnrar = which.exitCode() ? 0 : 1;
        }
        if(foundExternalUnrar == 1) {
            img = load_unrar->load(filename, requestedSize, origSize);
            if(load_unrar->errormsg != "") {
                LOG << CURDATE << "PQLoadImage::load(): failed to load image with unrar" << NL;
                err += QString("<b>unrar</b><br>%1<br><br>").arg(load_unrar->errormsg);
            }
            if(!img.isNull()) return;
        }
    }

    img = load_archive->load(filename, requestedSize, origSize);
    if(load_archive->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with libarchive" << NL;
        err += QString("<b>libarchive</b><br>%1<br><br>").arg(load_archive->errormsg);
    }

}

void PQLoadImage::loadWithXCFTools(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with xcftools" << NL;

    img = load_xcf->load(filename, requestedSize, origSize);

    if(load_xcf->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with xcftools" << NL;
        err += QString("<b>XCFTools</b><br>%1<br><br>").arg(load_xcf->errormsg);
    }

}

void PQLoadImage::loadWithMagick(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

#ifdef IMAGEMAGICK
    DBG << CURDATE << "attempt to load image with imagemagick" << NL;
#elif defined(GRAPHICSMAGICK)
    DBG << CURDATE << "attempt to load image with graphicsmagick" << NL;
#endif

    img = load_magick->load(filename, requestedSize, origSize);

    if(load_magick->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with magick" << NL;
        err += QString("<div style='font-weight: bold'>Magick</div>%1<br><br>").arg(load_magick->errormsg);
    }

}

void PQLoadImage::loadWithFreeImage(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with freeimage" << NL;

    img = load_freeimage->load(filename, requestedSize, origSize);

    if(load_freeimage->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with freeimage" << NL;
        err += QString("<b>FreeImage</b><br>%1<br><br>").arg(load_freeimage->errormsg);
    }

}

void PQLoadImage::loadWithDevIL(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with devil" << NL;

    img = load_devil->load(filename, requestedSize, origSize);

    if(load_devil->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with devil" << NL;
        err += QString("<b>DevIL</b><br>%1<br><br>").arg(load_devil->errormsg);
    }

}

void PQLoadImage::loadWithVideo(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err) {

    DBG << CURDATE << "attempt to load image with video" << NL;

    img = load_video->load(filename, requestedSize, origSize);

    if(load_video->errormsg != "") {
        LOG << CURDATE << "PQLoadImage::load(): failed to load image with video" << NL;
        err += QString("<b>Video</b><br>%1<br><br>").arg(load_video->errormsg);
    }

}
