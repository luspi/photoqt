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
#include "loader/loadimage_libvips.h"
#include "loader/helper.h"

class PQLoadImage {

public:
    PQLoadImage();
    ~PQLoadImage();

    QString load(QString filename, QSize requestedSize, QSize *origSize, QImage &img);

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
    PQLoadImageLibVips *load_libvips;
    QMimeDatabase db;

    void loadWithQt(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithLibRaw(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithPoppler(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithLibArchive(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithXCFTools(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithMagick(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithFreeImage(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithDevIL(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithVideo(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);
    void loadWithLibVips(QString filename, QSize requestedSize, QSize *origSize, QImage &img, QString &err);

};

#endif // PQLOADIMAGE_H
