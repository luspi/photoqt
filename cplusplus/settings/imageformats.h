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

        categories << "qt" << "kde" << "extras" << "gm" << "gmghostscript" << "raw";
        formatsfiles << ConfigFiles::FILEFORMATSQT_FILE() << ConfigFiles::FILEFORMATSKDE_FILE()
                     << ConfigFiles::FILEFORMATSEXTRAS_FILE() << ConfigFiles::FILEFORMATSGM_FILE()
                     << ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE() << ConfigFiles::FILEFORMATSRAW_FILE();

        setupAvailable = new QMap<QString, QStringList>[categories.length()];


        // Qt
        setupAvailable[0].insert("bmp"     , QStringList() << "Microsoft Windows bitmap"                        << "1");
        setupAvailable[0].insert("bitmap"  , QStringList() << "Microsoft Windows bitmap"                        << "1");
        setupAvailable[0].insert("gif"     , QStringList() << "CompuServe Graphics Interchange Format"          << "1");
        setupAvailable[0].insert("jp2"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("jpc"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("j2k"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("jpeg2000", QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("jpx"     , QStringList() << "JPEG-2000 Code Stream Syntax"                    << "1");
        setupAvailable[0].insert("mng"     , QStringList() << "Multiple-image Network Graphics"                 << "1");
        setupAvailable[0].insert("ico"     , QStringList() << "Microsoft icon"                                  << "1");
        setupAvailable[0].insert("cur"     , QStringList() << "Microsoft icon"                                  << "1");
        setupAvailable[0].insert("icns"    , QStringList() << "Macintosh OS X icon"                             << "1");
        setupAvailable[0].insert("jpeg"    , QStringList() << "Joint Photographic Experts Group JFIF format"    << "1");
        setupAvailable[0].insert("jpg"     , QStringList() << "Joint Photographic Experts Group JFIF format"    << "1");
        setupAvailable[0].insert("jpe"     , QStringList() << "Joint Photographic Experts Group JFIF format"    << "1");
        setupAvailable[0].insert("png"     , QStringList() << "Portable Network Graphics"                       << "1");
        setupAvailable[0].insert("pbm"     , QStringList() << "Portable bitmap format (black and white)"        << "1");
        setupAvailable[0].insert("pgm"     , QStringList() << "Portable graymap format (gray scale)"            << "1");
        setupAvailable[0].insert("ppm"     , QStringList() << "Portable pixmap format (color)"                  << "1");
        setupAvailable[0].insert("pnm"     , QStringList() << "Portable anymap (pbm, pgm, or ppm)"              << "1");
        setupAvailable[0].insert("svg"     , QStringList() << "Scalable Vector Graphics"                        << "1");
        setupAvailable[0].insert("svgz"    , QStringList() << "Scalable Vector Graphics"                        << "1");
        setupAvailable[0].insert("tga"     , QStringList() << "Truevision Targa Graphic"                        << "1");
        setupAvailable[0].insert("tif"     , QStringList() << "Tagged Image File Format"                        << "1");
        setupAvailable[0].insert("tiff"    , QStringList() << "Tagged Image File Format"                        << "1");
        setupAvailable[0].insert("wbmp"    , QStringList() << "Wireless bitmap"                                 << "1");
        setupAvailable[0].insert("webp"    , QStringList() << "Google web image format"                         << "1");
        setupAvailable[0].insert("xbm"     , QStringList() << "X Windows system bitmap, black and white only"   << "1");
        setupAvailable[0].insert("xpm"     , QStringList() << "X Windows system pixmap"                         << "1");

        // KDE
        setupAvailable[1].insert("eps"     , QStringList() << "Adobe Encapsulated PostScript"                   << "1");
        setupAvailable[1].insert("epsf"    , QStringList() << "Adobe Encapsulated PostScript"                   << "1");
        setupAvailable[1].insert("epsi"    , QStringList() << "Adobe Encapsulated PostScript"                   << "1");
        setupAvailable[1].insert("exr"     , QStringList() << "OpenEXR"                                         << "1");
        setupAvailable[1].insert("kra"     , QStringList() << "Krita Document"                                  << "1");
        setupAvailable[1].insert("ora"     , QStringList() << "Open Raster Image File"                          << "1");
        setupAvailable[1].insert("pcx"     , QStringList() << "ZSoft PCX"                                       << "1");
        setupAvailable[1].insert("pic"     , QStringList() << "Apple Macintosh QuickDraw/PICT file"             << "1");
        setupAvailable[1].insert("psd"     , QStringList() << "Adobe PhotoShop"                                 << "1");
        setupAvailable[1].insert("ras"     , QStringList() << "Sun Graphics"                                    << "1");
        setupAvailable[1].insert("bw"      , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("rgb"     , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("rgba"    , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("sgi"     , QStringList() << "Silicon Graphics"                                << "1");
        setupAvailable[1].insert("tga"     , QStringList() << "Truevision Targa Graphic"                        << "1");
        setupAvailable[1].insert("xcf"     , QStringList() << "Gimp format"                                     << "1");

        // Extras
        setupAvailable[2].insert("psb"     , QStringList() << "Adobe PhotoShop - Makes use of 'libqpsd'"        << "0");
        setupAvailable[2].insert("psd"     , QStringList() << "Adobe PhotoShop - Makes use of 'libqpsd'"        << "0");
        setupAvailable[2].insert("xcf"     , QStringList() << "Gimp format - Makes use of 'xcftoold'"           << "0");

        // GraphicsMagick
        setupAvailable[3].insert("avs"      , QStringList() << "AVS X image"                                    << "1");
        setupAvailable[3].insert("x"        , QStringList() << "AVS X image"                                    << "0");
        setupAvailable[3].insert("cals"     , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"   << "1");
        setupAvailable[3].insert("cal"      , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"   << "1");
        setupAvailable[3].insert("dcl"      , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"   << "1");
        setupAvailable[3].insert("cin"      , QStringList() << "Kodak Cineon"                                   << "1");
        setupAvailable[3].insert("cut"      , QStringList() << "DR Halo"                                        << "1");
        setupAvailable[3].insert("acr"      , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("dcm"      , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("dicom"    , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("dic"      , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image" << "1");
        setupAvailable[3].insert("dcx"      , QStringList() << "ZSoft IBM PC multi-page Paintbrush image"       << "1");
        setupAvailable[3].insert("dib"      , QStringList() << "Microsoft Windows Device Independent Bitmap"    << "1");
        setupAvailable[3].insert("dpx"      , QStringList() << "Digital Moving Picture Exchange"                << "1");
        setupAvailable[3].insert("epdf"     , QStringList() << "Encapsulated Portable Document Format"          << "0");
        setupAvailable[3].insert("fax"      , QStringList() << "Group 3 FAX"                                    << "1");
        setupAvailable[3].insert("fits"     , QStringList() << "Flexible Image Transport System"                << "1");
        setupAvailable[3].insert("fts"      , QStringList() << "Flexible Image Transport System"                << "1");
        setupAvailable[3].insert("fit"      , QStringList() << "Flexible Image Transport System"                << "1");
        setupAvailable[3].insert("fpx"      , QStringList() << "FlashPix Format"                                << "1");
        setupAvailable[3].insert("jng"      , QStringList() << "JPEG Network Graphics"                          << "1");
        setupAvailable[3].insert("mat"      , QStringList() << "MATLAB image format"                            << "1");
        setupAvailable[3].insert("miff"     , QStringList() << "Magick image file format"                       << "1");
        setupAvailable[3].insert("mono"     , QStringList() << "Bi-level bitmap in least-significant-byte first order"        << "0");
        setupAvailable[3].insert("mtv"      , QStringList() << "MTV Raytracing image format"                    << "1");
        setupAvailable[3].insert("otb"      , QStringList() << "On-the-air Bitmap"                              << "1");
        setupAvailable[3].insert("p7"       , QStringList() << "Xv's Visual Schnauzer thumbnail format"         << "1");
        setupAvailable[3].insert("palm"     , QStringList() << "Palm pixmap"                                    << "1");
        setupAvailable[3].insert("pam"      , QStringList() << "Portable Arbitrary Map format"                  << "1");
        setupAvailable[3].insert("pcd"      , QStringList() << "Photo CD"                                       << "1");
        setupAvailable[3].insert("pcds"     , QStringList() << "Photo CD"                                       << "1");
        setupAvailable[3].insert("pcx"      , QStringList() << "ZSoft IBM PC Paintbrush file"                   << "1");
        setupAvailable[3].insert("pdb"      , QStringList() << "Palm Database ImageViewer Format"               << "1");
        setupAvailable[3].insert("pict"     , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "0");
        setupAvailable[3].insert("pct"      , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "0");
        setupAvailable[3].insert("pic"      , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "0");
        setupAvailable[3].insert("pix"      , QStringList() << "Alias/Wavefront RLE image format"               << "0");
        setupAvailable[3].insert("pal"      , QStringList() << "Alias/Wavefront RLE image format"               << "0");
        setupAvailable[3].insert("pnm"      , QStringList() << "Portable anymap"                                << "1");
        setupAvailable[3].insert("psd"      , QStringList() << "Adobe Photoshop bitmap file"                    << "0");
        setupAvailable[3].insert("ptif"     , QStringList() << "Pyramid encoded TIFF"                           << "1");
        setupAvailable[3].insert("ptiff"    , QStringList() << "Pyramid encoded TIFF"                           << "1");
        setupAvailable[3].insert("sfw"      , QStringList() << "Seattle File Works image"                       << "1");
        setupAvailable[3].insert("sgi"      , QStringList() << "Irix RGB image"                                 << "1");
        setupAvailable[3].insert("sun"      , QStringList() << "SUN Rasterfile"                                 << "1");
        setupAvailable[3].insert("tga"      , QStringList() << "Truevision Targa image"                         << "1");
        setupAvailable[3].insert("vicar"    , QStringList() << "VICAR rasterfile format"                        << "1");
        setupAvailable[3].insert("viff"     , QStringList() << "Khoros Visualization Image File Format"         << "0");
        setupAvailable[3].insert("wpg"      , QStringList() << "Word Perfect Graphics File"                     << "1");
        setupAvailable[3].insert("xwd"      , QStringList() << "X Windows system window dump"                   << "1");

        // GraphicsMagick w/ Ghostscript
        setupAvailable[4].insert("epi"      , QStringList() << "Adobe Encapsulated PostScript Interchange format"   << "0");
        setupAvailable[4].insert("epsi"     , QStringList() << "Adobe Encapsulated PostScript Interchange format"   << "0");
        setupAvailable[4].insert("eps"      , QStringList() << "Adobe Encapsulated PostScript"                      << "0");
        setupAvailable[4].insert("epsf"     , QStringList() << "Adobe Encapsulated PostScript"                      << "0");
        setupAvailable[4].insert("eps2"     , QStringList() << "Adobe Level II Encapsulated PostScript"             << "0");
        setupAvailable[4].insert("eps3"     , QStringList() << "Adobe Level III Encapsulated PostScript"            << "0");
        setupAvailable[4].insert("ept"      , QStringList() << "Adobe Encapsulated PostScript Interchange format with TIFF preview" << "0");
        setupAvailable[4].insert("pdf"      , QStringList() << "Portable Document Format"                           << "0");
        setupAvailable[4].insert("ps"       , QStringList() << "Adobe PostScript file"                              << "0");
        setupAvailable[4].insert("ps2"      , QStringList() << "Adobe Level II PostScript file"                     << "0");
        setupAvailable[4].insert("ps3"      , QStringList() << "Adobe Level III PostScript file"                    << "0");

        // RAW
        setupAvailable[5].insert("3fr"      , QStringList() << "Hasselblad"                 << "1");
        setupAvailable[5].insert("ari"      , QStringList() << "ARRIFLEX"                   << "1");
        setupAvailable[5].insert("arw"      , QStringList() << "Sony"                       << "1");
        setupAvailable[5].insert("srf"      , QStringList() << "Sony"                       << "1");
        setupAvailable[5].insert("sr2"      , QStringList() << "Sony"                       << "1");
        setupAvailable[5].insert("bay"      , QStringList() << "Casio"                      << "1");
        setupAvailable[5].insert("crw"      , QStringList() << "Canon"                      << "1");
        setupAvailable[5].insert("crr"      , QStringList() << "Canon"                      << "1");
        setupAvailable[5].insert("cr2"      , QStringList() << "Canon"                      << "1");
        setupAvailable[5].insert("cap"      , QStringList() << "Phase_one"                  << "1");
        setupAvailable[5].insert("liq"      , QStringList() << "Phase_one"                  << "1");
        setupAvailable[5].insert("eip"      , QStringList() << "Phase_one"                  << "1");
        setupAvailable[5].insert("dcs"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("dcr"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("drf"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("k25"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("kdc"      , QStringList() << "Kodak"                      << "1");
        setupAvailable[5].insert("dng"      , QStringList() << "Adobe"                      << "1");
        setupAvailable[5].insert("erf"      , QStringList() << "Epson"                      << "1");
        setupAvailable[5].insert("fff"      , QStringList() << "Imacon/Hasselblad raw"      << "1");
        setupAvailable[5].insert("mef"      , QStringList() << "Mamiya"                     << "1");
        setupAvailable[5].insert("mdc"      , QStringList() << "Minolta, Agfa"              << "1");
        setupAvailable[5].insert("mos"      , QStringList() << "Leaf"                       << "1");
        setupAvailable[5].insert("mrw"      , QStringList() << "Minolta, Konica Minolta"    << "1");
        setupAvailable[5].insert("nef"      , QStringList() << "Nikon"                      << "1");
        setupAvailable[5].insert("nrw"      , QStringList() << "Nikon"                      << "1");
        setupAvailable[5].insert("orf"      , QStringList() << "Olympus"                    << "1");
        setupAvailable[5].insert("pef"      , QStringList() << "Pentax"                     << "1");
        setupAvailable[5].insert("ptx"      , QStringList() << "Pentax"                     << "1");
        setupAvailable[5].insert("pxn"      , QStringList() << "Logitech"                   << "1");
        setupAvailable[5].insert("r3d"      , QStringList() << "RED Digital Cinema"         << "1");
        setupAvailable[5].insert("raf"      , QStringList() << "Fuji"                       << "1");
        setupAvailable[5].insert("raw"      , QStringList() << "Panasonic"                  << "1");
        setupAvailable[5].insert("rw2"      , QStringList() << "Panasonic"                  << "1");
        setupAvailable[5].insert("raw"      , QStringList() << "Leica"                      << "1");
        setupAvailable[5].insert("rwl"      , QStringList() << "Leica"                      << "1");
        setupAvailable[5].insert("dng"      , QStringList() << "Leica"                      << "1");
        setupAvailable[5].insert("rwz"      , QStringList() << "Rawzor"                     << "1");
        setupAvailable[5].insert("srw"      , QStringList() << "Samsung"                    << "1");
        setupAvailable[5].insert("x3f"      , QStringList() << "Sigma"                      << "1");



        availableFileformats = new QVariantList[categories.length()];
        availableFileformatsWithDescription = new QVariantList[categories.length()];
        enabledFileformats = new QVariantList[categories.length()];
        defaultEnabledFileformats = new QVariantList[categories.length()];

        composeAvailableFormats();
        composeEnabledFormats();

        saveTimer = new QTimer;
        saveTimer->setSingleShot(true);
        saveTimer->setInterval(500);
        connect(saveTimer, &QTimer::timeout, this, &ImageFormats::saveEnabledFormats);

        connect(this, SIGNAL(enabledFileformatsQtChanged(QVariantList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsKDEChanged(QVariantList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsExtrasChanged(QVariantList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsGmChanged(QVariantList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsGmGhostscriptChanged(QVariantList)), saveTimer, SLOT(start()));
        connect(this, SIGNAL(enabledFileformatsRAWChanged(QVariantList)), saveTimer, SLOT(start()));

    }

    void setEnabledFileformats(QString cat, QVariantList val) {
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
    }

    // All possibly available file formats for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsQt() { return availableFileformats[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsKDE() { return availableFileformats[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsExtras() { return availableFileformats[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGm() { return availableFileformats[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGmGhostscript() { return availableFileformats[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsRAW() { return availableFileformats[categories.indexOf("raw")]; }

    // All possibly available file formats INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionQt() { return availableFileformatsWithDescription[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionKDE() { return availableFileformatsWithDescription[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionExtras() { return availableFileformatsWithDescription[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGm() { return availableFileformatsWithDescription[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGmGhostscript() { return availableFileformatsWithDescription[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionRAW() { return availableFileformatsWithDescription[categories.indexOf("raw")]; }

    // All currently enabled file formats for ...
    // ... Qt
    Q_PROPERTY(QVariantList enabledFileformatsQt READ getEnabledFileformatsQt WRITE setEnabledFileformatsQt NOTIFY enabledFileformatsQtChanged)
    QVariantList getEnabledFileformatsQt() { return enabledFileformats[categories.indexOf("qt")]; }
    void setEnabledFileformatsQt(QVariantList val) { enabledFileformats[categories.indexOf("qt")] = val; emit enabledFileformatsQtChanged(val); }
    // ... KDE
    Q_PROPERTY(QVariantList enabledFileformatsKDE READ getEnabledFileformatsKDE WRITE setEnabledFileformatsKDE NOTIFY enabledFileformatsKDEChanged)
    QVariantList getEnabledFileformatsKDE() { return enabledFileformats[categories.indexOf("kde")]; }
    void setEnabledFileformatsKDE(QVariantList val) { enabledFileformats[categories.indexOf("kde")] = val; emit enabledFileformatsKDEChanged(val); }
    // ... Extras
    Q_PROPERTY(QVariantList enabledFileformatsExtras READ getEnabledFileformatsExtras WRITE setEnabledFileformatsExtras NOTIFY enabledFileformatsExtrasChanged)
    QVariantList getEnabledFileformatsExtras() { return enabledFileformats[categories.indexOf("extras")]; }
    void setEnabledFileformatsExtras(QVariantList val) { enabledFileformats[categories.indexOf("extras")] = val; emit enabledFileformatsExtrasChanged(val); }
    // ... GraphicsMagick
    Q_PROPERTY(QVariantList enabledFileformatsGm READ getEnabledFileformatsGm WRITE setEnabledFileformatsGm NOTIFY enabledFileformatsGmChanged)
    QVariantList getEnabledFileformatsGm() { return enabledFileformats[categories.indexOf("gm")]; }
    void setEnabledFileformatsGm(QVariantList val) { enabledFileformats[categories.indexOf("gm")] = val; emit enabledFileformatsGmChanged(val); }
    // ... GraphicsMagick w/ Ghostscript
    Q_PROPERTY(QVariantList enabledFileformatsGmGhostscript READ getEnabledFileformatsGmGhostscript WRITE setEnabledFileformatsGmGhostscript NOTIFY enabledFileformatsGmGhostscriptChanged)
    QVariantList getEnabledFileformatsGmGhostscript() { return enabledFileformats[categories.indexOf("gmghostscript")]; }
    void setEnabledFileformatsGmGhostscript(QVariantList val) { enabledFileformats[categories.indexOf("gmghostscript")] = val; emit enabledFileformatsGmGhostscriptChanged(val); }
    // ... RAW
    Q_PROPERTY(QVariantList enabledFileformatsRAW READ getEnabledFileformatsRAW WRITE setEnabledFileformatsRAW NOTIFY enabledFileformatsRAWChanged)
    QVariantList getEnabledFileformatsRAW() { return enabledFileformats[categories.indexOf("raw")]; }
    void setEnabledFileformatsRAW(QVariantList val) { enabledFileformats[categories.indexOf("raw")] = val; emit enabledFileformatsRAWChanged(val); }

    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultFileformats() {
        setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
        setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]);
        setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]);
        setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]);
        setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]);
        setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]);
    }

signals:
    void enabledFileformatsQtChanged(QVariantList val);
    void enabledFileformatsKDEChanged(QVariantList val);
    void enabledFileformatsExtrasChanged(QVariantList val);
    void enabledFileformatsGmChanged(QVariantList val);
    void enabledFileformatsGmGhostscriptChanged(QVariantList val);
    void enabledFileformatsRAWChanged(QVariantList val);

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
    QVariantList *enabledFileformats;

    // This is not accessible from outside. They are used when, e.g., the respective disabled fileformats file doesn't exist or when the settings are reset.
    QVariantList *defaultEnabledFileformats;

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
            QVariantList setTheseAsEnabled;

            // Read disabled formats, remove "*." (if it is there) and split into each line
            QTextStream in(&disabledfile);
            QStringList alldisabled = in.readAll().replace("*.","").split("\n", QString::SkipEmptyParts);


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
                if(!enabledFileformats[categories.indexOf(cat)].contains(avail))
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
