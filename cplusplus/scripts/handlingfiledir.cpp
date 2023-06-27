/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "handlingfiledir.h"

PQHandlingFileDir::PQHandlingFileDir() {
    animatedImageTemporaryCounter = 0;
    animatedImagesTemporaryList.clear();
}

QString PQHandlingFileDir::cleanPath(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::cleanPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    // older versions of PhotoQt used the incorrect form of only two slashes after file:
    // this was corrected everywhere starting with v3.0, but we still need to check for both

#ifdef Q_OS_WIN
    if(path.startsWith("file:///"))
        path = path.remove(0, 8);
    else if(path.startsWith("file://"))
        path = path.remove(0, 7);
#else
    if(path.startsWith("file:////"))
        path = path.remove(0, 8);
    else if(path.startsWith("file:///"))
        path = path.remove(0, 7);
#endif
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);
    else if(path.startsWith("image://folderthumb/")) {
        path = path.remove(0, 20);
        if(path.contains(":://::"))
            path = path.split(":://::")[0];
    }

#ifdef Q_OS_WIN
    path = QDir::cleanPath(path.replace("//", "|::::::::|"));
    return path.replace("|::::::::|", "//");
#else
    return QDir::cleanPath(path);
#endif

}

QString PQHandlingFileDir::copyFile(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::copyFile()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    const QString ending = QFileInfo(filename).suffix();

    //: Title of filedialog to select new filename/location to copy file to.
    QString newfilename = QFileDialog::getSaveFileName(0, "Where to copy the file to", filename, QString("*.%1 (*.%2)").arg(ending, ending));

    if(newfilename.trimmed() == "")
        return "";

    QFile file(filename);
    if(!file.copy(newfilename)) {
        LOG << CURDATE << "PQHandlingFileDir::copyFile(): ERROR: The file could not be copied to its new location." << NL;
        return "";
    }

    return newfilename;

}

bool PQHandlingFileDir::copyFileToHere(QString filename, QString targetdir) {

    DBG << CURDATE << "PQHandlingFileDir::copyFileToHere()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** targetdir = " << targetdir.toStdString() << NL;

    QFileInfo info(filename);
    if(!info.exists())
        return false;

    QString targetFilename = QString("%1/%2").arg(targetdir).arg(info.fileName());
    QFileInfo targetinfo(targetFilename);

    // file copied to itself
    if(targetFilename == filename)
        return true;

    if(targetinfo.exists()) {
        QFile tf(targetFilename);
        tf.remove();
    }

    QFile f(filename);
    return f.copy(targetFilename);

}

QString PQHandlingFileDir::copyFileToCacheDir(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::copyFileToTmpDir()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QFileInfo info(filename);
    if(!info.exists())
        return "";

    // if the image is larger than 256 MB we don't copy this
    if(info.size() > 1024*1024*256)
        return "";

    QString targetFilename = QString("%1/%2%3.%4").arg(ConfigFiles::CACHE_DIR()).arg("temp").arg(animatedImageTemporaryCounter).arg(info.suffix());
    QFileInfo targetinfo(targetFilename);

    animatedImageTemporaryCounter = (animatedImageTemporaryCounter+1)%3;
    if(!animatedImagesTemporaryList.contains(targetFilename))
        animatedImagesTemporaryList.append(targetFilename);

    // file copied to itself
    if(targetFilename == filename)
        return "";

    if(targetinfo.exists()) {
        QFile tf(targetFilename);
        tf.remove();
    }

    QFile f(filename);
    if(f.copy(targetFilename))
        return targetFilename;

    return "";

}

bool PQHandlingFileDir::deleteFile(QString filename, bool permanent) {

    DBG << CURDATE << "PQHandlingFileDir::deleteFile()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** permanent = " << permanent << NL;

    if(permanent) {
        QFileInfo info(filename);
        if(info.isDir()) {
            QDir dir(filename);
            if(!dir.removeRecursively()) {
                LOG << CURDATE << "PQHandlingFileDir::deleteFile(): Failed to delete folder recursively!" << NL;
                return false;
            }
            return true;
        }
        QFile file(filename);
        return file.remove();
    }

#ifdef Q_OS_LINUX

    // the native Qt function has some issues (at least on Linux):
    // 1) doesn't encode path in trashinfo file
    // 2) uses different convention for handling duplicate filenames
    // 3) doesn't update the directorysizes file (for folders)
    // For now, our custom implementation only supports Linux.
    return moveFileToTrash(filename);

#elif (QT_VERSION >= QT_VERSION_CHECK(5, 15, 0))

    QFile file(filename);
#ifdef Q_OS_WIN
    // we need to call moveToTrash on a different QFile object, otherwise the exists() check will return false
    // even while the file isn't deleted as it is seen as opened by PhotoQt
    QFile f(filename);
    bool ret = f.moveToTrash();
    int count = 0;
    while(file.exists() && count < 20) {
        QFile f(filename);
        ret = f.moveToTrash();
        std::this_thread::sleep_for(std::chrono::milliseconds(250));
        ++count;
    }
    return ret;
#else
    return file.moveToTrash();
#endif

#else
    return moveFileToTrash(filename);
#endif

}

void PQHandlingFileDir::deleteTemporaryAnimatedImageFiles() {

    DBG << CURDATE << "PQHandlingFileDir::deleteTemporaryAnimatedImageFiles()" << NL;

    for(const auto &f : qAsConst(animatedImagesTemporaryList)) {
        qDebug() << "deleting:" << f;
        QFile file(f);
        file.remove();
    }

}

bool PQHandlingFileDir::moveFileToTrash(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::moveFileToTrash()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

#ifdef Q_OS_WIN
    QFile file(filename);
    return file.remove();
#else

    QFileInfo info(filename);

    if(!info.exists()) {
        LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: File/Folder '" << filename.toStdString() << "' doesn't exist...?" << NL;
        return false;
    }

    // Create the meta .trashinfo file
    QString trashinfo = "[Trash Info]\n";
    trashinfo += "Path=" + QUrl(filename).toEncoded() + "\n";
    trashinfo += "DeletionDate=" + QDateTime::currentDateTime().toString("yyyy-MM-ddThh:mm:ss");

    // The base path for the Trah (files on external devices  use the external device for Trash)
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
            if(!storage.isReadOnly() && storage.isValid() && filename.startsWith(storage.rootPath()) && baseTrash.length() < storage.rootPath().length()) {
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
    QString trashFile = baseTrash + "files/" + QUrl::toPercentEncoding(QFileInfo(filename).fileName(),""," ");
    QString backupTrashFile = trashFile;

    // If there exists already a file with that name, we simply append the next higher number (sarting at 1)
    QFileInfo ensure(trashFile);
    int j = 1;
    while(ensure.exists()) {
        trashFile = backupTrashFile + QString(" (%1)").arg(j++);
        ensure.setFile(trashFile);
    }

    // Write the .trashinfo file
    QFile iF(baseTrash + "info/" + QFileInfo(trashFile).fileName() + ".trashinfo");
    if(iF.open(QIODevice::WriteOnly)) {
        QTextStream out(&iF);
        out << trashinfo;
        iF.close();
    } else {
        LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: *.trashinfo file couldn't be created!" << NL;
        return false;
    }

    if(info.isDir()) {

        QDir dir(filename);
        if(!dir.rename(filename, trashFile)) {
            LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: Unable to move directory to trash, path = " << trashFile.toStdString() << NL;
            return false;
        }

        // find directory size
        qint64 size = 0;
        QDirIterator it(trashFile, QDirIterator::Subdirectories);
        while(it.hasNext()) {
            QString cur = it.next();
            QFileInfo curinfo(cur);
            if(curinfo.isFile()) {
                size += curinfo.size();
            }
        }

        // update directorysizes files
        QFile s(baseTrash + "/directorysizes");
        s.open(QIODevice::WriteOnly|QIODevice::Append);
        QTextStream out(&s);

        QFileInfo trashFileInfo(iF);
        QString line = QString("%1 %2 %3\n").arg(size).arg(trashFileInfo.lastModified().toMSecsSinceEpoch()).arg(QString(QUrl::toPercentEncoding(QFileInfo(trashFile).fileName(),""," ")));
        out << line;
        s.close();

    } else if(info.isFile()) {

        QFile file(filename);
        if(!file.rename(trashFile)) {
            LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: Unable to move file to trash, path = " << trashFile.toStdString() << NL;
            return false;
        }

    } else {

        LOG << CURDATE << "PQHandlingFileDir::deleteFile(): ERROR: File '" << filename.toStdString() << "' doesn't appear to be file nor folder" << NL;
        return false;
    }

#endif

    return true;

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

QString PQHandlingFileDir::getDirectoryBaseName(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::getDirectoryBaseName()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QDir(path).dirName();

}

QString PQHandlingFileDir::getExistingDirectory(QString startDir) {

    DBG << CURDATE << "PQHandlingFileDir::getExistingDirectory()" << NL
        << CURDATE << "** startDir = " << startDir.toStdString() << NL;

    return QFileDialog::getExistingDirectory(nullptr, QString(), startDir);


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

QString PQHandlingFileDir::getInternalFilenameArchive(QString path) {

    DBG << CURDATE << "PQHandlingFileDir::getInternalFilename()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    if(!path.contains("::ARC::"))
        return "";

    QFileInfo info(path.split("::ARC::")[0]);
    return info.fileName();

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

bool PQHandlingFileDir::isExcludeDirFromCaching(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::isExcludeDirFromCaching()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    if(PQSettings::get()["thumbnailsExcludeDropBox"].toString() != "") {
        if(filename.indexOf(PQSettings::get()["thumbnailsExcludeDropBox"].toString())== 0)
            return true;
    }

    if(PQSettings::get()["thumbnailsExcludeNextcloud"].toString() != "") {
        if(filename.indexOf(PQSettings::get()["thumbnailsExcludeNextcloud"].toString())== 0)
            return true;
    }

    if(PQSettings::get()["thumbnailsExcludeOwnCloud"].toString() != "") {
        if(filename.indexOf(PQSettings::get()["thumbnailsExcludeOwnCloud"].toString())== 0)
            return true;
    }

    const QStringList str = PQSettings::get()["thumbnailsExcludeFolders"].toStringList();
    for(const QString &dir: str) {
        if(filename.indexOf(dir) == 0)
            return true;
    }

    return false;

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

    const QFileInfo info(path);

#ifndef Q_OS_WIN
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "unrar");
    which.waitForFinished();

    if(!which.exitCode() && PQSettings::get()["filetypesExternalUnrar"].toBool() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

        QProcess p;
        p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            // We need to use a QTextCodec as otherwise non-latin characters would be lost
#if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
            QStringList allfiles = QTextCodec::codecForMib(106)->toUnicode(outdata).split('\n', Qt::SkipEmptyParts);
#else
            QStringList allfiles = QTextCodec::codecForMib(106)->toUnicode(outdata).split('\n', QString::SkipEmptyParts);
#endif
            allfiles.sort();
            for(const QString &f : qAsConst(allfiles)) {
                if(PQImageFormats::get().getEnabledFormatsQt().contains(QFileInfo(f).suffix()))
                    ret.append(QString("%1::ARC::%2").arg(f, path));
            }

        }

    }

    // this either means there is nothing in that archive
    // or something went wrong above with unrar
    if(ret.length() == 0) {

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
            // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
            QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

            // If supported file format, append to temporary list
            if((PQImageFormats::get().getEnabledFormatsQt().contains(QFileInfo(filenameinside).suffix())))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();
        for(const QString &f : qAsConst(allfiles))
            ret.append(QString("%1::ARC::%2").arg(f, path));

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

    if(PQSettings::get()["imageviewSortImagesAscending"].toBool())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    return ret;

}

bool PQHandlingFileDir::moveFiles(QStringList filenames, QString targetDir) {

    DBG << CURDATE << "PQHandlingFileDir::moveFiles()" << NL
        << CURDATE << "** filenames = " << filenames.join(",").toStdString() << NL;

    if(filenames.length() == 0) {
        LOG << CURDATE << "PQHandlingFileDir::moveFiles(): No filenames passed on." << NL;
        return false;
    }

    QFileInfo firstinfo = QFileInfo(filenames.at(0));

    QString curdir = firstinfo.absolutePath();

    if(targetDir.trimmed() == "")
        return false;

    targetDir = cleanPath(targetDir);

    for(auto &f : qAsConst(filenames)) {


        QFile file(f);
        QFileInfo fileinfo(f);

        QString newname = QString("%1/%2").arg(targetDir).arg(fileinfo.fileName());

        bool skipfile = false;

        // first check if target file exists
        if(QFile::exists(newname)) {
            QMessageBox msg;

            msg.setText("Target file exists.");
            msg.setInformativeText(QString("The target file %1 already exists. Do you want to overwrite this file? If not, then this file will be skipped.").arg(fileinfo.fileName()));
            msg.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
            msg.setDefaultButton(QMessageBox::Yes);
            msg.setWindowModality(Qt::ApplicationModal);

            int ret = msg.exec();

            if(ret == QMessageBox::No)
                skipfile = true;
            else
                QFile::remove(newname);
        }

        if(skipfile)
            continue;

        if(!file.rename(newname)) {
            LOG << CURDATE << "PQHandlingFileDir::moveFiles(): ERROR: The file/folder could not be moved to its new location." << NL;
            LOG << CURDATE << "PQHandlingFileDir::moveFiles(): filename: '" << fileinfo.fileName().toStdString() << "'" << NL;
            continue;
        } else {
#ifdef Q_OS_WIN
            int count = 0;
            QFile oldfile(f);
            while(oldfile.exists() && count < 20) {
                QFile ff(f);
                ff.remove();
                std::this_thread::sleep_for(std::chrono::milliseconds(250));
                ++count;
            }
#endif
        }

    }

    return true;


}

QString PQHandlingFileDir::moveFile(QString filename) {

    DBG << CURDATE << "PQHandlingFileDir::moveFile()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    const QString ending = QFileInfo(filename).suffix();

    //: Title of filedialog to select new filename/location to move file to.
    QString newfilename = QFileDialog::getSaveFileName(0, "Where to move the file to", filename, QString("*.%1 (*.%2)").arg(ending, ending));

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

    const QFileInfo info(filename);
    return QString("%1.%2").arg(info.baseName(), newSuffix);

}

void PQHandlingFileDir::saveStringToNewFile(QString txt) {

    DBG << CURDATE << "PQHandlingFileDir::saveStringToNewFile()" << NL
        << CURDATE << "** txt = " << txt.toStdString() << NL;

    QString newfile = QFileDialog::getSaveFileName(nullptr, QString(), QString("%1/photoqt-%2.log").arg(QDir::homePath()).arg(QDateTime::currentDateTime().toString("yyyy-MM-dd-hhmm")));

    if(newfile == "")
        return;

    QFile file(newfile);
    file.open(QIODevice::WriteOnly|QIODevice::Truncate);
    QTextStream out(&file);
    out << txt;
    file.close();

}

QString PQHandlingFileDir::pathWithNativeSeparators(QString path) {

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.mid(1);
#endif

    return QDir::toNativeSeparators(path);

}
