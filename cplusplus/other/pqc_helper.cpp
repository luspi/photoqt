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
