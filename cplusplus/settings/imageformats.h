#ifndef IMAGEFORMATS_H
#define IMAGEFORMATS_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QFile>
#include <QTimer>

#include "../configfiles.h"
#include "../logger.h"

class ImageFormats : public QObject {

    Q_OBJECT

public:
    ImageFormats(QObject *parent = 0) : QObject(parent) {

        categories << "qt" << "kde" << "extras" << "gm" << "gmghostscript" << "raw" << "devil" << "freeimage";
        formatsfiles << ConfigFiles::FILEFORMATSQT_FILE() << ConfigFiles::FILEFORMATSKDE_FILE()
                     << ConfigFiles::FILEFORMATSEXTRAS_FILE() << ConfigFiles::FILEFORMATSGM_FILE()
                     << ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE() << ConfigFiles::FILEFORMATSRAW_FILE()
                     << ConfigFiles::FILEFORMATSDEVIL_FILE() << ConfigFiles::FILEFORMATSFREEIMAGE_FILE();

        setupAvailable = new QMap<QString, QStringList>[categories.length()];

        // Qt
        setupAvailable[0].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
        setupAvailable[0].insert("*.bitmap"     , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
        setupAvailable[0].insert("*.gif"        , QStringList() << "gif" << "CompuServe Graphics Interchange Format"        << "1");
        setupAvailable[0].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.jpc"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.j2k"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.jpeg2000"   , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.jpx"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.mng"        , QStringList() << "mng" << "Multiple-image Network Graphics"               << "1");
        setupAvailable[0].insert("*.ico"        , QStringList() << "ico" << "Microsoft icon"                                << "1");
        setupAvailable[0].insert("*.cur"        , QStringList() << "ico" << "Microsoft icon"                                << "1");
        setupAvailable[0].insert("*.icns"       , QStringList() << "icn" << "Macintosh OS X icon"                           << "1");
        setupAvailable[0].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[0].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[0].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[0].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
        setupAvailable[0].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
        setupAvailable[0].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
        setupAvailable[0].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
        setupAvailable[0].insert("*.pnm"        , QStringList() << "pbm" << "Portable anymap (pbm, pgm, or ppm)"            << "1");
        setupAvailable[0].insert("*.svg"        , QStringList() << "svg" << "Scalable Vector Graphics"                      << "1");
        setupAvailable[0].insert("*.svgz"       , QStringList() << "svg" << "Scalable Vector Graphics"                      << "1");
        setupAvailable[0].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa Graphic"                      << "1");
        setupAvailable[0].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        setupAvailable[0].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        setupAvailable[0].insert("*.wbmp"       , QStringList() << "wbp" << "Wireless bitmap"                               << "1");
        setupAvailable[0].insert("*.webp"       , QStringList() << "wep" << "Google web image format"                       << "1");
        setupAvailable[0].insert("*.xbm"        , QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
        setupAvailable[0].insert("*.xpm"        , QStringList() << "xpm" << "X Windows system pixmap"                       << "1");

        // KDE
        setupAvailable[1].insert("*.eps"        , QStringList() << "eps" << "Adobe Encapsulated PostScript"                 << "1");
        setupAvailable[1].insert("*.epsf"       , QStringList() << "eps" << "Adobe Encapsulated PostScript"                 << "1");
        setupAvailable[1].insert("*.epsi"       , QStringList() << "eps" << "Adobe Encapsulated PostScript"                 << "1");
        setupAvailable[1].insert("*.exr"        , QStringList() << "exr" << "OpenEXR"                                       << "1");
        setupAvailable[1].insert("*.kra"        , QStringList() << "kra" << "Krita Document"                                << "1");
        setupAvailable[1].insert("*.ora"        , QStringList() << "ora" << "Open Raster Image File"                        << "1");
        setupAvailable[1].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "1");
        setupAvailable[1].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file"           << "1");
        setupAvailable[1].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
        setupAvailable[1].insert("*.ras"        , QStringList() << "ras" << "Sun Graphics"                                  << "1");
        setupAvailable[1].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[1].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[1].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[1].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[1].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa Graphic"                      << "1");
        setupAvailable[1].insert("*.xcf"        , QStringList() << "xcf" << "Gimp format"                                   << "1");

        // Extras
        setupAvailable[2].insert("*.psb"        , QStringList() << "psd" << "Adobe PhotoShop - Makes use of 'libqpsd'"      << "0");
        setupAvailable[2].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop - Makes use of 'libqpsd'"      << "0");
        setupAvailable[2].insert("*.xcf"        , QStringList() << "xcf" << "Gimp format - Makes use of 'xcftoold'"         << "0");

        // GraphicsMagick
        setupAvailable[3].insert("*.art"        , QStringList() << "art" << "PFS: 1st Publisher"                            << "1");
        setupAvailable[3].insert("*.avs"        , QStringList() << "avs" << "AVS X image"                                   << "1");
        setupAvailable[3].insert("*.x"          , QStringList() << "avs" << "AVS X image"                                   << "1");
        setupAvailable[3].insert("*.mbfavs"     , QStringList() << "avs" << "AVS X image"                                   << "1");
        setupAvailable[3].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
        setupAvailable[3].insert("*.rle"        , QStringList() << "bmp" << "Microsoft Windows RLE-compressed bitmap"       << "1");
        setupAvailable[3].insert("*.dib"        , QStringList() << "bmp" << "Microsoft Windows Device-Independent bitmap"   << "1");
        setupAvailable[3].insert("*.cals"       , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.cal"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.ct1"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.ct2"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.ct3"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.nif"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.ct4"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.c4"         , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.cin"        , QStringList() << "cin" << "Kodak Cineon"                                  << "1");
        setupAvailable[3].insert("*.cut"        , QStringList() << "cut" << "DR Halo"                                       << "1");
        setupAvailable[3].insert("*.acr"        , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
        setupAvailable[3].insert("*.dcm"        , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
        setupAvailable[3].insert("*.dicom"      , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
        setupAvailable[3].insert("*.dic"        , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
        setupAvailable[3].insert("*.dpx"        , QStringList() << "dpx" << "Digital Moving Picture Exchange"               << "1");
        setupAvailable[3].insert("*.epdf"       , QStringList() << "pdf" << "Encapsulated Portable Document Format"         << "0");
        setupAvailable[3].insert("*.fig"        , QStringList() << "fig" << "FIG graphics format"                           << "1");
        setupAvailable[3].insert("*.fits"       , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[3].insert("*.fit"        , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[3].insert("*.fts"        , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[3].insert("*.gif"        , QStringList() << "gif" << "CompuServe Graphics Interchange Format"        << "1");
        setupAvailable[3].insert("*.jng"        , QStringList() << "jng" << "JPEG Network Graphics"                         << "1");
        setupAvailable[3].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 JP2 File Format Syntax"              << "1");
        setupAvailable[3].insert("*.jpc"        , QStringList() << "jpc" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[3].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[3].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[3].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[3].insert("*.mat"        , QStringList() << "mat" << "MATLAB image format"                           << "1");
        setupAvailable[3].insert("*.mif"        , QStringList() << "mif" << "Magick image file format"                      << "1");
        setupAvailable[3].insert("*.miff"       , QStringList() << "mif" << "Magick image file format"                      << "1");
        setupAvailable[3].insert("*.mng"        , QStringList() << "mng" << "Multiple-image Network Graphics"               << "1");
        setupAvailable[3].insert("*.mtv"        , QStringList() << "mtv" << "MTV Raytracing image format"                   << "1");
        setupAvailable[3].insert("*.otb"        , QStringList() << "otb" << "On-the-air Bitmap"                             << "1");
        setupAvailable[3].insert("*.p7"         , QStringList() << "p7 " << "Xv's Visual Schnauzer thumbnail format"        << "1");
        setupAvailable[3].insert("*.palm"       , QStringList() << "pal" << "Palm pixmap"                                   << "1");
        setupAvailable[3].insert("*.pam"        , QStringList() << "pam" << "Portable Arbitrary Map format"                 << "1");
        setupAvailable[3].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
        setupAvailable[3].insert("*.pcd"        , QStringList() << "pcd" << "Photo CD"                                      << "1");
        setupAvailable[3].insert("*.pcds"       , QStringList() << "pcd" << "Photo CD"                                      << "1");
        setupAvailable[3].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft IBM PC Paintbrush file"                  << "1");
        setupAvailable[3].insert("*.pdb"        , QStringList() << "pdb" << "Palm Database ImageViewer Format"              << "1");
        setupAvailable[3].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
        setupAvailable[3].insert("*.picon"      , QStringList() << "pio" << "Personal Icon"                << "1");
        setupAvailable[3].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
        setupAvailable[3].insert("*.pnm"        , QStringList() << "pbm" << "Portable pixmap format (pbm, pgm, or ppm)"     << "1");
        setupAvailable[3].insert("*.pict"       , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
        setupAvailable[3].insert("*.pct"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
        setupAvailable[3].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
        setupAvailable[3].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
        setupAvailable[3].insert("*.ptif"       , QStringList() << "pti" << "Pyramid encoded TIFF"                          << "1");
        setupAvailable[3].insert("*.ptiff"      , QStringList() << "pti" << "Pyramid encoded TIFF"                          << "1");
        setupAvailable[3].insert("*.sfw"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
        setupAvailable[3].insert("*.alb"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
        setupAvailable[3].insert("*.pwp"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
        setupAvailable[3].insert("*.pwm"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
        setupAvailable[3].insert("*.rla"        , QStringList() << "rla" << "Wavefront RLA File Format"                     << "1");
        setupAvailable[3].insert("*.rle"        , QStringList() << "rle" << "Utah Run length encoded image file"            << "1");
        setupAvailable[3].insert("*.sgi"        , QStringList() << "sgi" << "Irix RGB image"                                << "1");
        setupAvailable[3].insert("*.bw"         , QStringList() << "sgi" << "Irix RGB image"                                << "1");
        setupAvailable[3].insert("*.rgb"        , QStringList() << "sgi" << "Irix RGB image"                                << "1");
        setupAvailable[3].insert("*.rgba"       , QStringList() << "sgi" << "Irix RGB image"                                << "1");
        setupAvailable[3].insert("*.sun"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.ras"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.rast"       , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.rs"         , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.sr"         , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.scr"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.im1"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.im8"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.im24"       , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.im32"       , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
        setupAvailable[3].insert("*.icb"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
        setupAvailable[3].insert("*.vda"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
        setupAvailable[3].insert("*.vst"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
        setupAvailable[3].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        setupAvailable[3].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        setupAvailable[3].insert("*.tim"        , QStringList() << "tim" << "PSX TIM file"                                  << "1");
        setupAvailable[3].insert("*.vicar"      , QStringList() << "vic" << "VICAR rasterfile format"                       << "1");
        setupAvailable[3].insert("*.vic"        , QStringList() << "vic" << "VICAR rasterfile format"                       << "1");
        setupAvailable[3].insert("*.img"        , QStringList() << "vic" << "VICAR rasterfile format"                       << "1");
        setupAvailable[3].insert("*.viff"       , QStringList() << "vif" << "Khoros Visualization Image File Format"        << "1");
        setupAvailable[3].insert("*.xv"         , QStringList() << "vif" << "Khoros Visualization Image File Format"        << "1");
        setupAvailable[3].insert("*.wbmp"       , QStringList() << "wbm" << "Wireless Bitmap"                               << "1");
        setupAvailable[3].insert("*.wpg"        , QStringList() << "wpg" << "Word Perfect Graphics File"                    << "1");
        setupAvailable[3].insert("*.xbm"        , QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
        setupAvailable[3].insert("*.bm"         , QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
        setupAvailable[3].insert("*.xpm"        , QStringList() << "xpm" << "X Windows system pixmap"                       << "1");
        setupAvailable[3].insert("*.pm"         , QStringList() << "xpm" << "X Windows system pixmap"                       << "1");
        setupAvailable[3].insert("*.xwd"        , QStringList() << "xwd" << "X Windows system window dump"                  << "1");
        // NO TEST IMAGE AVAILABLE FOR THE FOLLOWING FORMATS:
        setupAvailable[3].insert("*.sct"        , QStringList() << "sct" << "Scitex Continuous Tone Picture"                << "0");
        setupAvailable[3].insert("*.ct"         , QStringList() << "sct" << "Scitex Continuous Tone Picture"                << "0");
        setupAvailable[3].insert("*.ch"         , QStringList() << "sct" << "Scitex Continuous Tone Picture"                << "0");
        // THE FOLLOWING FORMATS FAIL ON MY SYSTEM:
        setupAvailable[3].insert("*.hpgl"       , QStringList() << "hpg" << "HP-GL plotter language"                        << "0");
        setupAvailable[3].insert("*.hpg"        , QStringList() << "hpg" << "HP-GL plotter language"                        << "0");
        setupAvailable[3].insert("*.hgl"        , QStringList() << "hpg" << "HP-GL plotter language"                        << "0");
        setupAvailable[3].insert("*.plt"        , QStringList() << "hpg" << "HP-GL plotter language"                        << "0");
        setupAvailable[3].insert("*.ico"        , QStringList() << "ico" << "Microsoft icon"                                << "0");
        setupAvailable[3].insert("*.cgm"        , QStringList() << "cgm" << "Computer Graphics Metafile"                    << "0");
        setupAvailable[3].insert("*.cur"        , QStringList() << "cur" << "Microsoft Cursor Icon"                         << "0");
        setupAvailable[3].insert("*.man"        , QStringList() << "man" << "Unix reference manual pages"                   << "0");
        setupAvailable[3].insert("*.mvg"        , QStringList() << "mtv" << "Magick Vector Graphics"                        << "0");
        setupAvailable[3].insert("*.svg"        , QStringList() << "svg" << "Scalable Vector Graphics"                      << "0");
        setupAvailable[3].insert("*.svgz"       , QStringList() << "svg" << "Scalable Vector Graphics"                      << "0");
        setupAvailable[3].insert("*.ttf"        , QStringList() << "ttf" << "TrueType font file"                            << "0");
        setupAvailable[3].insert("*.txt"        , QStringList() << "txt" << "Raw text file"                                 << "0");
        setupAvailable[3].insert("*.xcf"        , QStringList() << "xcf" << "Gimp XCF"                                      << "0");
        // THE FOLLOWING FORMATS ARE NOT PART OF GRAPHICSMAGICK IN ARCH LINUX (possibly in others too):
        setupAvailable[3].insert("*.fpx"        , QStringList() << "fpx" << "FlashPix Format"                               << "0");
        setupAvailable[3].insert("*.jbig"       , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.jbig2"      , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.jbg"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.jb2"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.bie"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");

        // GraphicsMagick w/ Ghostscript
        setupAvailable[4].insert("*.epi"        , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
        setupAvailable[4].insert("*.epsi"       , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
        setupAvailable[4].insert("*.eps"        , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
        setupAvailable[4].insert("*.epsf"       , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
        setupAvailable[4].insert("*.ept"        , QStringList() << "ept" << "Adobe Encapsulated PostScript Interchange format with TIFF preview" << "0");
        setupAvailable[4].insert("*.pdf"        , QStringList() << "pdf" << "Portable Document Format"                          << "0");
        setupAvailable[4].insert("*.ps"         , QStringList() << "ps " << "Adobe PostScript file"                             << "0");
        setupAvailable[4].insert("*.ps2"        , QStringList() << "ps " << "Adobe Level II PostScript file"                    << "0");
        setupAvailable[4].insert("*.ps3"        , QStringList() << "ps " << "Adobe Level III PostScript file"                   << "0");

        // RAW
        setupAvailable[5].insert("*.3fr"        , QStringList() << "3fr" << "Hasselblad"                << "1");
        setupAvailable[5].insert("*.ari"        , QStringList() << "ari" << "ARRIFLEX"                  << "1");
        setupAvailable[5].insert("*.arw"        , QStringList() << "arw" << "Sony"                      << "1");
        setupAvailable[5].insert("*.srf"        , QStringList() << "srf" << "Sony"                      << "1");
        setupAvailable[5].insert("*.sr2"        , QStringList() << "sr2" << "Sony"                      << "1");
        setupAvailable[5].insert("*.bay"        , QStringList() << "bay" << "Casio"                     << "1");
        setupAvailable[5].insert("*.crw"        , QStringList() << "crw" << "Canon"                     << "1");
        setupAvailable[5].insert("*.crr"        , QStringList() << "crr" << "Canon"                     << "1");
        setupAvailable[5].insert("*.cr2"        , QStringList() << "cr2" << "Canon"                     << "1");
        setupAvailable[5].insert("*.cap"        , QStringList() << "cap" << "Phase_one"                 << "1");
        setupAvailable[5].insert("*.liq"        , QStringList() << "liq" << "Phase_one"                 << "1");
        setupAvailable[5].insert("*.eip"        , QStringList() << "eip" << "Phase_one"                 << "1");
        setupAvailable[5].insert("*.dcs"        , QStringList() << "dcs" << "Kodak"                     << "1");
        setupAvailable[5].insert("*.dcr"        , QStringList() << "dcr" << "Kodak"                     << "1");
        setupAvailable[5].insert("*.drf"        , QStringList() << "drf" << "Kodak"                     << "1");
        setupAvailable[5].insert("*.k25"        , QStringList() << "k25" << "Kodak"                     << "1");
        setupAvailable[5].insert("*.kdc"        , QStringList() << "kdc" << "Kodak"                     << "1");
        setupAvailable[5].insert("*.dng"        , QStringList() << "dng" << "Adobe"                     << "1");
        setupAvailable[5].insert("*.erf"        , QStringList() << "erf" << "Epson"                     << "1");
        setupAvailable[5].insert("*.fff"        , QStringList() << "fff" << "Imacon/Hasselblad raw"     << "1");
        setupAvailable[5].insert("*.mef"        , QStringList() << "mef" << "Mamiya"                    << "1");
        setupAvailable[5].insert("*.mdc"        , QStringList() << "mdc" << "Minolta, Agfa"             << "1");
        setupAvailable[5].insert("*.mos"        , QStringList() << "mos" << "Leaf"                      << "1");
        setupAvailable[5].insert("*.mrw"        , QStringList() << "mrw" << "Minolta, Konica Minolta"   << "1");
        setupAvailable[5].insert("*.nef"        , QStringList() << "nef" << "Nikon"                     << "1");
        setupAvailable[5].insert("*.nrw"        , QStringList() << "nrw" << "Nikon"                     << "1");
        setupAvailable[5].insert("*.orf"        , QStringList() << "orf" << "Olympus"                   << "1");
        setupAvailable[5].insert("*.pef"        , QStringList() << "pef" << "Pentax"                    << "1");
        setupAvailable[5].insert("*.ptx"        , QStringList() << "ptx" << "Pentax"                    << "1");
        setupAvailable[5].insert("*.pxn"        , QStringList() << "pxn" << "Logitech"                  << "1");
        setupAvailable[5].insert("*.r3d"        , QStringList() << "r3d" << "RED Digital Cinema"        << "1");
        setupAvailable[5].insert("*.raf"        , QStringList() << "raf" << "Fuji"                      << "1");
        setupAvailable[5].insert("*.raw"        , QStringList() << "raw" << "Panasonic"                 << "1");
        setupAvailable[5].insert("*.rw2"        , QStringList() << "rw2" << "Panasonic"                 << "1");
        setupAvailable[5].insert("*.raw"        , QStringList() << "raw" << "Leica"                     << "1");
        setupAvailable[5].insert("*.rwl"        , QStringList() << "rwl" << "Leica"                     << "1");
        setupAvailable[5].insert("*.dng"        , QStringList() << "dng" << "Leica"                     << "1");
        setupAvailable[5].insert("*.rwz"        , QStringList() << "rwz" << "Rawzor"                    << "1");
        setupAvailable[5].insert("*.srw"        , QStringList() << "srw" << "Samsung"                   << "1");
        setupAvailable[5].insert("*.x3f"        , QStringList() << "x3f" << "Sigma"                     << "1");

        // DevIL
        setupAvailable[6].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
        setupAvailable[6].insert("*.dds"        , QStringList() << "dds" << "DirectDraw Surface"                            << "1");
        setupAvailable[6].insert("*.exr"        , QStringList() << "exr" << "OpenEXR"                                       << "1");
        setupAvailable[6].insert("*.fits"       , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[6].insert("*.fit"        , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[6].insert("*.ftx"        , QStringList() << "ftx" << "Heavy Metal: FAKK 2"                           << "1");
        setupAvailable[6].insert("*.hdr"        , QStringList() << "hdr" << "Radiance High Dynamic"                         << "1");
        setupAvailable[6].insert("*.icns"       , QStringList() << "icn" << "Macintosh icon"                                << "1");
        setupAvailable[6].insert("*.ico"        , QStringList() << "ico" << "Windows icon/cursor"                           << "1");
        setupAvailable[6].insert("*.cur"        , QStringList() << "ico" << "Windows icon/cursor"                           << "1");
        setupAvailable[6].insert("*.iff"        , QStringList() << "iff" << "Interchange File Format"                       << "1");
        setupAvailable[6].insert("*.gif"        , QStringList() << "gif" << "Graphics Interchange Format"                   << "1");
        setupAvailable[6].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[6].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[6].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[6].insert("*.lbm"        , QStringList() << "lbm" << "Interlaced Bitmap"                             << "1");
        setupAvailable[6].insert("*.pcd"        , QStringList() << "pcd" << "Kodak PhotoCD"                                 << "1");
        setupAvailable[6].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
        setupAvailable[6].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
        setupAvailable[6].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
        setupAvailable[6].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
        setupAvailable[6].insert("*.pnm"        , QStringList() << "pbm" << "Portable pixmap format (pbm, pgm, or ppm)"     << "1");
        setupAvailable[6].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
        setupAvailable[6].insert("*.psp"        , QStringList() << "psp" << "PaintShop Pro"                                 << "1");
        setupAvailable[6].insert("*.raw"        , QStringList() << "raw" << "Raw data"                                      << "1");
        setupAvailable[6].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[6].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[6].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[6].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
        setupAvailable[6].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa Graphic"                      << "1");
        setupAvailable[6].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        setupAvailable[6].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        // no test image available
        setupAvailable[6].insert("*.iwi"        , QStringList() << "iwi" << "Infinity Ward Image"                           << "0");
        setupAvailable[6].insert("*.lif"        , QStringList() << "lif" << "Homeworld texture"                             << "0");
        setupAvailable[6].insert("*.pxr"        , QStringList() << "pxr" << "Pixar"                                         << "0");
        setupAvailable[6].insert("*.rot"        , QStringList() << "rot" << "Homeworld 2 Texture"                           << "0");
        setupAvailable[6].insert("*.texture"    , QStringList() << "tex" << "Creative Assembly Texture"                     << "0");
        setupAvailable[6].insert("*.tpl"        , QStringList() << "tpl" << "Gamecube Texture"                              << "0");
        setupAvailable[6].insert("*.utx"        , QStringList() << "utx" << "Unreal Texture"                                << "0");
        setupAvailable[6].insert("*.wal"        , QStringList() << "wal" << "Quake2 Texture"                                << "0");
        setupAvailable[6].insert("*.vtf"        , QStringList() << "vtf" << "Valve Texture Format"                          << "0");
        // fails on my system
        setupAvailable[6].insert("*.cut"        , QStringList() << "cut" << "DR Halo"                                       << "0");
        setupAvailable[6].insert("*.dcx"        , QStringList() << "dcx" << "Multi-PCX"                                     << "0");
        setupAvailable[6].insert("*.dcm"        , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "0");
        setupAvailable[6].insert("*.dicom"      , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "0");
        setupAvailable[6].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 JP2 File Format Syntax"              << "0");
        setupAvailable[6].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "0");
        setupAvailable[6].insert("*.pic"        , QStringList() << "pic" << "Softimage PIC"                                 << "0");
        setupAvailable[6].insert("*.pix"        , QStringList() << "pix" << "Alias | Wavefront"                             << "0");
        setupAvailable[6].insert("*.wdp"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");
        setupAvailable[6].insert("*.hdp"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");

        // FreeImage
//        setupAvailable[7].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
//        setupAvailable[7].insert("*.jpg", QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format" << "1");
//        setupAvailable[7].insert("*.tga", QStringList() << "tga" << "Truevision Targa Graphic" << "1");
//        setupAvailable[7].insert("*.png", QStringList() << "png" << "Portable Network Graphics" << "1");


        availableFileformats = new QVariantList[categories.length()];
        availableFileformatsWithDescription = new QVariantList[categories.length()];
        enabledFileformats = new QStringList[categories.length()];
        defaultEnabledFileformats = new QStringList[categories.length()];

        composeAvailableFormats();
        composeEnabledFormats();

        saveTimer = new QTimer;
        saveTimer->setSingleShot(true);
        saveTimer->setInterval(500);
        connect(saveTimer, &QTimer::timeout, this, &ImageFormats::saveEnabledFormats);

        connect(this, SIGNAL(enabledFileformatsQtChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsKDEChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsExtrasChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsGmChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsGmGhostscriptChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsRAWChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsDevILChanged(QStringList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsFreeImageChanged(QStringList)), saveTimer, SLOT(start()));

    }

    void setEnabledFileformats(QString cat, QStringList val) {
        if(cat == "qt")
            setEnabledFileformatsQt(val);
        else if(cat == "kde")
            setEnabledFileformatsKDE(val);
        else if(cat == "extras")
            setEnabledFileformatsExtras(val);
        else if(cat == "gm")
            setEnabledFileformatsGm(val);
        else if(cat == "gmghostscript")
            setEnabledFileformatsGmGhostscript(val);
        else if(cat == "raw")
            setEnabledFileformatsRAW(val);
        else if(cat == "devil")
            setEnabledFileformatsDevIL(val);
        else if(cat == "freeimage")
            setEnabledFileformatsFreeImage(val);
    }

    // All possibly available file formats for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsQt() { return availableFileformats[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsKDE() { return availableFileformats[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsExtras() { return availableFileformats[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGm() { return availableFileformats[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGmGhostscript() { return availableFileformats[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsRAW() { return availableFileformats[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsDevIL() { return availableFileformats[categories.indexOf("devil")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsFreeImage() { return availableFileformats[categories.indexOf("freeimage")]; }

    // All possibly available file formats INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionQt() { return availableFileformatsWithDescription[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionKDE() { return availableFileformatsWithDescription[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionExtras() { return availableFileformatsWithDescription[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGm() { return availableFileformatsWithDescription[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGmGhostscript() { return availableFileformatsWithDescription[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionRAW() { return availableFileformatsWithDescription[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionDevIL() { return availableFileformatsWithDescription[categories.indexOf("devil")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionFreeImage() { return availableFileformatsWithDescription[categories.indexOf("freeimage")]; }

    // All currently enabled file formats for ...
    // ... Qt
    Q_PROPERTY(QStringList enabledFileformatsQt READ getEnabledFileformatsQt WRITE setEnabledFileformatsQt NOTIFY enabledFileformatsQtChanged)
    QStringList getEnabledFileformatsQt() { return enabledFileformats[categories.indexOf("qt")]; }
    void setEnabledFileformatsQt(QStringList val) { enabledFileformats[categories.indexOf("qt")] = val; emit enabledFileformatsQtChanged(val); }
    // ... KDE
    Q_PROPERTY(QStringList enabledFileformatsKDE READ getEnabledFileformatsKDE WRITE setEnabledFileformatsKDE NOTIFY enabledFileformatsKDEChanged)
    QStringList getEnabledFileformatsKDE() { return enabledFileformats[categories.indexOf("kde")]; }
    void setEnabledFileformatsKDE(QStringList val) { enabledFileformats[categories.indexOf("kde")] = val; emit enabledFileformatsKDEChanged(val); }
    // ... Extras
    Q_PROPERTY(QStringList enabledFileformatsExtras READ getEnabledFileformatsExtras WRITE setEnabledFileformatsExtras NOTIFY enabledFileformatsExtrasChanged)
    QStringList getEnabledFileformatsExtras() { return enabledFileformats[categories.indexOf("extras")]; }
    void setEnabledFileformatsExtras(QStringList val) { enabledFileformats[categories.indexOf("extras")] = val; emit enabledFileformatsExtrasChanged(val); }
    // ... GraphicsMagick
    Q_PROPERTY(QStringList enabledFileformatsGm READ getEnabledFileformatsGm WRITE setEnabledFileformatsGm NOTIFY enabledFileformatsGmChanged)
    QStringList getEnabledFileformatsGm() { return enabledFileformats[categories.indexOf("gm")]; }
    void setEnabledFileformatsGm(QStringList val) { enabledFileformats[categories.indexOf("gm")] = val; emit enabledFileformatsGmChanged(val); }
    // ... GraphicsMagick w/ Ghostscript
    Q_PROPERTY(QStringList enabledFileformatsGmGhostscript READ getEnabledFileformatsGmGhostscript WRITE setEnabledFileformatsGmGhostscript NOTIFY enabledFileformatsGmGhostscriptChanged)
    QStringList getEnabledFileformatsGmGhostscript() { return enabledFileformats[categories.indexOf("gmghostscript")]; }
    void setEnabledFileformatsGmGhostscript(QStringList val) { enabledFileformats[categories.indexOf("gmghostscript")] = val; emit enabledFileformatsGmGhostscriptChanged(val); }
    // ... RAW
    Q_PROPERTY(QStringList enabledFileformatsRAW READ getEnabledFileformatsRAW WRITE setEnabledFileformatsRAW NOTIFY enabledFileformatsRAWChanged)
    QStringList getEnabledFileformatsRAW() { return enabledFileformats[categories.indexOf("raw")]; }
    void setEnabledFileformatsRAW(QStringList val) { enabledFileformats[categories.indexOf("raw")] = val; emit enabledFileformatsRAWChanged(val); }
    // ... DevIL
    Q_PROPERTY(QStringList enabledFileformatsDevIL READ getEnabledFileformatsDevIL WRITE setEnabledFileformatsDevIL NOTIFY enabledFileformatsDevILChanged)
    QStringList getEnabledFileformatsDevIL() { return enabledFileformats[categories.indexOf("devil")]; }
    void setEnabledFileformatsDevIL(QStringList val) { enabledFileformats[categories.indexOf("devil")] = val; emit enabledFileformatsDevILChanged(val); }
    // ... FreeImage
    Q_PROPERTY(QStringList enabledFileformatsFreeImage READ getEnabledFileformatsFreeImage WRITE setEnabledFileformatsFreeImage NOTIFY enabledFileformatsFreeImageChanged)
    QStringList getEnabledFileformatsFreeImage() { return enabledFileformats[categories.indexOf("freeimage")]; }
    void setEnabledFileformatsFreeImage(QStringList val) { enabledFileformats[categories.indexOf("freeimage")] = val; emit enabledFileformatsFreeImageChanged(val); }

    Q_INVOKABLE void setDefaultFormatsQt() { setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]); }
    Q_INVOKABLE void setDefaultFormatsKDE() { setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]); }
    Q_INVOKABLE void setDefaultFormatsExtras() { setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]); }
    Q_INVOKABLE void setDefaultFormatsGm() { setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]); }
    Q_INVOKABLE void setDefaultFormatsGmGhostscript() { setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]); }
    Q_INVOKABLE void setDefaultFormatsRAW() { setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]); }
    Q_INVOKABLE void setDefaultFormatsDevIL() { setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]); }
    Q_INVOKABLE void setDefaultFormatsFreeImage() { setEnabledFileformatsFreeImage(defaultEnabledFileformats[categories.indexOf("freeimage")]); }

    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultFileformats() {
        setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
        setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]);
        setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]);
        setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]);
        setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]);
        setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]);
        setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]);
        setEnabledFileformatsFreeImage(defaultEnabledFileformats[categories.indexOf("freeimage")]);
    }

    Q_INVOKABLE QStringList getAllEnabledFileformats() {
        QStringList allFormats;
        for(int i = 0; i < categories.length(); ++i) {
            foreach(QVariant entry, enabledFileformats[i])
                allFormats.append(entry.toString());
        }
        return allFormats;
    }

signals:
    void enabledFileformatsQtChanged(QStringList val);
    void enabledFileformatsKDEChanged(QStringList val);
    void enabledFileformatsExtrasChanged(QStringList val);
    void enabledFileformatsGmChanged(QStringList val);
    void enabledFileformatsGmGhostscriptChanged(QStringList val);
    void enabledFileformatsRAWChanged(QStringList val);
    void enabledFileformatsDevILChanged(QStringList val);
    void enabledFileformatsFreeImageChanged(QStringList val);

    /****************************************************************************************/
    /****************************************************************************************/
    /****** Anything below here is agnostic to how many and what categories there are *******/
    /*********** As long as everything above is adjusted properly, that is enough ***********/
    /****************************************************************************************/
    /****************************************************************************************/

private:

    // This is only used for entering which file endings are available, the name of the image and whether it is enabled by default
    QMap<QString, QStringList> *setupAvailable;

    QStringList categories;
    QStringList formatsfiles;

    // These are accessible from QML and hold the set info about the file endings
    QVariantList *availableFileformats;
    QVariantList *availableFileformatsWithDescription;
    QStringList *enabledFileformats;

    // This is not accessible from outside. They are used when, e.g., the respective disabled fileformats file doesn't exist or when the settings are reset.
    QStringList *defaultEnabledFileformats;

    QTimer *saveTimer;

    // Called at setup, these do not change during runtime
    void composeAvailableFormats() {

        for(int i = 0; i < categories.length(); ++i) {

            QString cat = categories.at(i);

            // iterate over all file formats
            QMap<QString, QStringList>::const_iterator val = setupAvailable[categories.indexOf(cat)].constBegin();
            while(val != setupAvailable[categories.indexOf(cat)].constEnd()) {

                // Compose data into their respective sub arrays for easier handling later-on
                availableFileformats[categories.indexOf(cat)].append(val.key());
                availableFileformatsWithDescription[categories.indexOf(cat)].append(QStringList() << val.key() << val.value().at(1) << val.value().at(0));
                if(val.value().at(2) == "1") defaultEnabledFileformats[categories.indexOf(cat)].append(val.key());

                ++val;

            }

        }

    }

    // Read the currently disabled file formats from file (and thus compose the list of currently enabled formats)
    void composeEnabledFormats() {

        for(int i = 0; i < categories.length(); ++i) {

            QString cat = categories.at(i);

            // This is the file with disabled formats
            QFile disabledfile(formatsfiles.at(i));

            // If file doesn't exist, we use the default set of enabled formats
            if(!disabledfile.exists()) {
                LOG << CURDATE << "ImageFormats::composeEnabledFormats() :: NOTE: Disabled " << cat.toStdString() << " formats file doesn't exist. Setting default entries..." << NL;
                setEnabledFileformats(cat, defaultEnabledFileformats[categories.indexOf(cat)]);
                return;
            }

            // If we can't open the file for reading, we also use the default set of enabled formats
            if(!disabledfile.open(QIODevice::ReadOnly)) {
                LOG << CURDATE << "ImageFormats::composeEnabledFormats() :: ERROR: Unable to open disabled " << cat.toStdString() << " formats for reading..." << NL;
                setEnabledFileformats(cat, defaultEnabledFileformats[categories.indexOf(cat)]);
                return;
            }

            // These will hold the formats that are enabled
            QStringList setTheseAsEnabled;

            // Read disabled formats and split into each line
            QTextStream in(&disabledfile);
            QStringList alldisabled = in.readAll().split("\n", QString::SkipEmptyParts);


            // Loop over each item of available formats
            foreach(QVariant item, availableFileformats[categories.indexOf(cat)]) {

                // The current available format
                QString avail = item.toString();

                // If format is not disabled, add to list of enabled formats
                if(!alldisabled.contains(avail))
                    setTheseAsEnabled.append(avail);

            }

            // Set enabled formats to file
            setEnabledFileformats(cat, setTheseAsEnabled);

            // close file...
            disabledfile.close();

        }

    }

private slots:

    // Save Qt file formats
    void saveEnabledFormats() {

        for(int i = 0; i < categories.length(); ++i) {

            QString cat = categories.at(i);

            // Compose list of disabled formats
            QString disabled = "";
            foreach(QVariant avail, availableFileformats[categories.indexOf(cat)]) {
                if(!enabledFileformats[categories.indexOf(cat)].contains(avail.toString()))
                    disabled += avail.toString()+"\n";
            }

            // Access and open disabled formats file for writing
            QFile file(formatsfiles.at(i));
            if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
                LOG << CURDATE << "ImageFormats::saveEnabledFormats() :: ERROR: Unable to open disabled " << cat.toStdString() << " formats for writing/truncating..." << NL;
                return;
            }

            // Write disabled formats
            QTextStream out(&file);
            out << disabled;

            // close file
            file.close();

        }

    }


};


#endif // IMAGEFORMATS_H
