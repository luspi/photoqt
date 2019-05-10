#include "imageformats.h"

PQImageFormats::PQImageFormats(QObject *parent) : QObject(parent) {

    categories << "qt";

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

    } else {

        if(cat == "qt")
            setEnabledFileformatsQtWithoutSaving(val);

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

// Save Qt file formats
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
//    QTextStream out(&file);
//    out << disabled;

    // close file
    file.close();

    emit enabledFileformatsSaved();

}
