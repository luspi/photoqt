/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <scripts/pqc_scriptsmetadata.h>
#include <pqc_settingscpp.h>
#include <pqc_imagehandler.h>
#include <pqc_configfiles.h>
#include <pqc_notify_cpp.h>
#include <pqc_helper.h>

#ifdef Q_OS_UNIX
#include <sys/xattr.h>
#endif

#ifdef Q_OS_WIN
#include <shobjidl_core.h>
#include <propvarutil.h>
#include <propkey.h>
#endif

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

#ifdef PQMZXINGQT
#include <ZXing/ZXingQt.h>
#elif defined(PQMZXING)
#if __has_include(<ZXing/WriteBarcode.h>)
#include <ZXing/ZXingCpp.h>
#else
#include <ZXing/ReadBarcode.h>
#include <ZXing/ZXVersion.h>
#endif
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

    // if the formats changed then we can't rely on the archive cache anymore
#if __cplusplus >= 202002L
    connect(&PQCImageHandler::get(), &PQCImageHandler::formatsUpdated, this, [=, this]() {archiveContentCache.clear();});
#else
    connect(&PQCImageHandler::get(), &PQCImageHandler::formatsUpdated, this, [=]() {archiveContentCache.clear();});
#endif

    devicePixelRatioCachedWhen = 0;

}

PQCScriptsImages::~PQCScriptsImages() {}

bool PQCScriptsImages::isItAnimated(QString filename) {
    QImageReader reader(filename);
    return (reader.supportsAnimation()&&reader.imageCount()>1);
}

QString PQCScriptsImages::getIconPathFromTheme(QString binary) {

    qDebug() << "args: binary =" << binary;

    // We go through all the themeSearchPath elements
    for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

        // Setup path (this is the most likely directory) and format (PNG)
        QString path = QIcon::themeSearchPaths().at(i) % "/hicolor/32x32/apps/" % binary.trimmed() % ".png";
        if(QFile(path).exists())
            return "file:" % path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" % path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" % path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file:" % path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" % path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" % path;
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

    if(!pix.load(filename))
        return "";

    if(pix.width() > 64 || pix.height() > 64)
        pix = pix.scaled(64, 64, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    QByteArray bytes;
    QBuffer buffer(&bytes);

    if(!buffer.open(QIODevice::WriteOnly))
        return "";

    if(!pix.save(&buffer, "PNG"))
        return "";

    return QString::fromLatin1(bytes.toBase64());

}

void PQCScriptsImages::listArchiveContent(QString path) {

    qDebug() << "args: path =" << path;

    path = PQCHelper::extractInsideARCFilename(path);

    const bool limitArchiveFileCount = PQCSettingsCPP::get().getFiletypesArchiveDontLoadMoreFilesThan();
    const int limitArchiveFileCountNumber = PQCSettingsCPP::get().getFiletypesArchiveDontLoadMoreFilesThanCount();

    const QFileInfo info(path);
    QString cacheKey = QString("%1::%2::%3::%4").arg(info.lastModified().toMSecsSinceEpoch())
                                                .arg(path)
                                                .arg(PQCSettingsCPP::get().getImageviewSortImagesAscending())
                                                .arg(limitArchiveFileCount ? limitArchiveFileCountNumber : -1);

    if(archiveContentCache.contains(cacheKey)) {
        qDebug() << "Found cached content, using that.";
        Q_EMIT haveArchiveContentFor(path, archiveContentCache[cacheKey]);
        return;
    }

    if(inProcesOfLoadingTheseArchives.contains(cacheKey)) {
        qDebug() << "Archive is currently being loaded. Waiting...";
#if __cplusplus >= 202002L
        QTimer::singleShot(500, this, [=, this]() { listArchiveContent(path); } );
#else
        QTimer::singleShot(500, this, [=]() { listArchiveContent(path); } );
#endif
        return;
    }

    inProcesOfLoadingTheseArchives.append(cacheKey);

#if __cplusplus >= 202002L
    QFuture<void> f = QtConcurrent::run([=, this]() {
#else
    QFuture<void> f = QtConcurrent::run([=]() {
#endif
        const QStringList ret = PQCScriptsImages::listArchiveContentWithoutThread(path, cacheKey);
        Q_EMIT haveArchiveContentFor(path, ret);
        inProcesOfLoadingTheseArchives.removeAt(inProcesOfLoadingTheseArchives.indexOf(cacheKey));
    });

}

QStringList PQCScriptsImages::listArchiveContentWithoutThread(QString path, QString cacheKey) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: cacheKey =" << cacheKey;

    QStringList ret;

    const bool limitArchiveFileCount = PQCSettingsCPP::get().getFiletypesArchiveDontLoadMoreFilesThan();
    const int limitArchiveFileCountNumber = PQCSettingsCPP::get().getFiletypesArchiveDontLoadMoreFilesThanCount();

    const QFileInfo info(path);

    if(cacheKey.isEmpty()) {
        cacheKey = QString("%1::%2::%3::%4").arg(info.lastModified().toMSecsSinceEpoch())
                                            .arg(path)
                                            .arg(PQCSettingsCPP::get().getImageviewSortImagesAscending())
                                            .arg(limitArchiveFileCount ? limitArchiveFileCountNumber : -1);

        qDebug() << "Constructed cacheKey =" << cacheKey;
    }

    if(archiveContentCache.contains(cacheKey)) {
        qDebug() << "Found cached content, using that.";
        return archiveContentCache[cacheKey];
    }

    const QSet<QString> enabledFormats = PQCImageHandler::get().getSuffixes();

#ifndef Q_OS_WIN

    const QString suffix = info.suffix().toLower();

    if(PQCSettingsCPP::get().getFiletypesExternalUnrar() && (suffix == "cbr" || suffix == "rar")) {

        QProcess p;
        p.setProcessChannelMode(QProcess::MergedChannels);
        p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

        if(p.waitForStarted()) {

            if(p.waitForFinished()) {

                if(p.exitStatus() == QProcess::NormalExit && p.exitCode() == 0) {

                    ret = QString::fromLocal8Bit(p.readAllStandardOutput()).split('\n', Qt::SkipEmptyParts);

                    // remove archives and unsupported files
                    ret.erase(std::remove_if(ret.begin(), ret.end(), [&](const QString &f) {
                                  return (isArchive(f) || !enabledFormats.contains(QFileInfo(f).suffix().toLower()));
                              }), ret.end());

                    // limit how many files to load
                    if(limitArchiveFileCount)
                        ret = ret.mid(0, limitArchiveFileCountNumber);

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
        QByteArray tmpPath = QFile::encodeName(info.absoluteFilePath());
        int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            qWarning() << "ERROR: archive_read_open_filename() returned code of" << r;
            qWarning() << "Archive:" << info.absoluteFilePath();
            archive_read_free(a);
            return ret;
        }

        int counter = 0;

        // Loop over entries in archive
        struct archive_entry *entry;
        while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

            ++counter;

            // Read the current file entry
            // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
            // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
            // and PhotoQt might crash if not handled properly -> check before converting to QString
            const wchar_t *wpath = archive_entry_pathname_w(entry);
            if(!wpath) continue;
            QString filenameinside = QString::fromWCharArray(wpath);

            // If supported file format, append to temporary list
            const QFileInfo info(filenameinside);
            if(!isArchive(filenameinside, true) && (enabledFormats.contains(info.suffix().toLower()) || enabledFormats.contains(info.completeSuffix().toLower())))
                ret.append(filenameinside);

            // limit how many files to load
            if(limitArchiveFileCount && counter > limitArchiveFileCountNumber)
                break;

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
    collator.setLocale(QLocale::system());
#ifndef PQMWITHOUTICU
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);
#endif

    if(PQCSettingsCPP::get().getImageviewSortImagesAscending())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    {
        QMutexLocker locker(&archiveMutex);
        archiveContentCache.insert(cacheKey, ret);
    }

    return ret;

}

QString PQCScriptsImages::convertSecondsToPosition(int t) {

    return QString("%1:%2").arg(t/60, 2, 10, '0').arg(t%60, 2, 10, '0');

}

bool PQCScriptsImages::isMpvVideo(QString path) {

    qDebug() << "args: path =" << path;

    bool supported = false;

#ifdef PQMVIDEOMPV

    QFileInfo info(path);
    const QSet<QString> suffixes = PQCImageHandler::get().getSuffixes("libmpv");
    if(suffixes.contains(info.suffix().toLower()) || suffixes.contains(info.completeSuffix().toLower())) {

        supported = true;

    } else {

        QMimeDatabase db;
        if(PQCImageHandler::get().getMimetypes("libmpv").contains(db.mimeTypeForFile(path).name()))
            supported = true;

    }

#ifdef PQMVIDEOQT
    if(supported) {
        if(PQCSettingsCPP::get().getFiletypesVideoBackend().startsWith("qt"))
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

    QFileInfo info = QFileInfo(path);
    const QSet<QString> suffixes = PQCImageHandler::get().getSuffixes("video");
    if(suffixes.contains(info.suffix().toLower()) || suffixes.contains(info.completeSuffix().toLower())) {

        supported = true;

    } else {

        QMimeDatabase db;
        if(PQCImageHandler::get().getMimetypes("video").contains(db.mimeTypeForFile(path).name()))
            supported = true;

    }

#ifdef PQMVIDEOMPV
    if(supported) {
        if(PQCSettingsCPP::get().getFiletypesVideoBackend().startsWith("mpv"))
            supported = false;
    }
#endif

#endif

    return supported;

}

bool PQCScriptsImages::isPDFDocument(QString path) {

    qDebug() << "args: path =" << path;

#if defined(PQMPOPPLER) || defined(PQMQTPDF)
    QFileInfo info(path);
    const QSet<QString> set = PQCImageHandler::get().getSuffixes("pdf");
    if(set.contains(info.suffix().toLower()) || set.contains(info.completeSuffix().toLower()))
        return true;

    QMimeDatabase db;
    if(PQCImageHandler::get().getMimetypes("pdf").contains(db.mimeTypeForFile(path).name()))
        return true;
#endif

    return false;

}

bool PQCScriptsImages::isArchive(QString path, bool insideArchive) {

    QFileInfo info(path);
    const QSet<QString> set = PQCImageHandler::get().getSuffixes("libarchive");
    if(set.contains(info.suffix().toLower()) || set.contains(info.completeSuffix().toLower()))
        return true;

    if(!insideArchive) {
        QMimeDatabase db;
        if(PQCImageHandler::get().getMimetypes("libarchive").contains(db.mimeTypeForFile(path).name()))
            return true;
    }

    return false;

}

int PQCScriptsImages::getNumberDocumentPages(QString path) {

    qDebug() << "args: path =" << path;

    if(path.trimmed().isEmpty())
        return 0;

    path = PQCHelper::extractInsidePDFFilename(path);

#ifdef PQMPOPPLER
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(path);
    if(document && !document->isLocked())
        return document->numPages();
#endif
#ifdef PQMQTPDF
    QPdfDocument doc;
    if(doc.load(path) == QPdfDocument::Error::None)
        return doc.pageCount();
#endif
    return 0;

}

void PQCScriptsImages::setSupportsTransparency(QString path, bool alpha) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: alpha =" << alpha;

    QMutexLocker locker(&alphaMutex);
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

        if(PQCSettingsCPP::get().getFiletypesLoadAppleLivePhotos()) {

            QString videopath = QString("%1/%2.mov").arg(info.absolutePath(), info.baseName());
            QFileInfo videoinfo(videopath);
            if(videoinfo.exists())
                return 1;

        }

        if(!PQCSettingsCPP::get().getFiletypesLoadMotionPhotos())
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

    QFileInfo info(path);
    if(!info.exists())
        return "";

    const QString videofilename = PQCConfigFiles::get().CACHE_DIR() % "/motionphotos/" % QString::number(qHash(info.baseName())) % ".mp4";
    if(QFileInfo::exists(videofilename)) {
        return videofilename;
    }

    QFile file(path);
    if(!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Unable to open file for reading";
        return "";
    }

    const qint64 fileSize = file.size();

    if(fileSize < 16) {
        qWarning() << "File too small to contain embedded video";
        return "";
    }

    uchar *data = file.map(0, fileSize);

    if(!data) {
        qWarning() << "Failed to memory-map file";
        return "";
    }

    // some common MP4 tags found in motion photos
    static const QList<QByteArray> validTags = {"mp42", "mp41", "isom", "iso2", "avc1", "M4V "};

    qint64 videoOffset = -1;

    // scan for MP4 ftyp atom
    for(qint64 i = 0; i < fileSize - 12; ++i) {

        // we are checking for:
        // [size:4]["ftyp":4][tag:4]

        // this is much faster than converting the four characters to a single string and comparing that
        if(data[i + 4] == 'f' && data[i + 5] == 't' &&
           data[i + 6] == 'y' && data[i + 7] == 'p') {

            // read atom size (big endian)
            quint32 atomSize = (quint32(data[i]) << 24) | (quint32(data[i + 1]) << 16) |
                               (quint32(data[i + 2]) << 8) | quint32(data[i + 3]);

            // some basic validation
            if(atomSize < 8 || atomSize > (fileSize - i))
                continue;

            QByteArray tag(reinterpret_cast<const char*>(data + i + 8), 4);

            if(!validTags.contains(tag))
                continue;

            videoOffset = i;

            break;
        }
    }

    file.unmap(data);

    if(videoOffset < 0) {
        qWarning() << "no embedded MP4 video found";
        return "";
    }

    // Ensure output directory exists
    QDir dir;
    dir.mkpath(QFileInfo(videofilename).absolutePath());

    if(!file.seek(videoOffset)) {
        qWarning() << "failed to seek to video offset";
        return "";
    }

    QFile outFile(videofilename);

    if(!outFile.open(QIODevice::WriteOnly)) {
        qWarning() << "failed to create output video file:" << videofilename;
        return "";
    }

    // use a buffer of 1MB
    constexpr qint64 bufferSize = 1024 * 1024;

    while(!file.atEnd()) {

        QByteArray chunk = file.read(bufferSize);

        if(chunk.isEmpty() && file.error() != QFile::NoError) {
            qWarning() << "error reading input file";
            outFile.close();
            outFile.remove();
            return "";
        }

        if(outFile.write(chunk) != chunk.size()) {
            qWarning() << "error writing output file";
            outFile.close();
            outFile.remove();
            return "";
        }
    }

    outFile.close();

    qDebug() << "extracted motion video to:" << videofilename;

    return outFile.fileName();

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

        const QString familyName = QString::fromStdString(it_xmp->familyName());
        const QString groupName = QString::fromStdString(it_xmp->groupName());
        const QString tagName = QString::fromStdString(it_xmp->tagName());

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

#ifdef PQMZXINGQT

    QSize origSize;
    QString err = "";
    QImage img = PQCImageHandler::get().getImage(path, QSize(-1,-1), origSize, err);

    // Read from QImage
    const QList<ZXingQt::Barcode> codes = ZXingQt::ReadBarcodes(img);
    for(const auto& barcode : codes) {

        QVariantList vals;
        vals << barcode.text();
        vals << barcode.position().topLeft();
        vals << barcode.position().bottomRight()-barcode.position().topLeft();
        ret << vals;

    }

#elif defined(PQMZXING)

    QSize origSize;
    QString err = "";
    QImage img = PQCImageHandler::get().getImage(path, QSize(-1,-1), origSize, err);

    ZXing::ImageFormat frmt;
    switch (img.format()) {
        case QImage::Format_ARGB32:
        case QImage::Format_RGB32:
#if ZXING_VERSION_MAJOR ==2 && ZXING_VERSION_MINOR <= 2
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
#if ZXING_VERSION_MAJOR ==2 && ZXING_VERSION_MINOR <= 2
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

#if (ZXING_VERSION_MAJOR == 2 && ZXING_VERSION_MINOR <= 1)

    // Read all bar codes
    const auto results = ZXing::ReadBarcodes({img.bits(), img.width(), img.height(), frmt, static_cast<int>(img.bytesPerLine())});

#else

    // Read all bar codes
    auto options = ZXing::ReaderOptions().setMaxNumberOfSymbols(10);
    auto results = ZXing::ReadBarcodes({img.bits(), img.width(), img.height(), frmt, static_cast<int>(img.bytesPerLine())}, options);

#endif

    /******************************/
    // process and store results

    for(const auto& r : results) {

        QVariantList vals;
        vals << QString::fromStdString(r.text());
        vals << QPoint(r.position().topLeft().x, r.position().topLeft().y);
        vals << QPoint(r.position().bottomRight().x-r.position().topLeft().x, r.position().bottomRight().y-r.position().topLeft().y);
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

    const QStringList parts = path.split("::ARC::");
    QString archivefile = parts.at(1);
    QString compressedFilename = parts.at(0);

    QFileInfo info(archivefile);
    const QString suffix = info.suffix().toLower();

#ifndef Q_OS_WIN
    if(PQCSettingsCPP::get().getFiletypesExternalUnrar() && (suffix == "cbr" || suffix == "rar")) {

        qDebug() << "attempting to load archive with unrar";

        // we extract it to a temp location from where we can load it then
        const QString tempdir = PQCConfigFiles::get().CACHE_DIR() + "/clipboard/";

        QDir td;
        if(!td.exists(tempdir))
            td.mkpath(tempdir);

        QProcess p;
        p.start("unrar", QStringList() << "x" << "-y" << archivefile << compressedFilename << tempdir);
        if(p.waitForStarted()) {
            if(p.waitForFinished(15000)) {
                qDebug() << "temporary file:" << tempdir+compressedFilename;
                return tempdir+compressedFilename;
            }
        }

    }
#endif

#ifdef PQMLIBARCHIVE

    qDebug() << "attempting to load archive with libarchive";

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

    // Read file
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archivefile.utf16()), 10240);
#else
    QByteArray tmpPath = QFile::encodeName(archivefile);
    int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        qWarning() << QString("archive_read_open_filename() returned code of %1").arg(r);
        return QString();
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
        // and PhotoQt might crash if not handled properly -> check before converting to QString
        const wchar_t *wpath = archive_entry_pathname_w(entry);
        if(!wpath) continue;
        QString filenameinside = QString::fromWCharArray(wpath);

        // If this is the file we are looking for:
        if(filenameinside == compressedFilename || (compressedFilename.isEmpty() && !QFileInfo(filenameinside).suffix().isEmpty())) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            if(size <= 0) {
                qWarning() << QString("Invalid image size of file in archive: %1").arg(size);
                return QString();
            }

            // Create a buffer of that size to hold the image data
            QByteArray data;
            data.resize(size);

            // And finally read the file into the buffer in chunks
            char* ptr = data.data();
            qint64 total = 0;
            while (total < size) {
                la_ssize_t chunk = archive_read_data(a, ptr + total, size - total);
                if(chunk < 0) {
                    const QString err = QString("Invalid chunk read: %1").arg(archive_error_string(a));
                    qWarning() << err;
                    return err;
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                return QString();
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
                return QString();
            }
            QDataStream out(&file);   // we will serialize the data into the file
            out.writeRawData(data, data.size());
            file.close();

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

    if(!ret.isEmpty())
        qDebug() << "temporary file:" << ret;

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
    const QStringList parts = path.split("::PDF::");
    int page = parts.at(0).toInt();
    QString realFileName = parts.at(1);

    QPdfDocument doc;

    if(doc.load(realFileName) != QPdfDocument::Error::None) {
        qWarning() << "Error occurred loading PDF";
        return "";
    }

    QSizeF _pageSize = (doc.pagePointSize(page)/72.0*qApp->primaryScreen()->physicalDotsPerInch())*(PQCSettingsCPP::get().getFiletypesPDFQuality()/72.0);
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
    const QString tempdir = PQCConfigFiles::get().CACHE_DIR() % "/clipboard/";
    const QString temppath = tempdir % QString::number(page+1) % ".jpg";

    QDir td;
    if(!td.exists(tempdir))
        td.mkpath(tempdir);

    if(img.save(temppath)) {
        return temppath;
    }

#endif
#ifdef PQMPOPPLER

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    const QStringList parts = path.split("::PDF::");
    int page = parts.at(0).toInt();
    QString filename = parts.at(1);

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
    const QString tempdir = PQCConfigFiles::get().CACHE_DIR() % "/clipboard/";
    const QString temppath = tempdir + QString::number(page+1) % ".jpg";

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
    const QString defaultfile = info.absolutePath() % "/" % info.baseName() % "_" % QString::number(frameNumber) % "." % suffix;

    // ask user to confirm target file
    const QString targetfile = PQCScriptsFilesPaths::get().selectFileFromDialog("Save", defaultfile, suffix, true);

    // no file selected/dialog cancelled
    if(targetfile.isEmpty())
        return false;

    // save to new file
    return img.save(targetfile);

}

int PQCScriptsImages::getDocumentPageCount(QString path) {

    qDebug() << "args: path =" << path;

#ifdef PQMQTPDF

    path = PQCHelper::extractInsidePDFFilename(path);

    QPdfDocument doc;

    if(doc.load(path) != QPdfDocument::Error::None) {
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
        const QString thumbcachepath = PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/" % c % "/" % md5 % ".png";
        if(QFileInfo::exists(thumbcachepath))
            QFile::remove(thumbcachepath);
    }

}

double PQCScriptsImages::getPixelDensity(QString modelName) {

#ifndef Q_OS_WIN

    // 2025-01-01: Wayland issue:
    // Fractional scaling factors are currently (Qt 6.8.1) reported as full integers by QScreen::devicePixelRatio()
    // The same issue occurs in wayland-info (from wayland-utils 1.2.0) with the reported scale factor there
    // However, we can try to calculate the right scaling factor from the logical and physical dimensions reported by wayland-info
    // Using the modelId of the current screen we can get the exact factor as floating point.
    // It is HIGHLY RECOMMENDED to enable this part of the code if there is any chance this instance will be run on wayland.

    // If we are on wayland...
    if(qApp->platformName() == "wayland") {

#ifdef PQMWAYLANDSPECIFIC
        const int timeout = 60*1;
#else
        const int timeout = 60*5;
#endif

#ifndef PQMWAYLANDSPECIFIC
        modelName = "_all_";
#endif

        // we cache a once calculated value for 5 or 1 minutes
        if(QDateTime::currentSecsSinceEpoch()-devicePixelRatioCachedWhen < timeout) {
            return devicePixelRatioCached.value(modelName, 1.0).toDouble();
        }

#ifdef PQMWAYLANDSPECIFIC

        devicePixelRatioCached = PQCWayland::getDevicePixelRatio();
        devicePixelRatioCachedWhen = QDateTime::currentSecsSinceEpoch();
        return devicePixelRatioCached.value(modelName, 1.0).toDouble();

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

                devicePixelRatioCached.insert("_all_", useRatio);
                devicePixelRatioCachedWhen = QDateTime::currentSecsSinceEpoch();
                return useRatio;

            // if error occurred, then we effectively disable this feature
            } else {

                devicePixelRatioCached.insert("_all_", 1);
                devicePixelRatioCachedWhen = QDateTime::currentSecsSinceEpoch();
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
    if(val.isEmpty())
        val = PQCImageHandler::get().getDescription(QFileInfo(filename).suffix());

    return val;

}

QString PQCScriptsImages::getMimetypeForFile(QString path) {
    QMimeDatabase db;
    return db.mimeTypeForFile(path).name();
}

void PQCScriptsImages::applyExifOrientation(const QString filename, QImage &img) {

    const int orientation = PQCScriptsMetaData::get().getExifOrientation(filename);

    QTransform transform;

    switch(orientation) {

        case 1:
            // no rotation, no mirror
            break;
        case 2:
            // no rotation, horizontal mirror
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
            img = img.flipped(Qt::Horizontal);
#else
            img = img.mirrored(true, false);
#endif
            break;
        case 3:
            // 180 degree rotation, no mirror
            transform.rotate(180);
            img = img.transformed(transform);
            break;
        case 4:
            // 180 degree rotation, horizontal mirror
            transform.rotate(180);
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
            img = img.flipped(Qt::Horizontal).transformed(transform);
#else
            img = img.mirrored(true, false).transformed(transform);
#endif
            break;
        case 5:
            // 90 degree rotation, horizontal mirror
            transform.rotate(90);
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
            img = img.flipped(Qt::Horizontal).transformed(transform);
#else
            img = img.mirrored(true, false).transformed(transform);
#endif
            break;
        case 6:
            // 90 degree rotation, no mirror
            transform.rotate(90);
            img = img.transformed(transform);
            break;
        case 7:
            // 270 degree rotation, horizontal mirror
            transform.rotate(270);
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
            img = img.flipped(Qt::Horizontal).transformed(transform);
#else
            img = img.mirrored(true, false).transformed(transform);
#endif
            break;
        case 8:
            // 270 degree rotation, no mirror
            transform.rotate(270);
            img = img.transformed(transform);
            break;
        default:
            qWarning() << "Unexpected orientation value received:" << orientation;
            break;

    }

}

bool PQCScriptsImages::canHaveStarRating(const QString path) {

    qDebug() << "args: path =" << path;

#ifdef Q_OS_WIN

    // this can be done if the file is supported by
    // Exiv2 and/or Windows property store
    HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if(SUCCEEDED(hr)) {

        IPropertyStore* store = nullptr;

        hr = SHGetPropertyStoreFromParsingName((LPCWSTR)QDir::toNativeSeparators(path).utf16(),
                                               nullptr, GPS_READWRITE,
                                               IID_PPV_ARGS(&store));

        if(SUCCEEDED(hr)) {
            store->Release();
            CoUninitialize();
            return true;
        }

    }

#ifdef PQMEXIV2

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif

    bool canUseExiv2 = true;

    try {
        image = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        canUseExiv2 = false;
    }

    return canUseExiv2;

#endif

    return false;

#endif

    // on Linux we can always fall back to xattr
    return true;

}

void PQCScriptsImages::setStarRating(const int star, const QString path) {

    qDebug() << "args: star =" << star;
    qDebug() << "args: path =" << path;

    if(star < 0 || star > 5) {
        qWarning() << "Invalid star rating (0 <= star <= 5):" << star;
        return;
    }

    const QList<int> percentageSteps = {0, 1, 25, 50, 75, 99};
    const int percentage = percentageSteps[star];

    // there are a few different places/ways star ratings need to be stored for support across various systems
    // not all of them are stored IN the file and wont travel, but some will

    /******************************************/
    // 1) Store to metadata (exif and xmp)
#ifdef PQMEXIV2

    qDebug() << "Setting star rating with Exiv2...";

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif

    bool haveExiv2 = true;

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

        haveExiv2 = false;
    }

    if(haveExiv2) {

        Exiv2::ExifData exifData;
        try {
            exifData = image->exifData();
            if(star > 0) {
                exifData["Exif.Image.Rating"] = star;
                exifData["Exif.Image.RatingPercent"] = percentage;
            } else {
                auto iter1 = exifData.findKey(Exiv2::ExifKey("Exif.Image.Rating"));
                if(iter1 != exifData.end())
                    exifData.erase(iter1);
                auto iter2 = exifData.findKey(Exiv2::ExifKey("Exif.Image.RatingPercent"));
                if(iter2 != exifData.end())
                    exifData.erase(iter2);
            }
            image->setExifData(exifData);
        } catch(Exiv2::Error &e) {
            qDebug() << "ERROR: Unable to manipulate exif metadata:" << e.what();
        }

        Exiv2::XmpData xmpData;
        try {
            xmpData = image->xmpData();
            if(star > 0) {
                xmpData["Xmp.xmp.Rating"] = star;
                xmpData["Xmp.MicrosoftPhoto.Rating"] = percentage;
            } else {
                auto iter1 = xmpData.findKey(Exiv2::XmpKey("Xmp.xmp.Rating"));
                if(iter1 != xmpData.end())
                    xmpData.erase(iter1);
                auto iter2 = xmpData.findKey(Exiv2::XmpKey("Xmp.MicrosoftPhoto.Rating"));
                if(iter2 != xmpData.end())
                    xmpData.erase(iter2);
            }
            image->setXmpData(xmpData);
        } catch(Exiv2::Error &e) {
            qDebug() << "ERROR: Unable to manipulate xmp metadata:" << e.what();
        }

    }

#endif

    /******************************************/
    // 2) Store xattr rating (used, e.g., by KDE)
#ifdef Q_OS_UNIX

    qDebug() << "Setting star rating for KDE...";

    if(star > 0) {

        const QByteArray attr_path = path.toUtf8();
        const QByteArray attr_value = QByteArray::number(star*2);
        const QByteArray attr_name = "user.baloo.rating";

        // setting an attribute
        int ret = setxattr(attr_path, attr_name, attr_value, strlen(attr_value), 0);
        if(ret == -1)
            qWarning() << "ERROR setting star rating with setxattr(), return value:" << ret;

    } else {

        const QByteArray attr_path = path.toUtf8();
        const char* attr_name = "user.baloo.rating";

        int ret = removexattr(attr_path, attr_name);
        if(ret != 0)
            qWarning() << "ERROR removing star rating with removexattr, return value:" << ret;

    }

#endif

    /******************************************/
    // 3) Store WINDOWS rating
#ifdef Q_OS_WIN

    HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if(FAILED(hr)) {
        qWarning() << "CoInitialize failed.";
    } else {

        IPropertyStore* store = nullptr;

        hr = SHGetPropertyStoreFromParsingName((LPCWSTR)QDir::toNativeSeparators(path).utf16(),
                                               nullptr, GPS_READWRITE,
                                               IID_PPV_ARGS(&store));

        if(FAILED(hr)) {
            qWarning() << "SHGetPropertyStoreFromParsingName failed";
            CoUninitialize();
        } else {

            PROPVARIANT var;
            InitPropVariantFromUInt32(percentage, &var);

            hr = store->SetValue(PKEY_Rating, var);

            if(SUCCEEDED(hr)) {
                qDebug() << "SetValue succeeded";
                hr = store->Commit();
            } else
                qWarning() << "SetValue failed";

            PropVariantClear(&var);
            store->Release();

            CoUninitialize();

            if(!SUCCEEDED(hr))
                qWarning() << "Failure when finishing up storing rating value";

        }

    }

#endif

}

int PQCScriptsImages::getStarRating(const QString path) {

    qDebug() << "args: path =" << path;

    int kdeStarRating = -1;
    int exifStarRating = -1;

    // 1) check system specific data first: xattr (KDE/...)
#ifdef Q_OS_UNIX

    qDebug() << "Getting star rating from KDE...";

    const QByteArray attr_path = path.toUtf8();
    const QByteArray attr_name = "user.baloo.rating";

    // if something went wrong we don't continue with this section
    bool cont = true;

    // FIRST get size of value
    ssize_t size = getxattr(attr_path, attr_name, NULL, 0);
    if(size == -1) {
        qDebug() << "KDE star rating not found.";
        cont = false;
    } else if(size == 0) {
        qDebug() << "KDE star rating value empty.";
        cont = false;
    }

    char *value;
    if(cont) {

        // SECOND allocate a buffer based on the size found
        value = (char*)malloc(size);
        if(value == NULL) {
            qWarning() << "FAILED to allocate memory...";
            cont = false;
        }

    }

    if(cont) {

        // THIRD call getxattr again to actually retrieve the data
        size = getxattr(attr_path, attr_name, value, size);

        if(size == -1) {
            qWarning() << "FAILED to retrieve data.";
            free(value);
        } else {
            // KDE supports half-step ratings
            kdeStarRating = atoi(value)/2;
            if(kdeStarRating < 0 || kdeStarRating > 5)
                kdeStarRating = -1;
        }

    }

    if(kdeStarRating > -1) {
        // if we are actually running KDE/Plasma, then we treat this as top authority and stop here
        QList<QByteArray> wm = QByteArray(getenv("XDG_CURRENT_DESKTOP")).toLower().split(',');
        if(wm.contains("plasma") || wm.contains("kde")) {
            qDebug() << "Found KDE star rating, returning that.";
            return kdeStarRating;
        }
    }

#endif

    // look in the windows property store for a rating
#ifdef Q_OS_WIN

    HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if(FAILED(hr)) {
        qWarning() << "CoInitialize failed.";
    } else {

        IPropertyStore* store = nullptr;

        int winRating = -1;

        hr = SHGetPropertyStoreFromParsingName((LPCWSTR)QDir::toNativeSeparators(path).utf16(),
                                               nullptr, GPS_READWRITE,
                                               IID_PPV_ARGS(&store));

        // this fails, for example, for unsupported file types
        if(FAILED(hr)) {
            qDebug() << "SHGetPropertyStoreFromParsingName failed";
            CoUninitialize();
        } else {

            PROPVARIANT var;
            PropVariantInit(&var);

            hr = store->GetValue(PKEY_Rating, &var);

            if(SUCCEEDED(hr)) {

                // PKEY_Rating is stored as UInt32
                if(var.vt == VT_UI4)
                    winRating = var.ulVal;
                else if(var.vt != VT_EMPTY)
                    qWarning() << "Unexpected variant type:" << var.vt;

            } else
                qWarning() << "GetValue failed";

            PropVariantClear(&var);
            store->Release();

            CoUninitialize();

            if(winRating != -1) {
                qDebug() << "Found Window file rating of:" << winRating;
                return winRating;
            }

        }

    }

#endif

#ifdef PQMEXIV2

    qDebug() << "Getting star rating with Exiv2...";

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif

    bool haveExiv2 = true;

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

        haveExiv2 = false;
    }

    if(haveExiv2) {

        const QList<int> percentageSteps = {0, 1, 25, 50, 75, 99};

        Exiv2::ExifData exifData;
        try {
            exifData = image->exifData();
            auto iter1 = exifData.findKey(Exiv2::ExifKey("Exif.Image.Rating"));
            if(iter1 != exifData.end()) {
                const int star = QString::fromStdString(iter1->value().toString()).toInt();
                if(star >= 0 && star <= 5)
                    exifStarRating = star;
            }
            if(exifStarRating == -1) {
                auto iter2 = exifData.findKey(Exiv2::ExifKey("Exif.Image.RatingPercent"));
                if(iter2 != exifData.end()) {
                    const int star = QString::fromStdString(iter2->value().toString()).toInt();
                    if(star >= 0 && star <= 99) {
                        for(int i = 0; i < percentageSteps.length(); ++i)
                            if(star <= percentageSteps[i])
                                exifStarRating = i;
                    }
                }
            }
        } catch(Exiv2::Error &e) {
            qDebug() << "ERROR: Unable to read exif metadata:" << e.what();
        }

        if(exifStarRating == -1) {

            Exiv2::XmpData xmpData;
            try {
                xmpData = image->xmpData();
                auto iter1 = xmpData.findKey(Exiv2::XmpKey("Xmp.xmp.Rating"));
                if(iter1 != xmpData.end()) {
                    const int star = QString::fromStdString(iter1->value().toString()).toInt();
                    if(star >= 0 && star <= 5)
                        exifStarRating = star;
                }
                if(exifStarRating == -1) {
                    auto iter2 = xmpData.findKey(Exiv2::XmpKey("Xmp.MicrosoftPhoto.Rating"));
                    if(iter2 != xmpData.end()) {
                        const int star = QString::fromStdString(iter2->value().toString()).toInt();
                        if(star >= 0 && star <= 99) {
                            for(int i = 0; i < percentageSteps.length(); ++i)
                                if(star <= percentageSteps[i])
                                    exifStarRating = i;
                        }
                    }
                }
            } catch(Exiv2::Error &e) {
                qDebug() << "ERROR: Unable to read xmp metadata:" << e.what();
            }

        }

    }

#endif

    if(exifStarRating != -1)
        return exifStarRating;
    else if(kdeStarRating != -1)
        return kdeStarRating;

    return 0;
}

QString PQCScriptsImages::prepareSphereFile(QString path) {

    qDebug() << "args: path " << path;

#if defined(PQMEXIV2) && (EXIV2_TEST_VERSION(0, 28, 0) || defined(PQMEXIV2_ENABLE_BMFF))

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image;
#else
    Exiv2::Image::AutoPtr image;
#endif

    try {
        image = Exiv2::ImageFactory::open(path.toStdString());
        image->readMetadata();
    } catch (Exiv2::Error& e) {
        // An error code of kerFileContainsUnknownImageType (older version: 11) means unknown file type \
        // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
        if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
        if(e.code() != 11)
#endif
            qWarning() << "ERROR reading exiv data (caught exception):" << e.what();
        else
            qDebug() << "ERROR reading exiv data (caught exception):" << e.what();

        return path;
    }

    Exiv2::XmpData xmpData;
    try {
        xmpData = image->xmpData();
    } catch(Exiv2::Error &e) {
        qDebug() << "ERROR: Unable to read xmp metadata:" << e.what();
        return path;
    }

    int croppedW = 0, croppedH = 0;
    int fullW = 0, fullH = 0;

    for(Exiv2::XmpData::const_iterator it_xmp = xmpData.begin(); it_xmp != xmpData.end(); ++it_xmp) {

        QString familyName = QString::fromStdString(it_xmp->familyName());
        QString groupName = QString::fromStdString(it_xmp->groupName());
        QString tagName = QString::fromStdString(it_xmp->tagName());

        // check for actual and full dimensions of sphere
        if(familyName == "Xmp" && groupName == "GPano") {
            if(tagName == "CroppedAreaImageHeightPixels")
                croppedH = QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt();
            else if(tagName == "CroppedAreaImageWidthPixels")
                croppedW = QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt();
            else if(tagName == "FullPanoHeightPixels")
                fullH = QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt();
            else if(tagName == "FullPanoWidthPixels")
                fullW = QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt();
        }

    }

    // we add a small margin to allow for minor inaccuracies in creating the image
    // this will not affect the visible part of the image
    if(croppedW > 0 && croppedH > 0 && fullW > 0 && fullH > 0 && (croppedW < fullW-10 || croppedH < fullH-10)) {

        // image is cropped -> process

        QImage partialImage = QImage(path);

        QImage fullimage(fullW, fullH, QImage::Format_RGB32);
        fullimage.fill(Qt::transparent);
        QPainter painter(&fullimage);
        painter.drawImage((fullW-croppedW)/2, (fullH-croppedH)/2, partialImage);
        painter.end();

        const QString dir = PQCConfigFiles::get().CACHE_DIR() % "/sphere";
        if(QDir().mkpath(dir)) {
            const QString newPath = dir % "/" % QFileInfo(path).fileName();
            if(QFile(newPath).exists()) QFile::remove(newPath);
            fullimage.save(newPath);
            return newPath;
        }

        return path;

    }

#endif

    return path;

}
