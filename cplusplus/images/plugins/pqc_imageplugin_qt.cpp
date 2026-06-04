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

#include <imageplugins/pqc_imageplugin_qt.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>
#include <QImageIOHandler>
#include <QImageReader>
#include <QImageWriter>
#include <QSvgRenderer>
#include <QPainter>

PQCImagePluginQt::PQCImagePluginQt() {

    setData({{"Animated Windows cursors",
                    {{"ani"}, {"application/x-navi-animation"}}},
             {"AVIF: AV1 Image File Format",
                    {{"avif", "avifs"}, {"image/avif", "image/avif-sequence"}}},
             {"BMP: Microsoft Windows bitmap",
                    {{"bmp", "dib"}, {"image/bmp", "image/x-ms-bmp"}}},
             {"Cine File Format",
                    {{"cine"}, {}}},
             {"CUR: Microsoft Windows cursor format",
                    {{"cur"}, {"image/x-win-bitmap"}}},
             {"DirectDraw Surface",
                    {{"dds"}, {}}},
             {"OpenEXR",
                    {{"exr"}, {"image/x-exr"}}},
             {"GIF: Graphics Interchange Format",
                    {{"gif"}, {"image/gif"}}},
             {"HEIF: High Efficiency Image Format",
                    {{"heif", "heic"}, {"image/heif", "image/heic"}}},
             {"Microsoft Windows icon format",
                    {{"ico"}, {"image/vnd.microsoft.icon", "image/x-icon"}}},
             {"JPEG File Interchange Format",
                    {{"jfif"}, {}}},
             {"JPEG: Joint Photographic Experts Group JFIF format",
                    {{"jpeg", "jpg", "jpe", "jif"}, {"image/jpeg"}}},
             {"JPEG-2000",
                    {{"jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpf", "j2c"}, {"image/jp2", "image/jpx", "image/jpm"}}},
             {"JPEG XL",
                    {{"jxl"}, {"image/jxl"}}},
             {"JPEG-XR",
                    {{"jxr", "hdp", "wdp"}, {}}},
             {"Krita Document",
                    {{"kra"}, {"application/x-krita"}}},
             {"MNG: Multiple-image Network Graphics",
                    {{"mng"}, {"video/x-mng"}}},
             {"OBM file",
                    {{"obm"}, {}}},
             {"OpenRaster",
                    {{"ora"}, {"image/openraster"}}},
             {"PBM: Portable bitmap format (black and white)",
                    {{"pbm"}, {"image/x-portable-anymap"}}},
             {"PCX: ZSoft PiCture eXchange",
                    {{"pcx"}, {"image/vnd.zbrush.pcx", "image/x-pcx"}}},
             {"Adobe PhotoDeluxe",
                    {{"pdd"}, {}}},
             {"Portable Float Map",
                    {{"pfm"}, {}}},
             {"PGM: Portable graymap format (gray scale)",
                    {{"pgm"}, {"image/x-portable-greymap", "image/x-portable-anymap"}}},
             {"Portable float map format 16-bit half",
                    {{"phm"}, {}}},
             {"Softimage PIC",
                    {{"pic"}, {}}},
             {"PNG: Portable Network Graphics",
                    {{"png"}, {"image/png"}}},
             {"PPM: Portable pixmap format (color)",
                    {{"ppm", "pnm"}, {"image/x-portable-pixmap", "image/x-portable-anymap"}}},
             {"Adobe PhotoShop",
                    {{"psd", "psb", "psdt"}, {"image/vnd.adobe.photoshop"}}},
             {"PIXAR format",
                    {{"PIXAR format"}, {}}},
             {"Quite OK image format",
                    {{"qoi"}, {}}},
             {"Apple QuickTake Picture",
                    {{"qtk"}, {}}},
             {"RED R3D file format",
                    {{"r3d"}, {}}},
             {"SGI images",
                    {{"rgba", "rgb", "sgi", "bw"}, {"image/sgi"}}},
             {"HDR: Radiance RGBE image format",
                    {{"rgbe", "hdr", "rad"}, {}}},
             {"Scitex Continuous Tone Picture",
                    {{"sct", "ch", "ct"}, {}}},
             {"SUN Rasterfile",
                    {{"sun", "ras", "sr", "im1", "im24", "im32", "im8", "rast", "rs", "scr"}, {}}},
             {"SVG: Scalable Vector Graphics",
                    {{"svg", "svgz"}, {"image/svg+xml"}}},
             {"TGA: Truevision Targa image",
                    {{"tga", "icb", "vda", "vst"}, {"image/x-targa", "image/x-tga"}}},
             {"TIFF: Tagged Image File Format",
                    {{"tiff", "tif"}, {"image/tiff", "image/tiff-fx"}}},
             {"Wireless Bitmap",
                    {{"wbmp"}, {"image/vnd.wap.wbmp"}}},
             {"WEBP: Google web image format",
                    {{"webp"}, {"image/webp"}}},
             {"X BitMap",
                    {{"xbm", "bm"}, {"image/x-xbitmap", "image/x-xbm"}}},
             {"Gimp XCF",
                    {{"xcf"}, {"image/x-xcf"}}},
             {"X PixMap",
                    {{"xpm", "pm"}, {"image/x-xpixmap", "image/x-xpmi"}}}},
            "qt",
            {"jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpf", "j2c"}, {"image/jp2", "image/jpx", "image/jpm"});

    QSet<QString> writableFormats;
    QImageWriter writer;
    const QString tmpPath = QDir::tempPath();
    for(const QString &format : getEnabledFormats()) {
        const QSet<QString> allsuf = getSuffixesForFormat(format);
        writer.setFileName(tmpPath % "/temp." % *allsuf.begin());
        if(writer.canWrite()) {
            writableFormats.insert(format);
        }
    }
    setWritableFormats(writableFormats);

}

const QSize PQCImagePluginQt::loadSize(QString path) {

    // Suffix, for easier access later-on
    QString suffix = QFileInfo(path).suffix().toLower();

    if(suffix == "svg") {

        // For reading SVG files
        QSvgRenderer svg;

        // Loading SVG file
        svg.load(path);

        // Invalid vector graphic
        if(!svg.isValid()) {
            qWarning() << "Error: invalid svg file";
            return QSize();
        }

        // Store the width/height for later use
        return svg.defaultSize();

    } else {

        // For all other supported file types
        QImageReader reader;

        // Setting QImageReader
        reader.setFileName(path);
        reader.setAutoTransform(PQCSettingsCPP::get().getMetadataAutoRotation());

        bool imgAlreadyLoaded = false;

        // Store the width/height for later use
        QSize origSize = reader.size();
        // check if we need to read the image in full to get the original size
        if(origSize.width() == -1 || origSize.height() == -1) {
            QImage img;
            reader.read(&img);
            return img.size();
        }

        // the reported size is not rotated automatically, we need to take care of this ourselves
        if(PQCSettingsCPP::get().getMetadataAutoRotation()) {
            QImageIOHandler::Transformations trans = reader.transformation();
            switch(trans) {
            case QImageIOHandler::TransformationRotate90:
            case QImageIOHandler::TransformationRotate270:
            case QImageIOHandler::TransformationFlipAndRotate90:
            case QImageIOHandler::TransformationMirrorAndRotate90: {
                origSize = QSize(origSize.height(), origSize.width());
                break;
            }
            default:
                break;
            }
        }

        return origSize;

    }

}

const QImage PQCImagePluginQt::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

    // Suffix, for easier access later-on
    QString suffix = QFileInfo(path).suffix().toLower();

    QImage img;

    if(suffix == "svg" || suffix == "svgz") {

        // For reading SVG files
        QSvgRenderer svg;

        // Loading SVG file
        svg.load(path);

        // Invalid vector graphic
        if(!svg.isValid()) {
            const QString msg = "Error: invalid svg file";
            error += msg % "\n";
            qWarning() << msg;
            return QImage();
        }

        // Store the width/height for later use
        origSize = svg.defaultSize();
        // some svg's might not have a default size
        // in that case we fall back to the a default size
        if(!origSize.isValid())
            origSize = QSize(512,512);

        // Render SVG into pixmap
        if(!requestedSize.isEmpty())
            img = QImage(origSize.scaled(requestedSize, Qt::KeepAspectRatio), QImage::Format_ARGB32);
        else
            img = QImage(origSize, QImage::Format_ARGB32_Premultiplied);
        img.fill(::Qt::transparent);
        QPainter painter(&img);
        painter.setRenderHint(QPainter::Antialiasing);
        painter.setRenderHint(QPainter::SmoothPixmapTransform);
        painter.setRenderHint(QPainter::TextAntialiasing);
        svg.render(&painter);

        return img;

    } else {

        // For all other supported file types
        QImageReader reader;

        reader.setAllocationLimit(0);

        // Setting QImageReader
        reader.setFileName(path);

        reader.setAutoTransform(PQCSettingsCPP::get().getMetadataAutoRotation());

        bool imgAlreadyLoaded = false;

        bool colorProfileAlreadyApplied = false;

        // Store the width/height for later use
        origSize = reader.size();
        // check if we need to read the image in full to get the original size
        if(!origSize.isValid()) {
            reader.read(&img);
            imgAlreadyLoaded = true;
            origSize = img.size();
            if(!img.isNull()) {
                colorProfileAlreadyApplied = true;
                PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().applyColorProfile(path, img), img);
            }
        }

        // If QImageReader cannot read the image does not mean all hope is lost
        if(!reader.canRead()) {

            qDebug() << "unable to read image with reader, trying direct QImage";

            // It is possible that QImage can load an image directly even if QImageReader cannot
            img.load(path);
            imgAlreadyLoaded = true;
            origSize = img.size();

            if(img.isNull()) {
                const QString msg = "image reader and QImage unable to read image";
                error += msg % "\n";
                qWarning() << msg;
                return QImage();
            } else {
                error = "";
                colorProfileAlreadyApplied = true;
                PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().applyColorProfile(path, img), img);
            }
        }

        bool imageIsScaled = false;

        // check if we need to scale the image
        if(!requestedSize.isEmpty() && !origSize.isEmpty()) {

            imageIsScaled = true;

            // scaling
            if(imgAlreadyLoaded) {
                img = img.scaled(requestedSize,
                                 Qt::KeepAspectRatio,
                                 (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
            } else
                reader.setScaledSize(origSize.scaled(requestedSize, Qt::KeepAspectRatio));

        }

        if(!imgAlreadyLoaded && reader.canRead() && suffix != "jxl") {
            reader.read(&img);
            if(!img.isNull() && !imageIsScaled) {
                colorProfileAlreadyApplied = true;
                PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().applyColorProfile(path, img), img);
            }
        }

        // If an error occurred
        if(img.isNull()) {
            const QString msg = reader.errorString();
            error += msg % "\n";
            qWarning() << msg;
            return QImage();
        }

        if(!colorProfileAlreadyApplied)
            PQCScriptsColorProfiles::get().applyColorProfile(path, img);

        return img;

    }

}

const bool PQCImagePluginQt::writeImage(QImage img, QString targetPath) {

    QImageWriter writer(targetPath);

    if(!writer.canWrite())
        return false;

    return writer.write(img);

}
