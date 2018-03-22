#include "mimetypes.h"

MimeTypes::MimeTypes(QObject *parent) : QObject(parent) {

    categories << "qt" << "xcftools" << "poppler" << "gm" << "gmghostscript"
               << "raw" << "devil" << "freeimage" << "quazip";

    setupAvailable = new QMap<QString, QStringList>[categories.length()];

    QList<QByteArray> imageReaderSupported = QImageReader::supportedImageFormats();

    /************************************************************/
    /************************************************************/
    // Qt (incl. plugins, like qt5-imageformats, KDE, libqpsd)
    if(imageReaderSupported.contains("bmp"))
        setupAvailable[0].insert("image/bmp"                , QStringList() << "Microsoft Windows bitmap"                       << "1");
    if(imageReaderSupported.contains("gif"))
        setupAvailable[0].insert("image/gif"                , QStringList() << "CompuServe Graphics Interchange Format"         << "1");
    if(imageReaderSupported.contains("jp2"))
        setupAvailable[0].insert("image/jp2"                , QStringList() << "JPEG-2000 Code Stream Syntax"                   << "1");
    if(imageReaderSupported.contains("mng"))
        setupAvailable[0].insert("video/x-mng"              , QStringList() << "Multiple-image Network Graphics"                << "1");
    if(imageReaderSupported.contains("ico"))
        setupAvailable[0].insert("image/vnd.microsoft.icon" , QStringList() << "Microsoft icon"                                 << "1");
    if(imageReaderSupported.contains("cur"))
        setupAvailable[0].insert("image/x-win-bitmap"       , QStringList() << "Microsoft icon"                                 << "1");
    if(imageReaderSupported.contains("icns"))
        setupAvailable[0].insert("image/x-icns"             , QStringList() << "Macintosh OS X icon"                            << "1");
    if(imageReaderSupported.contains("jpeg") || imageReaderSupported.contains("jpg"))
        setupAvailable[0].insert("image/jpeg"               , QStringList() << "Joint Photographic Experts Group JFIF format"   << "1");
    if(imageReaderSupported.contains("png"))
        setupAvailable[0].insert("image/png"                , QStringList() << "Portable Network Graphics"                      << "1");
    if(imageReaderSupported.contains("pbm"))
        setupAvailable[0].insert("image/x-portable-bitmap"  , QStringList() << "Portable bitmap format (black and white)"       << "1");
    if(imageReaderSupported.contains("pgm"))
        setupAvailable[0].insert("image/x-portable-graymap" , QStringList() << "Portable graymap format (gray scale)"           << "1");
    if(imageReaderSupported.contains("ppm"))
        setupAvailable[0].insert("image/x-portable-pixmap"  , QStringList() << "Portable pixmap format (color)"                 << "1");
    if(imageReaderSupported.contains("pbm") || imageReaderSupported.contains("pgm") || imageReaderSupported.contains("ppm"))
        setupAvailable[0].insert("image/x-portable-anymap"  , QStringList() << "Portable anymap (pbm, pgm, or ppm)"             << "1");
    if(imageReaderSupported.contains("svg") || imageReaderSupported.contains("svgz"))
        setupAvailable[0].insert("image/svg+xml"            , QStringList() << "Scalable Vector Graphics"                       << "1");
    if(imageReaderSupported.contains("tga"))
        setupAvailable[0].insert("image/x-tga"              , QStringList() << "Truevision Targa Graphic"                       << "1");
    if(imageReaderSupported.contains("tif") || imageReaderSupported.contains("tiff"))
        setupAvailable[0].insert("image/tiff"               , QStringList() << "Tagged Image File Format"                       << "1");
    if(imageReaderSupported.contains("wbmp"))
        setupAvailable[0].insert("image/vnd.wap.wbmp"       , QStringList() << "Wireless bitmap"                                << "1");
    if(imageReaderSupported.contains("xbm"))
        setupAvailable[0].insert("image/x-xbitmap"          , QStringList() << "X Windows system bitmap, black and white only"  << "1");
    if(imageReaderSupported.contains("xpm"))
        setupAvailable[0].insert("image/x-xpixmap"          , QStringList() << "X Windows system pixmap"                        << "1");
    if(imageReaderSupported.contains("eps") || imageReaderSupported.contains("epsf") || imageReaderSupported.contains("epsi"))
        setupAvailable[0].insert("image/x-eps"              , QStringList() << "Adobe Encapsulated PostScript"                  << "1");
    if(imageReaderSupported.contains("exr"))
        setupAvailable[0].insert("image/x-exr"              , QStringList() << "OpenEXR"                                        << "1");
    if(imageReaderSupported.contains("ora"))
        setupAvailable[0].insert("image/openraster"         , QStringList() << "Open Raster Image File"                         << "1");
    if(imageReaderSupported.contains("pcx"))
        setupAvailable[0].insert("image/vnd.zbrush.pcx"     , QStringList() << "ZSoft PCX"                                      << "1");
    if(imageReaderSupported.contains("psd") || imageReaderSupported.contains("psb"))
        setupAvailable[0].insert("image/vnd.adobe.photoshop", QStringList() << "Adobe PhotoShop"                                << "1");
    if(imageReaderSupported.contains("sgi"))
        setupAvailable[0].insert("image/x-sgi"              , QStringList() << "Silicon Graphics"                               << "1");
    if(imageReaderSupported.contains("tga"))
        setupAvailable[0].insert("image/x-tga"              , QStringList() << "Truevision Targa Graphic"                       << "1");
    if(imageReaderSupported.contains("xcf"))
        setupAvailable[0].insert("image/x-xcf"              , QStringList() << "Gimp format"                                    << "1");
#ifndef FREEIMAGE
    // CAUSES CRASH when FreeImage is enabled:
    if(imageReaderSup.contains("webp"))
        setupAvailable[0].insert("image/webp"               , QStringList() << "Google web image format"                        << "1");
#endif
    // FAILS TO LOAD test image:
    if(imageReaderSupported.contains("kra"))
        setupAvailable[0].insert("application/x-krita"      , QStringList() << "Krita Document"                                 << "0");
    if(imageReaderSupported.contains("pic"))
        setupAvailable[0].insert("image/x-pict"             , QStringList() << "Apple Macintosh QuickDraw/PICT file"            << "0");
    if(imageReaderSupported.contains("ras"))
        setupAvailable[0].insert("image/x-cmu-raster"       , QStringList() << "Sun Graphics"                                   << "0");


    /************************************************************/
    /************************************************************/
    // xcftools
    setupAvailable[1].insert("image/x-xcf"                  , QStringList() << "Gimp format - Makes use of 'xcftools'"          << "0");

    /************************************************************/
    /************************************************************/
    // poppler
    setupAvailable[2].insert("application/pdf"              , QStringList() << "Portable Document Format - Makes use of 'poppler'"  << "1");

    /************************************************************/
    /************************************************************/
    // GraphicsMagick
    setupAvailable[3].insert("image/bmp"                    , QStringList() << "Microsoft Windows bitmap"                       << "1");
    setupAvailable[3].insert("image/rle"                    , QStringList() << "Microsoft Windows RLE-compressed bitmap"        << "1");
    setupAvailable[3].insert("image/x-cmu-raster"           , QStringList() << "Continuous Acquisition and Life-cycle Support Type 1 image"     << "1");
    setupAvailable[3].insert("application/dicom"            , QStringList() << "Digital Imaging and Communications in Medicine (DICOM) image"   << "1");
    setupAvailable[3].insert("image/dpx"                    , QStringList() << "Digital Moving Picture Exchange"                << "1");
    setupAvailable[3].insert("image/fax-g3"                 , QStringList() << "Group 3 FAX"                                    << "1");
    setupAvailable[3].insert("image/fits"                   , QStringList() << "Flexible Image Transport System"                << "1");
    setupAvailable[3].insert("image/gif"                    , QStringList() << "CompuServe Graphics Interchange Format"         << "1");
    setupAvailable[3].insert("image/x-jng"                  , QStringList() << "JPEG Network Graphics"                          << "1");
    setupAvailable[3].insert("image/jp2"                    , QStringList() << "JPEG-2000 JP2 File Format Syntax"               << "1");
    setupAvailable[3].insert("image/jpeg"                   , QStringList() << "Joint Photographic Experts Group JFIF format"   << "1");
    setupAvailable[3].insert("application/x-mif"            , QStringList() << "Magick image file format"                       << "1");
    setupAvailable[3].insert("video/x-mng"                  , QStringList() << "Multiple-image Network Graphics"                << "1");
    setupAvailable[3].insert("image/x-portable-bitmap"      , QStringList() << "Portable bitmap format (black and white)"       << "1");
    setupAvailable[3].insert("image/x-photo-cd"             , QStringList() << "Photo CD"                                       << "1");
    setupAvailable[3].insert("image/vnd.zbrush.pcx"         , QStringList() << "ZSoft IBM PC Paintbrush file"                   << "1");
    setupAvailable[3].insert("image/x-portable-graymap"     , QStringList() << "Portable graymap format (gray scale)"           << "1");
    setupAvailable[3].insert("image/x-xpixmap"              , QStringList() << "Personal Icon"                                  << "1");
    setupAvailable[3].insert("image/x-portable-pixmap"      , QStringList() << "Portable pixmap format (color)"                 << "1");
    setupAvailable[3].insert("image/x-portable-anymap"      , QStringList() << "Portable pixmap format (pbm, pgm, or ppm)"      << "1");
    setupAvailable[3].insert("image/x-pict"                 , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "1");
    setupAvailable[3].insert("image/png"                    , QStringList() << "Portable Network Graphics"                      << "1");
    setupAvailable[3].insert("audio/vnd.dts.hd"             , QStringList() << "Seattle File Works image"                       << "1");
    setupAvailable[3].insert("text/x-mpsub"                 , QStringList() << "Alias/Wavefront RLE image format"               << "1");
    setupAvailable[3].insert("image/rle"                    , QStringList() << "Utah Run length encoded image file"             << "1");
    setupAvailable[3].insert("image/x-sgi"                  , QStringList() << "Irix RGB image"                                 << "1");
    setupAvailable[3].insert("image/x-sun-raster"           , QStringList() << "SUN Rasterfile"                                 << "1");
    setupAvailable[3].insert("image/x-tga"                  , QStringList() << "Truevision Targa image"                         << "1");
    setupAvailable[3].insert("image/tiff"                   , QStringList() << "Tagged Image File Format"                       << "1");
    setupAvailable[3].insert("image/vnd.wap.wbmp"           , QStringList() << "Wireless Bitmap"                                << "1");
    setupAvailable[3].insert("image/webp"                   , QStringList() << "Google web image format"                        << "1");
    setupAvailable[3].insert("application/x-wpg"            , QStringList() << "Word Perfect Graphics File"                     << "1");
    setupAvailable[3].insert("image/x-xbitmap"              , QStringList() << "X Windows system bitmap, black and white only"  << "1");
    setupAvailable[3].insert("image/x-xpixmap"              , QStringList() << "X Windows system pixmap"                        << "1");
    setupAvailable[3].insert("image/x-xwindowdump"          , QStringList() << "X Windows system window dump"                   << "1");

    /************************************************************/
    /************************************************************/
    // GraphicsMagick w/ Ghostscript
    setupAvailable[4].insert("image/x-eps"                  , QStringList() << "Adobe Encapsulated PostScript"                 << "0");
    setupAvailable[4].insert("application/pdf"              , QStringList() << "Portable Document Format"                      << "0");
    setupAvailable[4].insert("application/postscript"       , QStringList() << "Adobe PostScript file"                         << "0");

    /************************************************************/
    /************************************************************/
    // RAW
    setupAvailable[5].insert("image/x-sony-arw"             , QStringList() << "Sony"                       << "1");
    setupAvailable[5].insert("image/x-sony-sr2"             , QStringList() << "Sony"                       << "1");
    setupAvailable[5].insert("image/x-canon-crw"            , QStringList() << "Canon"                      << "1");
    setupAvailable[5].insert("image/x-canon-cr2"            , QStringList() << "Canon"                      << "1");
    setupAvailable[5].insert("image/x-kodak-dcr"            , QStringList() << "Kodak"                      << "1");
    setupAvailable[5].insert("image/x-kodak-kdc"            , QStringList() << "Kodak"                      << "1");
    setupAvailable[5].insert("image/x-adobe-dng"            , QStringList() << "Adobe"                      << "1");
    setupAvailable[5].insert("image/x-kde-raw"              , QStringList() << "Epson, Leaf, Minolta, Agfa" << "1");
    setupAvailable[5].insert("image/x-minolta-mrw"          , QStringList() << "Minolta, Konica Minolta"    << "1");
    setupAvailable[5].insert("image/x-nikon-nef"            , QStringList() << "Nikon"                      << "1");
    setupAvailable[5].insert("image/x-olympus-orf"          , QStringList() << "Olympus"                    << "1");
    setupAvailable[5].insert("image/x-pentax-pef"           , QStringList() << "Pentax"                     << "1");
    setupAvailable[5].insert("image/x-fuji-raf"             , QStringList() << "Fuji"                       << "1");
    setupAvailable[5].insert("image/x-panasonic-rw2"        , QStringList() << "Panasonic"                  << "1");
    setupAvailable[5].insert("image/x-panasonic-rw"         , QStringList() << "Panasonic, Leica"           << "1");
    setupAvailable[5].insert("image/x-adobe-dng"            , QStringList() << "Leica"                      << "1");
    setupAvailable[5].insert("image/x-sigma-x3f"            , QStringList() << "Sigma"                      << "1");

    /************************************************************/
    /************************************************************/
    // DevIL
    setupAvailable[6].insert("image/bmp"                    , QStringList() << "Microsoft Windows bitmap"                       << "1");
    setupAvailable[6].insert("image/x-dds"                  , QStringList() << "DirectDraw Surface"                             << "1");
    setupAvailable[6].insert("image/x-exr"                  , QStringList() << "OpenEXR"                                        << "1");
    setupAvailable[6].insert("image/fits"                   , QStringList() << "Flexible Image Transport System"                << "1");
    setupAvailable[6].insert("image/x-hdr"                  , QStringList() << "Radiance High Dynamic"                          << "1");
    setupAvailable[6].insert("image/x-icns"                 , QStringList() << "Macintosh icon"                                 << "1");
    setupAvailable[6].insert("image/vnd.microsoft.icon"     , QStringList() << "Windows icon/cursor"                            << "1");
    setupAvailable[6].insert("image/x-win-bitmap"           , QStringList() << "Windows icon/cursor"                            << "1");
    setupAvailable[6].insert("image/x-ilbm"                 , QStringList() << "Interlaced Bitmap"                              << "1");
    setupAvailable[6].insert("image/gif"                    , QStringList() << "Graphics Interchange Format"                    << "1");
    setupAvailable[6].insert("image/jpeg"                   , QStringList() << "Joint Photographic Experts Group JFIF format"   << "1");
    setupAvailable[6].insert("image/jp2"                    , QStringList() << "JPEG-2000 JP2 File Format Syntax"               << "0");
    setupAvailable[6].insert("image/x-photo-cd"             , QStringList() << "Kodak PhotoCD"                                  << "1");
    setupAvailable[6].insert("image/png"                    , QStringList() << "Portable Network Graphics"                      << "1");
    setupAvailable[6].insert("image/x-portable-bitmap"      , QStringList() << "Portable bitmap format (black and white)"       << "1");
    setupAvailable[6].insert("image/x-portable-graymap"     , QStringList() << "Portable graymap format (gray scale)"           << "1");
    setupAvailable[6].insert("image/x-portable-pixmap"      , QStringList() << "Portable pixmap format (color)"                 << "1");
    setupAvailable[6].insert("image/x-portable-anymap"      , QStringList() << "Portable pixmap format (pbm, pgm, or ppm)"      << "1");
    setupAvailable[6].insert("image/vnd.adobe.photoshop"    , QStringList() << "Adobe PhotoShop"                                << "1");
    setupAvailable[6].insert("image/x-panasonic-rw"         , QStringList() << "Raw data"                                       << "1");
    setupAvailable[6].insert("image/x-sgi"                  , QStringList() << "Silicon Graphics"                               << "1");
    setupAvailable[6].insert("image/x-tga"                  , QStringList() << "Truevision Targa Graphic"                       << "1");
    setupAvailable[6].insert("image/tiff"                   , QStringList() << "Tagged Image File Format"                       << "1");

    /************************************************************/
    /************************************************************/
    // FreeImage
    setupAvailable[7].insert("image/bmp"                    , QStringList() << "Microsoft Windows bitmap"                       << "1");
    setupAvailable[7].insert("image/x-dds"                  , QStringList() << "DirectDraw Surface"                             << "1");
    setupAvailable[7].insert("image/fax-g3"                 , QStringList() << "Raw Fax"                                        << "1");
    setupAvailable[7].insert("image/gif"                    , QStringList() << "CompuServe Graphics Interchange Format"         << "1");
    setupAvailable[7].insert("image/vnd.microsoft.icon"     , QStringList() << "Windows icon/cursor"                            << "1");
    setupAvailable[7].insert("image/x-ilbm"                 , QStringList() << "Interchange File Format"                        << "1");
    setupAvailable[7].insert("image/x-jng"                  , QStringList() << "JPEG Network Graphics"                          << "1");
    setupAvailable[7].insert("image/jpeg"                   , QStringList() << "Joint Photographic Experts Group JFIF format"   << "1");
    setupAvailable[7].insert("image/jp2"                    , QStringList() << "JPEG-2000 JP2 File Format Syntax"               << "1");
    setupAvailable[7].insert("image/x-photo-cd"             , QStringList() << "Kodak PhotoCD"                                  << "1");
    setupAvailable[7].insert("video/x-mng"                  , QStringList() << "Multiple-image Network Graphics"                << "1");
    setupAvailable[7].insert("image/vnd.zbrush.pcx"         , QStringList() << "ZSoft PCX"                                      << "1");
    setupAvailable[7].insert("image/x-portable-bitmap"      , QStringList() << "Portable bitmap format (black and white)"       << "1");
    setupAvailable[7].insert("image/x-portable-graymap"     , QStringList() << "Portable graymap format (gray scale)"           << "1");
    setupAvailable[7].insert("image/x-portable-pixmap"      , QStringList() << "Portable pixmap format (color)"                 << "1");
    setupAvailable[7].insert("image/x-portable-anymap"      , QStringList() << "Portable pixmap format (pbm, pgm, or ppm)"      << "1");
    setupAvailable[7].insert("image/png"                    , QStringList() << "Portable Network Graphics"                      << "1");
    setupAvailable[7].insert("image/x-pict"                 , QStringList() << "Apple Macintosh QuickDraw /PICT file"           << "1");
    setupAvailable[7].insert("image/vnd.adobe.photoshop"    , QStringList() << "Adobe PhotoShop"                                << "1");
    setupAvailable[7].insert("image/x-sun-raster"           , QStringList() << "SUN Rasterfile"                                 << "1");
    setupAvailable[7].insert("image/x-sgi"                  , QStringList() << "Silicon Graphics"                               << "1");
    setupAvailable[7].insert("image/x-tga"                  , QStringList() << "Truevision Targa Graphic"                       << "1");
    setupAvailable[7].insert("image/tiff"                   , QStringList() << "Tagged Image File Format"                       << "1");
    setupAvailable[7].insert("image/vnd.wap.wbmp"           , QStringList() << "Wireless Bitmap"                                << "1");
    setupAvailable[7].insert("image/webp"                   , QStringList() << "Google web image format"                        << "1");
    setupAvailable[7].insert("image/x-xbitmap"              , QStringList() << "X Windows system bitmap, black and white only"  << "1");
    setupAvailable[7].insert("image/x-xpixmap"              , QStringList() << "X Windows system pixmap"                        << "1");

    /************************************************************/
    /************************************************************/
    // QuaZIP
    setupAvailable[8].insert("application/zip"              , QStringList() << "Zip file format"                                << "1");


    availableMimeTypes = new QVariantList[categories.length()];
    availableMimeTypesWithDescription = new QVariantList[categories.length()];
    enabledMimeTypes = new QStringList[categories.length()];
    defaultEnabledMimeTypes = new QStringList[categories.length()];

    // watch for changes, load changes with delay and without re-saving files (this is the parameter 'false')
    watcherTimer = new QTimer;
    watcherTimer->setSingleShot(true);
    watcherTimer->setInterval(250);
    connect(watcherTimer, &QTimer::timeout, this, [=]() { composeEnabledMimeTypes(false); enabledMimeTypesChanged(); watcher->addPath(ConfigFiles::MIMEFORMATS_FILE()); });
    watcher = new QFileSystemWatcher;
    if(QFileInfo(ConfigFiles::MIMEFORMATS_FILE()).exists())
        watcher->addPath(ConfigFiles::MIMEFORMATS_FILE());
    connect(watcher, &QFileSystemWatcher::fileChanged, this, [=](QString) { watcherTimer->start(); });

    composeAvailableMimeTypes();
    composeEnabledMimeTypes();

    saveTimer = new QTimer;
    saveTimer->setSingleShot(true);
    saveTimer->setInterval(250);
    connect(saveTimer, &QTimer::timeout, this, &MimeTypes::saveEnabledMimeTypes);

    connect(this, &MimeTypes::enabledMimeTypesQtChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesXCFToolsChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesPopplerChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesGmChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesGmGhostscriptChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesRAWChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesDevILChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesFreeImageChanged, this, [=](QStringList) {saveTimer->start();});
    connect(this, &MimeTypes::enabledMimeTypesQuaZIPChanged, this, [=](QStringList) {saveTimer->start();});

}

void MimeTypes::setEnabledMimeTypes(QString cat, QStringList val, bool withSaving) {

    if(withSaving) {

        if(cat == "qt")
            setEnabledMimeTypesQt(val);
        else if(cat == "xcftools")
            setEnabledMimeTypesXCFTools(val);
        else if(cat == "poppler")
            setEnabledMimeTypesPoppler(val);
        else if(cat == "gm")
            setEnabledMimeTypesGm(val);
        else if(cat == "gmghostscript")
            setEnabledMimeTypesGmGhostscript(val);
        else if(cat == "raw")
            setEnabledMimeTypesRAW(val);
        else if(cat == "devil")
            setEnabledMimeTypesDevIL(val);
        else if(cat == "freeimage")
            setEnabledMimeTypesFreeImage(val);
        else if(cat == "quazip")
            setEnabledMimeTypesQuaZIP(val);

    } else {

        if(cat == "qt")
            setEnabledMimeTypesQtWithoutSaving(val);
        else if(cat == "xcftools")
            setEnabledMimeTypesXCFToolsWithoutSaving(val);
        else if(cat == "poppler")
            setEnabledMimeTypesPopplerWithoutSaving(val);
        else if(cat == "gm")
            setEnabledMimeTypesGmWithoutSaving(val);
        else if(cat == "gmghostscript")
            setEnabledMimeTypesGmGhostscriptWithoutSaving(val);
        else if(cat == "raw")
            setEnabledMimeTypesRAWWithoutSaving(val);
        else if(cat == "devil")
            setEnabledMimeTypesDevILWithoutSaving(val);
        else if(cat == "freeimage")
            setEnabledMimeTypesFreeImageWithoutSaving(val);
        else if(cat == "quazip")
            setEnabledMimeTypesQuaZIPWithoutSaving(val);

    }
}

// Called at setup, these do not change during runtime
void MimeTypes::composeAvailableMimeTypes() {

    for(int i = 0; i < categories.length(); ++i) {

        QString cat = categories.at(i);

        // iterate over all mime types
        QMap<QString, QStringList>::const_iterator val = setupAvailable[categories.indexOf(cat)].constBegin();
        while(val != setupAvailable[categories.indexOf(cat)].constEnd()) {

            // Compose data into their respective sub arrays for easier handling later-on
            availableMimeTypes[categories.indexOf(cat)].append(val.key());
            availableMimeTypesWithDescription[categories.indexOf(cat)].append(QStringList() << val.key() << val.value().at(0));
            if(val.value().at(1) == "1") defaultEnabledMimeTypes[categories.indexOf(cat)].append(val.key());

            ++val;

        }

    }

}

// Read the currently disabled mime types from file (and thus compose the list of currently enabled types)
void MimeTypes::composeEnabledMimeTypes(bool withSaving) {

    QFile disabled(ConfigFiles::MIMEFORMATS_FILE());
    // If file does not exist we use default entries. The same happens as when the file cannot be opened, but in this case no message is printed out.
    if(!disabled.exists()) {
        for(QString cat : categories)
            setEnabledMimeTypes(cat, defaultEnabledMimeTypes[categories.indexOf(cat)]);
        return;
    }
    if(!disabled.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "MimeTypes::composeEnabledMimeType() :: WARNING: Disabled mime types file cannot be opened for reading. Setting default entries..." << NL;
        for(QString cat : categories)
            setEnabledMimeTypes(cat, defaultEnabledMimeTypes[categories.indexOf(cat)]);
        return;
    }

    QTextStream in(&disabled);
    QString line, cat = "";
    QMap<QString,QStringList> allDisabled;
    while(in.readLineInto(&line)) {

        if(line.trimmed() == "") continue;

        if(line.startsWith("[")) {
            for(int i = 0; i < categories.length(); ++i) {
                if(line.trimmed() == QString("[%1]").arg(categories.at(i))) {
                    cat = categories.at(i);
                    i = categories.length();
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

        // These will hold the mime types that are enabled
        QStringList setTheseAsEnabled;

        // Loop over each item of available mime types
        foreach(QVariant item, availableMimeTypes[categories.indexOf(cat)]) {

            // The current available format
            QString avail = item.toString();

            // If mime type is not disabled, add to list of enabled types
            if(!allDisabled[cat].contains(avail)) {
                setTheseAsEnabled.append(avail);
            }

        }

        // Set enabled mime types to file
        setEnabledMimeTypes(cat, setTheseAsEnabled, withSaving);

    }

}

// Save enabled mime types
void MimeTypes::saveEnabledMimeTypes() {

    QString disabled = "";

    for(int i = 0; i < categories.length(); ++i) {

        QString cat = categories.at(i);

        disabled += QString("[%1]\n").arg(cat);

        // Compose list of disabled mime types
        foreach(QVariant avail, availableMimeTypes[categories.indexOf(cat)]) {
            if(!enabledMimeTypes[categories.indexOf(cat)].contains(avail.toString()))
                disabled += avail.toString()+"\n";
        }

        disabled += "\n";

    }

    // Access and open disabled mime types file for writing
    QFile file(ConfigFiles::MIMEFORMATS_FILE());
    if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        LOG << CURDATE << "MimeTypes::saveEnabledMimeTypes() :: ERROR: Unable to open disabled mime types for writing/truncating..." << NL;
        return;
    }

    // Write disabled mime types
    QTextStream out(&file);
    out << disabled;

    // close file
    file.close();

    emit enabledMimeTypesSaved();

}
