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

#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_settingscpp.h>
#include <pqc_notify_cpp.h>
#include <pqc_imagehandler.h>
#include <pqc_configfiles.h>
#include <pqc_helper.h>
#include <qlogging.h>   // needed in this form to compile with Qt 6.2
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
        if(!s.isValid())
            continue;
        const QByteArrayView fsType = s.fileSystemType();
        if(fsType == "cifs" || fsType == "samba" || fsType == "fuse")
            networkshares.insert(s.rootPath());
#ifdef Q_OS_WIN
        // on windows network shares often have a fileSystemType of FAT or NTFS or therelike
        // This check excludes known physical devices assuming everything else to be remote
        if(!QString::fromUtf8(s.device()).startsWith("\\\\?\\Volume"))
            networkshares.insert(s.rootPath());
#endif
    }
#ifdef Q_OS_UNIX
    // sshfs mounts are not listed as part of mountedVolumes but we might be able to find them in mtab
    QFile f("/proc/mounts");
    if(f.open(QIODevice::ReadOnly|QIODevice::Text)) {
        QTextStream in(&f);
        QString line;
        while(in.readLineInto(&line)) {
            QList<QStringView> parts = QStringView{line}.split(u' ');
            if(parts.length() > 2 && parts[2] == u"fuse.sshfs")
                networkshares.insert(parts[1].toString());
        }
    }
#endif
    networkSharesTimer.start();
}

QString PQCScriptsFilesPaths::cleanPath(QString path) {

#ifdef Q_OS_WIN
    bool addslash = false;
    if(path.startsWith("//"))
        addslash = true;
#endif

    QUrl url(path);
    if(url.isLocalFile())
        path = url.toLocalFile();
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

    QFileInfo info(path);
    if(info.isSymLink() && info.exists())
        path = info.symLinkTarget();

#ifdef Q_OS_WIN
    path = QDir::cleanPath(path);
    if(addslash)
        return ("/"+path);
    return path;
#else
    return QDir::cleanPath(path);
#endif

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

    return QFileInfo(path).suffix();

}

QString PQCScriptsFilesPaths::getSuffixLowerCase(QString path) {

    return QFileInfo(path).suffix().toLower();

}

QString PQCScriptsFilesPaths::getCompleteSuffix(QString path) {

    return QFileInfo(path).completeSuffix();

}

QString PQCScriptsFilesPaths::getCompleteSuffixLowerCase(QString path) {

    return QFileInfo(path).completeSuffix().toLower();

}

QString PQCScriptsFilesPaths::getBasename(QString fullpath) {

    if(fullpath.isEmpty())
        return "";

    return QFileInfo(fullpath).baseName();

}

QString PQCScriptsFilesPaths::getFilename(QString fullpath) {

    if(fullpath.isEmpty())
        return "";

    return QFileInfo(PQCHelper::extractInsideFilename(fullpath)).fileName();

}

QString PQCScriptsFilesPaths::getDir(QString fullpath) {

    if(fullpath.isEmpty())
        return "";

    return QFileInfo(PQCHelper::extractInsideFilename(fullpath)).absolutePath();

}

QString PQCScriptsFilesPaths::getDirname(const QString fullpath) {

    if(fullpath.isEmpty())
        return "";

    QDir dir(fullpath);
    return dir.dirName();

}

QString PQCScriptsFilesPaths::getFullArchivePath(QString path) {

    const int idx = path.indexOf("::ARC::");
    if(idx != -1)
        return path.mid(0, idx);

    const int idx2 = path.indexOf("::ARC::");
    if(idx2 != -1)
        return path.mid(idx+7) % " (" % QString::number(path.mid(0,idx).toInt()+1) % ")";

    return path;
}

QDateTime PQCScriptsFilesPaths::getFileModified(QString path) {

    return QFileInfo(path).lastModified();

}

QString PQCScriptsFilesPaths::getFileType(QString path) {

    if(path.isEmpty())
        return "";

    QMimeDatabase db;
    return db.mimeTypeForFile(path).name();

}

QString PQCScriptsFilesPaths::getFileSizeHumanReadable(QString path) {

    if(path.isEmpty())
        return "";

    // get the bytes
    double bytes = static_cast<double>(QFileInfo(path).size());
    if(bytes < 1024)
        return QString("%1 B").arg(bytes);

    // the possible units
    const QStringList units = {"B", "KB", "MB", "GB", "TB"};
    int unitIndex = 0;

    // we keep going until we have les than 1024 of some unit
    while(bytes >= 1024 && unitIndex < units.length()-1) {
        bytes /= 1024;
        unitIndex++;
    }

    QString sizeAsStr = QString::number(bytes, 'f', 2);
    // remove trailing .00
    if(sizeAsStr.endsWith(".00"))
        sizeAsStr.chop(3);
    // and remove second zero of decimal digits if any
    // we don't need to worry about the decimal marker here
    // for example, a size of 100 will trigger the 100.00 case above first
    // only cases like 100.20 trigger this second case
    else if(sizeAsStr.endsWith("0"))
        sizeAsStr.chop(1);

    // compose final string
    return QString("%1 %2").arg(sizeAsStr, units[unitIndex]);

}

double PQCScriptsFilesPaths::convertBytesToGB(const qint64 bytes) {
    // 1073741824 := 1024*1024*1024
    return qRound(100.0*(bytes/(1073741824.0)))/100.0;
}

QString PQCScriptsFilesPaths::toPercentEncoding(QString str) {
    return QUrl::toPercentEncoding(str);
}

QString PQCScriptsFilesPaths::fromPercentEncoding(QString str) {
    return QUrl::fromPercentEncoding(str.toUtf8());
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

    if(path.isEmpty())
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
    collator.setLocale(QLocale::system());
#ifndef PQMWITHOUTICU
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);
#endif
    std::sort(ret.begin(), ret.end(), collator);

    return ret;

}

QString PQCScriptsFilesPaths::getHomeDir() {
    return QDir::homePath();
}

QString PQCScriptsFilesPaths::getTempDir() {
    return QDir::tempPath();
}

QString PQCScriptsFilesPaths::getApplicationCacheDir() {
    return PQCConfigFiles::get().CACHE_DIR();
}

bool PQCScriptsFilesPaths::isFolder(QString path) {
    return QFileInfo(path).isDir();
}

bool PQCScriptsFilesPaths::doesItExist(QString path) {
    return QFileInfo::exists(path);
}

bool PQCScriptsFilesPaths::isExcludeDirFromCaching(QString filename) {

    if(!PQCSettingsCPP::get().getThumbnailsExcludeDropBox().isEmpty()) {
        if(filename.startsWith(PQCSettingsCPP::get().getThumbnailsExcludeDropBox()))
            return true;
    }

    if(!PQCSettingsCPP::get().getThumbnailsExcludeNextcloud().isEmpty()) {
        if(filename.startsWith(PQCSettingsCPP::get().getThumbnailsExcludeNextcloud()))
            return true;
    }

    if(!PQCSettingsCPP::get().getThumbnailsExcludeOwnCloud().isEmpty()) {
        if(filename.startsWith(PQCSettingsCPP::get().getThumbnailsExcludeOwnCloud()))
            return true;
    }

    const QStringList str = PQCSettingsCPP::get().getThumbnailsExcludeFolders();
    for(const QString &dir: str) {
        if(!dir.isEmpty() && filename.startsWith(dir))
            return true;
    }

    if(PQCSettingsCPP::get().getThumbnailsExcludeNetworkShares()) {
        return isOnNetwork(filename);
    }

    return false;

}

bool PQCScriptsFilesPaths::isOnNetwork(QString filename) {

    for(const QString &dir: std::as_const(networkshares)) {
        if(!dir.isEmpty() && filename.startsWith(dir))
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
    if(!exe.isEmpty()) {

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

    return PQCScriptsFilesPaths::selectFileFromDialog(buttonlabel, preselectFile, QFileInfo(preselectFile).suffix(), confirmOverwrite);

}

QString PQCScriptsFilesPaths::selectFileFromDialog(QString buttonlabel, QString preselectFile, QString suffix, bool confirmOverwrite) {

    qDebug() << "args: buttonlabel" << buttonlabel;
    qDebug() << "args: preselectFile" << preselectFile;
    qDebug() << "args: suffix" << suffix;
    qDebug() << "args: confirmOverwrite" << confirmOverwrite;

    QFileInfo info(preselectFile);

    QFileDialog diag;
    diag.setWindowModality(Qt::ApplicationModal);
    diag.setLabelText(QFileDialog::Accept, buttonlabel);
    diag.setFileMode(QFileDialog::AnyFile);
    diag.setModal(true);
    diag.setAcceptMode(QFileDialog::AcceptSave);
    if(!confirmOverwrite)
        diag.setOption(QFileDialog::DontConfirmOverwrite);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    diag.setNameFilter("*." % suffix % ";;All Files (*.*)");
    diag.setDirectory(info.absolutePath());
    diag.selectFile(info.completeBaseName() % "." % info.completeSuffix());

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {
            QString fn = fileNames[0];
            QFileInfo newinfo(fn);
            if(newinfo.suffix().isEmpty())
                return (fn % "." % suffix);
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

    QString newfile = QFileDialog::getSaveFileName(nullptr, QString(), QDir::homePath() % "/photoqt-" % QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm") % ".log");

    if(newfile.isEmpty()) {
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

QString PQCScriptsFilesPaths::openFileFromDialog(QString buttonlabel, QString preselectFile, QSet<QString> endings) {

    qDebug() << "args: buttonlabel" << buttonlabel;
    qDebug() << "args: preselectFile" << preselectFile;
    qDebug() << "args: endings" << endings;

    QStringList fnames = openFilesFromDialog(buttonlabel, preselectFile, endings);

    if(fnames.length() > 0)
        return fnames[0];

    return "";

}

QStringList PQCScriptsFilesPaths::openFilesFromDialog(QString buttonlabel, QString preselectFile, QSet<QString> endings) {

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
    if(endings.size() > 0)
        diag.setNameFilter("*." % PQCHelper::setJoin(endings, " *.") % ";;All Files (*.*)");
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

QString PQCScriptsFilesPaths::createTooltipFilename(const QString fname) {

    QFontMetrics metrics(qApp->font());

    // if we are only slightly longer than the max width, we just go for it
    if(metrics.horizontalAdvance(fname) < 250)
        return fname.toHtmlEscaped();

    QString result = "";
    QString currentLine = "";

    // go through file name character by character
    for(const QChar &c : fname) {

        // the new string of the current line
        QString testLine = currentLine + c;

        // if it is too long, then the new character is moved to a new line
        if(metrics.horizontalAdvance(testLine) > 200) {
            result += currentLine % "\n";
            currentLine = c;
        } else {
            currentLine += c;
        }
    }

    // add final result
    result += currentLine;

    // html escape and add proper line breaks AFTER escaping
    return result.toHtmlEscaped().replace("\n", "<br>");

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
    QFile f(QDir::homePath() % "/.dropbox/host.db");
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
    QFile f(QDir::homePath() % "/.config/Nextcloud/nextcloud.cfg");
#elif defined Q_OS_WIN
    QFile f(QString("%1/Nextcloud/nextcloud.cfg").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QString txt = in.readAll();
        const int first = txt.indexOf("0\\Folders\\1\\localPath=");
        if(first > 0) {
            const QString firstStr = txt.mid(first);
            const int second = firstStr.indexOf("\n");
            QString path = firstStr.mid(0,second);
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
    QFile f(QDir::homePath() % "/.config/ownCloud/owncloud.cfg");
#elif defined Q_OS_WIN
    QFile f(QString("%1/ownCloud/owncloud.cfg").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QString txt = in.readAll();
        const int first = txt.indexOf("0\\Folders\\1\\localPath=");
        if(first > 0) {
            const QString firstStr = txt.mid(first);
            const int second = firstStr.indexOf("\n");
            QString path = firstStr.mid(0,second);
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
    // 268435456 := 1024*1024*256
    if(info.size() > 268435456)
        return toPercentEncoding(path);

    const QString tempdir = PQCConfigFiles::get().CACHE_DIR() % "/animatedfiles";
    QDir dir(tempdir);
    if(!dir.exists())
        dir.mkdir(tempdir);

    QString targetFilename = PQCConfigFiles::get().CACHE_DIR() % "/animatedfiles/temp" % QString::number(animatedImageTemporaryCounter) % "." % info.suffix();
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

    QDir dir(PQCConfigFiles::get().CACHE_DIR() % "%1/animatedfiles");
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() % "/archive/");
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() % "/clipboard/");
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() % "/motionphotos/");
    if(dir.exists())
        dir.removeRecursively();

    dir.setPath(PQCConfigFiles::get().CACHE_DIR() % "/screenshots/");
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

QString PQCScriptsFilesPaths::getSiblingFile(const QString currentFile, const int direction, int &remainingIteration, int &remainingLevelUp, int &remainingLevelDown) {

    QString siblingFile = "";

    QDir prefixDir(QFileInfo(currentFile).dir().absolutePath());

    /////////////////////////////////////////////////////////////////////////
    // Loop until we found a file or exceeded maximum counter

    while(siblingFile.isEmpty() && remainingIteration > 0 && remainingLevelUp > 0) {

        /////////////////////////////////////////////////////////////////////////
        /// // Go up a folder to find siblings

        // this is where we are currently in (stored so we don't check for files in ourselves)
        QString origDirName = prefixDir.dirName();

        // go up a level
        if(!prefixDir.cdUp())
            break;
        remainingLevelDown += 1;
        remainingLevelUp -= 1;

        // we exclude root, this can be expensive
        if(prefixDir.isRoot())
            break;

        qDebug() << "Going up to folder:" << prefixDir.absolutePath();

        /////////////////////////////////////////////////////////////////////////
        // Get all directories in parent directory (siblings to this folder)

        QDir parentDir(prefixDir.absolutePath());
        QStringList parentSiblings = parentDir.entryList(QDir::Dirs|QDir::NoDotAndDotDot);
        _sortList(parentSiblings, true);

        // our position in the directory
        const int currentIndex = parentSiblings.indexOf(origDirName);

        /////////////////////////////////////////////////////////////////////////
        // check previous/next folders for content

        // go backwards
        if(direction == -1 && currentIndex > 0) {

            // check all previous directories one by one
            for(int i = currentIndex-1; i >= 0; --i) {
                siblingFile = _findFirstFileinFolderAndSubFolder(prefixDir.absolutePath() % "/" % parentSiblings.at(i), false, remainingIteration, remainingLevelDown);
                // if we found a file or reached maximum iteration level: stop
                if(!siblingFile.isEmpty() || remainingIteration <= 0) break;
            }

        // go forwards
        } else if(direction == 1 && currentIndex < parentSiblings.length()-1) {

            // check all next directories one by one
            for(int i = currentIndex+1; i < parentSiblings.length(); ++i) {
                siblingFile = _findFirstFileinFolderAndSubFolder(prefixDir.absolutePath() % "/" % parentSiblings.at(i), true, remainingIteration, remainingLevelDown);
                // if we found a file or reached maximum iteration level: stop
                if(!siblingFile.isEmpty() || remainingIteration <= 0) break;
            }

        }

        // if nothing found one level up, repeat

    }

    return siblingFile;

}

QString PQCScriptsFilesPaths::_findFirstFileinFolderAndSubFolder(const QString folder, const bool ascendingFolder, int &remainingIteration, int &remainingDescending) {

    qDebug() << "Checking folder:" << folder;

    remainingIteration -= 1;

    QString ret = "";

    QMimeDatabase db;

    QDir dir(folder);

    QStringList fileList = dir.entryList(QDir::Files);

    if(fileList.length() > 0) {

        qDebug() << "Found" << fileList.length() << "files, checking for supported file types";

        _sortList(fileList, true);

        for(const QString &f : std::as_const(fileList)) {

            const QString fullPath = dir.absolutePath() % "/" % f;

            const QString suffix = QFileInfo(fullPath).suffix().toLower();
            if(PQCImageHandler::get().getEnabledSuffixes().contains(suffix)) {
                ret = fullPath;
                break;
            } else {
                QString mimetype = db.mimeTypeForFile(fullPath).name();
                if(PQCImageHandler::get().getEnabledMimetypes().contains(mimetype)) {
                    ret = fullPath;
                    break;
                }
            }

        }

    }

    if(ret.isEmpty() && remainingDescending > 0) {

        QStringList folderList = dir.entryList(QDir::Dirs|QDir::NoDotAndDotDot|QDir::NoSymLinks);

        if(folderList.length() > 0) {

            qDebug() << "Found" << folderList.length() << "subfolder, checking their contents";

            _sortList(folderList, ascendingFolder);

            for(const QString &f : std::as_const(folderList)) {

                remainingDescending -= 1;
                ret = _findFirstFileinFolderAndSubFolder(dir.filePath(f), ascendingFolder, remainingIteration, remainingDescending);

                if(!ret.isEmpty())
                    break;

            }

        }

    }

    return ret;

}

void PQCScriptsFilesPaths::_sortList(QStringList &lst, const bool ascending) {
    QCollator collator;
    collator.setLocale(QLocale::system());
#ifndef PQMWITHOUTICU
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);
#endif
    if(ascending)
        std::sort(lst.begin(), lst.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(lst.begin(), lst.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
}

bool PQCScriptsFilesPaths::areDirsTheSame(QString folder1, QString folder2) {
    qDebug() << "args: folder1 =" << folder1;
    qDebug() << "args: folder2 =" << folder2;
    return (QDir(folder1)==QDir(folder2));
}
