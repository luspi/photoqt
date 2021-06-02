/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#include "handlingfiledir.h"

QString PQHandlingFileDir::cleanPath(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::cleanPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

#ifdef Q_OS_WIN
    if(path.startsWith("file:///"))
        path = path.remove(0, 8);
    if(path.startsWith("file://"))
        path = path.remove(0, 7);
    if(path.startsWith("file:/"))
        path = path.remove(0, 6);
#else
    if(path.startsWith("file:///"))
        path = path.remove(0, 7);
    if(path.startsWith("file://"))
        path = path.remove(0, 6);
#endif

    return QDir::cleanPath(path);

}

QString PQHandlingFileDir::copyFile(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::copyFile()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QString ending = QFileInfo(filename).suffix();

    //: Title of filedialog to select new filename/location to copy file to.
    QString newfilename = QFileDialog::getSaveFileName(0, "Where to copy the file to", filename, QString("*.%1 (*.%2)").arg(ending).arg(ending));

    if(newfilename.trimmed() == "")
        return "";

    QFile file(filename);
    if(!file.copy(newfilename)) {
        LOG << CURDATE << "PQHandlingFileDir::copyFile(): ERROR: The file could not be copied to its new location." << NL;
        return "";
    }

    return newfilename;

}

bool PQHandlingFileDir::deleteFile(QString filename, bool permanent) {

    DBG << CURDATE << "PQHandlingFileDir::deleteFile()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** permanent = " << permanent << NL;

#ifndef Q_OS_WIN
    if(permanent) {
#endif

        QFile file(filename);
        return file.remove();

#ifndef Q_OS_WIN
    } else {

        // The file to delete
        QFile file(filename);

        // Of course we only proceed if the file actually exists
        if(file.exists()) {

            // Create the meta .trashinfo file
            QString info = "[Trash Info]\n";
            info += "Path=" + QUrl(filename).toEncoded() + "\n";
            info += "DeletionDate=" + QDateTime::currentDateTime().toString("yyyy-MM-ddThh:mm:ss");

            // The base patzh for the Trah (files on external devices  use the external device for Trash)
            QString baseTrash = "";

            // If file lies in the home directory
            if(QFileInfo(filename).absoluteFilePath().startsWith(QDir::homePath())) {

                // Set the base path and make sure all the dirs exist
                baseTrash = ConfigFiles::GENERIC_DATA_DIR() + "/Trash/";

                QDir dir;
                dir.setPath(baseTrash);
                if(!dir.exists()) {
                    if(!dir.mkpath(baseTrash)) {
                        LOG << "PQHandlingFileDir::deleteFile(): ERROR: mkdir(baseTrash) failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "files");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "files")) {
                        LOG << "PQHandlingFileDir::deleteFile(): ERROR: mkdir(files) failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "info");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "info")) {
                        LOG << "PQHandlingFileDir::deleteFile(): ERROR: mkdir(info) failed!";
                        return false;
                    }
                }
            } else {
                // Set the base path ...
                for(QStorageInfo &storage : QStorageInfo::mountedVolumes()) {
                    if(!storage.isReadOnly() && storage.isValid() && filename.startsWith(storage.rootPath()) &&
                       baseTrash.length() < storage.rootPath().length()) {
                        baseTrash = storage.rootPath();
                    }
                }
                baseTrash += "/" + QString("/.Trash-%1/").arg(getuid());
                // ... and make sure all the dirs exist
                QDir dir;
                dir.setPath(baseTrash);
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash)) {
                        LOG << "PQHandlingFileDir::deleteFile(): ERROR: mkdir(baseTrash) failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "files");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "files")) {
                        LOG << "PQHandlingFileDir::deleteFile(): ERROR: mkdir(files) failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "info");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "info")) {
                        LOG << "PQHandlingFileDir::deleteFile(): ERROR: mkdir(info) failed!";
                        return false;
                    }
                }

            }

            // that's the new trash file
            QString trashFile = baseTrash + "files/" + QUrl::toPercentEncoding(QFileInfo(file).fileName(),""," ");
            QString backupTrashFile = trashFile;

            // If there exists already a file with that name, we simply append the next higher number (sarting at 1)
            QFile ensure(trashFile);
            int j = 1;
            while(ensure.exists()) {
                trashFile = backupTrashFile + QString(" (%1)").arg(j++);
                ensure.setFileName(trashFile);
            }

            // Copy the file to the Trash
            if(file.copy(trashFile)) {

                // And remove the old file
                if(!file.remove()) {
                    LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: Old file couldn't be removed!" << NL;
                    return false;
                }

                // Write the .trashinfo file
                QFile i(baseTrash + "info/" + QFileInfo(trashFile).fileName() + ".trashinfo");
                if(i.open(QIODevice::WriteOnly)) {
                    QTextStream out(&i);
                    out << info;
                    i.close();
                } else {
                    LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: *.trashinfo file couldn't be created!" << NL;
                    return false;
                }

            } else {
                LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: File couldn't be deleted (moving file failed)" << NL;
                return false;
            }

        } else {
            LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: File '" << filename.toStdString() << "' doesn't exist...?" << NL;
            return false;
        }

    }

    return true;

#endif

}

bool PQHandlingFileDir::doesItExist(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::doesItExist()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QFile file(path);
    return file.exists();

}

QString PQHandlingFileDir::getBaseName(QString path, bool lowerCase) {

    DBG << CURDATE << "PQHandlingFileDir::getBaseName()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** lowerCase = " << lowerCase << NL;

    if(lowerCase)
        return QFileInfo(path).baseName().toLower();
    return QFileInfo(path).baseName();

}

QString PQHandlingFileDir::getDirectory(QString path, bool lowerCase) {

    DBG << CURDATE << "PQHandlingFileDir::getDirectory()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** lowerCase = " << lowerCase << NL;

    if(lowerCase)
        return QFileInfo(path).absolutePath().toLower();
    return QFileInfo(path).absolutePath();

}

QString PQHandlingFileDir::getFileNameFromFullPath(QString path, bool onlyExtraInfo) {

    DBG << CURDATE << "PQHandlingFileDir::getFileNameFromFullPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** onlyExtraInfo = " << onlyExtraInfo << NL;

    QString ret = QFileInfo(path).fileName();
    if(onlyExtraInfo) {
        if(path.contains("::PQT::"))
            ret = QString("Page %1").arg(path.split("::PQT::").at(0).toInt()+1);
        if(path.contains("::ARC::"))
            ret = path.split("::ARC::").at(0);
    }
    return ret;
}

QString PQHandlingFileDir::getFilePathFromFullPath(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::getFilePathFromFullPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QString ret = QFileInfo(path).fileName();
    if(path.contains("::PQT::"))
        path = path.split("::PQT::").at(1);
    if(path.contains("::ARC::"))
        path = path.split("::ARC::").at(1);

    return QFileInfo(path).absolutePath();

}

qint64 PQHandlingFileDir::getFileSize(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::getFileSize()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QFileInfo(path).size();

}

QString PQHandlingFileDir::getFileType(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::getFileType()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return db.mimeTypeForFile(path).name();

}

QDateTime PQHandlingFileDir::getFileModified(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::getFileModified()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QFileInfo(path).lastModified();

}

QString PQHandlingFileDir::getHomeDir() {

    DBG << CURDATE << "PQHandlingFileDir::getHomeDir()" << NL;

    return QDir::homePath();

}

QString PQHandlingFileDir::getSuffix(QString path, bool lowerCase) {

    DBG << CURDATE << "PQHandlingFileDir::getSuffix()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** lowerCase = " << lowerCase << NL;

    if(lowerCase)
        return QFileInfo(path).suffix().toLower();
    return QFileInfo(path).suffix();

}

QString PQHandlingFileDir::getTempDir() {

    DBG << CURDATE << "PQHandlingFileDir::getTempDir()" << NL;

    return QDir::tempPath();

}

bool PQHandlingFileDir::isDir(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::isDir()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QFileInfo(path).isDir();

}

bool PQHandlingFileDir::isRoot(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::isRoot()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QDir dir(path);
    dir.setPath(dir.canonicalPath());
    return dir.isRoot();

}

QStringList PQHandlingFileDir::listArchiveContent(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::listArchiveContent()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QStringList ret;

    QFileInfo info(path);

#ifndef Q_OS_WIN
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "unrar");
    which.waitForFinished();

    if(!which.exitCode() && PQSettings::get().getArchiveUseExternalUnrar() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

        QProcess p;
        p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

#if (QT_VERSION >= QT_VERSION_CHECK(5, 15, 0))
            QStringList allfiles = QString::fromLatin1(outdata).split('\n', Qt::SkipEmptyParts);
#else
            QStringList allfiles = QString::fromLatin1(outdata).split('\n', QString::SkipEmptyParts);
#endif
            allfiles.sort();
            foreach(QString f, allfiles) {
                if(PQImageFormats::get().getEnabledFormatsQt().contains(QFileInfo(f).suffix()))
                    ret.append(QString("%1::ARC::%2").arg(f).arg(path));
            }

        }

    } else {

#endif

#ifdef LIBARCHIVE

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

        // Read file
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLocal8Bit().data(), 10240);

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            LOG << CURDATE << "PQHandlingFileDialog::listArchiveContent: ERROR: archive_read_open_filename() returned code of " << r << NL;
            return ret;
        }

        // Loop over entries in archive
        struct archive_entry *entry;
        QStringList allfiles;
        while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

            // Read the current file entry
            QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

            // If supported file format, append to temporary list
            if((PQImageFormats::get().getEnabledFormatsQt().contains(QFileInfo(filenameinside).suffix())))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();
        foreach(QString f, allfiles)
            ret.append(QString("%1::ARC::%2").arg(f).arg(path));

        // Close archive
        r = archive_read_free(a);
        if(r != ARCHIVE_OK)
            LOG << CURDATE << "PQHandlingFileDialog::listArchiveContent: ERROR: archive_read_free() returned code of " << r << NL;

#endif

#ifndef Q_OS_WIN
    }
#endif

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);

    if(PQSettings::get().getSortImagesAscending())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    return ret;

}

QString PQHandlingFileDir::moveFile(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::moveFile()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QString ending = QFileInfo(filename).suffix();

    //: Title of filedialog to select new filename/location to move file to.
    QString newfilename = QFileDialog::getSaveFileName(0, "Where to move the file to", filename, QString("*.%1 (*.%2)").arg(ending).arg(ending));

    if(newfilename.trimmed() == "")
        return "";

    QFile file(filename);
    if(!file.copy(newfilename)) {
        LOG << CURDATE << "PQHandlingFileDir::moveFile(): ERROR: The file could not be moved to its new location, copy process failed." << NL;
        return "";
    }

    if(!file.remove()) {
        LOG << CURDATE << "PQHandlingFileDir::moveFile(): ERROR: The file was successfully copied to new location but the old file could not be removed." << NL;
        return newfilename;
    }

    return newfilename;

}

bool PQHandlingFileDir::renameFile(QString dir, QString oldName, QString newName) {

    DBG << CURDATE << "PQHandlingFileDir::renameFile()" << NL
        << CURDATE << "** dir = " << dir.toStdString() << NL
        << CURDATE << "** oldName = " << oldName.toStdString() << NL
        << CURDATE << "** newName = " << newName.toStdString() << NL;

    QFile file(dir + "/" + oldName);
    return file.rename(dir + "/" + newName);

}

QString PQHandlingFileDir::replaceSuffix(QString filename, QString newSuffix) {

    DBG << CURDATE << "PQHandlingFileDir::replaceSuffix()" << NL
        << CURDATE << "** dir = " << filename.toStdString() << NL
        << CURDATE << "** oldName = " << newSuffix.toStdString() << NL;

    QFileInfo info(filename);
    return QString("%1.%2").arg(info.baseName(), newSuffix);

}
