/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <qlogging.h>   // needed in this form to compile with Qt 6.2
#include <QtDebug>
#include <QIcon>
#include <QFile>
#include <QBuffer>
#include <QFileInfo>
#include <QProcess>
#include <QStringConverter>
#include <QImageReader>
#include <QtConcurrent/QtConcurrentRun>
#include <QMediaPlayer>
#include <QColorSpace>
#include <QFileDialog>
#include <QScreen>
#include <QMimeDatabase>
#include <QCollator>
#include <QCryptographicHash>

#include <qml/pqc_scriptsimages.h>
// #include <scripts/pqc_scriptsfilespaths.h>
#include <shared/pqc_csettings.h>
#include <shared/pqc_configfiles.h>

#ifdef PQMWAYLANDSPECIFIC
#include <pqc_wayland.h>
#endif

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

#ifdef PQMQTPDF
#include <QtPdf/QPdfDocument>
#include <QtPdf/QtPdf>
#endif
#ifdef PQMPOPPLER
#include <poppler/qt6/poppler-qt6.h>
#endif

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

#ifdef PQMZXING
#include <ZXing/ReadBarcode.h>
#include <ZXing/ZXVersion.h>
#endif

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/Image.h>
#endif

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

PQCScriptsImages &PQCScriptsImages::get() {
    static PQCScriptsImages instance;
    return instance;
}

PQCScriptsImages::PQCScriptsImages() {
    // importedICCLastMod = 0;
    // colorlastlocation = new QFile(QString("%1/%2").arg(PQCConfigFiles::get().CACHE_DIR(), "colorlastlocation"));

    // if the formats changed then we can't rely on the archive cache anymore
    // connect(&PQCImageFormats::get(), &PQCImageFormats::formatsUpdated, this, [=]() {archiveContentCache.clear();});

    // loadColorProfileInfo();

    // lcms2CountFailedApplications = 0;

    m_devicePixelRatioCached = 0;
    m_devicePixelRatioCachedWhen = 0;

}

PQCScriptsImages::~PQCScriptsImages() {}

QSize PQCScriptsImages::getCurrentImageResolution(QString filename) {

    // TODO!!!
    // return PQCLoadImage::get().load(filename);
    return QSize();

}

bool PQCScriptsImages::isItAnimated(QString filename) {
    QImageReader reader(filename);
    return (reader.supportsAnimation()&&reader.imageCount()>1);
}

QString PQCScriptsImages::getIconPathFromTheme(QString binary) {

    qDebug() << "args: binary =" << binary;

    // We go through all the themeSearchPath elements
    for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

        // Setup path (this is the most likely directory) and format (PNG)
        QString path = QIcon::themeSearchPaths().at(i) + "/hicolor/32x32/apps/" + binary.trimmed() + ".png";
        if(QFile(path).exists())
            return "file:" + path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" + path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" + path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file:" + path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" + path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" + path;
            }
        }

    }

    // Nothing found
    return "";

}

QString PQCScriptsImages::loadImageAndConvertToBase64(QString filename) {

    qDebug() << "args: filename =" << filename;

    // TODO!!!
    // filename = PQCScriptsFilesPaths::get().cleanPath(filename);

    QPixmap pix;
    pix.load(filename);
    if(pix.width() > 64 || pix.height() > 64)
        pix = pix.scaled(64,64,Qt::KeepAspectRatio);
    QByteArray bytes;
    QBuffer buffer(&bytes);
    buffer.open(QIODevice::WriteOnly);
    pix.save(&buffer, "PNG");
    return bytes.toBase64();

}

void PQCScriptsImages::listArchiveContent(QString path, bool insideFilenameOnly) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: insideFilenameOnly =" << insideFilenameOnly;

    if(path.contains("::ARC::"))
        path = path.split("::ARC::").at(1);

    const QFileInfo info(path);
    QString cacheKey = QString("%1::%2::%3::%4").arg(info.lastModified().toMSecsSinceEpoch()).arg(path, PQCCSettings::get().getImageviewSortImagesAscending()).arg(insideFilenameOnly);

    if(m_archiveContentCache.contains(cacheKey)) {
        Q_EMIT haveArchiveContentFor(path, m_archiveContentCache[cacheKey]);
        return;
    }

    QFuture<void> f = QtConcurrent::run([=]() {
        Q_EMIT haveArchiveContentFor(path, PQCScriptsImages::listArchiveContentWithoutThread(path, cacheKey, insideFilenameOnly));
    });

}

QStringList PQCScriptsImages::listArchiveContentWithoutThread(QString path, QString cacheKey, bool insideFilenameOnly) {

    QStringList ret;

    const QFileInfo info(path);

    if(cacheKey == "") {
        cacheKey = QString("%1::%2::%3::%4").arg(info.lastModified().toMSecsSinceEpoch()).arg(path, PQCCSettings::get().getImageviewSortImagesAscending()).arg(insideFilenameOnly);
    }

#ifndef Q_OS_WIN

    if(PQCCSettings::get().getFiletypesExternalUnrar() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

        QProcess which;
        which.setStandardOutputFile(QProcess::nullDevice());
        which.start("which", QStringList() << "unrar");
        which.waitForFinished();

        if(!which.exitCode()) {

            QProcess p;
            p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

            if(p.waitForStarted()) {

                QByteArray outdata = "";

                while(p.waitForReadyRead())
                    outdata.append(p.readAll());

                auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
                QStringList allfiles = QString(toUtf16(outdata)).split('\n', Qt::SkipEmptyParts);

                allfiles.sort();

                if(insideFilenameOnly) {
                    for(const QString &f : std::as_const(allfiles)) {
                        // TODO!!!
                        // if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix().toLower()))
                            ret.append(f);
                    }
                } else {
                    for(const QString &f : std::as_const(allfiles)) {
                        // TODO!!!
                        // if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix().toLower()))
                            ret.append(QString("%1::ARC::%2").arg(f, path));
                    }
                }

            }

        }

    }

    // this either means there is nothing in that archive
    // or something went wrong above with unrar
    if(ret.length() == 0) {

#endif

#ifdef PQMLIBARCHIVE

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

// Read file
#ifdef Q_OS_WIN
        int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(info.absoluteFilePath().utf16()), 10240);
#else
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLocal8Bit().data(), 10240);
#endif

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            qWarning() << "ERROR: archive_read_open_filename() returned code of" << r;
            qWarning() << "Archive:" << info.absoluteFilePath();
            return ret;
        }

        // Loop over entries in archive
        struct archive_entry *entry;
        QStringList allfiles;
        while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

            // Read the current file entry
            // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
            QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

            // If supported file format, append to temporary list
            const QFileInfo info(filenameinside);
            // TODO!!!
            // if(PQCImageFormats::get().getEnabledFormats().contains(info.suffix().toLower()) || PQCImageFormats::get().getEnabledFormats().contains(info.completeSuffix().toLower()))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();

        if(insideFilenameOnly) {
            ret = allfiles;
        } else {
            for(const QString &f : std::as_const(allfiles))
                ret.append(QString("%1::ARC::%2").arg(f, path));
        }

        // Close archive
        r = archive_read_free(a);
        if(r != ARCHIVE_OK)
            qWarning() << "ERROR: archive_read_free() returned code of" << r;

#endif

#ifndef Q_OS_WIN
    }
#endif

    QCollator collator;
#ifndef PQMWITHOUTICU
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);
#endif

    if(PQCCSettings::get().getImageviewSortImagesAscending())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    m_archiveContentCache.insert(cacheKey, ret);

    return ret;

}

QString PQCScriptsImages::convertSecondsToPosition(int t) {

    int m = t/60;
    int s = t%60;

    QString minutes;
    QString seconds;

    if(m < 10)
        minutes = QString("0%1").arg(m);
    else
        minutes = QString("%1").arg(m);

    if(s < 10)
        seconds = QString("0%1").arg(s);
    else
        seconds = QString("%1").arg(s);

    return QString("%1:%2").arg(minutes, seconds);

}

bool PQCScriptsImages::isMpvVideo(QString path) {

    qDebug() << "args: path =" << path;

    bool supported = false;

#ifdef PQMVIDEOMPV

    QString suf = QFileInfo(path).suffix().toLower();
    // TODO!!!
    // if(PQCImageFormats::get().getEnabledFormatsLibmpv().contains(suf)) {

    //     supported = true;

    // } else {

    //     QMimeDatabase db;
    //     QString mimetype = db.mimeTypeForFile(path).name();
    //     if(PQCImageFormats::get().getEnabledMimeTypesLibmpv().contains(mimetype))
    //         supported = true;

    // }

#ifdef PQMVIDEOQT
    if(supported) {
        if(!PQCCSettings::get().getFiletypesVideoPreferLibmpv())
            supported = false;
    }
#endif

#endif

    return supported;

}

bool PQCScriptsImages::isQtVideo(QString path) {

    qDebug() << "args: path =" << path;

    bool supported = false;

#ifdef PQMVIDEOQT

    QString suf = QFileInfo(path).suffix().toLower();
    // if(PQCImageFormats::get().getEnabledFormatsVideo().contains(suf)) {

    //     supported = true;

    // } else {

    //     QMimeDatabase db;
    //     QString mimetype = db.mimeTypeForFile(path).name();
    //     if(PQCImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype))
    //         supported = true;

    // }

#endif

    return supported;

}

bool PQCScriptsImages::isPDFDocument(QString path) {

    qDebug() << "args: path =" << path;

    // if(PQCImageFormats::get().getEnabledFormatsPoppler().contains(QFileInfo(path).suffix().toLower()) ||
    //     PQCImageFormats::get().getEnabledFormatsPoppler().contains(QFileInfo(path).completeSuffix().toLower()))
    //     return true;

    // QMimeDatabase db;
    // if(PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(db.mimeTypeForFile(path).name()))
    //     return true;

    return false;

}

bool PQCScriptsImages::isArchive(QString path) {

    qDebug() << "args: path =" << path;

    // if(PQCImageFormats::get().getEnabledFormatsLibArchive().contains(QFileInfo(path).suffix().toLower()) ||
    //     PQCImageFormats::get().getEnabledFormatsLibArchive().contains(QFileInfo(path).completeSuffix().toLower()))
    //     return true;

    // QMimeDatabase db;
    // if(PQCImageFormats::get().getEnabledMimeTypesLibArchive().contains(db.mimeTypeForFile(path).name()))
    //     return true;

    return false;

}

int PQCScriptsImages::getNumberDocumentPages(QString path) {

    qDebug() << "args: path =" << path;

    if(path.trimmed().isEmpty())
        return 0;

    if(path.contains("::PDF::"))
        path = path.split("::PDF::").at(1);

#ifdef PQMPOPPLER
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(path);
    if(document && !document->isLocked())
        return document->numPages();
#endif
#ifdef PQMQTPDF
    QPdfDocument doc;
    doc.load(path);
    QPdfDocument::Error err = doc.error();
    if(err == QPdfDocument::Error::None)
        return doc.pageCount();
#endif
    return 0;

}

void PQCScriptsImages::setSupportsTransparency(QString path, bool alpha) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: alpha =" << alpha;

    m_alphaChannels.insert(path, alpha);

}

bool PQCScriptsImages::supportsTransparency(QString path) {

    qDebug() << "args: path =" << path;

    return m_alphaChannels.value(path, false);

}

int PQCScriptsImages::isMotionPhoto(QString path) {

    qDebug() << "args: path =" << path;

#ifndef PQMMOTIONPHOTO
    return 0;
#endif

    // 1 = Apple Live Photos
    // 2 = Motion Photo
    // 3 = Micro Video

    QFileInfo info(path);
    const QString suffix = info.suffix().toLower();

    if(suffix == "jpg" || suffix == "jpeg" || suffix == "heic" || suffix == "heif") {

        /***********************************/
        // check for Apply Live Photos

        if(PQCCSettings::get().getFiletypesLoadAppleLivePhotos()) {

            QString videopath = QString("%1/%2.mov").arg(info.absolutePath(), info.baseName());
            QFileInfo videoinfo(videopath);
            if(videoinfo.exists())
                return 1;

        }

        if(!PQCCSettings::get().getFiletypesLoadMotionPhotos())
            return 0;

            /***********************************/
            // Access EXIV2 data

#if defined(PQMEXIV2) && defined(PQMEXIV2_ENABLE_BMFF)

#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Image::UniquePtr image;
#else
        Exiv2::Image::AutoPtr image;
#endif

        try {
            image = Exiv2::ImageFactory::open(path.toStdString());
            image->readMetadata();
        } catch (Exiv2::Error& e) {
            // An error code of kerFileContainsUnknownImageType (older version: 11) means unknown file type
            // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
            if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
            if(e.code() != 11)
#endif
                qWarning() << "ERROR reading exiv data (caught exception):" << e.what();
            else
                qDebug() << "ERROR reading exiv data (caught exception):" << e.what();

            return 0;
        }

        Exiv2::XmpData xmpData;
        try {
            xmpData = image->xmpData();
        } catch(Exiv2::Error &e) {
            qDebug() << "ERROR: Unable to read xmp metadata:" << e.what();
            return 0;
        }

        for(Exiv2::XmpData::const_iterator it_xmp = xmpData.begin(); it_xmp != xmpData.end(); ++it_xmp) {

            QString familyName = QString::fromStdString(it_xmp->familyName());
            QString groupName = QString::fromStdString(it_xmp->groupName());
            QString tagName = QString::fromStdString(it_xmp->tagName());

            /***********************************/
            // check for Motion Photo
            if(familyName == "Xmp" && groupName == "GCamera" && tagName == "MotionPhoto") {

                // check value == 1
                if(QString::fromStdString(Exiv2::toString(it_xmp->value())) == "1")
                    return 2;
            }

            /***********************************/
            // check for Micro Video

            if(familyName == "Xmp" && groupName == "GCamera" && tagName == "MicroVideo") {

                // check value == 1
                if(QString::fromStdString(Exiv2::toString(it_xmp->value())) == "1")
                    return 3;

            }

        }

#endif

    }

    return 0;

}

QString PQCScriptsImages::extractMotionPhoto(QString path) {

    qDebug() << "args: path =" << path;

    // at this point we assume that the check for google motion photo has already been done
    // and we won't need to check again

    // the approach taken in this function is inspired by the analysis found at:
    // https://linuxreviews.org/Google_Pixel_%22Motion_Photo%22

    QFileInfo info(path);
    if(!info.exists())
        return "";

    const QString videofilename = QString("%1/motionphotos/%2.mp4").arg(PQCConfigFiles::get().CACHE_DIR(), info.baseName());
    if(QFileInfo::exists(videofilename)) {
        return videofilename;
    }

    // we assume header for type==2
    QStringList headerbytes = {"00000018667479706d703432",
                               "0000001c6674797069736f6d"};

    char *data = new char[info.size()]{};

    QFile file(path);
    if(!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Unable to open file for reading";
        delete[] data;
        return "";
    }

    QDataStream in(&file);
    in.readRawData(data, info.size());

    // we look for the offset of the header of size 12
    // it looks like this: 00000018667479706d703432
    for(int i = 0; i < info.size()-12; ++i) {

        // we inspect the current 3
        QByteArray firstthree(&data[i], 3);

        if(firstthree.toHex() == "000000") {

            // read the full 12 bytes
            QByteArray array(&data[i], 12);

            // if it matches we found the video
            if(headerbytes.contains(array.toHex())) {

                // get the video data
                QByteArray videodata(&data[i], info.size()-i);

                // make sure cache folder exists
                QDir dir;
                dir.mkpath(QFileInfo(videofilename).absolutePath());

                // write video to temporary file
                QFile outfile(videofilename);
                if(!outfile.open(QIODevice::WriteOnly)) {
                    delete[] data;
                    qWarning() << "ERROR extracting motion photo.";
                    return "";
                }
                QDataStream out(&outfile);
                out.writeRawData(videodata, info.size()-i);
                outfile.close();

                delete[] data;

                return outfile.fileName();

            }
        }
    }

    delete[] data;

    return "";

}

bool PQCScriptsImages::isPhotoSphere(QString path) {

    qDebug() << "args: path =" << path;

#ifdef PQMPHOTOSPHERE

#if defined(PQMEXIV2) && defined(PQMEXIV2_ENABLE_BMFF)

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif

    try {
        image = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of kerFileContainsUnknownImageType (older version: 11) means unknown file type
        // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
        if(e.code() != 11)
#endif
            qWarning() << "ERROR reading exiv data (caught exception):" << e.what();
        else
            qDebug() << "ERROR reading exiv data (caught exception):" << e.what();

        return false;
    }

    Exiv2::XmpData xmpData;
    try {
        xmpData = image->xmpData();
    } catch(Exiv2::Error &e) {
        qDebug() << "ERROR: Unable to read xmp metadata:" << e.what();
        return false;
    }

    for(Exiv2::XmpData::const_iterator it_xmp = xmpData.begin(); it_xmp != xmpData.end(); ++it_xmp) {

        QString familyName = QString::fromStdString(it_xmp->familyName());
        QString groupName = QString::fromStdString(it_xmp->groupName());
        QString tagName = QString::fromStdString(it_xmp->tagName());

        /***********************************/
        // check for Motion Photo
        if(familyName == "Xmp" && groupName == "GPano" && tagName == "ProjectionType") {

            // check value == equirectangular
            if(QString::fromStdString(Exiv2::toString(it_xmp->value())) == "equirectangular")
                return true;
        }

    }

#endif

#endif

    return false;

}

bool PQCScriptsImages::isComicBook(QString path) {

    qDebug() << "args: path =" << path;

    const QString suffix = QFileInfo(path).suffix().toLower();

    return (suffix=="cbt" || suffix=="cbr" || suffix=="cbz" || suffix=="cb7");

}

QVariantList PQCScriptsImages::getZXingData(QString path) {

    qDebug() << "args: path =" << path;

    QVariantList ret;

#ifdef PQMZXING

    QSize origSize;
    QImage img;
    // TODO!!!
    // PQCLoadImage::get().load(path, QSize(-1,-1), origSize, img);

    ZXing::ImageFormat frmt;
    switch (img.format()) {
    case QImage::Format_ARGB32:
    case QImage::Format_RGB32:
#if ZXING_VERSION_MAJOR <=2 && ZXING_VERSION_MINOR <= 2
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        frmt = ZXing::ImageFormat::BGRX;
#else
        frmt = ZXing::ImageFormat::XRGB;
#endif
#else
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        frmt = ZXing::ImageFormat::BGRA;
#else
        frmt = ZXing::ImageFormat::ARGB;
#endif
#endif
        break;
    case QImage::Format_RGB888:
        frmt = ZXing::ImageFormat::RGB;
        break;
    case QImage::Format_RGBX8888:
    case QImage::Format_RGBA8888:
#if ZXING_VERSION_MAJOR <=2 && ZXING_VERSION_MINOR <= 2
        frmt = ZXing::ImageFormat::RGBX;
#else
        frmt = ZXing::ImageFormat::RGBA;
#endif
        break;
    case QImage::Format_Grayscale8:
        frmt = ZXing::ImageFormat::Lum;
        break;
    default:
        img.convertTo(QImage::Format_Grayscale8);
        frmt = ZXing::ImageFormat::Lum;
    }

#if ZXING_VERSION_MAJOR == 1 && ZXING_VERSION_MINOR <= 2

    // Read any bar code
    const ZXing::DecodeHints hints = ZXing::DecodeHints().setFormats(ZXing::BarcodeFormat::Any);
    const ZXing::Result r = ZXing::ReadBarcode({img.bits(), img.width(), img.height(), ZXing::ImageFormat::Lum}, hints);

#elif (ZXING_VERSION_MAJOR == 2 && ZXING_VERSION_MINOR <= 1) || ZXING_VERSION_MAJOR == 1

    // Read all bar codes
    const ZXing::DecodeHints hints = ZXing::DecodeHints().setFormats(ZXing::BarcodeFormat::Any);
    const std::vector<ZXing::Result> results = ZXing::ReadBarcodes({img.bits(), img.width(), img.height(), ZXing::ImageFormat::Lum}, hints);

#else

    // Read all bar codes
    auto hints = ZXing::ReaderOptions().setFormats(ZXing::BarcodeFormat::Any)
                     .setTryHarder(true)
                     .setTryInvert(true)
                     .setTextMode(ZXing::TextMode::HRI)
                     .setMaxNumberOfSymbols(10);
    auto results = ZXing::ReadBarcodes({img.bits(), img.width(), img.height(), frmt, static_cast<int>(img.bytesPerLine())}, hints);

#endif

    /******************************/
    // process and store results

#if ZXING_VERSION_MAJOR == 1 && ZXING_VERSION_MINOR <= 2

    if(r.format() != ZXing::BarcodeFormat::None) {

#else // ZXing 1.3 and up

    for(const auto& r : results) {

#endif

        QVariantList vals;
#if ZXING_VERSION_MAJOR == 1 && ZXING_VERSION_MINOR <= 4
        vals << QString::fromStdWString(r.text());
#else
        vals << QString::fromStdString(r.text());
#endif
        vals << QPoint(r.position().topLeft().x, r.position().topLeft().y);
        vals << QSize(r.position().bottomRight().x-r.position().topLeft().x, r.position().bottomRight().y-r.position().topLeft().y);
        ret << vals;

    }

#endif  // PQMZXING

    return ret;

}

QString PQCScriptsImages::extractArchiveFileToTempLocation(QString path) {

    qDebug() << "args: path =" << path;

    QString ret = "";

    if(!path.contains("::ARC::"))
        return "";

    QStringList parts = path.split("::ARC::");
    QString archivefile = parts.at(1);
    QString compressedFilename = parts.at(0);

    QFileInfo info(archivefile);
    const QString suffix = info.suffix().toLower();

#ifndef Q_OS_WIN
    if(PQCCSettings::get().getFiletypesExternalUnrar() && (suffix == "cbr" || suffix == "rar")) {

        QProcess which;
        which.setStandardOutputFile(QProcess::nullDevice());
        which.start("which", QStringList() << "unrar");
        which.waitForFinished();

        if(!which.exitCode()) {

            qDebug() << "loading archive with unrar";

            // we extract it to a temp location from where we can load it then
            const QString tempdir = PQCConfigFiles::get().CACHE_DIR() + "/clipboard/";

            QDir td;
            if(!td.exists(tempdir))
                td.mkpath(tempdir);

            QProcess p;
            p.start("unrar", QStringList() << "x" << "-y" << archivefile << compressedFilename << tempdir);
            p.waitForFinished(15000);

            return tempdir+compressedFilename;

        } else
            qWarning() << "unrar was not found in system path";

    }
#endif

#ifdef PQMLIBARCHIVE

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

// Read file
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archivefile.utf16()), 10240);
#else
    int r = archive_read_open_filename(a, archivefile.toLocal8Bit().data(), 10240);
#endif

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        qWarning() << QString("archive_read_open_filename() returned code of %1").arg(r);
        return "";
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename == "" && QFileInfo(filenameinside).suffix() != "")) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the image data
            uchar *buff = new uchar[size];

            // And finally read the file into the buffer
            la_ssize_t r = archive_read_data(a, (void*)buff, size);

            if(r != size || size == 0) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(r).arg(size);
                return "";
            }

            // we extract it to a temp location from where we can load it then
            const QString tempdir = PQCConfigFiles::get().CACHE_DIR() + "/clipboard/";
            const QString temppath = tempdir + filenameinside;

            QDir td;
            if(!td.exists(tempdir))
                td.mkpath(tempdir);

            // file handles
            QFile file(temppath);
            QFileInfo info(file);

            // remove it if it exists, there is no way to know if it's the same file or not
            if(file.exists()) file.remove();

            // make sure the path exists
            QDir dir(info.absolutePath());
            if(!dir.exists())
                dir.mkpath(info.absolutePath());

            // write buffer to file
            if(!file.open(QIODevice::WriteOnly)) {
                qWarning() << "Unable to extract file to temporary location.";
                return "";
            }
            QDataStream out(&file);   // we will serialize the data into the file
            out.writeRawData((const char*) buff,size);
            file.close();
            delete[] buff;

            ret = temppath;

            break;

        }

    }

    // Close archive
    r = archive_read_close(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_close() returned code of" << r;
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_free() returned code of" << r;

#endif

    return ret;

}

QString PQCScriptsImages::extractDocumentPageToTempLocation(QString path) {

    qDebug() << "args: path =" << path;

    if(!path.contains("::PDF::"))
        return "";

    QString ret = "";

#ifdef PQMQTPDF

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    int page = path.split("::PDF::").at(0).toInt();
    QString realFileName = path.split("::PDF::").at(1);

    QPdfDocument doc;
    doc.load(realFileName);

    QPdfDocument::Error err = doc.error();
    if(err != QPdfDocument::Error::None) {
        qWarning() << "Error occurred loading PDF";
        return "";
    }

    QSizeF _pageSize = (doc.pagePointSize(page)/72.0*qApp->primaryScreen()->physicalDotsPerInch())*(PQCCSettings::get().getFiletypesPDFQuality()/72.0);
    QSize origSize = QSize(_pageSize.width(), _pageSize.height());

    QImage p = doc.render(page, origSize);

    if(p.isNull()) {
        qWarning() << QString("Unable to read page %1").arg(page);
        return "";
    }

    // some pdfs don't specify a background
    // in that case the resulting image will have a transparent background
    // to "fix" this we simply draw the image on top of a white image
    QImage img(p.size(), p.format());
    img.fill(Qt::white);
    QPainter paint(&img);
    paint.drawImage(QRect(QPoint(0,0), img.size()), p);
    paint.end();

    // we extract it to a temp location from where we can load it then
    const QString tempdir = PQCConfigFiles::get().CACHE_DIR() + "/clipboard/";
    const QString temppath = tempdir + QString("%1.jpg").arg(page+1);

    QDir td;
    if(!td.exists(tempdir))
        td.mkpath(tempdir);

    if(img.save(temppath)) {
        return temppath;
    }

#endif
#ifdef PQMPOPPLER

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    int page = path.split("::PDF::").at(0).toInt();
    QString filename = path.split("::PDF::").at(1);

    // Load poppler document and render to QImage
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(filename);
    if(!document || document->isLocked()) {
        qWarning() << "Invalid PDF document, unable to load!";
        return "";
    }
    document->setRenderHint(Poppler::Document::TextAntialiasing);
    document->setRenderHint(Poppler::Document::Antialiasing);
    std::unique_ptr<Poppler::Page> p = document->page(page);
    if(p == nullptr) {
        qWarning() << QString("Unable to read page %1").arg(page);
        return "";
    }

    const double quality = PQCSettingsCPP::get().getFiletypesPDFQuality();

    QImage img = p->renderToImage(quality, quality);

    // we extract it to a temp location from where we can load it then
    const QString tempdir = PQCConfigFiles::get().CACHE_DIR() + "/clipboard/";
    const QString temppath = tempdir + QString("%1.jpg").arg(page+1);

    QDir td;
    if(!td.exists(tempdir))
        td.mkpath(tempdir);

    if(img.save(temppath)) {
        return temppath;
    }

#endif

    return ret;

}

bool PQCScriptsImages::extractFrameAndSave(QString path, int frameNumber) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: frameNumber =" << frameNumber;

    QFileInfo info(path);

    // set up reader
    QImageReader reader(path);

    // we use jumpToNextImage() in a loop as jumpToImage(imageNumber) seems to do nothing
    QImage img = reader.read();
    for(int i = 0; i < frameNumber; ++i) {
        reader.jumpToNextImage();
        reader.read(&img);
    }

    // depending on alpha channel we choose the appropriate suffix
    QString suffix = "jpg";
    if(img.hasAlphaChannel())
        suffix = "png";

    // compose default target filename
    QString targetfile = QString("%1/%2_%3.%4").arg(info.absolutePath(), info.baseName()).arg(frameNumber).arg(suffix);

    // ask user to confirm target file
    // targetfile = PQCScriptsFilesPaths::get().selectFileFromDialog("Save", targetfile, PQCImageFormats::get().detectFormatId(targetfile), true);

    // no file selected/dialog cancelled
    if(targetfile == "")
        return false;

    // save to new file
    return img.save(targetfile);

}

int PQCScriptsImages::getDocumentPageCount(QString path) {

    qDebug() << "args: path =" << path;

#ifdef PQMQTPDF

    if(path.contains("::PDF::"))
        path = path.split("::PDF::").at(1);

    QPdfDocument doc;
    doc.load(path);

    QPdfDocument::Error err = doc.error();
    if(err != QPdfDocument::Error::None) {
        qWarning() << "Error occurred loading PDF";
        return 0;
    }

    return doc.pageCount();

#elif PQMPOPPLER

    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(path);
    if(!document || document->isLocked()) {
        qWarning() << "Invalid PDF document, unable to load!";
        return 0;
    }

    return document->numPages();

#endif

    return 0;

}

bool PQCScriptsImages::isSVG(QString path) {

    qDebug() << "args: path =" << path;

    const QString suffix = QFileInfo(path).suffix().toLower();
    return (suffix == "svg" || suffix == "svgz");

}

bool PQCScriptsImages::isNormalImage(QString path) {

    qDebug() << "args: path =" << path;

    return !isMpvVideo(path) && !isQtVideo(path) && !isPDFDocument(path) && !isArchive(path) && !isItAnimated(path) && !isSVG(path);

}



void PQCScriptsImages::removeThumbnailFor(QString path) {

    qDebug() << "args: path =" << path;

    QByteArray p = QUrl::fromLocalFile(path).toString().toUtf8();

    const QStringList cachedirs = {"xx-large",
                                   "x-large",
                                   "large",
                                   "normal"};

    for(auto &c : cachedirs) {
        const QByteArray md5 = QCryptographicHash::hash(p,QCryptographicHash::Md5).toHex();
        const QString thumbcachepath = PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() + "/" + c + "/" + md5 + ".png";
        if(QFileInfo::exists(thumbcachepath))
            QFile::remove(thumbcachepath);
    }

}

double PQCScriptsImages::getPixelDensity() {

#ifndef Q_OS_WIN

    // 2025-01-01: Wayland issue:
    // Fractional scaling factors are currently (Qt 6.8.1) reported as full integers by QScreen::devicePixelRatio()
    // The same issue occurs in wayland-info (from wayland-utils 1.2.0) with the reported scale factor there
    // However, we can try to calculate the right scaling factor from the logical and physical dimensions reported by wayland-info

    // If we are on wayland...
    if(qApp->platformName() == "wayland") {

#ifdef PQMWAYLANDSPECIFIC
        const int timeout = 60*1;
#else
        const int timeout = 60*5;
#endif

        // we cache a once calculated value for 5 or 1 minutes
        if(QDateTime::currentSecsSinceEpoch()-m_devicePixelRatioCachedWhen < timeout) {
            return m_devicePixelRatioCached;
        }

#ifdef PQMWAYLANDSPECIFIC

        devicePixelRatioCached = PQCWayland::getDevicePixelRatio();
        devicePixelRatioCachedWhen = QDateTime::currentSecsSinceEpoch();
        return devicePixelRatioCached;

#else

        QMap<int, QList<int> > valsLogical;
        QMap<int, QList<int> > valsPhysical;

        // request all output information from wayland-info
        QProcess proc;
        proc.start("wayland-info", {"-i", "output"});
        proc.waitForFinished(1000);
        const QString out = proc.readAll();
        const int ret = proc.exitCode();

        // a return value would likely mean that wayland-info is not installed
        // in that case we default to what was done before
        if(ret == 0) {

            // prepare variables
            int logicalW = 0, logicalH = 0;
            int physicalW = 0, physicalH = 0;
            int logicalId = -1, physicalId = -1;

            // go through output line by line
            const QStringList parts = out.split("\n");
            for(const QString &line : parts) {

                // read out output ids
                if(line.trimmed().startsWith("output:"))
                    logicalId = line.split("output: ")[1].toInt();
                if(line.contains("wl_output") && line.contains(", name:"))
                    physicalId = line.split(", name: ")[1].toInt();

                // read out logical dimensions
                if(line.contains("logical_width:") && line.contains("logical_height:")) {
                    logicalW = line.split("logical_width: ")[1].split(",")[0].toInt();
                    logicalH = line.split("logical_height: ")[1].split("\n")[0].toInt();
                    if(logicalId > -1)
                        valsLogical[logicalId] = {logicalW, logicalH};
                }

                // read out physical dimensions
                if(!line.contains("logical_width:") && !line.contains("logical_height:") && line.contains("width:") && line.contains("height:")) {
                    physicalW = line.split("width: ")[1].split(" ")[0].toInt();
                    physicalH = line.split("height: ")[1].split(" ")[0].toInt();
                    if(physicalId > -1)
                        valsPhysical[physicalId] = {physicalW, physicalH};
                }

            }

            // if all screen ratios are the same, we can still make use of that
            // if this variable is >0 a common ratio has been found
            // a value of -1 indicates different ratios
            double useRatio = 0;

            // different amount of outputs found -> stop here
            if(valsLogical.size() != valsPhysical.size())
                useRatio = -1;

            // same number of outputs
            else {

                // loop over all found outputs
                QMapIterator<int, QList<int> > i(valsLogical);
                while (i.hasNext()) {

                    i.next();
                    const int id = i.key();

                    // if we have a matching physical output
                    if(valsPhysical.contains(id)) {

                        // compute the height/width ratios
                        const double fac1 = static_cast<double>(valsPhysical.value(id).value(0))/static_cast<double>(valsLogical.value(id).value(0));
                        const double fac2 = static_cast<double>(valsPhysical.value(id).value(1))/static_cast<double>(valsLogical.value(id).value(1));

                        // if the two ratios match and make sense, return them
                        if(fabs(fac1-fac2) < 1e-6 && fac1 > 0.25 && fac1 < 6) {

                            // same ratio as before -> all good
                            if(useRatio == 0 || fabs(useRatio-fac1) < 1e-6)
                                useRatio = fac1;

                            // different ratio -> problem
                            else
                                useRatio = -1;
                        }

                    } else
                        // error -> stop
                        useRatio = -1;

                    // different ratios found
                    if(useRatio < 0)
                        break;

                }

            }

            // Found single ratio across all screens
            if(useRatio > 0) {

                m_devicePixelRatioCached = useRatio;
                m_devicePixelRatioCachedWhen = QDateTime::currentSecsSinceEpoch();
                return useRatio;

                // if error occurred, then we effectively disable this feature
            } else {

                m_devicePixelRatioCached = 1;
                m_devicePixelRatioCachedWhen = QDateTime::currentSecsSinceEpoch();
                return 1;

            }

        }

#endif

    }

#endif

    // if the above didn't work, or we are on Windows
    return qApp->devicePixelRatio();

}

QString PQCScriptsImages::getNameFromMimetype(QString mimetype, QString filename) {

    QMimeDatabase db;

    QString val = db.mimeTypeForName(mimetype).comment();
    // TODO!!!
    // if(val == "")
    //     val = PQCImageFormats::get().getFormatName(PQCImageFormats::get().detectFormatId(filename));

    return val;

}
