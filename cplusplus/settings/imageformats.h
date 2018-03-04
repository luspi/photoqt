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
        setupAvailable[0].insert("*.bmp"     , QStringList() << "Microsoft Windows bitmap"                        << "1");
        setupAvailable[0].insert("*.bitmap"  , QStringList() << "Microsoft Windows bitmap"                        << "1");
        setupAvailable[0].insert("*.gif"     , QStringList() << "CompuServe Graphics Interchange Format"          << "1");
        setupAvailable[0].insert("*.jp2"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("*.jpc"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("*.j2k"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("*.jpeg2000", QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("*.jpx"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("*.mng"     , QStringList() << "Multiple-image Network Graphics"                 << "1");
        setupAvailable[0].insert("*.ico"     , QStringList() << "Microsoft icon"                                  << "1");
        setupAvailable[0].insert("*.cur"     , QStringList() << "Microsoft icon"                                  << "1");
        setupAvailable[0].insert("*.icns"    , QStringList() << "Macintosh OS X icon"                             << "1");
        setupAvailable[0].insert("*.jpeg"    , QStringList() << "Joint Photographic Experts Group JFIF format"    << "1");
        setupAvailable[0].insert("*.jpg"     , QStringList() << "Joint Photographic Experts Group JFIF format"    << "1");
        setupAvailable[0].insert("*.jpe"     , QStringList() << "Joint Photographic Experts Group JFIF format"    << "1");
        setupAvailable[0].insert("*.png"     , QStringList() << "Portable Network Graphics"                       << "1");
        setupAvailable[0].insert("*.pbm"     , QStringList() << "Portable bitmap format (black and white)"        << "1");
        setupAvailable[0].insert("*.pgm"     , QStringList() << "Portable graymap format (gray scale)"            << "1");
        setupAvailable[0].insert("*.ppm"     , QStringList() << "Portable pixmap format (color)"                  << "1");
        setupAvailable[0].insert("*.pnm"     , QStringList() << "Portable anymap (pbm, pgm, or ppm)"              << "1");
        setupAvailable[0].insert("*.svg"     , QStringList() << "Scalable Vector Graphics"                        << "1");
        setupAvailable[0].insert("*.svgz"    , QStringList() << "Scalable Vector Graphics"                        << "1");
        setupAvailable[0].insert("*.tga"     , QStringList() << "Truevision Targa Graphic"                        << "1");
        setupAvailable[0].insert("*.tif"     , QStringList() << "Tagged Image File Format"                        << "1");
        setupAvailable[0].insert("*.tiff"    , QStringList() << "Tagged Image File Format"                        << "1");
        setupAvailable[0].insert("*.wbmp"    , QStringList() << "Wireless bitmap"                                 << "1");
        setupAvailable[0].insert("*.webp"    , QStringList() << "Google web image format"                         << "1");
        setupAvailable[0].insert("*.xbm"     , QStringList() << "X Windows system bitmap, black and white only"   << "1");
        setupAvailable[0].insert("*.xpm"     , QStringList() << "X Windows system pixmap"                         << "1");

        // KDE
        setupAvailable[1].insert("*.eps"     , QStringList() << "Adobe Encapsulated PostScript"                   << "1");
        setupAvailable[1].insert("*.epsf"    , QStringList() << "Adobe Encapsulated PostScript"                   << "1");
        setupAvailable[1].insert("*.epsi"    , QStringList() << "Adobe Encapsulated PostScript"                   << "1");
        setupAvailable[1].insert("*.exr"     , QStringList() << "OpenEXR"                                         << "1");
        setupAvailable[1].insert("*.kra"     , QStringList() << "Krita Document"                                  << "1");
        setupAvailable[1].insert("*.ora"     , QStringList() << "Open Raster Image File"                          << "1");
        setupAvailable[1].insert("*.pcx"     , QStringList() << "ZSoft PCX"                                       << "1");
        setupAvailable[1].insert("*.pic"     , QStringList() << "Apple Macintosh QuickDraw/PICT file"             << "1");
        setupAvailable[1].insert("*.psd"     , QStringList() << "Adobe PhotoShop"                                 << "1");
        setupAvailable[1].insert("*.ras"     , QStringList() << "Sun Graphics"                                    << "1");
        setupAvailable[1].insert("*.bw"      , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("*.rgb"     , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("*.rgba"    , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("*.sgi"     , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("*.tga"     , QStringList() << "Truevision Targa Graphic"                        << "1");
        setupAvailable[1].insert("*.xcf"     , QStringList() << "Gimp format"                                     << "1");

        // Extras
        setupAvailable[2].insert("*.psb"     , QStringList() << "Adobe PhotoShop - Makes use of 'libqpsd'"        << "0");
        setupAvailable[2].insert("*.psd"     , QStringList() << "Adobe PhotoShop - Makes use of 'libqpsd'"        << "0");
        setupAvailable[2].insert("*.xcf"     , QStringList() << "Gimp format - Makes use of 'xcftoold'"           << "0");

        // GraphicsMagick
        setupAvailable[3].insert("*.art"      , QStringList() << "PFS: 1st Publisher"                             << "1");
        setupAvailable[3].insert("*.avs"      , QStringList() << "AVS X image"                                    << "1");
        setupAvailable[3].insert("*.x"        , QStringList() << "AVS X image"                                    << "1");
        setupAvailable[3].insert("*.mbfavs"   , QStringList() << "AVS X image"                                    << "1");
        setupAvailable[3].insert("*.cals"     , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"   << "1");
        setupAvailable[3].insert("*.cal"      , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"   << "1");
        setupAvailable[3].insert("*.dcl"      , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"   << "1");
        setupAvailable[3].insert("*.cin"      , QStringList() << "Kodak Cineon"                                   << "1");
        setupAvailable[3].insert("*.cut"      , QStringList() << "DR Halo"                                        << "1");
        setupAvailable[3].insert("*.acr"      , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("*.dcm"      , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("*.dicom"    , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("*.dic"      , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("*.dcx"      , QStringList() << "ZSoft IBM PC multi-page Paintbrush image"       << "1");
        setupAvailable[3].insert("*.dib"      , QStringList() << "Microsoft Windows Device Independent Bitmap"    << "1");
        setupAvailable[3].insert("*.dpx"      , QStringList() << "Digital Moving Picture Exchange"                << "1");
        setupAvailable[3].insert("*.epdf"     , QStringList() << "Encapsulated Portable Document Format"          << "0");
        setupAvailable[3].insert("*.fax"      , QStringList() << "Group 3 FAX"                                    << "1");
        setupAvailable[3].insert("*.fits"     , QStringList() << "Flexible Image Transport System"                << "1");
        setupAvailable[3].insert("*.fts"      , QStringList() << "Flexible Image Transport System"                << "1");
        setupAvailable[3].insert("*.fit"      , QStringList() << "Flexible Image Transport System"                << "1");
        setupAvailable[3].insert("*.fpx"      , QStringList() << "FlashPix Format"                                << "1");
        setupAvailable[3].insert("*.jng"      , QStringList() << "JPEG Network Graphics"                          << "1");
        setupAvailable[3].insert("*.mat"      , QStringList() << "MATLAB image format"                            << "1");
        setupAvailable[3].insert("*.miff"     , QStringList() << "Magick image file format"                       << "1");
        setupAvailable[3].insert("*.mono"     , QStringList() << "Bi-level bitmap in least-significant-byte first order" << "0");
        setupAvailable[3].insert("*.mtv"      , QStringList() << "MTV Raytracing image format"                    << "1");
        setupAvailable[3].insert("*.otb"      , QStringList() << "On-the-air Bitmap"                              << "1");
        setupAvailable[3].insert("*.p7"       , QStringList() << "Xv's Visual Schnauzer thumbnail format"         << "1");
        setupAvailable[3].insert("*.palm"     , QStringList() << "Palm pixmap"                                    << "1");
        setupAvailable[3].insert("*.pam"      , QStringList() << "Portable Arbitrary Map format"                  << "1");
        setupAvailable[3].insert("*.pcd"      , QStringList() << "Photo CD"                                       << "1");
        setupAvailable[3].insert("*.pcds"     , QStringList() << "Photo CD"                                       << "1");
        setupAvailable[3].insert("*.pcx"      , QStringList() << "ZSoft IBM PC Paintbrush file"                   << "1");
        setupAvailable[3].insert("*.pdb"      , QStringList() << "Palm Database ImageViewer Format"               << "1");
        setupAvailable[3].insert("*.pict"     , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "0");
        setupAvailable[3].insert("*.pct"      , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "0");
        setupAvailable[3].insert("*.pic"      , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "0");
        setupAvailable[3].insert("*.pix"      , QStringList() << "Alias/Wavefront RLE image format"               << "0");
        setupAvailable[3].insert("*.pal"      , QStringList() << "Alias/Wavefront RLE image format"               << "0");
        setupAvailable[3].insert("*.pnm"      , QStringList() << "Portable anymap"                                << "1");
        setupAvailable[3].insert("*.psd"      , QStringList() << "Adobe Photoshop bitmap file"                    << "0");
        setupAvailable[3].insert("*.ptif"     , QStringList() << "Pyramid encoded TIFF"                           << "1");
        setupAvailable[3].insert("*.ptiff"    , QStringList() << "Pyramid encoded TIFF"                           << "1");
        setupAvailable[3].insert("*.sfw"      , QStringList() << "Seattle File Works image"                       << "1");
        setupAvailable[3].insert("*.sgi"      , QStringList() << "Irix RGB image"                                 << "1");
        setupAvailable[3].insert("*.sun"      , QStringList() << "SUN Rasterfile"                                 << "1");
        setupAvailable[3].insert("*.tga"      , QStringList() << "Truevision Targa image"                         << "1");
        setupAvailable[3].insert("*.vicar"    , QStringList() << "VICAR rasterfile format"                        << "1");
        setupAvailable[3].insert("*.viff"     , QStringList() << "Khoros Visualization Image File Format"         << "0");
        setupAvailable[3].insert("*.wpg"      , QStringList() << "Word Perfect Graphics File"                     << "1");
        setupAvailable[3].insert("*.xwd"      , QStringList() << "X Windows system window dump"                   << "1");
        // The following formats are untested (no test image) and are thus disabled by default, but they might very well work
        setupAvailable[3].insert("*.hp"       , QStringList() << "HP-GL plotter language"                         << "0");
        setupAvailable[3].insert("*.hpgl"     , QStringList() << "HP-GL plotter language"                         << "0");
        setupAvailable[3].insert("*.jbig"     , QStringList() << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.jbg"      , QStringList() << "Joint Bi-level Image experts Group file interchange format" << "0");
        setupAvailable[3].insert("*.pwp"      , QStringList() << "Seattle File Works multi-image file"            << "0");
        setupAvailable[3].insert("*.rast"     , QStringList() << "Sun Raster Image"                               << "0");
        setupAvailable[3].insert("*.rla"      , QStringList() << "Alias/Wavefront image file"                     << "0");
        setupAvailable[3].insert("*.rle"      , QStringList() << "Utah Run length encoded image file"             << "0");
        setupAvailable[3].insert("*.sct"      , QStringList() << "Scitex Continuous Tone Picture"                 << "0");
        setupAvailable[3].insert("*.tim"      , QStringList() << "PSX TIM file"                                   << "0");

        // GraphicsMagick w/ Ghostscript
        setupAvailable[4].insert("*.epi"      , QStringList() << "Adobe Encapsulated PostScript Interchange format"   << "0");
        setupAvailable[4].insert("*.epsi"     , QStringList() << "Adobe Encapsulated PostScript Interchange format"   << "0");
        setupAvailable[4].insert("*.eps"      , QStringList() << "Adobe Encapsulated PostScript"                      << "0");
        setupAvailable[4].insert("*.epsf"     , QStringList() << "Adobe Encapsulated PostScript"                      << "0");
        setupAvailable[4].insert("*.eps2"     , QStringList() << "Adobe Level II Encapsulated PostScript"             << "0");
        setupAvailable[4].insert("*.eps3"     , QStringList() << "Adobe Level III Encapsulated PostScript"            << "0");
        setupAvailable[4].insert("*.ept"      , QStringList() << "Adobe Encapsulated PostScript Interchange format with TIFF preview" << "0");
        setupAvailable[4].insert("*.pdf"      , QStringList() << "Portable Document Format"                           << "0");
        setupAvailable[4].insert("*.ps"       , QStringList() << "Adobe PostScript file"                              << "0");
        setupAvailable[4].insert("*.ps2"      , QStringList() << "Adobe Level II PostScript file"                     << "0");
        setupAvailable[4].insert("*.ps3"      , QStringList() << "Adobe Level III PostScript file"                    << "0");

        // RAW
        setupAvailable[5].insert("*.3fr"      , QStringList() << "Hasselblad"                 << "1");
        setupAvailable[5].insert("*.ari"      , QStringList() << "ARRIFLEX"                   << "1");
        setupAvailable[5].insert("*.arw"      , QStringList() << "Sony"                       << "1");
        setupAvailable[5].insert("*.srf"      , QStringList() << "Sony"                       << "1");
        setupAvailable[5].insert("*.sr2"      , QStringList() << "Sony"                       << "1");
        setupAvailable[5].insert("*.bay"      , QStringList() << "Casio"                      << "1");
        setupAvailable[5].insert("*.crw"      , QStringList() << "Canon"                      << "1");
        setupAvailable[5].insert("*.crr"      , QStringList() << "Canon"                      << "1");
        setupAvailable[5].insert("*.cr2"      , QStringList() << "Canon"                      << "1");
        setupAvailable[5].insert("*.cap"      , QStringList() << "Phase_one"                  << "1");
        setupAvailable[5].insert("*.liq"      , QStringList() << "Phase_one"                  << "1");
        setupAvailable[5].insert("*.eip"      , QStringList() << "Phase_one"                  << "1");
        setupAvailable[5].insert("*.dcs"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("*.dcr"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("*.drf"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("*.k25"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("*.kdc"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("*.dng"      , QStringList() << "Adobe"                      << "1");
        setupAvailable[5].insert("*.erf"      , QStringList() << "Epson"                      << "1");
        setupAvailable[5].insert("*.fff"      , QStringList() << "Imacon/Hasselblad raw"      << "1");
        setupAvailable[5].insert("*.mef"      , QStringList() << "Mamiya"                     << "1");
        setupAvailable[5].insert("*.mdc"      , QStringList() << "Minolta, Agfa"              << "1");
        setupAvailable[5].insert("*.mos"      , QStringList() << "Leaf"                       << "1");
        setupAvailable[5].insert("*.mrw"      , QStringList() << "Minolta, Konica Minolta"    << "1");
        setupAvailable[5].insert("*.nef"      , QStringList() << "Nikon"                      << "1");
        setupAvailable[5].insert("*.nrw"      , QStringList() << "Nikon"                      << "1");
        setupAvailable[5].insert("*.orf"      , QStringList() << "Olympus"                    << "1");
        setupAvailable[5].insert("*.pef"      , QStringList() << "Pentax"                     << "1");
        setupAvailable[5].insert("*.ptx"      , QStringList() << "Pentax"                     << "1");
        setupAvailable[5].insert("*.pxn"      , QStringList() << "Logitech"                   << "1");
        setupAvailable[5].insert("*.r3d"      , QStringList() << "RED Digital Cinema"         << "1");
        setupAvailable[5].insert("*.raf"      , QStringList() << "Fuji"                       << "1");
        setupAvailable[5].insert("*.raw"      , QStringList() << "Panasonic"                  << "1");
        setupAvailable[5].insert("*.rw2"      , QStringList() << "Panasonic"                  << "1");
        setupAvailable[5].insert("*.raw"      , QStringList() << "Leica"                      << "1");
        setupAvailable[5].insert("*.rwl"      , QStringList() << "Leica"                      << "1");
        setupAvailable[5].insert("*.dng"      , QStringList() << "Leica"                      << "1");
        setupAvailable[5].insert("*.rwz"      , QStringList() << "Rawzor"                     << "1");
        setupAvailable[5].insert("*.srw"      , QStringList() << "Samsung"                    << "1");
        setupAvailable[5].insert("*.x3f"      , QStringList() << "Sigma"                      << "1");

        // DevIL
        setupAvailable[6].insert("*.cut"      , QStringList() << "DR Halo"                    << "1");
        setupAvailable[6].insert("*.dds"      , QStringList() << "DirectDraw Surface"         << "1");
        setupAvailable[6].insert("*.lbm"      , QStringList() << "Interlaced Bitmap"          << "1");
        setupAvailable[6].insert("*.lif"      , QStringList() << "Homeworld File"             << "1");
        setupAvailable[6].insert("*.lmp"      , QStringList() << "Doom Walls / Flats"         << "1");
        setupAvailable[6].insert("*.mdl"      , QStringList() << "Half-Life Model"            << "1");
        setupAvailable[6].insert("*.pcd"      , QStringList() << "PhotoCD"                    << "1");
        setupAvailable[6].insert("*.pcx"      , QStringList() << "ZSoft PCX"                  << "1");
        setupAvailable[6].insert("*.pic"      , QStringList() << "Apple Macintosh QuickDraw/PICT file" << "1");
        setupAvailable[6].insert("*.psd"      , QStringList() << "Adobe PhotoShop"            << "1");
        setupAvailable[6].insert("*.bw"       , QStringList() << "Silicon Graphics"           << "1");
        setupAvailable[6].insert("*.rgb"      , QStringList() << "Silicon Graphics"           << "1");
        setupAvailable[6].insert("*.rgba"     , QStringList() << "Silicon Graphics"           << "1");
        setupAvailable[6].insert("*.sgi"      , QStringList() << "Silicon Graphics"           << "1");
        setupAvailable[6].insert("*.tga"      , QStringList() << "Truevision Targa Graphic"   << "1");
        setupAvailable[6].insert("*.wal"      , QStringList() << "Quake2 Texture"             << "1");


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
                availableFileformatsWithDescription[categories.indexOf(cat)].append(QStringList() << val.key() << val.value().at(0));
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
