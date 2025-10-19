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

#include <qml/pqc_scriptsfilespaths.h>
#include <shared/pqc_csettings.h>
#include <shared/pqc_configfiles.h>
#include <shared/pqc_sharedconstants.h>

#include <QtDebug>
#include <QDir>
#include <QMimeDatabase>
#include <QUrl>
#include <QStorageInfo>
#include <QCollator>
#include <QDesktopServices>
#include <QFileDialog>
#include <QProcess>

PQCScriptsFilesPaths &PQCScriptsFilesPaths::get() {
    static PQCScriptsFilesPaths instance;
    return instance;
}

PQCScriptsFilesPaths::PQCScriptsFilesPaths() {
    animatedImageTemporaryCounter = 0;

    networkSharesTimer.setInterval(1000*60*5);
    connect(&networkSharesTimer, &QTimer::timeout, this, &PQCScriptsFilesPaths::detectNetworkShares);
    detectNetworkShares();
}

PQCScriptsFilesPaths::~PQCScriptsFilesPaths() { }

void PQCScriptsFilesPaths::detectNetworkShares() {
    networkshares.clear();
    const QList<QStorageInfo> info = QStorageInfo::mountedVolumes();
    for(const QStorageInfo &s : info) {
        if(s.isValid() && (s.fileSystemType() == "cifs" || s.fileSystemType() == "samba" || s.fileSystemType() == "fuse"))
            networkshares.push_back(s.rootPath());
#ifdef Q_OS_WIN
        // on windows network shares often have a fileSystemType of FAT or NTFS or therelike
        // This check excludes known physical devices assuming everything else to be remote
        if (!QString::fromLatin1(s.device()).startsWith(QLatin1String("\\\\?\\Volume")))
            networkshares.push_back(s.rootPath());
#endif
    }
#ifdef Q_OS_UNIX
    // sshfs mounts are not listed as part of mountedVolumes but we might be able to find them in mtab
    QFile f("/etc/mtab");
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QString line;
        while(in.readLineInto(&line)) {
            QStringList parts = line.split(" ");
            if(parts[2] == "fuse.sshfs")
                networkshares.push_back(parts[1]);
        }
    }
#endif
    networkSharesTimer.start();
}

QString PQCScriptsFilesPaths::cleanPath(QString path) {

#ifdef Q_OS_WIN
    return cleanPath_windows(path);
#else
    if(path.startsWith("file:////"))
        path = path.remove(0, 8);
    else if(path.startsWith("file:///"))
        path = path.remove(0, 7);
    else if(path.startsWith("file://"))
        path = path.remove(0, 6);
    else if(path.startsWith("file:/"))
        path = path.remove(0, 5);
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

    QFileInfo info(path);
    if(info.isSymLink() && info.exists())
        path = info.symLinkTarget();

    return QDir::cleanPath(path);
#endif

}

QString PQCScriptsFilesPaths::cleanPath_windows(QString path) {

    if(path.startsWith("file:///"))
        path = path.remove(0, 8);
    else if(path.startsWith("file://"))
        path = path.remove(0, 7);
    else if(path.startsWith("file:/"))
        path = path.remove(0, 6);
    else if(path.startsWith("file:"))
        path = path.remove(0, 5);
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

    QFileInfo info(path);
    if(info.isSymLink() && info.exists())
        path = info.symLinkTarget();

    bool addslash = false;
    if(path.startsWith("//"))
        addslash = true;

    path = QDir::cleanPath(path);
    if(addslash)
        path = "/"+path;

    return path;

}

QString PQCScriptsFilesPaths::pathWithNativeSeparators(QString path) {

#ifdef Q_OS_WIN
    if(path.startsWith("\\\\") && path.mid(3,1) == ":")
        path = path.mid(2);
    else if(path.startsWith("\\") && path.mid(2,1) == ":")
        path = path.mid(1);
#endif

    return QDir::toNativeSeparators(path);

}

QString PQCScriptsFilesPaths::pathFromNativeSeparators(QString path) {

#ifdef Q_OS_WIN
    if(path.startsWith("\\\\") && path.mid(3,1) == ":")
        path = path.mid(2);
    else if(path.startsWith("\\") && path.mid(2,1) == ":")
        path = path.mid(1);
#endif

    return QDir::fromNativeSeparators(path);

}

QString PQCScriptsFilesPaths::getSuffix(QString path) {

    return QFileInfo(path).completeSuffix();

}

QString PQCScriptsFilesPaths::getSuffixLowerCase(QString path) {

    return QFileInfo(path).completeSuffix().toLower();

}

QString PQCScriptsFilesPaths::getBasename(QString fullpath) {

    if(fullpath == "")
        return "";

    return QFileInfo(fullpath).baseName();

}

QString PQCScriptsFilesPaths::getFilename(QString fullpath) {

    if(fullpath == "")
        return "";

    if(fullpath.contains("::ARC::"))
        fullpath = fullpath.split("::ARC::")[0];

    return QFileInfo(fullpath).fileName();

}

QString PQCScriptsFilesPaths::getDir(QString fullpath) {

    if(fullpath == "")
        return "";

    if(fullpath.contains("::ARC::"))
        return QFileInfo(fullpath.split("::ARC::")[1]).absolutePath();
    if(fullpath.contains("::PDF::"))
        return QFileInfo(fullpath.split("::PDF::")[1]).absolutePath();

    return QFileInfo(fullpath).absolutePath();

}

QDateTime PQCScriptsFilesPaths::getFileModified(QString path) {

    return QFileInfo(path).lastModified();

}

QString PQCScriptsFilesPaths::getFileType(QString path) {

    if(path == "")
        return "";

    QMimeDatabase db;
    return db.mimeTypeForFile(path).name();

}

QString PQCScriptsFilesPaths::getFileSizeHumanReadable(QString path) {

    if(path == "")
        return "";

    const qint64 bytes = QFileInfo(path).size();

    if(bytes <= 1024)
        return QString("%1 B").arg(bytes);
    else if(bytes <= 1024*1024)
        return QString("%1 KB").arg(qRound(10.0*(bytes/1024.0))/10.0);

    return QString("%1 MB").arg(qRound(100.0*(bytes/(1024.0*1024.0)))/100.0);

}

QString PQCScriptsFilesPaths::toPercentEncoding(QString str) {
    return QUrl::toPercentEncoding(str);
}

QString PQCScriptsFilesPaths::goUpOneLevel(QString path) {
    QDir dir(path);
    dir.cdUp();
    return dir.absolutePath();
}

QString PQCScriptsFilesPaths::getWindowsDriveLetter(QString path) {

    QStorageInfo info(path);
    return info.rootPath();

}

QStringList PQCScriptsFilesPaths::getFoldersIn(QString path) {

    qDebug() << "args: path =" << path;

    if(path == "")
        return QStringList();

#ifdef Q_OS_WIN
    // Without this the top level folder list shows the folders in the application directory
    if(!path.endsWith("/"))
        path = path + "/";
#endif

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    QStringList ret = dir.entryList();

    QCollator collator;
#ifndef PQMWITHOUTICU
    collator.setNumericMode(true);
#endif
    std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });

    return ret;

}

QString PQCScriptsFilesPaths::getHomeDir() {
    return QDir::homePath();
}

QString PQCScriptsFilesPaths::getTempDir() {
    return QDir::tempPath();
}

bool PQCScriptsFilesPaths::isFolder(QString path) {
    return QFileInfo(path).isDir();
}

bool PQCScriptsFilesPaths::doesItExist(QString path) {
    return QFileInfo::exists(path);
}

bool PQCScriptsFilesPaths::isExcludeDirFromCaching(QString filename) {

    qDebug() << "args: filename =" << filename;

    if(PQCCSettings::get().getThumbnailsExcludeDropBox() != "") {
        if(filename.indexOf(PQCCSettings::get().getThumbnailsExcludeDropBox())== 0)
            return true;
    }

    if(PQCCSettings::get().getThumbnailsExcludeNextcloud() != "") {
        if(filename.indexOf(PQCCSettings::get().getThumbnailsExcludeNextcloud())== 0)
            return true;
    }

    if(PQCCSettings::get().getThumbnailsExcludeOwnCloud() != "") {
        if(filename.indexOf(PQCCSettings::get().getThumbnailsExcludeOwnCloud())== 0)
            return true;
    }

    const QStringList str = PQCCSettings::get().getThumbnailsExcludeFolders();
    for(const QString &dir: str) {
        if(dir != "" && filename.indexOf(dir) == 0)
            return true;
    }

    if(PQCCSettings::get().getThumbnailsExcludeNetworkShares()) {
        return isOnNetwork(filename);
    }

    return false;

}

bool PQCScriptsFilesPaths::isOnNetwork(QString filename) {

    qDebug() << "args: filename =" << filename;

    for(const QString &dir: std::as_const(networkshares)) {
        if(dir != "" && filename.indexOf(dir) == 0)
            return true;
    }
    return false;
}

void PQCScriptsFilesPaths::openInDefaultFileManager(QString filename) {

    qDebug() << "args: filename =" << filename;

#ifdef Q_OS_WIN

    QProcess::startDetached("explorer.exe", {"/select,", QDir::toNativeSeparators(filename)});

#else

    // Finding out what is set as default file manager
    QProcess proc;
    proc.start("xdg-mime", {"query", "default", "inode/directory"});
    proc.waitForFinished();
    QString def = proc.readAllStandardOutput().toLower();

    // If we find a supported file manager, store it in here
    QString exe = "";
    QStringList args;

    // Check for all currently supported file managers
    if(def.contains("dolphin")) {
        exe = "dolphin";
        args << "--select" << filename;
    } else if(def.contains("nautilus")) {
        exe = "nautilus";
        args << "--select" << filename;
    } else if(def.contains("konqbrowser")) {
        exe = "konqueror";
        args << "--select" << filename;
    } else if(def.contains("thunar")) {
        exe = "thunar";
        args << filename;
    } else if(def.contains("caja")) {
        exe = "caja";
        args << "--select" << filename;
    } else if(def.contains("dde-file-manager")) {
        exe = "dde-file-manager";
        args << "--show-item" << filename;
    } else if(def.contains("doublecmd")) {
        exe = "doublecmd";
        args << filename;
    } else if(def.contains("nemo")) {
        exe = "nemo";
        args << filename;
    } else if(def.contains("rox")) {
        exe = "rox";
        args << "-s" << filename;
    }

    // found a supported one
    if(exe != "") {

        QProcess proc;
        proc.setProgram(exe);
        proc.setArguments(args);
        proc.startDetached();

        // else open folder in default file manager
    } else
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(filename).absolutePath()));

#endif

}

QString PQCScriptsFilesPaths::selectFileFromDialog(QString buttonlabel, QString preselectFile, bool confirmOverwrite) {

    return selectFileFromDialog(buttonlabel, preselectFile, PQCSharedMemory::get().getImageFormatsEndings2Id().value(QFileInfo(preselectFile).suffix().toLower()), confirmOverwrite);

}

QString PQCScriptsFilesPaths::selectFileFromDialog(QString buttonlabel, QString preselectFile, int formatId, bool confirmOverwrite) {

    qDebug() << "args: buttonlabel" << buttonlabel;
    qDebug() << "args: preselectFile" << preselectFile;
    qDebug() << "args: formatId" << formatId;
    qDebug() << "args: confirmOverwrite" << confirmOverwrite;

    QFileInfo info(preselectFile);

    const QStringList endings = PQCSharedMemory::get().getImageFormatsId2Endings().value(formatId);

    QFileDialog diag;
    diag.setWindowModality(Qt::ApplicationModal);
    diag.setLabelText(QFileDialog::Accept, buttonlabel);
    diag.setFileMode(QFileDialog::AnyFile);
    diag.setModal(true);
    diag.setAcceptMode(QFileDialog::AcceptSave);
    if(!confirmOverwrite)
        diag.setOption(QFileDialog::DontConfirmOverwrite);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    diag.setNameFilter("*."+endings.join(" *.") + ";;All Files (*.*)");
    diag.setDirectory(info.absolutePath());
    diag.selectFile(info.completeBaseName() + "." + info.completeSuffix());

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {
            QString fn = fileNames[0];
            QFileInfo newinfo(fn);
            if(newinfo.suffix() == "")
                return fn+"."+endings[0];
            return fn;
        }
    }

    return "";

}

QString PQCScriptsFilesPaths::selectFolderFromDialog(QString buttonlabel, QString preselectFolder) {

    qDebug() << "args: buttonlabel" << buttonlabel;
    qDebug() << "args: preselectFolder" << preselectFolder;

    QFileInfo info(preselectFolder);


    QFileDialog diag;
    diag.setLabelText(QFileDialog::Accept, buttonlabel);
    diag.setFileMode(QFileDialog::Directory);
    diag.setModal(true);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    diag.setDirectory(preselectFolder);
    diag.selectFile(info.baseName());

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {
            return fileNames[0];
        }
    }

    return "";

}

void PQCScriptsFilesPaths::saveLogToFile(QString txt) {

    qDebug() << "args: txt.length = " << txt.length();

    QString newfile = QFileDialog::getSaveFileName(nullptr, QString(), QString("%1/photoqt-%2.log").arg(QDir::homePath(), QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm")));

    if(newfile == "") {
        return;
    }

    QFile file(newfile);
    if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        qWarning() << "ERROR opening file for saving log.";
        return;
    }
    QTextStream out(&file);
    out << txt;
    file.close();

}

QString PQCScriptsFilesPaths::openFileFromDialog(QString buttonlabel, QString preselectFile, QStringList endings) {

    qDebug() << "args: buttonlabel" << buttonlabel;
    qDebug() << "args: preselectFile" << preselectFile;
    qDebug() << "args: endings" << endings;

    QStringList fnames = openFilesFromDialog(buttonlabel, preselectFile, endings);

    if(fnames.length() > 0)
        return fnames[0];

    return "";

}

QStringList PQCScriptsFilesPaths::openFilesFromDialog(QString buttonlabel, QString preselectFile, QStringList endings) {

    qDebug() << "args: buttonlabel" << buttonlabel;
    qDebug() << "args: preselectFile" << preselectFile;
    qDebug() << "args: endings" << endings;

    QFileInfo info(preselectFile);

    QFileDialog diag;
    diag.setLabelText(QFileDialog::Accept, buttonlabel);
    diag.setFileMode(QFileDialog::ExistingFiles);
    diag.setModal(true);
    diag.setAcceptMode(QFileDialog::AcceptOpen);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    if(endings.length() > 0)
        diag.setNameFilter("*."+endings.join(" *.") + ";;All Files (*.*)");
    if(info.isFile()) {
        diag.setDirectory(info.absolutePath());
        diag.selectFile(info.fileName());
    } else
        diag.setDirectory(info.absoluteFilePath());

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {
            return fileNames;
        }
    }

    return QStringList();

}

QString PQCScriptsFilesPaths::createTooltipFilename(QString fname) {

    QMap<QString, int> widths;
    widths.insert("a", 2); widths.insert("A", 2);
    widths.insert("b", 2); widths.insert("B", 2);
    widths.insert("c", 2); widths.insert("C", 2);
    widths.insert("d", 2); widths.insert("D", 2);
    widths.insert("e", 2); widths.insert("E", 2);
    widths.insert("f", 1); widths.insert("F", 2);
    widths.insert("g", 2); widths.insert("G", 2);
    widths.insert("h", 2); widths.insert("H", 2);
    widths.insert("i", 1); widths.insert("I", 1);
    widths.insert("j", 1); widths.insert("J", 1);
    widths.insert("k", 2); widths.insert("K", 2);
    widths.insert("l", 1); widths.insert("L", 2);
    widths.insert("m", 3); widths.insert("M", 3);
    widths.insert("n", 2); widths.insert("N", 2);
    widths.insert("o", 2); widths.insert("O", 2);
    widths.insert("p", 2); widths.insert("P", 2);
    widths.insert("q", 2); widths.insert("Q", 2);
    widths.insert("r", 1); widths.insert("R", 2);
    widths.insert("s", 2); widths.insert("S", 2);
    widths.insert("t", 1); widths.insert("T", 2);
    widths.insert("u", 2); widths.insert("U", 2);
    widths.insert("v", 2); widths.insert("V", 2);
    widths.insert("w", 3); widths.insert("W", 3);
    widths.insert("x", 2); widths.insert("X", 2);
    widths.insert("y", 2); widths.insert("Y", 2);
    widths.insert("z", 2); widths.insert("Z", 2);

    int fulllength = 0;
    for(int i = 0; i < fname.length(); ++i) {
        if(widths.contains(fname.at(i)))
            fulllength += widths[fname.at(i)];
        else
            fulllength += 2;
    }

    if(fulllength < 60)
        return fname.toHtmlEscaped();

    QString ret = "";

    int len = 0;
    for(int pos = 0; pos < fname.length(); ++pos) {

        QString cur = fname.at(pos);

        ret += cur.toHtmlEscaped();
        if(widths.contains(cur))
            len += widths[cur];
        else
            len += 2;

        if(len > 60) {
            ret += "<br>";
            len = 0;
        }

    }

    return ret;

}

QString PQCScriptsFilesPaths::getExistingDirectory(QString startDir) {

    qDebug() << "args: startDir =" << startDir;

    return QFileDialog::getExistingDirectory(nullptr, QString(), startDir);

}

QString PQCScriptsFilesPaths::findDropBoxFolder() {

#if defined Q_OS_UNIX || defined Q_OS_WIN

// credit for how to find DropBox location:
// https://stackoverflow.com/questions/12118162/how-to-determine-the-dropbox-folder-location-programmatically

#ifdef Q_OS_UNIX
    QFile f(QDir::homePath()+"/.dropbox/host.db");
#else
    QFile f(QString("%1/Dropbox/host.db").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QStringList txt = in.readAll().split("\n");
        if(txt.length() > 1) {
            QString path = QByteArray::fromBase64(txt[1].toUtf8());
            if(path.endsWith("/"))
                return path.remove(path.length()-1,1);
            return path;
        }
    }
#endif

    return "";

}

QString PQCScriptsFilesPaths::findNextcloudFolder() {

#if defined Q_OS_UNIX || defined Q_OS_WIN
#if defined Q_OS_UNIX
    QFile f(QDir::homePath()+"/.config/Nextcloud/nextcloud.cfg");
#elif defined Q_OS_WIN
    QFile f(QString("%1/Nextcloud/nextcloud.cfg").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QString txt = in.readAll();
        if(txt.contains("0\\Folders\\1\\localPath=")) {
            QString path = txt.split("0\\Folders\\1\\localPath=")[1].split("\n")[0];
            if(path.endsWith("/"))
                return path.remove(path.length()-1,1);
            return path;
        }
    }
#endif

    return "";

}

QString PQCScriptsFilesPaths::findOwnCloudFolder() {

#if defined Q_OS_UNIX || defined Q_OS_WIN
#if defined Q_OS_UNIX
    QFile f(QDir::homePath()+"/.config/ownCloud/owncloud.cfg");
#elif defined Q_OS_WIN
    QFile f(QString("%1/ownCloud/owncloud.cfg").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QString txt = in.readAll();
        if(txt.contains("0\\Folders\\1\\localPath=")) {
            QString path = txt.split("0\\Folders\\1\\localPath=")[1].split("\n")[0];
            if(path.endsWith("/"))
                return path.remove(path.length()-1,1);
            return path;
        }
    }
#endif

    return "";

}

QString PQCScriptsFilesPaths::handleAnimatedImagePathAndEncode(QString path) {

    qDebug() << "args: path =" << path;

#ifndef Q_OS_WIN

    return toPercentEncoding(path);

#else

    QFileInfo info(path);
    if(!info.exists())
        return toPercentEncoding(path);

    // if the image is larger than 256 MB we don't copy this
    if(info.size() > 1024*1024*256)
        return toPercentEncoding(path);

    const QString tempdir = QString("%1/animatedfiles").arg(PQCConfigFiles::get().CACHE_DIR());
    QDir dir(tempdir);
    if(!dir.exists())
        dir.mkdir(tempdir);

    QString targetFilename = QString("%1/animatedfiles/temp%3.%4").arg(PQCConfigFiles::get().CACHE_DIR()).arg(animatedImageTemporaryCounter).arg(info.suffix());
    QFileInfo targetinfo(targetFilename);

    animatedImageTemporaryCounter = (animatedImageTemporaryCounter+1)%5;

    // file copied to itself
    if(targetFilename == path)
        return toPercentEncoding(path);

    if(targetinfo.exists()) {
        QFile tf(targetFilename);
        tf.remove();
    }

    QFile f(path);
    if(f.copy(targetFilename))
        return toPercentEncoding(targetFilename);

    return toPercentEncoding(path);

#endif

}

void PQCScriptsFilesPaths::cleanupTemporaryFiles() {

    QDir dir(QString("%1/animatedfiles").arg(PQCConfigFiles::get().CACHE_DIR()));
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() + "/archive/");
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() + "/clipboard/");
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() + "/motionphotos/");
    if(dir.exists())
        dir.removeRecursively();

}

bool PQCScriptsFilesPaths::isUrl(QString path) {

    return (path.startsWith("http://") || path.startsWith("https://") || path.startsWith("ftp://") || path.startsWith("ftps://"));

}

void PQCScriptsFilesPaths::setThumbnailBaseCacheDir(QString dir) {

    qDebug() << "args dir =" << dir;

    PQCConfigFiles::get().setThumbnailCacheBaseDir(dir);

}
