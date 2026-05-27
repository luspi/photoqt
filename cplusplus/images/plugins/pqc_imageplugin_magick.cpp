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

#include <pqc_imageplugin_magick.h>
#include <pqc_settingscpp.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif

PQCImagePluginMagick::PQCImagePluginMagick(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginMagick::getDescription(QString suffix) {
    return m_suffix2description.value(suffix.toLower(), "");
}

const QSet<QString> PQCImagePluginMagick::getSuffixesForFormatByDescription(QString description) {
    QSet<QString> ret;
    for(const auto &[suf, desc] : std::as_const(m_suffix2description).asKeyValueRange()) {
        if(desc == description)
            ret.insert(suf);
    }
    return ret;
}

const bool PQCImagePluginMagick::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(m_suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const bool PQCImagePluginMagick::isEnabled(QString description) {
    for(const auto &[suf, desc] : std::as_const(m_suffix2description).asKeyValueRange()) {
        if(desc == description)
            return m_suffixes.contains(suf);
    }
    return false;
}

const QSet<QString> PQCImagePluginMagick::getWritableSuffixes() {

    if(m_composedWritableSuffixes) return m_writableSuffixes;

    m_composedWritableSuffixes = true;

    for(const QString &suf : std::as_const(m_allSuffixes)) {

        const QString magick = m_suffix2magick.value(suf, suf.toUpper());

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
        try {
            Magick::CoderInfo magickCoderInfo(magick.toStdString());
            if(magickCoderInfo.isWritable())
                m_writableSuffixes.insert(suf);
        } catch(...) {
            // do nothing here
        }
#endif

    }

    return m_writableSuffixes;

}

const bool PQCImagePluginMagick::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginMagick::loadSize(QString path) {

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

    QString suf = QFileInfo(path).suffix().toUpper();
    Magick::Image image;

    QStringList mgs;
    if(!suf.isEmpty()) {
        mgs = QStringList() << suf.toUpper();
        const QString sufl = suf.toLower();
        if(m_suffix2magick.contains(sufl))
            mgs << m_suffix2magick.value(sufl).toUpper();
    }

    // if nothing else worked try without any magick, maybe this will help...
    mgs << "";

    int howOftenFailed = 0;
    for(int i = 0; i < mgs.length(); ++i) {

        try {

            // set current magick
            image.magick(mgs.at(i).toStdString());

            // Ping image to get meta information
            image.ping(path.toStdString());

            // done with the loop if we manage to get here.
            break;

        } catch(Magick::Exception &e) {

            ++howOftenFailed;
            qWarning() << e.what();

        }

    }

    return QSize(image.columns(), image.rows());

#endif

    return QSize();

}

const QImage PQCImagePluginMagick::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

    QSize finalSize;

    const QString suf = QFileInfo(path).suffix().toUpper();
    int howOftenFailed = 0;
    bool imageIsScaled = false;

    QImage img;

    try {

        // Prepare Magick
        Magick::Image image;

        QStringList mgs;
        if(!suf.isEmpty()) {
            mgs = QStringList() << suf.toUpper();
            const QString sufl = suf.toLower();
            if(m_suffix2magick.contains(sufl))
                mgs << m_suffix2magick.value(sufl).toUpper();
        }

        // if nothing else worked try without any magick, maybe this will help...
        mgs << "";

        for(int i = 0; i < mgs.length(); ++i) {

            // set current magick
            image.magick(mgs.at(i).toStdString());

            // Read image into Magick
            image.read(path.toStdString());

            // Don't apply any orientation automatically, we handle it ourselves below
            image.orientation(Magick::UndefinedOrientation);

            // done with the loop if we manage to get here.
            break;

        }

        // no attempt was successful -> stop here
        if(howOftenFailed == mgs.length()) {
            const QString msg = "Failed to read image";
            error += msg % "\n";
            qWarning() << msg;
            return QImage();
        }

        finalSize = QSize(image.columns(), image.rows());
        origSize = finalSize;

        // Scale image if necessary
        if(!requestedSize.isEmpty()) {

            imageIsScaled = true;

            finalSize = finalSize.scaled(requestedSize, Qt::KeepAspectRatio);

            // For small images we can use the faster algorithm, as the quality is good enough for that
            if(finalSize.width() < 300 && finalSize.height() < 300)
                image.thumbnail(Magick::Geometry(finalSize.width(),finalSize.height()));
            else
                image.resize(Magick::Geometry(finalSize.width(),finalSize.height()));

        }

        // force RGBA output
        image.magick("RGBA");

        // prepare image output
        img = QImage(image.columns(), image.rows(), QImage::Format_RGBA8888);

        // convert Magick Image to QImage
        image.write(0, 0, image.columns(), image.rows(),
                    "RGBA", Magick::CharPixel, img.bits());

    } catch(Magick::Exception &e) {

        ++howOftenFailed;
        qWarning() << e.what();
        error += QString(e.what()) % "\n";

    }

    // heif/heic images always will be loaded already transformed, even if we attempt to disable it explicitely
    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation() && suf != "HEIF" && suf != "HEIC") {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(path, img);
    }

    if(!img.isNull() && !imageIsScaled) {
        PQCScriptsColorProfiles::get().applyColorProfile(path, img);
        PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
    }

    // And we're done!
    return img;


#endif

    return QImage();

}

void PQCImagePluginMagick::setEnabled(QString description, bool enabled) {

    // first find all the suffixes and mimetypes for this format description
    QSet<QString> suffixes, mimetypes;
    for(const auto &[key, value] : std::as_const(m_suffix2description).asKeyValueRange()) {
        if(value == description)
            suffixes.insert(key);
    }
    for(const auto &[key, value] : std::as_const(mimetype2description).asKeyValueRange()) {
        if(value == description)
            mimetypes.insert(key);
    }

    // then find the ones stored as toggled
    QSet<QString> storedSuffixes, storedMimetypes;

#ifdef PQMIMAGEMAGICK
    const QString suffixFilename = m_settingsDir % "/imagemagick_suffixes";
#else
    const QString suffixFilename = m_settingsDir % "/graphicsmagick_suffixes";
#endif
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

#ifdef PQMIMAGEMAGICK
    const QString mimeFilename = m_settingsDir % "/imagemagick_mimetypes";
#else
    const QString mimeFilename = m_settingsDir % "/graphicsmagick_mimetypes";
#endif
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

void PQCImagePluginMagick::loadFormats() {

    // we always already consider the file ending, these are only the mismatched pairs
    m_suffix2magick = {
        {"dib", "BMP"},
        {"epsf", "EPS"},
        {"epsi", "EPS"},
        {"jpeg2000", "JP2"},
        {"j2k",      "JP2"},
        {"jpc",      "JP2"},
        {"jpx",      "JP2"},
        {"jpf",      "JP2"},
        {"j2c",      "JP2"},
        {"jpg",  "JPEG"},
        {"jpe",  "JPEG"},
        {"jif",  "JPEG"},
        {"pnm", "PPM"},
        {"rgba", "RGB"},
        {"sgi",  "RGB"},
        {"bw",   "RGB"},
        {"icb", "TGA"},
        {"vda", "TGA"},
        {"vst", "TGA"},
        {"tiff", "TIF"},
        {"bm",  "XBM"},
        {"ch",  "SCT"},
        {"ct",  "SCT"},
        {"sun",  "RAS"},
        {"sr",   "RAS"},
        {"im1",  "RAS"},
        {"im24", "RAS"},
        {"im32", "RAS"},
        {"im8",  "RAS"},
        {"rast", "RAS"},
        {"rs",   "RAS"},
        {"scr",  "RAS"},
        {"pm",  "XPM"},
        {"avifs", "AVIF"}
    };

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
#ifdef PQMIMAGEMAGICK
    const QString suffixFilename = m_settingsDir % "/imagemagick_suffixes";
#else
    const QString suffixFilename = m_settingsDir % "/graphicsmagick_suffixes";
#endif
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
#ifdef PQMIMAGEMAGICK
        m_toggledSuffixes = {"eps", "epsf", "epsi", "epi", "ept", "ps", "ps2", "ps3", "bpg", "cg4", "g4"};
#else
        m_toggledSuffixes = {"eps", "epsf", "epsi", "epi", "ept", "ps", "ps2", "ps3"};
#endif
    } else {
        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();
    }

    // then we store ALL supported suffixes
#ifdef PQMIMAGEMAGICK
    const QSet<QString> candidates = {"bmp", "dib", "cur", "eps", "epsf", "epsi", "exr", "gif", "icns",
                                      "jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpeg", "jpg", "jpe", "jif",
                                      "mng", "ora", "pbm", "pcx", "pgm", "pict", "pct", "pic", "png",
                                      "ppm", "pnm", "psd", "psb", "psdt", "rgba", "rgb", "sgi", "bw",
                                      "svg", "svgz", "tga", "icb", "vda", "vst", "tiff", "tif", "wbmp",
                                      "xbm", "bm", "xcf", "sfw", "alb", "pwm", "pwp", "art", "avs",
                                      "mbfavs", "sct", "ch", "ct", "dcr", "kdc", "drf", "k25", "dcs",
                                      "dc2", "kc2", "cals", "ct1", "ct2", "ct3", "ct4", "c4", "cal", "nif",
                                      "ras", "cut", "pal", "dcx", "dic", "dcm", "dpx", "epi", "ept", "fits",
                                      "fit", "fts", "cg3", "g3", "jbig", "jbg", "bie", "jng", "mat", "miff",
                                      "mif", "mtv", "pic", "otb", "palm", "pam", "pcd", "pcds", "pdb", "picon",
                                      "pix", "als", "alias", "ps", "ps2", "ps3", "ptiff", "ptif", "rla",
                                      "rle", "sun", "ras", "sr", "im1", "im24", "im32", "im8", "rast", "rs",
                                      "scr", "tim", "ttf", "vicar", "vic", "img", "viff", "xv", "webp", "wpg",
                                      "aai", "arw", "bpg", "crw", "crr", "cr2", "cr3", "djvu", "djv", "dng",
                                      "ff", "fl32", "rgbe", "hdr", "rad", "heif", "heic", "hrz", "mpc", "srf",
                                      "mrw", "sr2", "arq", "orf", "ori", "pef", "ptx", "pes", "pfm", "raf", "rgf",
                                      "wmf", "wmz", "apm", "dds", "iff", "ico", "xpm", "pm", "avif", "avifs",
                                      "apng", "cube", "mvg", "phm", "xwd", "jxl", "otf", "otc", "ttf", "ttc",
                                      "cg4", "g4", "dfont", "pfb", "pfm", "afm", "inf", "pfa", "ofm", "pgx",
                                      "qoi", "scr", "sixel", "ai"};
#else
    const QSet<QString> candidates = {"bmp", "dib", "cur", "eps", "epsf", "epsi", "gif", "jpeg2000", "j2k",
                                      "jp2", "jpc", "jpx", "jpeg", "jpg", "jpe", "jif", "mng", "pbm", "pcx",
                                      "pgm", "pict", "pct", "pic", "png", "ppm", "pnm", "rgba", "rgb", "sgi",
                                      "bw", "tga", "icb", "vda", "vst", "tiff", "tif", "wbmp", "xbm", "bm",
                                      "xcf", "sfw", "alb", "pwm", "pwp", "art", "avs", "mbfavs", "sct",
                                      "ch", "ct", "dcr", "kdc", "drf", "k25", "dcs", "dc2", "kc2", "cals",
                                      "ct1", "ct2", "ct3", "ct4", "c4", "cal", "nif", "ras", "cut", "pal",
                                      "dic", "dcm", "dpx", "epi", "ept", "fits", "fit", "fts", "cg3", "g3",
                                      "jng", "mat", "miff", "mif", "mtv", "pic", "otb", "p7", "palm", "pam",
                                      "pcd", "pcds", "pdb", "picon", "pix", "als", "alias", "ps", "ps2", "ps3",
                                      "ptiff", "ptif", "rla", "rle", "sun", "ras", "sr", "im1", "im24", "im32",
                                      "im8", "rast", "rs", "scr", "tim", "vicar", "vic", "img", "viff", "xv",
                                      "webp", "wpg", "iff", "ico", "xpm", "pm", "avif", "avifs", "mvg", "xwd",
                                      "pfb", "pfm", "afm", "inf", "pfa", "ofm", "pgx", "ai"};
#endif

    // these are the ones supported by ImageMagick, GraphicsMagick supports a subset of them
    // for simplicity we list them only once
    QHash<QString,QString> candidate_suffix2description = {
        {"bmp", "BMP: Microsoft Windows bitmap"},
        {"dib", "BMP: Microsoft Windows bitmap"},
        {"cur", "CUR: Microsoft Windows cursor format"},
        {"eps",  "EPS: Encapsulated PostScript"},
        {"epsf", "EPS: Encapsulated PostScript"},
        {"epsi", "EPS: Encapsulated PostScript"},
        {"exr", "OpenEXR"},
        {"gif", "GIF: Graphics Interchange Format"},
        {"icns", "Apple Icon Image"},
        {"jpeg2000", "JPEG-2000"},
        {"j2k",      "JPEG-2000"},
        {"jp2",      "JPEG-2000"},
        {"jpc",      "JPEG-2000"},
        {"jpx",      "JPEG-2000"},
        {"jpf",      "JPEG-2000"},
        {"j2c",      "JPEG-2000"},
        {"jpeg", "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpg",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpe",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jif",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"mng", "MNG: Multiple-image Network Graphics"},
        {"ora", "OpenRaster"},
        {"pbm", "PBM: Portable bitmap format (black and white)"},
        {"pcx", "PCX: ZSoft PiCture eXchange"},
        {"pgm", "PGM: Portable graymap format (gray scale)"},
        {"pict", "QuickDraw/PICT"},
        {"pct",  "QuickDraw/PICT"},
        {"pic",  "QuickDraw/PICT"},
        {"png", "PNG: Portable Network Graphics"},
        {"ppm", "PPM: Portable pixmap format (color)"},
        {"pnm", "PPM: Portable pixmap format (color)"},
        {"psd",  "Adobe PhotoShop"},
        {"psb",  "Adobe PhotoShop"},
        {"psdt", "Adobe PhotoShop"},
        {"rgba", "SGI images"},
        {"rgb",  "SGI images"},
        {"sgi",  "SGI images"},
        {"bw",   "SGI images"},
        {"svg",  "SVG: Scalable Vector Graphics"},
        {"svgz", "SVG: Scalable Vector Graphics"},
        {"tga", "TGA: Truevision Targa image"},
        {"icb", "TGA: Truevision Targa image"},
        {"vda", "TGA: Truevision Targa image"},
        {"vst", "TGA: Truevision Targa image"},
        {"tiff", "TIFF: Tagged Image File Format"},
        {"tif",  "TIFF: Tagged Image File Format"},
        {"wbmp", "Wireless Bitmap"},
        {"xbm", "X BitMap"},
        {"bm",  "X BitMap"},
        {"xcf", "Gimp XCF"},
        {"sfw", "Seattle File Works image"},
        {"alb", "Seattle File Works image"},
        {"pwm", "Seattle File Works image"},
        {"pwp", "Seattle File Works image"},
        {"art", "PFS: 1st Publisher"},
        {"avs",    "AVS X image"},
        {"x",      "AVS X image"},
        {"mbfavs", "AVS X image"},
        {"sct", "Scitex Continuous Tone Picture"},
        {"ch",  "Scitex Continuous Tone Picture"},
        {"ct",  "Scitex Continuous Tone Picture"},
        {"dcr", "Kodak Cineon Raw Image Format"},
        {"kdc", "Kodak Cineon Raw Image Format"},
        {"drf", "Kodak Cineon Raw Image Format"},
        {"k25", "Kodak Cineon Raw Image Format"},
        {"dcs", "Kodak Cineon Raw Image Format"},
        {"dc2", "Kodak Cineon Raw Image Format"},
        {"kc2", "Kodak Cineon Raw Image Format"},
        {"cals", "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"ct1",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"ct2",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"ct3",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"ct4",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"c4",   "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"cal",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"nif",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"ras",  "CALS: Continuous Acquisition and Life-cycle Support Type 1 image"},
        {"cut", "Dr. Halo"},
        {"pal", "Dr. Halo"},
        {"dcx", "ZSoft IBM PC multi-page Paintbrush image"},
        {"dic", "Digital Imaging and Communications in Medicine (DICOM) image"},
        {"dcm", "Digital Imaging and Communications in Medicine (DICOM) image"},
        {"dpx", "Digital Moving Picture Exchange"},
        {"epi", "Adobe Encapsulated PostScript Interchange format"},
        {"ept", "Adobe Encapsulated PostScript Interchange format with TIFF preview"},
        {"fits", "FITS: Flexible Image Transport System"},
        {"fit",  "FITS: Flexible Image Transport System"},
        {"fts",  "FITS: Flexible Image Transport System"},
        {"cg3", "FAX: CCITT Group 3"},
        {"g3", "FAX: CCITT Group 3"},
        {"jbig", "JBIG: Joint Bi-level Image experts Group file interchange format (JBIG)"},
        {"jbg",  "JBIG: Joint Bi-level Image experts Group file interchange format (JBIG)"},
        {"bie",  "JBIG: Joint Bi-level Image experts Group file interchange format (JBIG)"},
        {"jng", "JPEG Network Graphics"},
        {"mat", "MATLAB image format"},
        {"miff", "Magick image file format"},
        {"mif",  "Magick image file format"},
        {"mtv", "MTV ray tracer bitmap"},
        {"pic", "MTV ray tracer bitmap"},
        {"otb", "On-the-air Bitmap"},
        {"palm", "Palm pixmap"},
        {"pam", "Portable Arbitrary Map format"},
        {"pcd",  "Photo CD"},
        {"pcds", "Photo CD"},
        {"pdb", "Palm Database ImageViewer Format"},
        {"picon", "Personal Icon"},
        {"pix",   "Alias/Wavefront RLE image format"},
        {"als",   "Alias/Wavefront RLE image format"},
        {"alias", "Alias/Wavefront RLE image format"},
        {"ps",  "Adobe Level III PostScript file"},
        {"ps2", "Adobe Level III PostScript file"},
        {"ps3", "Adobe Level III PostScript file"},
        {"ptiff", "Pyramid encoded TIFF"},
        {"ptif",  "Pyramid encoded TIFF"},
        {"rla", "Wavefront RLA File Format"},
        {"rle", "Utah Run length encoded image file"},
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
        {"tim", "PSX TIM (PlayStation Graphics)"},
        {"ttf", "TrueType font file"},
        {"vicar", "VICAR rasterfile format"},
        {"vic",   "VICAR rasterfile format"},
        {"img",   "VICAR rasterfile format"},
        {"viff", "Khoros Visualization Image File Format"},
        {"xv",   "Khoros Visualization Image File Format"},
        {"webp", "WEBP: Google web image format"},
        {"wpg", "Word Perfect Graphics File"},
        {"aai", "AAI Dune image"},
        {"arw", "Sony Digital Camera Alpha Raw Image Format"},
        {"bpg", "BPG: Better Portable Graphics"},
        {"crw", "Canon Digital Camera Raw Image Format"},
        {"crr", "Canon Digital Camera Raw Image Format"},
        {"cr2", "Canon Digital Camera Raw Image Format"},
        {"cr3", "Canon Digital Camera Raw Image Format"},
        {"djvu", "DjVu digital document format "},
        {"djv",  "DjVu digital document format "},
        {"dng", "Adobe Digital Negative Raw Image Format"},
        {"ff", "farbfeld"},
        {"fl32", "FilmLight floating point image format"},
        {"rgbe", "HDR: Radiance RGBE image format"},
        {"hdr",  "HDR: Radiance RGBE image format"},
        {"rad",  "HDR: Radiance RGBE image format"},
        {"heif", "HEIF: High Efficiency Image Format"},
        {"heic", "HEIF: High Efficiency Image Format"},
        {"hrz", "Slow-scan television"},
        {"mpc", "Magick Persistent Cache image file format"},
        {"srf", "Sony (Minolta) Raw Image Format"},
        {"mrw", "Sony (Minolta) Raw Image Format"},
        {"sr2", "Sony (Minolta) Raw Image Format"},
        {"arq", "Sony (Minolta) Raw Image Format"},
        {"orf", "Olympus Digital Camera Raw Image Format"},
        {"ori", "Olympus Digital Camera Raw Image Format"},
        {"pef", "Pentax Raw Image Format"},
        {"ptx", "Pentax Raw Image Format"},
        {"pes", "Embrid Embroidery Format"},
        {"pfm", "Portable Float Map"},
        {"raf", "Fuji CCD Raw Image Format"},
        {"rgf", "LEGO Mindstorms EV3 Robot Graphics File"},
        {"wmf", "Windows Metafile"},
        {"wmz", "Windows Metafile"},
        {"apm", "Windows Metafile"},
        {"dds", "DirectDraw Surface"},
        {"iff", "Interchange File Format"},
        {"ico", "Microsoft Windows icon format"},
        {"xpm", "X PixMap"},
        {"pm",  "X PixMap"},
        {"avif",  "AVIF: AV1 Image File Format"},
        {"avifs", "AVIF: AV1 Image File Format"},
        {"apng", "APNG: Animated Portable Network Graphics"},
        {"cube", "Cube Color lookup table converted to a HALD image"},
        {"mvg", "Magick Vector Graphics"},
        {"phm", "Portable float map format 16-bit half"},
        {"xwd", "X Windows system window dump"},
        {"jxl", "JPEG XL"},
        {"otf", "OpenType font file"},
        {"otc", "OpenType font file"},
        {"ttf", "OpenType font file"},
        {"ttc", "OpenType font file"},
        {"cg4", "FAX: CCITT Group 4"},
        {"g4",  "FAX: CCITT Group 4"},
        {"dfont", "Multi-face font package"},
        {"pfb", "Postscript Type 1 font "},
        {"pfm", "Postscript Type 1 font "},
        {"afm", "Postscript Type 1 font "},
        {"inf", "Postscript Type 1 font "},
        {"pfa", "Postscript Type 1 font "},
        {"ofm", "Postscript Type 1 font "},
        {"pgx", "JPEG 2000 uncompressed format"},
        {"qoi", "Quite OK image format"},
        {"scr", "ZX-Spectrum SCREEN"},
        {"sixel", "DEC SIXEL Graphics Format"},
        {"ai", "AI: Adobe Illustrator (PDF compatible)"}
    };

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    for(const QString &s : std::as_const(candidates)) {
        try {
            Magick::CoderInfo magickCoderInfo(m_suffix2magick.value(s, s.toUpper()).toStdString());
            if(magickCoderInfo.isWritable()) {
                m_allSuffixes.insert(s);
                m_suffix2description.insert(s, candidate_suffix2description.value(s, ""));
            }
        } catch(...) {
            // do nothing here
        }
    }
#endif

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

#ifdef PQMIMAGEMAGICK
    const QString mimeFilename = m_settingsDir % "/imagemagick_mimetypes";
#else
    const QString mimeFilename = m_settingsDir % "/graphicsmagick_mimetypes";
#endif
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
#ifdef PQMIMAGEMAGICK
        m_toggledMimetypes = {"application/postscript", "application/eps", "application/x-eps",
                              "image/eps", "image/x-eps", "application/postscript", "image/x-eps",
                              "application/postscript", "image/bpg"};
#else
        m_toggledMimetypes = {"application/postscript", "application/eps", "application/x-eps",
                              "image/eps", "image/x-eps", "application/postscript", "image/x-eps",
                              "application/postscript"};
#endif
    } else {
        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();
    }

    // then we store ALL supported mimetypes
#ifdef PQMIMAGEMAGICK
    m_allMimetypes = {"image/bmp", "image/x-ms-bmp", "image/x-win-bitmap", "application/postscript",
                      "application/eps", "application/x-eps", "image/eps", "image/x-eps", "image/x-exr",
                      "image/gif", "image/jp2", "image/jpx", "image/jpeg", "video/x-mng",
                      "image/openraster", "image/x-portable-anymap", "image/vnd.zbrush.pcx", "image/x-pcx",
                      "image/x-portable-greymap", "image/x-portable-anymap", "image/png",
                      "image/x-portable-pixmap", "image/x-portable-anymap", "image/vnd.adobe.photoshop",
                      "image/sgi", "image/svg+xml", "image/x-targa", "image/x-tga", "image/tiff",
                      "image/tiff-fx", "image/vnd.wap.wbmp", "image/x-xbitmap", "image/x-xbm", "image/x-xcf",
                      "application/x-fpt", "application/dicom", "image/dicom-rle", "image/x-dpx",
                      "application/postscript", "image/x-eps", "image/fits", "application/x-pnf", "video/x-jng",
                      "image/x-miff", "image/x-portable-arbitrarymap", "image/x-portable-pixmap", "image/x-xpmi",
                      "application/postscript", "image/tiff", "font/sfnt", "image/webp", "image/bpg",
                      "image/x-canon-crw", "image/x-canon-cr2", "image/vnd.djvu", "image/heic", "image/heif",
                      "image/x-olympus-orf", "image/x-pentax-pef", "image/vnd.microsoft.icon", "image/x-icon",
                      "image/x-xpixmap", "image/x-xpmi", "image/avif", "image/avif-sequence", "image/x-mvg",
                      "image/jxl", "font/opentype", "application/vnd.ms-opentype"};
#else
    m_allMimetypes = {"image/bmp", "image/x-ms-bmp", "image/x-win-bitmap", "application/postscript",
                      "application/eps", "application/x-eps", "image/eps", "image/x-eps", "image/gif",
                      "image/jp2", "image/jpx", "image/jpeg", "video/x-mng", "image/x-portable-anymap",
                      "image/vnd.zbrush.pcx", "image/x-pcx", "image/x-portable-greymap", "image/x-portable-anymap",
                      "image/png", "image/x-portable-pixmap", "image/x-portable-anymap", "image/sgi",
                      "image/x-targa", "image/x-tga", "image/tiff", "image/tiff-fx", "image/vnd.wap.wbmp",
                      "image/x-xbitmap", "image/x-xbm", "image/x-xcf", "application/x-fpt", "application/dicom",
                      "image/dicom-rle", "image/x-dpx", "application/postscript", "image/x-eps", "image/fits",
                      "video/x-jng", "image/x-miff", "image/x-portable-arbitrarymap", "image/x-portable-pixmap",
                      "image/x-xpmi", "application/postscript", "image/tiff", "image/webp", "image/vnd.microsoft.icon",
                      "image/x-icon", "image/x-xpixmap", "image/x-xpmi", "image/avif", "image/avif-sequence",
                      "image/x-mvg"};
#endif

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    mimetype2description = {
        {"image/bmp",                    "BMP: Microsoft Windows bitmap"},
        {"image/x-ms-bmp",               "BMP: Microsoft Windows bitmap"},
        {"image/x-win-bitmap",           "CUR: Microsoft Windows cursor format"},
        {"application/postscript",       "EPS: Encapsulated PostScript"},
        {"application/eps",              "EPS: Encapsulated PostScript"},
        {"application/x-eps",            "EPS: Encapsulated PostScript"},
        {"image/eps",                    "EPS: Encapsulated PostScript"},
        {"image/x-eps",                  "EPS: Encapsulated PostScript"},
        {"image/x-exr",                  "OpenEXR"},
        {"image/gif",                    "GIF: Graphics Interchange Format"},
        {"image/jp2",                    "JPEG-2000"},
        {"image/jpx",                    "JPEG-2000"},
        {"image/jpm",                    "JPEG-2000"},
        {"image/jpeg",                   "JPEG: Joint Photographic Experts Group JFIF format"},
        {"video/x-mng",                  "MNG: Multiple-image Network Graphics"},
        {"image/openraster",             "OpenRaster"},
        {"image/x-portable-anymap",      "PBM: Portable bitmap format (black and white)"},
        {"image/vnd.zbrush.pcx",         "PCX: ZSoft PiCture eXchange"},
        {"image/x-pcx",                  "PCX: ZSoft PiCture eXchange"},
        {"image/x-portable-greymap",     "PGM: Portable graymap format (gray scale)"},
        {"image/x-portable-anymap",      "PGM: Portable graymap format (gray scale)"},
        {"image/png",                    "PNG: Portable Network Graphics"},
        {"image/x-portable-pixmap",      "PPM: Portable pixmap format (color)"},
        {"image/x-portable-anymap",      "PPM: Portable pixmap format (color)"},
        {"image/vnd.adobe.photoshop",    "Adobe PhotoShop"},
        {"image/sgi",                    "SGI images"},
        {"image/svg+xml",                "SVG: Scalable Vector Graphics"},
        {"image/x-targa",                "TGA: Truevision Targa image"},
        {"image/x-tga",                  "TGA: Truevision Targa image"},
        {"image/tiff",                   "TIFF: Tagged Image File Format"},
        {"image/tiff-fx",                "TIFF: Tagged Image File Format"},
        {"image/vnd.wap.wbmp",           "Wireless Bitmap"},
        {"image/x-xbitmap",              "X BitMap"},
        {"image/x-xbm",                  "X BitMap"},
        {"image/x-xcf",                  "Gimp XCF"},
        {"application/x-fpt",            "AVS X image"},
        {"application/dicom",            "Digital Imaging and Communications in Medicine (DICOM) image"},
        {"image/dicom-rle",              "Digital Imaging and Communications in Medicine (DICOM) image"},
        {"image/x-dpx",                  "Digital Moving Picture Exchange"},
        {"application/postscript",       "Adobe Encapsulated PostScript Interchange format"},
        {"image/x-eps",                  "Adobe Encapsulated PostScript Interchange format with TIFF preview"},
        {"image/fits",                   "FITS: Flexible Image Transport System"},
        {"application/x-pnf",            "JBIG: Joint Bi-level Image experts Group file interchange format (JBIG)"},
        {"video/x-jng",                  "JPEG Network Graphics"},
        {"image/x-miff",                 "Magick image file format"},
        {"image/x-portable-arbitrarymap", "Portable Arbitrary Map format"},
        {"image/x-portable-pixmap",       "Portable Arbitrary Map format"},
        {"image/x-xpmi",                  "Personal Icon"},
        {"application/postscript",        "Adobe Level III PostScript file"},
        {"image/tiff",                    "Pyramid encoded TIFF"},
        {"font/sfnt",                     "TrueType font file"},
        {"image/webp",                    "WEBP: Google web image format"},
        {"image/bpg",                     "BPG: Better Portable Graphics"},
        {"image/x-canon-crw",             "Canon Digital Camera Raw Image Format"},
        {"image/x-canon-cr2",             "Canon Digital Camera Raw Image Format"},
        {"image/vnd.djvu",                "DjVu digital document format "},
        {"image/heic",                    "HEIF: High Efficiency Image Format"},
        {"image/heif",                    "HEIF: High Efficiency Image Format"},
        {"image/x-olympus-orf",           "Olympus Digital Camera Raw Image Format"},
        {"image/x-pentax-pef",            "Pentax Raw Image Format"},
        {"image/vnd.microsoft.icon",      "Microsoft Windows icon format"},
        {"image/x-icon",                  "Microsoft Windows icon format"},
        {"image/x-xpixmap",               "X PixMap"},
        {"image/x-xpmi",                  "X PixMap"},
        {"image/avif",                    "AVIF: AV1 Image File Format"},
        {"image/avif-sequence",           "AVIF: AV1 Image File Format"},
        {"image/x-mvg",                   "Magick Vector Graphics"},
        {"image/jxl",                     "JPEG XL"},
        {"font/opentype",                 "OpenType font file"},
        {"application/vnd.ms-opentype",   "OpenType font file"}
    };

    Q_EMIT formatsUpdated();

}
