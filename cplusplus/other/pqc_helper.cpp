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
#include <pqc_helper.h>
#include <pqc_configfiles.h>
#include <QSet>
#include <QtSql/QSqlDatabase>
#include <QDirIterator>

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

// adapted from:
// https://codebrowser.dev/qt6/qtbase/src/corelib/text/qstringlist.cpp.html#_ZL15accumulatedSizeRK5QListI7QStringEx
qsizetype PQCHelper::setAccumulatedSize(QSet<QString> set, qsizetype seplen) {

    qsizetype result = 0;
    if(!set.isEmpty()) {
        for(const QString &e : set)
            result += e.size() + seplen;
        result -= seplen;
    }
    return result;

}
qsizetype PQCHelper::setAccumulatedSize(QSet<int> set, qsizetype seplen) {

    qsizetype result = 0;
    if(!set.isEmpty()) {
        for(const int &e : set)
            result += static_cast<int>(std::log10(e)) + seplen;
        result -= seplen;
    }
    return result;

}

// adapted from:
// https://codebrowser.dev/qt6/qtbase/src/corelib/text/qstringlist.cpp.html#_ZN9QtPrivate16QStringList_joinERK5QListI7QStringE13QLatin1String
QString PQCHelper::setJoin(QSet<QString> set, QString sep) {

    QString result;
    if(!set.isEmpty()) {
        result.reserve(setAccumulatedSize(set, sep.size()));
        const auto end = set.end();
        auto it = set.begin();
        result += *it;
        while(++it != end) {
            result += sep;
            result += *it;
        }
    }
    return result;

}

QString PQCHelper::setJoin(QSet<int> set, QString sep) {

    QString result;
    if(!set.isEmpty()) {
        result.reserve(setAccumulatedSize(set, sep.size()));
        const auto end = set.end();
        auto it = set.begin();
        result += QString::number(*it);
        while(++it != end) {
            result += sep;
            result += QString::number(*it);
        }
    }
    return result;

}

QString PQCHelper::extractInsideFilename(QString path) {

    const QStringList lst = {"::PDF::", "::ARC::"};

    for(const QString &str : lst) {
        const int idx = path.indexOf(str);
        if(idx != -1)
            return path.mid(idx + str.length());
    }

    return path;

}

QString PQCHelper::extractInsidePDFFilename(QString path) {
    const int idx = path.indexOf("::PDF::");
    if(idx != -1)
        return path.mid(idx + 7);
    return path;
}

QString PQCHelper::extractInsideARCFilename(QString path) {
    const int idx = path.indexOf("::ARC::");
    if(idx != -1)
        return path.mid(idx + 7);
    return path;
}

int PQCHelper::extractOutsidePDFNumber(QString path) {
    int idx = path.indexOf("::PDF::");
    if(idx != -1)
        return path.mid(0, idx).toInt();
    return 0;
}

QString PQCHelper::extractOutsideARCFilename(QString path) {
    int idx = path.indexOf("::ARC::");
    if(idx != -1)
        return path.mid(0, idx);
    return path;
}

bool PQCHelper::zipDirectory(const QString sourceDir, const QString archiveFile) {

#ifdef PQMLIBARCHIVE

    struct archive* a = archive_write_new();

    archive_write_set_format_pax_restricted(a);
    archive_write_add_filter_gzip(a);

    QByteArray archivePath = QFile::encodeName(archiveFile);

    if(archive_write_open_filename(a, archivePath.constData()) != ARCHIVE_OK) {
        qWarning() << QString("ERROR creating archive of directory %1:").arg(sourceDir) << archive_error_string(a);
        archive_write_free(a);
        return false;
    }

    QDir baseDir(sourceDir);

    QDirIterator it(sourceDir, QDir::Files|QDir::Dirs|QDir::NoDotAndDotDot, QDirIterator::Subdirectories);

    constexpr qsizetype BufferSize = 65536;// = 64*1024
    QByteArray buffer(BufferSize, Qt::Uninitialized);

    while(it.hasNext()) {

        const QString fullPath = it.next();
        QFileInfo info(fullPath);

        const QString relativePath = baseDir.relativeFilePath(fullPath);
        const QByteArray entryName = QFile::encodeName(relativePath);

        struct archive_entry *entry = archive_entry_new();
        archive_entry_set_pathname(entry, entryName.constData());

        QFile file(fullPath);
        if(!file.open(QIODevice::ReadOnly)) {
            qWarning() << "Failed to open:" << fullPath;
            archive_entry_free(entry);
            continue;
        }

        archive_entry_set_filetype(entry, AE_IFREG);
        archive_entry_set_perm(entry, 0644);
        archive_entry_set_size(entry, info.size());

        if(archive_write_header(a, entry) != ARCHIVE_OK) {
            qWarning() << "Failed to write header info:" << archive_error_string(a);
            archive_entry_free(entry);
            file.close();
            continue;
        }

        while(!file.atEnd()) {

            qint64 bytesRead = file.read(buffer.data(), buffer.size());
            if(bytesRead < 0) {
                qWarning() << "Failed reading data:" << file.errorString();
                break;
            }

            const char* ptr = buffer.constData();
            qint64 remaining = bytesRead;

            while(remaining > 0) {

                la_ssize_t written = archive_write_data(a, ptr, remaining);

                if(written < 0) {
                    qWarning() << "Error writing file:" << archive_error_string(a);
                    break;
                }

                ptr += written;
                remaining -= written;
            }
        }

        file.close();
        archive_entry_free(entry);
    }

    archive_write_close(a);
    archive_write_free(a);

    return true;

#endif

    return false;

}

bool PQCHelper::unzipDirectory(const QString archiveFile, const QString targetDir) {

#ifdef PQMLIBARCHIVE
    struct archive* a = archive_read_new();

    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

#ifdef Q_OS_WIN
    if(archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archiveFile.utf16()), 10240) != ARCHIVE_OK) {
        qWarning() << QString("ERROR opening archive %1:").arg(archiveFile) << archive_error_string(a);
#else
    QByteArray tmpPath = QFile::encodeName(archiveFile);
    if(archive_read_open_filename(a, tmpPath.constData(), 10240) != ARCHIVE_OK) {
        qWarning() << QString("ERROR opening archive %1:").arg(tmpPath) << archive_error_string(a);
#endif
        archive_read_free(a);
        return false;
    }

    QDir().mkpath(targetDir);

    // prepare data structures
    struct archive_entry *entry;
    QByteArray buffer(65536, Qt::Uninitialized);

    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        // Also, if the archives is malformed or there is an encoding issue then it is possible that this may return a nullptr
        // and PhotoQt might crash if not handled properly -> check before converting to QString
        const wchar_t *wpath = archive_entry_pathname_w(entry);
        if(!wpath) continue;
        const QString filenameinside = QString::fromWCharArray(wpath);

        // Find out the size of the data
        int64_t size = archive_entry_size(entry);

        // where to write it to
        const QString outputPath = QDir(targetDir).filePath(filenameinside);

        // we use a file info as the entry might be in a subfolder and thus the path might be different to targetDir
        QFileInfo info(outputPath);
        QDir().mkpath(info.path());

        // we check if it is a directory entry, in that case we simply create the full path
#ifdef Q_OS_WIN
        ushort filetype = archive_entry_filetype(entry);
#else
        mode_t filetype = archive_entry_filetype(entry);
#endif
        if(filetype == AE_IFDIR) {
            QDir().mkpath(outputPath);
            continue;
        }

        // prepare target file (if possible)
        QFile outFile(outputPath);
        if(!outFile.open(QIODevice::WriteOnly)) {
            qWarning() << "Failed to create file:" << outputPath;
            archive_read_data_skip(a);
            continue;
        }

        char* ptr = buffer.data();
        qint64 total = 0;
        while(total < size) {
            la_ssize_t chunk = archive_read_data(a, ptr + total, size - total);
            qint64 written = outFile.write(buffer.constData(), chunk);
            if(written != chunk) {
                qWarning() << "Failed writing file:" << outputPath;
                break;
            }
        }

        if(total < 0) {
            qWarning() << "Error reading archive data:" << archive_error_string(a);
        }

        outFile.close();
    }

    archive_read_close(a);
    archive_read_free(a);

    return true;
#endif

    return false;

}
