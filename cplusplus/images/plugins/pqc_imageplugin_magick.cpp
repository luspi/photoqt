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

#include <imageplugins/pqc_imageplugin_magick.h>
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

PQCImagePluginMagick::PQCImagePluginMagick() {

    // we always already consider the file ending, these are only the mismatched pairs
    m_suffix2magick = {
        {"dib",      "BMP"},
        {"epsf",     "EPS"},
        {"epsi",     "EPS"},
        {"jpeg2000", "JP2"},
        {"j2k",      "JP2"},
        {"jpc",      "JP2"},
        {"jpx",      "JP2"},
        {"jpf",      "JP2"},
        {"j2c",      "JP2"},
        {"jpg",      "JPEG"},
        {"jpe",      "JPEG"},
        {"jif",      "JPEG"},
        {"pnm",      "PPM"},
        {"rgba",     "RGB"},
        {"sgi",      "RGB"},
        {"bw",       "RGB"},
        {"icb",      "TGA"},
        {"vda",      "TGA"},
        {"vst",      "TGA"},
        {"tiff",     "TIF"},
        {"bm",       "XBM"},
        {"ch",       "SCT"},
        {"ct",       "SCT"},
        {"sun",      "RAS"},
        {"sr",       "RAS"},
        {"im1",      "RAS"},
        {"im24",     "RAS"},
        {"im32",     "RAS"},
        {"im8",      "RAS"},
        {"rast",     "RAS"},
        {"rs",       "RAS"},
        {"scr",      "RAS"},
        {"pm",       "XPM"},
        {"avifs",    "AVIF"}
    };

    QHash<QString, QList<QStringList > > candidateData = {
        {"BMP: Microsoft Windows bitmap",
                {{"bmp", "dib"}, {"image/bmp", "image/x-ms-bmp"}}},
        {"CUR: Microsoft Windows cursor format",
                {{"cur"}, {"image/x-win-bitmap"}}},
        {"EPS: Encapsulated PostScript",
                {{"eps", "epsf", "epsi"}, {"application/postscript", "application/eps", "application/x-eps", "image/eps", "image/x-eps"}}},
        {"OpenEXR",
                {{"exr"}, {"image/x-exr"}}},
        {"GIF: Graphics Interchange Format",
                {{"gif"}, {"image/gif"}}},
        {"Apple Icon Image",
                {{"icns"}, {}}},
        {"JPEG-2000",
                {{"jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpf", "j2c"}, {"image/jp2", "image/jpx", "image/jpm"}}},
        {"JPEG: Joint Photographic Experts Group JFIF format",
                {{"jpeg", "jpg", "jpe", "jif"}, {"image/jpeg"}}},
        {"MNG: Multiple-image Network Graphics",
                {{"mng"}, {"video/x-mng"}}},
        {"OpenRaster",
                {{"ora"}, {"image/openraster"}}},
        {"PBM: Portable bitmap format (black and white)",
                {{"pbm"}, {"image/x-portable-anymap"}}},
        {"PCX: ZSoft PiCture eXchange",
                {{"pcx"}, {"image/vnd.zbrush.pcx", "image/x-pcx"}}},
        {"PGM: Portable graymap format (gray scale)",
                {{"pgm"}, {"image/x-portable-greymap", "image/x-portable-anymap"}}},
        {"QuickDraw/PICT",
                {{"pict", "pct", "pic"}, {}}},
        {"PNG: Portable Network Graphics",
                {{"png"}, {"image/png"}}},
        {"PPM: Portable pixmap format (color)",
                {{"ppm", "pnm"}, {"image/x-portable-pixmap", "image/x-portable-anymap"}}},
        {"Adobe PhotoShop",
                {{"psd", "psb", "psdt"}, {"image/vnd.adobe.photoshop"}}},
        {"SGI images",
                {{"rgba", "rgb", "sgi", "bw"}, {"image/sgi"}}},
        {"SVG: Scalable Vector Graphics",
                {{"svg", "svgz"}, {"image/svg+xml"}}},
        {"TGA: Truevision Targa image",
                {{"tga", "icb", "vda", "vst"}, {"image/x-targa", "image/x-tga"}}},
        {"TIFF: Tagged Image File Format",
                {{"tiff", "tif"}, {"image/tiff", "image/tiff-fx"}}},
        {"Wireless Bitmap",
                {{"wbmp"}, {"image/vnd.wap.wbmp"}}},
        {"X BitMap",
                {{"xbm", "bm"}, {"image/x-xbitmap", "image/x-xbm"}}},
        {"Gimp XCF",
                {{"xcf"}, {"image/x-xcf"}}},
        {"Seattle File Works image",
                {{"sfw", "alb", "pwm", "pwp"}, {}}},
        {"PFS: 1st Publisher",
                {{"art"}, {}}},
        {"AVS X image",
                {{"avs", "x", "mbfavs"}, {"application/x-fpt"}}},
        {"Scitex Continuous Tone Picture",
                {{"sct", "ch", "ct"}, {}}},
        {"Kodak Cineon Raw Image Format",
                {{"dcr", "kdc", "drf", "k25", "dcs", "dc2", "kc2"}, {}}},
        {"CALS: Continuous Acquisition and Life-cycle Support Type 1 image",
                {{"cals", "ct1", "ct2", "ct3", "ct4", "c4", "cal", "nif", "ras"}, {}}},
        {"Dr. Halo",
                {{"cut", "pal"}, {}}},
        {"ZSoft IBM PC multi-page Paintbrush image",
                {{"dcx"}, {}}},
        {"Digital Imaging and Communications in Medicine (DICOM) image",
                {{"dic", "dcm"}, {"application/dicom", "image/dicom-rle"}}},
        {"Digital Moving Picture Exchange",
                {{"dpx"}, {"image/x-dpx"}}},
        {"Adobe Encapsulated PostScript Interchange format",
                {{"epi"}, {"application/postscript"}}},
        {"Adobe Encapsulated PostScript Interchange format with TIFF preview",
                {{"ept"}, {"image/x-eps"}}},
        {"FITS: Flexible Image Transport System",
                {{"fits", "fit", "fts"}, {"image/fits"}}},
        {"FAX: CCITT Group 3",
                {{"cg3", "g3"}, {}}},
        {"JBIG: Joint Bi-level Image experts Group file interchange format (JBIG)",
                {{"jbig", "jbg", "bie"}, {"application/x-pnf"}}},
        {"JPEG Network Graphics",
                {{"jng"}, {"video/x-jng"}}},
        {"MATLAB image format",
                {{"mat"}, {}}},
        {"Magick image file format",
                {{"miff", "mif"}, {"image/x-miff"}}},
        {"MTV ray tracer bitmap",
                {{"mtv", "pic"}, {}}},
        {"On-the-air Bitmap",
                {{"otb"}, {}}},
        {"Palm pixmap",
                {{"palm"}, {}}},
        {"Portable Arbitrary Map format",
                {{"pam"}, {"image/x-portable-arbitrarymap", "image/x-portable-pixmap"}}},
        {"Photo CD",
                {{"pcd", "pcds"}, {}}},
        {"Palm Database ImageViewer Format",
                {{"pdb"}, {}}},
        {"Personal Icon",
                {{"picon"}, {"image/x-xpmi"}}},
        {"Alias/Wavefront RLE image format",
                {{"pix", "als", "alias"}, {}}},
        {"Adobe Level III PostScript file",
                {{"ps", "ps2", "ps3"}, {"application/postscript"}}},
        {"Pyramid encoded TIFF",
                {{"ptiff", "ptif"}, {"image/tiff"}}},
        {"Wavefront RLA File Format",
                {{"rla"}, {}}},
        {"Utah Run length encoded image file",
                {{"rle"}, {}}},
        {"SUN Rasterfile",
                {{"sun", "ras", "sr", "im1", "im24", "im32", "im8", "rast", "rs", "scr"}, {}}},
        {"PSX TIM (PlayStation Graphics)",
                {{"tim"}, {}}},
        {"TrueType font file",
                {{"ttf"}, {"font/sfnt"}}},
        {"VICAR rasterfile format",
                {{"vicar", "vic", "img"}, {}}},
        {"Khoros Visualization Image File Format",
                {{"viff", "xv"}, {}}},
        {"WEBP: Google web image format",
                {{"webp"}, {"image/webp"}}},
        {"Word Perfect Graphics File",
                {{"wpg"}, {}}},
        {"AAI Dune image",
                {{"aai"}, {}}},
        {"Sony Digital Camera Alpha Raw Image Format",
                {{"arw"}, {}}},
        {"BPG: Better Portable Graphics",
                {{"bpg"}, {"image/bpg"}}},
        {"Canon Digital Camera Raw Image Format",
                {{"crw", "crr", "cr2", "cr3"}, {"image/x-canon-crw", "image/x-canon-cr2"}}},
        {"DjVu digital document format",
                {{"djvu", "djv"}, {"image/vnd.djvu"}}},
        {"Adobe Digital Negative Raw Image Format",
                {{"dng"}, {}}},
        {"farbfeld",
                {{"ff"}, {}}},
        {"FilmLight floating point image format",
                {{"fl32"}, {}}},
        {"HDR: Radiance RGBE image format",
                {{"rgbe", "hdr", "rad"}, {}}},
        {"HEIF: High Efficiency Image Format",
                {{"heif", "heic"}, {"image/heif", "image/heic"}}},
        {"Slow-scan television",
                {{"hrz"}, {}}},
        {"Magick Persistent Cache image file format",
                {{"mpc"}, {}}},
        {"Sony (Minolta) Raw Image Format",
                {{"srf", "mrw", "sr2", "arq"}, {}}},
        {"Olympus Digital Camera Raw Image Format",
                {{"orf", "ori"}, {"image/x-olympus-orf"}}},
        {"Pentax Raw Image Format",
                {{"pef", "ptx"}, {"image/x-pentax-pef"}}},
        {"Embrid Embroidery Format",
                {{"pes"}, {}}},
        {"Portable Float Map",
                {{"pfm"}, {}}},
        {"Fuji CCD Raw Image Format",
                {{"raf"}, {}}},
        {"LEGO Mindstorms EV3 Robot Graphics File",
                {{"rgf"}, {}}},
        {"Windows Metafile",
                {{"wmf", "wmz", "apm"}, {}}},
        {"DirectDraw Surface",
                {{"dds"}, {}}},
        {"Interchange File Format",
                {{"iff"}, {}}},
        {"Microsoft Windows icon format",
                {{"ico"}, {"image/vnd.microsoft.icon", "image/x-icon"}}},
        {"X PixMap",
                {{"xpm", "pm"}, {"image/x-xpixmap", "image/x-xpmi"}}},
        {"AVIF: AV1 Image File Format",
                {{"avif", "avifs"}, {"image/avif", "image/avif-sequence"}}},
        {"APNG: Animated Portable Network Graphics",
                {{"apng"}, {}}},
        {"Cube Color lookup table converted to a HALD image",
                {{"cube"}, {}}},
        {"Magick Vector Graphics",
                {{"mvg"}, {"image/x-mvg"}}},
        {"Portable float map format 16-bit half",
                {{"phm"}, {}}},
        {"X Windows system window dump",
                {{"xwd"}, {}}},
        {"JPEG XL",
                {{"jxl"}, {"image/jxl"}}},
        {"OpenType font file",
                {{"otf", "otc", "ttf", "ttc"}, {"font/opentype", "application/vnd.ms-opentype"}}},
        {"FAX: CCITT Group 4",
                {{"cg4", "g4"}, {}}},
        {"Multi-face font package",
                {{"dfont"}, {}}},
        {"Postscript Type 1 font",
                {{"pfb", "pfm", "afm", "inf", "pfa", "ofm"}, {}}},
        {"JPEG 2000 uncompressed format",
                {{"pgx"}, {}}},
        {"Quite OK image format",
                {{"qoi"}, {}}},
        {"ZX-Spectrum SCREEN",
                {{"scr"}, {}}},
        {"DEC SIXEL Graphics Format",
                {{"sixel"}, {}}},
        {"AI: Adobe Illustrator (PDF compatible)",
                {{"ai"}, {}}}
    };

    QHash<QString,QList<QStringList > > finalData;
    QSet<QString> finalWritableFormats;
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

    for(const auto &[key, value] : std::as_const(candidateData).asKeyValueRange()) {

        QStringList finalS;
        bool canWrite = false;
        const QStringList allS = value.at(0);
        for(const QString &s : allS) {
            try {
                Magick::CoderInfo magickCoderInfo(m_suffix2magick.value(s, s.toUpper()).toStdString());
                if(magickCoderInfo.isReadable() && !finalS.contains(s))
                        finalS.append(s);
                if(!canWrite && magickCoderInfo.isWritable())
                    canWrite = true;
            } catch(...) {
                // do nothing here
            }
        }
        if(canWrite)
            finalWritableFormats.insert(key);
        if(finalS.size())
            finalData.insert(key, {finalS, value[1]});

    }
#endif
    setData(finalData,
#ifdef PQMIMAGEMAGICK
            "imagemagick",
            {"eps", "epsf", "epsi", "epi", "ept", "ps", "ps2", "ps3", "bpg", "cg4", "g4",
             "jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpf", "j2c"},
            {"application/postscript", "application/eps", "application/x-eps",
             "image/eps", "image/x-eps", "application/postscript", "image/x-eps",
             "application/postscript", "image/bpg",
             "image/jp2", "image/jpx", "image/jpm"}
#else
            "graphicsmagick",
            {"eps", "epsf", "epsi", "epi", "ept", "ps", "ps2", "ps3",
             "jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpf", "j2c"},
            {"application/postscript", "application/eps", "application/x-eps",
             "image/eps", "image/x-eps", "application/postscript", "image/x-eps",
             "application/postscript", "image/jp2", "image/jpx", "image/jpm"}
#endif
            );

    setWritableFormats(finalWritableFormats);

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

    if(!img.isNull() && !imageIsScaled)
        PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().applyColorProfile(path, img), img);

    // And we're done!
    return img;


#endif

    return QImage();

}

const bool PQCImagePluginMagick::writeImage(QImage img, QString targetPath) {
    return false;
}
