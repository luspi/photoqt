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

    setData({{53218,
                    {{"Animated Windows cursors"}, {"ani"}, {"application/x-navi-animation"}}},
             {66696,
                    {{"AVIF: AV1 Image File Format"}, {"avif", "avifs"}, {"image/avif", "image/avif-sequence"}}},
             {45621,
                    {{"BMP: Microsoft Windows bitmap"}, {"bmp", "dib"}, {"image/bmp", "image/x-ms-bmp"}}},
             {54432,
                    {{"Cine File Format"}, {"cine"}, {}}},
             {58156,
                    {{"CUR: Microsoft Windows cursor format"}, {"cur"}, {"image/x-win-bitmap"}}},
             {74447,
                    {{"DirectDraw Surface"}, {"dds"}, {}}},
             {74586,
                    {{"OpenEXR"}, {"exr"}, {"image/x-exr"}}},
             {52412,
                    {{"GIF: Graphics Interchange Format"}, {"gif"}, {"image/gif"}}},
             {22226,
                    {{"HEIF: High Efficiency Image Format"}, {"heif", "heic"}, {"image/heif", "image/heic"}}},
             {66646,
                    {{"Microsoft Windows icon format"}, {"ico"}, {"image/vnd.microsoft.icon", "image/x-icon"}}},
             {12454,
                    {{"JPEG File Interchange Format"}, {"jfif"}, {}}},
             {11485,
                    {{"JPEG: Joint Photographic Experts Group JFIF format"}, {"jpeg", "jpg", "jpe", "jif"}, {"image/jpeg"}}},
             {13245,
                    {{"JPEG-2000"}, {"jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpf", "j2c"}, {"image/jp2", "image/jpx", "image/jpm"}}},
             {34567,
                    {{"JPEG XL"}, {"jxl"}, {"image/jxl"}}},
             {44445,
                    {{"JPEG-XR"}, {"jxr", "hdp", "wdp"}, {}}},
             {97621,
                    {{"Krita Document"}, {"kra"}, {"application/x-krita"}}},
             {13695,
                    {{"MNG: Multiple-image Network Graphics"}, {"mng"}, {"video/x-mng"}}},
             {77332,
                    {{"OBM file"}, {"obm"}, {}}},
             {84523,
                    {{"OpenRaster"}, {"ora"}, {"image/openraster"}}},
             {16685,
                    {{"PBM: Portable bitmap format (black and white)"}, {"pbm"}, {"image/x-portable-anymap"}}},
             {25566,
                    {{"PCX: ZSoft PiCture eXchange"}, {"pcx"}, {"image/vnd.zbrush.pcx", "image/x-pcx"}}},
             {33344,
                    {{"Adobe PhotoDeluxe"}, {"pdd"}, {}}},
             {44444,
                    {{"Portable Float Map"}, {"pfm"}, {}}},
             {85444,
                    {{"PGM: Portable graymap format (gray scale)"}, {"pgm"}, {"image/x-portable-greymap", "image/x-portable-anymap"}}},
             {98765,
                    {{"Portable float map format 16-bit half"}, {"phm"}, {}}},
             {55585,
                    {{"Softimage PIC"}, {"pic"}, {}}},
             {46215,
                    {{"PNG: Portable Network Graphics"}, {"png"}, {"image/png"}}},
             {77521,
                    {{"PPM: Portable pixmap format (color)"}, {"ppm", "pnm"}, {"image/x-portable-pixmap", "image/x-portable-anymap"}}},
             {26486,
                    {{"Adobe PhotoShop"}, {"psd", "psb", "psdt"}, {"image/vnd.adobe.photoshop"}}},
             {11278,
                    {{"PIXAR format"}, {"PIXAR format"}, {}}},
             {31111,
                    {{"Quite OK image format"}, {"qoi"}, {}}},
             {99344,
                    {{"Apple QuickTake Picture"}, {"qtk"}, {}}},
             {22255,
                    {{"RED R3D file format"}, {"r3d"}, {}}},
             {33352,
                    {{"SGI images"}, {"rgba", "rgb", "sgi", "bw"}, {"image/sgi"}}},
             {11113,
                    {{"HDR: Radiance RGBE image format"}, {"rgbe", "hdr", "rad"}, {}}},
             {56223,
                    {{"Scitex Continuous Tone Picture"}, {"sct", "ch", "ct"}, {}}},
             {91919,
                    {{"SUN Rasterfile"}, {"sun", "ras", "sr", "im1", "im24", "im32", "im8", "rast", "rs", "scr"}, {}}},
             {26112,
                    {{"SVG: Scalable Vector Graphics"}, {"svg", "svgz"}, {"image/svg+xml"}}},
             {85621,
                    {{"TGA: Truevision Targa image"}, {"tga", "icb", "vda", "vst"}, {"image/x-targa", "image/x-tga"}}},
             {44462,
                    {{"TIFF: Tagged Image File Format"}, {"tiff", "tif"}, {"image/tiff", "image/tiff-fx"}}},
             {12788,
                    {{"Wireless Bitmap"}, {"wbmp"}, {"image/vnd.wap.wbmp"}}},
             {28282,
                    {{"WEBP: Google web image format"}, {"webp"}, {"image/webp"}}},
             {87775,
                    {{"X BitMap"}, {"xbm", "bm"}, {"image/x-xbitmap", "image/x-xbm"}}},
             {16443,
                    {{"Gimp XCF"}, {"xcf"}, {"image/x-xcf"}}},
             {44474,
                    {{"X PixMap"}, {"xpm", "pm"}, {"image/x-xpixmap", "image/x-xpmi"}}}},
            "qt",
            {13245});

    QSet<int> writableFormats;
    QImageWriter writer;
    const QString tmpPath = QDir::tempPath();
    for(const int &format : getEnabledFormats()) {
        const QStringList allsuf = getSuffixesForFormat(format);
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
                const QString prf = PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                PQCImageCache::get().saveImageToCache(path, prf, img);
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
                const QString prf = PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                PQCImageCache::get().saveImageToCache(path, prf, img);
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
                const QString prf = PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                PQCImageCache::get().saveImageToCache(path, prf, img);
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
