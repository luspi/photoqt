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
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_settings.h>
#include <pqc_imageformats.h>
#include <pqc_loadimage.h>
#include <pqc_configfiles.h>

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

PQCScriptsImages::PQCScriptsImages() {
}

PQCScriptsImages::~PQCScriptsImages() {

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
            return "file:///" + path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:///" + path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:///" + path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file:///" + path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:///" + path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:///" + path;
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

    QStringList ret;

    const QFileInfo info(path);

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
                        if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix()))
                            ret.append(f);
                    }
                } else {
                    for(const QString &f : std::as_const(allfiles)) {
                        if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix()))
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
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLocal8Bit().data(), 10240);

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
            if((PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(filenameinside).suffix())))
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
    QList<int> grey(256);

    // Loop over all rows of the image
    for(int i = 0; i < img.height(); ++i) {

        // Get the pixel data of row i of the image
        QRgb *rowData = (QRgb*)img.scanLine(i);

        // Loop over all columns
        for(int j = 0; j < img.width(); ++j) {

            // Get pixel data of pixel at column j in row i
            QRgb pixelData = rowData[j];

            // store color data
            ++grey[qGray(pixelData)];
            ++red[qRed(pixelData)];
            ++green[qGreen(pixelData)];
            ++blue[qBlue(pixelData)];

        }

    }

    // find the max values for normalization
    double max_red = *std::max_element(red.begin(), red.end());
    double max_green = *std::max_element(green.begin(), green.end());
    double max_blue = *std::max_element(blue.begin(), blue.end());

    double max_grey = *std::max_element(grey.begin(), grey.end());
    double max_rgb = qMax(max_red, qMax(max_green, max_blue));

    // the return lists, normalized
    QList<double> ret_red(256);
    QList<double> ret_green(256);
    QList<double> ret_blue(256);
    QList<double> ret_grey(256);

    // normalize values
    std::transform(red.begin(), red.end(), ret_red.begin(), [=](double val) { return val/max_rgb; });
    std::transform(green.begin(), green.end(), ret_green.begin(), [=](double val) { return val/max_rgb; });
    std::transform(blue.begin(), blue.end(), ret_blue.begin(), [=](double val) { return val/max_rgb; });
    std::transform(grey.begin(), grey.end(), ret_grey.begin(), [=](double val) { return val/max_grey; });

    // store values
    ret << QVariant::fromValue(ret_red);
    ret << QVariant::fromValue(ret_green);
    ret << QVariant::fromValue(ret_blue);
    ret << QVariant::fromValue(ret_grey);

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

    if(path.contains("::PQT::"))
        path = path.split("::PQT::").at(1);

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

    const QString videofilename = QString("%1/motionphotos/%2.mp4").arg(PQCConfigFiles::CACHE_DIR(), info.baseName());
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

    if(!PQCSettings::get()["filetypesCheckForPhotoSphere"].toBool())
        return false;

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
