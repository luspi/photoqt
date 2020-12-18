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

#include "imageformats.h"

PQImageFormats::PQImageFormats() {

    categories << "qt" << "xcftools" << "poppler" << "graphicsmagick" << "imagemagick"
               << "raw" << "devil" << "freeimage" << "archive" << "video";

    setupAvailable = new QMap<QString, QStringList>[categories.length()];

    QList<QByteArray> imageReaderSup = QImageReader::supportedImageFormats();

    /************************************************************/
    /************************************************************/
    // Qt (incl. plugins, like qt5-imageformats, KDE, libqpsd)

    if(imageReaderSup.contains("bmp"))
        setupAvailable[0].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
    if(imageReaderSup.contains("gif"))
        setupAvailable[0].insert("*.gif"        , QStringList() << "gif" << "CompuServe Graphics Interchange Format"        << "1");
    if(imageReaderSup.contains("jp2")) {
        setupAvailable[0].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.jpc"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.j2k"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.jpeg2000"   , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
        setupAvailable[0].insert("*.jpx"        , QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax"                  << "1");
    }
    if(imageReaderSup.contains("mng"))
        setupAvailable[0].insert("*.mng"        , QStringList() << "mng" << "Multiple-image Network Graphics"               << "1");
    if(imageReaderSup.contains("ico"))
        setupAvailable[0].insert("*.ico"        , QStringList() << "ico" << "Microsoft icon"                                << "1");
    if(imageReaderSup.contains("cur"))
        setupAvailable[0].insert("*.cur"        , QStringList() << "ico" << "Microsoft icon"                                << "1");
    if(imageReaderSup.contains("icns"))
        setupAvailable[0].insert("*.icns"       , QStringList() << "icn" << "Macintosh OS X icon"                           << "1");
    if(imageReaderSup.contains("jpeg") || imageReaderSup.contains("jpg")) {
        setupAvailable[0].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[0].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
        setupAvailable[0].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    }
    if(imageReaderSup.contains("png"))
        setupAvailable[0].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
    if(imageReaderSup.contains("pbm"))
        setupAvailable[0].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
    if(imageReaderSup.contains("pgm"))
        setupAvailable[0].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
    if(imageReaderSup.contains("ppm"))
        setupAvailable[0].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
    if(imageReaderSup.contains("pbm") || imageReaderSup.contains("pgm") || imageReaderSup.contains("ppm"))
        setupAvailable[0].insert("*.pnm"        , QStringList() << "pbm" << "Portable anymap (pbm, pgm, or ppm)"            << "1");
    if(imageReaderSup.contains("svg") || imageReaderSup.contains("svgz")) {
        setupAvailable[0].insert("*.svg"        , QStringList() << "svg" << "Scalable Vector Graphics"                      << "1");
        setupAvailable[0].insert("*.svgz"       , QStringList() << "svg" << "Scalable Vector Graphics"                      << "1");
    }
    if(imageReaderSup.contains("tga"))
        setupAvailable[0].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
    if(imageReaderSup.contains("tif") || imageReaderSup.contains("tiff")) {
        setupAvailable[0].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
        setupAvailable[0].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    }
    if(imageReaderSup.contains("wbmp"))
        setupAvailable[0].insert("*.wbmp"       , QStringList() << "wbp" << "Wireless Bitmap"                               << "1");
    if(imageReaderSup.contains("xbm"))
        setupAvailable[0].insert("*.xbm"        , QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
    if(imageReaderSup.contains("xpm"))
        setupAvailable[0].insert("*.xpm"        , QStringList() << "xpm" << "X Windows system pixmap"                       << "1");
    if(imageReaderSup.contains("eps") || imageReaderSup.contains("epsf") || imageReaderSup.contains("epsi")) {
        setupAvailable[0].insert("*.eps"        , QStringList() << "eps" << "Adobe Encapsulated PostScript"                 << "1");
        setupAvailable[0].insert("*.epsf"       , QStringList() << "eps" << "Adobe Encapsulated PostScript"                 << "1");
        setupAvailable[0].insert("*.epsi"       , QStringList() << "eps" << "Adobe Encapsulated PostScript"                 << "1");
    }
    if(imageReaderSup.contains("exr"))
        setupAvailable[0].insert("*.exr"        , QStringList() << "exr" << "OpenEXR"                                       << "1");
    if(imageReaderSup.contains("ora"))
        setupAvailable[0].insert("*.ora"        , QStringList() << "ora" << "Open Raster Image File"                        << "1");
    if(imageReaderSup.contains("pcx"))
        setupAvailable[0].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "1");
    if(imageReaderSup.contains("psd"))
        setupAvailable[0].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
    if(imageReaderSup.contains("psb"))
        setupAvailable[0].insert("*.psb"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
    if(imageReaderSup.contains("bw"))
        setupAvailable[0].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    if(imageReaderSup.contains("rgb"))
        setupAvailable[0].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    if(imageReaderSup.contains("rgba"))
        setupAvailable[0].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    if(imageReaderSup.contains("sgi"))
        setupAvailable[0].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    if(imageReaderSup.contains("xcf"))
        setupAvailable[0].insert("*.xcf"        , QStringList() << "xcf" << "Gimp XCF"                                      << "1");
#ifndef FREEIMAGE
    // CAUSES CRASH when FreeImage is enabled:
    if(imageReaderSup.contains("webp"))
        setupAvailable[0].insert("*.webp"       , QStringList() << "wep" << "Google web image format"                       << "1");
#endif
    // FAILS TO LOAD test image:
    if(imageReaderSup.contains("kra"))
        setupAvailable[0].insert("*.kra"        , QStringList() << "kra" << "Krita Document"                                << "1");
    if(imageReaderSup.contains("pic"))
        setupAvailable[0].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file"           << "0");
    if(imageReaderSup.contains("ras"))
        setupAvailable[0].insert("*.ras"        , QStringList() << "ras" << "Sun Graphics"                                  << "0");
    if(imageReaderSup.contains("avif"))
        setupAvailable[0].insert("*.avif"       , QStringList() << "avif" << "AV1 Image File Format (AVIF)"                 << "1");
    if(imageReaderSup.contains("avifs"))
        setupAvailable[0].insert("*.avifs"      , QStringList() << "avif" << "AV1F image sequence"                          << "1");


    /************************************************************/
    /************************************************************/
    // xcftools
    setupAvailable[1].insert("*.xcf"        , QStringList() << "xcf" << "Gimp XCF - Makes use of 'xcftools'"                << "0");

    /************************************************************/
    /************************************************************/
    // poppler
    setupAvailable[2].insert("*.pdf"        , QStringList() << "pdf" << "Portable Document Format - Makes use of 'poppler'"              << "1");
    setupAvailable[2].insert("*.epdf"       , QStringList() << "pdf" << "Encapsulated Portable Document Format - Makes use of 'poppler'" << "1");

    /************************************************************/
    /************************************************************/
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
    setupAvailable[3].insert("*.g3"         , QStringList() << "fax" << "Group 3 FAX"                                   << "1");
    setupAvailable[3].insert("*.fax"        , QStringList() << "fax" << "Group 3 FAX"                                   << "1");
    setupAvailable[3].insert("*.gp3"        , QStringList() << "fax" << "Group 3 FAX"                                   << "1");
    setupAvailable[3].insert("*.cg3"        , QStringList() << "fax" << "Group 3 FAX"                                   << "1");
    setupAvailable[3].insert("*.g4"         , QStringList() << "fax" << "Group 4 FAX"                                   << "1");
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
    setupAvailable[3].insert("*.pict"       , QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file"          << "1");
    setupAvailable[3].insert("*.pct"        , QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file"          << "1");
    setupAvailable[3].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file"          << "1");
    setupAvailable[3].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
    setupAvailable[3].insert("*.ptif"       , QStringList() << "pti" << "Pyramid encoded TIFF"                          << "1");
    setupAvailable[3].insert("*.ptiff"      , QStringList() << "pti" << "Pyramid encoded TIFF"                          << "1");
    setupAvailable[3].insert("*.sfw"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
    setupAvailable[3].insert("*.alb"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
    setupAvailable[3].insert("*.pwp"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
    setupAvailable[3].insert("*.pwm"        , QStringList() << "pwp" << "Seattle File Works image"                      << "1");
    setupAvailable[3].insert("*.pix"        , QStringList() << "pix" << "Alias/Wavefront RLE image format"              << "1");
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
    setupAvailable[3].insert("*.webp"       , QStringList() << "web" << "Google web image format"                       << "1");
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
    setupAvailable[3].insert("*.dcx"        , QStringList() << "dcx" << "ZSoft IBM PC multi-page Paintbrush image"      << "0");
    setupAvailable[3].insert("*.fig"        , QStringList() << "fig" << "FIG graphics format"                           << "0");
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
    setupAvailable[3].insert("*.jbg"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
    setupAvailable[3].insert("*.bie"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
    /************************************************************/
    /************************************************************/
    // GraphicsMagick w/ Ghostscript
    setupAvailable[3].insert("*.epi"        , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
    setupAvailable[3].insert("*.epsi"       , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
    setupAvailable[3].insert("*.eps"        , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
    setupAvailable[3].insert("*.epsf"       , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
    setupAvailable[3].insert("*.ept"        , QStringList() << "ept" << "Adobe Encapsulated PostScript Interchange format with TIFF preview" << "0");
    setupAvailable[3].insert("*.epdf"       , QStringList() << "pdf" << "Encapsulated Portable Document Format"             << "0");
    setupAvailable[3].insert("*.pdf"        , QStringList() << "pdf" << "Portable Document Format"                          << "0");
    setupAvailable[3].insert("*.ps"         , QStringList() << "ps " << "Adobe PostScript file"                             << "0");
    setupAvailable[3].insert("*.ps2"        , QStringList() << "ps " << "Adobe Level II PostScript file"                    << "0");
    setupAvailable[3].insert("*.ps3"        , QStringList() << "ps " << "Adobe Level III PostScript file"                   << "0");


    /************************************************************/
    /************************************************************/
    // ImageMagick
    // working
    setupAvailable[4].insert("*.aai", QStringList() << "aai" << "AAI Dune image" << "1");
    setupAvailable[4].insert("*.art", QStringList() << "art" << "PFS: 1st Publisher" << "1");
    setupAvailable[4].insert("*.bmp", QStringList() << "bmp" << "Microsoft Windows bitmap" << "1");
    setupAvailable[4].insert("*.rle", QStringList() << "bmp" << "Microsoft Windows RLE-compressed bitmap" << "1");
    setupAvailable[4].insert("*.dib", QStringList() << "bmp" << "Microsoft Windows Device-Independent bitmap" << "1");
    setupAvailable[4].insert("*.cals", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.cal", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.ct1", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.ct2", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.ct3", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.nif", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.ct4", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.c4", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.ras", QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image" << "1");
    setupAvailable[4].insert("*.cin", QStringList() << "cin" << "Kodak Cineon" << "1");
    setupAvailable[4].insert("*.cr2", QStringList() << "crw" << "Canon Digital Camera Raw Image Format" << "1");
    setupAvailable[4].insert("*.crw", QStringList() << "crw" << "Canon Digital Camera Raw Image Format" << "1");
    setupAvailable[4].insert("*.cur", QStringList() << "cur" << "Microsoft Cursor Icon" << "1");
    setupAvailable[4].insert("*.cut", QStringList() << "cut" << "DR Halo" << "1");
    setupAvailable[4].insert("*.dcm", QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
    setupAvailable[4].insert("*.dicom", QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
    setupAvailable[4].insert("*.dic", QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "1");
    setupAvailable[4].insert("*.dcx", QStringList() << "dcx" << "ZSoft IBM PC multi-page Paintbrush image" << "1");
    setupAvailable[4].insert("*.dpx", QStringList() << "dpx" << "Digital Moving Picture Exchange" << "1");
    setupAvailable[4].insert("*.exr", QStringList() << "exr" << "OpenEXR" << "1");
    setupAvailable[4].insert("*.ff", QStringList() << "ffe" << "farbfeld" << "1");
    setupAvailable[4].insert("*.g3", QStringList() << "fax" << "Group 3 FAX" << "1");
    setupAvailable[4].insert("*.fax", QStringList() << "fax" << "Group 3 FAX" << "1");
    setupAvailable[4].insert("*.gp3", QStringList() << "fax" << "Group 3 FAX" << "1");
    setupAvailable[4].insert("*.cg3", QStringList() << "fax" << "Group 3 FAX" << "1");
    setupAvailable[4].insert("*.g4", QStringList() << "fax" << "Group 4 FAX" << "1");
    setupAvailable[4].insert("*.fits", QStringList() << "fit" << "Flexible Image Transport System" << "1");
    setupAvailable[4].insert("*.fit", QStringList() << "fit" << "Flexible Image Transport System" << "1");
    setupAvailable[4].insert("*.fts", QStringList() << "fit" << "Flexible Image Transport System" << "1");
    setupAvailable[4].insert("*.gif", QStringList() << "gif" << "CompuServe Graphics Interchange Format" << "1");
    setupAvailable[4].insert("*.hdr", QStringList() << "hdr" << "Radiance RGBE image format" << "1");
    setupAvailable[4].insert("*.rgbe", QStringList() << "hdr" << "Radiance RGBE image format" << "1");
    setupAvailable[4].insert("*.xyze", QStringList() << "hdr" << "Radiance RGBE image format" << "1");
    setupAvailable[4].insert("*.pic", QStringList() << "hdr" << "Radiance RGBE image format" << "1");
    setupAvailable[4].insert("*.rad", QStringList() << "hdr" << "Radiance RGBE image format" << "1");
    setupAvailable[4].insert("*.heic", QStringList() << "hei" << "Apple High efficiency Image Format" << "1");
    setupAvailable[4].insert("*.heif", QStringList() << "hei" << "Apple High efficiency Image Format" << "1");
    setupAvailable[4].insert("*.hrz", QStringList() << "hrz" << "Slow-scan television" << "1");
    setupAvailable[4].insert("*.ico", QStringList() << "ico" << "Microsoft icon" << "1");
    setupAvailable[4].insert("*.jbig", QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "1");
    setupAvailable[4].insert("*.jbg", QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "1");
    setupAvailable[4].insert("*.bie", QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "1");
    setupAvailable[4].insert("*.jng", QStringList() << "jng" << "JPEG Network Graphics" << "1");
    setupAvailable[4].insert("*.jp2", QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax" << "1");
    setupAvailable[4].insert("*.jpc", QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax" << "1");
    setupAvailable[4].insert("*.j2k", QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax" << "1");
    setupAvailable[4].insert("*.jpeg2000", QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax" << "1");
    setupAvailable[4].insert("*.jpx", QStringList() << "jp2" << "JPEG-2000 Code Stream Syntax" << "1");
    setupAvailable[4].insert("*.mif", QStringList() << "mif" << "Magick image file format" << "1");
    setupAvailable[4].insert("*.miff", QStringList() << "mif" << "Magick image file format" << "1");
    setupAvailable[4].insert("*.mpc", QStringList() << "mpc" << "Magick Persistent Cache image file format" << "1");
    setupAvailable[4].insert("*.mrw", QStringList() << "mrw" << "Sony (Minolta) Raw Image File" << "1");
    setupAvailable[4].insert("*.msl", QStringList() << "msl" << "Magick Scripting Language" << "1");
    setupAvailable[4].insert("*.mtv", QStringList() << "mtv" << "MTV Raytracing image format" << "1");
    setupAvailable[4].insert("*.pic", QStringList() << "mtv" << "MTV Raytracing image format" << "1");
    setupAvailable[4].insert("*.mvg", QStringList() << "mvg" << "Magick Vector Graphics" << "1");
    setupAvailable[4].insert("*.mvg", QStringList() << "mvg" << "Magick Vector Graphics" << "1");
    setupAvailable[4].insert("*.orf", QStringList() << "orf" << "Olympus Digital Camera Raw Image File" << "1");
    setupAvailable[4].insert("*.otb", QStringList() << "otb" << "On-the-air Bitmap" << "1");
    setupAvailable[4].insert("*.palm", QStringList() << "pal" << "Palm pixmap" << "1");
    setupAvailable[4].insert("*.pbm", QStringList() << "pbm" << "Portable bitmap format (black and white)" << "1");
    setupAvailable[4].insert("*.pcd", QStringList() << "pcd" << "Photo CD" << "1");
    setupAvailable[4].insert("*.pcds", QStringList() << "pcd" << "Photo CD" << "1");
    setupAvailable[4].insert("*.pcx", QStringList() << "pcx" << "ZSoft IBM PC Paintbrush file" << "1");
    setupAvailable[4].insert("*.pdb", QStringList() << "pdb" << "Palm Database ImageViewer Format" << "1");
    setupAvailable[4].insert("*.pfm", QStringList() << "pfm" << "Portable Float Map" << "1");
    setupAvailable[4].insert("*.pgm", QStringList() << "pbm" << "Portable graymap format (gray scale)" << "1");
    setupAvailable[4].insert("*.ppm", QStringList() << "pbm" << "Portable pixmap format (color)" << "1");
    setupAvailable[4].insert("*.pnm", QStringList() << "pbm" << "Portable pixmap format (pbm, pgm, or ppm)" << "1");
    setupAvailable[4].insert("*.picon", QStringList() << "pio" << "Personal Icon" << "1");
    setupAvailable[4].insert("*.pict", QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file" << "1");
    setupAvailable[4].insert("*.pct", QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file" << "1");
    setupAvailable[4].insert("*.pic", QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file" << "1");
    setupAvailable[4].insert("*.png", QStringList() << "png" << "Portable Network Graphics" << "1");
    setupAvailable[4].insert("*.psd", QStringList() << "psd" << "Adobe Photoshop bitmap file" << "1");
    setupAvailable[4].insert("*.ptif", QStringList() << "pti" << "Pyramid encoded TIFF" << "1");
    setupAvailable[4].insert("*.ptiff", QStringList() << "pti" << "Pyramid encoded TIFF" << "1");
    setupAvailable[4].insert("*.sfw", QStringList() << "pwp" << "Seattle File Works image" << "1");
    setupAvailable[4].insert("*.alb", QStringList() << "pwp" << "Seattle File Works image" << "1");
    setupAvailable[4].insert("*.pwp", QStringList() << "pwp" << "Seattle File Works image" << "1");
    setupAvailable[4].insert("*.pwm", QStringList() << "pwp" << "Seattle File Works image" << "1");
    setupAvailable[4].insert("*.raf", QStringList() << "fuj" << "Fuji CCD-RAW Graphic File" << "1");
    setupAvailable[4].insert("*.sgi", QStringList() << "sgi" << "Irix RGB image" << "1");
    setupAvailable[4].insert("*.bw", QStringList() << "sgi" << "Irix RGB image" << "1");
    setupAvailable[4].insert("*.rgb", QStringList() << "sgi" << "Irix RGB image" << "1");
    setupAvailable[4].insert("*.rgba", QStringList() << "sgi" << "Irix RGB image" << "1");
    setupAvailable[4].insert("*.rla", QStringList() << "rla" << "Alias/Wavefront image format" << "1");
    setupAvailable[4].insert("*.rle", QStringList() << "rle" << "Utah Run length encoded image file" << "1");
    setupAvailable[4].insert("*.sun", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.ras", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.rast", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.rs", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.sr", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.scr", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.im1", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.im8", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.im24", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.im32", QStringList() << "sun" << "SUN Rasterfile" << "1");
    setupAvailable[4].insert("*.svg", QStringList() << "svg" << "Scalable Vector Graphics" << "1");
    setupAvailable[4].insert("*.tif", QStringList() << "tif" << "Tagged Image File Format" << "1");
    setupAvailable[4].insert("*.tiff", QStringList() << "tif" << "Tagged Image File Format" << "1");
    setupAvailable[4].insert("*.tim", QStringList() << "tim" << "PSX TIM file" << "1");
    setupAvailable[4].insert("*.ttf", QStringList() << "ttf" << "TrueType font file" << "1");
    setupAvailable[4].insert("*.vicar", QStringList() << "vic" << "VICAR rasterfile format" << "1");
    setupAvailable[4].insert("*.vic", QStringList() << "vic" << "VICAR rasterfile format" << "1");
    setupAvailable[4].insert("*.img", QStringList() << "vic" << "VICAR rasterfile format" << "1");
    setupAvailable[4].insert("*.xv", QStringList() << "vif" << "Khoros Visualization Image File Format" << "1");
    setupAvailable[4].insert("*.viff", QStringList() << "vif" << "Khoros Visualization Image File Format" << "1");
    setupAvailable[4].insert("*.wbmp", QStringList() << "wbm" << "Wireless Bitmap" << "1");
    setupAvailable[4].insert("*.webp", QStringList() << "web" << "Weppy image format" << "1");
    setupAvailable[4].insert("*.wmf", QStringList() << "wmf" << "Windows Metafile" << "1");
    setupAvailable[4].insert("*.wmz", QStringList() << "wmf" << "Windows Metafile" << "1");
    setupAvailable[4].insert("*.apm", QStringList() << "wmf" << "Windows Metafile" << "1");
    setupAvailable[4].insert("*.wpg", QStringList() << "wpg" << "Word Perfect Graphics File" << "1");
    setupAvailable[4].insert("*.xbm", QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
    setupAvailable[4].insert("*.bm", QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
    setupAvailable[4].insert("*.xcf", QStringList() << "xcf" << "Gimp XCF" << "1");
    setupAvailable[4].insert("*.xpm", QStringList() << "xpm" << "X Windows system pixmap" << "1");
    setupAvailable[4].insert("*.pm", QStringList() << "xpm" << "X Windows system pixmap" << "1");
    setupAvailable[4].insert("*.xwd", QStringList() << "xwd" << "X Windows system window dump" << "1");
    // working, requires libbgm
    setupAvailable[4].insert("*.bpg", QStringList() << "bpg" << "Better Portable Graphics" << "1");
    // NO TEST IMAGE AVAILABLE FOR THE FOLLOWING FORMATS:
    setupAvailable[4].insert("*.fl32", QStringList() << "f32" << "FilmLight floating point image format" << "0");
    setupAvailable[4].insert("*.rgf", QStringList() << "rgf" << "LEGO Mindstorms EV3 Robot Graphics File" << "0");
    setupAvailable[4].insert("*.sct", QStringList() << "sct" << "Scitex Continuous Tone Picture" << "0");
    setupAvailable[4].insert("*.ct", QStringList() << "sct" << "Scitex Continuous Tone Picture" << "0");
    setupAvailable[4].insert("*.ch", QStringList() << "sct" << "Scitex Continuous Tone Picture" << "0");
    setupAvailable[4].insert("*.sid", QStringList() << "sid" << "Multiresolution seamless image" << "0");
    // not working
    setupAvailable[4].insert("*.arw", QStringList() << "arw" << "Sony Digital Camera Alpha Raw Image Format" << "0");
    setupAvailable[4].insert("*.avs", QStringList() << "avs" << "AVS X image" << "0");
    setupAvailable[4].insert("*.x", QStringList() << "avs" << "AVS X image" << "0");
    setupAvailable[4].insert("*.mbfavs", QStringList() << "avs" << "AVS X image" << "0");
    setupAvailable[4].insert("*.cgm", QStringList() << "cgm" << "Computer Graphics Metafile" << "0");
    setupAvailable[4].insert("*.dcr", QStringList() << "dcr" << "Kodak Digital Camera Raw Image File" << "0");
    setupAvailable[4].insert("*.kdc", QStringList() << "dcr" << "Kodak Digital Camera Raw Image File" << "0");
    setupAvailable[4].insert("*.djv", QStringList() << "djv" << "DjVu digital document format " << "0");
    setupAvailable[4].insert("*.djvu", QStringList() << "djv" << "DjVu digital document format " << "0");
    setupAvailable[4].insert("*.gv", QStringList() << "dot" << "Graph Visualization" << "0");
    setupAvailable[4].insert("*.fig", QStringList() << "fig" << "FIG graphics format" << "0");
    setupAvailable[4].insert("*.flif", QStringList() << "flf" << "Free Lossless Image Format" << "0");
    setupAvailable[4].insert("*.fpx", QStringList() << "fpx" << "FlashPix Format" << "0");
    setupAvailable[4].insert("*.dng", QStringList() << "ado" << "Adobe" << "0");
    setupAvailable[4].insert("*.cgm", QStringList() << "cgm" << "Computer Graphics Metafile" << "0");
    setupAvailable[4].insert("*.jxr", QStringList() << "jxr" << "JPEG-XR" << "0");
    setupAvailable[4].insert("*.hdp", QStringList() << "jxr" << "JPEG-XR" << "0");
    setupAvailable[4].insert("*.wdp", QStringList() << "jxr" << "JPEG-XR" << "0");
    setupAvailable[4].insert("*.mng", QStringList() << "mng" << "Multiple-image Network Graphics" << "0");
    setupAvailable[4].insert("*.nef", QStringList() << "nef" << "Nikon Digital SLR Camera Raw Image File" << "0");
    setupAvailable[4].insert("*.nrw", QStringList() << "nef" << "Nikon Digital SLR Camera Raw Image File" << "0");
    setupAvailable[4].insert("*.ora", QStringList() << "ora" << "Open exchange format for layered raster based graphics" << "0");
    setupAvailable[4].insert("*.p7", QStringList() << "p7 " << "Xv's Visual Schnauzer thumbnail format" << "0");
    setupAvailable[4].insert("*.pef", QStringList() << "pen" << "Pentax" << "0");
    setupAvailable[4].insert("*.ptx", QStringList() << "pen" << "Pentax" << "0");
    setupAvailable[4].insert("*.pes", QStringList() << "pes" << "Embrid Embroidery Format" << "0");
    setupAvailable[4].insert("*.img", QStringList() << "pix" << "Alias/Wavefront RLE image format" << "0");
    setupAvailable[4].insert("*.als", QStringList() << "pix" << "Alias/Wavefront RLE image format" << "0");
    setupAvailable[4].insert("*.pix", QStringList() << "pix" << "Alias/Wavefront RLE image format" << "0");
    setupAvailable[4].insert("*.tga", QStringList() << "tga" << "Truevision Targa image" << "0");
    setupAvailable[4].insert("*.icb", QStringList() << "tga" << "Truevision Targa image" << "0");
    setupAvailable[4].insert("*.vda", QStringList() << "tga" << "Truevision Targa image" << "0");
    setupAvailable[4].insert("*.vst", QStringList() << "tga" << "Truevision Targa image" << "0");
    setupAvailable[4].insert("*.x3f", QStringList() << "sig" << "Sigma Camera RAW Picture File" << "0");
    /************************************************************/
    /************************************************************/
    // ImageMagick w/ Ghostscript
    setupAvailable[4].insert("*.epi"        , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
    setupAvailable[4].insert("*.epsi"       , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
    setupAvailable[4].insert("*.eps"        , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
    setupAvailable[4].insert("*.epsf"       , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
    setupAvailable[4].insert("*.ept"        , QStringList() << "ept" << "Adobe Encapsulated PostScript Interchange format with TIFF preview" << "0");
    setupAvailable[4].insert("*.epdf"       , QStringList() << "pdf" << "Encapsulated Portable Document Format"             << "0");
    setupAvailable[4].insert("*.pdf"        , QStringList() << "pdf" << "Portable Document Format"                          << "0");
    setupAvailable[4].insert("*.ps"         , QStringList() << "ps " << "Adobe PostScript file"                             << "0");
    setupAvailable[4].insert("*.ps2"        , QStringList() << "ps " << "Adobe Level II PostScript file"                    << "0");
    setupAvailable[4].insert("*.ps3"        , QStringList() << "ps " << "Adobe Level III PostScript file"                   << "0");


    /************************************************************/
    /************************************************************/
    // RAW
    setupAvailable[5].insert("*.3fr"        , QStringList() << "has" << "Hasselblad"                << "1");
    setupAvailable[5].insert("*.ari"        , QStringList() << "arr" << "ARRIFLEX"                  << "1");
    setupAvailable[5].insert("*.arw"        , QStringList() << "son" << "Sony"                      << "1");
    setupAvailable[5].insert("*.srf"        , QStringList() << "son" << "Sony"                      << "1");
    setupAvailable[5].insert("*.sr2"        , QStringList() << "son" << "Sony"                      << "1");
    setupAvailable[5].insert("*.bay"        , QStringList() << "cas" << "Casio"                     << "1");
    setupAvailable[5].insert("*.crw"        , QStringList() << "can" << "Canon"                     << "1");
    setupAvailable[5].insert("*.crr"        , QStringList() << "can" << "Canon"                     << "1");
    setupAvailable[5].insert("*.cr2"        , QStringList() << "can" << "Canon"                     << "1");
    setupAvailable[5].insert("*.cap"        , QStringList() << "ph1" << "Phase_one"                 << "1");
    setupAvailable[5].insert("*.liq"        , QStringList() << "ph1" << "Phase_one"                 << "1");
    setupAvailable[5].insert("*.eip"        , QStringList() << "ph1" << "Phase_one"                 << "1");
    setupAvailable[5].insert("*.dcs"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[5].insert("*.dcr"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[5].insert("*.drf"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[5].insert("*.k25"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[5].insert("*.kdc"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[5].insert("*.dng"        , QStringList() << "ado" << "Adobe"                     << "1");
    setupAvailable[5].insert("*.erf"        , QStringList() << "eps" << "Epson"                     << "1");
    setupAvailable[5].insert("*.fff"        , QStringList() << "fff" << "Imacon/Hasselblad raw"     << "1");
    setupAvailable[5].insert("*.mef"        , QStringList() << "mam" << "Mamiya"                    << "1");
    setupAvailable[5].insert("*.mdc"        , QStringList() << "min" << "Minolta, Agfa"             << "1");
    setupAvailable[5].insert("*.mos"        , QStringList() << "mos" << "Leaf"                      << "1");
    setupAvailable[5].insert("*.mrw"        , QStringList() << "min" << "Minolta, Konica Minolta"   << "1");
    setupAvailable[5].insert("*.nef"        , QStringList() << "nik" << "Nikon"                     << "1");
    setupAvailable[5].insert("*.nrw"        , QStringList() << "nik" << "Nikon"                     << "1");
    setupAvailable[5].insert("*.orf"        , QStringList() << "oly" << "Olympus"                   << "1");
    setupAvailable[5].insert("*.pef"        , QStringList() << "pen" << "Pentax"                    << "1");
    setupAvailable[5].insert("*.ptx"        , QStringList() << "pen" << "Pentax"                    << "1");
    setupAvailable[5].insert("*.pxn"        , QStringList() << "log" << "Logitech"                  << "1");
    setupAvailable[5].insert("*.r3d"        , QStringList() << "red" << "RED Digital Cinema"        << "1");
    setupAvailable[5].insert("*.raf"        , QStringList() << "fuj" << "Fuji"                      << "1");
    setupAvailable[5].insert("*.raw"        , QStringList() << "pan" << "Panasonic"                 << "1");
    setupAvailable[5].insert("*.rw2"        , QStringList() << "pan" << "Panasonic"                 << "1");
    setupAvailable[5].insert("*.raw"        , QStringList() << "lei" << "Leica"                     << "1");
    setupAvailable[5].insert("*.rwl"        , QStringList() << "lei" << "Leica"                     << "1");
    setupAvailable[5].insert("*.dng"        , QStringList() << "lei" << "Leica"                     << "1");
    setupAvailable[5].insert("*.rwz"        , QStringList() << "raw" << "Rawzor"                    << "1");
    setupAvailable[5].insert("*.srw"        , QStringList() << "sam" << "Samsung"                   << "1");
    setupAvailable[5].insert("*.x3f"        , QStringList() << "sig" << "Sigma"                     << "1");


    /************************************************************/
    /************************************************************/
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
    setupAvailable[6].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 JP2 File Format Syntax"              << "1");
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
    setupAvailable[6].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
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
    setupAvailable[6].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "0");
    setupAvailable[6].insert("*.pic"        , QStringList() << "pic" << "Softimage PIC"                                 << "0");
    setupAvailable[6].insert("*.pix"        , QStringList() << "pix" << "Alias | Wavefront"                             << "0");
    setupAvailable[6].insert("*.jxr"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");
    setupAvailable[6].insert("*.wdp"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");
    setupAvailable[6].insert("*.hdp"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");


    /************************************************************/
    /************************************************************/
    // FreeImage
    setupAvailable[7].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
    setupAvailable[7].insert("*.cut"        , QStringList() << "cut" << "DR Halo"                                       << "1");
    setupAvailable[7].insert("*.dds"        , QStringList() << "dds" << "DirectDraw Surface"                            << "1");
    setupAvailable[7].insert("*.g3"         , QStringList() << "fax" << "Raw Fax"                                       << "1");
    setupAvailable[7].insert("*.g4"         , QStringList() << "fax" << "Raw Fax"                                       << "1");
    setupAvailable[7].insert("*.gif"        , QStringList() << "gif" << "CompuServe Graphics Interchange Format"        << "1");
    setupAvailable[7].insert("*.ico"        , QStringList() << "ico" << "Windows icon/cursor"                           << "1");
    setupAvailable[7].insert("*.iff"        , QStringList() << "iff" << "Interchange File Format"                       << "1");
    setupAvailable[7].insert("*.jng"        , QStringList() << "jng" << "JPEG Network Graphics"                         << "1");
    setupAvailable[7].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[7].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[7].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[7].insert("*.jif"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[7].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 JP2 File Format Syntax"              << "1");
    setupAvailable[7].insert("*.jpc"        , QStringList() << "jpc" << "JPEG-2000 Code Stream Syntax"                  << "1");
    setupAvailable[7].insert("*.pcd"        , QStringList() << "pcd" << "Kodak PhotoCD"                                 << "1");
    setupAvailable[7].insert("*.mng"        , QStringList() << "mng" << "Multiple-image Network Graphics"               << "1");
    setupAvailable[7].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "1");
    setupAvailable[7].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
    setupAvailable[7].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
    setupAvailable[7].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
    setupAvailable[7].insert("*.pnm"        , QStringList() << "pbm" << "Portable pixmap format (pbm, pgm, or ppm)"     << "1");
    setupAvailable[7].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
    setupAvailable[7].insert("*.pict"       , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
    setupAvailable[7].insert("*.pct"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
    setupAvailable[7].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
    setupAvailable[7].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
    setupAvailable[7].insert("*.sun"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
    setupAvailable[7].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[7].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[7].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[7].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[7].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
    setupAvailable[7].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    setupAvailable[7].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    setupAvailable[7].insert("*.wbmp"       , QStringList() << "wbm" << "Wireless Bitmap"                               << "1");
    setupAvailable[7].insert("*.webp"       , QStringList() << "wep" << "Google web image format"                       << "1");
    setupAvailable[7].insert("*.xbm"        , QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
    setupAvailable[7].insert("*.xpm"        , QStringList() << "xpm" << "X Windows system pixmap"                       << "1");
    // missing test image
    setupAvailable[7].insert("*.koa"        , QStringList() << "koa" << "KOALA files"                                   << "0");
    // fails currently (apparently needs some more code for proper conversion)
    setupAvailable[7].insert("*.exr"        , QStringList() << "exr" << "OpenEXR"                                       << "0");
    setupAvailable[7].insert("*.hdr"        , QStringList() << "hdr" << "Radiance High Dynamic"                         << "0");
    setupAvailable[7].insert("*.pfm"        , QStringList() << "pfm" << "Portable Float Map"                            << "0");
    // fails on my system
    setupAvailable[7].insert("*.jxr"        , QStringList() << "jxr" << "JPEG-XR"                                       << "0");
    setupAvailable[7].insert("*.hdp"        , QStringList() << "jxr" << "JPEG-XR"                                       << "0");
    setupAvailable[7].insert("*.wdp"        , QStringList() << "jxr" << "JPEG-XR"                                       << "0");


    /************************************************************/
    /************************************************************/
    // Archive
    setupAvailable[8].insert("*.cbz"        , QStringList() << "zip" << "Comic book archive (ZIP)"                      << "1");
    setupAvailable[8].insert("*.cbr"        , QStringList() << "rar" << "Comic book archive (RAR)"                      << "1");
    setupAvailable[8].insert("*.cb7"        , QStringList() << "7z " << "Comic book archive (7z)"                       << "1");
    setupAvailable[8].insert("*.cbt"        , QStringList() << "tar" << "Comic book archive (TAR)"                      << "1");
    setupAvailable[8].insert("*.zip"        , QStringList() << "zip" << "ZIP file format"                               << "0");
    setupAvailable[8].insert("*.rar"        , QStringList() << "rar" << "RAR file format"                               << "0");
    setupAvailable[8].insert("*.7z"         , QStringList() << "7z " << "7z file format"                                << "0");
    setupAvailable[8].insert("*.tar"        , QStringList() << "tar" << "TAR file format"                               << "0");


    /************************************************************/
    /************************************************************/
    // Video
#ifdef VIDEO
    setupAvailable[9].insert("*.webm"       , QStringList() << "webm" << "WebM"                                         << "0");
    setupAvailable[9].insert("*.mkv"        , QStringList() << "mkv" << "Matroska Video"                                << "0");
    setupAvailable[9].insert("*.flv"        , QStringList() << "flv" << "Flash Video"                                   << "0");
    setupAvailable[9].insert("*.f4v"        , QStringList() << "flv" << "Flash Video"                                   << "0");
    setupAvailable[9].insert("*.vob"        , QStringList() << "vob" << "Video Object"                                  << "0");
    setupAvailable[9].insert("*.ogg"        , QStringList() << "ogg" << "Theora"                                        << "0");
    setupAvailable[9].insert("*.ogv"        , QStringList() << "ogg" << "Theora"                                        << "0");
    setupAvailable[9].insert("*.avi"        , QStringList() << "avi" << "Audio Video Interleave"                        << "0");
    setupAvailable[9].insert("*.mov"        , QStringList() << "quk" << "QuickTime File Format"                         << "0");
    setupAvailable[9].insert("*.qt"         , QStringList() << "quk" << "QuickTime File Format"                         << "0");
    setupAvailable[9].insert("*.wmv"        , QStringList() << "wmv" << "Windows Media Video"                           << "0");
    setupAvailable[9].insert("*.asf"        , QStringList() << "wmv" << "Advanced Systems Format"                       << "0");
    setupAvailable[9].insert("*.amv"        , QStringList() << "amv" << "AMV video format"                              << "0");
    setupAvailable[9].insert("*.mp4"        , QStringList() << "mp4" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.m4v"        , QStringList() << "mp4" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.3gp"        , QStringList() << "mp4" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.3g2"        , QStringList() << "mp4" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.mpg"        , QStringList() << "mpg" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.mpeg"       , QStringList() << "mpg" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.mpv"        , QStringList() << "mpg" << "MPEG"                                          << "0");
    setupAvailable[9].insert("*.m2v"        , QStringList() << "mpg" << "MPEG"                                          << "0");
#endif



    availableFileformats = new QVariantList[categories.length()];
    availableFileformatsWithDescription = new QVariantList[categories.length()];
    enabledFileformats = new QStringList[categories.length()];
    defaultEnabledFileformats = new QStringList[categories.length()];

    // watch for changes, load changes with delay and without re-saving files (this is the parameter 'false')
    watcherTimer = new QTimer;
    watcherTimer->setSingleShot(true);
    watcherTimer->setInterval(250);
    connect(watcherTimer, &QTimer::timeout, this, [=]() { composeEnabledFormats(false); enabledFileformatsChanged();
                                                          watcher->addPath(ConfigFiles::IMAGEFORMATS_FILE()); });
    watcher = new QFileSystemWatcher;
    if(QFileInfo(ConfigFiles::IMAGEFORMATS_FILE()).exists())
        watcher->addPath(ConfigFiles::IMAGEFORMATS_FILE());
    connect(watcher, &QFileSystemWatcher::fileChanged, this, [=](QString) { watcherTimer->start(); });

    composeAvailableFormats();
    composeEnabledFormats();

    saveTimer = new QTimer;
    saveTimer->setSingleShot(true);
    saveTimer->setInterval(250);
    connect(saveTimer, &QTimer::timeout, this, &PQImageFormats::saveEnabledFormats);

    connect(this, &PQImageFormats::enabledFileformatsQtChanged, this, [=](QStringList) {saveTimer->start();});

}


void PQImageFormats::setEnabledFileformats(QString cat, QStringList val, bool withSaving) {

    DBG << CURDATE << "PQImageFormats::setEnabledFileformats()" << NL
        << CURDATE << "** cat = " << cat.toStdString() << NL
        << CURDATE << "** withSaving = " << withSaving << NL;

    if(withSaving) {

        if(cat == "qt")
            setEnabledFileformatsQt(val);

        else if(cat == "xcftools")
            setEnabledFileformatsXCF(val);

        else if(cat == "poppler")
            setEnabledFileformatsPoppler(val);

        else if(cat == "graphicsmagick")
            setEnabledFileformatsGraphicsMagick(val);

        else if(cat == "imagemagick")
            setEnabledFileformatsImageMagick(val);

        else if(cat == "raw")
            setEnabledFileformatsRAW(val);

        else if(cat == "devil")
            setEnabledFileformatsDevIL(val);

        else if(cat == "freeimage")
            setEnabledFileformatsFreeImage(val);

        else if(cat == "archive")
            setEnabledFileformatsArchive(val);

        else if(cat == "video")
            setEnabledFileformatsVideo(val);

    } else {

        if(cat == "qt")
            setEnabledFileformatsQtWithoutSaving(val);

        else if(cat == "xcftools")
            setEnabledFileformatsXCFWithoutSaving(val);

        else if(cat == "poppler")
            setEnabledFileformatsPopplerWithoutSaving(val);

        else if(cat == "graphicsmagick")
            setEnabledFileformatsGraphicsMagickWithoutSaving(val);

        else if(cat == "imagemagick")
            setEnabledFileformatsImageMagickWithoutSaving(val);

        else if(cat == "raw")
            setEnabledFileformatsRAWWithoutSaving(val);

        else if(cat == "devil")
            setEnabledFileformatsDevILWithoutSaving(val);

        else if(cat == "freeimage")
            setEnabledFileformatsFreeImageWithoutSaving(val);

        else if(cat == "archive")
            setEnabledFileformatsArchiveWithoutSaving(val);

        else if(cat == "video")
            setEnabledFileformatsVideoWithoutSaving(val);

    }
}

// Called at setup, these do not change during runtime
void PQImageFormats::composeAvailableFormats() {

    DBG << CURDATE << "PQImageFormats::composeAvailableFormats()" << NL;

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
void PQImageFormats::composeEnabledFormats(bool withSaving) {

    DBG << CURDATE << "PQImageFormats::composeEnabledFormats()" << NL
        << CURDATE << "** withSaving = " << withSaving << NL;

    QFile disabled(ConfigFiles::IMAGEFORMATS_FILE());
    // If file does not exist we use default entries. The same happens as when the file cannot be opened, but in this case no message is printed out.
    if(!disabled.exists()) {
        for(QString cat : categories)
            setEnabledFileformats(cat, defaultEnabledFileformats[categories.indexOf(cat)]);

        return;
    }
    if(!disabled.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "ImageFormats::composeEnabledFormats() :: NOTE: Disabled formats file cannot be opened for reading. "
                       << "Setting default entries..." << NL;
        for(QString cat : categories)
            setEnabledFileformats(cat, defaultEnabledFileformats[categories.indexOf(cat)]);
        return;
    }

    QStringList categoriesFoundInDisabledFile;

    QTextStream in(&disabled);
    QString line, cat = "";
    QMap<QString,QStringList> allDisabled;
    while(in.readLineInto(&line)) {

        if(line.trimmed() == "") continue;

        if(line.startsWith("[")) {
            foreach(QString c, categories) {
                if(line.trimmed() == QString("[%1]").arg(c)) {
                    cat = c;
                    categoriesFoundInDisabledFile.push_back(c);
                    break;
                }
            }
        } else {

            if(cat == "") continue;

            if(allDisabled.keys().contains(cat))
                allDisabled[cat].append(line.trimmed());
            else
                allDisabled.insert(cat, QStringList() << line.trimmed());

        }

    }

    for(QString cat : categories) {

        // if this category wasn't found in the file with the disabled formats, then it must be a new category
        // even if all formats are enabled, the category is still listed (just without any formats below)
        if(!categoriesFoundInDisabledFile.contains(cat)) {
            setDefaultFileformats(cat);
            continue;
        }

        // These will hold the formats that are enabled
        QStringList setTheseAsEnabled;

        // Loop over each item of available formats
        foreach(QVariant item, availableFileformats[categories.indexOf(cat)]) {

            // The current available format
            QString avail = item.toString();

            // If format is not disabled, add to list of enabled formats
            if(!allDisabled[cat].contains(avail)) {
                setTheseAsEnabled.append(avail);
            }

        }

        // Set enabled formats to file
        setEnabledFileformats(cat, setTheseAsEnabled, withSaving);

    }

}

// Save file formats
void PQImageFormats::saveEnabledFormats() {

    DBG << CURDATE << "PQImageFormats::saveEnabledFormats()" << NL;

    QString disabled = "";

    for(int i = 0; i < categories.length(); ++i) {

        QString cat = categories.at(i);

        disabled += QString("[%1]\n").arg(cat);

        // Compose list of disabled formats
        foreach(QVariant avail, availableFileformats[categories.indexOf(cat)]) {
            if(!enabledFileformats[categories.indexOf(cat)].contains(avail.toString()))
                disabled += avail.toString()+"\n";
        }

        disabled += "\n";

    }

    // Access and open disabled formats file for writing
    QFile file(ConfigFiles::IMAGEFORMATS_FILE());
    if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        LOG << CURDATE << "ImageFormats::saveEnabledFormats() :: ERROR: Unable to open disabled formats for writing/truncating..." << NL;
        return;
    }

    // Write disabled formats
    QTextStream out(&file);
    out << disabled;

    // close file
    file.close();

    emit enabledFileformatsSaved();

}
