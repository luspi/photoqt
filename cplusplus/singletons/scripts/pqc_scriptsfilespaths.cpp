#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_settings.h>
#include <pqc_notify.h>
#include <pqc_imageformats.h>
#include <QtLogging>
#include <QtDebug>
#include <QDir>
#include <QMimeDatabase>
#include <QUrl>
#include <QStorageInfo>
#include <QCollator>
#include <QDesktopServices>
#include <QFileDialog>

PQCScriptsFilesPaths::PQCScriptsFilesPaths() {

}

PQCScriptsFilesPaths::~PQCScriptsFilesPaths() {

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
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

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
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

    bool networkPath = path.startsWith("//");
    path = QDir::cleanPath(path);
    if(networkPath)
        path = "/"+path;

    return path;

}

QString PQCScriptsFilesPaths::pathWithNativeSeparators(QString path) {

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.mid(1);
#endif

    return QDir::toNativeSeparators(path);

}

QString PQCScriptsFilesPaths::getSuffix(QString path) {

    return QFileInfo(path).completeSuffix();

}

QString PQCScriptsFilesPaths::getBasename(QString fullpath) {

    if(fullpath == "")
        return "";

    return QFileInfo(fullpath).baseName();

}

QString PQCScriptsFilesPaths::getFilename(QString fullpath) {

    if(fullpath == "")
        return "";

    return QFileInfo(fullpath).fileName();

}

QString PQCScriptsFilesPaths::getDir(QString fullpath) {

    if(fullpath == "")
        return "";

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

    if(path == "")
        return QStringList();

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    QStringList ret = dir.entryList();

    QCollator collator;
    collator.setNumericMode(true);
    std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });

    return ret;

}

QString PQCScriptsFilesPaths::getHomeDir() {
    return QDir::homePath();
}

bool PQCScriptsFilesPaths::isFolder(QString path) {
    return QFileInfo(path).isDir();
}

bool PQCScriptsFilesPaths::doesItExist(QString path) {
    return QFileInfo::exists(path);
}

bool PQCScriptsFilesPaths::isExcludeDirFromCaching(QString filename) {

    if(PQCSettings::get()["thumbnailsExcludeDropBox"].toString() != "") {
        if(filename.indexOf(PQCSettings::get()["thumbnailsExcludeDropBox"].toString())== 0)
            return true;
    }

    if(PQCSettings::get()["thumbnailsExcludeNextcloud"].toString() != "") {
        if(filename.indexOf(PQCSettings::get()["thumbnailsExcludeNextcloud"].toString())== 0)
            return true;
    }

    if(PQCSettings::get()["thumbnailsExcludeOwnCloud"].toString() != "") {
        if(filename.indexOf(PQCSettings::get()["thumbnailsExcludeOwnCloud"].toString())== 0)
            return true;
    }

    const QStringList str = PQCSettings::get()["thumbnailsExcludeFolders"].toStringList();
    for(const QString &dir: str) {
        if(filename.indexOf(dir) == 0)
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

QString PQCScriptsFilesPaths::selectFileFromDialog(QString buttonlabel, QString preselectFile, int formatId, bool confirmOverwrite) {

    QFileInfo info(preselectFile);

    PQCNotify::get().setModalFileDialogOpen(true);

    const QStringList endings = PQCImageFormats::get().getFormatEndings(formatId);

    QFileDialog diag;
    diag.setLabelText(QFileDialog::Accept, buttonlabel);
    diag.setFileMode(QFileDialog::AnyFile);
    diag.setModal(true);
    diag.setAcceptMode(QFileDialog::AcceptSave);
    if(!confirmOverwrite)
        diag.setOption(QFileDialog::DontConfirmOverwrite);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    diag.setNameFilter("*."+endings.join(" *."));
    diag.setDirectory(info.absolutePath());
    diag.selectFile(info.baseName() + "." + endings[0]);

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {
            PQCNotify::get().setModalFileDialogOpen(false);
            QString fn = fileNames[0];
            QFileInfo newinfo(fn);
            if(newinfo.suffix() == "")
                return fn+"."+endings[0];
            return fn;
        }
    }

    PQCNotify::get().setModalFileDialogOpen(false);
    return "";

}
