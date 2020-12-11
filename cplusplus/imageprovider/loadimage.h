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

        if(filename.trimmed() == "")
            return "";

        QFileInfo info(filename);

        // check image cache, we might be done right here
        QImage *cachedImg = load_helper->getCachedImage(filename);
        if(!cachedImg->isNull()) {
            load_helper->ensureImageFitsMaxSize(cachedImg, requestedSize);
            img = *cachedImg;
            return "";
        }

        QString ret_err = "";

        if(info.suffix().toLower() == "svg" || info.suffix().toLower() == "svgz" ||
            PQImageFormats::get().getEnabledFileformatsQt().contains("*." + info.suffix().toLower())) {
            img = load_qt->load(filename, requestedSize, origSize);
            ret_err = load_qt->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsXCF().contains("*." + info.suffix().toLower())) {
            img = load_xcf->load(filename, requestedSize, origSize);
            ret_err = load_xcf->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsPoppler().contains("*." + info.suffix().toLower())) {
            img = load_poppler->load(filename, requestedSize, origSize);
            ret_err = load_poppler->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsGraphicsMagick().contains("*." + info.suffix().toLower())) {
            img = load_graphicsmagick->load(filename, requestedSize, origSize);
            ret_err = load_graphicsmagick->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsRAW().contains("*." + info.suffix().toLower())) {
            img = load_raw->load(filename, requestedSize, origSize);
            ret_err = load_raw->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsDevIL().contains("*." + info.suffix().toLower())) {
            img = load_devil->load(filename, requestedSize, origSize);
            ret_err = load_devil->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsFreeImage().contains("*." + info.suffix().toLower())) {
            img = load_freeimage->load(filename, requestedSize, origSize);
            ret_err = load_freeimage->errormsg;
        } else if(PQImageFormats::get().getEnabledFileformatsArchive().contains("*." + info.suffix().toLower())) {

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
                img = load_unrar->load(filename, requestedSize, origSize);
                ret_err = load_unrar->errormsg;
            }

        } else if(PQImageFormats::get().getEnabledFileformatsVideo().contains("*." + info.suffix().toLower())) {

            img = load_video->load(filename, requestedSize, origSize);
            ret_err = load_video->errormsg;

        } else {
            img = load_qt->load(filename, requestedSize, origSize);
            ret_err = load_qt->errormsg;
        }

        // cache image (if not scaled)
        if(ret_err == "" && img.width() == origSize->width() && img.height() == origSize->height())
            load_helper->saveImageToCache(filename, &img);

        return ret_err;

    }

private:
    int foundExternalUnrar;
    PQLoadImageHelper *load_helper;
    PQLoadImageErrorImage *load_err;
    PQLoadImageQt *load_qt;
    PQLoadImageGraphicsMagick *load_graphicsmagick;
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
