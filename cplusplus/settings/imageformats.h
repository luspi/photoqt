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

        categories << "qt" << "kde" << "extras" << "gm" << "gmghostscript" << "raw" << "devil";
        formatsfiles << ConfigFiles::FILEFORMATSQT_FILE() << ConfigFiles::FILEFORMATSKDE_FILE()
                     << ConfigFiles::FILEFORMATSEXTRAS_FILE() << ConfigFiles::FILEFORMATSGM_FILE()
                     << ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE() << ConfigFiles::FILEFORMATSRAW_FILE()
                     << ConfigFiles::FILEFORMATSDEVIL_FILE();

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
        setupAvailable[3].insert("*.rle"        , QStringList() << "bmp" << "RLE-compressed bitmap"                         << "1");
        setupAvailable[3].insert("*.dib"        , QStringList() << "bmp" << "Device-Independent bitmap"                     << "1");
        setupAvailable[3].insert("*.cals"       , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.cal"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
        setupAvailable[3].insert("*.ras"        , QStringList() << "cal" << "Continuous Acquisition and Life-cycle Support Type 1 image"    << "1");
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
        setupAvailable[3].insert("*.dcx"        , QStringList() << "dcx" << "ZSoft IBM PC multi-page Paintbrush image"      << "1");
        setupAvailable[3].insert("*.dib"        , QStringList() << "bmp" << "Microsoft Windows Device Independent Bitmap"   << "1");
        setupAvailable[3].insert("*.dpx"        , QStringList() << "dpx" << "Digital Moving Picture Exchange"               << "1");
        setupAvailable[3].insert("*.epdf"       , QStringList() << "pdf" << "Encapsulated Portable Document Format"         << "0");
        setupAvailable[3].insert("*.fax"        , QStringList() << "fax" << "Group 3 FAX"                                   << "1");
        setupAvailable[3].insert("*.fits"       , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[3].insert("*.fts"        , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[3].insert("*.fit"        , QStringList() << "fit" << "Flexible Image Transport System"               << "1");
        setupAvailable[3].insert("*.fpx"        , QStringList() << "fpx" << "FlashPix Format"                               << "1");
        setupAvailable[3].insert("*.jng"        , QStringList() << "jng" << "JPEG Network Graphics"                         << "1");
        setupAvailable[3].insert("*.mat"        , QStringList() << "mat" << "MATLAB image format"                           << "1");
        setupAvailable[3].insert("*.miff"       , QStringList() << "mif" << "Magick image file format"                      << "1");
        setupAvailable[3].insert("*.mono"       , QStringList() << "mon" << "Bi-level bitmap in least-significant-byte first order" << "0");
        setupAvailable[3].insert("*.mtv"        , QStringList() << "mtv" << "MTV Raytracing image format"                   << "1");
        setupAvailable[3].insert("*.otb"        , QStringList() << "otb" << "On-the-air Bitmap"                             << "1");
        setupAvailable[3].insert("*.p7"         , QStringList() << "p7 " << "Xv's Visual Schnauzer thumbnail format"        << "1");
        setupAvailable[3].insert("*.palm"       , QStringList() << "pal" << "Palm pixmap"                                   << "1");
        setupAvailable[3].insert("*.pam"        , QStringList() << "pam" << "Portable Arbitrary Map format"                 << "1");
        setupAvailable[3].insert("*.pcd"        , QStringList() << "pcd" << "Photo CD"                                      << "1");
        setupAvailable[3].insert("*.pcds"       , QStringList() << "pcd" << "Photo CD"                                      << "1");
        setupAvailable[3].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft IBM PC Paintbrush file"                  << "1");
        setupAvailable[3].insert("*.pdb"        , QStringList() << "pdb" << "Palm Database ImageViewer Format"              << "1");
        setupAvailable[3].insert("*.pict"       , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "0");
        setupAvailable[3].insert("*.pct"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "0");
        setupAvailable[3].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw /PICT file"          << "0");
        setupAvailable[3].insert("*.pix"        , QStringList() << "pix" << "Alias/Wavefront RLE image format"              << "0");
        setupAvailable[3].insert("*.pal"        , QStringList() << "pix" << "Alias/Wavefront RLE image format"              << "0");
        setupAvailable[3].insert("*.pnm"        , QStringList() << "pbm" << "Portable anymap"                               << "1");
        setupAvailable[3].insert("*.psd"        , QStringList() << "psd" << "Adobe Photoshop bitmap file"                   << "0");
        setupAvailable[3].insert("*.ptif"       , QStringList() << "pti" << "Pyramid encoded TIFF"                          << "1");
        setupAvailable[3].insert("*.ptiff"      , QStringList() << "pti" << "Pyramid encoded TIFF"                          << "1");
        setupAvailable[3].insert("*.sfw"        , QStringList() << "sfw" << "Seattle File Works image"                      << "1");
        setupAvailable[3].insert("*.sgi"        , QStringList() << "iri" << "Irix RGB image"                                << "1");
        setupAvailable[3].insert("*.sun"        , QStringList() << "sun" << "SUN Rasterfile"                                << "1");
        setupAvailable[3].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa image"                        << "1");
        setupAvailable[3].insert("*.vicar"      , QStringList() << "vic" << "VICAR rasterfile format"                       << "1");
        setupAvailable[3].insert("*.viff"       , QStringList() << "vif" << "Khoros Visualization Image File Format"        << "0");
        setupAvailable[3].insert("*.wpg"        , QStringList() << "wpg" << "Word Perfect Graphics File"                    << "1");
        setupAvailable[3].insert("*.xwd"        , QStringList() << "xwd" << "X Windows system window dump"                  << "1");
        // The following formats are untested (no test image) and are thus disabled by default, but they might very well work
        setupAvailable[3].insert("*.hp"         , QStringList() << "hp " << "HP-GL plotter language"                        << "0");
        setupAvailable[3].insert("*.hpgl"       , QStringList() << "hp " << "HP-GL plotter language"                        << "0");
        setupAvailable[3].insert("*.jbig"       , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.jbg"        , QStringList() << "jbg" << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.pwp"        , QStringList() << "pwp" << "Seattle File Works multi-image file"           << "0");
        setupAvailable[3].insert("*.rast"       , QStringList() << "ras" << "Sun Raster Image"                              << "0");
        setupAvailable[3].insert("*.rla"        , QStringList() << "rla" << "Alias/Wavefront image file"                    << "0");
        setupAvailable[3].insert("*.rle"        , QStringList() << "bmp" << "Utah Run length encoded image file"            << "0"); // bmp or independent?
        setupAvailable[3].insert("*.sct"        , QStringList() << "sct" << "Scitex Continuous Tone Picture"                << "0");
        setupAvailable[3].insert("*.tim"        , QStringList() << "tim" << "PSX TIM file"                                  << "0");

        // GraphicsMagick w/ Ghostscript
        setupAvailable[4].insert("*.epi"        , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
        setupAvailable[4].insert("*.epsi"       , QStringList() << "pse" << "Adobe Encapsulated PostScript Interchange format"  << "0");
        setupAvailable[4].insert("*.eps"        , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
        setupAvailable[4].insert("*.epsf"       , QStringList() << "pse" << "Adobe Encapsulated PostScript"                     << "0");
        setupAvailable[4].insert("*.eps2"       , QStringList() << "pse" << "Adobe Level II Encapsulated PostScript"            << "0");
        setupAvailable[4].insert("*.eps3"       , QStringList() << "pse" << "Adobe Level III Encapsulated PostScript"           << "0");
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
        setupAvailable[6].insert("*.cut"        , QStringList() << "cut" << "DR Halo"                   << "1");
        setupAvailable[6].insert("*.dds"        , QStringList() << "dds" << "DirectDraw Surface"        << "1");
        setupAvailable[6].insert("*.lbm"        , QStringList() << "lbm" << "Interlaced Bitmap"         << "1");
        setupAvailable[6].insert("*.lif"        , QStringList() << "lif" << "Homeworld File"            << "1");
        setupAvailable[6].insert("*.lmp"        , QStringList() << "lmp" << "Doom Walls / Flats"        << "1");
        setupAvailable[6].insert("*.mdl"        , QStringList() << "mdl" << "Half-Life Model"           << "1");
        setupAvailable[6].insert("*.pcd"        , QStringList() << "pcd" << "PhotoCD"                   << "1");
        setupAvailable[6].insert("*.pcx"        , QStringList() << "pcx" << "ZSoft PCX"                 << "1");
        setupAvailable[6].insert("*.pic"        , QStringList() << "pic" << "Apple Macintosh QuickDraw/PICT file" << "1");
        setupAvailable[6].insert("*.psd"        , QStringList() << "psd" << "Adobe PhotoShop"           << "1");
        setupAvailable[6].insert("*.bw"         , QStringList() << "sgi" << "Silicon Graphics"          << "1");
        setupAvailable[6].insert("*.rgb"        , QStringList() << "sgi" << "Silicon Graphics"          << "1");
        setupAvailable[6].insert("*.rgba"       , QStringList() << "sgi" << "Silicon Graphics"          << "1");
        setupAvailable[6].insert("*.sgi"        , QStringList() << "sgi" << "Silicon Graphics"          << "1");
        setupAvailable[6].insert("*.tga"        , QStringList() << "tga" << "Truevision Targa Graphic"  << "1");
        setupAvailable[6].insert("*.wal"        , QStringList() << "wal" << "Quake2 Texture"            << "1");


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
    }

    // All possibly available file formats for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsQt() { return availableFileformats[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsKDE() { return availableFileformats[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsExtras() { return availableFileformats[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGm() { return availableFileformats[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGmGhostscript() { return availableFileformats[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsRAW() { return availableFileformats[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsDevIL() { return availableFileformats[categories.indexOf("devil")]; }

    // All possibly available file formats INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionQt() { return availableFileformatsWithDescription[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionKDE() { return availableFileformatsWithDescription[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionExtras() { return availableFileformatsWithDescription[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGm() { return availableFileformatsWithDescription[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGmGhostscript() { return availableFileformatsWithDescription[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionRAW() { return availableFileformatsWithDescription[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionDevIL() { return availableFileformatsWithDescription[categories.indexOf("devil")]; }

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

    Q_INVOKABLE void setDefaultFormatsQt() { setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]); }
    Q_INVOKABLE void setDefaultFormatsKDE() { setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]); }
    Q_INVOKABLE void setDefaultFormatsExtras() { setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]); }
    Q_INVOKABLE void setDefaultFormatsGm() { setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]); }
    Q_INVOKABLE void setDefaultFormatsGmGhostscript() { setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]); }
    Q_INVOKABLE void setDefaultFormatsRAW() { setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]); }
    Q_INVOKABLE void setDefaultFormatsDevIL() { setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]); }

    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultFileformats() {
        setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
        setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]);
        setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]);
        setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]);
        setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]);
        setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]);
        setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]);
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
                if(val.value().at(1) == "1") defaultEnabledFileformats[categories.indexOf(cat)].append(val.key());

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
