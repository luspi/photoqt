#include "imageformats.h"

PQImageFormats::PQImageFormats() {

    categories << "qt" << "xcftools" << "poppler" << "gm" << "raw"
               << "devil" << "freeimage" << "archive" << "video";

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
    setupAvailable[3].insert("*.jbig2"      , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
    setupAvailable[3].insert("*.jbg"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
    setupAvailable[3].insert("*.jb2"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
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
    // RAW
    setupAvailable[4].insert("*.3fr"        , QStringList() << "has" << "Hasselblad"                << "1");
    setupAvailable[4].insert("*.ari"        , QStringList() << "arr" << "ARRIFLEX"                  << "1");
    setupAvailable[4].insert("*.arw"        , QStringList() << "son" << "Sony"                      << "1");
    setupAvailable[4].insert("*.srf"        , QStringList() << "son" << "Sony"                      << "1");
    setupAvailable[4].insert("*.sr2"        , QStringList() << "son" << "Sony"                      << "1");
    setupAvailable[4].insert("*.bay"        , QStringList() << "cas" << "Casio"                     << "1");
    setupAvailable[4].insert("*.crw"        , QStringList() << "can" << "Canon"                     << "1");
    setupAvailable[4].insert("*.crr"        , QStringList() << "can" << "Canon"                     << "1");
    setupAvailable[4].insert("*.cr2"        , QStringList() << "can" << "Canon"                     << "1");
    setupAvailable[4].insert("*.cap"        , QStringList() << "ph1" << "Phase_one"                 << "1");
    setupAvailable[4].insert("*.liq"        , QStringList() << "ph1" << "Phase_one"                 << "1");
    setupAvailable[4].insert("*.eip"        , QStringList() << "ph1" << "Phase_one"                 << "1");
    setupAvailable[4].insert("*.dcs"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[4].insert("*.dcr"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[4].insert("*.drf"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[4].insert("*.k25"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[4].insert("*.kdc"        , QStringList() << "kod" << "Kodak"                     << "1");
    setupAvailable[4].insert("*.dng"        , QStringList() << "ado" << "Adobe"                     << "1");
    setupAvailable[4].insert("*.erf"        , QStringList() << "eps" << "Epson"                     << "1");
    setupAvailable[4].insert("*.fff"        , QStringList() << "fff" << "Imacon/Hasselblad raw"     << "1");
    setupAvailable[4].insert("*.mef"        , QStringList() << "mam" << "Mamiya"                    << "1");
    setupAvailable[4].insert("*.mdc"        , QStringList() << "min" << "Minolta, Agfa"             << "1");
    setupAvailable[4].insert("*.mos"        , QStringList() << "mos" << "Leaf"                      << "1");
    setupAvailable[4].insert("*.mrw"        , QStringList() << "min" << "Minolta, Konica Minolta"   << "1");
    setupAvailable[4].insert("*.nef"        , QStringList() << "nik" << "Nikon"                     << "1");
    setupAvailable[4].insert("*.nrw"        , QStringList() << "nik" << "Nikon"                     << "1");
    setupAvailable[4].insert("*.orf"        , QStringList() << "oly" << "Olympus"                   << "1");
    setupAvailable[4].insert("*.pef"        , QStringList() << "pen" << "Pentax"                    << "1");
    setupAvailable[4].insert("*.ptx"        , QStringList() << "pen" << "Pentax"                    << "1");
    setupAvailable[4].insert("*.pxn"        , QStringList() << "log" << "Logitech"                  << "1");
    setupAvailable[4].insert("*.r3d"        , QStringList() << "red" << "RED Digital Cinema"        << "1");
    setupAvailable[4].insert("*.raf"        , QStringList() << "fuj" << "Fuji"                      << "1");
    setupAvailable[4].insert("*.raw"        , QStringList() << "pan" << "Panasonic"                 << "1");
    setupAvailable[4].insert("*.rw2"        , QStringList() << "pan" << "Panasonic"                 << "1");
    setupAvailable[4].insert("*.raw"        , QStringList() << "lei" << "Leica"                     << "1");
    setupAvailable[4].insert("*.rwl"        , QStringList() << "lei" << "Leica"                     << "1");
    setupAvailable[4].insert("*.dng"        , QStringList() << "lei" << "Leica"                     << "1");
    setupAvailable[4].insert("*.rwz"        , QStringList() << "raw" << "Rawzor"                    << "1");
    setupAvailable[4].insert("*.srw"        , QStringList() << "sam" << "Samsung"                   << "1");
    setupAvailable[4].insert("*.x3f"        , QStringList() << "sig" << "Sigma"                     << "1");


    /************************************************************/
    /************************************************************/
    // DevIL
    setupAvailable[5].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
    setupAvailable[5].insert("*.dds"        , QStringList() << "dds" << "DirectDraw Surface"                            << "1");
    setupAvailable[5].insert("*.exr"        , QStringList() << "exr" << "OpenEXR"                                       << "1");
    setupAvailable[5].insert("*.fits"       , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
    setupAvailable[5].insert("*.fit"        , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
    setupAvailable[5].insert("*.ftx"        , QStringList() << "ftx" << "Heavy Metal: FAKK 2"                           << "1");
    setupAvailable[5].insert("*.hdr"        , QStringList() << "hdr" << "Radiance High Dynamic"                         << "1");
    setupAvailable[5].insert("*.icns"       , QStringList() << "icn" << "Macintosh icon"                                << "1");
    setupAvailable[5].insert("*.ico"        , QStringList() << "ico" << "Windows icon/cursor"                           << "1");
    setupAvailable[5].insert("*.cur"        , QStringList() << "ico" << "Windows icon/cursor"                           << "1");
    setupAvailable[5].insert("*.iff"        , QStringList() << "iff" << "Interchange File Format"                       << "1");
    setupAvailable[5].insert("*.gif"        , QStringList() << "gif" << "Graphics Interchange Format"                   << "1");
    setupAvailable[5].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[5].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[5].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[5].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 JP2 File Format Syntax"              << "1");
    setupAvailable[5].insert("*.lbm"        , QStringList() << "lbm" << "Interlaced Bitmap"                             << "1");
    setupAvailable[5].insert("*.pcd"        , QStringList() << "pcd" << "Kodak PhotoCD"                                 << "1");
    setupAvailable[5].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
    setupAvailable[5].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
    setupAvailable[5].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
    setupAvailable[5].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
    setupAvailable[5].insert("*.pnm"        , QStringList() << "pbm" << "Portable pixmap format (pbm, pgm, or ppm)"     << "1");
    setupAvailable[5].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
    setupAvailable[5].insert("*.psp"        , QStringList() << "psp" << "PaintShop Pro"                                 << "1");
    setupAvailable[5].insert("*.raw"        , QStringList() << "raw" << "Raw data"                                      << "1");
    setupAvailable[5].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[5].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[5].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[5].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[5].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
    setupAvailable[5].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    setupAvailable[5].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    // no test image available
    setupAvailable[5].insert("*.iwi"        , QStringList() << "iwi" << "Infinity Ward Image"                           << "0");
    setupAvailable[5].insert("*.lif"        , QStringList() << "lif" << "Homeworld texture"                             << "0");
    setupAvailable[5].insert("*.pxr"        , QStringList() << "pxr" << "Pixar"                                         << "0");
    setupAvailable[5].insert("*.rot"        , QStringList() << "rot" << "Homeworld 2 Texture"                           << "0");
    setupAvailable[5].insert("*.texture"    , QStringList() << "tex" << "Creative Assembly Texture"                     << "0");
    setupAvailable[5].insert("*.tpl"        , QStringList() << "tpl" << "Gamecube Texture"                              << "0");
    setupAvailable[5].insert("*.utx"        , QStringList() << "utx" << "Unreal Texture"                                << "0");
    setupAvailable[5].insert("*.wal"        , QStringList() << "wal" << "Quake2 Texture"                                << "0");
    setupAvailable[5].insert("*.vtf"        , QStringList() << "vtf" << "Valve Texture Format"                          << "0");
    // fails on my system
    setupAvailable[5].insert("*.cut"        , QStringList() << "cut" << "DR Halo"                                       << "0");
    setupAvailable[5].insert("*.dcx"        , QStringList() << "dcx" << "Multi-PCX"                                     << "0");
    setupAvailable[5].insert("*.dcm"        , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "0");
    setupAvailable[5].insert("*.dicom"      , QStringList() << "dic" << "Digital Imaging and Communications in Medicine (DICOM) image"  << "0");
    setupAvailable[5].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "0");
    setupAvailable[5].insert("*.pic"        , QStringList() << "pic" << "Softimage PIC"                                 << "0");
    setupAvailable[5].insert("*.pix"        , QStringList() << "pix" << "Alias | Wavefront"                             << "0");
    setupAvailable[5].insert("*.wdp"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");
    setupAvailable[5].insert("*.hdp"        , QStringList() << "hdp" << "JPEG XR aka HD Photo"                          << "0");


    /************************************************************/
    /************************************************************/
    // FreeImage
    setupAvailable[6].insert("*.bmp"        , QStringList() << "bmp" << "Microsoft Windows bitmap"                      << "1");
    setupAvailable[6].insert("*.cut"        , QStringList() << "cut" << "DR Halo"                                       << "1");
    setupAvailable[6].insert("*.dds"        , QStringList() << "dds" << "DirectDraw Surface"                            << "1");
    setupAvailable[6].insert("*.g3"         , QStringList() << "fax" << "Raw Fax"                                       << "1");
    setupAvailable[6].insert("*.g4"         , QStringList() << "fax" << "Raw Fax"                                       << "1");
    setupAvailable[6].insert("*.gif"        , QStringList() << "gif" << "CompuServe Graphics Interchange Format"        << "1");
    setupAvailable[6].insert("*.ico"        , QStringList() << "ico" << "Windows icon/cursor"                           << "1");
    setupAvailable[6].insert("*.iff"        , QStringList() << "iff" << "Interchange File Format"                       << "1");
    setupAvailable[6].insert("*.jng"        , QStringList() << "jng" << "JPEG Network Graphics"                         << "1");
    setupAvailable[6].insert("*.jpg"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[6].insert("*.jpe"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[6].insert("*.jpeg"       , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[6].insert("*.jif"        , QStringList() << "jpg" << "Joint Photographic Experts Group JFIF format"  << "1");
    setupAvailable[6].insert("*.jp2"        , QStringList() << "jp2" << "JPEG-2000 JP2 File Format Syntax"              << "1");
    setupAvailable[6].insert("*.jpc"        , QStringList() << "jpc" << "JPEG-2000 Code Stream Syntax"                  << "1");
    setupAvailable[6].insert("*.pcd"        , QStringList() << "pcd" << "Kodak PhotoCD"                                 << "1");
    setupAvailable[6].insert("*.mng"        , QStringList() << "mng" << "Multiple-image Network Graphics"               << "1");
    setupAvailable[6].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                                     << "1");
    setupAvailable[6].insert("*.pbm"        , QStringList() << "pbm" << "Portable bitmap format (black and white)"      << "1");
    setupAvailable[6].insert("*.pgm"        , QStringList() << "pbm" << "Portable graymap format (gray scale)"          << "1");
    setupAvailable[6].insert("*.ppm"        , QStringList() << "pbm" << "Portable pixmap format (color)"                << "1");
    setupAvailable[6].insert("*.pnm"        , QStringList() << "pbm" << "Portable pixmap format (pbm, pgm, or ppm)"     << "1");
    setupAvailable[6].insert("*.png"        , QStringList() << "png" << "Portable Network Graphics"                     << "1");
    setupAvailable[6].insert("*.pict"       , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
    setupAvailable[6].insert("*.pct"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
    setupAvailable[6].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "1");
    setupAvailable[6].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"                               << "1");
    setupAvailable[6].insert("*.sun"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
    setupAvailable[6].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[6].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[6].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[6].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"                              << "1");
    setupAvailable[6].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
    setupAvailable[6].insert("*.tif"        , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    setupAvailable[6].insert("*.tiff"       , QStringList() << "tif" << "Tagged Image File Format"                      << "1");
    setupAvailable[6].insert("*.wbmp"       , QStringList() << "wbm" << "Wireless Bitmap"                               << "1");
    setupAvailable[6].insert("*.webp"       , QStringList() << "wep" << "Google web image format"                       << "1");
    setupAvailable[6].insert("*.xbm"        , QStringList() << "xbm" << "X Windows system bitmap, black and white only" << "1");
    setupAvailable[6].insert("*.xpm"        , QStringList() << "xpm" << "X Windows system pixmap"                       << "1");
    // missing test image
    setupAvailable[6].insert("*.koa"        , QStringList() << "koa" << "KOALA files"                                   << "0");
    // fails currently (apparently needs some more code for proper conversion)
    setupAvailable[6].insert("*.exr"        , QStringList() << "exr" << "OpenEXR"                                       << "0");
    setupAvailable[6].insert("*.hdr"        , QStringList() << "hdr" << "Radiance High Dynamic"                         << "0");
    setupAvailable[6].insert("*.pfm"        , QStringList() << "pfm" << "Portable Float Map"                            << "0");
    // fails on my system
    setupAvailable[6].insert("*.jxr"        , QStringList() << "jxr" << "JPEG-XR"                                       << "0");
    setupAvailable[6].insert("*.hdp"        , QStringList() << "jxr" << "JPEG-XR"                                       << "0");
    setupAvailable[6].insert("*.wdp"        , QStringList() << "jxr" << "JPEG-XR"                                       << "0");


    /************************************************************/
    /************************************************************/
    // Archive
    setupAvailable[7].insert("*.cbz"        , QStringList() << "zip" << "Comic book archive (ZIP)"                      << "1");
    setupAvailable[7].insert("*.cbr"        , QStringList() << "rar" << "Comic book archive (RAR)"                      << "1");
    setupAvailable[7].insert("*.cb7"        , QStringList() << "7z " << "Comic book archive (7z)"                       << "1");
    setupAvailable[7].insert("*.cbt"        , QStringList() << "tar" << "Comic book archive (TAR)"                      << "1");
    setupAvailable[7].insert("*.zip"        , QStringList() << "zip" << "ZIP file format"                               << "0");
    setupAvailable[7].insert("*.rar"        , QStringList() << "rar" << "RAR file format"                               << "0");
    setupAvailable[7].insert("*.7z"         , QStringList() << "7z " << "7z file format"                                << "0");
    setupAvailable[7].insert("*.tar"        , QStringList() << "tar" << "TAR file format"                               << "0");


    /************************************************************/
    /************************************************************/
    // Video
    setupAvailable[8].insert("*.mp4"        , QStringList() << "mp4" << "MPEG-4"                                        << "1");
    setupAvailable[8].insert("*.ogv"        , QStringList() << "ogv" << "Theora"                                        << "1");
    setupAvailable[8].insert("*.webm"       , QStringList() << "wem" << "WebM"                                          << "1");
    setupAvailable[8].insert("*.m4v"       , QStringList() << "m4v" << "WebM"                                          << "1");



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

    if(withSaving) {

        if(cat == "qt")
            setEnabledFileformatsQt(val);

        else if(cat == "xcftools")
            setEnabledFileformatsXCF(val);

        else if(cat == "poppler")
            setEnabledFileformatsPoppler(val);

        else if(cat == "gm")
            setEnabledFileformatsGm(val);

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

        else if(cat == "gm")
            setEnabledFileformatsGmWithoutSaving(val);

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

    QTextStream in(&disabled);
    QString line, cat = "";
    QMap<QString,QStringList> allDisabled;
    while(in.readLineInto(&line)) {

        if(line.trimmed() == "") continue;

        if(line.startsWith("[")) {
            foreach(QString c, categories) {
                if(line.trimmed() == QString("[%1]").arg(c)) {
                    cat = c;
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
