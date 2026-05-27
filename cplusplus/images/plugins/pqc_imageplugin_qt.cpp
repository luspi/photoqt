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

#include <pqc_imageplugin_qt.h>
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

PQCImagePluginQt::PQCImagePluginQt(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginQt::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const QSet<QString> PQCImagePluginQt::getSuffixesForFormatByDescription(QString description) {
    QSet<QString> ret;
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            ret.insert(suf);
    }
    return ret;
}

const bool PQCImagePluginQt::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const bool PQCImagePluginQt::isEnabled(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return m_suffixes.contains(suf);
    }
    return false;
}

const QSet<QString> PQCImagePluginQt::getWritableSuffixes() {

    if(m_composedWritableSuffixes) return m_writableSuffixes;

    m_composedWritableSuffixes = true;

    QImageWriter writer;
    const QString tmpPath = QDir::tempPath();
    for(const QString &suf : std::as_const(m_allSuffixes)) {
        writer.setFileName(tmpPath % "/temp." % suf);
        if(writer.canWrite())
            m_writableSuffixes.insert(suf);
    }

    return m_writableSuffixes;

}

const bool PQCImagePluginQt::writeImage(QImage img, QString targetPath) {

    QImageWriter writer(targetPath);

    if(!writer.canWrite())
        return false;

    return writer.write(img);

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
                PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
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
                PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
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
                PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
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

void PQCImagePluginQt::setEnabled(QString description, bool enabled) {

    // first find all the suffixes and mimetypes for this format description
    QSet<QString> suffixes, mimetypes;
    for(const auto &[key, value] : std::as_const(suffix2description).asKeyValueRange()) {
        if(value == description)
            suffixes.insert(key);
    }
    for(const auto &[key, value] : std::as_const(mimetype2description).asKeyValueRange()) {
        if(value == description)
            mimetypes.insert(key);
    }

    // then find the ones stored as toggled
    QSet<QString> storedSuffixes, storedMimetypes;

    const QString suffixFilename = m_settingsDir % "/qt_suffixes";
    QFile suffixFile(suffixFilename);
    if(suffixFile.exists()) {
        if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
            qWarning() << "Failed to open settings file at:" << suffixFilename;
            return;
        } else {
            QTextStream suffixIn(&suffixFile);
            const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
            storedSuffixes = QSet<QString>(tmp.begin(), tmp.end());
            suffixFile.close();
        }
    }

    const QString mimeFilename = m_settingsDir % "/qt_mimetypes";
    QFile mimeFile(mimeFilename);
    if(mimeFile.exists()) {
        if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
            qWarning() << "Failed to open settings file at:" << mimeFilename;
            return;
        } else {
            QTextStream mimeIn(&mimeFile);
            const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
            storedMimetypes = QSet<QString>(tmp.begin(), tmp.end());
            mimeFile.close();
        }
    }

    // if we toggle this format then we only need to make sure they are added to the list, nothing else
    if((enabledByDefault() && !enabled) || (!enabledByDefault() && enabled)) {

        storedSuffixes += suffixes;
        storedMimetypes += mimetypes;

        // otherwise we need to make sure that no suffix is part of the list
    } else {

        QSet<QString> newsetSuffixes, newsetMime;

        for(const QString &s : std::as_const(storedSuffixes)) {
            if(!suffixes.contains(s))
                newsetSuffixes.insert(s);
        }
        for(const QString &m : std::as_const(storedMimetypes)) {
            if(!mimetypes.contains(m))
                newsetMime.insert(m);
        }

        storedSuffixes = newsetSuffixes;
        storedMimetypes = newsetMime;

    }

    QFile outSuffixFile(suffixFilename);
    if(!outSuffixFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
    } else {
        QTextStream suffixOut(&outSuffixFile);
        suffixOut << PQCHelper::setJoin(storedSuffixes, "\n");
        outSuffixFile.close();
    }

    QFile outMimeFile(mimeFilename);
    if(!outMimeFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
    } else {
        QTextStream mimeOut(&outMimeFile);
        mimeOut << PQCHelper::setJoin(storedMimetypes, "\n");
        outMimeFile.close();
    }

}

/***********************************************/

void PQCImagePluginQt::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/qt_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << suffixFilename;

        // these are the ones DISABLED BY DEFAULT
        m_toggledSuffixes << "eps" << "epsf" << "epsi" << "pdf";

    } else {

        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();

    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"ani", "avif", "avifs", "bmp", "dib", "cine", "cur", "dds", "eps", "epsf", "epsi", "exr",
                     "gif", "heif", "heic", "ico", "jfif", "jpeg", "jpg", "jpe", "jif", "jpeg2000", "j2k", "jp2",
                     "jpc", "jpx", "jpf", "j2c", "jxl", "jxr", "hdp", "wdp", "kra", "mng", "obm", "ora", "pbm",
                     "pcx", "pdd", "pdf", "pfm", "pgm", "phm", "pic", "png", "ppm", "pnm", "psd", "psb", "psdt",
                     "qtk", "r3d", "rgba", "rgb", "sgi", "bw", "rgbe", "hdr", "rad", "sct", "ch", "ct", "sun",
                     "ras", "sr", "im1", "im24", "im32", "im8", "rast", "rs", "scr", "svg", "svgz", "tga", "icb",
                     "vda", "vst", "tiff", "tif", "wbmp", "webp", "xbm", "bm", "xcf", "xpm", "pm", "pxr", "qoi",
                     "eps", "epsf", "epsi", "pdf"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"ani", "Animated Windows cursors"},
        {"avif",  "AVIF: AV1 Image File Format"},
        {"avifs", "AVIF: AV1 Image File Format"},
        {"bmp", "BMP: Microsoft Windows bitmap"},
        {"dib", "BMP: Microsoft Windows bitmap"},
        {"cine", "Cine File Format"},
        {"cur", "CUR: Microsoft Windows cursor format"},
        {"dds", "DirectDraw Surface"},
        {"eps",  "EPS: Encapsulated PostScript"},
        {"epsf", "EPS: Encapsulated PostScript"},
        {"epsi", "EPS: Encapsulated PostScript"},
        {"exr", "OpenEXR"},
        {"gif", "GIF: Graphics Interchange Format"},
        {"heif", "HEIF: High Efficiency Image Format"},
        {"heic", "HEIF: High Efficiency Image Format"},
        {"ico", "Microsoft Windows icon format"},
        {"jfif", "JPEG File Interchange Format"},
        {"jpeg", "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpg",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpe",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jif",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpeg2000", "JPEG-2000"},
        {"j2k",      "JPEG-2000"},
        {"jp2",      "JPEG-2000"},
        {"jpc",      "JPEG-2000"},
        {"jpx",      "JPEG-2000"},
        {"jpf",      "JPEG-2000"},
        {"j2c",      "JPEG-2000"},
        {"jxl",      "JPEG XL"},
        {"jxr", "JPEG-XR"},
        {"hdp", "JPEG-XR"},
        {"wdp", "JPEG-XR"},
        {"kra", "Krita Document"},
        {"mng", "MNG: Multiple-image Network Graphics"},
        {"obm", "OBM file"},
        {"ora", "OpenRaster"},
        {"pbm", "PBM: Portable bitmap format (black and white)"},
        {"pcx", "PCX: ZSoft PiCture eXchange"},
        {"pdd", "Adobe PhotoDeluxe"},
        {"pdf", "PDF: Adobe Portable Document Format"},
        {"pfm", "Portable Float Map"},
        {"pgm", "PGM: Portable graymap format (gray scale)"},
        {"phm", "Portable float map format 16-bit half"},
        {"pic", "Softimage PIC"},
        {"png", "PNG: Portable Network Graphics"},
        {"ppm", "PPM: Portable pixmap format (color)"},
        {"pnm", "PPM: Portable pixmap format (color)"},
        {"psd",  "Adobe PhotoShop"},
        {"psb",  "Adobe PhotoShop"},
        {"psdt", "Adobe PhotoShop"},
        {"pxr", "PIXAR format"},
        {"qoi", "Quite OK image format"},
        {"qtk", "Apple QuickTake Picture"},
        {"r3d", "RED R3D file format"},
        {"rgba", "SGI images"},
        {"rgb",  "SGI images"},
        {"sgi",  "SGI images"},
        {"bw",   "SGI images"},
        {"rgbe", "HDR: Radiance RGBE image format"},
        {"hdr",  "HDR: Radiance RGBE image format"},
        {"rad",  "HDR: Radiance RGBE image format"},
        {"sct", "Scitex Continuous Tone Picture"},
        {"ch",  "Scitex Continuous Tone Picture"},
        {"ct",  "Scitex Continuous Tone Picture"},
        {"sun",  "SUN Rasterfile"},
        {"ras",  "SUN Rasterfile"},
        {"sr",   "SUN Rasterfile"},
        {"im1",  "SUN Rasterfile"},
        {"im24", "SUN Rasterfile"},
        {"im32", "SUN Rasterfile"},
        {"im8",  "SUN Rasterfile"},
        {"rast", "SUN Rasterfile"},
        {"rs",   "SUN Rasterfile"},
        {"scr",  "SUN Rasterfile"},
        {"svg",  "SVG: Scalable Vector Graphics"},
        {"svgz", "SVG: Scalable Vector Graphics"},
        {"tga", "TGA: Truevision Targa image"},
        {"icb", "TGA: Truevision Targa image"},
        {"vda", "TGA: Truevision Targa image"},
        {"vst", "TGA: Truevision Targa image"},
        {"tiff", "TIFF: Tagged Image File Format"},
        {"tif",  "TIFF: Tagged Image File Format"},
        {"wbmp", "Wireless Bitmap"},
        {"webp", "WEBP: Google web image format"},
        {"xbm", "X BitMap"},
        {"bm",  "X BitMap"},
        {"xcf", "Gimp XCF"},
        {"xpm", "X PixMap"},
        {"pm",  "X PixMap"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/qt_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
    } else {
        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();
    }

    // then we store ALL supported mimetypes
    m_allMimetypes = {"application/x-navi-animation", "image/avif", "image/avif-sequence", "image/bmp", "image/x-ms-bmp",
                      "image/x-win-bitmap", "application/postscript", "application/eps", "application/x-eps", "image/eps",
                      "image/x-eps", "image/x-exr", "image/gif", "image/heic", "image/heif", "image/vnd.microsoft.icon",
                      "image/x-icon", "image/jpeg", "image/jp2", "image/jpx", "image/jxl", "application/x-krita",
                      "video/x-mng", "image/openraster", "image/x-portable-anymap", "image/vnd.zbrush.pcx", "image/x-pcx",
                      "application/pdf", "application/x-pdf", "application/x-bzpdf", "application/x-gzpdf",
                      "image/x-portable-greymap", "image/x-portable-anymap", "image/png", "image/x-portable-pixmap",
                      "image/x-portable-anymap", "image/vnd.adobe.photoshop", "image/sgi", "image/svg+xml", "image/x-targa",
                      "image/x-tga", "image/tiff", "image/tiff-fx", "image/vnd.wap.wbmp", "image/webp", "image/x-xbitmap",
                      "image/x-xbm", "image/x-xcf", "image/x-xpixmap", "image/x-xpmi"};


    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    mimetype2description = {
        {"image/bmp", "BMP: Microsoft Windows bitmap"},
        {"image/x-ms-bmp", "BMP: Microsoft Windows bitmap"},
        {"image/x-win-bitmap", "CUR: Microsoft Windows cursor format"},
        {"application/postscript", "EPS: Encapsulated PostScript"},
        {"application/eps", "EPS: Encapsulated PostScript"},
        {"application/x-eps", "EPS: Encapsulated PostScript"},
        {"image/eps", "EPS: Encapsulated PostScript"},
        {"image/x-eps", "EPS: Encapsulated PostScript"},
        {"image/x-exr", "OpenEXR"},
        {"image/gif", "GIF: Graphics Interchange Format"},
        {"image/jp2", "JPEG-2000"},
        {"image/jpx", "JPEG-2000"},
        {"image/jpm", "JPEG-2000"},
        {"image/jpeg", "JPEG: Joint Photographic Experts Group JFIF format"},
        {"application/x-krita", "Krita Document"},
        {"video/x-mng", "MNG: Multiple-image Network Graphics"},
        {"image/openraster", "OpenRaster"},
        {"image/x-portable-anymap", "PBM: Portable bitmap format (black and white)"},
        {"image/vnd.zbrush.pcx", "PCX: ZSoft PiCture eXchange"},
        {"image/x-pcx", "PCX: ZSoft PiCture eXchange"},
        {"image/x-portable-greymap", "PGM: Portable graymap format (gray scale)"},
        {"image/x-portable-anymap", "PGM: Portable graymap format (gray scale)"},
        {"image/png", "PNG: Portable Network Graphics"},
        {"image/x-portable-pixmap", "PPM: Portable pixmap format (color)"},
        {"image/x-portable-anymap", "PPM: Portable pixmap format (color)"},
        {"image/vnd.adobe.photoshop", "Adobe PhotoShop"},
        {"image/sgi", "SGI images"},
        {"image/svg+xml", "SVG: Scalable Vector Graphics"},
        {"image/x-targa", "TGA: Truevision Targa image"},
        {"image/x-tga", "TGA: Truevision Targa image"},
        {"image/tiff", "TIFF: Tagged Image File Format"},
        {"image/tiff-fx", "TIFF: Tagged Image File Format"},
        {"image/vnd.wap.wbmp", "Wireless Bitmap"},
        {"image/x-xbitmap", "X BitMap"},
        {"image/x-xbm", "X BitMap"},
        {"image/x-xcf", "Gimp XCF"},
        {"image/webp", "WEBP: Google web image format"},
        {"image/heic", "HEIF: High Efficiency Image Format"},
        {"image/heif", "HEIF: High Efficiency Image Format"},
        {"image/vnd.microsoft.icon", "Microsoft Windows icon format"},
        {"image/x-icon", "Microsoft Windows icon format"},
        {"image/x-xpixmap", "X PixMap"},
        {"image/x-xpmi", "X PixMap"},
        {"image/avif", "AVIF: AV1 Image File Format"},
        {"image/avif-sequence", "AVIF: AV1 Image File Format"},
        {"application/pdf", "PDF: Adobe Portable Document Format"},
        {"application/x-pdf", "PDF: Adobe Portable Document Format"},
        {"application/x-bzpdf", "PDF: Adobe Portable Document Format"},
        {"application/x-gzpdf", "PDF: Adobe Portable Document Format"},
        {"image/jxl", "JPEG XL"},
        {"application/x-navi-animation", "Animated Windows cursors"}
    };

    Q_EMIT formatsUpdated();

}
