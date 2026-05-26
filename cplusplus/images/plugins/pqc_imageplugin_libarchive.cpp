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

#include <pqc_imageplugin_libarchive.h>
#include <pqc_settingscpp.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_imagehandler.h>

#include <QFile>
#include <QtDebug>
#include <QTemporaryFile>
#include <QProcess>

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

PQCImagePluginLibarchive::PQCImagePluginLibarchive(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginLibarchive::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const bool PQCImagePluginLibarchive::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const QSet<QString> PQCImagePluginLibarchive::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginLibarchive::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginLibarchive::loadSize(QString path) {

#ifdef PQMLIBARCHIVE

    // filter out name of archivefile and of compressed file inside
    QString archivefile = path;
    QString compressedFilename = "";
    const int idx = archivefile.indexOf("::ARC::");
    if(idx > -1) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = archivefile.mid(idx+7);
        compressedFilename = archivefile.mid(0,idx);
    } else {
        QStringList cont = PQCScriptsImages::get().listArchiveContentWithoutThread(archivefile);
        if(cont.length() == 0) {
            qWarning() << "Unable to list contents of archive file...";
            return QSize();
        }
        compressedFilename = cont.at(0);
    }

    if(!QFileInfo::exists(archivefile)) {
        qWarning() << "File doesn't seem to exist...";
        return QSize();
    }

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
        return QSize();
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
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
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
                    qWarning() << QString("Invalid chunk read: %1").arg(archive_error_string(a));
                    archive_read_close(a);
                    archive_read_free(a);
                    return QSize();
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                qWarning() << QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            // and finish off by turning it into an image

            // we use a temporary file that is automatically removed afterwards
            QTemporaryFile tempFile;
            tempFile.setAutoRemove(true);

            // write buffer to file
            if(!tempFile.open()) {
                qWarning() << "Unable to load archive file to temporary file.";
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            if(tempFile.write(data) != data.size()) {
                qWarning() << "Failed to write image to temporary file.";
                archive_read_close(a);
                archive_read_free(a);
                return QSize();
            }

            tempFile.flush();

            QSize origSize = PQCImageHandler::get().getSize(tempFile.fileName());

            r = archive_read_free(a);
            if(r != ARCHIVE_OK)
                qWarning() << "PQLoadImage::Archive::load(): ERROR: archive_read_free() returned code of" << r;

            archive_read_close(a);
            archive_read_free(a);
            return origSize;
        }

    }

    archive_read_close(a);
    archive_read_free(a);

#endif

    return QSize();

}

const QImage PQCImagePluginLibarchive::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

    QString errormsg = "";

#ifdef PQMLIBARCHIVE

    // filter out name of archivefile and of compressed file inside
    QString archivefile = path;
    QString compressedFilename = "";
    if(archivefile.contains("::ARC::")) {
        QStringList parts = archivefile.split("::ARC::");
        archivefile = parts.at(1);
        compressedFilename = parts.at(0);
    } else {
        QStringList cont = PQCScriptsImages::get().listArchiveContentWithoutThread(archivefile);
        if(cont.length() == 0) {
            const QString msg = "Unable to list contents of archive file...";
            error += msg % "\n";
            qWarning() << msg;
            return QImage();
        }
        compressedFilename = cont.at(0);
    }

    if(!QFileInfo::exists(archivefile)) {
        const QString msg = "File doesn't seem to exist...";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    QFileInfo info(archivefile);
    const QString suffix = info.suffix().toLower();

#ifndef Q_OS_WIN
    if(PQCSettingsCPP::get().getFiletypesExternalUnrar() && (suffix == "cbr" || suffix == "rar")) {

        qDebug() << "trying to load archive with unrar";

        const QString tmpDir = PQCConfigFiles::get().CACHE_DIR()+"/unrar/";

        QDir dir;
        if(dir.mkpath(tmpDir)) {

            QProcess p;
            p.setProcessChannelMode(QProcess::MergedChannels);
            p.start("unrar", QStringList() << "x" << "-y" << archivefile << compressedFilename << tmpDir);

            if(p.waitForStarted()) {

                p.waitForFinished(15000);

                QImage img = PQCImageHandler::get().getImage(tmpDir + compressedFilename, QSize(-1,-1), origSize, error);
                QDir dir(tmpDir);
                dir.removeRecursively();

                // cache image before potentially scaling it
                if(!img.isNull()) {
                    PQCScriptsColorProfiles::get().applyColorProfile(path, img);
                    PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
                }

                // Scale image if necessary
                if(!requestedSize.isEmpty()) {

                    QSize finalSize = origSize;

                    if(finalSize.width() > requestedSize.width() || finalSize.height() > requestedSize.height())
                        finalSize = finalSize.scaled(requestedSize, Qt::KeepAspectRatio);

                    return img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

                }

                return img;

            } else
                qWarning() << "Failed to run unrar, trying with libarchive";

        } else
            qWarning() << "unable to create temporary folder for unrar target:" << tmpDir;

    }
#endif

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

    // Read file
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archivefile.utf16()), 10240);
#else
    QByteArray tmpPath = QFile::encodeName(info.absoluteFilePath());
    int r = archive_read_open_filename(a, tmpPath.constData(), 10240);
#endif

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        const QString msg = QString("archive_read_open_filename() returned code of %1").arg(r);
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    QImage img;

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
                const QString msg = QString("Invalid image size of file in archive: %1").arg(size);
                error += msg % "\n";
                qWarning() << msg;
                return QImage();
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
                    const QString msg = QString("Invalid chunk read: %1").arg(archive_error_string(a));
                    error += msg % "\n";
                    qWarning() << msg;
                    return QImage();
                }

                if (chunk == 0) {
                    break;
                }

                total += chunk;
            }

            if(total != size) {
                const QString msg = QString("Failed to read image data, read size (%1) doesn't match expected size (%2)...").arg(total).arg(size);
                error += msg % "\n";
                qWarning() << msg;
                return QImage();
            }

            // and finish off by turning it into an image

            // we use a temporary file that is automatically removed afterwards
            QTemporaryFile tempFile;
            tempFile.setAutoRemove(true);

            // write buffer to file
            if(!tempFile.open()) {
                const QString msg = "Unable to load archive file to temporary file.";
                error += msg % "\n";
                qWarning() << msg;
                return QImage();
            }

            if(tempFile.write(data) != data.size()) {
                const QString msg = "Failed to write image to temporary file.";
                error += msg % "\n";
                qWarning() << msg;
                return QImage();
            }

            tempFile.flush();

            // attempt to load file
            img = PQCImageHandler::get().getImage(tempFile.fileName(), QSize(-1,-1), origSize, error);
            if(img.isNull())
                qWarning() << "Failed to load image inside archive:" << filenameinside;

            // Nothing more to do except some cleaning up below
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

    // cache image before potentially scaling it
    if(!img.isNull()) {

        if(PQCSettingsCPP::get().getMetadataAutoRotation()) {
            // apply transformations if any
            PQCScriptsImages::get().applyExifOrientation(path, img);
        }

        PQCScriptsColorProfiles::get().applyColorProfile(path, img);
        PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
    }

    // Scale image if necessary
    if(!requestedSize.isEmpty()) {
        img = img.scaled(origSize.scaled(requestedSize, Qt::KeepAspectRatio),
                         Qt::IgnoreAspectRatio,
                         (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
    }

    return img;

#endif

    return QImage();

}

void PQCImagePluginLibarchive::setEnabled(QString description, bool enabled) {

}

/***********************************************/

void PQCImagePluginLibarchive::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/libarchive_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
    } else {
        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();
    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"cb7", "cbr", "cbt", "cbz", "rar", "tar", "7z", "zip", "tar.gz",
                     "taz", "tgz", "tar.xz", "txz", "tar.bz2", "tb2", "tbz", "tbz2",
                     "tz2", "tar.zst", "tzst", "tar.lz", "tar.lzma", "tlz", "tar.lzo",
                     "tar.z", "tz"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"cb7",      "Comic book archive"},
        {"cbr",      "Comic book archive"},
        {"cbt",      "Comic book archive"},
        {"cbz",      "Comic book archive"},
        {"rar",      "RAR file format"},
        {"tar",      "TAR file format"},
        {"7z",       "7z file format"},
        {"zip",      "ZIP file format"},
        {"tar.gz",   "TAR file format (GZIP)"},
        {"taz",      "TAR file format (GZIP)"},
        {"tgz",      "TAR file format (GZIP)"},
        {"tar.xz",   "TAR file format (XZ)"},
        {"txz",      "TAR file format (XZ)"},
        {"tar.bz2",  "TAR file format (BZIP2)"},
        {"tb2",      "TAR file format (BZIP2)"},
        {"tbz",      "TAR file format (BZIP2)"},
        {"tbz2",     "TAR file format (BZIP2)"},
        {"tz2",      "TAR file format (BZIP2)"},
        {"tar.zst",  "TAR file format (ZSTD)"},
        {"tzst",     "TAR file format (ZSTD)"},
        {"tar.lz",   "TAR file format (LZIP)"},
        {"tar.lzma", "TAR file format (LZMA)"},
        {"tlz",      "TAR file format (LZMA)"},
        {"tar.lzo",  "TAR file format (LZOP)"},
        {"tar.z",    "TAR file format (COMPRESS)"},
        {"tz",       "TAR file format (COMPRESS)"}
    };

    // no mimetypes
    mimetype2description.clear();

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    // no mimetypes here currently

    Q_EMIT formatsUpdated();

}

void PQCImagePluginLibarchive::saveFormats() {

    // TODO

}
