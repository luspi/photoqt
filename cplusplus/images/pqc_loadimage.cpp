/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#include <pqc_loadimage_video.h>
#include <pqc_loadimage_libsai.h>

#include <pqc_loadimage.h>
#include <pqc_settingscpp.h>
#include <pqc_imageformats.h>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptscolorprofiles.h>

#include <QSize>
#include <QImage>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QtDebug>

PQCLoadImage::PQCLoadImage() {}
PQCLoadImage::~PQCLoadImage() {}

QSize PQCLoadImage::load(QString filename) {

    if(filename.trimmed().isEmpty())
        return QSize();

    QFileInfo info(filename);

    if(info.isSymLink() && info.exists())
        filename = info.symLinkTarget();

    // check image cache, we might be done right here
    QImage img;
    if(PQCImageCache::get().getCachedImage(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), img))
        return img.size();

    // for easier access below
    QString suffix1 = info.suffix().toLower();
    QString suffix2 = info.completeSuffix().toLower();

    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // first we check for filename suffix matches

    // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
    if(PQCImageFormats::get().getEnabledFormatsResvgSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsResvgSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageResvg::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

#ifdef PQMPOPPLER
    if(PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix2)) {
        const QSize sze = PQCLoadImagePoppler::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

#ifdef PQMQTPDF
    if(PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageQtPDF::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

    if(PQCImageFormats::get().getEnabledFormatsQtSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsQtSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageQt::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }

#ifdef PQMRAW
    if(PQCImageFormats::get().getEnabledFormatsLibRawSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibRawSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageRAW::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

#ifdef PQMLIBARCHIVE
    if(PQCImageFormats::get().getEnabledFormatsLibArchiveSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibArchiveSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageArchive::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

#ifdef PQMLIBSAI
    if(PQCImageFormats::get().getEnabledFormatsLibsaiSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibsaiSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageLibsai::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

    if(PQCImageFormats::get().getEnabledFormatsXCFToolsSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsXCFToolsSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageXCF::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    if(PQCImageFormats::get().getEnabledFormatsMagickSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsMagickSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageMagick::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

#ifdef PQMLIBVIPS
    if(PQCImageFormats::get().getEnabledFormatsLibVipsSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibVipsSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageLibVips::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

#ifdef PQMDEVIL
    if(PQCImageFormats::get().getEnabledFormatsDevILSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsDevILSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageDevil::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }
#endif

    if(PQCImageFormats::get().getEnabledFormatsVideoSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibmpvSet().contains(suffix1) ||
       PQCImageFormats::get().getEnabledFormatsVideoSet().contains(suffix2) || PQCImageFormats::get().getEnabledFormatsLibmpvSet().contains(suffix2)) {
        const QSize sze = PQCLoadImageVideo::loadSize(filename);
        if(!sze.isEmpty()) return sze;
    }


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // if we got here then the above checks  failed and we check for mimetype matches

    QMimeDatabase db;
    QString mimetype = db.mimeTypeForFile(filename).name();

    if(!mimetype.isEmpty() && mimetype != "application/octet-stream") {

        // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
        if(PQCImageFormats::get().getEnabledMimeTypesResvgSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageResvg::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

#ifdef PQMPOPPLER
        if(PQCImageFormats::get().getEnabledMimeTypesPopplerSet().contains(mimetype)) {
            const QSize sze = PQCLoadImagePoppler::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

#ifdef PQMQTPDF
        if(PQCImageFormats::get().getEnabledMimeTypesPopplerSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageQtPDF::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

        if(PQCImageFormats::get().getEnabledMimeTypesQtSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageQt::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }

#ifdef PQMRAW
        if(PQCImageFormats::get().getEnabledMimeTypesLibRawSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageRAW::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

#ifdef PQMLIBARCHIVE
        if(PQCImageFormats::get().getEnabledMimeTypesLibArchiveSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageArchive::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

#ifdef PQMLIBSAI
        if(PQCImageFormats::get().getEnabledMimeTypesLibsaiSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageLibsai::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

        if(PQCImageFormats::get().getEnabledMimeTypesXCFToolsSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageXCF::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
        if(PQCImageFormats::get().getEnabledMimeTypesMagickSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageMagick::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

#ifdef PQMLIBVIPS
        if(PQCImageFormats::get().getEnabledMimeTypesLibVipsSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageLibVips::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

#ifdef PQMDEVIL
        if(PQCImageFormats::get().getEnabledMimeTypesDevILSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageDevil::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }
#endif

        if(PQCImageFormats::get().getEnabledMimeTypesVideoSet().contains(mimetype) || PQCImageFormats::get().getEnabledMimeTypesLibmpvSet().contains(mimetype)) {
            const QSize sze = PQCLoadImageVideo::loadSize(filename);
            if(!sze.isEmpty()) return sze;
        }

    }

#if defined(PQMGRAPHICSMAGICK) || defined(PQMIMAGEMAGICK)
    // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
    return PQCLoadImageMagick::loadSize(filename);
#endif

    return QSize(0,0);

}

QString PQCLoadImage::load(QString filename, QSize requestedSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: requestedSize =" << requestedSize;
    qDebug() << "args: origSize =" << origSize;
    qDebug() << "args: img";

    if(filename.trimmed().isEmpty())
        return "";

    QFileInfo info(filename);

    if(info.isSymLink() && info.exists())
        filename = info.symLinkTarget();

    // check image cache, we might be done right here
    if(PQCImageCache::get().getCachedImage(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), img)) {
        origSize = img.size();
        if(requestedSize.width() > 2 && requestedSize.height() > 2 && origSize.width() > requestedSize.width() && origSize.height() > requestedSize.height())
            img = img.scaled(requestedSize,
                             Qt::KeepAspectRatio,
                             (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
        return "";
    }

    QStringList err;

    // for easier access below
    QString suffix1 = info.suffix().toLower();
    QString suffix2 = info.completeSuffix().toLower();

    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // first we check for filename suffix matches

    // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
    if(PQCImageFormats::get().getEnabledFormatsResvgSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsResvgSet().contains(suffix2)) {
        err.append(PQCLoadImageResvg::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

#ifdef PQMPOPPLER
    if(PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix2)) {
        err.append(PQCLoadImagePoppler::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

#ifdef PQMQTPDF
    if(PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsPopplerSet().contains(suffix2)) {
        err.append(PQCLoadImageQtPDF::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

    if(PQCImageFormats::get().getEnabledFormatsQtSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsQtSet().contains(suffix2)) {
        err.append(PQCLoadImageQt::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }

#ifdef PQMRAW
    if(PQCImageFormats::get().getEnabledFormatsLibRawSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibRawSet().contains(suffix2)) {
        err.append(PQCLoadImageRAW::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

#ifdef PQMLIBARCHIVE
    if(PQCImageFormats::get().getEnabledFormatsLibArchiveSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibArchiveSet().contains(suffix2)) {
        err.append(PQCLoadImageArchive::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

#ifdef PQMLIBSAI
    if(PQCImageFormats::get().getEnabledFormatsLibsaiSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibsaiSet().contains(suffix2)) {
        err.append(PQCLoadImageLibsai::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

    if(PQCImageFormats::get().getEnabledFormatsXCFToolsSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsXCFToolsSet().contains(suffix2)) {
        err.append(PQCLoadImageXCF::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    if(PQCImageFormats::get().getEnabledFormatsMagickSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsMagickSet().contains(suffix2)) {
        err.append(PQCLoadImageMagick::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

#ifdef PQMLIBVIPS
    if(PQCImageFormats::get().getEnabledFormatsLibVipsSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibVipsSet().contains(suffix2)) {
        err.append(PQCLoadImageLibVips::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

#ifdef PQMDEVIL
    if(PQCImageFormats::get().getEnabledFormatsDevILSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsDevILSet().contains(suffix2)) {
        err.append(PQCLoadImageDevil::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }
#endif

    if((PQCImageFormats::get().getEnabledFormatsVideoSet().contains(suffix1) || PQCImageFormats::get().getEnabledFormatsLibmpvSet().contains(suffix1) ||
        PQCImageFormats::get().getEnabledFormatsVideoSet().contains(suffix2) || PQCImageFormats::get().getEnabledFormatsLibmpvSet().contains(suffix2))) {
        err.append(PQCLoadImageVideo::load(filename, requestedSize, origSize, img));
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }
    }


    //////////////////////////////////////////////
    //////////////////////////////////////////////
    // if we got here then the above failed and we check for mimetype matches

    QMimeDatabase db;
    QString mimetype = db.mimeTypeForFile(filename).name();

    if(!mimetype.isEmpty() && mimetype != "application/octet-stream") {

        // resvg trumps Qt's SVG engine
#ifdef PQMRESVG
        if(PQCImageFormats::get().getEnabledMimeTypesResvgSet().contains(mimetype)) {
            err.append(PQCLoadImageResvg::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

#ifdef PQMPOPPLER
        if(PQCImageFormats::get().getEnabledMimeTypesPopplerSet().contains(mimetype)) {
            err.append(PQCLoadImagePoppler::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

#ifdef PQMQTPDF
        if(PQCImageFormats::get().getEnabledMimeTypesPopplerSet().contains(mimetype)) {
            err.append(PQCLoadImageQtPDF::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

        if(PQCImageFormats::get().getEnabledMimeTypesQtSet().contains(mimetype)) {
            err.append(PQCLoadImageQt::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }

#ifdef PQMRAW
        if(PQCImageFormats::get().getEnabledMimeTypesLibRawSet().contains(mimetype)) {
            err.append(PQCLoadImageRAW::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

#ifdef PQMLIBARCHIVE
        if(PQCImageFormats::get().getEnabledMimeTypesLibArchiveSet().contains(mimetype)) {
            err.append(PQCLoadImageArchive::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

#ifdef PQMLIBSAI
        if(PQCImageFormats::get().getEnabledMimeTypesLibsaiSet().contains(mimetype)) {
            err.append(PQCLoadImageLibsai::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

        if(PQCImageFormats::get().getEnabledMimeTypesXCFToolsSet().contains(mimetype)) {
            err.append(PQCLoadImageXCF::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
        if(PQCImageFormats::get().getEnabledMimeTypesMagickSet().contains(mimetype)) {
            err.append(PQCLoadImageMagick::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

#ifdef PQMLIBVIPS
        if(PQCImageFormats::get().getEnabledMimeTypesLibVipsSet().contains(mimetype)) {
            err.append(PQCLoadImageLibVips::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

#ifdef PQMDEVIL
        if(PQCImageFormats::get().getEnabledMimeTypesDevILSet().contains(mimetype)) {
            err.append(PQCLoadImageDevil::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }
#endif

        if(PQCImageFormats::get().getEnabledMimeTypesVideoSet().contains(mimetype) || PQCImageFormats::get().getEnabledMimeTypesLibmpvSet().contains(mimetype)) {
            err.append(PQCLoadImageVideo::load(filename, requestedSize, origSize, img));
            if(!img.isNull()) {
                PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
                return "";
            }
        }

    }


#if defined(PQMGRAPHICSMAGICK) || defined(PQMIMAGEMAGICK)
    // if everything failed, we make sure to try one more time with ImageMagick or GraphicsMagick to see what could be done
    // we do not do this for video files as it can lead to resource intensive ffmpeg processes that may persist after PhotoQt is closed
    if(!PQCImageFormats::get().getEnabledFormatsVideoSet().contains(suffix1) && !PQCImageFormats::get().getEnabledFormatsLibmpvSet().contains(suffix1) &&
       !PQCImageFormats::get().getEnabledFormatsVideoSet().contains(suffix2) && !PQCImageFormats::get().getEnabledFormatsLibmpvSet().contains(suffix2)) {

        qDebug() << "null image, try magick";

        // we do not override the old error message
        PQCLoadImageMagick::load(filename, requestedSize, origSize, img);
        if(!img.isNull()) {
            PQCScriptsImages::get().setSupportsTransparency(filename, img.hasAlphaChannel());
            return "";
        }

    }
#endif

    return err.join("\n");

}
