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

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

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

    QHash<int, QList<QStringList > > candidateData = {
        {46588,
             {{"AAI Dune image"}, {"aai"}, {}}},
        {48547,
             {{"AI: Adobe Illustrator (PDF compatible)"}, {"ai"}, {}}},
        {33323,
             {{"APNG: Animated Portable Network Graphics"}, {"apng"}, {}}},
        {66696,
             {{"AVIF: AV1 Image File Format"}, {"avif","avifs"}, {"image/avif","image/avif-sequence"}}},
        {11322,
             {{"AVS X image"}, {"avs","x","mbfavs"}, {"application/x-fpt"}}},
        {19119,
             {{"Adobe Digital Negative Raw Image Format"}, {"dng"}, {}}},
        {15687,
             {{"Adobe Encapsulated PostScript Interchange format"}, {"epi"}, {"application/postscript"}}},
        {23556,
             {{"Adobe Encapsulated PostScript Interchange format with TIFF preview"}, {"ept"}, {"image/x-eps"}}},
        {13477,
             {{"Adobe Level III PostScript file"}, {"ps","ps2","ps3"}, {"application/postscript"}}},
        {26486,
             {{"Adobe PhotoShop"}, {"psd","psb","psdt"}, {"image/vnd.adobe.photoshop"}}},
        {55462,
             {{"Alias/Wavefront RLE image format"}, {"pix","als","alias"}, {}}},
        {54789,
             {{"Apple Icon Image"}, {"icns"}, {}}},
        {45621,
             {{"BMP: Microsoft Windows bitmap"}, {"bmp","dib"}, {"image/bmp","image/x-ms-bmp"}}},
        {27272,
             {{"BPG: Better Portable Graphics"}, {"bpg"}, {"image/bpg"}}},
        {15612,
             {{"CALS: Continuous Acquisition and Life-cycle Support Type 1 image"}, {"cals","ct1","ct2","ct3","ct4","c4","cal","nif","ras"}, {}}},
        {58156,
             {{"CUR: Microsoft Windows cursor format"}, {"cur"}, {"image/x-win-bitmap"}}},
        {61616,
             {{"Canon Digital Camera Raw Image Format"}, {"crw","crr","cr2","cr3"}, {"image/x-canon-crw","image/x-canon-cr2"}}},
        {65432,
             {{"Cube Color lookup table converted to a HALD image"}, {"cube"}, {}}},
        {22647,
             {{"DEC SIXEL Graphics Format"}, {"sixel"}, {}}},
        {44562,
             {{"Digital Imaging and Communications in Medicine (DICOM) image"}, {"dic","dcm"}, {"application/dicom","image/dicom-rle"}}},
        {12347,
             {{"Digital Moving Picture Exchange"}, {"dpx"}, {"image/x-dpx"}}},
        {74447,
             {{"DirectDraw Surface"}, {"dds"}, {}}},
        {43433,
             {{"DjVu digital document format "}, {"djvu","djv"}, {"image/vnd.djvu"}}},
        {13444,
             {{"Dr. Halo"}, {"cut","pal"}, {}}},
        {45612,
             {{"EPS: Encapsulated PostScript"}, {"eps","epsf","epsi"}, {"application/postscript","application/eps","application/x-eps","image/eps","image/x-eps"}}},
        {55555,
             {{"Embrid Embroidery Format"}, {"pes"}, {}}},
        {85223,
             {{"FAX: CCITT Group 3"}, {"cg3","g3"}, {}}},
        {56789,
             {{"FAX: CCITT Group 4"}, {"cg4","g4"}, {}}},
        {12444,
             {{"FITS: Flexible Image Transport System"}, {"fits","fit","fts"}, {"image/fits"}}},
        {71711,
             {{"FilmLight floating point image format"}, {"fl32"}, {}}},
        {33333,
             {{"Fuji CCD Raw Image Format"}, {"raf"}, {}}},
        {52412,
             {{"GIF: Graphics Interchange Format"}, {"gif"}, {"image/gif"}}},
        {16443,
             {{"Gimp XCF"}, {"xcf"}, {"image/x-xcf"}}},
        {11113,
             {{"HDR: Radiance RGBE image format"}, {"rgbe","hdr","rad"}, {}}},
        {22226,
             {{"HEIF: High Efficiency Image Format"}, {"heif","heic"}, {"image/heic","image/heif"}}},
        {28882,
             {{"Interchange File Format"}, {"iff"}, {}}},
        {68974,
             {{"JBIG: Joint Bi-level Image experts Group file interchange format (JBIG)"}, {"jbig","jbg","bie"}, {"application/x-pnf"}}},
        {71111,
             {{"JPEG 2000 uncompressed format"}, {"pgx"}, {}}},
        {69532,
             {{"JPEG Network Graphics"}, {"jng"}, {"video/x-jng"}}},
        {34567,
             {{"JPEG XL"}, {"jxl"}, {"image/jxl"}}},
        {13245,
             {{"JPEG-2000"}, {"jpeg2000","j2k","jp2","jpc","jpx"}, {"image/jp2","image/jpx","image/jpm"}}},
        {11485,
             {{"JPEG: Joint Photographic Experts Group JFIF format"}, {"jpeg","jpg","jpe","jif"}, {"image/jpeg"}}},
        {66554,
             {{"Khoros Visualization Image File Format"}, {"viff","xv"}, {}}},
        {88854,
             {{"Kodak Cineon Raw Image Format"}, {"dcr","kdc","drf","k25","dcs","dc2","kc2"}, {}}},
        {22222,
             {{"LEGO Mindstorms EV3 Robot Graphics File"}, {"rgf"}, {}}},
        {12348,
             {{"MATLAB image format"}, {"mat"}, {}}},
        {13695,
             {{"MNG: Multiple-image Network Graphics"}, {"mng"}, {"video/x-mng"}}},
        {18866,
             {{"MTV ray tracer bitmap"}, {"mtv","pic"}, {}}},
        {77755,
             {{"Magick Persistent Cache image file format"}, {"mpc"}, {}}},
        {76532,
             {{"Magick Vector Graphics"}, {"mvg"}, {"image/x-mvg"}}},
        {56214,
             {{"Magick image file format"}, {"miff","mif"}, {"image/x-miff"}}},
        {66646,
             {{"Microsoft Windows icon format"}, {"ico"}, {"image/vnd.microsoft.icon","image/x-icon"}}},
        {66111,
             {{"Multi-face font package"}, {"dfont"}, {}}},
        {73333,
             {{"Olympus Digital Camera Raw Image Format"}, {"orf","ori"}, {"image/x-olympus-orf"}}},
        {32547,
             {{"On-the-air Bitmap"}, {"otb"}, {}}},
        {74586,
             {{"OpenEXR"}, {"exr"}, {"image/x-exr"}}},
        {84523,
             {{"OpenRaster"}, {"ora"}, {"image/openraster"}}},
        {45678,
             {{"OpenType font file"}, {"otf","otc","ttf","ttc"}, {"font/opentype","application/vnd.ms-opentype"}}},
        {16685,
             {{"PBM: Portable bitmap format (black and white)"}, {"pbm"}, {"image/x-portable-anymap"}}},
        {25566,
             {{"PCX: ZSoft PiCture eXchange"}, {"pcx"}, {"image/vnd.zbrush.pcx","image/x-pcx"}}},
        {32286,
             {{"PFS: 1st Publisher"}, {"art"}, {}}},
        {85444,
             {{"PGM: Portable graymap format (gray scale)"}, {"pgm"}, {"image/x-portable-greymap","image/x-portable-anymap"}}},
        {46215,
             {{"PNG: Portable Network Graphics"}, {"png"}, {"image/png"}}},
        {77521,
             {{"PPM: Portable pixmap format (color)"}, {"ppm","pnm"}, {"image/x-portable-pixmap","image/x-portable-anymap"}}},
        {15151,
             {{"PSX TIM (PlayStation Graphics)"}, {"tim"}, {}}},
        {99951,
             {{"Palm Database ImageViewer Format"}, {"pdb"}, {}}},
        {53214,
             {{"Palm pixmap"}, {"palm"}, {}}},
        {64444,
             {{"Pentax Raw Image Format"}, {"pef","ptx"}, {"image/x-pentax-pef"}}},
        {12211,
             {{"Personal Icon"}, {"picon"}, {"image/x-xpmi"}}},
        {56231,
             {{"Photo CD"}, {"pcd","pcds"}, {}}},
        {89774,
             {{"Portable Arbitrary Map format"}, {"pam"}, {"image/x-portable-arbitrarymap","image/x-portable-pixmap"}}},
        {44444,
             {{"Portable Float Map"}, {"pfm"}, {}}},
        {98765,
             {{"Portable float map format 16-bit half"}, {"phm"}, {}}},
        {55511,
             {{"Postscript Type 1 font "}, {"pfb","pfm","afm","inf","pfa","ofm"}, {}}},
        {45122,
             {{"Pyramid encoded TIFF"}, {"ptiff","ptif"}, {"image/tiff"}}},
        {11998,
             {{"QuickDraw/PICT"}, {"pict","pct","pic"}, {}}},
        {31111,
             {{"Quite OK image format"}, {"qoi"}, {}}},
        {33352,
             {{"SGI images"}, {"rgba","rgb","sgi","bw"}, {"image/sgi"}}},
        {91919,
             {{"SUN Rasterfile"}, {"sun","ras","sr","im1","im24","im32","im8","rast","rs","scr"}, {}}},
        {26112,
             {{"SVG: Scalable Vector Graphics"}, {"svg","svgz"}, {"image/svg+xml"}}},
        {56223,
             {{"Scitex Continuous Tone Picture"}, {"sct","ch","ct"}, {}}},
        {11162,
             {{"Seattle File Works image"}, {"sfw","alb","pwm","pwp"}, {}}},
        {88888,
             {{"Slow-scan television"}, {"hrz"}, {}}},
        {91111,
             {{"Sony (Minolta) Raw Image Format"}, {"srf","mrw","sr2","arq"}, {}}},
        {13131,
             {{"Sony Digital Camera Alpha Raw Image Format"}, {"arw"}, {}}},
        {85621,
             {{"TGA: Truevision Targa image"}, {"tga","icb","vda","vst"}, {"image/x-targa","image/x-tga"}}},
        {44462,
             {{"TIFF: Tagged Image File Format"}, {"tiff","tif"}, {"image/tiff","image/tiff-fx"}}},
        {46464,
             {{"TrueType font file"}, {"ttf"}, {"font/sfnt"}}},
        {99885,
             {{"Utah Run length encoded image file"}, {"rle"}, {}}},
        {32321,
             {{"VICAR rasterfile format"}, {"vicar","vic","img"}, {}}},
        {28282,
             {{"WEBP: Google web image format"}, {"webp"}, {"image/webp"}}},
        {65423,
             {{"Wavefront RLA File Format"}, {"rla"}, {}}},
        {11111,
             {{"Windows Metafile"}, {"wmf","wmz","apm"}, {}}},
        {12788,
             {{"Wireless Bitmap"}, {"wbmp"}, {"image/vnd.wap.wbmp"}}},
        {39393,
             {{"Word Perfect Graphics File"}, {"wpg"}, {}}},
        {87775,
             {{"X BitMap"}, {"xbm","bm"}, {"image/x-xbitmap","image/x-xbm"}}},
        {44474,
             {{"X PixMap"}, {"xpm","pm"}, {"image/x-xpixmap","image/x-xpmi"}}},
        {87654,
             {{"X Windows system window dump"}, {"xwd"}, {}}},
        {66688,
             {{"Xv Visual Schnauzer thumbnail format"}, {"p7"}, {}}},
        {85521,
             {{"ZSoft IBM PC multi-page Paintbrush image"}, {"dcx"}, {}}},
        {99775,
             {{"ZX-Spectrum SCREEN"}, {"scr"}, {}}},
        {42422,
             {{"farbfeld"}, {"ff"}, {}}}
    };

    QHash<int,QList<QStringList > > finalData;
    QSet<int> finalWritableFormats;
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

    for(const auto &[key, value] : std::as_const(candidateData).asKeyValueRange()) {

        QStringList finalS;
        bool canWrite = false;
        const QStringList allS = value.at(1);
        for(const QString &s : allS) {
            try {
                Magick::CoderInfo magickCoderInfo(m_suffix2magick.value(s, s.toUpper()).toStdString());
                if(magickCoderInfo.isReadable() && !finalS.contains(s))
                        finalS.append(s);
                if(!canWrite && magickCoderInfo.isWritable()) {
                    canWrite = true;
                    break;
                }
            } catch(...) {
                // do nothing here
            }
        }
        if(canWrite)
            finalWritableFormats.insert(key);
        if(finalS.size())
            finalData.insert(key, {value[0], finalS, value[2]});

    }

#endif
    setData(finalData,
#ifdef PQMIMAGEMAGICK
            "imagemagick",
            {45612, 15687, 23556, 13477, 27272, 56789, 13245}
#else
            "graphicsmagick",
            {45612, 15687, 23556, 13477, 13245}
#endif
            );

    setWritableFormats(finalWritableFormats);

#endif

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
        const QString prf = PQCScriptsColorProfiles::get().applyColorProfile(path, img);
        PQCImageCache::get().saveImageToCache(path, prf, img);
    }

    // And we're done!
    return img;


#endif

    return QImage();

}

const bool PQCImagePluginMagick::writeImage(QImage img, QString targetPath) {
    return false;
}
