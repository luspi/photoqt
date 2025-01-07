/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
#include <QtConcurrent>
#include <QMediaPlayer>
#include <QColorSpace>
#include <QFileDialog>
#include <QScreen>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_settings.h>
#include <pqc_imageformats.h>
#include <pqc_loadimage.h>
#include <pqc_configfiles.h>
#include <pqc_notify.h>

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

PQCScriptsImages::PQCScriptsImages() {
    importedICCLastMod = 0;
    colorlastlocation = new QFile(QString("%1/%2").arg(PQCConfigFiles::get().CACHE_DIR(), "colorlastlocation"));

    // if the formats changed then we can't rely on the archive cache anymore
    connect(&PQCImageFormats::get(), &PQCImageFormats::formatsUpdated, this, [=]() {archiveContentCache.clear();});

    loadColorProfileInfo();

    lcms2CountFailedApplications = 0;

    devicePixelRatioCached = 0;
    devicePixelRatioCachedWhen = 0;

}

PQCScriptsImages::~PQCScriptsImages() {
    delete colorlastlocation;
}

QSize PQCScriptsImages::getCurrentImageResolution(QString filename) {

    return PQCLoadImage::get().load(filename);

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

    filename = PQCScriptsFilesPaths::get().cleanPath(filename);

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

QStringList PQCScriptsImages::listArchiveContent(QString path, bool insideFilenameOnly) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: insideFilenameOnly =" << insideFilenameOnly;

    const QFileInfo info(path);
    QString cacheKey = QString("%1::%2::%3::%4").arg(info.lastModified().toMSecsSinceEpoch()).arg(path, PQCSettings::get()["imageviewSortImagesAscending"].toBool()).arg(insideFilenameOnly);

    if(archiveContentCache.contains(cacheKey))
        return archiveContentCache[cacheKey];

    QStringList ret;


#ifndef Q_OS_WIN

    if(PQCSettings::get()["filetypesExternalUnrar"].toBool() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

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
                        if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix().toLower()))
                            ret.append(f);
                    }
                } else {
                    for(const QString &f : std::as_const(allfiles)) {
                        if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix().toLower()))
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
            if((PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(filenameinside).suffix().toLower())))
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
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);

    if(PQCSettings::get()["imageviewSortImagesAscending"].toBool())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    archiveContentCache.insert(cacheKey, ret);

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

void PQCScriptsImages::loadHistogramData(QString filepath, int index) {

    QFuture<void> f = QtConcurrent::run([=]() {
        _loadHistogramData(filepath, index);
    });

}

void PQCScriptsImages::_loadHistogramData(QString filepath, int index) {

    qDebug() << "args: filepath =" << filepath;

    QFileInfo info(filepath);
    QString key = QString("%1%2").arg(filepath).arg(info.lastModified().toMSecsSinceEpoch());
    if(histogramCache.contains(key)) {
        Q_EMIT histogramDataLoaded(histogramCache[key], index);
        return;
    }

    QVariantList ret;

    if(filepath == "" || !info.exists()) {
        Q_EMIT histogramDataLoadedFailed(index);
        return;
    }

    // first we need to retrieve the current image
    QImage img;
    QSize size;
    PQCLoadImage::get().load(filepath, QSize(), size, img);

    if(img.size().isNull() || img.size().isEmpty()) {
        Q_EMIT histogramDataLoadedFailed(index);
        return;
    }

    if(img.format() != QImage::Format_RGB32)
        img.convertTo(QImage::Format_RGB32);

    // we first count using integers for faster adding up
    QList<int> red(256);
    QList<int> green(256);
    QList<int> blue(256);

    // Loop over all rows of the image
    for(int i = 0; i < img.height(); ++i) {

        // Get the pixel data of row i of the image
        QRgb *rowData = (QRgb*)img.scanLine(i);

        // Loop over all columns
        for(int j = 0; j < img.width(); ++j) {

            // Get pixel data of pixel at column j in row i
            QRgb pixelData = rowData[j];

            // store color data
            ++red[qRed(pixelData)];
            ++green[qGreen(pixelData)];
            ++blue[qBlue(pixelData)];

        }

    }

    // we compute the grey values once we red all rgb pixels
    // this is much faster than calculate the grey values for each pixel
    QList<int> grey(256);
    for(int i = 0; i < 256; ++i)
        grey[i] = red[i]*0.34375 + green[i]*0.5 + blue[i]*0.15625;

    // find the max values for normalization
    double max_red = *std::max_element(red.begin(), red.end());
    double max_green = *std::max_element(green.begin(), green.end());
    double max_blue = *std::max_element(blue.begin(), blue.end());
    double max_grey = *std::max_element(grey.begin(), grey.end());
    double max_rgb = qMax(max_red, qMax(max_green, max_blue));

    // the return lists, normalized
    QList<float> ret_red(256);
    QList<float> ret_green(256);
    QList<float> ret_blue(256);
    QList<float> ret_gray(256);

    // normalize values
    std::transform(red.begin(), red.end(), ret_red.begin(), [=](float val) { return val/max_rgb; });
    std::transform(green.begin(), green.end(), ret_green.begin(), [=](float val) { return val/max_rgb; });
    std::transform(blue.begin(), blue.end(), ret_blue.begin(), [=](float val) { return val/max_rgb; });
    std::transform(grey.begin(), grey.end(), ret_gray.begin(), [=](float val) { return val/max_grey; });

    // store values
    ret << QVariant::fromValue(ret_red);
    ret << QVariant::fromValue(ret_green);
    ret << QVariant::fromValue(ret_blue);
    ret << QVariant::fromValue(ret_gray);

    histogramCache.insert(key, ret);

    Q_EMIT histogramDataLoaded(ret, index);

}

bool PQCScriptsImages::isMpvVideo(QString path) {

    qDebug() << "args: path =" << path;

    bool supported = false;

#ifdef PQMVIDEOMPV

    QString suf = QFileInfo(path).suffix().toLower();
    if(PQCImageFormats::get().getEnabledFormatsLibmpv().contains(suf)) {

        supported = true;

    } else {

        QMimeDatabase db;
        QString mimetype = db.mimeTypeForFile(path).name();
        if(PQCImageFormats::get().getEnabledMimeTypesLibmpv().contains(mimetype))
            supported = true;

    }

#ifdef PQMVIDEOQT
    if(supported) {
        if(!PQCSettings::get()["filetypesVideoPreferLibmpv"].toBool())
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
    if(PQCImageFormats::get().getEnabledFormatsVideo().contains(suf)) {

        supported = true;

    } else {

        QMimeDatabase db;
        QString mimetype = db.mimeTypeForFile(path).name();
        if(PQCImageFormats::get().getEnabledMimeTypesVideo().contains(mimetype))
            supported = true;

    }

#endif

    return supported;

}

bool PQCScriptsImages::isPDFDocument(QString path) {

    qDebug() << "args: path =" << path;

    QString suf = QFileInfo(path).suffix().toLower();
    if(PQCImageFormats::get().getEnabledFormatsPoppler().contains(suf))
        return true;

    QMimeDatabase db;
    QString mimetype = db.mimeTypeForFile(path).name();
    if(PQCImageFormats::get().getEnabledMimeTypesPoppler().contains(mimetype))
        return true;

    return false;

}

bool PQCScriptsImages::isArchive(QString path) {

    qDebug() << "args: path =" << path;

    QString suf = QFileInfo(path).suffix().toLower();
    if(PQCImageFormats::get().getEnabledFormatsLibArchive().contains(suf))
        return true;

    QMimeDatabase db;
    QString mimetype = db.mimeTypeForFile(path).name();
    if(PQCImageFormats::get().getEnabledMimeTypesLibArchive().contains(mimetype))
        return true;

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

    alphaChannels.insert(path, alpha);

}

bool PQCScriptsImages::supportsTransparency(QString path) {

    qDebug() << "args: path =" << path;

    return alphaChannels.value(path, false);

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

        if(PQCSettings::get()["filetypesLoadAppleLivePhotos"].toBool()) {

            QString videopath = QString("%1/%2.mov").arg(info.absolutePath(), info.baseName());
            QFileInfo videoinfo(videopath);
            if(videoinfo.exists())
                return 1;

        }

        if(!PQCSettings::get()["filetypesLoadMotionPhotos"].toBool())
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
    // and we wont need to check again

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

    char *data = new char[info.size()];

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
                outfile.open(QIODevice::WriteOnly);
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
    PQCLoadImage::get().load(path, QSize(-1,-1), origSize, img);

    // convert to gray scale
    img.convertTo(QImage::Format_Grayscale8);

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
    const ZXing::ReaderOptions hints = ZXing::ReaderOptions().setFormats(ZXing::BarcodeFormat::Any);
    const std::vector<ZXing::Result> results = ZXing::ReadBarcodes({img.bits(), img.width(), img.height(), ZXing::ImageFormat::Lum}, hints);

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
    if(PQCSettings::get()["filetypesExternalUnrar"].toBool() && (suffix == "cbr" || suffix == "rar")) {

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
            file.open(QIODevice::WriteOnly);
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
        qWarning() << "Error occured loading PDF";
        return "";
    }

    QSizeF _pageSize = (doc.pagePointSize(page)/72.0*qApp->primaryScreen()->physicalDotsPerInch())*(PQCSettings::get()["filetypesPDFQuality"].toDouble()/72.0);
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

    const double quality = PQCSettings::get()["filetypesPDFQuality"].toDouble();

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
    targetfile = PQCScriptsFilesPaths::get().selectFileFromDialog("Save", targetfile, PQCImageFormats::get().detectFormatId(targetfile), true);

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
        qWarning() << "Error occured loading PDF";
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

void PQCScriptsImages::loadColorProfileInfo() {

#ifdef PQMLCMS2

    QFileInfo info(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR());
    if(info.lastModified().toMSecsSinceEpoch() != importedICCLastMod) {

        // we always check for imported profile changes
        importedColorProfiles.clear();
        importedColorProfileDescriptions.clear();

        importedICCLastMod = info.lastModified().toMSecsSinceEpoch();

        QDir dir(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR());
        dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);
        QStringList lst = dir.entryList();
        for(auto &f : std::as_const(lst)) {

            QString fullpath = QString("%1/%2").arg(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR(), f);

            QFile file(fullpath);

            if(!file.open(QIODevice::ReadOnly)) {
                qWarning() << "Unable to open imported color profile:" << fullpath;
                continue;
            }

            QByteArray bt = file.readAll();
            cmsHPROFILE profile = cmsOpenProfileFromMem(bt.constData(), bt.size());

            if(!profile) {
                qWarning() << "Unable to create imported color profile:" << fullpath;
                continue;
            }

            const int bufSize = 100;
            char buf[bufSize];

#if LCMS_VERSION >= 2160
            cmsGetProfileInfoUTF8(profile, cmsInfoDescription,
                                  "en", "US",
                                  buf, bufSize);
#else
            cmsGetProfileInfoASCII(profile, cmsInfoDescription,
                                   "en", "US",
                                   buf, bufSize);
#endif

            importedColorProfiles << fullpath;
            importedColorProfileDescriptions << QString("%1 <i>(imported)</i>").arg(buf);

        }

    }

#endif


    if(externalColorProfiles.length() == 0) {

        externalColorProfiles.clear();
        externalColorProfileDescriptions.clear();

#ifdef Q_OS_UNIX
#ifdef PQMLCMS2

        if(externalColorProfiles.length() == 0) {

            QString basedir = "/usr/share/color/icc";
            QDir dir(basedir);
            dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);
            QStringList lst = dir.entryList();
            for(auto &f : std::as_const(lst)) {

                QString fullpath = QString("%1/%2").arg(basedir, f);

                QFile file(fullpath);

                if(!file.open(QIODevice::ReadOnly)) {
                    qWarning() << "Unable to open color profile:" << fullpath;
                    continue;
                }

                QByteArray bt = file.readAll();
                cmsHPROFILE profile = cmsOpenProfileFromMem(bt.constData(), bt.size());

                if(!profile) {
                    qWarning() << "Unable to create color profile:" << fullpath;
                    continue;
                }

                const int bufSize = 100;
                char buf[bufSize];

#if LCMS_VERSION >= 2160
                cmsGetProfileInfoUTF8(profile, cmsInfoDescription,
                                      "en", "US",
                                      buf, bufSize);
#else
                cmsGetProfileInfoASCII(profile, cmsInfoDescription,
                                       "en", "US",
                                       buf, bufSize);
#endif

                externalColorProfiles << fullpath;
                externalColorProfileDescriptions << QString("%1 <i>(system)</i>").arg(buf);

            }

        }

    #else

        QString basedir = "/usr/share/color/icc";
        QDir dir(basedir);
        dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);
        QStringList lst = dir.entryList();
        for(auto &f : std::as_const(lst)) {
            QFile iccfile(QString("%1/%2").arg(basedir, f));
            if(iccfile.open(QIODevice::ReadOnly)) {
                QColorSpace sp = QColorSpace::fromIccProfile(iccfile.readAll());
                if(sp.isValid()) {
                    externalColorProfiles << QString("%1/%2").arg(basedir, f);
                    externalColorProfileDescriptions << QString("%1 <i>(system)</i>").arg(sp.description());
                }
            }
        }

#endif
#endif

    }

    if(integratedColorProfileDescriptions.length() == 0) {

        integratedColorProfiles.clear();
        integratedColorProfileDescriptions.clear();

        integratedColorProfiles << QColorSpace::SRgb
                                << QColorSpace::SRgbLinear
                                << QColorSpace::AdobeRgb
                                << QColorSpace::DisplayP3
                                << QColorSpace::ProPhotoRgb;

        for(auto &c : std::as_const(integratedColorProfiles))
            integratedColorProfileDescriptions << QColorSpace(c).description();

    }

}

QStringList PQCScriptsImages::getColorProfileDescriptions() {

    qDebug() << "";

    QStringList ret;

    ret << importedColorProfileDescriptions;
    ret << integratedColorProfileDescriptions;
    ret << externalColorProfileDescriptions;

    return ret;

}

QStringList PQCScriptsImages::getColorProfiles() {

    qDebug() << "";

    QStringList ret;

    ret << importedColorProfiles;
    for(int i = 0; i < integratedColorProfiles.length(); ++i)
        ret << QString("::%1").arg(i);
    ret << externalColorProfiles;

    return ret;

}

QString PQCScriptsImages::getColorProfileID(int index) {

    if(index < importedColorProfiles.length())
        return importedColorProfiles[index];

    index -= importedColorProfiles.length();

    if(index < integratedColorProfiles.length())
        return QString("::%1").arg(static_cast<int>(index));

    index -= integratedColorProfiles.length();

    if(index < externalColorProfiles.length())
        return externalColorProfiles[index];

    return "";

}

void PQCScriptsImages::setColorProfile(QString path, int index) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: index =" << index;

    if(index == -1)
        iccColorProfiles.remove(path);
    else
        iccColorProfiles[path] = getColorProfileID(index);

}

QString PQCScriptsImages::getColorProfileFor(QString path) {

    qDebug() << "args: path =" << path;

    return iccColorProfiles.value(path, "");

}

QString PQCScriptsImages::getDescriptionForColorSpace(QString path) {

    qDebug() << "args: path =" << path;

    if(!iccColorProfiles.contains(path))
        return QColorSpace(QColorSpace::SRgb).description();

    QString name = iccColorProfiles[path];

    if(name.startsWith("::")) {
        int index = name.remove(0,2).toInt();
        return QColorSpace(integratedColorProfiles[index]).description();
    }

    int index = importedColorProfiles.indexOf(name);
    if(index != -1)
        return importedColorProfileDescriptions[index];

    index = externalColorProfiles.indexOf(name);
    if(index != -1)
        return externalColorProfileDescriptions[index];

    return "[unknown color space]";

}

QStringList PQCScriptsImages::getExternalColorProfiles() {
    return externalColorProfiles;
}

QStringList PQCScriptsImages::getExternalColorProfileDescriptions() {
    return externalColorProfileDescriptions;
}

QStringList PQCScriptsImages::getImportedColorProfiles() {
    return importedColorProfiles;
}

QStringList PQCScriptsImages::getImportedColorProfileDescriptions() {
    return importedColorProfileDescriptions;
}

QList<QColorSpace::NamedColorSpace> PQCScriptsImages::getIntegratedColorProfiles() {
    return integratedColorProfiles;
}

int PQCScriptsImages::getIndexForColorProfile(QString desc) {

    qDebug() << "args: desc =" << desc;

    int index = integratedColorProfileDescriptions.indexOf(desc);
    if(index > -1)
        return index;

    return integratedColorProfileDescriptions.length() + externalColorProfileDescriptions.indexOf(desc);

}

#ifdef PQMLCMS2
int PQCScriptsImages::toLcmsFormat(QImage::Format fmt) {

    switch (fmt) {

        case QImage::Format_ARGB32:  //  (0xAARRGGBB)
        case QImage::Format_RGB32:   //  (0xffRRGGBB)
            return TYPE_BGRA_8;

        case QImage::Format_RGB888:
            return TYPE_RGB_8;       // 24-bit RGB format (8-8-8).

        case QImage::Format_RGBX8888:
        case QImage::Format_RGBA8888:
            return TYPE_RGBA_8;

        case QImage::Format_Grayscale8:
            return TYPE_GRAY_8;

        case QImage::Format_Grayscale16:
            return TYPE_GRAY_16;

        case QImage::Format_RGBA64:
        case QImage::Format_RGBX64:
            return TYPE_RGBA_16;

        case QImage::Format_BGR888:
            return TYPE_BGR_8;

        default:
            return 0;

    }

}
#endif

bool PQCScriptsImages::importColorProfile() {

    qDebug() << "";

    PQCNotify::get().setModalFileDialogOpen(true);

#ifdef Q_OS_UNIX
    QString loc = "/usr/share/color/icc";
#else
    QString loc = QDir::homePath();
#endif
    if(colorlastlocation->open(QIODevice::ReadOnly)) {
        QTextStream in(colorlastlocation);
        QString tmp = in.readAll();
        if(tmp != "" && QFileInfo::exists(tmp))
            loc = tmp;
        colorlastlocation->close();
    }

    QFileDialog diag;
    diag.setLabelText(QFileDialog::Accept, "Import");
    diag.setFileMode(QFileDialog::AnyFile);
    diag.setModal(true);
    diag.setAcceptMode(QFileDialog::AcceptOpen);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    diag.setNameFilter("*.icc;;All Files (*.*)");
    diag.setDirectory(loc);

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {

            PQCNotify::get().setModalFileDialogOpen(false);

            QString fn = fileNames[0];
            QFileInfo info(fn);

            if(colorlastlocation->open(QIODevice::WriteOnly)) {
                QTextStream out(colorlastlocation);
                out << info.absolutePath();
                colorlastlocation->close();
            }

            QDir dir(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR());
            if(!dir.exists()) {
                if(!dir.mkpath(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR())) {
                    qWarning() << "Unable to create internal ICC directory";
                    return false;
                }
            }

            if(!QFile::copy(fn,QString("%1/%2").arg(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR(), info.fileName()))) {
                qWarning() << "Unable to import file";
                return false;
            }

            loadColorProfileInfo();

            return true;

        }
    }

    PQCNotify::get().setModalFileDialogOpen(false);
    return true;

}

bool PQCScriptsImages::removeImportedColorProfile(int index) {

    qDebug() << "args: index =" << index;

    if(index < importedColorProfiles.length()) {

        if(QFile::remove(importedColorProfiles[index])) {
            importedColorProfiles.remove(index, 1);
            importedColorProfileDescriptions.remove(index, 1);
            loadColorProfileInfo();
            return true;
        } else
            return false;

    } else
        return false;


}

bool PQCScriptsImages::applyColorProfile(QString filename, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: img";

    // If enabled we do some color profile management now
    if(!PQCSettings::get()["imageviewColorSpaceEnable"].toBool()) {
        qDebug() << "Color space handling disabled";
        PQCNotify::get().setColorProfileFor(filename, QColorSpace(QColorSpace::SRgb).description());
        return true;
    }

    bool manualSelectionCausedError = false;

    bool attemptedToSetLCMS2Profile = false;

    // check if a color profile has been set by the user for this file
    QString profileName = getColorProfileFor(filename);

    // if no color space is set we set the default one
    // without this some conversion below might fail
    bool colorSpaceManuallySet = false;
    if(profileName != "" && !img.colorSpace().isValid()) {
        colorSpaceManuallySet = true;
        img.setColorSpace(QColorSpace(QColorSpace::SRgb));
    }

    // if internal profile is manually selected
    if(profileName.startsWith("::")) {

        qDebug() << "Loading integrated color profile:" << profileName;

        int index = profileName.remove(0,2).toInt();

        if(index < integratedColorProfiles.length() && applyColorSpaceQt(img, filename, QColorSpace(integratedColorProfiles[index])))
            return true;
        else
            manualSelectionCausedError = true;

#ifndef PQMLCMS2

    } else if(profileName != "") {

        // basic handling of external color profiles

        QColorSpace sp;

        QFile f(profileName);
        if(f.open(QIODevice::ReadOnly))
            sp = QColorSpace::fromIccProfile(f.readAll());

        if(applyColorSpaceQt(img, filename, sp))
            return true;
        else
            manualSelectionCausedError = true;

#endif

    }

#ifdef PQMLCMS2

    QStringList lcmsProfileList;
    lcmsProfileList << importedColorProfiles;
    lcmsProfileList << externalColorProfiles;

    // if external profile is manually selected
    if(profileName != "" && !profileName.startsWith("::")) {

        qDebug() << "Loading external color profile:" << profileName;

        int index = lcmsProfileList.indexOf(profileName);
        cmsHPROFILE targetProfile = nullptr;
        if(index != -1) {

            QFile f(profileName);
            if(f.open(QIODevice::ReadOnly)) {
                QByteArray bt = f.readAll();
                targetProfile = cmsOpenProfileFromMem(bt.constData(), bt.size());
            }

            attemptedToSetLCMS2Profile = true;

            if(targetProfile && applyColorSpaceLCMS2(img, filename, targetProfile)) {
                lcms2CountFailedApplications = 0;
                return true;
            } else
                manualSelectionCausedError = true;

        }

    }

    // if no profile has been applied and we need to check for embedded profiles
    if(!colorSpaceManuallySet && PQCSettings::get()["imageviewColorSpaceLoadEmbedded"].toBool()) {

        qDebug() << "Checking for embedded color profiles";

        cmsHPROFILE targetProfile = cmsOpenProfileFromMem(img.colorSpace().iccProfile().constData(),
                                                          img.colorSpace().iccProfile().size());

        if(targetProfile) {
            attemptedToSetLCMS2Profile = true;
            if(applyColorSpaceLCMS2(img, filename, targetProfile)) {
                lcms2CountFailedApplications = 0;
                return !manualSelectionCausedError;
            }
        }

    }

#endif

    // no profile (successfully) applied, set default one (if selected)
    QString def = PQCSettings::get()["imageviewColorSpaceDefault"].toString();
    if(def != "") {

        qDebug() << "Applying color profile selected as default:" << def;

        // make sure we have a valid starting profile
        if(!img.colorSpace().isValid())
            img.setColorSpace(QColorSpace(QColorSpace::SRgb));

        if(def.startsWith("::")) {

            int index = def.remove(0,2).toInt();

            if(index < integratedColorProfiles.length() && applyColorSpaceQt(img, filename, QColorSpace(integratedColorProfiles[index])))
                return !manualSelectionCausedError;

#ifdef PQMLCMS2

        } else {

            int index = lcmsProfileList.indexOf(def);
            cmsHPROFILE targetProfile = nullptr;
            if(index != -1) {

                QFile f(def);
                if(f.open(QIODevice::ReadOnly)) {
                    QByteArray bt = f.readAll();
                    targetProfile = cmsOpenProfileFromMem(bt.constData(), bt.size());
                }

                if(targetProfile ) {
                    attemptedToSetLCMS2Profile = true;
                    if(applyColorSpaceLCMS2(img, filename, targetProfile)) {
                        lcms2CountFailedApplications = 0;
                        return !manualSelectionCausedError;
                    }
                }

            }

# else

        } else {

            // basic handling of external color profiles

            QColorSpace sp;

            QFile f(def);
            if(f.open(QIODevice::ReadOnly))
                sp = QColorSpace::fromIccProfile(f.readAll());

            if(applyColorSpaceQt(img, filename, sp))
                return !manualSelectionCausedError;

#endif

        }

    }

    // if a profile was attempted to be set with LCMS2 but failed (i.e., we ended up here)
    // then we increment a counter and show a notification message.
    // If the counter passes 5 then we disable support for color spaces.
    if(attemptedToSetLCMS2Profile && profileName == "") {

        lcms2CountFailedApplications += 1;

        if(lcms2CountFailedApplications > 5) {
            PQCSettings::get().update("imageviewColorSpaceEnable", false);
            Q_EMIT PQCNotify::get().showNotificationMessage(QCoreApplication::translate("imageprovider", "Application of color profile failed for:") + "<br><i>" + PQCScriptsFilesPaths::get().getFilename(filename) + "</i>");
            Q_EMIT PQCNotify::get().showNotificationMessage(QCoreApplication::translate("imageprovider", "Application of color profiles failed repeatedly. Support for color spaces will be disabled, but can be enabled again in the settings manager."));
        } else {
            Q_EMIT PQCNotify::get().showNotificationMessage(QCoreApplication::translate("imageprovider", "Application of color profile failed for:") + "<br><i>" + PQCScriptsFilesPaths::get().getFilename(filename) + "</i>");
        }

    }

    // no profile (successfully) applied, set default name
    PQCNotify::get().setColorProfileFor(filename, QColorSpace(QColorSpace::SRgb).description());
    qDebug() << "Using default color profile";
    return !manualSelectionCausedError;

}

bool PQCScriptsImages::applyColorSpaceQt(QImage &img, QString filename, QColorSpace sp) {

    QImage ret;
    ret = img.convertedToColorSpace(sp);
    if(ret.isNull()) {
        qWarning() << "Integrated color profile could not be applied.";
        return false;
    } else {
        const QString desc = sp.description();
        qDebug() << "Applying integrated color profile:" << desc;
        PQCNotify::get().setColorProfileFor(filename, desc);
        img = ret;
        return true;
    }

}

#ifdef PQMLCMS2
bool PQCScriptsImages::applyColorSpaceLCMS2(QImage &img, QString filename, cmsHPROFILE targetProfile) {

    int lcms2SourceFormat = PQCScriptsImages::get().toLcmsFormat(img.format());

    QImage::Format targetFormat = img.format();
    // this format causes problems with lcms2
    // no error is caused but the resulting image is fully transparent
    // removing the alpha channel seems to fix this
    if(img.format() == QImage::Format_ARGB32)
        targetFormat = QImage::Format_RGB32;

    int lcms2targetFormat = PQCScriptsImages::get().toLcmsFormat(img.format());

    // Outputting an RGBA64 image with LCMS2 results in a blank rectangle.
    // Reading it seems to work just fine, however.
    // Thus we make sure to output the image in a working format here.
    if(img.format() == QImage::Format_RGBA64) {
        targetFormat = QImage::Format_RGB32;
        lcms2targetFormat = PQCScriptsImages::get().toLcmsFormat(QImage::Format_RGB32);
    }

    if(lcms2SourceFormat == 0 || lcms2targetFormat == 0) {
        qWarning() << "Unknown image format. Attempting to convert image to format known to LCMS2.";
        img.convertTo(QImage::Format_ARGB32);
        targetFormat = QImage::Format_RGB32;
        lcms2SourceFormat = PQCScriptsImages::get().toLcmsFormat(img.format());
        lcms2targetFormat = lcms2SourceFormat;
        if(img.isNull()) {
            qWarning() << "Error converting image to ARGB32. Not applying color profile.";
            return false;
        }
        if(lcms2targetFormat == 0) {
            qWarning() << "Unable to 'fix' image format. Not applying color profile.";
            return false;
        }
    }

    // Create a transformation from source (sRGB) to destination (provided ICC profile) color space
    cmsHTRANSFORM transform = cmsCreateTransform(targetProfile, lcms2SourceFormat, cmsCreate_sRGBProfile(), lcms2targetFormat, INTENT_PERCEPTUAL, 0);
    if (!transform) {
        // Handle error, maybe close profile and return original image or null image
        cmsCloseProfile(targetProfile);
        qWarning() << "Error creating transform for external color profile";
        return false;
    } else {

        // since the target format might not support alpha channels we use black instead of transparent to fill the initial image.
        // we don't have to fill the image for cmsDoTransform but it allows for additional checking whether cmsDoTransform succeeded.
        QImage ret(img.size(), targetFormat);
        ret.fill(Qt::black);

        // Perform color space conversion
        cmsDoTransform(transform, img.constBits(), ret.bits(), img.width() * img.height());

        // transform failed returning null image
        if(ret.isNull()) {
            qWarning() << "Failed to apply external color profile, null image returned";
            return false;
        }

        // check if image is all black -> transform failed
        bool allblack = true;
        for(int x = 0; x < img.width(); ++x) {
            for(int y = 0; y < img.height(); ++y) {
                if(ret.pixelColor(x,y).black() < 255) {
                    allblack = false;
                    break;
                }
            }
            if(!allblack) break;
        }

        if(allblack) {
            qWarning() << "Failed to apply external color profile, image completely black";
            return false;
        }

        const int bufSize = 100;
        char buf[bufSize];

#if LCMS_VERSION >= 2160
        cmsGetProfileInfoUTF8(targetProfile, cmsInfoDescription,
                              "en", "US",
                              buf, bufSize);
#else
        cmsGetProfileInfoASCII(targetProfile, cmsInfoDescription,
                               "en", "US",
                               buf, bufSize);
#endif

        // Release resources
        cmsDeleteTransform(transform);
        cmsCloseProfile(targetProfile);

        qDebug() << "Applying external color profile:" << buf;

        PQCNotify::get().setColorProfileFor(filename, buf);

        img = ret;

        return true;

    }
}
#endif

QString PQCScriptsImages::detectVideoColorProfile(QString path) {

    qDebug() << "args: path =" << path;

#ifdef Q_OS_UNIX

    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "mediainfo");
    which.waitForFinished();

    if(!which.exitCode()) {

        QProcess p;
        p.start("mediainfo", QStringList() << path);

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
            QString out = (toUtf16(outdata));

            if(out.contains("Color space  "))
                return out.split("Color space ")[1].split(" : ")[1].split("\n")[0].trimmed();

        }

    }

    which.start("which", QStringList() << "ffprobe");
    which.waitForFinished();

    if(!which.exitCode()) {

        QProcess p;
        p.start("ffprobe", QStringList() << "-show_streams" << path);

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
            QString out = (toUtf16(outdata));

            if(out.contains("pix_fmt="))
                return out.split("pix_fmt=")[1].split("\n")[0].trimmed();

        }

    }


#endif

    return "";

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

        // we cache a once calculated value for 5 minutes
        if(QDateTime::currentMSecsSinceEpoch()-devicePixelRatioCachedWhen < 1000*60*5) {
            return devicePixelRatioCached;
        }

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

                devicePixelRatioCached = useRatio;
                devicePixelRatioCachedWhen = QDateTime::currentMSecsSinceEpoch();
                return useRatio;

            // if error occured, then we effectively disable this feature
            } else {

                devicePixelRatioCached = 1;
                devicePixelRatioCachedWhen = QDateTime::currentMSecsSinceEpoch();
                return 1;

            }

        }

    }

#endif

    // if the above didn't work, or we are on Windows
    return qApp->devicePixelRatio();

}
